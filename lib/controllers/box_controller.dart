import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/services/audio_sync_service.dart';
import 'package:vocabulaire/services/audio_upload_queue_service.dart';
import 'package:vocabulaire/services/box_sync_service.dart';
import 'package:vocabulaire/services/vocabulary_sync_service.dart';
import '../models/vocabulary.dart';

/// Hybrid facade over two box storage backends, addressed by the same
/// [VocabularyBox.id] regardless of where a box lives:
///  - local boxes: the `boxes` Hive box, keyed by [VocabularyBox.id]
///  - online boxes: Firestore, via [BoxSyncService]/[VocabularySyncService]
class BoxController {
  final Box<VocabularyBox> _localBox = Hive.box<VocabularyBox>('boxes');
  final BoxSyncService _boxSync = BoxSyncService.instance;
  final VocabularySyncService _vocabSync = VocabularySyncService.instance;
  final AudioSyncService _audioSync = AudioSyncService.instance;
  final AudioUploadQueueService _audioUploadQueue =
      AudioUploadQueueService.instance;

  /// All boxes across both backends.
  List<VocabularyBox> get boxes => [..._localBoxes, ..._onlineBoxes];

  List<VocabularyBox> get _localBoxes =>
      _localBox.values.where((b) => b.id.isNotEmpty).toList();

  List<VocabularyBox> get _onlineBoxes => _boxSync.boxes
      .map((b) => b.copyWith(vocabularies: _vocabSync.cachedVocabularies(b.id)))
      .toList();

  int get length => boxes.length;

  List<MapEntry<String, VocabularyBox>> get entries =>
      boxes.map((b) => MapEntry(b.id, b)).toList();

  bool _isLocal(String boxId) {
    final local = _localBox.get(boxId);
    return local != null && local.id.isNotEmpty;
  }

  /// Whether box [boxId] currently lives in local storage
  bool isLocal(String boxId) => _isLocal(boxId);

  VocabularyBox? getBox(String boxId) {
    final local = _localBox.get(boxId);
    if (local != null && local.id.isNotEmpty) return local;

    final online = _boxSync.getBox(boxId);
    if (online == null) return null;
    return online.copyWith(vocabularies: _vocabSync.cachedVocabularies(boxId));
  }

  /// Boxes belonging to group [groupId], across both backends.
  List<VocabularyBox> boxesForGroup(String groupId) =>
      boxes.where((b) => b.groupId == groupId).toList();

  /// Adds new boxes, either as an online or local box.
  /// A box with the name '[box.name] copy' is created if box with same
  /// already exists.
  Future<void> addBoxes(
    List<VocabularyBox> importBoxes, {
    bool online = false,
  }) async {
    List<String> names = boxes.map((box) => box.name).toList();
    for (final finalBox in importBoxes) {
      VocabularyBox box = finalBox.copyWith();
      String boxName = box.name;
      while (names.contains(boxName)) {
        boxName = "$boxName copy";
        box = box.copyWith(name: boxName);
      }
      if (online) {
        unawaited(
          _boxSync.addBox(box, box.groupId).catchError((Object error) {
            debugPrint('BoxController: background addBox failed: $error');
          }),
        );
      } else {
        await _localBox.put(box.id, box);
      }
    }
    return;
  }

  /// Deletes box with [boxId] regardless of their backend.
  void deleteBox(String boxId) {
    final box = getBox(boxId);
    if (box == null) return;

    if (_isLocal(boxId)) {
      _localBox.delete(boxId);
    } else {
      _boxSync.softDeleteBox(box.groupId, boxId);
    }
  }

  /// Updates box with [boxId] regardless of their backend.
  void updateBox(String boxId, VocabularyBox updatedBox) {
    final box = getBox(boxId);
    if (box == null) return;

    if (_isLocal(boxId)) {
      _localBox.put(boxId, updatedBox);
    } else {
      _boxSync.updateBoxFields(
        updatedBox.groupId,
        boxId,
        updatedBox.toFirestore(),
      );
    }
  }

  /// Increments the box's new-cards-reviewed-today counter and stamps
  /// [VocabularyBox.lastNewVocabularyReview] on the 0 -> 1 transition.
  void incrementNewCardsReviewedToday(String boxId, VocabularyBox current) {
    final wasZero = current.newCardsReviewedToday == 0;
    if (_isLocal(boxId)) {
      _localBox.put(
        boxId,
        current.copyWith(
          newCardsReviewedToday: current.newCardsReviewedToday + 1,
          dailyLimitResetDate: wasZero ? DateTime.now() : null,
        ),
      );
    } else {
      _boxSync.incrementNewCardsReviewedToday(
        current.groupId,
        boxId,
        resetToday: wasZero,
      );
    }
  }

  /// Returns a [ValueNotifier] that recomputes whenever any of the given
  /// boxes change.
  ValueNotifier<List<MapEntry<String, VocabularyBox>>> listenableForKeys(
    List<String> boxIds,
  ) {
    return _MergedBoxesNotifier(
      () => _entriesForKeys(boxIds),
      boxIds: boxIds,
      localBoxListenable: _localBox.listenable(keys: boxIds),
      boxSyncListenable: _boxSync.listenable,
      vocabSync: _vocabSync,
    );
  }

  /// Returns a [ValueNotifier] that recomputes whenever any box changes.
  ValueNotifier<List<MapEntry<String, VocabularyBox>>> listenableForAll() {
    return _MergedAllBoxesNotifier(
      getter: () => entries,
      localBoxListenable: _localBox.listenable(),
      boxSyncListenable: _boxSync.listenable,
      vocabSync: _vocabSync,
    );
  }

  /// Returns a [ValueNotifier] that recomputes whenever any box belonging to
  /// group [groupId] changes.
  ValueNotifier<List<MapEntry<String, VocabularyBox>>> listenableForGroup(
    String groupId,
  ) {
    return _MergedAllBoxesNotifier(
      getter: () => entries.where((e) => e.value.groupId == groupId).toList(),
      localBoxListenable: _localBox.listenable(),
      boxSyncListenable: _boxSync.listenable,
      vocabSync: _vocabSync,
    );
  }

  List<MapEntry<String, VocabularyBox>> _entriesForKeys(List<String> boxIds) {
    return boxIds
        .map((id) => getBox(id))
        .whereType<VocabularyBox>()
        .toList()
        .asMap()
        .entries
        .map((e) => MapEntry(boxIds[e.key], e.value))
        .toList();
  }

  /// Adds the given [Vocabulary] to the box indicated by [boxId].
  Future<void> addVocabularyToBox(String boxId, Vocabulary vocabulary) async {
    final box = getBox(boxId);
    if (box == null) throw StateError('Box with id $boxId not found');

    if (_isLocal(boxId)) {
      final vocabularies = List<Vocabulary>.from(box.vocabularies)
        ..add(vocabulary);
      _localBox.put(boxId, box.copyWith(vocabularies: vocabularies));
    } else {
      _boxSync.ensureVocabularyQuota(1);
      await _vocabSync.addVocabulary(box.groupId, boxId, vocabulary);
    }
  }

  void removeVocabularyFromBox(String boxId, String id) {
    final box = getBox(boxId);
    if (box == null) throw StateError('Box with id $boxId not found');

    if (_isLocal(boxId)) {
      final updated = box.copyWith(
        vocabularies: List<Vocabulary>.from(box.vocabularies)
          ..removeWhere((v) => v.id == id),
      );
      _localBox.put(boxId, updated);
    } else {
      _vocabSync.softDeleteVocabulary(box.groupId, boxId, id);
      _audioUploadQueue.cancel(id);
      unawaited(_audioSync.deleteAudio(id));
    }

    final audio = AppPaths.audioFile(id);
    if (audio.existsSync()) {
      audio.delete();
    }
  }

  void updateVocabularyInBox(String boxId, Vocabulary updatedVocabulary) {
    final box = getBox(boxId);
    if (box == null) throw StateError('Box with id $boxId not found');

    if (_isLocal(boxId)) {
      final full = List<Vocabulary>.from(box.vocabularies);
      final idx = full.indexWhere((v) => v.id == updatedVocabulary.id);

      // if vocabulary not in box idx is -1
      if (idx < 0) {
        throw StateError(
          'Vocabulary with id ${updatedVocabulary.id} not found in box with id $boxId',
        );
      }

      full[idx] = updatedVocabulary;
      _localBox.put(boxId, box.copyWith(vocabularies: full));
    } else {
      _vocabSync.updateVocabulary(box.groupId, boxId, updatedVocabulary);
    }
  }

  /// Creates vocabulary with a fresh id.
  Vocabulary createVocabulary() {
    return Vocabulary(
      word: "",
      meaning: "",
      example: "",
      cardData: Card(cardId: DateTime.now().millisecondsSinceEpoch).toMap(),
      id: const Uuid().v4(),
    );
  }
}

/// A ValueNotifier that recomputes its value whenever any of the boxes
/// identified by [boxIds] changes.
class _MergedBoxesNotifier
    extends ValueNotifier<List<MapEntry<String, VocabularyBox>>> {
  final List<MapEntry<String, VocabularyBox>> Function() _getter;
  final Set<String> _boxIds;
  final Listenable _localBoxListenable;
  final ValueListenable<List<VocabularyBox>> _boxSyncListenable;
  final VocabularySyncService _vocabSync;

  final Map<String, ValueListenable<List<Vocabulary>>> _onlineListenables = {};
  late final VoidCallback _recompute;
  late final VoidCallback _onBoxSyncChanged;

  _MergedBoxesNotifier(
    List<MapEntry<String, VocabularyBox>> Function() getter, {
    required List<String> boxIds,
    required Listenable localBoxListenable,
    required ValueListenable<List<VocabularyBox>> boxSyncListenable,
    required VocabularySyncService vocabSync,
  }) : _getter = getter,
       _boxIds = boxIds.toSet(),
       _localBoxListenable = localBoxListenable,
       _boxSyncListenable = boxSyncListenable,
       _vocabSync = vocabSync,
       super(getter()) {
    _recompute = () => value = _getter();
    _onBoxSyncChanged = () {
      _syncOnlineSubscriptions();
      value = _getter();
    };
    _localBoxListenable.addListener(_recompute);
    _boxSyncListenable.addListener(_onBoxSyncChanged);
    _syncOnlineSubscriptions();
  }

  /// Reconciles the online boxes we hold a [_vocabSync] reference for with
  /// the current [_boxSyncListenable] value, starting listeners for newly
  /// discovered boxes and releasing ones for boxes no longer present.
  void _syncOnlineSubscriptions() {
    final currentBoxes = {
      for (final b in _boxSyncListenable.value)
        if (_boxIds.contains(b.id)) b.id: b,
    };

    final staleIds = _onlineListenables.keys
        .where((id) => !currentBoxes.containsKey(id))
        .toList(growable: false);
    for (final id in staleIds) {
      _onlineListenables.remove(id)!.removeListener(_recompute);
      _vocabSync.releaseBox(id);
    }

    for (final entry in currentBoxes.entries) {
      if (_onlineListenables.containsKey(entry.key)) continue;
      final listenable = _vocabSync.listenableForBox(
        entry.value.groupId,
        entry.key,
      );
      listenable.addListener(_recompute);
      _onlineListenables[entry.key] = listenable;
    }
  }

  @override
  void dispose() {
    _localBoxListenable.removeListener(_recompute);
    _boxSyncListenable.removeListener(_onBoxSyncChanged);
    for (final entry in _onlineListenables.entries) {
      entry.value.removeListener(_recompute);
      _vocabSync.releaseBox(entry.key);
    }
    _onlineListenables.clear();
    super.dispose();
  }
}

/// A ValueNotifier that recomputes its value whenever a box changes.
class _MergedAllBoxesNotifier
    extends ValueNotifier<List<MapEntry<String, VocabularyBox>>> {
  final List<MapEntry<String, VocabularyBox>> Function() _getter;
  final Listenable _localBoxListenable;
  final ValueListenable<List<VocabularyBox>> _boxSyncListenable;
  final VocabularySyncService _vocabSync;

  final Map<String, ValueListenable<List<Vocabulary>>> _onlineListenables = {};
  late final VoidCallback _recompute;
  late final VoidCallback _onBoxSyncChanged;

  _MergedAllBoxesNotifier({
    required List<MapEntry<String, VocabularyBox>> Function() getter,
    required Listenable localBoxListenable,
    required ValueListenable<List<VocabularyBox>> boxSyncListenable,
    required VocabularySyncService vocabSync,
  }) : _getter = getter,
       _localBoxListenable = localBoxListenable,
       _boxSyncListenable = boxSyncListenable,
       _vocabSync = vocabSync,
       super(getter()) {
    _recompute = () => value = _getter();
    _onBoxSyncChanged = () {
      _syncOnlineSubscriptions();
      value = _getter();
    };
    _localBoxListenable.addListener(_recompute);
    _boxSyncListenable.addListener(_onBoxSyncChanged);
    _syncOnlineSubscriptions();
  }

  /// Reconciles the online boxes we hold a [_vocabSync] reference for with
  /// the current [_boxSyncListenable] value, starting listeners for newly
  /// discovered boxes and releasing ones for boxes no longer present.
  void _syncOnlineSubscriptions() {
    final currentBoxes = {for (final b in _boxSyncListenable.value) b.id: b};

    final staleIds = _onlineListenables.keys
        .where((id) => !currentBoxes.containsKey(id))
        .toList(growable: false);
    for (final id in staleIds) {
      _onlineListenables.remove(id)!.removeListener(_recompute);
      _vocabSync.releaseBox(id);
    }

    for (final entry in currentBoxes.entries) {
      if (_onlineListenables.containsKey(entry.key)) continue;
      final listenable = _vocabSync.listenableForBox(
        entry.value.groupId,
        entry.key,
      );
      listenable.addListener(_recompute);
      _onlineListenables[entry.key] = listenable;
    }
  }

  @override
  void dispose() {
    _localBoxListenable.removeListener(_recompute);
    _boxSyncListenable.removeListener(_onBoxSyncChanged);
    for (final entry in _onlineListenables.entries) {
      entry.value.removeListener(_recompute);
      _vocabSync.releaseBox(entry.key);
    }
    _onlineListenables.clear();
    super.dispose();
  }
}
