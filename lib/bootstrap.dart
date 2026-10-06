import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kReleaseMode, kDebugMode, PlatformDispatcher;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vocabulaire/flavors.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/views/login_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/controllers/settings_controller.dart';
import 'package:vocabulaire/models/app_settings.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/services/audio_upload_queue_service.dart';
import 'package:vocabulaire/services/box_sync_service.dart';
import 'package:vocabulaire/services/group_sync_service.dart';
import 'package:vocabulaire/services/settings_sync_service.dart';
import 'package:vocabulaire/services/subscription_service.dart';
import 'package:vocabulaire/services/usage_service.dart';
import 'models/conjugation.dart';
import 'models/pending_audio_upload.dart';
import 'models/vocabulary_box.dart';
import 'models/vocabulary_group.dart';
import 'models/vocabulary.dart';
import 'theme/app_theme.dart';
import 'views/home_page.dart';
import 'views/verify_email_view.dart';

/// When enabled, the local Firebase emulator will be used
const bool _useFirebaseEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');
const bool _useDebugProvider = bool.fromEnvironment('USE_DEBUG_PROVIDER');
const String _debugToken = String.fromEnvironment('DEBUG_TOKEN');

Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.init(flavor);
  await Firebase.initializeApp(options: FlavorConfig.instance.firebaseOptions);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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

  await FirebaseAppCheck.instance.activate(
    providerApple: kReleaseMode || !_useDebugProvider
        ? const AppleAppAttestWithDeviceCheckFallbackProvider()
        : const AppleDebugProvider(debugToken: _debugToken),
  );

  await Hive.initFlutter();
  await AppPaths.init();

  Hive.registerAdapter(VocabularyAdapter());
  Hive.registerAdapter(VocabularyBoxAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(PendingAudioUploadAdapter());
  Hive.registerAdapter(ConjugationAdapter());
  Hive.registerAdapter(VocabularyGroupAdapter());

  try {
    await Hive.openBox<VocabularyBox>('boxes');
    await Hive.openBox<VocabularyGroup>('groups');
    await Hive.openBox<AppSettings>(SettingsController.settingsBoxName);
    await Hive.openBox<PendingAudioUpload>('pendingAudioUploads');
  } on FileSystemException catch (_) {
    debugPrint(
      "Hive box file locked. Another instance of Vocabulaire is running.",
    );
    exit(1);
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authSub = FirebaseAuth.instance.userChanges().listen(_onAuthChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    BoxSyncService.instance.detach();
    GroupSyncService.instance.detach();
    UsageService.instance.detach();
    AudioUploadQueueService.instance.detach();
    SubscriptionService.instance.detach();
    SettingsSyncService.instance.detach();
    super.dispose();
  }

  void _onAuthChanged(User? user) {
    BoxSyncService.instance.detach();
    GroupSyncService.instance.detach();
    UsageService.instance.detach();
    AudioUploadQueueService.instance.detach();
    SettingsSyncService.instance.detach();
    if (user != null && user.emailVerified) {
      BoxSyncService.instance.attach();
      GroupSyncService.instance.attach();
      UsageService.instance.attach();
      AudioUploadQueueService.instance.attach();
      SubscriptionService.instance.attach();
      SettingsSyncService.instance.attach();
    }
  }

  Future<void> resumeApplication() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.reload();
      } catch (_) {}
    }
    if (user != null && user.emailVerified) {
      try {
        await Future.wait([
          user.getIdToken(true),
          FirebaseAppCheck.instance.getToken(true),
        ]);
      } catch (_) {}
      BoxSyncService.instance.attach();
      GroupSyncService.instance.attach();
      UsageService.instance.attach();
      AudioUploadQueueService.instance.attach();
      SettingsSyncService.instance.attach();
    }
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await resumeApplication();
      case AppLifecycleState.paused:
        BoxSyncService.instance.detach();
        GroupSyncService.instance.detach();
        UsageService.instance.detach();
        AudioUploadQueueService.instance.detach();
        SettingsSyncService.instance.detach();
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
      supportedLocales: const [Locale('en'), Locale('de'), Locale('fr')],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        initialData: FirebaseAuth.instance.currentUser,
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) return const LoginView();
          if (!user.emailVerified) return const VerifyEmailView();
          return const MyHomePage();
        },
      ),
    );
  }
}
