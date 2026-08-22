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
  String get addBox => 'Neue Box';

  @override
  String get back => 'Zurück';

  @override
  String overdueCardsCounter(int num) {
    return '$num fällig';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsImportBox => 'Box importieren';

  @override
  String get settingsCardAnimations => 'Kartenanimationen';

  @override
  String get settingsSyncStatus => 'Synchronisierungsstatus';

  @override
  String get settingsSyncStatusSynced => 'Aktuell';

  @override
  String get settingsSyncStatusSyncing => 'Wird synchronisiert…';

  @override
  String get settingsSyncStatusOffline => 'Offline';

  @override
  String get settingsLicenses => 'Lizenzen';

  @override
  String get settingsGithub => 'Vocabulaire auf Github';

  @override
  String get settingsBoxSync => 'Box-Synchronisierung';

  @override
  String get settingsExportAll => 'Alle Boxen exportieren';

  @override
  String get settingsVocabularyUsage => 'Vokabeln online';

  @override
  String settingsVocabularyUsageValue(int count, int limit) {
    return '$count/$limit';
  }

  @override
  String get settingsAudioUsage => 'Audiospeicher online';

  @override
  String settingsAudioUsageValue(String usedMb, int limitMb) {
    return '$usedMb MB / $limitMb MB';
  }

  @override
  String get boxSyncTitle => 'Box-Synchronisierung';

  @override
  String get boxSyncDescription =>
      'Online gespeicherte Boxen werden geräteübergreifend synchronisiert, lokale Boxen sind nur auf diesem Gerät verfügbar. Verschiebe eine Box in eine der beiden Richtungen.';

  @override
  String get boxSyncEmpty => 'Keine Boxen vorhanden.';

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
  String get editVocabConjugationSection => 'Konjugation';

  @override
  String get editVocabConjugationTempsHint => 'Tempus';

  @override
  String get editVocabConjugationFormsHint => 'Formen';

  @override
  String get editVocabConjugationAdd => '+ Konjugation hinzufügen';

  @override
  String reviewCard(int index, int total) {
    return '$index von $total';
  }

  @override
  String get reviewPlay => 'Anhören';

  @override
  String get reviewShowTranslation => 'Übersetzung anzeigen';

  @override
  String get reviewShowBack => 'Rückseite anzeigen';

  @override
  String get reviewRatingQuestion => 'Wie ist diese Vokabel?';

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
  String get boxTileNoDescription => 'Keine Beschreibung vorhanden';

  @override
  String get boxDetailOptions => 'Optionen';

  @override
  String get boxDetailDueVocabs => 'Fällige Vokabeln abfragen';

  @override
  String get boxDetailMethod => 'Lernmethode';

  @override
  String get boxDetailDailyLimit => 'Tageslimit neuer Karten';

  @override
  String get boxDetailNewCardsPerDay => 'Neue Karten / Tag';

  @override
  String get boxDetailDailyLimitInfo =>
      'Das tägliche Limit begrenzt die Anzahl der neuen Vokabeln, die pro Tag abgefragt werden.';

  @override
  String get boxDetailEditVocabs => 'Vokabeln bearbeiten';

  @override
  String get boxDetailStart => 'Starten';

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
  String boxDetailSubline(int total, int due) {
    return '$total Vokabeln — $due jetzt fällig';
  }

  @override
  String boxDetailDailyLimitValue(int count) {
    return '$count Karten';
  }

  @override
  String get boxDetailActionsSheetTitle => 'Diese Box bearbeiten.';

  @override
  String get boxDetailEditAction => 'Bearbeiten';

  @override
  String get boxDetailShareAction => 'Teilen';

  @override
  String get boxDetailSaveAction => 'Speichern';

  @override
  String get boxDetailDailyLimitOff => 'Aus';

  @override
  String get boxDetailDailyLimitEnable => 'Tageslimit aktivieren';

  @override
  String get boxDetailMoveOfflineAction => 'Auslagern';

  @override
  String get boxDetailMoveOfflineTitle => 'Box auslagern';

  @override
  String get boxDetailMoveOfflineMessage =>
      'Die Box wird lokal auf diesem Gerät gespeichert und nicht mehr geräteübergreifend synchronisiert. Fortfahren?';

  @override
  String get boxDetailMoveOnlineAction => 'Online stellen';

  @override
  String get boxDetailMoveOnlineTitle => 'Box online stellen';

  @override
  String get boxDetailMoveOnlineMessage =>
      'Die Box wird in die Cloud hochgeladen und geräteübergreifend synchronisiert. Fortfahren?';

  @override
  String get vocabListTitle => 'Vokabeln';

  @override
  String get vocabListEmpty => 'Keine Vokabeln vorhanden.';

  @override
  String get vocabListSearchPlaceholder => 'Suchen';

  @override
  String get vocabListNoResults => 'Keine Vokabel gefunden.';

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
  String get commonNext => 'Weiter';

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
  String get errorExportBulkDirectoryFailed =>
      'Export konnte nicht vorbereitet werden';

  @override
  String get errorExportBulkArchiveFailed =>
      'Boxen konnten nicht für den Export verpackt werden';

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
  String get errorMoveBoxOfflineFailed => 'Box konnte nicht ausgelagert werden';

  @override
  String get errorMoveBoxOnlineFailed =>
      'Box konnte nicht online gestellt werden';

  @override
  String get errorMoveGroupOfflineFailed =>
      'Gruppe konnte nicht ausgelagert werden';

  @override
  String get errorMoveGroupOnlineFailed =>
      'Gruppe konnte nicht online gestellt werden';

  @override
  String get errorAddVocabularyFailed =>
      'Vokabel konnte nicht gespeichert werden';

  @override
  String get errorVocabularyLimitReached =>
      'Vokabel-Limit für Online-Boxen erreicht. Lagere eine Box aus, um Platz für neue Online-Vokabeln zu schaffen.';

  @override
  String get errorGroupLimitReached => 'Limit von 1000 Gruppen erreicht.';

  @override
  String get errorBoxLimitPerGroupReached =>
      'Limit von 800 Boxen pro Gruppe erreicht.';

  @override
  String get errorAudioStorageLimitReached =>
      'Audio-Speicherlimit erreicht. Lagere eine Box aus, um Speicherplatz freizugeben.';

  @override
  String get editVocabGenerateAudio => 'Generieren';

  @override
  String get editVocabOverwriteAudioTitle => 'Aufnahme überschreiben?';

  @override
  String get editVocabOverwriteAudioMessage =>
      'Für diese Karte existiert bereits eine Audioaufnahme. Soll sie durch die neu generierte Sprachausgabe ersetzt werden?';

  @override
  String get editVocabOverwriteAudioConfirm => 'Überschreiben';

  @override
  String editVocabTtsTooLongHint(Object len) {
    return 'Sprachausgabe ist nur bis 65 Zeichen verfügbar. Deine Eingabe hat $len Zeichen.';
  }

  @override
  String get editVocabUnsavedChangesTitle =>
      'Sollen deine Änderungen gespeichert werden?';

  @override
  String get editVocabUnsavedChangesSaveAndLeave => 'Speichern und verlassen';

  @override
  String get editVocabUnsavedChangesDiscard => 'Eingaben verwerfen';

  @override
  String get editVocabDeleteTitle => 'Vokabel löschen';

  @override
  String get editVocabDeleteMessage =>
      'Möchtest du diese Vokabel wirklich löschen?';

  @override
  String get editVocabDeleteConfirm => 'Löschen';

  @override
  String get errorTtsEmptyText =>
      'Die Rückseite darf nicht leer sein, um eine Aussprache zu generieren.';

  @override
  String get errorTtsTextTooLong =>
      'Der Text für die Sprachausgabe darf maximal 65 Zeichen lang sein.';

  @override
  String get errorTtsRateLimitExceeded =>
      'Tageslimit für Sprachausgabe-Generierungen erreicht.';

  @override
  String get errorTtsNotAuthenticated =>
      'Anmeldung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get errorTtsUnknownError =>
      'Die Sprachausgabe konnte nicht generiert werden. Bitte überprüfe deine Internetverbindung.';

  @override
  String get language => 'Sprache';

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
      'Für das Vokabellernen einer Sprache mit zusätzlichen Funktionalitäten.';

  @override
  String get boxTypeFlashcardTitle => 'Karteikartenbox';

  @override
  String get boxTypeFlashcardSubtitle =>
      'Für beliebige Frage-Antwort-Karten. Alle Grundfunktionalitäten an Bord.';

  @override
  String get createBoxNavTitle => 'Neue Box';

  @override
  String get createBoxTypeTitle => 'Was für eine Box soll erstellt werden?';

  @override
  String get createBoxTypeSubtitle =>
      'Wähle einen Typ für die neue Box. Der Typ kann später nicht mehr geändert werden.';

  @override
  String get createBoxTypeImportSubtitle =>
      'Importiere eine Box mit allen Vokabeln und Audiodateien (falls vorhanden).';

  @override
  String get createBoxTitleLabel => 'Titel';

  @override
  String get createBoxTitleHint => 'Name der Box';

  @override
  String get createBoxDescriptionLabel => 'Beschreibung';

  @override
  String get createBoxDescriptionHint => 'Kurze optionale Beschreibung';

  @override
  String get createBoxNameEmpty => 'Der Name darf nicht leer sein.';

  @override
  String get createBoxSourceLanguageLabel =>
      'Ausgangssprache - das kennst du bereits';

  @override
  String get createBoxTargetLanguageLabel => 'Zielsprache - das lernst du';

  @override
  String get createBoxSourceLanguagePickerTitle => 'Ausgangssprache wählen';

  @override
  String get createBoxTargetLanguagePickerTitle => 'Zielsprache wählen';

  @override
  String get createBoxOnlineSync => 'Online speichern';

  @override
  String get createBoxFinish => 'Fertig';

  @override
  String get languageSearchPlaceholder => 'Suchen';

  @override
  String get languageCustomOption => 'Eigene...';

  @override
  String get languageCustomTitle => 'Eigene Sprache';

  @override
  String get languageCustomPlaceholder => 'Sprache eingeben';
}
