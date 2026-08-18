import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart' hide State;
import '../controllers/box_controller.dart';
import '../models/reviewable_item.dart';
import '../models/vocabulary.dart';
import '../models/vocabulary_box.dart';
import '../models/review_session.dart';

/// Controller for managing the review process of vocabulary cards in a box.
class ReviewController extends ChangeNotifier {
  final BoxController _boxController = BoxController();
  final Scheduler _scheduler = Scheduler();

  final String boxKey;
  final bool onlyTimely;
  final LearningMethod learningMethod;

  VocabularyBox? _box;
  List<ReviewableItem> _cards = [];
  int _index = 0;

  late final ValueListenable _boxListenable;

  /// Initializes the review controller with the specified box key and filters.
  /// - [boxKey]: The key of the vocabulary box to review.
  /// - [onlyTimely]: If true, only include cards that are due for review (due date <= now).
  /// - [learningMethod]: The learning method to filter cards, see [LearningMethod] enum.
  ReviewController({
    required this.boxKey,
    this.onlyTimely = true,
    this.learningMethod = LearningMethod.all,
  });

  int get index => _index;

  int get length => _cards.length;

  ReviewableItem? get current => _index < _cards.length ? _cards[_index] : null;

  List<ReviewableItem> get cards => List.unmodifiable(_cards);

  VocabularyBox? get box => _box;

  bool get isFinished => _index >= _cards.length;

  @override
  void dispose() {
    _boxListenable.removeListener(_onBoxChanged);
    super.dispose();
  }

  /// Loads the vocabulary box and applies the specified filters to prepare the review session.
  void load() {
    _cards = buildCardList();
    _index = 0;
    _boxListenable = _boxController.listenableForKeys([boxKey]);
    _boxListenable.addListener(_onBoxChanged);
    notifyListeners();
  }

  /// Remove items from current review session that were deleted from this
  /// box (as a vocabulary or a conjugation) while the review session is in
  /// progress.
  void _onBoxChanged() {
    final liveBox = _boxController.getBox(boxKey);
    if (liveBox != null) {
      final currentIds = ReviewSession.reviewableItemsForBox(
        liveBox,
      ).map((i) => i.id).toSet();
      _cards.removeWhere((i) => !currentIds.contains(i.id));
    }
    if (_index >= _cards.length) _index = _cards.length;
    notifyListeners();
  }

  /// Builds the list of reviewable items to review based on the box and applied filters.
  /// Returned list is shuffled.
  List<ReviewableItem> buildCardList() {
    var b = _boxController.getBox(boxKey);
    if (b == null) {
      throw Exception("Box with key $boxKey not found");
    }

    if (b.newCardsReviewedToday > 0 && b.isDailyLimitStale) {
      b = b.copyWith(newCardsReviewedToday: 0);
      _boxController.updateBox(boxKey, b);
    }

    _box = b;

    return ReviewSession.filterItems(
      ReviewSession.reviewableItemsForBox(b),
      onlyTimely: onlyTimely,
      method: learningMethod,
      dailyLimitEnabled: b.dailyLimitEnabled,
      remainingNewCards: b.remainingNewCardsToday,
    )..shuffle();
  }

  /// Applies the user's rating to the current card, updates the review data, and moves to the next card.
  /// - [rating]: The rating given by the user for the current card, see [Rating] enum.
  Future<bool> applyRating(Rating rating) async {
    if (_index >= _cards.length) return false;

    final item = _cards[_index];

    final liveBox = _boxController.getBox(boxKey);
    final stillPresent =
        liveBox != null &&
        ReviewSession.reviewableItemsForBox(
          liveBox,
        ).any((i) => i.id == item.id);
    if (!stillPresent) {
      skip();
      return true;
    }

    final wasNew = item.card.lastReview == null;
    final reviewResult = _scheduler.reviewCard(item.card, rating).card;
    final newCardData = reviewResult.toMap();

    final Vocabulary updatedVocab;
    final ReviewableItem updatedItem;
    if (item is VocabularyItem) {
      updatedVocab = item.vocabulary.copyWith(cardData: newCardData);
      updatedItem = VocabularyItem(updatedVocab);
    } else if (item is ConjugationItem) {
      final updatedConjugations = item.parent.conjugations
          .map(
            (c) => c.id == item.conjugation.id
                ? c.copyWith(cardData: newCardData)
                : c,
          )
          .toList();
      updatedVocab = item.parent.copyWith(conjugations: updatedConjugations);
      updatedItem = ConjugationItem(
        updatedVocab,
        updatedVocab.conjugations.firstWhere((c) => c.id == item.id),
      );
    } else {
      throw StateError('Unknown ReviewableItem variant');
    }

    _cards[_index] = updatedItem;
    if (_box != null) {
      _boxController.updateVocabularyInBox(boxKey, updatedVocab);
      if (wasNew) {
        _incrementNewCardsReviewedToday();
      }
    }

    _index++;
    notifyListeners();
    return true;
  }

  /// Increments the box's new-cards-reviewed-today counter and stamps
  /// [VocabularyBox.lastNewVocabularyReview] on the 0 -> 1 transition.
  void _incrementNewCardsReviewedToday() {
    final box = _boxController.getBox(boxKey);
    if (box == null) return;

    _boxController.incrementNewCardsReviewedToday(boxKey, box);
    _box = box.copyWith(
      newCardsReviewedToday: box.newCardsReviewedToday + 1,
      dailyLimitResetDate: box.newCardsReviewedToday == 0
          ? DateTime.now()
          : null,
    );
  }

  void skip() {
    if (_index < _cards.length) {
      _index += 1;
      notifyListeners();
    }
  }

  void reset() {
    _index = 0;
    notifyListeners();
  }
}
