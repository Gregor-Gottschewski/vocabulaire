import 'package:vocabulaire/l10n/app_localizations.dart';

/// [AppLanguage] represents a language that can be chosen
/// as vocabulary language.
enum AppLanguage {
  german('de', '🇩🇪'),
  english('en', '🇬🇧'),
  french('fr', '🇫🇷'),
  spanish('es', '🇪🇸'),
  italian('it', '🇮🇹'),
  portuguese('pt', '🇵🇹'),
  dutch('nl', '🇳🇱'),
  russian('ru', '🇷🇺'),
  polish('pl', '🇵🇱'),
  turkish('tr', '🇹🇷'),
  chinese('zh', '🇨🇳'),
  japanese('ja', '🇯🇵'),
  danish('da', '🇩🇰'),
  czech('cs', '🇨🇿'),
  hungarian('hu', '🇭🇺'),
  korean('ko', '🇰🇷');

  final String code;
  final String flag;

  const AppLanguage(this.code, this.flag);

  static AppLanguage? fromCode(String? code) {
    if (code == null) return null;
    for (final language in AppLanguage.values) {
      if (language.code == code) return language;
    }
    return null;
  }

  String displayName(AppLocalizations l10n) {
    switch (this) {
      case AppLanguage.german:
        return l10n.languageGerman;
      case AppLanguage.english:
        return l10n.languageEnglish;
      case AppLanguage.french:
        return l10n.languageFrench;
      case AppLanguage.spanish:
        return l10n.languageSpanish;
      case AppLanguage.italian:
        return l10n.languageItalian;
      case AppLanguage.portuguese:
        return l10n.languagePortuguese;
      case AppLanguage.dutch:
        return l10n.languageDutch;
      case AppLanguage.russian:
        return l10n.languageRussian;
      case AppLanguage.polish:
        return l10n.languagePolish;
      case AppLanguage.turkish:
        return l10n.languageTurkish;
      case AppLanguage.chinese:
        return l10n.languageChinese;
      case AppLanguage.japanese:
        return l10n.languageJapanese;
      case AppLanguage.danish:
        return l10n.languageDanish;
      case AppLanguage.czech:
        return l10n.languageCzech;
      case AppLanguage.hungarian:
        return l10n.languageHungarian;
      case AppLanguage.korean:
        return l10n.languageKorean;
    }
  }
}
