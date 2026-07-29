 import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/vocabulary.dart';

/// Owns the per-box Firestore listeners on `users/{uid}/boxes/{boxId}/vocabularies`
/// for online boxes, plus one `collectionGroup('vocabularies')` listener for
/// the cross-box vocabulary tab.
class VocabularySyncService {
  VocabularySyncService._();

  static final VocabularySyncService instance = VocabularySyncService._();

  final Map<String, ValueNotifier<List<Vocabulary>>> _perBoxNotifiers = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _perBoxSubscriptions = {};
  final Map<String, int> _perBoxRefCounts = {};

  final ValueNotifier<List<Vocabulary>> _allVocabulariesNotifier =
      ValueNotifier(const []);
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _allVocabulariesSubscription;

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    String boxId,
  ) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('boxes')
      .doc(boxId)
      .collection('vocabularies');

  List<Vocabulary> cachedVocabularies(String boxId) =>
      _perBoxNotifiers[boxId]?.value ?? const [];

  /// Returns a live list of an online box's vocabularies, starting the
  /// underlying Firestore listener on first access.
  ValueListenable<List<Vocabulary>> listenableForBox(String boxId) {
    _perBoxRefCounts[boxId] = (_perBoxRefCounts[boxId] ?? 0) + 1;
    return _perBoxNotifiers.putIfAbsent(boxId, () {
      final notifier = ValueNotifier<List<Vocabulary>>(const []);
      _attachBoxListener(boxId, notifier);
      return notifier;
    });
  }

  void _attachBoxListener(
    String boxId,
    ValueNotifier<List<Vocabulary>> notifier,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _perBoxSubscriptions[boxId]?.cancel();
    _perBoxSubscriptions[boxId] = _collection(uid, boxId)
        .where('deleted', isEqualTo: false)
        .snapshots(includeMetadataChanges: true)
        .listen(
          (snapshot) {
            notifier.value = snapshot.docs
                .map(Vocabulary.fromFirestore)
                .toList();
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint(
              'VocabularySyncService: box $boxId listener error: $error',
            );
          },
        );
  }

  /// Releases one reference acquired via [listenableForBox].
  void releaseBox(String boxId) {
    final remaining = (_perBoxRefCounts[boxId] ?? 1) - 1;
    if (remaining <= 0) {
      _perBoxRefCounts.remove(boxId);
      _perBoxSubscriptions.remove(boxId)?.cancel();
      _perBoxNotifiers.remove(boxId);
    } else {
      _perBoxRefCounts[boxId] = remaining;
    }
  }

  /// Fires whenever the cross-box vocabulary list changes. Only populated
  /// while [attachAllVocabularies] is active.
  ValueListenable<List<Vocabulary>> get allVocabulariesListenable =>
      _allVocabulariesNotifier;

  /// Starts the `collectionGroup('vocabularies')` listener backing the
  /// cross-box vocabulary tab.
  void attachAllVocabularies() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _allVocabulariesSubscription?.cancel();
    _allVocabulariesSubscription = FirebaseFirestore.instance
        .collectionGroup('vocabularies')
        .where('ownerUid', isEqualTo: uid)
        .where('deleted', isEqualTo: false)
        .snapshots(includeMetadataChanges: true)
        .listen(
          (snapshot) {
            _allVocabulariesNotifier.value = snapshot.docs
                .map(Vocabulary.fromFirestore)
                .toList();
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint(
              'VocabularySyncService: all-vocabularies listener error: $error',
            );
          },
        );
  }

  void detachAllVocabularies() {
    _allVocabulariesSubscription?.cancel();
    _allVocabulariesSubscription = null;
  }

  Future<void> addVocabulary(String boxId, Vocabulary vocabulary) async {
    final uid = _requireUid();
    await _collection(uid, boxId).doc(vocabulary.id).set({
      ...vocabulary.toFirestore(),
      'ownerUid': uid,
      'deleted': false,
      'audioSynced': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateVocabulary(String boxId, Vocabulary vocabulary) async {
    final uid = _requireUid();
    await _collection(uid, boxId).doc(vocabulary.id).update({
      ...vocabulary.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> softDeleteVocabulary(String boxId, String vocabularyId) async {
    final uid = _requireUid();
    await _collection(uid, boxId).doc(vocabularyId).update({
      'deleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _requireUid() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError(
        'VocabularySyncService write attempted before sign-in completed.',
      );
    }
    return uid;
  }
}
