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
  String get commonNext => 'Next';

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

  @override
  String get editVocabGenerateAudio => 'Generate pronunciation';

  @override
  String get editVocabOverwriteAudioTitle => 'Overwrite recording?';

  @override
  String get editVocabOverwriteAudioMessage =>
      'This card already has an audio recording. Replace it with the newly generated pronunciation?';

  @override
  String get editVocabOverwriteAudioConfirm => 'Overwrite';

  @override
  String editVocabTtsTooLongHint(Object len) {
    return 'Pronunciation is only available up to 65 characters. Your input has $len characters.';
  }

  @override
  String get editVocabUnsavedChangesTitle =>
      'Do you want to save your changes?';

  @override
  String get editVocabUnsavedChangesSaveAndLeave => 'Save and leave';

  @override
  String get editVocabUnsavedChangesDiscard => 'Discard changes';

  @override
  String get errorTtsEmptyText =>
      'The back side must not be empty to generate a pronunciation.';

  @override
  String get errorTtsTextTooLong =>
      'The text must not be longer than 65 characters.';

  @override
  String get errorTtsRateLimitExceeded =>
      'Daily limit for speech generations reached.';

  @override
  String get errorTtsNotAuthenticated => 'Sign-in failed. Please try again.';

  @override
  String get errorTtsUnknownError =>
      'The pronunciation could not be generated. Please check your internet connection.';

  @override
  String get languageGerman => 'German';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languagePolish => 'Polish';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageDanish => 'Danish';

  @override
  String get languageCzech => 'Czech';

  @override
  String get languageHungarian => 'Hungarian';

  @override
  String get languageKorean => 'Korean';

  @override
  String get boxTypeVocabularyTitle => 'Vocabulary box';

  @override
  String get boxTypeVocabularySubtitle =>
      'For learning the vocabulary of a language, with additional features.';

  @override
  String get boxTypeFlashcardTitle => 'Flashcard box';

  @override
  String get boxTypeFlashcardSubtitle =>
      'For any kind of question-and-answer cards. All the basic features included.';

  @override
  String get createBoxNavTitle => 'New box';

  @override
  String get createBoxTypeTitle => 'What kind of box do you want to create?';

  @override
  String get createBoxTypeSubtitle =>
      'Choose a type for the new box. The type can\'t be changed later.';

  @override
  String get createBoxTypeImportSubtitle =>
      'Import a box with all its vocabulary and audio files.';

  @override
  String get createBoxIconEditTitle => 'Change icon';

  @override
  String get createBoxIconEditPlaceholder => 'Enter emoji';

  @override
  String get createBoxTitleLabel => 'Title';

  @override
  String get createBoxTitleHint => 'Box name';

  @override
  String get createBoxDescriptionLabel => 'Description (optional)';

  @override
  String get createBoxDescriptionHint => 'Short description';

  @override
  String get createBoxNameEmpty => 'Name must not be empty.';

  @override
  String get createBoxSourceLanguageLabel =>
      'Source language - what you already know';

  @override
  String get createBoxTargetLanguageLabel =>
      'Target language - what you\'re learning';

  @override
  String get createBoxSourceLanguagePickerTitle => 'Choose source language';

  @override
  String get createBoxTargetLanguagePickerTitle => 'Choose target language';

  @override
  String get createBoxColorTitle => 'Color';

  @override
  String get createBoxFinish => 'Done';

  @override
  String get languageSearchPlaceholder => 'Search';

  @override
  String get languageCustomOption => 'Custom...';

  @override
  String get languageCustomTitle => 'Custom language';

  @override
  String get languageCustomPlaceholder => 'Enter language';
}
