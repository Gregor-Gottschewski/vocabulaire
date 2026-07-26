import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// [showAppPicker] shows a bottom picker sheet.
/// - [context] build context of the sheet.
/// - [title] header of the sheet (longer texts are wrapped).
/// - [options] generic options list.
/// - [selected] selected element by default.
/// - [labelBuilder] builder for [options].
Future<T?> showAppPicker<T>({
  required BuildContext context,
  String? title,
  required List<T> options,
  required T? selected,
  required String Function(T) labelBuilder,
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
              for (var i = 0; i < options.length; i++) ...[
                if (i != 0)
                  Container(
                    height: AppSpacing.hairline,
                    color: colors.borderSubtle,
                  ),
                _PickerOptionRow(
                  label: labelBuilder(options[i]),
                  isSelected: options[i] == selected,
                  onTap: () => Navigator.of(sheetContext).pop(options[i]),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

/// [_PickerOptionRow] renders an option element.
/// The selected element is marked with a circle dot at the left site of
/// the label.
class _PickerOptionRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerOptionRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const double _dotSize = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.rowVertical),
        child: Row(
          children: [
            if (isSelected) ...[
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  color: colors.textPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.gapMedium),
            ],
            Expanded(
              child: Text(
                label,
                style: AppTypography.serifValue.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
