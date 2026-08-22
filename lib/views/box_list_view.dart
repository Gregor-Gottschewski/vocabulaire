import 'package:flutter/material.dart';
import 'package:vocabulaire/controllers/box_draft.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/views/box_detail_page.dart';
import 'package:vocabulaire/views/create_box_detail_view.dart';
import 'package:vocabulaire/views/create_group_detail_view.dart';
import 'package:vocabulaire/views/widgets/app_bottom_sheet.dart';
import 'package:vocabulaire/views/widgets/app_dialog.dart';
import 'package:vocabulaire/views/widgets/box_tile.dart';

import '../controllers/box_controller.dart';
import '../controllers/group_controller.dart';
import '../controllers/group_draft.dart';
import '../models/vocabulary_box.dart';
import '../models/vocabulary_group.dart';
import '../theme/app_page_route.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/text_link_button.dart';

/// Lists all boxes belonging to [group].
class BoxListView extends StatefulWidget {
  final VocabularyGroup group;
  final String groupId;

  const BoxListView({super.key, required this.group, required this.groupId});

  @override
  State<BoxListView> createState() => _BoxListViewState();
}

class _BoxListViewState extends State<BoxListView> {
  final BoxController _boxController = BoxController();
  final GroupController _groupController = GroupController();
  late String _groupId;
  late final ValueNotifier<List<MapEntry<String, VocabularyBox>>>
  _boxesNotifier;
  late final ValueNotifier<List<MapEntry<String, VocabularyGroup>>>
  _groupsNotifier;
  late AppLocalizations _l10n;
  bool _isPopping = false;
  bool _hasSeenGroup = false;

  /// Resolves the group to show.
  VocabularyGroup? get _group {
    final current = _groupController.getGroup(_groupId);
    if (current != null) {
      _hasSeenGroup = true;
      return current;
    }
    if (!_hasSeenGroup) return widget.group;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _groupId = widget.groupId;
    _boxesNotifier = _boxController.listenableForGroup(_groupId);
    _groupsNotifier = _groupController.listenableForAll();
  }

  @override
  void dispose() {
    _boxesNotifier.dispose();
    _groupsNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<void> _createBox() async {
    final group = _group;
    if (group == null) return;
    final result = await Navigator.of(context, rootNavigator: true)
        .push<({VocabularyBox box, String key})>(
          AppPageRoute(
            builder: (context) =>
                CreateBoxDetailView(draft: BoxDraft.fromGroup(widget.group)),
          ),
        );
    if (result == null || !mounted) return;
    Navigator.of(context).push(
      AppPageRoute(
        builder: (context) =>
            BoxDetailPage(box: result.box, boxKey: result.key),
      ),
    );
  }

  void _editGroup() {
    final group = _group;
    if (group == null) return;
    Navigator.of(context).push(
      AppPageRoute(
        builder: (_) => CreateGroupDetailView(
          draft: GroupDraft.fromGroup(group),
          isEditing: true,
        ),
      ),
    );
  }

  void _showBoxActionsSheet() {
    showAppActionSheet(
      context: context,
      title: _l10n.groupDetailActionsSheetTitle,
      actions: [
        AppActionSheetAction(label: _l10n.editAction, onPressed: _editGroup),
        AppActionSheetAction(
          label: _l10n.boxDetailDelete,
          destructive: true,
          onPressed: _deleteGroup,
        ),
      ],
    );
  }

  void _deleteGroup() {
    final pageContext = context;
    showAppDialog(
      context: pageContext,
      title: _l10n.groupDetailDeleteTitle,
      message: _l10n.groupDetailDeleteMessage,
      actions: [
        AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
        AppDialogAction(
          label: _l10n.boxDetailDelete,
          destructive: true,
          onPressed: () async {
            await _groupController.deleteGroup(widget.groupId);
            if (pageContext.mounted) Navigator.of(pageContext).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ValueListenableBuilder(
      valueListenable: _groupsNotifier,
      builder: (context, _, _) {
        final group = _group;
        if (group == null) {
          if (!_isPopping) {
            _isPopping = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Navigator.of(context).maybePop();
            });
          }
          return AppScaffold(
            backLabel: _l10n.tabGroups,
            body: const SizedBox.shrink(),
          );
        }

        return AppScaffold(
          bottomGap: false,
          backLabel: _l10n.tabGroups,
          actions: [
            TextLinkButton(
              label: _l10n.editAction,
              onPressed: _showBoxActionsSheet,
            ),
            TextLinkButton(label: _l10n.addBox, onPressed: _createBox),
          ],
          body: ValueListenableBuilder(
            valueListenable: _boxesNotifier,
            builder: (context, entries, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: AppTypography.headlineSerif.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  if (entries.isEmpty)
                    Text(
                      _l10n.homeEmpty,
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
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return BoxTile(
                              key: ValueKey(entry.key),
                              box: entry.value,
                              onTap: () {
                                Navigator.of(context).push(
                                  AppPageRoute(
                                    builder: (context) => BoxDetailPage(
                                      box: entry.value,
                                      boxKey: entry.key,
                                    ),
                                  ),
                                );
                              },
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
      },
    );
  }
}
