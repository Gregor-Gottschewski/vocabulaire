import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// [AppDialogAction] represents a choice in a application dialog window.
/// - [label] text/title of the action.
/// - [onPressed] action on pressed.
/// - [destructive] renders the element with red label.
/// - [isDefaultAction] currently unused. Planned for "Enter"-key in desktop
///   application.
class AppDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool destructive;
  final bool isDefaultAction;

  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.isDefaultAction = false,
  });
}

/// Show an application dialog with actions.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  required List<AppDialogAction> actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (_) => AppDialog(title: title, message: message, actions: actions),
  );
}

/// [AppDialog] is the main dialog element of this application.
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final List<AppDialogAction> actions;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Dialog(
      backgroundColor: colors.background,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(
          color: colors.borderStrong,
          width: AppSpacing.hairline,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sectionGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.headlineSerif.copyWith(
                fontSize: 20,
                color: colors.textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.gapMedium),
              Text(
                message!,
                style: AppTypography.bodySans.copyWith(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sectionGap),
            for (var i = 0; i < actions.length; i++) ...[
              if (i != 0)
                Container(
                  height: AppSpacing.hairline,
                  color: colors.borderSubtle,
                ),
              _DialogActionRow(action: actions[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// [_DialogActionRow] renders the action row itself.
/// Sets on tap behaviour to close dialog.
class _DialogActionRow extends StatelessWidget {
  final AppDialogAction action;

  const _DialogActionRow({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = action.destructive ? colors.danger : colors.textPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: action.onPressed == null
          ? null
          : () {
              Navigator.of(context).pop();
              action.onPressed!.call();
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.gapMedium + 4),
        child: Text(
          action.label,
          style: AppTypography.bodySans.copyWith(color: color),
        ),
      ),
    );
  }
}
