import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import '../controllers/box_controller.dart';
import '../models/vocabulary_box.dart';
import '../services/app_exception.dart';
import '../services/app_exception_ui.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'widgets/app_dialog.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/key_value_row.dart';
import 'widgets/text_link_button.dart';

/// Lists all boxes, local and online, allowing the user to move a box in
/// either direction between local-only storage and online synchronization.
class BoxSyncView extends StatefulWidget {
  const BoxSyncView({super.key});

  @override
  State<BoxSyncView> createState() => _BoxSyncViewState();
}

class _BoxSyncViewState extends State<BoxSyncView> {
  final BoxController _boxController = BoxController();
  late final ValueNotifier<List<MapEntry<String, VocabularyBox>>>
  _boxesNotifier;
  late AppLocalizations _l10n;
  final Set<String> _movingIds = {};

  @override
  void initState() {
    super.initState();
    _boxesNotifier = _boxController.listenableForAll();
  }

  @override
  void dispose() {
    _boxesNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  void _moveOffline(String boxId) {
    final pageContext = context;
    showAppDialog(
      context: pageContext,
      title: _l10n.boxDetailMoveOfflineTitle,
      message: _l10n.boxDetailMoveOfflineMessage,
      actions: [
        AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
        AppDialogAction(
          label: _l10n.boxDetailMoveOfflineAction,
          onPressed: () async {
            setState(() => _movingIds.add(boxId));
            try {
              await _boxController.moveBoxOffline(boxId);
            } catch (e) {
              if (!pageContext.mounted) return;
              await pageContext.showAppError(
                AppException(AppError.moveBoxOfflineFailed, details: e),
              );
            } finally {
              if (pageContext.mounted) {
                setState(() => _movingIds.remove(boxId));
              }
            }
          },
        ),
      ],
    );
  }

  void _moveOnline(String boxId) {
    final pageContext = context;
    showAppDialog(
      context: pageContext,
      title: _l10n.boxDetailMoveOnlineTitle,
      message: _l10n.boxDetailMoveOnlineMessage,
      actions: [
        AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
        AppDialogAction(
          label: _l10n.boxDetailMoveOnlineAction,
          onPressed: () async {
            setState(() => _movingIds.add(boxId));
            try {
              await _boxController.moveBoxOnline(boxId);
            } catch (e) {
              if (!pageContext.mounted) return;
              await pageContext.showAppError(
                AppException(AppError.moveBoxOnlineFailed, details: e),
              );
            } finally {
              if (pageContext.mounted) {
                setState(() => _movingIds.remove(boxId));
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppScaffold(
      backLabel: _l10n.settingsTitle,
      body: ValueListenableBuilder(
        valueListenable: _boxesNotifier,
        builder: (context, entries, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.boxSyncTitle,
                style: AppTypography.headlineSerif.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.gapSmall),
              Text(
                _l10n.boxSyncDescription,
                style: AppTypography.bodySans.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              if (entries.isEmpty)
                Text(
                  _l10n.boxSyncEmpty,
                  style: AppTypography.bodySans.copyWith(
                    color: colors.textSecondary,
                  ),
                )
              else
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colors.borderStrong,
                          width: AppSpacing.hairline,
                        ),
                      ),
                    ),
                    child: ListView.separated(
                      itemCount: entries.length,
                      separatorBuilder: (context, index) => Container(
                        height: AppSpacing.hairline,
                        color: colors.borderSubtle,
                      ),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final isLocal = _boxController.isLocal(entry.key);
                        return KeyValueRow(
                          label: entry.value.name,
                          trailing: TextLinkButton(
                            label: isLocal
                                ? _l10n.boxDetailMoveOnlineAction
                                : _l10n.boxDetailMoveOfflineAction,
                            onPressed: _movingIds.contains(entry.key)
                                ? null
                                : () => isLocal
                                      ? _moveOnline(entry.key)
                                      : _moveOffline(entry.key),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
