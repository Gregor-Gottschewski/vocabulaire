import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Snapshot of the current user's `rateLimits/{uid}` usage document
class UsageInfo {
  final int vocabularyCountOnline;
  final DateTime? subscriptionExpiresAt;
  final int audioBytesUsed;
  final int groupCountOnline;

  const UsageInfo({
    this.vocabularyCountOnline = 0,
    this.subscriptionExpiresAt,
    this.audioBytesUsed = 0,
    this.groupCountOnline = 0,
  });

  bool get isPremium =>
      subscriptionExpiresAt != null &&
      subscriptionExpiresAt!.isAfter(DateTime.now());

  int get vocabularyLimit => UsageService.vocabularyLimitPremium;

  int get groupLimit => UsageService.groupLimitPremium;

  static UsageInfo fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    final expiresAt = data?['subscriptionExpiresAt'] as Timestamp?;
    return UsageInfo(
      vocabularyCountOnline:
          (data?['vocabularyCountOnline'] as num?)?.toInt() ?? 0,
      subscriptionExpiresAt: expiresAt?.toDate(),
      audioBytesUsed: (data?['audioBytesUsed'] as num?)?.toInt() ?? 0,
      groupCountOnline: (data?['groupCountOnline'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Owns a listener on the current user's `rateLimits/{uid}` document
class UsageService {
  UsageService._();

  static final UsageService instance = UsageService._();

  static const int vocabularyLimitPremium = 3000;
  static const int audioStorageLimitBytes = 50 * 1024 * 1024;
  static const int groupLimitPremium = 1000;
  static const int boxLimitPerGroup = 800;

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
}
