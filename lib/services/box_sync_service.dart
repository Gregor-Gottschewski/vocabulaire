import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/vocabulary_box.dart';
import 'app_exception.dart';
import 'usage_service.dart';

/// Owns the active Firestore listener on the current user's online
/// boxes (`users/{uid}/groups/*/boxes`, `deleted == false`, queried via
/// `collectionGroup('boxes')`) and exposes them as a [ValueListenable].
/// — [BoxController] is the sole consumer, other call sites go through it.
class BoxSyncService {
  BoxSyncService._() {
    UsageService.instance.listenable.addListener(_onUsageChanged);
  }

  static final BoxSyncService instance = BoxSyncService._();

  final ValueNotifier<List<VocabularyBox>> _boxesNotifier = ValueNotifier(
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

  /// Fires whenever the online box list changes, including metadata-only
  /// changes.
  ValueListenable<List<VocabularyBox>> get listenable => _boxesNotifier;

  List<VocabularyBox> get boxes => _boxesNotifier.value;

  /// True while the most recent snapshot contains writes that have not yet
  /// been acknowledged by the server.
  bool hasPendingWrites = false;

  /// True while the most recent snapshot was served entirely from the local
  /// cache rather than the server
  bool isFromCache = false;

  VocabularyBox? getBox(String boxId) {
    for (final box in boxes) {
      if (box.id == boxId) return box;
    }
    return null;
  }

  CollectionReference<Map<String, dynamic>> _boxesCollection(
    String uid,
    String groupId,
  ) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('groups')
      .doc(groupId)
      .collection('boxes');

  /// Starts the listener for the currently signed-in user. Uses a
  /// `collectionGroup('boxes')` query so it doesn't need to know the set of
  /// groups upfront — new/removed groups are picked up automatically.
  void attach() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collectionGroup('boxes')
        .where('ownerUid', isEqualTo: uid)
        .where('deleted', isEqualTo: false)
        .snapshots(includeMetadataChanges: true)
        .listen(
          (snapshot) {
            hasPendingWrites = snapshot.metadata.hasPendingWrites;
            isFromCache = snapshot.metadata.isFromCache;
            _boxesNotifier.value = snapshot.docs
                .map(
                  (doc) => VocabularyBox.fromFirestore(
                    doc,
                  ).copyWith(groupId: doc.reference.parent.parent!.id),
                )
                .toList();
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('BoxSyncService: snapshot listener error: $error');
          },
        );
  }

  /// Stops the listener
  void detach() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Throws [AppException] with [AppError.vocabularyLimitReached] if adding
  /// [additionalCount] vocabularies would exceed the user's online-vocabulary
  /// quota
  void ensureVocabularyQuota(int additionalCount) {
    final usage = UsageService.instance.listenable.value;
    if (usage.vocabularyCountOnline + additionalCount > usage.vocabularyLimit) {
      throw AppException(AppError.vocabularyLimitReached);
    }
  }

  Future<void> addBox(VocabularyBox box, String groupId) async {
    final uid = _userUid();
    await _boxesCollection(uid, groupId).doc(box.id).set({
      ...box.toFirestore(),
      'ownerUid': uid,
      'deleted': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBoxFields(
    String groupId,
    String boxId,
    Map<String, dynamic> changes,
  ) async {
    final uid = _userUid();
    await _boxesCollection(uid, groupId).doc(boxId).update({
      ...changes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increments [VocabularyBox.newCardsReviewedToday] atomically.
  Future<void> incrementNewCardsReviewedToday(
    String groupId,
    String boxId, {
    required bool resetToday,
  }) async {
    final uid = _userUid();
    await _boxesCollection(uid, groupId).doc(boxId).update({
      'newCardsReviewedToday': resetToday ? 1 : FieldValue.increment(1),
      if (resetToday) 'lastNewVocabularyReview': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softDeleteBox(String groupId, String boxId) async {
    final uid = _userUid();
    await _boxesCollection(uid, groupId).doc(boxId).update({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _userUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError(
        'BoxSyncService: write attempted before sign-in completed.',
      );
    }
    return uid;
  }
}
