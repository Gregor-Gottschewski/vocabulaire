import 'dart:convert';
import 'dart:io';

import 'package:vocabulaire/models/vocabulary_box.dart';

class ImportController {
  static Future<VocabularyBox> importBoxFromFile(String path) async {
    final content = await File(path).readAsString(encoding: utf8);

    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid file format: expected a JSON object');
    }

    return VocabularyBox.fromMap(Map<String, dynamic>.from(decoded));
  }
}
