import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart' hide State;
import '../controllers/box_controller.dart';
import '../models/vocabulary.dart';
import '../models/vocabulary_box.dart';
import '../models/review_session.dart';

/// Controller for managing the review process of vocabulary cards in a box.
class ReviewController extends ChangeNotifier {
  final BoxController _boxController = BoxController();
  final Scheduler _scheduler = Scheduler();

  final dynamic boxKey;
  final bool onlyTimely;
  final LearningMethod learningMethod;

  VocabularyBox? _box;
  List<Vocabulary> _cards = [];
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

  Vocabulary? get current => _index < _cards.length ? _cards[_index] : null;

  List<Vocabulary> get cards => List.unmodifiable(_cards);

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

  /// Remove vocabularies from current review session that are deleted.
  void _onBoxChanged() {
    _cards.removeWhere((v) => !_boxController.vocabularyIDs.contains(v.id));
    if (_index >= _cards.length) _index = _cards.length;
    notifyListeners();
  }

  /// Builds the list of vocabularies to review based on the box and applied filters.
  /// Returned list is shuffled.
  List<Vocabulary> buildCardList() {
    final b = _boxController.getBox(boxKey);
    if (b == null) {
      throw Exception("Box with key $boxKey not found");
    }
    _box = b;

    var list = List<Vocabulary>.from(b.vocabularies);

    if (onlyTimely) {
      list = list.where((v) {
        return Card.fromMap(v.cardData).due.compareTo(DateTime.now()) < 0;
      }).toList();
    }

    return _applyLearningMethodFilter(list, learningMethod)..shuffle();
  }

  /// Applies the specified learning method filter to the list of vocabularies.
  /// Following heuristics based on FSRS card properties:
  /// - `onlyDifficult`: Cards with difficulty >= 7.0.
  /// - `onlyNew`: Cards that have never been reviewed (step == null).
  /// - `onlyUnstable`: Cards with stability <= 33.0.
  ///
  /// - [list]: The list of vocabularies to filter.
  /// - [method]: The learning method to apply, see [LearningMethod] enum.
  List<Vocabulary> _applyLearningMethodFilter(
    List<Vocabulary> list,
    LearningMethod method,
  ) {
    switch (method) {
      case LearningMethod.onlyDifficult:
        return list.where((v) {
          final card = Card.fromMap(v.cardData);
          return card.difficulty! >= 7.0;
        }).toList();
      case LearningMethod.onlyNew:
        return list.where((v) {
          final card = Card.fromMap(v.cardData);
          return card.lastReview == null;
        }).toList();
      case LearningMethod.onlyUnstable:
        return list.where((v) {
          final card = Card.fromMap(v.cardData);
          return card.stability! <= 33.0;
        }).toList();
      case LearningMethod.all:
        return list;
    }
  }

  /// Applies the user's rating to the current card, updates the review data, and moves to the next card.
  /// - [rating]: The rating given by the user for the current card, see [Rating] enum.
  Future<bool> applyRating(Rating rating) async {
    if (_index >= _cards.length) return false;

    final vocabulary = _cards[_index];

    if (!_boxController.vocabularyIDs.contains(vocabulary.id)) {
      skip();
      return true;
    }

    final reviewResult = _scheduler.reviewCard(vocabulary.card, rating).card;

    final updatedVocab = vocabulary.copyWith(cardData: reviewResult.toMap());

    _cards[_index] = updatedVocab;

    if (_box != null) {
      _boxController.updateVocabularyInBox(boxKey, updatedVocab);
    }

    _index++;
    notifyListeners();
    return true;
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
