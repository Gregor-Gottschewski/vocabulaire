import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/controllers/box_draft.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/field_limits.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/services/usage_service.dart';
import 'package:vocabulaire/theme/app_page_route.dart';
import 'package:vocabulaire/theme/app_spacing.dart';
import 'package:vocabulaire/theme/app_typography.dart';
import 'package:vocabulaire/views/widgets/app_dialog.dart';
import 'package:vocabulaire/views/widgets/app_scaffold.dart';
import 'package:vocabulaire/views/widgets/app_text_field.dart';
import 'package:vocabulaire/views/widgets/key_value_row.dart';
import 'package:vocabulaire/views/widgets/label_text_field.dart';
import 'package:vocabulaire/views/widgets/language_picker_view.dart';
import 'package:vocabulaire/views/widgets/section_title.dart';
import 'package:vocabulaire/views/widgets/header_text_button.dart';

/// Step 2 of the box-creation flow: title, description and languages (only
/// for vocabulary boxes), then creates the [VocabularyBox].
class CreateBoxDetailView extends StatefulWidget {
  final BoxDraft draft;

  const CreateBoxDetailView({super.key, required this.draft});

  @override
  State<CreateBoxDetailView> createState() => _CreateBoxDetailViewState();
}

class _CreateBoxDetailViewState extends State<CreateBoxDetailView> {
  final BoxController _boxController = BoxController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  late AppLocalizations _l10n;
  String? _source;
  String? _target;
  bool _saveOnline = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.draft.name;
    _descController.text = widget.draft.description;
    _source = widget.draft.sourceLanguage;
    _target = widget.draft.targetLanguage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  bool get _isEditing => widget.draft.id != null;

  Future<String?> _showLanguagePicker(String title, String? langCode) {
    return Navigator.of(context).push<String>(
      AppPageRoute(
        builder: (_) => LanguagePickerView(
          title: title,
          backLabel: _l10n.createBoxNavTitle,
          selectedCode: langCode,
        ),
      ),
    );
  }

  Future<void> _pickSourceLanguage() async {
    final result = await _showLanguagePicker(
      _l10n.createBoxSourceLanguagePickerTitle,
      _source,
    );
    if (result == null) return;
    setState(() => _source = result);
  }

  Future<void> _pickTargetLanguage() async {
    final result = await _showLanguagePicker(
      _l10n.createBoxTargetLanguagePickerTitle,
      _target,
    );
    if (result == null) return;
    setState(() => _target = result);
  }

  /// Renders a language code as its display name — falls back to the raw
  /// text for custom (non-[AppLanguage]) entries.
  String _languageLabel(String? code) {
    if (code == null) return '';
    final language = AppLanguage.fromCode(code);
    return language?.displayName(_l10n) ?? code;
  }

  Future<void> _onFinish() async {
    final name = _nameController.text.trim();
    final description = _descController.text.trim();

    if (name.isEmpty) {
      await showAppDialog(
        context: context,
        title: _l10n.commonError,
        message: _l10n.createBoxNameEmpty,
        actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      );
      return;
    }

    setState(() => {});

    final isVocabulary = widget.draft.type == BoxType.vocabulary;

    try {
      if (_isEditing) {
        final boxId = widget.draft.id!;
        final current = _boxController.getBox(boxId);
        if (current == null) {
          if (!mounted) return;
          Navigator.of(context).pop();
          return;
        }
        final updated = current.copyWith(
          name: name,
          description: description,
          sourceLanguage: isVocabulary ? _source : null,
          targetLanguage: isVocabulary ? _target : null,
        );
        _boxController.updateBox(boxId, updated);
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }

      final box = VocabularyBox(
        id: const Uuid().v4(),
        name: name,
        description: description,
        vocabularies: const [],
        type: widget.draft.type.name,
        sourceLanguage: isVocabulary ? _source : null,
        targetLanguage: isVocabulary ? _target : null,
      );
      await _boxController.addBoxes([box], online: UsageService.instance.listenable.value.isPremium && _saveOnline);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop((box: box, key: box.id));
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
    } finally {
      if (mounted) setState(() => {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVocabulary = widget.draft.type == BoxType.vocabulary;

    return AppScaffold(
      backLabel: _isEditing ? _l10n.back : _l10n.createBoxNavTitle,
      actions: [
        HeaderTextButton(
          label:
              "${_isEditing ? _l10n.boxDetailSaveAction : _l10n.createBoxFinish} →",
          onPressed: _onFinish,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelTextField(
                      label: _l10n.createBoxTitleLabel.toUpperCase(),
                      textField: AppTextField(
                        controller: _nameController,
                        style: AppTypography.headlineSerif,
                        placeholder: _l10n.createBoxTitleHint,
                        maxLength: FieldLimits.boxName,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    LabelTextField(
                      label: _l10n.createBoxDescriptionLabel.toUpperCase(),
                      textField: AppTextField(
                        controller: _descController,
                        style: AppTypography.serifValue,
                        placeholder: _l10n.createBoxDescriptionHint,
                        maxLines: 3,
                        maxLength: FieldLimits.boxDescription,
                      ),
                    ),
                    if (!_isEditing &&
                        UsageService.instance.listenable.value.isPremium) ...[
                      const SizedBox(height: AppSpacing.sectionGap),
                      KeyValueRowGroup(
                        children: [
                          KeyValueRow.toggle(
                            label: _l10n.createBoxOnlineSync,
                            value: _saveOnline,
                            onChanged: (v) => setState(() => _saveOnline = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.gapSmall),
                    ],
                    if (isVocabulary) ...[
                      const SizedBox(height: AppSpacing.sectionGap),
                      SectionTitle(text: _l10n.language),
                      const SizedBox(height: AppSpacing.gapSmall),
                      KeyValueRowGroup(
                        children: [
                          KeyValueRow.value(
                            label: _l10n.createBoxSourceLanguageLabel,
                            value: _languageLabel(_source),
                            onTap: _pickSourceLanguage,
                          ),
                          KeyValueRow.value(
                            label: _l10n.createBoxTargetLanguageLabel,
                            value: _languageLabel(_target),
                            onTap: _pickTargetLanguage,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
