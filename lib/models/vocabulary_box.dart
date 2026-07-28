import 'package:hive/hive.dart';
import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/vocabulary.dart';

part 'vocabulary_box.g.dart';

@HiveType(typeId: 1, adapterName: 'VocabularyBoxAdapter')
class VocabularyBox {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final List<Vocabulary> vocabularies;

  /// [BoxType.name] of this box.
  @HiveField(3)
  final String type;

  /// [AppLanguage.code] of the source language, only set for [BoxType.vocabulary] boxes.
  @HiveField(6)
  final String? sourceLanguage;

  /// [AppLanguage.code] of the target language, only set for [BoxType.vocabulary] boxes.
  @HiveField(7)
  final String? targetLanguage;

  /// Whether a daily limit on new cards is active for this box.
  @HiveField(8, defaultValue: false)
  final bool dailyLimitEnabled;

  /// Maximum number of new cards to review per day, when [dailyLimitEnabled].
  @HiveField(9, defaultValue: 20)
  final int dailyLimit;

  /// Number of new cards already reviewed on the current logical day.
  @HiveField(10, defaultValue: 0)
  final int newCardsReviewedToday;

  /// Last review of vocabulary box with new vocabulary
  @HiveField(11)
  final DateTime? lastNewVocabularyReview;

  BoxType get boxType => BoxType.fromName(type);

  AppLanguage? get sourceAppLanguage => AppLanguage.fromCode(sourceLanguage);

  AppLanguage? get targetAppLanguage => AppLanguage.fromCode(targetLanguage);

  /// True if [lastNewVocabularyReview] is set and refers to a previous
  /// calendar day
  bool get isDailyLimitStale {
    final resetDate = lastNewVocabularyReview;
    if (resetDate == null) return false;
    final now = DateTime.now();
    return resetDate.year != now.year ||
        resetDate.month != now.month ||
        resetDate.day != now.day;
  }

  /// Remaining number of new cards that may still be reviewed today,
  /// or `null` if no daily limit is enabled.
  int? get remainingNewCardsToday {
    if (!dailyLimitEnabled) return null;
    final reviewedToday = isDailyLimitStale ? 0 : newCardsReviewedToday;
    final remaining = dailyLimit - reviewedToday;
    return remaining < 0 ? 0 : remaining;
  }

  /// Sanitization to prevent path traversal.
  /// Returns sanitized import or 'export' if sanitized import is empty.
  String nameSanitized() {
    String sanitized = name.replaceAll(RegExp(r'[/\\:*?"<>|]'), '_');
    return sanitized.isEmpty ? "export" : sanitized;
  }

  VocabularyBox({
    required this.name,
    required this.description,
    required this.vocabularies,
    this.type = 'vocabulary',
    this.sourceLanguage,
    this.targetLanguage,
    this.dailyLimitEnabled = false,
    this.dailyLimit = 20,
    this.newCardsReviewedToday = 0,
    this.lastNewVocabularyReview,
  });

  VocabularyBox copyWith({
    String? name,
    String? description,
    List<Vocabulary>? vocabularies,
    String? type,
    String? sourceLanguage,
    String? targetLanguage,
    bool? dailyLimitEnabled,
    int? dailyLimit,
    int? newCardsReviewedToday,
    DateTime? dailyLimitResetDate,
  }) {
    return VocabularyBox(
      name: name ?? this.name,
      description: description ?? this.description,
      vocabularies: vocabularies ?? this.vocabularies,
      type: type ?? this.type,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      dailyLimitEnabled: dailyLimitEnabled ?? this.dailyLimitEnabled,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      newCardsReviewedToday:
          newCardsReviewedToday ?? this.newCardsReviewedToday,
      lastNewVocabularyReview: dailyLimitResetDate ?? this.lastNewVocabularyReview,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'vocabularies': vocabularies.map((v) => v.toMap()).toList(),
      'type': type,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
    };
  }

  factory VocabularyBox.fromMap(Map<String, dynamic> map) {
    return VocabularyBox(
      name: map['name'] as String,
      description: map['description'] as String,
      vocabularies: (map['vocabularies'] as List<dynamic>?)
              ?.map((v) => Vocabulary.fromMap(v as Map<String, dynamic>))
              .toList() ??
          [],
      type: map['type'] as String? ?? 'vocabulary',
      sourceLanguage: map['sourceLanguage'] as String?,
      targetLanguage: map['targetLanguage'] as String?,
    );
  }
}