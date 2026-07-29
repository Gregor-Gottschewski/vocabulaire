import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import '../controllers/settings_controller.dart';
import '../services/box_sync_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/key_value_row.dart';
import 'widgets/text_link_button.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsController _controller = SettingsController();
  final BoxSyncService _boxSync = BoxSyncService.instance;
  late AppLocalizations _l10n;
  bool _cardAnimations = true;

  @override
  void initState() {
    super.initState();
    _initSettings();
    _boxSync.listenable.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    _boxSync.listenable.removeListener(_onSyncChanged);
    super.dispose();
  }

  void _onSyncChanged() {
    if (mounted) setState(() {});
  }

  String get _syncStatusLabel {
    if (_boxSync.isFromCache) return _l10n.settingsSyncStatusOffline;
    if (_boxSync.hasPendingWrites) return _l10n.settingsSyncStatusSyncing;
    return _l10n.settingsSyncStatusSynced;
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
    final colors = context.colors;
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.settingsTitle,
            style: AppTypography.headlineSerif.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          KeyValueRowGroup(
            children: [
              KeyValueRow.toggle(
                label: _l10n.settingsCardAnimations,
                value: _cardAnimations,
                onChanged: _setCardAnimations,
              ),
              KeyValueRow.value(
                label: _l10n.settingsSyncStatus,
                value: _syncStatusLabel,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          TextLinkButton(
            label: _l10n.settingsLicenses,
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'Vocabulaire',
            ),
          ),
        ],
      ),
    );
  }
}
