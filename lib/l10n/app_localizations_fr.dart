// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get tabVokabeln => 'Vocabulaire';

  @override
  String get tabGroups => 'Groupes';

  @override
  String get tabEinstellungen => 'Paramètres';

  @override
  String get homeEmpty => 'Aucune boîte disponible.';

  @override
  String get addBox => 'Nouvelle boîte';

  @override
  String get groupsEmpty => 'Aucun groupe disponible.';

  @override
  String get addGroup => 'Nouveau groupe';

  @override
  String get back => 'Retour';

  @override
  String overdueCardsCounter(int num) {
    return '$num en retard';
  }

  @override
  String groupTileBoxCount(int count) {
    return '$count boîtes';
  }

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionUserExperience => 'Expérience utilisateur';

  @override
  String get settingsSectionPremiumFeatures => 'Fonctionnalités premium';

  @override
  String get settingsSectionYourContent => 'Ton contenu';

  @override
  String get settingsChangeEmail => 'Changer l\'adresse e-mail';

  @override
  String get settingsChangePassword => 'Changer le mot de passe';

  @override
  String get settingsAccountDeletion => 'Supprimer le compte';

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
  String get boxDetailDueVocabs => 'Interroger les vocabulaires à réviser';

  @override
  String get boxDetailMethod => 'Méthode d\'apprentissage';

  @override
  String get boxDetailDailyLimit => 'Limite quotidienne de nouvelles cartes';

  @override
  String get boxDetailNewCardsPerDay => 'Nouvelles cartes / jour';

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
  String get groupDetailActionsSheetTitle => 'Modifier cette groupe.';

  @override
  String get editAction => 'Modifier';

  @override
  String get export => 'Exporter';

  @override
  String get groupDetailImportAction => 'Importer';

  @override
  String get settingsImportBox => 'Importer une boîte';

  @override
  String get boxDetailDailyLimitOff => 'Désactivé';

  @override
  String get boxDetailDailyLimitEnable => 'Activer la limite quotidienne';

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
  String get errorImportGroupMismatch =>
      'Cette boîte ne correspond pas au groupe : le type ou la langue diffère';

  @override
  String get errorImportFailed => 'La boîte n\'a pas pu être importée.';

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
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitle =>
      'Ton billet d\'entrée dans le monde du vocabulaire. Connecte-toi ou crée un nouveau compte.';

  @override
  String get registerTitle => 'Tu es nouveau ici ?';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get loginSubmitButton => 'Se connecter';

  @override
  String get registerSubmitButton => 'Créer un compte';

  @override
  String get loginSwitchToRegister => 'Pas encore de compte ? S\'inscrire';

  @override
  String get loginSwitchToLogin => 'Déjà inscrit ? Se connecter';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get resetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordSubtitle =>
      'Tu recevras un lien pour définir un nouveau mot de passe.';

  @override
  String get resetPasswordEmailLabel => 'E-mail';

  @override
  String get resetPasswordSubmitButton => 'Réinitialiser';

  @override
  String get resetPasswordSuccessMessage =>
      'Si un compte existe pour cette adresse e-mail, un lien de réinitialisation du mot de passe a été envoyé.';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsSignOutConfirmTitle =>
      'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get verifyEmailTitle => 'Vérifie ton e-mail';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Nous avons envoyé un e-mail de vérification à $email. Merci de vérifier ton adresse e-mail pour utiliser Vocabulaire.';
  }

  @override
  String get verifyEmailResend => 'Renvoyer l\'e-mail';

  @override
  String verifyEmailResendCountdown(int seconds) {
    return 'Renvoyer l\'e-mail ($seconds)';
  }

  @override
  String get verifyEmailResendSuccessTitle => 'E-mail envoyé';

  @override
  String get verifyEmailResendSuccessMessage =>
      'Nous t\'avons envoyé un nouvel e-mail de vérification.';

  @override
  String get changeEmailTitle => 'Changer l\'adresse e-mail';

  @override
  String changeEmailSubtitle(String email) {
    return 'Ton adresse e-mail actuelle est $email. Saisis ta nouvelle adresse e-mail et ton mot de passe actuel pour confirmer le changement.';
  }

  @override
  String get changeEmailNewEmailLabel => 'Nouvelle adresse e-mail';

  @override
  String get changeEmailPasswordLabel => 'Mot de passe actuel';

  @override
  String get changeEmailSubmitButton => 'Changer l\'adresse e-mail';

  @override
  String get changeEmailSuccessTitle => 'E-mail de vérification envoyé';

  @override
  String get changeEmailSuccessMessage =>
      'Nous avons envoyé un lien de confirmation à ta nouvelle adresse e-mail. Ton adresse e-mail ne changera qu\'après avoir cliqué dessus.';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get changePasswordSubtitle =>
      'Saisis ton mot de passe actuel et un nouveau mot de passe pour confirmer le changement.';

  @override
  String get changePasswordCurrentPasswordLabel => 'Mot de passe actuel';

  @override
  String get changePasswordNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get changePasswordConfirmPasswordLabel =>
      'Confirmer le nouveau mot de passe';

  @override
  String get changePasswordSubmitButton => 'Changer le mot de passe';

  @override
  String get changePasswordSuccessTitle => 'Mot de passe modifié';

  @override
  String get changePasswordSuccessMessage =>
      'Ton mot de passe a été modifié avec succès.';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountSubtitle =>
      'Saisis ton mot de passe actuel pour confirmer la suppression définitive de ton compte. Tout le vocabulaire, les boîtes, les groupes et les enregistrements audio seront supprimés de manière irrévocable.';

  @override
  String get deleteAccountPasswordLabel => 'Mot de passe actuel';

  @override
  String get deleteAccountSubmitButton => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmTitle =>
      'Supprimer définitivement le compte ?';

  @override
  String get deleteAccountConfirmMessage =>
      'Cette action est irréversible. Toutes tes données seront supprimées de manière irrévocable.';

  @override
  String get deleteAccountConfirmButton => 'Supprimer définitivement';

  @override
  String get errorAuthInvalidEmail => 'Votre adresse e-mail semble incorrecte.';

  @override
  String get errorAuthUserDisabled =>
      'Votre compte a été désactivé. Veuillez contacter notre support.';

  @override
  String get errorAuthUserNotFound =>
      'L\'e-mail ou le mot de passe saisi est incorrect.';

  @override
  String get errorAuthWrongPassword =>
      'L\'e-mail ou le mot de passe saisi est incorrect.';

  @override
  String get errorAuthEmailAlreadyInUse =>
      'Vous possédez déjà un compte avec cette adresse e-mail. Vous allez être redirigé vers la page de connexion.';

  @override
  String get errorAuthWeakPassword =>
      'Le mot de passe doit comporter au moins 8 caractères et contenir au moins une majuscule, une minuscule, un chiffre et un caractère spécial.';

  @override
  String errorAuthWeakPasswordDetailed(String requirements) {
    return 'Ton mot de passe doit encore respecter les critères suivants : $requirements.';
  }

  @override
  String get errorAuthPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas.';

  @override
  String passwordRequirementMinLength(int length) {
    return 'au moins $length caractères';
  }

  @override
  String passwordRequirementMaxLength(int length) {
    return 'au plus $length caractères';
  }

  @override
  String get passwordRequirementLowercase => 'une minuscule';

  @override
  String get passwordRequirementUppercase => 'une majuscule';

  @override
  String get passwordRequirementDigit => 'un chiffre';

  @override
  String get passwordRequirementSymbol => 'un caractère spécial';

  @override
  String get errorAuthNetworkFailed =>
      'Pas de connexion internet. Veuillez réessayer.';

  @override
  String get errorAuthTooManyRequests =>
      'Vous avez effectué trop de tentatives. Veuillez réessayer plus tard.';

  @override
  String get errorAuthUnknownError =>
      'Échec de la connexion. Veuillez réessayer.';

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
  String get createBoxNavTitle => 'Nouvelle boîte';

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
  String get finish => 'Terminé';

  @override
  String get createGroupNavTitle => 'Nouveau groupe';

  @override
  String get createGroupTypeTitle => 'Quel type de groupe veux-tu créer ?';

  @override
  String get createGroupTypeSubtitle =>
      'Choisis un type pour le nouveau groupe. Le type ne pourra plus être modifié par la suite.';

  @override
  String get createGroupTitleHint => 'Nom du groupe';

  @override
  String get groupTypeVocabularyTitle => 'Groupe de vocabulaire';

  @override
  String get groupTypeVocabularySubtitle =>
      'Pour apprendre le vocabulaire d\'une langue, avec des fonctionnalités supplémentaires.';

  @override
  String get groupTypeFlashcardTitle => 'Groupe de cartes';

  @override
  String get groupTypeFlashcardSubtitle =>
      'Pour toutes sortes de cartes question-réponse. Toutes les fonctionnalités de base incluses.';

  @override
  String get groupDetailDeleteTitle => 'Supprimer le groupe';

  @override
  String get groupDetailDeleteMessage =>
      'Veux-tu vraiment supprimer ce groupe ? Toutes les boîtes qu\'il contient seront également supprimées.';

  @override
  String get languageSearchPlaceholder => 'Rechercher';

  @override
  String get languageCustomOption => 'Personnalisé...';

  @override
  String get languageCustomTitle => 'Langue personnalisée';

  @override
  String get languageCustomPlaceholder => 'Saisir une langue';

  @override
  String get settingsUpgradeToPremium => 'Passer à Premium';

  @override
  String get settingsManageSubscription => 'Gérer l\'abonnement';

  @override
  String get subscriptionHeadline => 'Apprendre sans limites';

  @override
  String get subscriptionSubtitle =>
      'Synchronisation de ton vocabulaire sur tous tes appareils et accès à l\'aide à la prononciation.';

  @override
  String get subscriptionPlanYearly => 'An';

  @override
  String get subscriptionPlanMonthly => 'Mois';

  @override
  String get subscriptionCta => 'Essayer gratuitement pendant 7 jours';

  @override
  String subscriptionFinePrint(String price, String period) {
    return 'Puis $price / $period';
  }

  @override
  String get subscriptionAutoRenewNotice =>
      'L\'abonnement se renouvelle automatiquement, sauf annulation au moins 24 heures avant la fin de la période en cours.';

  @override
  String get subscriptionRestore => 'Restaurer les achats';

  @override
  String get errorSubscriptionProductsUnavailable =>
      'Les produits d\'abonnement n\'ont pas pu être chargés. Vérifie ta connexion internet.';

  @override
  String get errorSubscriptionPurchaseFailed =>
      'L\'achat n\'a pas pu être finalisé. Merci de réessayer.';

  @override
  String get errorSubscriptionVerificationFailed =>
      'L\'achat n\'a pas pu être vérifié. Réessaie ou contacte le support.';

  @override
  String get errorSubscriptionRestoreFailed =>
      'Les achats n\'ont pas pu être restaurés. Merci de réessayer.';
}
