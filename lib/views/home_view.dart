import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/views/box_detail_page.dart';
import 'package:vocabulaire/views/box_tile.dart';

import '../controllers/box_controller.dart';
import '../models/vocabulary_box.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewWidget();
}

class HomeViewWidget extends State<HomeView> {
  final BoxController _boxController = BoxController();

  void _addNewBox() {
    var box = VocabularyBox(
      name: 'Neue Box ${DateTime.now().millisecondsSinceEpoch}',
      description: 'Beschreibung der neuen Box',
      vocabularies: [],
    );

    _boxController.addBox(box);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Boxen'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _addNewBox,
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Expanded(
          child: ValueListenableBuilder(
            valueListenable: _boxController.listenable,
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
                          builder: (context) =>
                              BoxDetailPage(box: b, boxKey: keys[index]),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
