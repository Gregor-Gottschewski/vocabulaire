import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared Timestamp <-> ISO8601-String conversion helpers
class FirestoreConverters {
  FirestoreConverters._();

  static Timestamp? isoStringToTimestamp(String? iso) {
    if (iso == null) return null;
    return Timestamp.fromDate(DateTime.parse(iso));
  }

  static String? timestampToIsoString(Object? value) {
    if (value == null) return null;
    return (value as Timestamp).toDate().toUtc().toIso8601String();
  }

  /// Converts a `Vocabulary.cardData` map to its Firestore representation.
  static Map<String, dynamic> cardDataToFirestore(Map<String, dynamic> cardData) {
    return {
      ...cardData,
      'due': isoStringToTimestamp(cardData['due'] as String?),
      'lastReview': isoStringToTimestamp(cardData['lastReview'] as String?),
    };
  }

  /// Reverses [cardDataToFirestore] — converts Firestore's `card` map back
  /// into the shape `Card.fromMap()` expects..
  static Map<String, dynamic> cardDataFromFirestore(Map<String, dynamic> data) {
    return {
      ...data,
      'stability': (data['stability'] as num?)?.toDouble(),
      'difficulty': (data['difficulty'] as num?)?.toDouble(),
      'due': timestampToIsoString(data['due']),
      'lastReview': timestampToIsoString(data['lastReview']),
    };
  }
}
