import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import '../models/vocabulary.dart';

class BoxController {
  final Box<VocabularyBox> _box = Hive.box<VocabularyBox>('boxes');

  List<VocabularyBox> get boxes => _box.values.toList();

  ValueListenable<Box<VocabularyBox>> get listenable => _box.listenable();

  int get length => _box.length;

  List<MapEntry<dynamic, VocabularyBox>> get entries =>
      _box.toMap().entries.toList();

  VocabularyBox? getBox(dynamic key) => _box.get(key);

  /// Adds a new box to the collection.
  /// Throws an exception if a box with the same name already exists.
  void addBox(VocabularyBox box) {
    if (getBox(box.name) != null) {
      throw Exception('Box with name ${box.name} already exists');
    }
    _box.add(box);
  }

  void deleteBox(dynamic key) {
    _box.delete(key);
  }

  void updateBox(dynamic key, VocabularyBox updatedBox) {
    _box.put(key, updatedBox);
  }

  void addVocabularyToBox(dynamic key, Vocabulary vocabulary) {
    final box = _box.get(key);
    if (box == null) throw Exception('Box with key $key not found');
    final updated = VocabularyBox(
      name: box.name,
      description: box.description,
      vocabularies: List<Vocabulary>.from(box.vocabularies)..add(vocabulary),
    );
    _box.put(key, updated);
  }

  void removeVocabularyFromBox(dynamic key, String id) {
    final box = _box.get(key);
    if (box == null) throw Exception('Box with key $key not found');
    final updated = VocabularyBox(
      name: box.name,
      description: box.description,
      vocabularies: List<Vocabulary>.from(box.vocabularies)
        ..removeWhere((v) => v.id == id),
    );
    _box.put(key, updated);
  }

  void updateVocabularyInBox(dynamic key, Vocabulary updatedVocabulary) {
    final box = _box.get(key);
    if (box == null) throw Exception('Box with key $key not found');

    final full = List<Vocabulary>.from(box.vocabularies);
    final idx = full.indexWhere((v) => v.id == updatedVocabulary.id);
    if (idx >= 0) {
      full[idx] = updatedVocabulary;
    } else {
      throw Exception('Vocabulary with id ${updatedVocabulary.id} not found in box with key $key');
    }

    final updated = VocabularyBox(
      name: box.name,
      description: box.description,
      vocabularies: full,
    );
    _box.put(key, updated);
  }
}
