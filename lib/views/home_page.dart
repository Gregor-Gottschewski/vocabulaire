import 'package:flutter/cupertino.dart';
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
  int _selectedIndex = 0;
  final BoxController _boxController = BoxController();
  late final ValueNotifier<List<MapEntry<dynamic, VocabularyBox>>>
  _allBoxesNotifier;
  late final List<Widget> _views;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cube_box),
            label: 'Boxen',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: 'Vokabeln',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Einstellungen',
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
