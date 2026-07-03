import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/controllers/import_controller.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';

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
  late AppLocalizations _l10n;
  bool _cardAnimations = true;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  /// Initialize settings to set UI to correct state.
  Future<void> _initSettings() async {
    setState(() {
      _cardAnimations = _controller.getCardAnimations();
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
    if (_importing) return;
    setState(() {
      _importing = true;
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

      _boxController.addBox(importedBox);

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
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
    } finally {
      setState(() {
        _importing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_l10n.settingsTitle),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _l10n.settingsCardAnimations,
                    style: const TextStyle(fontSize: 16),
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
              onPressed: _importing ? null : _onImportPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.arrow_down_to_line),
                  const SizedBox(width: 8),
                  Text(_l10n.settingsImportBox),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
