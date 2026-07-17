// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get tabBoxen => 'Boxen';

  @override
  String get tabVokabeln => 'Vokabeln';

  @override
  String get tabEinstellungen => 'Einstellungen';

  @override
  String get homeEmpty => 'Keine Boxen vorhanden.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsImportBox => 'Box importieren';

  @override
  String get settingsImportSuccess => 'Import erfolgreich';

  @override
  String settingsImportSuccessMessage(String name) {
    return 'Box \"$name\" wurde importiert.';
  }

  @override
  String get settingsCardAnimations => 'Kartenanimationen';

  @override
  String get addBoxTitle => 'Neue Box erstellen';

  @override
  String get addBoxNameLabel => 'Name der Box';

  @override
  String get addBoxDescriptionLabel => 'Beschreibung (optional)';

  @override
  String get addBoxButton => 'Hinzufügen';

  @override
  String get addBoxNameEmpty => 'Der Name darf nicht leer sein.';

  @override
  String get editVocabNew => 'Neue Vokabel';

  @override
  String get editVocabEdit => 'Vokabel bearbeiten';

  @override
  String get editVocabFront => 'Front';

  @override
  String get editVocabFrontHint => 'Wort / Vorderseite';

  @override
  String get editVocabBack => 'Back';

  @override
  String get editVocabBackHint => 'Bedeutung / Rückseite';

  @override
  String get editVocabDescriptionLabel => 'Beschreibung / Beispiel';

  @override
  String get editVocabDescriptionHint =>
      'Optionales Beispiel oder Beschreibung';

  @override
  String get editVocabAudio => 'Audioaufnahme';

  @override
  String get editVocabNoPermission => 'Keine Berechtigung';

  @override
  String get editVocabMicPermission =>
      'Die App benötigt Zugriff auf das Mikrofon, um Audioaufnahmen zu ermöglichen. Bitte erteilen Sie die Berechtigung in den Einstellungen.';

  @override
  String get editVocabMissingInput => 'Fehlende Eingabe';

  @override
  String get editVocabMissingInputMessage =>
      'Bitte Vorder- und Rückseite ausfüllen.';

  @override
  String get editVocabExists => 'Vokabel existiert bereits';

  @override
  String get editVocabExistsMessage =>
      'Diese Vokabel existiert bereits in diesem Box. Soll die Vokabel trotzdem hinzugefügt werden?';

  @override
  String get editVocabAddAnyway => 'Trotzdem hinzufügen';

  @override
  String get editVocabSave => 'Speichern';

  @override
  String get editVocabNext => 'Nächste';

  @override
  String get editVocabStats => 'Statistiken';

  @override
  String editVocabDue(String dueDate) {
    return 'Nächste Abfrage: $dueDate';
  }

  @override
  String get editVocabOverdue => 'überfällig';

  @override
  String editVocabDifficulty(String difficulty) {
    return 'Komplexität: $difficulty von 10';
  }

  @override
  String editVocabStability(String stability) {
    return 'Stabilität: $stability';
  }

  @override
  String get reviewTitle => 'Lernen';

  @override
  String get reviewBack => 'Zurück';

  @override
  String reviewCard(int index, int total) {
    return 'Karte $index / $total';
  }

  @override
  String get reviewPlay => 'Abspielen';

  @override
  String get reviewAgain => 'Nochmal';

  @override
  String get reviewHard => 'Schwer';

  @override
  String get reviewGood => 'Gut';

  @override
  String get reviewEasy => 'Einfach';

  @override
  String get reviewSkip => 'Überspringen';

  @override
  String reviewExample(String example) {
    return 'Beispiel: $example';
  }

  @override
  String get boxDetailDescription => 'Beschreibung';

  @override
  String get boxDetailOptions => 'Optionen';

  @override
  String get boxDetailDueVocabs => 'Zeitlich anstehende Vokabeln';

  @override
  String get boxDetailMethod => 'Lernmethode';

  @override
  String get boxDetailEditVocabs => 'Vokabeln bearbeiten';

  @override
  String get boxDetailStart => 'Start';

  @override
  String get boxDetailDeleteTitle => 'Box löschen';

  @override
  String get boxDetailDeleteMessage =>
      'Möchtest du diese Box wirklich löschen?';

  @override
  String get boxDetailDelete => 'Löschen';

  @override
  String get boxDetailNotFound => 'Box nicht gefunden';

  @override
  String get vocabListTitle => 'Vokabeln';

  @override
  String get vocabListEmpty => 'Keine Vokabeln vorhanden.';

  @override
  String get learningMethodAll => 'Alle';

  @override
  String get learningMethodHard => 'Nur schwierige';

  @override
  String get learningMethodNew => 'Nur neue';

  @override
  String get learningMethodUnstable => 'Nur Instabile';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonError => 'Fehler';

  @override
  String get errorExportDirectoryFailed =>
      'Exportverzeichnis konnte nicht erstellt werden';

  @override
  String get errorExportWriteFailed =>
      'Vokabeldaten konnten nicht gespeichert werden';

  @override
  String get errorExportAudioFailed =>
      'Audiodateien konnten nicht kopiert werden';

  @override
  String get errorExportArchiveFailed => 'Archiv konnte nicht erstellt werden';

  @override
  String get errorExportCacheFailed =>
      'Export-Cache konnte nicht geleert werden';

  @override
  String get errorImportMissingStoreFile =>
      'Ungültiges Dateiformat: store.json fehlt im Archiv';

  @override
  String get errorImportInvalidFormat =>
      'Ungültiges Dateiformat: JSON-Objekt erwartet';

  @override
  String errorDuplicateBoxName(String name) {
    return 'Eine Box mit dem Namen \"$name\" existiert bereits';
  }

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languagePortuguese => 'Portugiesisch';

  @override
  String get languageDutch => 'Niederländisch';

  @override
  String get languageRussian => 'Russisch';

  @override
  String get languagePolish => 'Polnisch';

  @override
  String get languageTurkish => 'Türkisch';

  @override
  String get languageChinese => 'Chinesisch';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get languageDanish => 'Dänisch';

  @override
  String get languageCzech => 'Tschechisch';

  @override
  String get languageHungarian => 'Ungarisch';

  @override
  String get languageKorean => 'Koreanisch';

  @override
  String get boxTypeVocabularyTitle => 'Vokabelbox';

  @override
  String get boxTypeVocabularySubtitle =>
      'Für das Vokabellernen einer Sprache.';

  @override
  String get boxTypeFlashcardTitle => 'Karteikartenbox';

  @override
  String get boxTypeFlashcardSubtitle => 'Für beliebige Frage-Antwort-Karten.';
}
