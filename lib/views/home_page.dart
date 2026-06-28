import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/views/vocabulary_list_view.dart';
import '../controllers/box_controller.dart';
import '../models/vocabulary_box.dart';
import 'home_view.dart';
import 'settings_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ValueNotifier<List<MapEntry<dynamic, VocabularyBox>>> _allBoxesNotifier;
  late final List<Widget> _views;
  final BoxController _boxController = BoxController();
  late AppLocalizations _l10n;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _allBoxesNotifier = _boxController.listenableForAll();
    _views = [
      const HomeView(),
      VocabularyListView(multipleBoxes: true, boxListenable: _allBoxesNotifier),
      const SettingsView(),
    ];
  }

  @override
  void dispose() {
    _allBoxesNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.cube_box),
            label: _l10n.tabBoxen,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.book),
            label: _l10n.tabVokabeln,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.settings),
            label: _l10n.tabEinstellungen,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (context) => _views[index]);
      },
    );
  }
}
