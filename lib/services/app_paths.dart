import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppPaths {
  static late final Directory _applicationDocumentsBaseDir;
  static late final Directory _applicationSupportBaseDir;
  static late final String audioDirPath;

  static Future<void> init() async {
    _applicationDocumentsBaseDir = await getApplicationDocumentsDirectory();
    _applicationSupportBaseDir = await getApplicationSupportDirectory();
    audioDirPath = p.join(_applicationDocumentsBaseDir.path, 'audio');
    final dir = Directory(audioDirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  static String audioFilePath(String cardId) {
    return p.join(audioDirPath, '$cardId.m4a');
  }

  static File audioFile(String cardId) => File(audioFilePath(cardId));
}