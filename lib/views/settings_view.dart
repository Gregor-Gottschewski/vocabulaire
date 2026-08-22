import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import '../controllers/box_controller.dart';
import '../controllers/export_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/app_exception.dart';
import '../services/app_exception_ui.dart';
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
  final BoxController _boxController = BoxController();
  final BoxSyncService _boxSync = BoxSyncService.instance;
  final UsageService _usage = UsageService.instance;
  late AppLocalizations _l10n;
  bool _cardAnimations = true;
  bool _hasConnectivity = true;
  bool _isExportingAll = false;
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

  /// Exports all boxes as `.vocab` files grouped into a single ZIP archive
  Future<void> _exportAllBoxes() async {
    final boxes = _boxController.boxes;
    if (boxes.isEmpty) return;

    setState(() => _isExportingAll = true);

    try {
      final zipFile = await ExportController.exportAllBoxes(boxes);

      await SharePlus.instance.share(
        ShareParams(
          title: _l10n.settingsExportAll,
          files: [XFile(zipFile.path)],
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
    } finally {
      if (mounted) setState(() => _isExportingAll = false);
    }
  }

  Future<void> _openGithub() async {
    final uri = Uri.parse(
      'https://github.com/Gregor-Gottschewski/vocabulaire/',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          KeyValueRow.submenu(
            context,
            label: _l10n.settingsExportAll,
            onTap: (_isExportingAll || _boxController.boxes.isEmpty)
                ? null
                : _exportAllBoxes,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          TextLinkButton(
            label: _l10n.settingsLicenses,
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'Vocabulaire',
            ),
          ),
          TextLinkButton(label: _l10n.settingsGithub, onPressed: _openGithub),
        ],
      ),
    );
  }
}
