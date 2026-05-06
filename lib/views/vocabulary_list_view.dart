import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/views/edit_vocabulary_view.dart';
import '../controllers/box_controller.dart';
import '../models/vocabulary_box.dart';
import '../models/vocabulary.dart';

class VocabularyListView extends StatefulWidget {
  final List<MapEntry<dynamic, VocabularyBox>> boxes;
  final bool multipleBoxes;

  const VocabularyListView({
    super.key,
    required this.boxes,
    required this.multipleBoxes,
  });

  @override
  State<VocabularyListView> createState() => _VocabularyListViewState();
}

/// Helper class to combine box key, box name and vocabulary for easier list rendering
class _BoxVocabulary {
  final dynamic boxKey;
  final String boxName;
  final Vocabulary vocabulary;

  _BoxVocabulary(this.boxKey, this.boxName, this.vocabulary);
}

class _VocabularyListViewState extends State<VocabularyListView> {
  final BoxController _controller = BoxController();
  final Set<String> _pendingRemoval = {};

  void _navigateToCreate(dynamic boxKey) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => EditVocabularyView(boxKey: boxKey)),
    );
  }

  void _navigateToEdit(dynamic boxKey, Vocabulary vocabulary) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) =>
            EditVocabularyView(boxKey: boxKey, vocabulary: vocabulary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Vokabeln"),
        trailing: !widget.multipleBoxes
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _navigateToCreate(widget.boxes.first.key),
                child: Icon(CupertinoIcons.add),
              )
            : null,
      ),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _controller.listenable,
          builder: (context, hiveBox, _) {
            final fresh = widget.boxes
                .map((e) => MapEntry(e.key, hiveBox.get(e.key)))
                .where((e) => e.value != null)
                .expand(
                  (entry) => entry.value!.vocabularies.map(
                    (v) => _BoxVocabulary(entry.key, entry.value!.name, v),
                  ),
                )
                .where(
                  (item) => !_pendingRemoval.contains(
                    '${item.vocabulary.id}_${item.boxKey}',
                  ),
                )
                .toList();

            if (fresh.isEmpty) {
              return const Center(child: Text('No vocabularies yet.'));
            }

            return ListView.builder(
              itemCount: fresh.length,
              itemBuilder: (context, index) {
                final item = fresh[index];
                final v = item.vocabulary;
                final boxKey = item.boxKey;
                final boxName = item.boxName;

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
                        onPressed: () => _navigateToEdit(boxKey, v),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.word,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.label,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    v.meaning,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (widget.multipleBoxes)
                                    Text(
                                      boxName,
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
