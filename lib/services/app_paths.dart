import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AppPaths {
  static late final Directory _applicationDocumentsBaseDir;
  static late final Directory _applicationSupportBaseDir;
  static late final Directory _applicationTempBaseDir;
  static late final String audioDirPath;

  static Future<void> init() async {
    _applicationDocumentsBaseDir = await getApplicationDocumentsDirectory();
    _applicationSupportBaseDir = await getApplicationSupportDirectory();
    _applicationTempBaseDir = await getTemporaryDirectory();
    audioDirPath = p.join(_applicationDocumentsBaseDir.path, 'audio');
    final dir = Directory(audioDirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final exportDir = applicationExportBaseDirectory;
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
  }

  static String audioFilePath(String cardId) {
    return p.join(audioDirPath, '$cardId.m4a');
  }

  static File audioFile(String cardId) => File(audioFilePath(cardId));

  static Directory get applicationExtractDirectory =>
      Directory(p.join(_applicationTempBaseDir.path, 'extracted'));

  static Directory get applicationExportBaseDirectory =>
      Directory(p.join(_applicationSupportBaseDir.path, "export"));

  static Future<Directory> createBoxExportDirectory() async =>
      Directory(p.join(applicationExportBaseDirectory.path, Uuid().v4())).create(recursive: true);
}
