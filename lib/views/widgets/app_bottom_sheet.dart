import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// [showAppPicker] shows a bottom picker sheet for generic children.
/// - [context] build context of the sheet.
/// - [title] header of the sheet (longer texts are wrapped).
/// - [children] content in the sheet.
Future<T?> showAppPicker<T>({
  required BuildContext context,
  String? title,
  required List<Widget> children,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: context.colors.background,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (sheetContext) {
      final colors = sheetContext.colors;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.sectionGap,
            AppSpacing.pageHorizontal,
            AppSpacing.sectionGap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title,
                  softWrap: true,
                  style: AppTypography.labelSans.copyWith(
                    color: colors.textLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapLarge),
              ],
              for (var i = 0; i < children.length; i++) ...[
                if (i != 0)
                  Container(
                    height: AppSpacing.hairline,
                    color: colors.borderSubtle,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      );
    },
  );
}

/// A single row in [showAppActionSheet].
class AppActionSheetAction {
  final String label;
  final VoidCallback onPressed;
  final bool destructive;

  const AppActionSheetAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });
}

/// Shows a bottom sheet listing [actions] as divider-separated rows.
/// Sheet for action buttons.
Future<void> showAppActionSheet({
  required BuildContext context,
  String? title,
  required List<AppActionSheetAction> actions,
}) {
  return showAppPicker<void>(
    context: context,
    title: title,
    children: [
      for (final action in actions) _AppActionSheetRow(action: action),
    ],
  );
}

class _AppActionSheetRow extends StatelessWidget {
  final AppActionSheetAction action;

  const _AppActionSheetRow({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).pop();
        action.onPressed();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.gapMedium + 4),
        child: Text(
          action.label,
          style: AppTypography.bodySans.copyWith(
            color: action.destructive ? colors.danger : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
