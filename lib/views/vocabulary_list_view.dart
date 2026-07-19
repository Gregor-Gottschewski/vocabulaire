import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/views/edit_vocabulary_view.dart';
import '../controllers/box_controller.dart';
import '../models/vocabulary.dart';
import '../models/vocabulary_box.dart';

class VocabularyListView extends StatefulWidget {
  final ValueListenable<List<MapEntry<dynamic, VocabularyBox>>> boxListenable;
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
  final dynamic boxKey;
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
  void _navigateToVocabularyEdit(dynamic boxKey, VocabularyBox box) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => EditVocabularyView(boxKey: boxKey, box: box),
      ),
    );
  }

  /// Opens the EditVocabularyView for editing an existing vocabulary.
  ///  - [boxKey] The key of the box containing the vocabulary to edit.
  ///  - [box] The box containing the vocabulary to edit.
  void _navigateToEdit(
    dynamic boxKey,
    VocabularyBox box,
    Vocabulary vocabulary,
  ) {
    Navigator.push(
      context,
      CupertinoPageRoute(
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_l10n.vocabListTitle),
        trailing: !widget.multipleBoxes
            ? ValueListenableBuilder(
                valueListenable: widget.boxListenable,
                builder: (context, entries, _) {
                  final firstEntry = entries.isEmpty ? null : entries.first;
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: firstEntry == null
                        ? null
                        : () => _navigateToVocabularyEdit(
                            firstEntry.key,
                            firstEntry.value,
                          ),
                    child: const Icon(CupertinoIcons.add),
                  );
                },
              )
            : null,
      ),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: widget.boxListenable,
          builder: (context, entries, _) {
            final items = entries.expand((entry) {
              final boxKey = entry.key;
              final box = entry.value;
              return box.vocabularies.map(
                (v) => _BoxVocabulary(boxKey, box, v),
              );
            }).toList();

            if (items.isEmpty) {
              return Center(child: Text(_l10n.vocabListEmpty));
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final v = item.vocabulary;
                final boxKey = item.boxKey;
                final box = item.box;

                return Column(
                  children: [
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                      color: CupertinoColors.separator.resolveFrom(context),
                    ),
                    Dismissible(
                      key: Key('${v.id}_$boxKey'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: CupertinoColors.systemRed.resolveFrom(context),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(
                          CupertinoIcons.trash,
                          color: CupertinoColors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _controller.removeVocabularyFromBox(boxKey, v.id);
                      },
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        onPressed: () => _navigateToEdit(boxKey, box, v),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.word,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoDynamicColor.resolve(
                                        CupertinoColors.label,
                                        context,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    v.meaning,
                                    maxLines: 2,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (widget.multipleBoxes)
                                    Text(
                                      box.name,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.systemGrey2,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              CupertinoIcons.chevron_right,
                              color: CupertinoColors.systemGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                      color: CupertinoColors.separator.resolveFrom(context),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
