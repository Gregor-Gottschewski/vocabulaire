import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/controllers/export_controller.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/services/box_sync_service.dart';
import '../models/vocabulary_box.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'box_detail_view.dart';
import 'widgets/app_dialog.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/text_link_button.dart';

class BoxDetailPage extends StatefulWidget {
  final VocabularyBox box;
  final String boxKey;

  const BoxDetailPage({super.key, required this.box, required this.boxKey});

  @override
  State<BoxDetailPage> createState() => _BoxDetailPageState();
}

class _BoxDetailPageState extends State<BoxDetailPage> {
  final BoxController _boxController = BoxController();
  late String _boxKey;
  late final ValueNotifier<List<MapEntry<String, VocabularyBox>>>
  _boxNotifier;
  late AppLocalizations _l10n;
  bool _isPopping = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  VocabularyBox? get _box {
    final fromController = _boxController.getBox(_boxKey);
    if (fromController != null) return fromController;
    if (!BoxSyncService.instance.hasLoadedOnce) return widget.box;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _boxKey = widget.boxKey;
    _boxNotifier = _boxController.listenableForKeys([_boxKey]);
  }

  @override
  void dispose() {
    _boxNotifier.dispose();
    super.dispose();
  }

  Future<void> _exportBox() async {
    final box = _box;
    if (box == null) return;

    final exportDir = AppPaths.applicationExportBaseDirectory;

    try {
      if (exportDir.existsSync()) await exportDir.delete(recursive: true);
      final zipFile = await ExportController.exportBox(box);

      await SharePlus.instance.share(
        ShareParams(
          title: 'Export ${box.nameSanitized()}',
          files: [XFile(zipFile.path)],
          fileNameOverrides: ['${box.nameSanitized()}.vocab'],
        ),
      );
    } on FileSystemException catch (e) {
      if (!mounted) return;
      await context.showAppError(
        AppException(AppError.exportCacheFailed, details: e),
      );
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
    }
  }

  /// Deletes the current box.
  /// If the box contains vocabularies, a confirmation dialog is shown before deletion.
  void _deleteBox() {
    final box = _box;
    if (box == null) return;

    if (box.vocabularies.isEmpty) {
      _boxController.deleteBox(widget.boxKey);
      Navigator.of(context).pop();
      return;
    }

    final pageContext = context;
    showAppDialog(
      context: pageContext,
      title: _l10n.boxDetailDeleteTitle,
      message: _l10n.boxDetailDeleteMessage,
      actions: [
        AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
        AppDialogAction(
          label: _l10n.boxDetailDelete,
          destructive: true,
          onPressed: () {
            Navigator.of(pageContext).pop();
            _boxController.deleteBox(widget.boxKey);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _boxNotifier,
      builder: (context, _, _) {
        final box = _box;
        if (box == null) {
          if (!_isPopping) {
            _isPopping = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).maybePop();
            });
          }

          return AppScaffold(
            backLabel: _l10n.tabBoxen,
            body: Text(
              _l10n.boxDetailNotFound,
              style: AppTypography.bodySans.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          );
        }
        return AppScaffold(
          backLabel: _l10n.tabBoxen,
          actions: [
            TextLinkButton(
              label: _l10n.boxDetailShareAction,
              onPressed: _exportBox,
            ),
            TextLinkButton(label: _l10n.boxDetailDelete, onPressed: _deleteBox),
          ],
          body: BoxDetailView(box: box, boxKey: widget.boxKey),
        );
      },
    );
  }
}
