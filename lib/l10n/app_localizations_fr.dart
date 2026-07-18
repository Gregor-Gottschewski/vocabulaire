// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get tabBoxen => 'Boîtes';

  @override
  String get tabVokabeln => 'Vocabulaire';

  @override
  String get tabEinstellungen => 'Paramètres';

  @override
  String get homeEmpty => 'Aucune boîte disponible.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsImportBox => 'Importer une boîte';

  @override
  String get settingsImportSuccess => 'Importation réussie';

  @override
  String settingsImportSuccessMessage(String name) {
    return 'La boîte \"$name\" a été importée.';
  }

  @override
  String get settingsCardAnimations => 'Animations de cartes';

  @override
  String get editVocabNew => 'Nouveau vocabulaire';

  @override
  String get editVocabEdit => 'Modifier le vocabulaire';

  @override
  String get editVocabFront => 'Recto';

  @override
  String get editVocabFrontHint => 'Mot / Recto';

  @override
  String get editVocabBack => 'Verso';

  @override
  String get editVocabBackHint => 'Signification / Verso';

  @override
  String get editVocabDescriptionLabel => 'Description / Exemple';

  @override
  String get editVocabDescriptionHint => 'Exemple ou description optionnel';

  @override
  String get editVocabAudio => 'Enregistrement audio';

  @override
  String get editVocabNoPermission => 'Pas d\'autorisation';

  @override
  String get editVocabMicPermission =>
      'L\'application a besoin d\'accéder au microphone pour permettre les enregistrements audio. Veuillez accorder l\'autorisation dans les paramètres.';

  @override
  String get editVocabMissingInput => 'Saisie manquante';

  @override
  String get editVocabMissingInputMessage =>
      'Veuillez remplir le recto et le verso.';

  @override
  String get editVocabExists => 'Le vocabulaire existe déjà';

  @override
  String get editVocabExistsMessage =>
      'Ce vocabulaire existe déjà dans cette boîte. Voulez-vous quand même l\'ajouter ?';

  @override
  String get editVocabAddAnyway => 'Ajouter quand même';

  @override
  String get editVocabSave => 'Enregistrer';

  @override
  String get editVocabNext => 'Suivant';

  @override
  String get editVocabStats => 'Statistiques';

  @override
  String editVocabDue(String dueDate) {
    return 'Prochaine révision : $dueDate';
  }

  @override
  String get editVocabOverdue => 'en retard';

  @override
  String editVocabDifficulty(String difficulty) {
    return 'Complexité : $difficulty sur 10';
  }

  @override
  String editVocabStability(String stability) {
    return 'Stabilité : $stability';
  }

  @override
  String get reviewTitle => 'Étudier';

  @override
  String get reviewBack => 'Retour';

  @override
  String reviewCard(int index, int total) {
    return 'Carte $index / $total';
  }

  @override
  String get reviewPlay => 'Lire';

  @override
  String get reviewAgain => 'Encore';

  @override
  String get reviewHard => 'Difficile';

  @override
  String get reviewGood => 'Bien';

  @override
  String get reviewEasy => 'Facile';

  @override
  String get reviewSkip => 'Passer';

  @override
  String reviewExample(String example) {
    return 'Exemple : $example';
  }

  @override
  String get boxDetailDescription => 'Description';

  @override
  String get boxDetailOptions => 'Options';

  @override
  String get boxDetailDueVocabs => 'Vocabulaires à réviser';

  @override
  String get boxDetailMethod => 'Méthode d\'apprentissage';

  @override
  String get boxDetailEditVocabs => 'Modifier les vocabulaires';

  @override
  String get boxDetailStart => 'Démarrer';

  @override
  String get boxDetailDeleteTitle => 'Supprimer la boîte';

  @override
  String get boxDetailDeleteMessage =>
      'Voulez-vous vraiment supprimer cette boîte ?';

  @override
  String get boxDetailDelete => 'Supprimer';

  @override
  String get boxDetailNotFound => 'Boîte introuvable';

  @override
  String get vocabListTitle => 'Vocabulaire';

  @override
  String get vocabListEmpty => 'Aucun vocabulaire disponible.';

  @override
  String get learningMethodAll => 'Tous';

  @override
  String get learningMethodHard => 'Difficiles uniquement';

  @override
  String get learningMethodNew => 'Nouveaux uniquement';

  @override
  String get learningMethodUnstable => 'Instables uniquement';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonNext => 'Suivant';

  @override
  String get errorExportDirectoryFailed =>
      'Le répertoire d\'exportation n\'a pas pu être créé';

  @override
  String get errorExportWriteFailed =>
      'Les données de vocabulaire n\'ont pas pu être enregistrées';

  @override
  String get errorExportAudioFailed =>
      'Les fichiers audio n\'ont pas pu être copiés';

  @override
  String get errorExportArchiveFailed => 'L\'archive n\'a pas pu être créée';

  @override
  String get errorExportCacheFailed =>
      'Le cache d\'exportation n\'a pas pu être vidé';

  @override
  String get errorImportMissingStoreFile =>
      'Format de fichier invalide : store.json introuvable dans l\'archive';

  @override
  String get errorImportInvalidFormat =>
      'Format de fichier invalide : objet JSON attendu';

  @override
  String errorDuplicateBoxName(String name) {
    return 'Une boîte nommée \"$name\" existe déjà';
  }

  @override
  String get editVocabGenerateAudio => 'Générer la prononciation';

  @override
  String get editVocabOverwriteAudioTitle => 'Remplacer l\'enregistrement ?';

  @override
  String get editVocabOverwriteAudioMessage =>
      'Cette carte possède déjà un enregistrement audio. Le remplacer par la prononciation générée ?';

  @override
  String get editVocabOverwriteAudioConfirm => 'Remplacer';

  @override
  String editVocabTtsTooLongHint(Object len) {
    return 'La prononciation n\'est disponible que jusqu\'à 65 caractères. Ta saisie comporte $len caractères.';
  }

  @override
  String get errorTtsEmptyText =>
      'Le verso ne doit pas être vide pour générer une prononciation.';

  @override
  String get errorTtsTextTooLong =>
      'Le texte ne doit pas dépasser 65 caractères.';

  @override
  String get errorTtsRateLimitExceeded =>
      'Limite quotidienne de générations vocales atteinte.';

  @override
  String get errorTtsNotAuthenticated =>
      'Échec de la connexion. Veuillez réessayer.';

  @override
  String get errorTtsUnknownError =>
      'La prononciation n\'a pas pu être générée. Veuillez vérifier votre connexion internet.';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageDutch => 'Néerlandais';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languagePolish => 'Polonais';

  @override
  String get languageTurkish => 'Turc';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageDanish => 'Danois';

  @override
  String get languageCzech => 'Tchèque';

  @override
  String get languageHungarian => 'Hongrois';

  @override
  String get languageKorean => 'Coréen';

  @override
  String get boxTypeVocabularyTitle => 'Boîte de vocabulaire';

  @override
  String get boxTypeVocabularySubtitle =>
      'Pour apprendre le vocabulaire d\'une langue, avec des fonctionnalités supplémentaires.';

  @override
  String get boxTypeFlashcardTitle => 'Boîte de cartes';

  @override
  String get boxTypeFlashcardSubtitle =>
      'Pour toutes sortes de cartes question-réponse. Toutes les fonctionnalités de base incluses.';

  @override
  String get createBoxNavTitle => 'Nouvelle boîte';

  @override
  String get createBoxTypeTitle => 'Quel type de boîte veux-tu créer ?';

  @override
  String get createBoxTypeSubtitle =>
      'Choisis un type pour la nouvelle boîte. Le type ne peut plus être modifié par la suite.';

  @override
  String get createBoxTypeImportSubtitle =>
      'Importe une boîte avec tous ses mots de vocabulaire et ses fichiers audio.';

  @override
  String get createBoxIconEditTitle => 'Changer l\'icône';

  @override
  String get createBoxIconEditPlaceholder => 'Saisir un emoji';

  @override
  String get createBoxTitleLabel => 'Titre';

  @override
  String get createBoxTitleHint => 'Nom de la boîte';

  @override
  String get createBoxDescriptionLabel => 'Description (optionnel)';

  @override
  String get createBoxDescriptionHint => 'Courte description';

  @override
  String get createBoxNameEmpty => 'Le nom ne peut pas être vide.';

  @override
  String get createBoxSourceLanguageLabel =>
      'Langue source - celle que tu connais déjà';

  @override
  String get createBoxTargetLanguageLabel =>
      'Langue cible - celle que tu apprends';

  @override
  String get createBoxSourceLanguagePickerTitle => 'Choisir la langue source';

  @override
  String get createBoxTargetLanguagePickerTitle => 'Choisir la langue cible';

  @override
  String get createBoxColorTitle => 'Couleur';

  @override
  String get createBoxFinish => 'Terminé';

  @override
  String get languageSearchPlaceholder => 'Rechercher';

  @override
  String get languageCustomOption => 'Personnalisé...';

  @override
  String get languageCustomTitle => 'Langue personnalisée';

  @override
  String get languageCustomPlaceholder => 'Saisir une langue';
}
