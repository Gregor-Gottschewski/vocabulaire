import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_paths.dart';
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
    if (boxes.any((b) => b.name == box.name)) {
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

  /// Returns a ValueNotifier that listens for changes to the specified keys in the box.
  /// The returned notifier automatically removes its Hive listener when disposed.
  ValueNotifier<List<MapEntry<dynamic, VocabularyBox>>> listenableForKeys(
    List<dynamic> keys,
  ) {
    return _BoxKeysValueNotifier(
      () => _entriesForKeys(keys),
      _box.listenable(keys: keys),
    );
  }

  /// Returns a ValueNotifier that listens for changes to all entries in the box.
  ValueNotifier<List<MapEntry<dynamic, VocabularyBox>>> listenableForAll() {
    return _BoxKeysValueNotifier(() => entries, _box.listenable());
  }

  /// Helper method to retrieve the entries for the specified keys.
  List<MapEntry<dynamic, VocabularyBox>> _entriesForKeys(List<dynamic> keys) {
    return keys
        .map((k) => _box.get(k))
        .whereType<VocabularyBox>()
        .toList()
        .asMap()
        .entries
        .map((e) => MapEntry(keys[e.key], e.value))
        .toList();
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

    final audio = AppPaths.audioFile(id);
    if (audio.existsSync()) {
      audio.delete();
    }
  }

  void updateVocabularyInBox(dynamic key, Vocabulary updatedVocabulary) {
    final box = _box.get(key);
    if (box == null) throw Exception('Box with key $key not found');

    final full = List<Vocabulary>.from(box.vocabularies);
    final idx = full.indexWhere((v) => v.id == updatedVocabulary.id);
    if (idx >= 0) {
      full[idx] = updatedVocabulary;
    } else {
      throw Exception(
        'Vocabulary with id ${updatedVocabulary.id} not found in box with key $key',
      );
    }

    final updated = VocabularyBox(
      name: box.name,
      description: box.description,
      vocabularies: full,
    );
    _box.put(key, updated);
  }
}

/// A ValueNotifier that removes its Hive box listener automatically on dispose,
/// preventing "used after being disposed" errors when the owning widget is removed.
class _BoxKeysValueNotifier
    extends ValueNotifier<List<MapEntry<dynamic, VocabularyBox>>> {
  final ValueListenable<Box<VocabularyBox>> _boxListenable;
  late final VoidCallback _boxListener;

  _BoxKeysValueNotifier(
    List<MapEntry<dynamic, VocabularyBox>> Function() getter,
    this._boxListenable,
  ) : super(getter()) {
    _boxListener = () => value = getter();
    _boxListenable.addListener(_boxListener);
  }

  @override
  void dispose() {
    _boxListenable.removeListener(_boxListener);
    super.dispose();
  }
}
