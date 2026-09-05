import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/models/pending_audio_upload.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/models/vocabulary_group.dart';
import 'package:vocabulaire/services/app_paths.dart';

/// Clears all local user data.
/// * boxes
/// * groups
/// * vocabularies
/// * pending audio uploads
/// * audios
/// * temporary data
class LocalDataDeletionService {
  LocalDataDeletionService._();

  static final LocalDataDeletionService instance = LocalDataDeletionService._();

  Future<void> clearLocalData() async {
    await Hive.box<VocabularyBox>('boxes').clear();
    await Hive.box<VocabularyGroup>('groups').clear();
    await Hive.box<PendingAudioUpload>('pendingAudioUploads').clear();
    await _deleteDirContents(Directory(AppPaths.audioDirPath));
    await _deleteDirContents(Directory(AppPaths.audioTempDirPath));
  }

  Future<void> _deleteDirContents(Directory dir) async {
    if (!await dir.exists()) return;
    await for (final entity in dir.list()) {
      await entity.delete(recursive: true);
    }
  }
}
