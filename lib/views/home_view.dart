import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/views/box_detail_page.dart';
import 'package:vocabulaire/views/box_tile.dart';

import '../controllers/box_controller.dart';
import '../models/vocabulary_box.dart';
import 'create_box_flow.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewWidget();
}

class HomeViewWidget extends State<HomeView> {
  final BoxController _boxController = BoxController();
  late AppLocalizations _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_l10n.tabBoxen),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final result = await Navigator.of(context, rootNavigator: true)
                .push<({VocabularyBox box, dynamic key})>(
                  CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => const CreateBoxFlow(),
                  ),
                );
            if (result == null || !context.mounted) return;
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    BoxDetailPage(box: result.box, boxKey: result.key),
              ),
            );
          },
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _boxController.listenable,
          builder: (context, Box<VocabularyBox> box, _) {
            final keys = box.keys.cast<dynamic>().toList();

            if (keys.isEmpty) {
              return Center(child: Text(_l10n.homeEmpty));
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
    );
  }
}
