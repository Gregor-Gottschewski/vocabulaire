import 'package:fsrs/fsrs.dart';
import 'package:hive/hive.dart';

import 'firestore_converters.dart';

part 'conjugation.g.dart';

/// A single conjugated form of a [Vocabulary], for a given tense ("temps").
@HiveType(typeId: 4, adapterName: 'ConjugationAdapter')
class Conjugation {
  @HiveField(0)
  String temps;

  @HiveField(1)
  String forms;

  @HiveField(2)
  final Map<String, dynamic> cardData;

  @HiveField(3)
  final String id;

  Card get card => Card.fromMap(cardData);

  Conjugation({
    required this.temps,
    required this.forms,
    required this.cardData,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {'temps': temps, 'forms': forms, 'cardData': cardData, 'id': id};
  }

  factory Conjugation.fromMap(Map<String, dynamic> map) {
    return Conjugation(
      temps: map['temps'] as String,
      forms: map['forms'] as String,
      cardData: Map<String, dynamic>.from(map['cardData'] as Map),
      id: map['id'] as String,
    );
  }

  /// Nested inside the parent [Vocabulary] document.
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'temps': temps,
      'forms': forms,
      'card': FirestoreConverters.cardDataToFirestore(cardData),
    };
  }

  factory Conjugation.fromFirestore(Map<String, dynamic> data) {
    return Conjugation(
      temps: data['temps'] as String,
      forms: data['forms'] as String,
      cardData: FirestoreConverters.cardDataFromFirestore(
        Map<String, dynamic>.from(data['card'] as Map),
      ),
      id: data['id'] as String,
    );
  }

  Conjugation copyWith({
    String? temps,
    String? forms,
    Map<String, dynamic>? cardData,
    String? id,
  }) {
    return Conjugation(
      temps: temps ?? this.temps,
      forms: forms ?? this.forms,
      cardData: cardData ?? this.cardData,
      id: id ?? this.id,
    );
  }
}
