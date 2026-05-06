import 'package:hive/hive.dart';
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

  VocabularyBox({
    required this.name,
    required this.description,
    required this.vocabularies,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'vocabularies': vocabularies.map((v) => v.toMap()).toList(),
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
    );
  }
}