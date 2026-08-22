import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/models/vocabulary_group.dart';

/// Checks whether an imported [box] may join [group]: same [BoxType], and
/// for [BoxType.vocabulary] groups additionally the same language pair
/// (in either direction).
bool boxMatchesGroup(VocabularyBox box, VocabularyGroup group) {
  if (box.type != group.type) return false;
  if (group.boxType != BoxType.vocabulary) return true;
  return (box.sourceLanguage == group.sourceLanguage &&
          box.targetLanguage == group.targetLanguage) ||
      (box.sourceLanguage == group.targetLanguage &&
          box.targetLanguage == group.sourceLanguage);
}

/// Returns [box] normalized onto [group]'s own type/language/groupId values,
/// so a box imported with a swapped language direction still stores the
/// group's canonical direction.
VocabularyBox normalizeBoxForGroup(VocabularyBox box, VocabularyGroup group) {
  return box.copyWith(
    type: group.type,
    sourceLanguage: group.sourceLanguage,
    targetLanguage: group.targetLanguage,
    groupId: group.id,
  );
}
