import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/hive_types.dart';

part 'vocabulary_group.g.dart';

@HiveType(typeId: HiveTypes.vocabularyGroupTypeId, adapterName: 'VocabularyGroupAdapter')
class VocabularyGroup {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  /// [BoxType.name] of this group. Immutable after creation.
  @HiveField(2)
  final String type;

  /// [AppLanguage.code] of the source language, only set for [BoxType.vocabulary] groups.
  @HiveField(3)
  final String? sourceLanguage;

  /// [AppLanguage.code] of the target language, only set for [BoxType.vocabulary] groups.
  @HiveField(4)
  final String? targetLanguage;

  /// Soft-delete flag for online synchronization.
  @HiveField(5, defaultValue: false)
  final bool deleted;

  final int boxCountOnline;

  BoxType get boxType => BoxType.fromName(type);

  AppLanguage? get sourceAppLanguage => AppLanguage.fromCode(sourceLanguage);

  AppLanguage? get targetAppLanguage => AppLanguage.fromCode(targetLanguage);

  VocabularyGroup({
    required this.id,
    required this.name,
    this.type = 'vocabulary',
    this.sourceLanguage,
    this.targetLanguage,
    this.deleted = false,
    this.boxCountOnline = 0,
  });

  VocabularyGroup copyWith({
    String? id,
    String? name,
    String? type,
    String? sourceLanguage,
    String? targetLanguage,
    bool? deleted,
    int? boxCountOnline,
  }) {
    return VocabularyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      deleted: deleted ?? this.deleted,
      boxCountOnline: boxCountOnline ?? this.boxCountOnline,
    );
  }

  /// Firestore representation of the group's own fields
  Map<String, dynamic> toFirestore() {
    return {'id': id, 'name': name, 'type': type, 'sourceLanguage': sourceLanguage, 'targetLanguage': targetLanguage};
  }

  factory VocabularyGroup.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VocabularyGroup(
      id: data['id'] as String? ?? doc.id,
      name: data['name'] as String,
      type: data['type'] as String? ?? 'vocabulary',
      sourceLanguage: data['sourceLanguage'] as String?,
      targetLanguage: data['targetLanguage'] as String?,
      deleted: data['deleted'] as bool? ?? false,
      boxCountOnline: (data['boxCountOnline'] as num?)?.toInt() ?? 0,
    );
  }
}
