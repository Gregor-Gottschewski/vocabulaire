# Firebase Emulator

Start the application with `--dart-define=USE_FIREBASE_EMULATOR=true` to point the app at the local Firebase emulator suite (`firebase emulators:start`) instead of the live project.
Never enabled in release builds due to check `kDebugMode && _useFirebaseEmulator`.