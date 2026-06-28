import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/controllers/export_controller.dart';
import 'package:vocabulaire/services/app_paths.dart';
import '../models/vocabulary_box.dart';
import 'box_detail_view.dart';

class BoxDetailPage extends StatefulWidget {
  final VocabularyBox box;
  final dynamic boxKey;

  const BoxDetailPage({super.key, required this.box, required this.boxKey});

  @override
  State<BoxDetailPage> createState() => _BoxDetailPageState();
}

class _BoxDetailPageState extends State<BoxDetailPage> {
  final BoxController _boxController = BoxController();
  late dynamic _boxKey;
  late TextEditingController _controller;
  late AppLocalizations _l10n;
  bool _isEditingTitle = false;
  bool _isPopping = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  VocabularyBox? get _box => _boxController.getBox(_boxKey);

  @override
  void initState() {
    super.initState();
    _boxKey = widget.boxKey;
    final box = _boxController.getBox(_boxKey);
    if (box == null) {
      throw Exception('Box with key $_boxKey not found');
    }
    _controller = TextEditingController(text: box.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveTitle() async {
    final box = _box;
    final newName = _controller.text.trim();
    if (newName.isEmpty || box == null) return;

    final updated = VocabularyBox(
      name: newName,
      description: box.description,
      vocabularies: box.vocabularies,
    );

    _boxController.updateBox(widget.boxKey, updated);

    setState(() {
      _isEditingTitle = false;
    });
  }

  Future<void> _exportBox() async {
    final box = _box;
    if (box == null) return;

    try {
      final exportDir = AppPaths.applicationExportBaseDirectory;
      if (exportDir.existsSync()) exportDir.delete(recursive: true);
    } on FileSystemException catch (e) {
      debugPrint(e.message);
      throw Exception("Cannot empty export cache");
    }

    try {
      final zipFile = await ExportController.exportBox(box);

      await SharePlus.instance.share(
        ShareParams(
          title: 'Export ${box.nameSanitized()}',
          files: [XFile(zipFile.path)],
          fileNameOverrides: ['${box.nameSanitized()}.vocab'],
        ),
      );
    } catch (e) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(_l10n.commonError),
          content: Text(_l10n.boxDetailExportError(e.toString())),
          actions: [
            CupertinoDialogAction(
              child: Text(_l10n.commonOk),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
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
    showCupertinoDialog(
      context: pageContext,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(_l10n.boxDetailDeleteTitle),
        content: Text(_l10n.boxDetailDeleteMessage),
        actions: [
          CupertinoDialogAction(
            child: Text(_l10n.commonCancel),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(_l10n.boxDetailDelete),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(pageContext).pop();
              _boxController.deleteBox(widget.boxKey);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<VocabularyBox>>(
      valueListenable: _boxController.listenable,
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

          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text(_l10n.boxDetailNotFound),
            ),
            child: const SizedBox.shrink(),
          );
        }
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: _isEditingTitle
                ? SizedBox(
                    height: 36,
                    child: CupertinoTextField(
                      controller: _controller,
                      autofocus: true,
                      onSubmitted: (_) => _saveTitle(),
                    ),
                  )
                : Text(
                    box.name,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    _isEditingTitle
                        ? CupertinoIcons.check_mark
                        : CupertinoIcons.pencil,
                  ),
                  onPressed: () {
                    if (_isEditingTitle) {
                      _saveTitle();
                    } else {
                      setState(() => _isEditingTitle = true);
                    }
                  },
                ),
                const SizedBox(width: 5),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _exportBox,
                  child: Icon(CupertinoIcons.share),
                ),
                const SizedBox(width: 5),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _deleteBox,
                  child: const Icon(CupertinoIcons.trash),
                ),
              ],
            ),
          ),
          child: BoxDetailView(box: box, boxKey: widget.boxKey),
        );
      },
    );
  }
}
