import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/views/box_detail_page.dart';
import 'package:vocabulaire/views/box_tile.dart';

import '../controllers/box_controller.dart';
import '../models/vocabulary_box.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final BoxController boxController = BoxController();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text('Boxen')),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton.filled(
                      onPressed: () {
                        var box = VocabularyBox(
                          name:
                              'Neue Box ${DateTime.now().millisecondsSinceEpoch}',
                          description: 'Beschreibung der neuen Box',
                          vocabularies: [],
                        );

                        boxController.addBox(box);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(CupertinoIcons.add, size: 20.0),
                          SizedBox(width: 8.0),
                          Text('Neue Box'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: BoxController().listenable,
                builder: (context, Box<VocabularyBox> box, _) {
                  final keys = box.keys.cast<dynamic>().toList();

                  if (keys.isEmpty) {
                    return const Center(child: Text('Keine Boxen vorhanden.'));
                  }

                  return ListView.builder(
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      final b = box.get(keys[index]) as VocabularyBox;
                      return BoxTile(
                        box: b,
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => BoxDetailPage(box: b, boxKey: keys[index]),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
