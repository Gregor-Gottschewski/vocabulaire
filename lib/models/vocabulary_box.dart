import 'package:hive/hive.dart';
import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/box_color.dart';
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

  /// A single emoji grapheme used as the box's icon.
  @HiveField(4)
  final String icon;

  /// [BoxColor.name] of this box.
  @HiveField(5)
  final String color;

  /// [AppLanguage.code] of the source language, only set for [BoxType.vocabulary] boxes.
  @HiveField(6)
  final String? sourceLanguage;

  /// [AppLanguage.code] of the target language, only set for [BoxType.vocabulary] boxes.
  @HiveField(7)
  final String? targetLanguage;

  BoxType get boxType => BoxType.fromName(type);

  BoxColor get boxColor => BoxColor.fromName(color);

  AppLanguage? get sourceAppLanguage => AppLanguage.fromCode(sourceLanguage);

  AppLanguage? get targetAppLanguage => AppLanguage.fromCode(targetLanguage);

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
    this.icon = '📚',
    this.color = 'purple',
    this.sourceLanguage,
    this.targetLanguage,
  });

  VocabularyBox copyWith({
    String? name,
    String? description,
    List<Vocabulary>? vocabularies,
    String? type,
    String? icon,
    String? color,
    String? sourceLanguage,
    String? targetLanguage,
  }) {
    return VocabularyBox(
      name: name ?? this.name,
      description: description ?? this.description,
      vocabularies: vocabularies ?? this.vocabularies,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'vocabularies': vocabularies.map((v) => v.toMap()).toList(),
      'type': type,
      'icon': icon,
      'color': color,
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
      icon: map['icon'] as String? ?? '📚',
      color: map['color'] as String? ?? 'purple',
      sourceLanguage: map['sourceLanguage'] as String?,
      targetLanguage: map['targetLanguage'] as String?,
    );
  }
}