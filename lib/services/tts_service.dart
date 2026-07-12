import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';

import 'app_exception.dart';
import 'app_paths.dart';
import 'auth_service.dart';

/// TTS support for card's back pronunciation.
class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  /// Character input limit is enforced by server.
  /// Local check prevents unnecessary server request.
  /// Current limit: `65`.
  static const maxChars = 65;

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'europe-west1',
  );

  Future<void> synthesizeAndSave({
    required String text,
    required String cardId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw AppException(AppError.ttsEmptyText);
    }
    if (trimmed.length > maxChars) {
      throw AppException(AppError.ttsTextTooLong);
    }

    await AuthService.instance.ensureSignedIn();

    final Map<Object?, Object?> data;
    try {
      // see functions/index.ts:synthesizeSpeech
      final result = await _functions.httpsCallable('synthesizeSpeech').call({
        'text': trimmed,
      });
      data = result.data as Map<Object?, Object?>;
    } on FirebaseFunctionsException catch (e) {
      throw AppException(
        switch (e.code) {
          'resource-exhausted' => AppError.ttsRateLimitExceeded,
          'invalid-argument' => AppError.ttsTextTooLong,
          'unauthenticated' => AppError.ttsNotAuthenticated,
          _ => AppError.ttsUnknownError,
        },
        details: e,
      );
    } catch (e) {
      throw AppException(AppError.ttsUnknownError, details: e);
    }

    final audioContent = data['audioContent'] as String;
    final bytes = base64Decode(audioContent);
    await AppPaths.audioFile(cardId).writeAsBytes(bytes, flush: true);
  }
}
