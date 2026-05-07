import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
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
  bool _isEditing = false;
  late TextEditingController _controller;

  VocabularyBox get _box => _boxController.getBox(_boxKey)!;

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
    final newName = _controller.text.trim();
    if (newName.isEmpty) return;

    final updated = VocabularyBox(
      name: newName,
      description: _box.description,
      vocabularies: _box.vocabularies,
    );

    _boxController.updateBox(widget.boxKey, updated);

    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _exportBoxAsJson() async {
    try {
      final jsonString = JsonEncoder().convert(_box.toMap());

      final tempDir = Platform.isMacOS
          ? await getApplicationSupportDirectory()
          : await getTemporaryDirectory();

      final file = File(
        '${tempDir.path}/export-${DateTime.now().millisecondsSinceEpoch}.json',
      );

      await file.writeAsString(jsonString, encoding: utf8);

      await SharePlus.instance.share(
        ShareParams(
          title: 'Export ${_box.name}',
          files: [XFile(file.path)],
          fileNameOverrides: ['${_box.name}.json'],
        ),
      );

      //await file.delete();
    } catch (e) {
      await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Fehler'),
          content: Text('Export fehlgeschlagen: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: _isEditing
            ? SizedBox(
                height: 36,
                child: CupertinoTextField(
                  controller: _controller,
                  autofocus: true,
                  onSubmitted: (_) => _saveTitle(),
                ),
              )
            : Text(_box.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                _isEditing ? CupertinoIcons.check_mark : CupertinoIcons.pencil,
              ),
              onPressed: () {
                if (_isEditing) {
                  _saveTitle();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
            const SizedBox(width: 5),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.share),
              onPressed: () {
                _exportBoxAsJson();
              },
            ),
          ],
        ),
      ),
      child: BoxDetailView(box: _box, boxKey: widget.boxKey),
    );
  }
}
