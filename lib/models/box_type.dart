
/// Represents the type of a [VocabularyBox].
enum BoxType {
  vocabulary,
  flashcard;

  /// Returns [BoxType] element based on input.
  /// Default is [BoxType.flashcard] if string name unknown.
  static BoxType fromName(String name) {
    return BoxType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => BoxType.flashcard,
    );
  }
}
