import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/vocabulary_box.dart';

/// Owns the active Firestore listener on the current user's online
/// boxes (`users/{uid}/boxes`, `deleted == false`) and exposes them as a
/// [ValueListenable].
/// — [BoxController] is the sole consumer, other call sites go through it.
class BoxSyncService {
  BoxSyncService._();

  static final BoxSyncService instance = BoxSyncService._();

  final ValueNotifier<List<VocabularyBox>> _boxesNotifier = ValueNotifier(
    const [],
  );
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

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

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('boxes');

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
            hasPendingWrites = snapshot.metadata.hasPendingWrites;
            isFromCache = snapshot.metadata.isFromCache;
            _boxesNotifier.value = snapshot.docs
                .map(VocabularyBox.fromFirestore)
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

  Future<void> addBox(VocabularyBox box) async {
    final uid = _requireUid();
    await _collection(uid).doc(box.id).set({
      ...box.toFirestore(),
      'ownerUid': uid,
      'deleted': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBoxFields(
    String boxId,
    Map<String, dynamic> changes,
  ) async {
    final uid = _requireUid();
    await _collection(uid).doc(boxId).update({
      ...changes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increments [VocabularyBox.newCardsReviewedToday] atomically.
  Future<void> incrementNewCardsReviewedToday(
    String boxId, {
    required bool resetToday,
  }) async {
    final uid = _requireUid();
    await _collection(uid).doc(boxId).update({
      'newCardsReviewedToday': resetToday
          ? 1
          : FieldValue.increment(1),
      if (resetToday) 'lastNewVocabularyReview': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softDeleteBox(String boxId) async {
    final uid = _requireUid();
    await _collection(uid).doc(boxId).update({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Hard-deletes the box document.
  Future<void> hardDeleteBox(String boxId) async {
    final uid = _requireUid();
    await _collection(uid).doc(boxId).delete();
  }

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError(
        'BoxSyncService write attempted before sign-in completed.',
      );
    }
    return uid;
  }
}
