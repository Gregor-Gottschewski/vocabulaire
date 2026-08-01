import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Stable identity of this box, valid across both storage backends.
  @HiveField(12, defaultValue: '')
  final String id;

  /// Soft-delete flag for online synchronization.
  @HiveField(13, defaultValue: false)
  final bool deleted;

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
    required this.id,
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
    this.deleted = false,
  });

  VocabularyBox copyWith({
    String? id,
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
    bool? deleted,
  }) {
    return VocabularyBox(
      id: id ?? this.id,
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
      lastNewVocabularyReview: dailyLimitResetDate ?? lastNewVocabularyReview,
      deleted: deleted ?? this.deleted,
    );
  }

  /// Used exclusively for the local `.vocab` export/import format.
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
      id: map['id'] as String? ?? '',
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

  /// Firestore representation of the box's own fields — deliberately
  /// excludes [vocabularies], which lives in the `vocabularies` subcollection
  /// (see the migration plan's Firestore schema), and envelope fields
  /// (`deleted`/`updatedAt`/`ownerUid`), which are added by [BoxSyncService].
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'dailyLimitEnabled': dailyLimitEnabled,
      'dailyLimit': dailyLimit,
      'newCardsReviewedToday': newCardsReviewedToday,
      'lastNewVocabularyReview': lastNewVocabularyReview,
    };
  }

  /// [vocabularies] is always empty here — callers populate it separately
  /// from the box's `vocabularies` subcollection, see [BoxSyncService].
  factory VocabularyBox.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VocabularyBox(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      vocabularies: const [],
      type: data['type'] as String? ?? 'vocabulary',
      sourceLanguage: data['sourceLanguage'] as String?,
      targetLanguage: data['targetLanguage'] as String?,
      dailyLimitEnabled: data['dailyLimitEnabled'] as bool? ?? false,
      dailyLimit: data['dailyLimit'] as int? ?? 20,
      newCardsReviewedToday: data['newCardsReviewedToday'] as int? ?? 0,
      lastNewVocabularyReview:
          (data['lastNewVocabularyReview'] as Timestamp?)?.toDate(),
      deleted: data['deleted'] as bool? ?? false,
    );
  }
}