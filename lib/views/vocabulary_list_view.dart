import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/views/edit_vocabulary_view.dart';
import '../controllers/box_controller.dart';
import '../models/vocabulary.dart';
import '../models/vocabulary_box.dart';
import '../theme/app_page_route.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/text_link_button.dart';

class VocabularyListView extends StatefulWidget {
  final ValueListenable<List<MapEntry<String, VocabularyBox>>> boxListenable;
  final bool multipleBoxes;

  const VocabularyListView({
    super.key,
    required this.boxListenable,
    required this.multipleBoxes,
  });

  @override
  State<VocabularyListView> createState() => _VocabularyListViewState();
}

/// Helper class to combine box key, box and vocabulary for easier list rendering
class _BoxVocabulary {
  final String boxKey;
  final VocabularyBox box;
  final Vocabulary vocabulary;

  _BoxVocabulary(this.boxKey, this.box, this.vocabulary);
}

class _VocabularyListViewState extends State<VocabularyListView> {
  final BoxController _controller = BoxController();
  late AppLocalizations _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  /// Opens the EditVocabularyView for adding a new vocabulary to the specified box.
  /// Option only available when not in multipleBoxes mode.
  ///  - [boxKey] The key of the box to which the new vocabulary will be added.
  ///  - [box] The box to which the new vocabulary will be added.
  void _navigateToVocabularyEdit(String boxKey, VocabularyBox box) {
    Navigator.push(
      context,
      AppPageRoute(
        builder: (_) => EditVocabularyView(boxKey: boxKey, box: box),
      ),
    );
  }

  /// Opens the EditVocabularyView for editing an existing vocabulary.
  ///  - [boxKey] The key of the box containing the vocabulary to edit.
  ///  - [box] The box containing the vocabulary to edit.
  void _navigateToEdit(
    String boxKey,
    VocabularyBox box,
    Vocabulary vocabulary,
  ) {
    Navigator.push(
      context,
      AppPageRoute(
        builder: (_) => EditVocabularyView(
          boxKey: boxKey,
          box: box,
          vocabulary: vocabulary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ValueListenableBuilder(
      valueListenable: widget.boxListenable,
      builder: (context, entries, _) {
        final firstEntry = entries.isEmpty ? null : entries.first;

        final items = entries.expand((entry) {
          final boxKey = entry.key;
          final box = entry.value;
          return box.vocabularies.map((v) => _BoxVocabulary(boxKey, box, v));
        }).toList();

        return AppScaffold(
          backLabel: widget.multipleBoxes ? null : firstEntry?.value.name,
          actions: widget.multipleBoxes || firstEntry == null
              ? []
              : [
                  TextLinkButton(
                    label: _l10n.editVocabNew,
                    onPressed: () => _navigateToVocabularyEdit(
                      firstEntry.key,
                      firstEntry.value,
                    ),
                  ),
                ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.vocabListTitle,
                style: AppTypography.headlineSerif.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              if (items.isEmpty)
                Text(
                  _l10n.vocabListEmpty,
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
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _VocabularyRow(
                          vocabulary: item.vocabulary,
                          box: item.box,
                          boxKey: item.boxKey,
                          showBoxName: widget.multipleBoxes,
                          deleteLabel: _l10n.boxDetailDelete,
                          onTap: () => _navigateToEdit(
                            item.boxKey,
                            item.box,
                            item.vocabulary,
                          ),
                          onDismissed: () =>
                              _controller.removeVocabularyFromBox(
                                item.boxKey,
                                item.vocabulary.id,
                              ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _VocabularyRow extends StatelessWidget {
  final Vocabulary vocabulary;
  final VocabularyBox box;
  final String boxKey;
  final bool showBoxName;
  final String deleteLabel;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _VocabularyRow({
    required this.vocabulary,
    required this.box,
    required this.boxKey,
    required this.showBoxName,
    required this.deleteLabel,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      type: MaterialType.transparency,
      child: Dismissible(
        key: Key('${vocabulary.id}_$boxKey'),
        direction: DismissDirection.endToStart,
        background: Container(
          color: colors.danger,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Text(
            deleteLabel,
            style: AppTypography.bodySans.copyWith(
              color: colors.background,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onDismissed: (_) => onDismissed(),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.background,
              border: Border(
                bottom: BorderSide(
                  color: colors.borderSubtle,
                  width: AppSpacing.hairline,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.rowVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vocabulary.word,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySans.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapSmall),
                Text(
                  vocabulary.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionSans.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                if (showBoxName) ...[
                  const SizedBox(height: AppSpacing.gapSmall),
                  Text(
                    box.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.captionSans.copyWith(
                      color: colors.textLabel,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
