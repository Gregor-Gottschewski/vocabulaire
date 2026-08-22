import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/pending_audio_upload.dart';
import 'app_exception.dart';
import 'audio_sync_service.dart';

/// Persists audio uploads for online-box vocabularies.
class AudioUploadQueueService {
  AudioUploadQueueService._();

  static final AudioUploadQueueService instance = AudioUploadQueueService._();

  static const int _maxConcurrentUploads = 3;
  static const List<Duration> _backoffSchedule = [
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 8),
  ];

  final Box<PendingAudioUpload> _queueBox = Hive.box<PendingAudioUpload>(
    'pendingAudioUploads',
  );
  final AudioSyncService _audioSync = AudioSyncService.instance;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  bool _draining = false;
  bool _drainAgain = false;

  /// Persists [vocabId] as pending and schedules background processing.
  void enqueue(String groupId, String boxId, String vocabId) {
    _queueBox.put(
      vocabId,
      PendingAudioUpload(
        id: vocabId,
        boxId: boxId,
        groupId: groupId,
        createdAt: DateTime.now(),
      ),
    );
    _scheduleDrain();
  }

  /// Drops a pending upload, e.g. because the recording or the vocabulary
  /// itself was deleted before the upload completed.
  void cancel(String vocabId) {
    _queueBox.delete(vocabId);
  }

  /// Starts reacting to connectivity changes and processes any entries left
  /// over from a previous session (e.g. the app was killed while offline).
  void attach() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        _scheduleDrain();
      }
    });
    _scheduleDrain();
  }

  /// Stops the connectivity listener and any pending retry timer. Queued
  /// entries remain persisted in Hive and resume on the next [attach].
  void detach() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  void _scheduleDrain() {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (_draining) {
      _drainAgain = true;
      return;
    }
    unawaited(_drain());
  }

  Future<void> _drain() async {
    _draining = true;
    try {
      final entries = _queueBox.values.toList();
      for (var i = 0; i < entries.length; i += _maxConcurrentUploads) {
        await Future.wait(
          entries.skip(i).take(_maxConcurrentUploads).map(_processEntry),
        );
      }
    } finally {
      _draining = false;
    }

    if (_drainAgain) {
      _drainAgain = false;
      unawaited(_drain());
      return;
    }

    _scheduleNextRetryIfNeeded();
  }

  Future<void> _processEntry(PendingAudioUpload entry) async {
    if (_queueBox.get(entry.id) == null) return;

    try {
      await _audioSync.uploadAudio(entry.groupId, entry.boxId, entry.id);
      await _queueBox.delete(entry.id);
    } on AppException catch (e) {
      if (e.error == AppError.audioStorageLimitReached) {
        debugPrint(
          'AudioUploadQueueService: dropping upload for ${entry.id} '
          '(storage limit reached)',
        );
        await _queueBox.delete(entry.id);
        return;
      }
      await _registerFailure(entry);
    } catch (error) {
      debugPrint(
        'AudioUploadQueueService: upload failed for ${entry.id}: $error',
      );
      await _registerFailure(entry);
    }
  }

  Future<void> _registerFailure(PendingAudioUpload entry) async {
    if (_queueBox.get(entry.id) == null) return;
    await _queueBox.put(entry.id, entry.copyWith(attempts: entry.attempts + 1));
  }

  void _scheduleNextRetryIfNeeded() {
    if (_queueBox.isEmpty) return;
    final minAttempts = _queueBox.values
        .map((e) => e.attempts)
        .reduce((a, b) => a < b ? a : b);
    final delay =
        _backoffSchedule[minAttempts.clamp(0, _backoffSchedule.length - 1)];
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, _scheduleDrain);
  }
}
