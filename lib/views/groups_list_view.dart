import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/services/usage_service.dart';
import 'package:vocabulaire/views/box_list_view.dart';
import 'package:vocabulaire/views/subscription_view.dart';
import 'package:vocabulaire/views/widgets/app_dialog.dart';
import 'package:vocabulaire/views/widgets/group_tile.dart';

import '../controllers/box_controller.dart';
import '../controllers/group_controller.dart';
import '../models/vocabulary_box.dart';
import '../models/vocabulary_group.dart';
import '../theme/app_page_route.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'create_group_flow.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/text_link_button.dart';

enum _LockedGroupAction { upgrade, download }

class GroupsListView extends StatefulWidget {
  const GroupsListView({super.key});

  @override
  State<GroupsListView> createState() => _GroupsListViewState();
}

class _GroupsListViewState extends State<GroupsListView> {
  final GroupController _groupController = GroupController();
  final BoxController _boxController = BoxController();
  late final ValueNotifier<List<MapEntry<String, VocabularyGroup>>>
  _groupsNotifier;
  late final ValueNotifier<List<MapEntry<String, VocabularyBox>>>
  _boxesNotifier;
  late AppLocalizations _l10n;

  @override
  void initState() {
    super.initState();
    _groupsNotifier = _groupController.listenableForAll();
    _boxesNotifier = _boxController.listenableForAll();
  }

  @override
  void dispose() {
    _groupsNotifier.dispose();
    _boxesNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  void _openBoxList(String groupId, VocabularyGroup group) {
    Navigator.of(context).push(
      AppPageRoute(
        builder: (context) => BoxListView(group: group, groupId: groupId),
      ),
    );
  }

  Future<void> _openGroup(String groupId, VocabularyGroup group) async {
    final isPremium = UsageService.instance.listenable.value.isPremium;
    if (_groupController.isLocal(groupId) || isPremium) {
      _openBoxList(groupId, group);
      return;
    }

    _LockedGroupAction? action;
    await showAppDialog(
      context: context,
      title: _l10n.lockedGroupTitle,
      message: _l10n.lockedGroupMessage,
      actions: [
        AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
        AppDialogAction(
          label: _l10n.lockedGroupDownload,
          destructive: true,
          onPressed: () => action = _LockedGroupAction.download,
        ),
        AppDialogAction(
          label: _l10n.lockedGroupUpgrade,
          isDefaultAction: true,
          onPressed: () => action = _LockedGroupAction.upgrade,
        ),
      ],
    );
    if (!mounted) return;

    switch (action) {
      case _LockedGroupAction.upgrade:
        Navigator.of(
          context,
        ).push(AppPageRoute(builder: (_) => const SubscriptionView()));
      case _LockedGroupAction.download:
        await _confirmAndDownloadGroup(groupId);
      case null:
        break;
    }
  }

  Future<void> _confirmAndDownloadGroup(String groupId) async {
    bool confirmed = false;
    await showAppDialog(
      context: context,
      title: _l10n.lockedGroupDownloadConfirmTitle,
      message: _l10n.lockedGroupDownloadConfirmMessage,
      actions: [
        AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
        AppDialogAction(
          label: _l10n.lockedGroupDownload,
          destructive: true,
          onPressed: () => confirmed = true,
        ),
      ],
    );
    if (!confirmed || !mounted) return;

    try {
      await _groupController.moveGroupOffline(groupId);
    } catch (_) {
      if (mounted) {
        await context.showAppError(
          AppException(AppError.moveGroupOfflineFailed),
        );
      }
      return;
    }
    if (!mounted) return;

    final group = _groupController.getGroup(groupId);
    if (group == null) return;
    _openBoxList(groupId, group);
  }

  Future<void> _createGroup() async {
    final group = await Navigator.of(context, rootNavigator: true)
        .push<VocabularyGroup>(
          AppPageRoute(builder: (context) => const CreateGroupFlow()),
        );
    if (group == null || !mounted) return;
    Navigator.of(context).push(
      AppPageRoute(
        builder: (context) => BoxListView(group: group, groupId: group.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppScaffold(
      bottomGap: false,
      actions: [TextLinkButton(label: _l10n.addGroup, onPressed: _createGroup)],
      body: ValueListenableBuilder(
        valueListenable: _groupsNotifier,
        builder: (context, groupEntries, _) {
          return ValueListenableBuilder(
            valueListenable: _boxesNotifier,
            builder: (context, boxEntries, _) {
              final boxCounts = <String, int>{};
              for (final entry in boxEntries) {
                boxCounts[entry.value.groupId] =
                    (boxCounts[entry.value.groupId] ?? 0) + 1;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.tabGroups,
                    style: AppTypography.headlineSerif.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  if (groupEntries.isEmpty)
                    Text(
                      _l10n.groupsEmpty,
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
                        child: ListView.builder(
                          itemCount: groupEntries.length,
                          itemBuilder: (context, index) {
                            final entry = groupEntries[index];
                            return GroupTile(
                              key: ValueKey(entry.key),
                              group: entry.value,
                              boxCount: boxCounts[entry.key] ?? 0,
                              onTap: () =>
                                  _openGroup(entry.key, entry.value),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
