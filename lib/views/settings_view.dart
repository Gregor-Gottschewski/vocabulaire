import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import '../controllers/settings_controller.dart';
import '../services/box_sync_service.dart';
import '../services/usage_service.dart';
import '../theme/app_page_route.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'box_sync_view.dart';
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
  final UsageService _usage = UsageService.instance;
  late AppLocalizations _l10n;
  bool _cardAnimations = true;
  bool _hasConnectivity = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initSettings();
    _initConnectivity();
    _boxSync.listenable.addListener(_onSyncChanged);
    _usage.listenable.addListener(_onSyncChanged);
  }

  @override
  void dispose() {
    _boxSync.listenable.removeListener(_onSyncChanged);
    _usage.listenable.removeListener(_onSyncChanged);
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _onSyncChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _onConnectivityChanged(result);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnectivity = results.any(
      (result) => result != ConnectivityResult.none,
    );
    if (mounted) setState(() => _hasConnectivity = hasConnectivity);
  }

  String get _syncStatusLabel {
    if (!_hasConnectivity || _boxSync.isFromCache) {
      return _l10n.settingsSyncStatusOffline;
    }
    if (_boxSync.hasPendingWrites) return _l10n.settingsSyncStatusSyncing;
    return _l10n.settingsSyncStatusSynced;
  }

  String get _vocabularyUsageLabel {
    final usage = _usage.listenable.value;
    return _l10n.settingsVocabularyUsageValue(
      usage.vocabularyCountOnline,
      usage.vocabularyLimit,
    );
  }

  String get _audioUsageLabel {
    final usedMb = _usage.listenable.value.audioBytesUsed / (1024 * 1024);
    const limitMb = UsageService.audioStorageLimitBytes / (1024 * 1024);
    return _l10n.settingsAudioUsageValue(
      usedMb.toStringAsFixed(1),
      limitMb.round(),
    );
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
              if (_usage.listenable.value.isPremium) ...[
                KeyValueRow.value(
                  label: _l10n.settingsSyncStatus,
                  value: _syncStatusLabel,
                ),
                KeyValueRow.value(
                  label: _l10n.settingsVocabularyUsage,
                  value: _vocabularyUsageLabel,
                ),
                KeyValueRow.value(
                  label: _l10n.settingsAudioUsage,
                  value: _audioUsageLabel,
                ),
                KeyValueRow.submenu(
                  context,
                  label: _l10n.settingsBoxSync,
                  onTap: () => Navigator.of(
                    context,
                  ).push(AppPageRoute(builder: (_) => const BoxSyncView())),
                ),
              ],
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
