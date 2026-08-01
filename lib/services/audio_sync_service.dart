import 'dart:async';

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
  Future<void> uploadAudio(String boxId, String vocabId) async {
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
      await ref.putFile(file);
      await VocabularySyncService.instance.setAudioSynced(boxId, vocabId, true);
    } on FirebaseException catch (e) {
      debugPrint('AudioSyncService: upload failed for $vocabId: $e');
      throw AppException(AppError.moveBoxOnlineFailed);
    }
  }

  /// Downloads the remote audio recording for [vocabId] into
  /// [AppPaths.audioFile], unless it already exists locally.
  Future<void> downloadAudio(String boxId, String vocabId) async {
    if (!_isPremium) return;

    final file = AppPaths.audioFile(vocabId);
    if (file.existsSync()) return;

    final ref = _audioRef(vocabId);
    if (ref == null) return;

    try {
      await ref.writeToFile(file);
    } on FirebaseException catch (e) {
      debugPrint('AudioSyncService: download failed for $vocabId: $e');
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
  void syncBoxAudio(String boxId, List<Vocabulary> vocabularies) {
    if (!_isPremium) return;
    for (final vocabulary in vocabularies) {
      if (!vocabulary.audioSynced) continue;
      if (AppPaths.audioFile(vocabulary.id).existsSync()) continue;
      unawaited(downloadAudio(boxId, vocabulary.id));
    }
  }

  /// Uploads every local audio recording found among [vocabularies].
  Future<void> uploadMissingAudioForBox(
    String boxId,
    List<Vocabulary> vocabularies,
  ) async {
    if (!_isPremium) return;
    for (final vocabulary in vocabularies) {
      if (!AppPaths.audioFile(vocabulary.id).existsSync()) continue;
      unawaited(
        uploadAudio(boxId, vocabulary.id).catchError((Object error) {
          debugPrint(
            'AudioSyncService: background upload failed for '
            '${vocabulary.id}: $error',
          );
          throw Exception(error);
        }),
      );
    }
  }
}
