import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Ensures a stable anonymous Firebase identity per device installation,
/// used server-side to enforce per-device rate limits.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const List<Duration> _retryBackoff = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 8),
  ];

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  int _retryAttempts = 0;

  Future<void> ensureSignedIn({bool forceFreshSession = false}) async {
    if (forceFreshSession && FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  Future<void> ensureSignedInWithRetry({
    bool forceFreshSession = false,
    VoidCallback? onSignedIn,
  }) async {
    try {
      await ensureSignedIn(forceFreshSession: forceFreshSession);
    } catch (_) {
      _scheduleRetry(onSignedIn);
    }
  }

  void _scheduleRetry(VoidCallback? onSignedIn) {
    _connectivitySubscription ??= Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        _retry(onSignedIn);
      }
    });
    _retryTimer?.cancel();
    final delay =
        _retryBackoff[_retryAttempts.clamp(0, _retryBackoff.length - 1)];
    _retryTimer = Timer(delay, () => _retry(onSignedIn));
  }

  Future<void> _retry(VoidCallback? onSignedIn) async {
    try {
      await ensureSignedIn();
      _retryTimer?.cancel();
      _retryTimer = null;
      await _connectivitySubscription?.cancel();
      _connectivitySubscription = null;
      _retryAttempts = 0;
      onSignedIn?.call();
    } catch (_) {
      _retryAttempts++;
      _scheduleRetry(onSignedIn);
    }
  }
}
