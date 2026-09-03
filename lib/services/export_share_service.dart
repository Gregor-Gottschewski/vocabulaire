import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import 'app_exception.dart';
import 'app_exception_ui.dart';

/// [ExportShareContext] bundles the common export-then-share flow.
extension ExportShareContext on BuildContext {
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
