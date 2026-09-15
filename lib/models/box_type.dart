
/// Represents the type of a [VocabularyBox].
enum GroupType {
  vocabulary,
  flashcard;

  /// Returns [GroupType] element based on input.
  /// Default is [GroupType.flashcard] if string name unknown.
  static GroupType fromName(String name) {
    return GroupType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => GroupType.flashcard,
    );
  }
}
