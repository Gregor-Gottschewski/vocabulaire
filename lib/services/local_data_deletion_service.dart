import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/controllers/settings_controller.dart';
import 'package:vocabulaire/models/app_settings.dart';
import 'package:vocabulaire/models/pending_audio_upload.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/models/vocabulary_group.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/services/local_ownership_service.dart';

/// Clears the local data of one user account.
/// * own groups
/// * boxes of own groups
/// * vocabularies and audios of those boxes
/// * pending audio uploads
/// * settings
/// * temporary data
class LocalDataDeletionService {
  LocalDataDeletionService._();

  static final LocalDataDeletionService instance = LocalDataDeletionService._();

  /// Clears local data owned by [uid]. The uid has to be read before the
  /// account is deleted, as there is no signed-in user afterwards.
  Future<void> clearLocalData(String uid) async {
    final groups = Hive.box<VocabularyGroup>('groups');
    final boxes = Hive.box<VocabularyBox>('boxes');
    final groupIds = LocalOwnershipService.instance.ownLocalGroupIds(uid: uid);

    final ownBoxes = boxes.values
        .where((b) => groupIds.contains(b.groupId))
        .toList();
    for (final box in ownBoxes) {
      for (final vocabulary in box.vocabularies) {
        final audio = AppPaths.audioFile(vocabulary.id);
        if (await audio.exists()) await audio.delete();
      }
      await boxes.delete(box.id);
    }
    await groups.deleteAll(groupIds);
    await Hive.box<PendingAudioUpload>('pendingAudioUploads').clear();
    await Hive.box<AppSettings>(SettingsController.settingsBoxName).clear();
    await _deleteDirContents(Directory(AppPaths.audioTempDirPath));
  }

  Future<void> _deleteDirContents(Directory dir) async {
    if (!await dir.exists()) return;
    await for (final entity in dir.list()) {
      await entity.delete(recursive: true);
    }
  }
}
