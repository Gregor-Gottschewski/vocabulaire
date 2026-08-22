import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/vocabulary_group.dart';
import 'app_exception.dart';
import 'usage_service.dart';

/// Owns the active Firestore listener on the current user's online
/// groups.
class GroupSyncService {
  GroupSyncService._() {
    UsageService.instance.listenable.addListener(_onUsageChanged);
  }

  static final GroupSyncService instance = GroupSyncService._();

  final ValueNotifier<List<VocabularyGroup>> _groupsNotifier = ValueNotifier(
    const [],
  );
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  bool _wasPremium = false;

  void _onUsageChanged() {
    final isPremium = UsageService.instance.listenable.value.isPremium;
    if (isPremium && !_wasPremium) {
      attach();
    }
    _wasPremium = isPremium;
  }

  /// Fires whenever the online group list changes, including metadata-only
  /// changes.
  ValueListenable<List<VocabularyGroup>> get listenable => _groupsNotifier;

  List<VocabularyGroup> get groups => _groupsNotifier.value;

  VocabularyGroup? getGroup(String groupId) {
    for (final group in groups) {
      if (group.id == groupId) return group;
    }
    return null;
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('groups');

  /// Starts the listener for the currently signed-in user.
  void attach() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _subscription?.cancel();
    _subscription = _collection(uid)
        .where('deleted', isEqualTo: false)
        .snapshots(includeMetadataChanges: true)
        .listen(
          (snapshot) {
            _groupsNotifier.value = snapshot.docs
                .map(VocabularyGroup.fromFirestore)
                .toList();
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('GroupSyncService: snapshot listener error: $error');
          },
        );
  }

  /// Stops the listener.
  void detach() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Throws [AppException] with [AppError.groupLimitReached] if creating one
  /// more group would exceed the user's online-group quota.
  void ensureGroupQuota() {
    final usage = UsageService.instance.listenable.value;
    if (usage.groupCountOnline + 1 > usage.groupLimit) {
      throw AppException(AppError.groupLimitReached);
    }
  }

  /// Throws [AppException] with [AppError.boxLimitPerGroupReached] if adding
  /// [additionalCount] boxes to [groupId] would exceed the per-group box
  /// quota.
  void ensureBoxQuota(String groupId, int additionalCount) {
    final group = getGroup(groupId);
    final current = group?.boxCountOnline ?? 0;
    if (current + additionalCount > UsageService.boxLimitPerGroup) {
      throw AppException(AppError.boxLimitPerGroupReached);
    }
  }

  Future<void> addGroup(VocabularyGroup group) async {
    final uid = _userUid();
    await _collection(uid).doc(group.id).set({
      ...group.toFirestore(),
      'ownerUid': uid,
      'deleted': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGroupFields(
    String groupId,
    Map<String, dynamic> changes,
  ) async {
    final uid = _userUid();
    await _collection(uid).doc(groupId).update({
      ...changes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softDeleteGroup(String groupId) async {
    final uid = _userUid();
    await _collection(uid).doc(groupId).update({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _userUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError(
        'GroupSyncService: write attempted before sign-in completed.',
      );
    }
    return uid;
  }
}
