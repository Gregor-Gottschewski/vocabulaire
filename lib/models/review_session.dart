import 'package:vocabulaire/l10n/app_localizations.dart';

import 'vocabulary.dart';

/// Learning method for a review session.
/// - `all`: All cards in the box.
/// - `onlyDifficult`: Only cards that are difficult, difficulty is calculated in FSRS.
/// - `onlyNew`: Only new cards that haven't been reviewed before.
/// - `onlyUnstable`: Only cards that are marked as unstable.
enum LearningMethod { all, onlyDifficult, onlyNew, onlyUnstable }

/// Extension to get display name for each learning method.
extension LearningMethodExtension on LearningMethod {
  String label(AppLocalizations l10n) {
    switch (this) {
      case LearningMethod.all:
        return l10n.learningMethodAll;
      case LearningMethod.onlyDifficult:
        return l10n.learningMethodHard;
      case LearningMethod.onlyNew:
        return l10n.learningMethodNew;
      case LearningMethod.onlyUnstable:
        return l10n.learningMethodUnstable;
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

  /// Filters [vocabularies] down to the ones matching [onlyTimely] and [method].
  /// Following heuristics based on FSRS card properties:
  ///   - `onlyDifficult`: Cards with difficulty >= 7.0.
  ///   - `onlyNew`: Cards that have never been reviewed (step == null).
  ///   - `onlyUnstable`: Cards with stability <= 5.0.
  ///
  /// - [onlyTimely]: If true, only include cards that are due for review (due date <= now).
  /// - [method]: The learning method to filter cards, see [LearningMethod].
  static List<Vocabulary> filterVocabularies(
    List<Vocabulary> vocabularies, {
    required bool onlyTimely,
    required LearningMethod method,
  }) {
    var list = List<Vocabulary>.from(vocabularies);

    if (onlyTimely) {
      list = list
          .where((v) => v.card.due.compareTo(DateTime.now()) < 0)
          .toList();
    }

    switch (method) {
      case LearningMethod.onlyDifficult:
        return list.where((v) => v.card.difficulty! >= 7.0).toList();
      case LearningMethod.onlyNew:
        return list.where((v) => v.card.lastReview == null).toList();
      case LearningMethod.onlyUnstable:
        return list.where((v) => v.card.stability! <= 5.0).toList();
      case LearningMethod.all:
        return list;
    }
  }
}
