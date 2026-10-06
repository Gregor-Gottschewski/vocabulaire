import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/group_type.dart';
import 'package:vocabulaire/models/vocabulary_group.dart';

/// Mutable value holder passed through the group-creation flow's steps.
class GroupDraft {
  String? id;
  GroupType type = GroupType.vocabulary;
  String name = '';
  String? sourceLanguage = AppLanguage.german.code;
  String? targetLanguage = AppLanguage.french.code;

  GroupDraft();

  GroupDraft.fromGroup(VocabularyGroup group)
    : id = group.id,
      type = group.boxType,
      name = group.name,
      sourceLanguage = group.sourceLanguage,
      targetLanguage = group.targetLanguage;
}
