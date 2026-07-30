# Firebase Emulator

Start the application with `--dart-define=USE_FIREBASE_EMULATOR=true` to point the app at the local Firebase emulator suite (`firebase emulators:start`) instead of the live project.
Never enabled in release builds due to check `kDebugMode && _useFirebaseEmulator`.
Changes in Firebase Emulator are not persistent.
Use `firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data` for automatic loading and storing data.

> [!WARNING]
> Never push your local store!
> It could contain personal information.

## Experiencing Connection Issues?

If your App has cashed your session from another session, a session reset is necessary.
To reset the session, run `flutter` with `--dart-define=USE_FIREBASE_EMULATOR=true --dart-define=RESET_AUTH_SESSION=true`.