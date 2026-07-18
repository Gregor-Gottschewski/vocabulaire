import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @tabBoxen.
  ///
  /// In de, this message translates to:
  /// **'Boxen'**
  String get tabBoxen;

  /// No description provided for @tabVokabeln.
  ///
  /// In de, this message translates to:
  /// **'Vokabeln'**
  String get tabVokabeln;

  /// No description provided for @tabEinstellungen.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get tabEinstellungen;

  /// No description provided for @homeEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Boxen vorhanden.'**
  String get homeEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsImportBox.
  ///
  /// In de, this message translates to:
  /// **'Box importieren'**
  String get settingsImportBox;

  /// No description provided for @settingsImportSuccess.
  ///
  /// In de, this message translates to:
  /// **'Import erfolgreich'**
  String get settingsImportSuccess;

  /// No description provided for @settingsImportSuccessMessage.
  ///
  /// In de, this message translates to:
  /// **'Box \"{name}\" wurde importiert.'**
  String settingsImportSuccessMessage(String name);

  /// No description provided for @settingsCardAnimations.
  ///
  /// In de, this message translates to:
  /// **'Kartenanimationen'**
  String get settingsCardAnimations;

  /// No description provided for @editVocabNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Vokabel'**
  String get editVocabNew;

  /// No description provided for @editVocabEdit.
  ///
  /// In de, this message translates to:
  /// **'Vokabel bearbeiten'**
  String get editVocabEdit;

  /// No description provided for @editVocabFront.
  ///
  /// In de, this message translates to:
  /// **'Front'**
  String get editVocabFront;

  /// No description provided for @editVocabFrontHint.
  ///
  /// In de, this message translates to:
  /// **'Wort / Vorderseite'**
  String get editVocabFrontHint;

  /// No description provided for @editVocabBack.
  ///
  /// In de, this message translates to:
  /// **'Back'**
  String get editVocabBack;

  /// No description provided for @editVocabBackHint.
  ///
  /// In de, this message translates to:
  /// **'Bedeutung / Rückseite'**
  String get editVocabBackHint;

  /// No description provided for @editVocabDescriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung / Beispiel'**
  String get editVocabDescriptionLabel;

  /// No description provided for @editVocabDescriptionHint.
  ///
  /// In de, this message translates to:
  /// **'Optionales Beispiel oder Beschreibung'**
  String get editVocabDescriptionHint;

  /// No description provided for @editVocabAudio.
  ///
  /// In de, this message translates to:
  /// **'Audioaufnahme'**
  String get editVocabAudio;

  /// No description provided for @editVocabNoPermission.
  ///
  /// In de, this message translates to:
  /// **'Keine Berechtigung'**
  String get editVocabNoPermission;

  /// No description provided for @editVocabMicPermission.
  ///
  /// In de, this message translates to:
  /// **'Die App benötigt Zugriff auf das Mikrofon, um Audioaufnahmen zu ermöglichen. Bitte erteilen Sie die Berechtigung in den Einstellungen.'**
  String get editVocabMicPermission;

  /// No description provided for @editVocabMissingInput.
  ///
  /// In de, this message translates to:
  /// **'Fehlende Eingabe'**
  String get editVocabMissingInput;

  /// No description provided for @editVocabMissingInputMessage.
  ///
  /// In de, this message translates to:
  /// **'Bitte Vorder- und Rückseite ausfüllen.'**
  String get editVocabMissingInputMessage;

  /// No description provided for @editVocabExists.
  ///
  /// In de, this message translates to:
  /// **'Vokabel existiert bereits'**
  String get editVocabExists;

  /// No description provided for @editVocabExistsMessage.
  ///
  /// In de, this message translates to:
  /// **'Diese Vokabel existiert bereits in diesem Box. Soll die Vokabel trotzdem hinzugefügt werden?'**
  String get editVocabExistsMessage;

  /// No description provided for @editVocabAddAnyway.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem hinzufügen'**
  String get editVocabAddAnyway;

  /// No description provided for @editVocabSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get editVocabSave;

  /// No description provided for @editVocabNext.
  ///
  /// In de, this message translates to:
  /// **'Nächste'**
  String get editVocabNext;

  /// No description provided for @editVocabStats.
  ///
  /// In de, this message translates to:
  /// **'Statistiken'**
  String get editVocabStats;

  /// No description provided for @editVocabDue.
  ///
  /// In de, this message translates to:
  /// **'Nächste Abfrage: {dueDate}'**
  String editVocabDue(String dueDate);

  /// No description provided for @editVocabOverdue.
  ///
  /// In de, this message translates to:
  /// **'überfällig'**
  String get editVocabOverdue;

  /// No description provided for @editVocabDifficulty.
  ///
  /// In de, this message translates to:
  /// **'Komplexität: {difficulty} von 10'**
  String editVocabDifficulty(String difficulty);

  /// No description provided for @editVocabStability.
  ///
  /// In de, this message translates to:
  /// **'Stabilität: {stability}'**
  String editVocabStability(String stability);

  /// No description provided for @reviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Lernen'**
  String get reviewTitle;

  /// No description provided for @reviewBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get reviewBack;

  /// No description provided for @reviewCard.
  ///
  /// In de, this message translates to:
  /// **'Karte {index} / {total}'**
  String reviewCard(int index, int total);

  /// No description provided for @reviewPlay.
  ///
  /// In de, this message translates to:
  /// **'Abspielen'**
  String get reviewPlay;

  /// No description provided for @reviewAgain.
  ///
  /// In de, this message translates to:
  /// **'Nochmal'**
  String get reviewAgain;

  /// No description provided for @reviewHard.
  ///
  /// In de, this message translates to:
  /// **'Schwer'**
  String get reviewHard;

  /// No description provided for @reviewGood.
  ///
  /// In de, this message translates to:
  /// **'Gut'**
  String get reviewGood;

  /// No description provided for @reviewEasy.
  ///
  /// In de, this message translates to:
  /// **'Einfach'**
  String get reviewEasy;

  /// No description provided for @reviewSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get reviewSkip;

  /// No description provided for @reviewExample.
  ///
  /// In de, this message translates to:
  /// **'Beispiel: {example}'**
  String reviewExample(String example);

  /// No description provided for @boxDetailDescription.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get boxDetailDescription;

  /// No description provided for @boxDetailOptions.
  ///
  /// In de, this message translates to:
  /// **'Optionen'**
  String get boxDetailOptions;

  /// No description provided for @boxDetailDueVocabs.
  ///
  /// In de, this message translates to:
  /// **'Zeitlich anstehende Vokabeln'**
  String get boxDetailDueVocabs;

  /// No description provided for @boxDetailMethod.
  ///
  /// In de, this message translates to:
  /// **'Lernmethode'**
  String get boxDetailMethod;

  /// No description provided for @boxDetailEditVocabs.
  ///
  /// In de, this message translates to:
  /// **'Vokabeln bearbeiten'**
  String get boxDetailEditVocabs;

  /// No description provided for @boxDetailStart.
  ///
  /// In de, this message translates to:
  /// **'Start'**
  String get boxDetailStart;

  /// No description provided for @boxDetailDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Box löschen'**
  String get boxDetailDeleteTitle;

  /// No description provided for @boxDetailDeleteMessage.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du diese Box wirklich löschen?'**
  String get boxDetailDeleteMessage;

  /// No description provided for @boxDetailDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get boxDetailDelete;

  /// No description provided for @boxDetailNotFound.
  ///
  /// In de, this message translates to:
  /// **'Box nicht gefunden'**
  String get boxDetailNotFound;

  /// No description provided for @vocabListTitle.
  ///
  /// In de, this message translates to:
  /// **'Vokabeln'**
  String get vocabListTitle;

  /// No description provided for @vocabListEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Vokabeln vorhanden.'**
  String get vocabListEmpty;

  /// No description provided for @learningMethodAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get learningMethodAll;

  /// No description provided for @learningMethodHard.
  ///
  /// In de, this message translates to:
  /// **'Nur schwierige'**
  String get learningMethodHard;

  /// No description provided for @learningMethodNew.
  ///
  /// In de, this message translates to:
  /// **'Nur neue'**
  String get learningMethodNew;

  /// No description provided for @learningMethodUnstable.
  ///
  /// In de, this message translates to:
  /// **'Nur Instabile'**
  String get learningMethodUnstable;

  /// No description provided for @commonOk.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get commonCancel;

  /// No description provided for @commonError.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get commonError;

  /// No description provided for @commonNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get commonNext;

  /// No description provided for @errorExportDirectoryFailed.
  ///
  /// In de, this message translates to:
  /// **'Exportverzeichnis konnte nicht erstellt werden'**
  String get errorExportDirectoryFailed;

  /// No description provided for @errorExportWriteFailed.
  ///
  /// In de, this message translates to:
  /// **'Vokabeldaten konnten nicht gespeichert werden'**
  String get errorExportWriteFailed;

  /// No description provided for @errorExportAudioFailed.
  ///
  /// In de, this message translates to:
  /// **'Audiodateien konnten nicht kopiert werden'**
  String get errorExportAudioFailed;

  /// No description provided for @errorExportArchiveFailed.
  ///
  /// In de, this message translates to:
  /// **'Archiv konnte nicht erstellt werden'**
  String get errorExportArchiveFailed;

  /// No description provided for @errorExportCacheFailed.
  ///
  /// In de, this message translates to:
  /// **'Export-Cache konnte nicht geleert werden'**
  String get errorExportCacheFailed;

  /// No description provided for @errorImportMissingStoreFile.
  ///
  /// In de, this message translates to:
  /// **'Ungültiges Dateiformat: store.json fehlt im Archiv'**
  String get errorImportMissingStoreFile;

  /// No description provided for @errorImportInvalidFormat.
  ///
  /// In de, this message translates to:
  /// **'Ungültiges Dateiformat: JSON-Objekt erwartet'**
  String get errorImportInvalidFormat;

  /// No description provided for @errorDuplicateBoxName.
  ///
  /// In de, this message translates to:
  /// **'Eine Box mit dem Namen \"{name}\" existiert bereits'**
  String errorDuplicateBoxName(String name);

  /// No description provided for @languageGerman.
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageEnglish.
  ///
  /// In de, this message translates to:
  /// **'Englisch'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In de, this message translates to:
  /// **'Französisch'**
  String get languageFrench;

  /// No description provided for @languageSpanish.
  ///
  /// In de, this message translates to:
  /// **'Spanisch'**
  String get languageSpanish;

  /// No description provided for @languageItalian.
  ///
  /// In de, this message translates to:
  /// **'Italienisch'**
  String get languageItalian;

  /// No description provided for @languagePortuguese.
  ///
  /// In de, this message translates to:
  /// **'Portugiesisch'**
  String get languagePortuguese;

  /// No description provided for @languageDutch.
  ///
  /// In de, this message translates to:
  /// **'Niederländisch'**
  String get languageDutch;

  /// No description provided for @languageRussian.
  ///
  /// In de, this message translates to:
  /// **'Russisch'**
  String get languageRussian;

  /// No description provided for @languagePolish.
  ///
  /// In de, this message translates to:
  /// **'Polnisch'**
  String get languagePolish;

  /// No description provided for @languageTurkish.
  ///
  /// In de, this message translates to:
  /// **'Türkisch'**
  String get languageTurkish;

  /// No description provided for @languageChinese.
  ///
  /// In de, this message translates to:
  /// **'Chinesisch'**
  String get languageChinese;

  /// No description provided for @languageJapanese.
  ///
  /// In de, this message translates to:
  /// **'Japanisch'**
  String get languageJapanese;

  /// No description provided for @languageDanish.
  ///
  /// In de, this message translates to:
  /// **'Dänisch'**
  String get languageDanish;

  /// No description provided for @languageCzech.
  ///
  /// In de, this message translates to:
  /// **'Tschechisch'**
  String get languageCzech;

  /// No description provided for @languageHungarian.
  ///
  /// In de, this message translates to:
  /// **'Ungarisch'**
  String get languageHungarian;

  /// No description provided for @languageKorean.
  ///
  /// In de, this message translates to:
  /// **'Koreanisch'**
  String get languageKorean;

  /// No description provided for @boxTypeVocabularyTitle.
  ///
  /// In de, this message translates to:
  /// **'Vokabelbox'**
  String get boxTypeVocabularyTitle;

  /// No description provided for @boxTypeVocabularySubtitle.
  ///
  /// In de, this message translates to:
  /// **'Für das Vokabellernen einer Sprache.'**
  String get boxTypeVocabularySubtitle;

  /// No description provided for @boxTypeFlashcardTitle.
  ///
  /// In de, this message translates to:
  /// **'Karteikartenbox'**
  String get boxTypeFlashcardTitle;

  /// No description provided for @boxTypeFlashcardSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Für beliebige Frage-Antwort-Karten.'**
  String get boxTypeFlashcardSubtitle;

  /// No description provided for @createBoxNavTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Box'**
  String get createBoxNavTitle;

  /// No description provided for @createBoxTypeTitle.
  ///
  /// In de, this message translates to:
  /// **'Was für eine Box soll erstellt werden?'**
  String get createBoxTypeTitle;

  /// No description provided for @createBoxTypeSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wähle einen Typ.'**
  String get createBoxTypeSubtitle;

  /// No description provided for @createBoxIconEditTitle.
  ///
  /// In de, this message translates to:
  /// **'Icon ändern'**
  String get createBoxIconEditTitle;

  /// No description provided for @createBoxIconEditPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Emoji eingeben'**
  String get createBoxIconEditPlaceholder;

  /// No description provided for @createBoxTitleLabel.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get createBoxTitleLabel;

  /// No description provided for @createBoxTitleHint.
  ///
  /// In de, this message translates to:
  /// **'Name der Box'**
  String get createBoxTitleHint;

  /// No description provided for @createBoxDescriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung (optional)'**
  String get createBoxDescriptionLabel;

  /// No description provided for @createBoxDescriptionHint.
  ///
  /// In de, this message translates to:
  /// **'Kurze Beschreibung'**
  String get createBoxDescriptionHint;

  /// No description provided for @createBoxNameEmpty.
  ///
  /// In de, this message translates to:
  /// **'Der Name darf nicht leer sein.'**
  String get createBoxNameEmpty;

  /// No description provided for @createBoxSourceLanguageLabel.
  ///
  /// In de, this message translates to:
  /// **'Ausgangssprache - das kennst du bereits'**
  String get createBoxSourceLanguageLabel;

  /// No description provided for @createBoxTargetLanguageLabel.
  ///
  /// In de, this message translates to:
  /// **'Zielsprache - das lernst du'**
  String get createBoxTargetLanguageLabel;

  /// No description provided for @createBoxSourceLanguagePickerTitle.
  ///
  /// In de, this message translates to:
  /// **'Ausgangssprache wählen'**
  String get createBoxSourceLanguagePickerTitle;

  /// No description provided for @createBoxTargetLanguagePickerTitle.
  ///
  /// In de, this message translates to:
  /// **'Zielsprache wählen'**
  String get createBoxTargetLanguagePickerTitle;

  /// No description provided for @createBoxColorTitle.
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get createBoxColorTitle;

  /// No description provided for @createBoxFinish.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get createBoxFinish;

  /// No description provided for @languageSearchPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get languageSearchPlaceholder;

  /// No description provided for @languageCustomOption.
  ///
  /// In de, this message translates to:
  /// **'Eigene...'**
  String get languageCustomOption;

  /// No description provided for @languageCustomTitle.
  ///
  /// In de, this message translates to:
  /// **'Eigene Sprache'**
  String get languageCustomTitle;

  /// No description provided for @languageCustomPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Sprache eingeben'**
  String get languageCustomPlaceholder;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
