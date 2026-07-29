import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/views/vocabulary_list_view.dart';
import '../controllers/box_controller.dart';
import '../models/vocabulary_box.dart';
import '../theme/theme_context_ext.dart';
import 'home_view.dart';
import 'settings_view.dart';
import 'widgets/app_tab_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ValueNotifier<List<MapEntry<String, VocabularyBox>>> _allBoxesNotifier;
  late final List<Widget> _views;
  final List<GlobalKey<NavigatorState>> _tabNavigatorKeys = List.generate(
    3,
    (_) => GlobalKey<NavigatorState>(),
  );
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
    setState(() => _selectedIndex = index);
  }

  Widget _buildTab(int index) {
    return Navigator(
      key: _tabNavigatorKeys[index],
      onGenerateRoute: (settings) => PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => _views[index],
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.background,
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: List.generate(_views.length, _buildTab),
            ),
          ),
          AppTabBar(
            items: [_l10n.tabBoxen, _l10n.tabVokabeln, _l10n.tabEinstellungen],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
