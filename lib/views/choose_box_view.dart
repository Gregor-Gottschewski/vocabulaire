import 'package:flutter/material.dart';
import 'package:vocabulaire/models/vocabulary.dart';
import 'package:vocabulaire/views/widgets/app_scaffold.dart';
import 'package:vocabulaire/views/widgets/box_tile.dart';

import '../controllers/box_controller.dart';
import '../controllers/group_controller.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import '../models/vocabulary_box.dart';
import '../models/vocabulary_group.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';

class ChooseBoxView extends StatefulWidget {
  final VocabularyGroup group;
  final Vocabulary vocabulary;
  final List<VocabularyBox> excluded;

  const ChooseBoxView({
    super.key,
    required this.group,
    required this.vocabulary,
    this.excluded = const <VocabularyBox>[],
  });

  @override
  State<StatefulWidget> createState() => _ChooseBoxView();
}

class _ChooseBoxView extends State<ChooseBoxView> {
  final BoxController _boxController = BoxController();
  final GroupController _groupController = GroupController();
  late final ValueNotifier<List<MapEntry<String, VocabularyGroup>>>
  _groupsNotifier;
  late ValueNotifier<List<MapEntry<String, VocabularyBox>>> _boxesNotifier;
  late AppLocalizations _l10n;

  @override
  void initState() {
    super.initState();
    _boxesNotifier = _boxController.listenableForGroup(widget.group.id);
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ValueListenableBuilder(
      valueListenable: _groupsNotifier,
      builder: (context, _, _) {
        return AppScaffold(
          bottomGap: false,
          backLabel: _l10n.back,
          body: ValueListenableBuilder(
            valueListenable: _boxesNotifier,
            builder: (context, allEntries, _) {
              final excludedIds = widget.excluded.map((b) => b.id).toSet();
              final entries = allEntries
                  .where((e) => !excludedIds.contains(e.value.id))
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.chooseBoxMoveTitle(widget.vocabulary.word),
                    style: AppTypography.headlineSerif.copyWith(
                      color: colors.textPrimary,
                    ),
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                              onTap: () => Navigator.pop(context, entry.value),
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
