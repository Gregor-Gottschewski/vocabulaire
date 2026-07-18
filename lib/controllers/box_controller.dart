import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_exception.dart';
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

  /// Assumption: Vocabulary boxes does not contain boxes without IDs!
  /// This is controlled by [addVocabularyToBox].
  Set<String?> get vocabularyIDs =>
      getAllVocabularies().map((v) => v.id).toSet();

  /// Returns all vocabularies across all boxes.
  List<Vocabulary> getAllVocabularies() {
    return boxes.expand((box) => box.vocabularies).toList();
  }

  /// Adds a new box to the collection.
  /// Throws an exception if a box with the same name already exists.
  /// This method does not check for duplicate IDs in the vocabularies.
  Future<dynamic> addBox(VocabularyBox box) async {
    if (boxes.any((b) => b.name == box.name)) {
      throw AppException(AppError.duplicateBoxName, details: box.name);
    }
    return await _box.add(box);
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

  /// Adds the given [Vocabulary] to the box indicated by the given [key].
  void addVocabularyToBox(dynamic key, Vocabulary vocabulary) {
    if (vocabularyIDs.contains(vocabulary.id)) {
      throw StateError('Vocabulary with id ${vocabulary.id} already exists');
    }

    final box = _box.get(key);
    if (box == null) throw StateError('Box with key $key not found');
    final updated = VocabularyBox(
      name: box.name,
      description: box.description,
      vocabularies: List<Vocabulary>.from(box.vocabularies)
        ..add(vocabulary),
    );
    _box.put(key, updated);
  }

  void removeVocabularyFromBox(dynamic key, String id) {
    final box = _box.get(key);
    if (box == null) throw StateError('Box with key $key not found');
    final updated = box.copyWith(
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
    if (box == null) throw StateError('Box with key $key not found');

    final full = List<Vocabulary>.from(box.vocabularies);
    final idx = full.indexWhere((v) => v.id == updatedVocabulary.id);

    // if vocabulary not in box idx is set to -1
    if (idx < 0) {
      throw StateError(
        'Vocabulary with id ${updatedVocabulary.id} not found in box with key $key',
      );
    }

    full[idx] = updatedVocabulary;

    final updated = box.copyWith(vocabularies: full);
    _box.put(key, updated);
  }

  /// Creates vocabulary with unique id.
  /// See [generateUniqueId] for information about ID generation.
  Vocabulary createVocabulary() {
    return Vocabulary(
      word: "",
      meaning: "",
      example: "",
      cardData: Card(cardId: DateTime.now().millisecondsSinceEpoch).toMap(),
      id: generateUniqueId(vocabularyIDs),
    );
  }

  /// This generates a unique V4 UUID.
  /// Runtime of this method is not constant due to the while-loop.
  /// However, it is extremely unlikely that this loops runs.
  /// So we life with this risk.
  ///
  /// [existingIds] the blocked IDs that should not be used.
  String generateUniqueId(Set<String?> existingIds) {
    String id;
    do {
      id = Uuid().v4();
    } while (existingIds.contains(id));
    return id;
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
