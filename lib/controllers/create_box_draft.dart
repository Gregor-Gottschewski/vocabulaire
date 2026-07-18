import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/box_color.dart';
import 'package:vocabulaire/models/box_type.dart';

/// Mutable value holder passed through the box-creation flow's steps.
class CreateBoxDraft {
  BoxType type = BoxType.vocabulary;
  String name = '';
  String description = '';
  String icon = '📚';
  BoxColor color = BoxColor.purple;
  String? sourceLanguage = AppLanguage.german.code;
  String? targetLanguage = AppLanguage.french.code;
}
