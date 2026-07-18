import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/controllers/create_box_draft.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/box_color.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/views/widgets/color_swatch_picker.dart';
import 'package:vocabulaire/views/widgets/language_picker_view.dart';
import 'package:vocabulaire/views/widgets/navigation_row.dart';
import 'package:vocabulaire/views/widgets/primary_action_button.dart';

/// Step 2 of the box-creation flow: title, description, icon, languages
/// (only for vocabulary boxes) and color, then creates the [VocabularyBox].
class CreateBoxDetailView extends StatefulWidget {
  final CreateBoxDraft draft;

  const CreateBoxDetailView({super.key, required this.draft});

  @override
  State<CreateBoxDetailView> createState() => _CreateBoxDetailViewState();
}

class _CreateBoxDetailViewState extends State<CreateBoxDetailView> {
  final BoxController _boxController = BoxController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  late AppLocalizations _l10n;
  late String _icon;
  late BoxColor _color;
  String? _source;
  String? _target;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.draft.name;
    _descController.text = widget.draft.description;
    _icon = widget.draft.icon;
    _color = widget.draft.color;
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

  /// [_editIcon] shows dialog to edit the box' icon.
  Future<void> _editIcon() async {
    final controller = TextEditingController(text: _icon);
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(_l10n.createBoxIconEditTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.center,
            placeholder: _l10n.createBoxIconEditPlaceholder,
            style: const TextStyle(fontSize: 24.0),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(_l10n.commonCancel),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          CupertinoDialogAction(
            child: Text(_l10n.commonOk),
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          ),
        ],
      ),
    );

    final characters = result?.trim().characters;
    if (characters == null || characters.isEmpty) return;
    setState(() => _icon = characters.first);
  }

  Future<String?> _showLanguagePicker(String title, String? langCode) {
    return Navigator.of(context).push<String>(
      CupertinoPageRoute(
        builder: (_) => LanguagePickerView(
          title: title,
          selectedCode: langCode,
        ),
      ),
    );
  }

  Future<void> _pickSourceLanguage() async {
    final result = await _showLanguagePicker(_l10n.createBoxSourceLanguagePickerTitle, _source);
    if (result == null) return;
    setState(() => _source = result);
  }

  Future<void> _pickTargetLanguage() async {
    final result = await _showLanguagePicker(_l10n.createBoxTargetLanguagePickerTitle, _target);
    if (result == null) return;
    setState(() => _target = result);
  }

  /// Renders a language code as "flag  name" — falls back to a generic icon
  /// and the raw text for custom (non-[AppLanguage]) entries.
  String _languageLabel(String? code) {
    if (code == null) return '';
    final language = AppLanguage.fromCode(code);
    final flag = language?.flag ?? '🌐';
    final name = language?.displayName(_l10n) ?? code;
    return '$flag  $name';
  }

  Future<void> _onFinish() async {
    final name = _nameController.text.trim();
    final description = _descController.text.trim();

    if (name.isEmpty) {
      await showCupertinoDialog(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: Text(_l10n.commonError),
          content: Text(_l10n.createBoxNameEmpty),
          actions: [
            CupertinoDialogAction(
              child: Text(_l10n.commonOk),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final isVocabulary = widget.draft.type == BoxType.vocabulary;
    final box = VocabularyBox(
      name: name,
      description: description,
      vocabularies: const [],
      type: widget.draft.type.name,
      icon: _icon,
      color: _color.name,
      sourceLanguage: isVocabulary ? _source : null,
      targetLanguage: isVocabulary ? _target : null,
    );

    try {
      final key = await _boxController.addBox(box);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop((box: box, key: key));
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVocabulary = widget.draft.type == BoxType.vocabulary;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_l10n.createBoxNavTitle),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 72.0,
                              height: 72.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(_color.argb),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                _icon,
                                style: const TextStyle(fontSize: 36.0),
                              ),
                            ),
                            Positioned(
                              bottom: -4.0,
                              right: -4.0,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                onPressed: _editIcon,
                                child: const Icon(
                                  CupertinoIcons.pencil_circle_fill,
                                  size: 24.0,
                                  color: CupertinoColors.activeBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Text(
                        _l10n.createBoxTitleLabel,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: CupertinoDynamicColor.resolve(
                            CupertinoColors.systemGrey,
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      CupertinoTextField(
                        controller: _nameController,
                        placeholder: _l10n.createBoxTitleHint,
                        clearButtonMode: OverlayVisibilityMode.editing,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        _l10n.createBoxDescriptionLabel,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: CupertinoDynamicColor.resolve(
                            CupertinoColors.systemGrey,
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      CupertinoTextField(
                        controller: _descController,
                        placeholder: _l10n.createBoxDescriptionHint,
                        minLines: 1,
                        maxLines: 3,
                      ),
                      if (isVocabulary) ...[
                        const SizedBox(height: 16.0),
                        NavigationRowGroup(
                          children: [
                            NavigationRow(
                              secondaryLabel: _l10n.createBoxSourceLanguageLabel,
                              primaryContent: Text(_languageLabel(_source)),
                              onTap: _pickSourceLanguage,
                            ),
                            NavigationRow(
                              secondaryLabel: _l10n.createBoxTargetLanguageLabel,
                              primaryContent: Text(_languageLabel(_target)),
                              onTap: _pickTargetLanguage,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16.0),
                      ColorSwatchPicker(
                        title: _l10n.createBoxColorTitle,
                        options: BoxColor.values,
                        selected: _color,
                        onChanged: (c) => setState(() => _color = c),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: PrimaryActionButton(
                label: _l10n.createBoxFinish,
                isLoading: _isSaving,
                onPressed: _onFinish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
