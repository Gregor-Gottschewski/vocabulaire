import 'package:fsrs/fsrs.dart';

import 'conjugation.dart';
import 'vocabulary.dart';

/// Something that can appear as an independent card in a review session.
sealed class ReviewableItem {
  String get id;

  Map<String, dynamic> get cardData;

  Card get card => Card.fromMap(cardData);

  /// Text shown on the front of the card.
  String get frontText;

  /// Text shown on the back of the card, after reveal.
  String get backText;

  /// The [Vocabulary] this item belongs to (itself, for [VocabularyItem]).
  Vocabulary get parentVocabulary;
}

class VocabularyItem extends ReviewableItem {
  final Vocabulary vocabulary;

  VocabularyItem(this.vocabulary);

  @override
  String get id => vocabulary.id;

  @override
  Map<String, dynamic> get cardData => vocabulary.cardData;

  @override
  String get frontText => vocabulary.word;

  @override
  String get backText => vocabulary.meaning;

  @override
  Vocabulary get parentVocabulary => vocabulary;
}

class ConjugationItem extends ReviewableItem {
  final Vocabulary parent;
  final Conjugation conjugation;

  ConjugationItem(this.parent, this.conjugation);

  @override
  String get id => conjugation.id;

  @override
  Map<String, dynamic> get cardData => conjugation.cardData;

  @override
  String get frontText => '(${conjugation.temps}) ${parent.word}';

  @override
  String get backText => conjugation.forms;

  @override
  Vocabulary get parentVocabulary => parent;
}
