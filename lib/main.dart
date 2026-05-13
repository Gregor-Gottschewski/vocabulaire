import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/controllers/settings_controller.dart';
import 'package:vocabulaire/models/app_settings.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'models/vocabulary_box.dart';
import 'models/vocabulary.dart';
import 'views/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await AppPaths.init();

  Hive.registerAdapter(VocabularyAdapter());
  Hive.registerAdapter(VocabularyBoxAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  await Hive.openBox<VocabularyBox>('boxes');
  await Hive.openBox<AppSettings>(SettingsController.settingsBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Vocabulaire',
      home: const MyHomePage(),
    );
  }
}
