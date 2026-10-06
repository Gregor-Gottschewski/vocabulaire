import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../controllers/settings_controller.dart';
import '../models/app_settings.dart';
import 'auth_service.dart';
import 'usage_service.dart';

/// Silently syncs the app settings of Premium users via `settings/{uid}`.
/// The newest `updatedAt` wins.
class SettingsSyncService {
  SettingsSyncService._() {
    UsageService.instance.listenable.addListener(_onUsageChanged);
  }

  static final SettingsSyncService instance = SettingsSyncService._();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _remoteSub;
  StreamSubscription<AppSettings?>? _localSub;
  SettingsController? _controller;
  bool _attached = false;

  /// `updatedAt` of the last settings received from Firestore. Local changes
  /// carrying it are echoes of [SettingsController.applyRemote] and not uploaded.
  DateTime? _lastRemoteUpdatedAt;

  bool get _isPremium => UsageService.instance.listenable.value.isPremium;

  void _onUsageChanged() {
    if (!_attached) return;
    if (_isPremium) {
      _start();
    } else {
      _stop();
    }
  }

  /// Enables syncing for the signed-in user; it only runs while Premium.
  void attach() {
    _attached = true;
    if (_isPremium) _start();
  }

  void detach() {
    _attached = false;
    _stop();
  }

  void _start() {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) return;

    _stop();
    final controller = _controller ??= SettingsController();
    final doc = FirebaseFirestore.instance.collection('settings').doc(uid);

    _remoteSub = doc.snapshots().listen(
      (snapshot) => _onRemote(controller, doc, snapshot),
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('SettingsSyncService: snapshot listener error: $error');
      },
    );
    _localSub = controller.watch().listen(
      (settings) => _upload(doc, settings),
    );
  }

  void _stop() {
    _remoteSub?.cancel();
    _remoteSub = null;
    _localSub?.cancel();
    _localSub = null;
  }

  Future<void> _onRemote(
    SettingsController controller,
    DocumentReference<Map<String, dynamic>> doc,
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) async {
    if (snapshot.metadata.hasPendingWrites) return;

    final local = controller.settings;
    final data = snapshot.data();
    if (data == null) {
      await _upload(doc, local);
      return;
    }

    final remote = AppSettings.fromFirestore(data);
    final remoteAt = remote.updatedAt;
    final localAt = local?.updatedAt;
    if (remoteAt == null) return;
    if (localAt == null || remoteAt.isAfter(localAt)) {
      _lastRemoteUpdatedAt = remoteAt;
      await controller.applyRemote(remote);
    } else if (localAt.isAfter(remoteAt)) {
      await _upload(doc, local);
    }
  }

  Future<void> _upload(
    DocumentReference<Map<String, dynamic>> doc,
    AppSettings? settings,
  ) async {
    final uid = AuthService.instance.currentUser?.uid;
    if (settings == null || uid == null) return;
    if (settings.updatedAt != null &&
        settings.updatedAt == _lastRemoteUpdatedAt) {
      return;
    }
    try {
      await doc.set({
        ...settings.toFirestore(),
        'ownerUid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('SettingsSyncService: upload failed: $e');
    }
  }
}
