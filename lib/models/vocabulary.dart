import 'package:fsrs/fsrs.dart';
import 'package:hive/hive.dart';

part 'vocabulary.g.dart';

/// A model representing a vocabulary word.
/// It contains the word itself, its meaning, an example sentence, and an id.
@HiveType(typeId: 0, adapterName: 'VocabularyAdapter')
class Vocabulary {
  @HiveField(0)
  String word;

  @HiveField(1)
  String meaning;

  @HiveField(2)
  String example;

  @HiveField(3)
  final Map<String, dynamic> cardData;

  @HiveField(4)
  final String id;

  Card get card => Card.fromMap(cardData);

  Vocabulary({
    required this.word,
    required this.meaning,
    required this.example,
    required this.cardData,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'meaning': meaning,
      'example': example,
      'cardData': cardData,
      'id': id,
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      word: map['word'] as String,
      meaning: map['meaning'] as String,
      example: map['example'] as String,
      cardData: Map<String, dynamic>.from(map['cardData'] as Map),
      id: map['id'] as String,
    );
  }

  Vocabulary copyWith({
    String? word,
    String? meaning,
    String? example,
    Map<String, dynamic>? cardData,
    String? id,
  }) {
    return Vocabulary(
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      cardData: cardData ?? this.cardData,
      id: id ?? this.id,
    );
  }
}
