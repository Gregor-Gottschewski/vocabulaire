import 'dart:convert';
import 'dart:io';

import 'package:flutter_archive/flutter_archive.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_paths.dart';

class ImportController {
  /// Imports the box with the given path.
  /// This extracts the given archive (`.vocab`, `.zip`) into a temporary directory.
  /// Temporary directory has name: {base-name}{DateTime.now()}
  ///   - `base-name` is the name of the given archive without extension
  /// Afterwards, it extracts the included `store.json` that contains the vocabulary
  /// and copies the included audio in /audio directory to the app storage.
  static Future<VocabularyBox> importBoxFromFile(final String path) async {
    Directory extractedVocabularyBox = await _extractZip(path);

    try {
      VocabularyBox box = await _readStoreFile(extractedVocabularyBox.path);

      BoxController boxController = BoxController();

      Map<String, String> newIds = {};
      Set<String?> ids = boxController.vocabularyIDs;

      final safeVocabularies = box.vocabularies.map((v) {
        final newId = boxController.generateUniqueId(ids);
        newIds[v.id] = newId;
        ids.add(newId);
        return v.copyWith(id: newId);
      }).toList();

      await _importAudioFiles(
        Directory(join(extractedVocabularyBox.path, "audio")),
        newIds,
      );

      return VocabularyBox(
        name: box.name,
        description: box.description,
        vocabularies: safeVocabularies,
      );
    } finally {
      await extractedVocabularyBox.delete(recursive: true);
    }
  }

  /// Reads the given vocabulary box store.
  ///
  /// [extractedVocabularyBox] path to the vocabulary box root.
  ///
  /// Returns the decoded vocabulary box.
  static Future<VocabularyBox> _readStoreFile(final String extractedVocabularyBox) async {
    final store = File(join(extractedVocabularyBox, 'store.json'));

    if (!await store.exists()) {
      throw Exception('Invalid file format: store.json not found in archive');
    }

    final decoded = jsonDecode(await store.readAsString(encoding: utf8));
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid file format: expected a JSON object');
    }

    return VocabularyBox.fromMap(Map<String, dynamic>.from(decoded));
  }

  /// Extracts the vocabulary box with the given path.
  ///
  /// [path] path to the vocabulary import.
  ///
  /// Returns [Directory] with extracted vocabulary box.
  static Future<Directory> _extractZip(final String path) async {
    final extractDir = Directory(
      join(AppPaths.applicationExtractDirectory.path, Uuid().v4()),
    )..create(recursive: true);

    await ZipFile.extractToDirectory(
      zipFile: File(path),
      destinationDir: extractDir,
    );

    return extractDir;
  }

  /// Imports all `.m4a` files in given directory.
  static Future<void> _importAudioFiles(
    Directory audioDir,
    Map<String, String> idChanges,
  ) async {
    if (!await audioDir.exists()) return;

    final files = (await audioDir.list().toList()).whereType<File>();
    await Future.wait(
      files.where((file) => extension(file.path) == ".m4a").map((file) {
        String fileName = basenameWithoutExtension(file.path);
        if (idChanges[fileName] != null) {
          fileName = idChanges[fileName]!;
        }
        return file.copy(AppPaths.audioFilePath(fileName));
      }),
    );
  }
}
