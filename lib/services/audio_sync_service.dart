import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/vocabulary.dart';
import 'app_exception.dart';
import 'app_paths.dart';
import 'usage_service.dart';
import 'vocabulary_sync_service.dart';

/// Syncs vocabulary audio recordings (`{vocabId}.m4a`) between Firebase
/// Storage and local storage.
class AudioSyncService {
  AudioSyncService._();

  static final AudioSyncService instance = AudioSyncService._();

  bool get _isPremium => UsageService.instance.listenable.value.isPremium;

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );

  Reference? _audioRef(String vocabId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseStorage.instance.ref('users/$uid/audio/$vocabId.m4a');
  }

  /// Uploads the local audio recording for [vocabId] and marks it
  /// as synced in Firestore on success.
  ///
  /// Throws [AppException] with [AppError.audioStorageLimitReached] if the
  /// upload would exceed the user's storage quota. Other failures (network,
  /// permission) are logged and swallowed.
  Future<void> uploadAudio(String groupId, String boxId, String vocabId) async {
    if (!_isPremium) return;

    final file = AppPaths.audioFile(vocabId);
    if (!file.existsSync()) return;

    final ref = _audioRef(vocabId);
    if (ref == null) return;

    final fileSize = await file.length();
    final usage = UsageService.instance.listenable.value;
    if (usage.audioBytesUsed + fileSize > UsageService.audioStorageLimitBytes) {
      throw AppException(AppError.audioStorageLimitReached);
    }

    try {
      await _functions.httpsCallable('reserveAudioUpload').call({
        'boxId': boxId,
        'vocabId': vocabId,
        'sizeBytes': fileSize,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'resource-exhausted') {
        throw AppException(AppError.audioStorageLimitReached);
      }
      debugPrint('AudioSyncService: reservation failed for $vocabId: $e');
      throw AppException(AppError.moveBoxOnlineFailed);
    }

    try {
      await ref.putFile(file);
      await VocabularySyncService.instance.setAudioSynced(
        groupId,
        boxId,
        vocabId,
        true,
      );
    } on FirebaseException catch (e) {
      debugPrint('AudioSyncService: upload failed for $vocabId: $e');
      throw AppException(AppError.moveBoxOnlineFailed);
    }
  }

  /// Downloads the remote audio recording for [vocabId] into
  /// [AppPaths.audioFile], unless it already exists locally.
  Future<void> downloadAudio(
    String groupId,
    String boxId,
    String vocabId,
  ) async {
    if (!_isPremium) return;

    final file = AppPaths.audioFile(vocabId);
    if (file.existsSync()) return;

    final ref = _audioRef(vocabId);
    if (ref == null) return;

    try {
      await ref.writeToFile(file);
    } on FirebaseException catch (e) {
      debugPrint('AudioSyncService: download failed for $vocabId: $e');
      if (e.code == 'object-not-found') {
        await VocabularySyncService.instance.setAudioSynced(
          groupId,
          boxId,
          vocabId,
          false,
        );
      }
    }
  }

  /// Deletes the remote audio recording for [vocabId], if any.
  Future<void> deleteAudio(String vocabId) async {
    final ref = _audioRef(vocabId);
    if (ref == null) return;

    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      debugPrint('AudioSyncService: delete failed for $vocabId: $e');
    }
  }

  /// Downloads audio for every vocabulary in [vocabularies].
  void syncBoxAudio(
    String groupId,
    String boxId,
    List<Vocabulary> vocabularies,
  ) {
    if (!_isPremium) return;
    for (final vocabulary in vocabularies) {
      if (!vocabulary.audioSynced) continue;
      if (AppPaths.audioFile(vocabulary.id).existsSync()) continue;
      unawaited(downloadAudio(groupId, boxId, vocabulary.id));
    }
  }
}
