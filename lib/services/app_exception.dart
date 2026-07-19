/// Predefined application errors
enum AppError {
  exportDirectoryFailed,
  exportWriteFailed,
  exportAudioFailed,
  exportArchiveFailed,
  exportCacheFailed,
  importMissingStoreFile,
  importInvalidFormat,
  duplicateBoxName,
  ttsEmptyText,
  ttsTextTooLong,
  ttsRateLimitExceeded,
  ttsNotAuthenticated,
  ttsUnknownError,
}

/// [AppException] represents a user-facing application error.
/// Use [AppError] to identify the error type; the UI layer translates it to a localized message.
class AppException implements Exception {
  final AppError error;
  final Object? details;

  AppException(this.error, {this.details});

  @override
  String toString() => 'AppException(error: $error)';
}
