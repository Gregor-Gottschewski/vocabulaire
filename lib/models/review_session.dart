import 'package:vocabulaire/l10n/app_localizations.dart';

import 'box_type.dart';
import 'reviewable_item.dart';
import 'vocabulary_box.dart';

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
  final String boxKey;
  final bool onlyTimely;
  final LearningMethod method;

  ReviewSession({
    required this.boxKey,
    this.onlyTimely = true,
    this.method = LearningMethod.all,
  });

  /// Builds the flattened pool of reviewable items for [box]: every
  /// [Vocabulary] itself, plus [ConjugationItem]s.
  static List<ReviewableItem> reviewableItemsForBox(VocabularyBox box) {
    final items = <ReviewableItem>[];
    for (final v in box.vocabularies) {
      items.add(VocabularyItem(v));
      if (box.boxType == BoxType.vocabulary) {
        for (final c in v.conjugations) {
          items.add(ConjugationItem(v, c));
        }
      }
    }
    return items;
  }

  /// Filters [items] down to the ones matching [onlyTimely] and [method].
  /// Following heuristics based on FSRS card properties:
  ///   - `onlyDifficult`: Cards with difficulty >= 7.0.
  ///   - `onlyNew`: Cards that have never been reviewed (step == null).
  ///   - `onlyUnstable`: Cards with stability <= 5.0.
  ///
  /// - [onlyTimely]: If true, only include cards that are due for review (due date <= now).
  /// - [method]: The learning method to filter cards, see [LearningMethod].
  /// - [dailyLimitEnabled] / [remainingNewCards]: If a daily limit is active,
  ///   caps the number of never-reviewed cards in the result to [remainingNewCards].
  static List<ReviewableItem> filterItems(
    List<ReviewableItem> items, {
    required bool onlyTimely,
    required LearningMethod method,
    bool dailyLimitEnabled = false,
    int? remainingNewCards,
  }) {
    var list = List<ReviewableItem>.from(items);

    if (onlyTimely) {
      list = list
          .where((i) => i.card.due.compareTo(DateTime.now()) < 0)
          .toList();
    }

    switch (method) {
      case LearningMethod.onlyDifficult:
        list = list.where((i) => i.card.lastReview != null && i.card.difficulty! >= 7.0).toList();
        break;
      case LearningMethod.onlyNew:
        list = list.where((i) => i.card.lastReview == null).toList();
        break;
      case LearningMethod.onlyUnstable:
        list = list.where((i) => i.card.lastReview != null && i.card.stability! <= 5.0).toList();
        break;
      case LearningMethod.all:
        break;
    }

    if (dailyLimitEnabled && remainingNewCards != null) {
      if (remainingNewCards <= 0) {
        list = list.where((i) => i.card.lastReview != null).toList();
      } else {
        final newCards = list.where((i) => i.card.lastReview == null).toList();
        if (newCards.length > remainingNewCards) {
          final excess = newCards.length - remainingNewCards;
          final excluded = newCards
              .sublist(newCards.length - excess)
              .map((i) => i.id)
              .toSet();
          list = list.where((i) => !excluded.contains(i.id)).toList();
        }
      }
    }

    return list;
  }
}
