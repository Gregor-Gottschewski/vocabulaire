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
  String get addBoxTitle => 'Créer une nouvelle boîte';

  @override
  String get addBoxNameLabel => 'Nom de la boîte';

  @override
  String get addBoxDescriptionLabel => 'Description (optionnel)';

  @override
  String get addBoxButton => 'Ajouter';

  @override
  String get addBoxNameEmpty => 'Le nom ne peut pas être vide.';

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
}
