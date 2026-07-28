import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/app_language.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';
import 'app_scaffold.dart';
import 'app_text_field.dart';
import 'key_value_row.dart';
import 'primary_action_button.dart';
import 'section_title.dart';
import 'selectable_option_card.dart';

/// A generic full-screen, searchable list of all [AppLanguage]s, plus a
/// "Custom..." entry at the top that lets the user type an arbitrary
/// language name. Tapping a language (or confirming a custom name) pops the
/// view with an [AppLanguage.code] or the custom text as the result.
class LanguagePickerView extends StatefulWidget {
  final String title;
  final String? backLabel;
  final String? selectedCode;

  const LanguagePickerView({
    super.key,
    required this.title,
    this.backLabel,
    this.selectedCode,
  });

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
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.sectionGap,
                AppSpacing.pageHorizontal,
                AppSpacing.sectionGap,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(text: _l10n.languageCustomTitle),
                  const SizedBox(height: AppSpacing.gapMedium),
                  AppTextField(
                    controller: controller,
                    autofocus: true,
                    placeholder: _l10n.languageCustomPlaceholder,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (v) =>
                        Navigator.of(sheetContext).pop(v.trim()),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  PrimaryActionButton(
                    label: _l10n.commonOk,
                    onPressed: () =>
                        Navigator.of(sheetContext).pop(controller.text.trim()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result == null || result.isEmpty || !mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final languages = _filteredLanguages;

    return AppScaffold(
      backLabel: widget.backLabel,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppTypography.headlineSerif.copyWith(
              fontSize: 24,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          AppTextField(
            placeholder: _l10n.languageSearchPlaceholder,
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.gapSmall),
          Expanded(
            child: SingleChildScrollView(
              child: KeyValueRowGroup(
                children: [
                  SelectableOptionCard(
                    title: _l10n.languageCustomOption,
                    selected: false,
                    onTap: _pickCustom,
                  ),
                  for (final language in languages)
                    SelectableOptionCard(
                      title: language.displayName(_l10n),
                      selected: language.code == widget.selectedCode,
                      onTap: () => Navigator.of(context).pop(language.code),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
