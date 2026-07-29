import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode, kDebugMode;
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
import 'theme/app_theme.dart';
import 'views/home_page.dart';

const bool _useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (kDebugMode && _useFirebaseEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }

  // TODO: switch to AppleAppAttestProvider (iOS) / AppleDeviceCheckProvider (macOS)
  // once a paid Apple Developer Program membership is available. The debug
  // provider requires no paid account but must not ship in App Store builds.
  // Sign in with Apple (once the Apple Developer Program membership above is
  // active) should be added alongside this switch — see AuthService.
  await FirebaseAppCheck.instance.activate(
    providerApple: kReleaseMode
        ? (throw UnsupportedError(
            'AppleDebugProvider must not ship in release builds. Configure '
            'AppleAppAttestProvider/AppleDeviceCheckProvider before release.',
          ))
        : const AppleDebugProvider(),
  );

  await AuthService.instance.ensureSignedIn();

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
    return MaterialApp(
      title: 'Vocabulaire',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
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
