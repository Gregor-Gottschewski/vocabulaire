import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode, kDebugMode;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vocabulaire/flavors.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/controllers/settings_controller.dart';
import 'package:vocabulaire/models/app_settings.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/services/audio_upload_queue_service.dart';
import 'package:vocabulaire/services/auth_service.dart';
import 'package:vocabulaire/services/box_sync_service.dart';
import 'package:vocabulaire/services/usage_service.dart';
import 'models/conjugation.dart';
import 'models/pending_audio_upload.dart';
import 'models/vocabulary_box.dart';
import 'models/vocabulary.dart';
import 'theme/app_theme.dart';
import 'views/home_page.dart';

/// When enabled, the local Firebase emulator will be used
const bool _useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

/// When enabled, the session is reset to remove real (old) session
const bool _resetAuthSession = bool.fromEnvironment('RESET_AUTH_SESSION');

Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.init(flavor);
  await Firebase.initializeApp(options: FlavorConfig.instance.firebaseOptions);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (kDebugMode && _useFirebaseEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFunctions.instanceFor(
      region: 'europe-west1',
    ).useFunctionsEmulator('localhost', 5001);
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

  // reset session if debug mode enabled, firebase emulator used and auth reset variable set to true
  await AuthService.instance.ensureSignedInWithRetry(
    forceFreshSession: kDebugMode && _useFirebaseEmulator && _resetAuthSession,
    onSignedIn: () {
      BoxSyncService.instance.attach();
      UsageService.instance.attach();
    },
  );

  await Hive.initFlutter();
  await AppPaths.init();

  Hive.registerAdapter(VocabularyAdapter());
  Hive.registerAdapter(VocabularyBoxAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(PendingAudioUploadAdapter());
  Hive.registerAdapter(ConjugationAdapter());

  await Hive.openBox<VocabularyBox>('boxes');
  await Hive.openBox<AppSettings>(SettingsController.settingsBoxName);
  await Hive.openBox<PendingAudioUpload>('pendingAudioUploads');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ensureSignedIn() has already completed in main() by the time this
    // runs, so the first attach() attempt succeeds rather than waiting for
    // the first `resumed` event (which doesn't fire on cold start).
    BoxSyncService.instance.attach();
    UsageService.instance.attach();
    AudioUploadQueueService.instance.attach();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BoxSyncService.instance.detach();
    UsageService.instance.detach();
    AudioUploadQueueService.instance.detach();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        BoxSyncService.instance.attach();
        UsageService.instance.attach();
        AudioUploadQueueService.instance.attach();
      case AppLifecycleState.paused:
        BoxSyncService.instance.detach();
        UsageService.instance.detach();
        AudioUploadQueueService.instance.detach();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlavorConfig.instance.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('de'), Locale('en'), Locale('fr')],
      home: const MyHomePage(),
    );
  }
}
