import 'package:flutter/widgets.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/views/widgets/app_dialog.dart';

import 'app_exception.dart';

/// [AppExceptionDialog] adds application global error dialogs methods.
extension AppExceptionDialog on BuildContext {
  /// Show a dialog with given error.
  Future<void> showAppError(AppException e) {
    final i18n = AppLocalizations.of(this)!;

    final message = switch (e.error) {
      AppError.exportDirectoryFailed => i18n.errorExportDirectoryFailed,
      AppError.exportWriteFailed => i18n.errorExportWriteFailed,
      AppError.exportAudioFailed => i18n.errorExportAudioFailed,
      AppError.exportArchiveFailed => i18n.errorExportArchiveFailed,
      AppError.exportCacheFailed => i18n.errorExportCacheFailed,
      AppError.importMissingStoreFile => i18n.errorImportMissingStoreFile,
      AppError.importInvalidFormat => i18n.errorImportInvalidFormat,
      AppError.duplicateBoxName => i18n.errorDuplicateBoxName(
        e.details as String,
      ),
      AppError.moveBoxOfflineFailed => i18n.errorMoveBoxOfflineFailed,
      AppError.moveBoxOnlineFailed => i18n.errorMoveBoxOnlineFailed,
      AppError.vocabularyLimitReached => i18n.errorVocabularyLimitReached,
      AppError.audioStorageLimitReached => i18n.errorAudioStorageLimitReached,
      AppError.ttsEmptyText => i18n.errorTtsEmptyText,
      AppError.ttsTextTooLong => i18n.errorTtsTextTooLong,
      AppError.ttsRateLimitExceeded => i18n.errorTtsRateLimitExceeded,
      AppError.ttsNotAuthenticated => i18n.errorTtsNotAuthenticated,
      AppError.ttsUnknownError => i18n.errorTtsUnknownError,
    };

    return showAppDialog(
      context: this,
      title: i18n.commonError,
      message: message,
      actions: [AppDialogAction(label: i18n.commonOk, onPressed: () {})],
    );
  }
}
