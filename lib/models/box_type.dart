import 'package:vocabulaire/l10n/app_localizations.dart';

/// Represents the type of a [VocabularyBox].
enum BoxType {
  vocabulary,
  flashcard;

  /// Returns [BoxType] element based on input.
  /// Default is [BoxType.flashcard] if string name unknown.
  static BoxType fromName(String name) {
    return BoxType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => BoxType.flashcard,
    );
  }

  String title(AppLocalizations l10n) {
    switch (this) {
      case BoxType.vocabulary:
        return l10n.boxTypeVocabularyTitle;
      case BoxType.flashcard:
        return l10n.boxTypeFlashcardTitle;
    }
  }

  String subtitle(AppLocalizations l10n) {
    switch (this) {
      case BoxType.vocabulary:
        return l10n.boxTypeVocabularySubtitle;
      case BoxType.flashcard:
        return l10n.boxTypeFlashcardSubtitle;
    }
  }
}
