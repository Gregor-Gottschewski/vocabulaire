# Localization

This app uses localizations so you can add new languages easily.

See [configuration](/l10n.yaml) `l10n.yaml` for template and general configuration.

Language files are located in `/lib/l10n/app_X.arb`. Generate `.dart`-files with `flutter gen-l10n`.

## Use Localization in Code

Every stateful class that uses localization needs `onDependencyChange` method:

```dart
late AppLocalizations _l10n;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _l10n = AppLocalizations.of(context)!;
}
```

Then you can use localizations with e.g. `_l10n.ilovepizza`.

