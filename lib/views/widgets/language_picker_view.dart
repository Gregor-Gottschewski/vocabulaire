import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/app_language.dart';

/// A generic full-screen, searchable list of all [AppLanguage]s, plus a
/// "Custom..." entry at the top that lets the user type an arbitrary
/// language name. Tapping a language (or confirming a custom name) pops the
/// view with an [AppLanguage.code] or the custom text as the result.
class LanguagePickerView extends StatefulWidget {
  final String title;
  final String? selectedCode;

  const LanguagePickerView({super.key, required this.title, this.selectedCode});

  @override
  State<LanguagePickerView> createState() => _LanguagePickerViewState();
}

class _LanguagePickerViewState extends State<LanguagePickerView> {
  late AppLocalizations _l10n;
  String _query = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  List<AppLanguage> get _filteredLanguages {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return AppLanguage.values;
    return AppLanguage.values
        .where((l) => l.displayName(_l10n).toLowerCase().contains(query))
        .toList();
  }

  Future<void> _pickCustom() async {
    final controller = TextEditingController();
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(_l10n.languageCustomTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.center,
            placeholder: _l10n.languageCustomPlaceholder,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(_l10n.commonCancel),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          CupertinoDialogAction(
            child: Text(_l10n.commonOk),
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty || !mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final languages = _filteredLanguages;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(widget.title)),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: CupertinoSearchTextField(
                placeholder: _l10n.languageSearchPlaceholder,
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          onPressed: _pickCustom,
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.pencil,
                                size: 20.0,
                                color: CupertinoDynamicColor.resolve(
                                  CupertinoColors.systemGrey,
                                  context,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  _l10n.languageCustomOption,
                                  style: TextStyle(
                                    fontSize: 17.0,
                                    color: CupertinoDynamicColor.resolve(
                                      CupertinoColors.label,
                                      context,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 0.5,
                          margin: const EdgeInsets.symmetric(horizontal: 12.0),
                          color: CupertinoColors.separator.resolveFrom(context),
                        ),
                      ],
                    );
                  }

                  final language = languages[index - 1];
                  final isSelected = language.code == widget.selectedCode;

                  return Column(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        onPressed: () => Navigator.of(context).pop(language.code),
                        child: Row(
                          children: [
                            Text(
                              language.flag,
                              style: const TextStyle(fontSize: 20.0),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Text(
                                language.displayName(_l10n),
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
                      if (index == languages.length)
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
          ],
        ),
      ),
    );
  }
}
