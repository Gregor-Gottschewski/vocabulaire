import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../views/widgets/app_dialog.dart';
import 'app_exception.dart';
import 'app_exception_ui.dart';

/// [ExportShareContext] bundles the common export-then-share flow.
extension ExportShareContext on BuildContext {
  /// Asks the user whether their learning progress should be included in
  /// an upcoming export.
  Future<bool> confirmExportProgress() async {
    final l10n = AppLocalizations.of(this)!;
    bool includeProgress = false;

    await showAppDialog(
      context: this,
      title: l10n.exportProgressDialogTitle,
      message: l10n.exportProgressDialogMessage,
      actions: [
        AppDialogAction(
          label: l10n.commonNo,
          onPressed: () => includeProgress = false,
        ),
        AppDialogAction(
          label: l10n.commonYes,
          onPressed: () => includeProgress = true,
        ),
      ],
    );

    return includeProgress;
  }

  /// Runs [export], shares the resulting file via [SharePlus] with [title],
  /// and shows an error dialog on failure.
  Future<void> exportAndShare({
    required Future<File> Function() export,
    required String title,
    List<String>? fileNameOverrides,
    VoidCallback? onStart,
    VoidCallback? onFinish,
  }) async {
    onStart?.call();
    try {
      final zipFile = await export();
      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          title: title,
          files: [XFile(zipFile.path)],
          fileNameOverrides: fileNameOverrides,
        ),
      );
    } on FileSystemException catch (e) {
      if (!mounted) return;
      await showAppError(AppException(AppError.exportCacheFailed, details: e));
    } on AppException catch (e) {
      if (!mounted) return;
      await showAppError(e);
    } finally {
      onFinish?.call();
    }
  }
}
