import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/vocabulary.dart';
import 'audio_sync_service.dart';

/// Owns the per-box Firestore listeners on
/// `users/{uid}/groups/{groupId}/boxes/{boxId}/vocabularies` for online
/// boxes.
class VocabularySyncService {
  VocabularySyncService._();

  static final VocabularySyncService instance = VocabularySyncService._();

  final Map<String, ValueNotifier<List<Vocabulary>>> _perBoxNotifiers = {};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _perBoxSubscriptions = {};
  final Map<String, int> _perBoxRefCounts = {};

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    String groupId,
    String boxId,
  ) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('groups')
      .doc(groupId)
      .collection('boxes')
      .doc(boxId)
      .collection('vocabularies');

  List<Vocabulary> cachedVocabularies(String boxId) =>
      _perBoxNotifiers[boxId]?.value ?? const [];

  /// Returns a live list of an online box's vocabularies, starting the
  /// underlying Firestore listener on first access.
  ValueListenable<List<Vocabulary>> listenableForBox(
    String groupId,
    String boxId,
  ) {
    _perBoxRefCounts[boxId] = (_perBoxRefCounts[boxId] ?? 0) + 1;
    return _perBoxNotifiers.putIfAbsent(boxId, () {
      final notifier = ValueNotifier<List<Vocabulary>>(const []);
      _attachBoxListener(groupId, boxId, notifier);
      return notifier;
    });
  }

  void _attachBoxListener(
    String groupId,
    String boxId,
    ValueNotifier<List<Vocabulary>> notifier,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _perBoxSubscriptions[boxId]?.cancel();
    _perBoxSubscriptions[boxId] = _collection(uid, groupId, boxId)
        .where('deleted', isEqualTo: false)
        .snapshots(includeMetadataChanges: true)
        .listen(
          (snapshot) {
            notifier.value = snapshot.docs
                .map(Vocabulary.fromFirestore)
                .toList();
            AudioSyncService.instance.syncBoxAudio(
              groupId,
              boxId,
              notifier.value,
            );
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

  Future<void> addVocabulary(
    String groupId,
    String boxId,
    Vocabulary vocabulary,
  ) async {
    final uid = _requireUid();
    await _collection(uid, groupId, boxId).doc(vocabulary.id).set({
      ...vocabulary.toFirestore(),
      'ownerUid': uid,
      'deleted': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Uploads [vocabularies] into [boxId]'s subcollection in chunked batches.
  /// Writes the same per-document fields as [addVocabulary].
  Future<void> addVocabularies(
    String groupId,
    String boxId,
    List<Vocabulary> vocabularies,
  ) async {
    final uid = _requireUid();
    const chunkSize = 400;
    for (var i = 0; i < vocabularies.length; i += chunkSize) {
      final batch = FirebaseFirestore.instance.batch();
      for (final vocabulary in vocabularies.skip(i).take(chunkSize)) {
        batch.set(_collection(uid, groupId, boxId).doc(vocabulary.id), {
          ...vocabulary.toFirestore(),
          'ownerUid': uid,
          'deleted': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  Future<void> updateVocabulary(
    String groupId,
    String boxId,
    Vocabulary vocabulary,
  ) async {
    final uid = _requireUid();
    await _collection(uid, groupId, boxId).doc(vocabulary.id).update({
      ...vocabulary.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates the [Vocabulary.audioSynced] flag
  Future<void> setAudioSynced(
    String groupId,
    String boxId,
    String vocabularyId,
    bool value,
  ) async {
    final uid = _requireUid();
    await _collection(
      uid,
      groupId,
      boxId,
    ).doc(vocabularyId).update({'audioSynced': value});
  }

  Future<void> softDeleteVocabulary(
    String groupId,
    String boxId,
    String vocabularyId,
  ) async {
    final uid = _requireUid();
    await _collection(uid, groupId, boxId).doc(vocabularyId).update({
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
