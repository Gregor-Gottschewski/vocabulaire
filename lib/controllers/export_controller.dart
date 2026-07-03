import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_paths.dart';

class ExportController {
  /// Exports given vocabulary box with store and audio files.
  static Future<File> exportBox(final VocabularyBox box) async {
    late Directory tempExportDir;

    try {
      tempExportDir = await AppPaths.createBoxExportDirectory();
    } on FileSystemException catch (e) {
      throw AppException(AppError.exportDirectoryFailed, details: e);
    }

    try {
      final jsonString = const JsonEncoder().convert(box.toMap());

      final file = File(join(tempExportDir.path, "store.json"));

      try {
        await file.writeAsString(jsonString, encoding: utf8);
      } on FileSystemException catch (e) {
        throw AppException(AppError.exportWriteFailed, details: e);
      }

      final audioDirectory = Directory(join(tempExportDir.path, "audio"));
      await audioDirectory.create();

      final audioFiles = box.vocabularies
          .map((v) => AppPaths.audioFile(v.id))
          .where((f) => f.existsSync());

      try {
        await Future.wait(
          audioFiles.map((f) => f.copy(join(audioDirectory.path, basename(f.path)))),
        );
      } on FileSystemException catch (e) {
        throw AppException(AppError.exportAudioFailed, details: e);
      }

      final zipFile = File(
        join(AppPaths.applicationExportBaseDirectory.path, "${box.nameSanitized()}.vocab"),
      );

      try {
        await ZipFile.createFromDirectory(
          sourceDir: tempExportDir,
          zipFile: zipFile,
        );
      } on PlatformException catch (e) {
        throw AppException(AppError.exportArchiveFailed, details: e);
      }

      return zipFile;
    } finally {
      await tempExportDir.delete(recursive: true);
    }
  }
}