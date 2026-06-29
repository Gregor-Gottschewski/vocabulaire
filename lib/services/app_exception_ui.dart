import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import 'app_exception.dart';

/// Generic UI dialogs for error handling using [CupertinoAlertDialog].
extension AppExceptionDialog on BuildContext {
  Future<void> showAppError(AppException e) {
    AppLocalizations i18n = AppLocalizations.of(this)!;

    return showCupertinoDialog(
      context: this,
      builder: (_) => CupertinoAlertDialog(
        title: Text(i18n.commonError),
        content: Text(e.userMessage),
        actions: [
          CupertinoDialogAction(
            child: Text(i18n.commonOk),
            onPressed: () => Navigator.of(this).pop(),
          ),
        ],
      ),
    );
  }
}
