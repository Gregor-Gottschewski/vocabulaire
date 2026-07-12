import 'package:firebase_auth/firebase_auth.dart';

/// Ensures a stable anonymous Firebase identity per device installation,
/// used server-side to enforce per-device rate limits.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<void> ensureSignedIn() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }
}
