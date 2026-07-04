import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

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
      AppError.duplicateBoxName => i18n.errorDuplicateBoxName(e.details as String),
    };

    return showCupertinoDialog(
      context: this,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(i18n.commonError),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(i18n.commonOk),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }
}
