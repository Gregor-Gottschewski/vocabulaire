import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/controllers/settings_controller.dart';
import 'package:vocabulaire/firebase_options.dart';
import 'package:vocabulaire/models/app_settings.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/services/auth_service.dart';
import 'models/vocabulary_box.dart';
import 'models/vocabulary.dart';
import 'views/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // TODO: switch to AppleAppAttestProvider (iOS) / AppleDeviceCheckProvider (macOS)
  // once a paid Apple Developer Program membership is available. The debug
  // provider requires no paid account but must not ship in App Store builds.
  await FirebaseAppCheck.instance.activate(
    providerApple: const AppleDebugProvider(),
  );
  unawaited(AuthService.instance.ensureSignedIn());

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
        Locale('fr'),
      ],
      home: const MyHomePage(),
    );
  }
}
