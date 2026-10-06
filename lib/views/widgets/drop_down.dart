import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// Compact drop-down showing the selected value; opens a popup menu on tap.
class DropDown<T> extends StatelessWidget {
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  const DropDown({
    super.key,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: onChanged,
      padding: EdgeInsets.zero,
      color: colors.background,
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final v in values)
          PopupMenuItem<T>(
            value: v,
            child: Text(
              labelOf(v),
              style: AppTypography.labelSans.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelOf(value),
            style: AppTypography.serifValue.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(width: 4),
          Icon(Icons.expand_more, size: 18, color: colors.textSecondary),
        ],
      ),
    );
  }
}
