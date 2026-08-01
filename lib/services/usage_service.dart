import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Snapshot of the current user's `rateLimits/{uid}` usage document —
/// online-vocabulary count and synced-audio storage, both maintained
/// server-side (see `functions/src/counters.ts`) and mirrored by the
/// `firestore.rules`/`storage.rules` limit checks.
class UsageInfo {
  final int vocabularyCountOnline;
  final bool isPremium;
  final int audioBytesUsed;

  const UsageInfo({
    this.vocabularyCountOnline = 0,
    this.isPremium = false,
    this.audioBytesUsed = 0,
  });

  int get vocabularyLimit => UsageService.vocabularyLimitPremium;

  static UsageInfo fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    return UsageInfo(
      vocabularyCountOnline:
          (data?['vocabularyCountOnline'] as num?)?.toInt() ?? 0,
      isPremium: data?['isPremium'] == true,
      audioBytesUsed: (data?['audioBytesUsed'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Owns a listener on the current user's `rateLimits/{uid}` document
class UsageService {
  UsageService._();

  static final UsageService instance = UsageService._();

  static const int vocabularyLimitPremium = 3000;
  static const int audioStorageLimitBytes = 50 * 1024 * 1024;

  final ValueNotifier<UsageInfo> _usageNotifier = ValueNotifier(
    const UsageInfo(),
  );
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  ValueListenable<UsageInfo> get listenable => _usageNotifier;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      FirebaseFirestore.instance.collection('rateLimits').doc(uid);

  /// Starts the listener for the currently signed-in user.
  void attach() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _subscription?.cancel();
    _subscription = _doc(uid).snapshots().listen(
      (snapshot) => _usageNotifier.value = UsageInfo.fromSnapshot(snapshot),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('UsageService: snapshot listener error: $error');
      },
    );
  }

  /// Stops the listener.
  void detach() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// One-shot read, independent of [attach]
  Future<UsageInfo> fetch() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const UsageInfo();
    return UsageInfo.fromSnapshot(await _doc(uid).get());
  }
}
