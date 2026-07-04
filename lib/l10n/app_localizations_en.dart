// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabBoxen => 'Boxes';

  @override
  String get tabVokabeln => 'Vocabulary';

  @override
  String get tabEinstellungen => 'Settings';

  @override
  String get homeEmpty => 'No boxes yet.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsImportBox => 'Import box';

  @override
  String get settingsImportSuccess => 'Import successful';

  @override
  String settingsImportSuccessMessage(String name) {
    return 'Box \"$name\" has been imported.';
  }

  @override
  String get settingsCardAnimations => 'Card animations';

  @override
  String get addBoxTitle => 'Create new box';

  @override
  String get addBoxNameLabel => 'Box name';

  @override
  String get addBoxDescriptionLabel => 'Description (optional)';

  @override
  String get addBoxButton => 'Add';

  @override
  String get addBoxNameEmpty => 'Name must not be empty.';

  @override
  String get editVocabNew => 'New vocabulary';

  @override
  String get editVocabEdit => 'Edit vocabulary';

  @override
  String get editVocabFront => 'Front';

  @override
  String get editVocabFrontHint => 'Word / Front side';

  @override
  String get editVocabBack => 'Back';

  @override
  String get editVocabBackHint => 'Meaning / Back side';

  @override
  String get editVocabDescriptionLabel => 'Description / Example';

  @override
  String get editVocabDescriptionHint => 'Optional example or description';

  @override
  String get editVocabAudio => 'Audio recording';

  @override
  String get editVocabNoPermission => 'No permission';

  @override
  String get editVocabMicPermission =>
      'The app needs access to the microphone to enable audio recordings. Please grant permission in Settings.';

  @override
  String get editVocabMissingInput => 'Missing input';

  @override
  String get editVocabMissingInputMessage =>
      'Please fill in front and back side.';

  @override
  String get editVocabExists => 'Vocabulary already exists';

  @override
  String get editVocabExistsMessage =>
      'This vocabulary already exists in this box. Add it anyway?';

  @override
  String get editVocabAddAnyway => 'Add anyway';

  @override
  String get editVocabSave => 'Save';

  @override
  String get editVocabNext => 'Next';

  @override
  String get editVocabStats => 'Statistics';

  @override
  String editVocabDue(String dueDate) {
    return 'Next review: $dueDate';
  }

  @override
  String get editVocabOverdue => 'overdue';

  @override
  String editVocabDifficulty(String difficulty) {
    return 'Difficulty: $difficulty of 10';
  }

  @override
  String editVocabStability(String stability) {
    return 'Stability: $stability';
  }

  @override
  String get reviewTitle => 'Study';

  @override
  String get reviewBack => 'Back';

  @override
  String reviewCard(int index, int total) {
    return 'Card $index / $total';
  }

  @override
  String get reviewPlay => 'Play';

  @override
  String get reviewAgain => 'Again';

  @override
  String get reviewHard => 'Hard';

  @override
  String get reviewGood => 'Good';

  @override
  String get reviewEasy => 'Easy';

  @override
  String get reviewSkip => 'Skip';

  @override
  String reviewExample(String example) {
    return 'Example: $example';
  }

  @override
  String get boxDetailDescription => 'Description';

  @override
  String get boxDetailOptions => 'Options';

  @override
  String get boxDetailDueVocabs => 'Due vocabulary';

  @override
  String get boxDetailMethod => 'Learning method';

  @override
  String get boxDetailEditVocabs => 'Edit vocabulary';

  @override
  String get boxDetailStart => 'Start';

  @override
  String get boxDetailDeleteTitle => 'Delete box';

  @override
  String get boxDetailDeleteMessage =>
      'Are you sure you want to delete this box?';

  @override
  String get boxDetailDelete => 'Delete';

  @override
  String get boxDetailNotFound => 'Box not found';

  @override
  String get vocabListTitle => 'Vocabulary';

  @override
  String get vocabListEmpty => 'No vocabulary yet.';

  @override
  String get learningMethodAll => 'All';

  @override
  String get learningMethodHard => 'Difficult only';

  @override
  String get learningMethodNew => 'New only';

  @override
  String get learningMethodUnstable => 'Unstable only';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonError => 'Error';

  @override
  String get errorExportDirectoryFailed =>
      'Export directory could not be created';

  @override
  String get errorExportWriteFailed => 'Vocabulary data could not be saved';

  @override
  String get errorExportAudioFailed => 'Audio files could not be copied';

  @override
  String get errorExportArchiveFailed => 'Archive could not be created';

  @override
  String get errorExportCacheFailed => 'Export cache could not be cleared';

  @override
  String get errorImportMissingStoreFile =>
      'Invalid file format: store.json not found in archive';

  @override
  String get errorImportInvalidFormat =>
      'Invalid file format: expected a JSON object';

  @override
  String errorDuplicateBoxName(String name) {
    return 'A box named \"$name\" already exists';
  }
}
