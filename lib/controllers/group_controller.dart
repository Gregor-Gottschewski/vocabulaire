import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/models/vocabulary_group.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/services/audio_upload_queue_service.dart';
import 'package:vocabulaire/services/box_sync_service.dart';
import 'package:vocabulaire/services/group_sync_service.dart';
import 'package:vocabulaire/services/vocabulary_sync_service.dart';

/// Controller for group operations.
class GroupController {
  final Box<VocabularyGroup> _localGroups = Hive.box<VocabularyGroup>('groups');
  final Box<VocabularyBox> _localBoxes = Hive.box<VocabularyBox>('boxes');
  final GroupSyncService _groupSync = GroupSyncService.instance;
  final BoxSyncService _boxSync = BoxSyncService.instance;
  final VocabularySyncService _vocabSync = VocabularySyncService.instance;
  final AudioUploadQueueService _audioUploadQueue =
      AudioUploadQueueService.instance;

  List<VocabularyGroup> get _localGroupList =>
      _localGroups.values.where((g) => g.id.isNotEmpty).toList();

  /// All groups across both backends.
  List<VocabularyGroup> get groups => [
    ..._localGroupList,
    ..._groupSync.groups,
  ];

  List<MapEntry<String, VocabularyGroup>> get entries =>
      groups.map((g) => MapEntry(g.id, g)).toList();

  bool _isLocal(String groupId) {
    final local = _localGroups.get(groupId);
    return local != null && local.id.isNotEmpty;
  }

  /// Whether group [groupId] currently lives in local storage.
  bool isLocal(String groupId) => _isLocal(groupId);

  VocabularyGroup? getGroup(String groupId) {
    final local = _localGroups.get(groupId);
    if (local != null && local.id.isNotEmpty) return local;
    return _groupSync.getGroup(groupId);
  }

  /// Adds new groups, either as online or local groups.
  Future<void> addGroups(
    List<VocabularyGroup> newGroups, {
    bool online = false,
  }) async {
    for (final group in newGroups) {
      if (online) {
        await _groupSync.addGroup(group);
      } else {
        await _localGroups.put(group.id, group);
      }
    }
  }

  /// Updates the name of group [groupId].
  Future<void> updateGroupName(String groupId, String name) async {
    if (_isLocal(groupId)) {
      final group = getGroup(groupId);
      if (group == null) throw StateError('Group with id $groupId not found');
      await _localGroups.put(groupId, group.copyWith(name: name));
    } else {
      await _groupSync.updateGroupFields(groupId, {'name': name});
    }
  }

  /// Deletes group [groupId] together with all boxes it contains.
  Future<void> deleteGroup(String groupId) async {
    if (_isLocal(groupId)) {
      for (final box in _boxesForGroup(groupId)) {
        await _localBoxes.delete(box.id);
      }
      await _localGroups.delete(groupId);
    } else {
      await _groupSync.softDeleteGroup(groupId);
    }
  }

  List<VocabularyBox> _boxesForGroup(String groupId) => _localBoxes.values
      .where((b) => b.id.isNotEmpty && b.groupId == groupId)
      .toList();

  /// Returns a [ValueNotifier] that recomputes whenever any group changes.
  ValueNotifier<List<MapEntry<String, VocabularyGroup>>> listenableForAll() {
    return _MergedGroupsNotifier(
      getter: () => entries,
      localGroupsListenable: _localGroups.listenable(),
      groupSyncListenable: _groupSync.listenable,
    );
  }

  /// Moves a local group online, together with all of its local boxes and
  /// their vocabularies. All-or-nothing: if any step fails (quota, network,
  /// permission), everything already written online for this group is
  /// rolled back and the group/boxes remain fully local.
  Future<void> moveGroupOnline(String groupId) async {
    if (!_isLocal(groupId)) return;
    final group = _localGroups.get(groupId);
    if (group == null) throw StateError('Group with id $groupId not found');

    final boxes = _boxesForGroup(groupId);

    _groupSync.ensureGroupQuota();
    _groupSync.ensureBoxQuota(groupId, boxes.length);
    final totalVocabularies = boxes.fold<int>(
      0,
      (sum, box) => sum + box.vocabularies.length,
    );
    _boxSync.ensureVocabularyQuota(totalVocabularies);

    final syncedBoxIds = <String>[];
    try {
      await _groupSync.addGroup(group);

      for (final box in boxes) {
        await _boxSync.addBox(box, groupId);
        await _vocabSync.addVocabularies(groupId, box.id, box.vocabularies);
        syncedBoxIds.add(box.id);
      }
    } catch (error) {
      for (final boxId in syncedBoxIds) {
        await _boxSync.softDeleteBox(groupId, boxId);
      }
      await _groupSync.softDeleteGroup(groupId);
      rethrow;
    }

    for (final box in boxes) {
      await _localBoxes.delete(box.id);
      for (final vocabulary in box.vocabularies) {
        if (AppPaths.audioFile(vocabulary.id).existsSync()) {
          _audioUploadQueue.enqueue(groupId, box.id, vocabulary.id);
        }
      }
    }
    await _localGroups.delete(groupId);
  }

  /// Moves an online group back to local storage, together with all of its
  /// boxes and their vocabularies.
  Future<void> moveGroupOffline(String groupId) async {
    if (_isLocal(groupId)) return;
    final group = getGroup(groupId);
    if (group == null) throw StateError('Group with id $groupId not found');

    final onlineBoxes = _boxSync.boxes
        .where((b) => b.groupId == groupId)
        .map(
          (b) => b.copyWith(vocabularies: _vocabSync.cachedVocabularies(b.id)),
        )
        .toList();

    for (final box in onlineBoxes) {
      for (final vocabulary in box.vocabularies) {
        _audioUploadQueue.cancel(vocabulary.id);
      }
      await _localBoxes.put(box.id, box.copyWith(deleted: false));
      await _boxSync.softDeleteBox(groupId, box.id);
    }

    await _localGroups.put(groupId, group.copyWith(deleted: false));
    await _groupSync.softDeleteGroup(groupId);
  }
}

/// A ValueNotifier that recomputes its value whenever a group changes.
class _MergedGroupsNotifier
    extends ValueNotifier<List<MapEntry<String, VocabularyGroup>>> {
  final List<MapEntry<String, VocabularyGroup>> Function() _getter;
  final Listenable _localGroupsListenable;
  final ValueListenable<List<VocabularyGroup>> _groupSyncListenable;
  late final VoidCallback _recompute;

  _MergedGroupsNotifier({
    required List<MapEntry<String, VocabularyGroup>> Function() getter,
    required Listenable localGroupsListenable,
    required ValueListenable<List<VocabularyGroup>> groupSyncListenable,
  }) : _getter = getter,
       _localGroupsListenable = localGroupsListenable,
       _groupSyncListenable = groupSyncListenable,
       super(getter()) {
    _recompute = () => value = _getter();
    _localGroupsListenable.addListener(_recompute);
    _groupSyncListenable.addListener(_recompute);
  }

  @override
  void dispose() {
    _localGroupsListenable.removeListener(_recompute);
    _groupSyncListenable.removeListener(_recompute);
    super.dispose();
  }
}
