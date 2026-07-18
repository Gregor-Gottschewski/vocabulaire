import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsController _controller = SettingsController();
  late AppLocalizations _l10n;
  bool _cardAnimations = true;

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
          ],
        ),
      ),
    );
  }
}
