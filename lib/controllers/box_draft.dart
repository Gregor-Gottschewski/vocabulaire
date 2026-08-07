import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';

/// Mutable value holder passed through the box-creation flow's steps.
class BoxDraft {
  String? id;
  BoxType type = BoxType.vocabulary;
  String name = '';
  String description = '';
  String? sourceLanguage = AppLanguage.german.code;
  String? targetLanguage = AppLanguage.french.code;

  BoxDraft();

  BoxDraft.fromBox(VocabularyBox box)
    : id = box.id,
      type = box.boxType,
      name = box.name,
      description = box.description,
      sourceLanguage = box.sourceLanguage,
      targetLanguage = box.targetLanguage;
}
