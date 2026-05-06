import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/controllers/import_controller.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';

import '../controllers/box_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsController _controller = SettingsController();
  final BoxController _boxController = BoxController();

  bool _cardAnimations = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  /// Initialize settings to set UI to correct state.
  Future<void> _initSettings() async {
    setState(() {
      _cardAnimations = _controller.getCardAnimations();
      _loading = false;
    });
  }

  /// Update card animation setting.
  Future<void> _setCardAnimations(bool value) async {
    setState(() => _cardAnimations = value);
    await _controller.setCardAnimations(value);
  }

  /// Handle box import action.
  /// Opens a file picker, imports the selected box, and adds it to the app.
  void _onImportPressed() async {
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: "Box Importieren",
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.single.path;

      if (path == null) return;

      final VocabularyBox importedBox =
          await ImportController.importBoxFromFile(path);

      if (!mounted) return;

      _boxController.addBox(importedBox);

      await showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Import erfolgreich'),
          content: Text('Box "${importedBox.name}" wurde importiert.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Fehler'),
          content: Text('Import fehlgeschlagen: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Einstellungen'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Kartenanimationen',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                CupertinoSwitch(
                  value: _cardAnimations,
                  onChanged: (v) => _setCardAnimations(v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CupertinoButton.tinted(
              onPressed: _onImportPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(CupertinoIcons.arrow_down_to_line),
                  SizedBox(width: 8),
                  Text('Box importieren'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
