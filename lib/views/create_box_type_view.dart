import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/controllers/box_draft.dart';
import 'package:vocabulaire/controllers/import_controller.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/theme/app_page_route.dart';
import 'package:vocabulaire/theme/app_spacing.dart';
import 'package:vocabulaire/theme/app_typography.dart';
import 'package:vocabulaire/theme/theme_context_ext.dart';
import 'package:vocabulaire/views/create_box_detail_view.dart';
import 'package:vocabulaire/views/widgets/app_scaffold.dart';
import 'package:vocabulaire/views/widgets/key_value_row.dart';
import 'package:vocabulaire/views/widgets/primary_action_button.dart';
import 'package:vocabulaire/views/widgets/selectable_option_card.dart';

enum _TypeOption { vocabulary, flashcard, import }

/// Choose between a vocabulary box, a flashcard box, or importing a box.
class CreateBoxTypeView extends StatefulWidget {
  final BoxDraft draft;

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
      AppPageRoute(builder: (_) => CreateBoxDetailView(draft: widget.draft)),
    );
  }

  /// Handle box import action.
  Future<void> _onImportPressed() async {
    if (_isImporting) return;
    setState(() {
      _isImporting = true;
    });

    try {
      final FilePickerResult? results = await FilePicker.pickFiles(
        dialogTitle: _l10n.settingsImportBox,
        type: FileType.custom,
        allowedExtensions: ['vocab'],
        allowMultiple: true,
        withData: false,
      );

      if (results == null || results.files.isEmpty) return;

      final importedBoxes = <VocabularyBox>[];
      for (final result in results.files) {
        final path = result.path;
        if (path == null) return;
        importedBoxes.add(await ImportController.importBoxFromFile(path));
      }

      if (!mounted) return;
      await _boxController.addBoxes(importedBoxes);

      // await showAppDialog(
      //   context: context,
      //   title: _l10n.settingsImportSuccess,
      //   message: _l10n.settingsImportSuccessMessage(importedBox.name),
      //   actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      // );

      if (!mounted) return;
      if (results.files.length == 1) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop((box: importedBoxes.first, key: importedBoxes.first.id));
      } else {
        Navigator.of(context, rootNavigator: true).pop();
      }
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
    final colors = context.colors;

    return AppScaffold(
      backLabel: _l10n.commonCancel,
      onBack: () => Navigator.of(context, rootNavigator: true).pop(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.createBoxTypeTitle,
            style: AppTypography.headlineSerif.copyWith(
              fontSize: 24,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.gapSmall),
          Text(
            _l10n.createBoxTypeSubtitle,
            style: AppTypography.bodySans.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          KeyValueRowGroup(
            children: [
              SelectableOptionCard(
                title: BoxType.vocabulary.title(_l10n),
                subtitle: BoxType.vocabulary.subtitle(_l10n),
                selected: _selected == _TypeOption.vocabulary,
                onTap: () => setState(() => _selected = _TypeOption.vocabulary),
              ),
              SelectableOptionCard(
                title: BoxType.flashcard.title(_l10n),
                subtitle: BoxType.flashcard.subtitle(_l10n),
                selected: _selected == _TypeOption.flashcard,
                onTap: () => setState(() => _selected = _TypeOption.flashcard),
              ),
              SelectableOptionCard(
                title: _l10n.settingsImportBox,
                subtitle: _l10n.createBoxTypeImportSubtitle,
                selected: _selected == _TypeOption.import,
                onTap: () => setState(() => _selected = _TypeOption.import),
              ),
            ],
          ),
          const Spacer(),
          PrimaryActionButton(
            label: _l10n.commonNext,
            isLoading: _isImporting,
            onPressed: _onNext,
          ),
        ],
      ),
    );
  }
}
