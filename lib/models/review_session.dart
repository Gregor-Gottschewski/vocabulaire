/// Learning method for a review session.
/// - `all`: All cards in the box.
/// - `onlyDifficult`: Only cards that are difficult, difficulty is calculated in FSRS.
/// - `onlyNew`: Only new cards that haven't been reviewed before.
/// - `onlyUnstable`: Only cards that are marked as unstable.
enum LearningMethod {
  all,
  onlyDifficult,
  onlyNew,
  onlyUnstable,
}

/// Extension to get display name for each learning method.
extension LearningMethodExtension on LearningMethod {
  String get displayName {
    switch (this) {
      case LearningMethod.all:
        return 'Alle';
      case LearningMethod.onlyDifficult:
        return 'Nur schwierige';
      case LearningMethod.onlyNew:
        return 'Nur neue';
      case LearningMethod.onlyUnstable:
        return 'Nur Instabile';
    }
  }
}

/// Represents a review session for a specific box with a chosen learning method.
class ReviewSession {
  final dynamic boxKey;
  final bool onlyTimely;
  final LearningMethod method;

  ReviewSession({
    required this.boxKey,
    this.onlyTimely = true,
    this.method = LearningMethod.all,
  });
}