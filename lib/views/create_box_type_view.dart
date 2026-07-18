import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/controllers/create_box_draft.dart';
import 'package:vocabulaire/controllers/import_controller.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/box_color.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/views/create_box_detail_view.dart';
import 'package:vocabulaire/views/widgets/primary_action_button.dart';
import 'package:vocabulaire/views/widgets/selectable_option_card.dart';

enum _TypeOption { vocabulary, flashcard, import }

/// Choose between a vocabulary box, a flashcard box, or importing a box.
class CreateBoxTypeView extends StatefulWidget {
  final CreateBoxDraft draft;

  const CreateBoxTypeView({super.key, required this.draft});

  @override
  State<CreateBoxTypeView> createState() => _CreateBoxTypeViewState();
}

class _CreateBoxTypeViewState extends State<CreateBoxTypeView> {
  final BoxController _boxController = BoxController();
  late _TypeOption _selected;
  late AppLocalizations _l10n;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.draft.type == BoxType.vocabulary
        ? _TypeOption.vocabulary
        : _TypeOption.flashcard;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  /// When pressing the 'Next'-button, following branches exist:
  /// 1. Import a box or
  /// 2. Create a new box (regardless of selected type).
  Future<void> _onNext() async {
    if (_selected == _TypeOption.import) {
      await _onImportPressed();
      return;
    }

    widget.draft.type = _selected == _TypeOption.vocabulary
        ? BoxType.vocabulary
        : BoxType.flashcard;
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => CreateBoxDetailView(draft: widget.draft),
      ),
    );
  }

  /// Handle box import action.
  Future<void> _onImportPressed() async {
    if (_isImporting) return;
    setState(() {
      _isImporting = true;
    });

    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: _l10n.settingsImportBox,
        type: FileType.custom,
        allowedExtensions: ['vocab'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;

      if (path == null) return;

      final VocabularyBox importedBox =
          await ImportController.importBoxFromFile(path);

      if (!mounted) return;

      final key = await _boxController.addBox(importedBox);

      if (!mounted) return;

      await showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(_l10n.settingsImportSuccess),
          content: Text(_l10n.settingsImportSuccessMessage(importedBox.name)),
          actions: [
            CupertinoDialogAction(
              child: Text(_l10n.commonOk),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop((box: importedBox, key: key));
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_l10n.createBoxNavTitle),
        padding: const EdgeInsetsDirectional.only(start: 0.0),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.createBoxTypeTitle,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                _l10n.createBoxTypeSubtitle,
                style: TextStyle(
                  fontSize: 14.0,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey,
                    context,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              SelectableOptionCard(
                icon: CupertinoIcons.globe,
                iconBackgroundColor: Color(BoxColor.purple.argb),
                title: BoxType.vocabulary.title(_l10n),
                subtitle: BoxType.vocabulary.subtitle(_l10n),
                selected: _selected == _TypeOption.vocabulary,
                selectedColor: Color(BoxColor.purple.argb),
                onTap: () => setState(() => _selected = _TypeOption.vocabulary),
              ),
              const SizedBox(height: 12.0),
              SelectableOptionCard(
                icon: CupertinoIcons.folder,
                iconBackgroundColor: Color(BoxColor.orange.argb),
                title: BoxType.flashcard.title(_l10n),
                subtitle: BoxType.flashcard.subtitle(_l10n),
                selected: _selected == _TypeOption.flashcard,
                selectedColor: Color(BoxColor.orange.argb),
                onTap: () => setState(() => _selected = _TypeOption.flashcard),
              ),
              const SizedBox(height: 12.0),
              SelectableOptionCard(
                icon: CupertinoIcons.arrow_down_to_line,
                iconBackgroundColor: Color(BoxColor.teal.argb),
                title: _l10n.settingsImportBox,
                subtitle: _l10n.createBoxTypeImportSubtitle,
                selected: _selected == _TypeOption.import,
                selectedColor: Color(BoxColor.teal.argb),
                onTap: () => setState(() => _selected = _TypeOption.import),
              ),
              const Spacer(),
              PrimaryActionButton(
                label: _l10n.commonNext,
                isLoading: _isImporting,
                onPressed: _onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
