import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_paths.dart';

class ExportController {
  /// Exports given vocabulary box with store and audio files.
  static Future<File> exportBox(final VocabularyBox box) async {
    late Directory tempExportDir;

    try {
      tempExportDir = await AppPaths.createBoxExportDirectory();
    } on FileSystemException catch (e) {
      throw Exception('Temporäres Exportverzeichnis konnte nicht erstellt werden: ${e.message}');
    }

    try {
      final jsonString = const JsonEncoder().convert(box.toMap());

      final file = File(join(tempExportDir.path, "store.json"));

      try {
        await file.writeAsString(jsonString, encoding: utf8);
      } on FileSystemException catch (e) {
        throw Exception('Vokabeldaten konnten nicht gespeichert werden: ${e.message}');
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
        throw Exception('Audiodateien konnten nicht kopiert werden: ${e.message}');
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
        throw Exception('Archiv konnte nicht erstellt werden: ${e.message}');
      }

      return zipFile;
    } finally {
      await tempExportDir.delete(recursive: true);
    }
  }
}