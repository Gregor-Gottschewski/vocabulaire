import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:fsrs/fsrs.dart';
import 'package:path/path.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_paths.dart';

class ExportController {

  static void _deleteExportDirectory() {
    final exportDir = AppPaths.applicationExportBaseDirectory;
    if (exportDir.existsSync()) {
      exportDir.deleteSync(recursive: true);
    }
  }

  /// Returns a copy of [box] without card progress data.
  static VocabularyBox _stripProgress(VocabularyBox box) {
    Map<String, dynamic> freshCardData() =>
        Card(cardId: DateTime.now().millisecondsSinceEpoch).toMap();

    return box.copyWith(
      vocabularies: box.vocabularies
          .map(
            (v) => v.copyWith(
              cardData: freshCardData(),
              conjugations: v.conjugations
                  .map((c) => c.copyWith(cardData: freshCardData()))
                  .toList(),
            ),
          )
          .toList(),
    );
  }

  /// Exports given vocabulary box with store and audio files.
  static Future<File> exportBox(
    final VocabularyBox box, {
    Directory? outputDir,
    bool includeProgress = true,
  }) async {
    if (outputDir == null) {
      _deleteExportDirectory();
    }

    late Directory tempExportDir;

    try {
      tempExportDir = await AppPaths.createBoxExportDirectory();
    } on FileSystemException catch (e) {
      throw AppException(AppError.exportDirectoryFailed, details: e);
    }

    try {
      final exportBox = includeProgress ? box : _stripProgress(box);
      final jsonString = const JsonEncoder().convert(exportBox.toMap());

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
          audioFiles.map(
            (f) => f.copy(join(audioDirectory.path, basename(f.path))),
          ),
        );
      } on FileSystemException catch (e) {
        throw AppException(AppError.exportAudioFailed, details: e);
      }

      final zipFile = File(
        join(
          (outputDir ?? AppPaths.applicationExportBaseDirectory).path,
          "${box.nameSanitized()}.vocab",
        ),
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

  /// Exports all given vocabulary boxes as `.vocab` files grouped into a
  /// single ZIP archive.
  static Future<File> exportAllBoxes(
    final List<VocabularyBox> boxes, {
    bool includeProgress = true,
  }) async {
    _deleteExportDirectory();

    late Directory tempBulkDir;

    try {
      tempBulkDir = await AppPaths.createBulkExportDirectory();
    } on FileSystemException catch (e) {
      throw AppException(AppError.exportBulkDirectoryFailed, details: e);
    }

    try {
      for (final box in boxes) {
        await exportBox(
          box,
          outputDir: tempBulkDir,
          includeProgress: includeProgress,
        );
      }

      final zipFile = File(
        join(
          AppPaths.applicationExportBaseDirectory.path,
          "vocabulaire_export.zip",
        ),
      );

      try {
        await ZipFile.createFromDirectory(
          sourceDir: tempBulkDir,
          zipFile: zipFile,
        );
      } on PlatformException catch (e) {
        throw AppException(AppError.exportBulkArchiveFailed, details: e);
      }

      return zipFile;
    } finally {
      await tempBulkDir.delete(recursive: true);
    }
  }
}
