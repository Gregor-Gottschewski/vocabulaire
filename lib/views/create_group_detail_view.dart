import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabulaire/controllers/group_controller.dart';
import 'package:vocabulaire/controllers/group_draft.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/field_limits.dart';
import 'package:vocabulaire/models/vocabulary_group.dart';
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

/// Step 2 of the group-creation flow, and the "Edit group" screen.
///
/// Creating: title, language (only for vocabulary groups) and online-sync.
/// Editing: only the name and the online-sync status can change — type and
/// language are fixed for the group's lifetime once created. Toggling
/// online-sync in edit mode moves the group (and all its boxes) between
/// local and online storage immediately, with no confirmation dialog.
class CreateGroupDetailView extends StatefulWidget {
  final GroupDraft draft;
  final bool isEditing;

  const CreateGroupDetailView({
    super.key,
    required this.draft,
    this.isEditing = false,
  });

  @override
  State<CreateGroupDetailView> createState() => _CreateGroupDetailViewState();
}

class _CreateGroupDetailViewState extends State<CreateGroupDetailView> {
  final GroupController _groupController = GroupController();
  final TextEditingController _nameController = TextEditingController();
  late AppLocalizations _l10n;
  String? _source;
  String? _target;
  bool _saveOnline = true;
  bool _isSyncing = false;

  bool get _isEditing => widget.isEditing;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.draft.name;
    _source = widget.draft.sourceLanguage;
    _target = widget.draft.targetLanguage;
    if (_isEditing && widget.draft.id != null) {
      _saveOnline = !_groupController.isLocal(widget.draft.id!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<String?> _showLanguagePicker(String title, String? langCode) {
    return Navigator.of(context).push<String>(
      AppPageRoute(
        builder: (_) => LanguagePickerView(
          title: title,
          backLabel: _l10n.createGroupNavTitle,
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

  /// Moves the group between local and online storage. No confirmation
  /// dialog — reverts the toggle and shows an error on failure.
  Future<void> _toggleOnlineSync(bool value) async {
    final groupId = widget.draft.id;
    if (groupId == null || _isSyncing) return;

    setState(() {
      _isSyncing = true;
      _saveOnline = value;
    });

    try {
      if (value) {
        await _groupController.moveGroupOnline(groupId);
      } else {
        await _groupController.moveGroupOffline(groupId);
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _saveOnline = !value);
      await context.showAppError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saveOnline = !value);
      await context.showAppError(
        AppException(
          value
              ? AppError.moveGroupOnlineFailed
              : AppError.moveGroupOfflineFailed,
          details: e,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _onFinish() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      await showAppDialog(
        context: context,
        title: _l10n.commonError,
        message: _l10n.createBoxNameEmpty,
        actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      );
      return;
    }

    if (_isEditing) {
      await _saveEdit(name);
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    final isVocabulary = widget.draft.type == BoxType.vocabulary;
    final isPremium = UsageService.instance.listenable.value.isPremium;
    final group = VocabularyGroup(
      id: const Uuid().v4(),
      name: name,
      type: widget.draft.type.name,
      sourceLanguage: isVocabulary ? _source : null,
      targetLanguage: isVocabulary ? _target : null,
    );

    try {
      await _groupController.addGroups([
        group,
      ], online: isPremium && _saveOnline);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(group);
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
    }
  }

  Future<void> _saveEdit(String name) async {
    if (widget.draft.name != name) {
      await _groupController.updateGroupName(widget.draft.id!, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVocabulary = widget.draft.type == BoxType.vocabulary;
    final isPremium = UsageService.instance.listenable.value.isPremium;

    return AppScaffold(
      backLabel: _isEditing ? _l10n.back : _l10n.createGroupNavTitle,
      actions: [
        HeaderTextButton(label: "${_l10n.finish} →", onPressed: _onFinish),
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
                        placeholder: _l10n.createGroupTitleHint,
                        maxLength: FieldLimits.groupName,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(height: AppSpacing.sectionGap),
                      KeyValueRowGroup(
                        children: [
                          KeyValueRow.toggle(
                            label: _l10n.createBoxOnlineSync,
                            value: _saveOnline,
                            onChanged: _isSyncing
                                ? (_) {}
                                : (_isEditing
                                      ? _toggleOnlineSync
                                      : (v) => setState(() => _saveOnline = v)),
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
                            onTap: _isEditing ? null : _pickSourceLanguage,
                          ),
                          KeyValueRow.value(
                            label: _l10n.createBoxTargetLanguageLabel,
                            value: _languageLabel(_target),
                            onTap: _isEditing ? null : _pickTargetLanguage,
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
