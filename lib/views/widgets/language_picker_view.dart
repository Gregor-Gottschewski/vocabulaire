import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/app_language.dart';

/// A generic full-screen list of all [AppLanguage]s. Tapping a language pops
/// the view with that language as the result.
class LanguagePickerView extends StatelessWidget {
  final String title;
  final AppLanguage? selected;

  const LanguagePickerView({super.key, required this.title, this.selected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: SafeArea(
        child: ListView.builder(
          itemCount: AppLanguage.values.length,
          itemBuilder: (context, index) {
            final language = AppLanguage.values[index];
            final isSelected = language == selected;

            return Column(
              children: [
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  color: CupertinoColors.separator.resolveFrom(context),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  onPressed: () => Navigator.of(context).pop(language),
                  child: Row(
                    children: [
                      Text(language.flag, style: const TextStyle(fontSize: 20.0)),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          language.displayName(l10n),
                          style: TextStyle(
                            fontSize: 17.0,
                            color: CupertinoDynamicColor.resolve(
                              CupertinoColors.label,
                              context,
                            ),
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          CupertinoIcons.check_mark,
                          color: CupertinoColors.activeBlue,
                        ),
                    ],
                  ),
                ),
                if (index == AppLanguage.values.length - 1)
                  Container(
                    height: 0.5,
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
