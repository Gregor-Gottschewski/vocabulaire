import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';

/// Handles email/password authentication against Firebase Auth.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  /// Emits whenever the signed-in user changes.
  Stream<User?> get userChanges => FirebaseAuth.instance.userChanges();

  Future<void> sendEmailVerification() =>
      _wrap(() => FirebaseAuth.instance.currentUser!.sendEmailVerification());

  /// Refreshes the current user's data from Firebase.
  Future<void> reloadUser() =>
      _wrap(() => FirebaseAuth.instance.currentUser!.reload());

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) => _wrap(
    () => FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  Future<UserCredential> register({
    required String email,
    required String password,
  }) => _wrap(
    () => FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ),
  );

  Future<PasswordValidationStatus> validatePassword({
    required String password,
  }) => _wrap(
    () =>
        FirebaseAuth.instance.validatePassword(FirebaseAuth.instance, password),
  );

  Future<void> sendPasswordResetEmail(String email) =>
      _wrap(() => FirebaseAuth.instance.sendPasswordResetEmail(email: email));

  /// Reauthenticates the current user with their password and sends a
  /// verification link to [newEmail].
  Future<void> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) => _wrap(() async {
    final credential = EmailAuthProvider.credential(
      email: currentUser!.email!,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.verifyBeforeUpdateEmail(newEmail);
  });

  /// Reauthenticates the current user with their password and sets
  /// [newPassword].
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _wrap(() async {
    final credential = EmailAuthProvider.credential(
      email: currentUser!.email!,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  });

  /// Reauthenticates the current user with their password, then permanently
  /// deletes their Firebase Auth account.
  Future<void> deleteAccount({required String currentPassword}) =>
      _wrap(() async {
        final credential = EmailAuthProvider.credential(
          email: currentUser!.email!,
          password: currentPassword,
        );
        await currentUser!.reauthenticateWithCredential(credential);
        await currentUser!.delete();
      });

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  Future<T> _wrap<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code), details: e);
    }
  }

  AppError _mapAuthError(String code) => switch (code) {
    'invalid-email' => AppError.authInvalidEmail,
    'user-disabled' => AppError.authUserDisabled,
    'user-not-found' => AppError.authUserNotFound,
    'wrong-password' || 'invalid-credential' => AppError.authWrongPassword,
    'email-already-in-use' => AppError.authEmailAlreadyInUse,
    'weak-password' => AppError.authWeakPassword,
    'network-request-failed' => AppError.authNetworkFailed,
    'too-many-requests' => AppError.authTooManyRequests,
    _ => AppError.authUnknownError,
  };
}
