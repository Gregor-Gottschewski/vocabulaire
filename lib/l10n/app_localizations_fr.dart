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
  String get addBox => 'Nouvelle boîte';

  @override
  String get back => 'Retour';

  @override
  String overdueCardsCounter(int num) {
    return '$num en retard';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsImportBox => 'Importer une boîte';

  @override
  String get settingsCardAnimations => 'Animations de cartes';

  @override
  String get settingsSyncStatus => 'État de synchronisation';

  @override
  String get settingsSyncStatusSynced => 'À jour';

  @override
  String get settingsSyncStatusSyncing => 'Synchronisation…';

  @override
  String get settingsSyncStatusOffline => 'Hors ligne';

  @override
  String get settingsLicenses => 'Licences';

  @override
  String get settingsGithub => 'Vocabulaire à GitHub';

  @override
  String get settingsBoxSync => 'Synchronisation des boîtes';

  @override
  String get settingsExportAll => 'Exporter toutes les boîtes';

  @override
  String get settingsVocabularyUsage => 'Vocabulaire en ligne';

  @override
  String settingsVocabularyUsageValue(int count, int limit) {
    return '$count/$limit';
  }

  @override
  String get settingsAudioUsage => 'Stockage audio en ligne';

  @override
  String settingsAudioUsageValue(String usedMb, int limitMb) {
    return '$usedMb Mo / $limitMb Mo';
  }

  @override
  String get boxSyncTitle => 'Synchronisation des boîtes';

  @override
  String get boxSyncDescription =>
      'Les boîtes stockées en ligne sont synchronisées sur tous vos appareils, les boîtes locales ne sont disponibles que sur cet appareil. Déplacez une boîte dans l\'un ou l\'autre sens.';

  @override
  String get boxSyncEmpty => 'Aucune boîte.';

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
  String get editVocabConjugationSection => 'Conjugaison';

  @override
  String get editVocabConjugationTempsHint => 'Temps';

  @override
  String get editVocabConjugationFormsHint => 'Formes';

  @override
  String get editVocabConjugationAdd => '+ Ajouter une conjugaison';

  @override
  String reviewCard(int index, int total) {
    return '$index sur $total';
  }

  @override
  String get reviewPlay => 'Écouter';

  @override
  String get reviewShowTranslation => 'Afficher la traduction';

  @override
  String get reviewShowBack => 'Afficher le verso';

  @override
  String get reviewRatingQuestion => 'Comment évalues-tu ce mot ?';

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
  String get boxTileNoDescription => 'Aucune description disponible';

  @override
  String get boxDetailOptions => 'Options';

  @override
  String get boxDetailDueVocabs => 'Interroger les vocabulaires à réviser';

  @override
  String get boxDetailMethod => 'Méthode d\'apprentissage';

  @override
  String get boxDetailDailyLimit => 'Limite quotidienne de nouvelles cartes';

  @override
  String get boxDetailNewCardsPerDay => 'Nouvelles cartes / jour';

  @override
  String get boxDetailDailyLimitInfo =>
      'La limite quotidienne restreint le nombre de nouveaux mots révisés par jour.';

  @override
  String get boxDetailEditVocabs => 'Afficher la liste des vocabulaires';

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
  String boxDetailSubline(int total, int due) {
    return '$total mots — $due à réviser maintenant';
  }

  @override
  String boxDetailDailyLimitValue(int count) {
    return '$count cartes';
  }

  @override
  String get boxDetailActionsSheetTitle => 'Modifier cette boîte.';

  @override
  String get boxDetailEditAction => 'Modifier';

  @override
  String get boxDetailShareAction => 'Partager';

  @override
  String get boxDetailSaveAction => 'Enregistrer';

  @override
  String get boxDetailDailyLimitOff => 'Désactivé';

  @override
  String get boxDetailDailyLimitEnable => 'Activer la limite quotidienne';

  @override
  String get boxDetailMoveOfflineAction => 'Rendre locale';

  @override
  String get boxDetailMoveOfflineTitle => 'Rendre la boîte locale';

  @override
  String get boxDetailMoveOfflineMessage =>
      'La boîte sera stockée localement sur cet appareil et ne sera plus synchronisée entre appareils. Continuer ?';

  @override
  String get boxDetailMoveOnlineAction => 'Mettre en ligne';

  @override
  String get boxDetailMoveOnlineTitle => 'Mettre la boîte en ligne';

  @override
  String get boxDetailMoveOnlineMessage =>
      'La boîte sera envoyée dans le cloud et synchronisée sur tous vos appareils. Continuer ?';

  @override
  String get vocabListTitle => 'Vocabulaire';

  @override
  String get vocabListEmpty => 'Aucun vocabulaire disponible.';

  @override
  String get vocabListSearchPlaceholder => 'Rechercher';

  @override
  String get vocabListNoResults => 'Aucun vocabulaire trouvé.';

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
  String get errorExportBulkDirectoryFailed =>
      'L\'exportation n\'a pas pu être préparée';

  @override
  String get errorExportBulkArchiveFailed =>
      'Les boîtes n\'ont pas pu être regroupées pour l\'exportation';

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
  String get errorMoveBoxOfflineFailed =>
      'La boîte n\'a pas pu être rendue locale';

  @override
  String get errorMoveBoxOnlineFailed =>
      'La boîte n\'a pas pu être mise en ligne';

  @override
  String get errorMoveGroupOfflineFailed =>
      'Le groupe n\'a pas pu être rendu local';

  @override
  String get errorMoveGroupOnlineFailed =>
      'Le groupe n\'a pas pu être mis en ligne';

  @override
  String get errorAddVocabularyFailed =>
      'Le vocabulaire n\'a pas pu être enregistré';

  @override
  String get errorVocabularyLimitReached =>
      'Limite de vocabulaire en ligne atteinte. Rends une boîte locale pour libérer de la place pour du nouveau vocabulaire en ligne.';

  @override
  String get errorGroupLimitReached => 'Limite de 1000 groupes atteinte.';

  @override
  String get errorBoxLimitPerGroupReached =>
      'Limite de 800 boîtes par groupe atteinte.';

  @override
  String get errorAudioStorageLimitReached =>
      'Limite de stockage audio atteinte. Rends une boîte locale pour libérer de l\'espace de stockage.';

  @override
  String get editVocabGenerateAudio => 'Générer';

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
  String get editVocabUnsavedChangesTitle =>
      'Voulez-vous enregistrer vos modifications ?';

  @override
  String get editVocabUnsavedChangesSaveAndLeave => 'Enregistrer et quitter';

  @override
  String get editVocabUnsavedChangesDiscard => 'Ignorer les modifications';

  @override
  String get editVocabDeleteTitle => 'Supprimer le vocabulaire';

  @override
  String get editVocabDeleteMessage =>
      'Voulez-vous vraiment supprimer ce vocabulaire ?';

  @override
  String get editVocabDeleteConfirm => 'Supprimer';

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
  String get language => 'Langue';

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
  String get createBoxTitleLabel => 'Titre';

  @override
  String get createBoxTitleHint => 'Nom de la boîte';

  @override
  String get createBoxDescriptionLabel => 'Description';

  @override
  String get createBoxDescriptionHint => 'Optionnel courte description';

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
  String get createBoxOnlineSync => 'Enregistrer en ligne';

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
