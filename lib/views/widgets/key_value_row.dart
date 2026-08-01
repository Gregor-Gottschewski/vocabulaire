import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';
import 'pill_toggle.dart';

/// A label/value row for the hairline-bordered key-value blocks.
class KeyValueRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;

  const KeyValueRow({
    super.key,
    required this.label,
    required this.trailing,
    this.onTap,
  });

  factory KeyValueRow.toggle({
    Key? key,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return KeyValueRow(
      key: key,
      label: label,
      trailing: PillToggle(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }

  factory KeyValueRow.value({
    Key? key,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return KeyValueRow(
      key: key,
      label: label,
      trailing: _RowValueText(value),
      onTap: onTap,
    );
  }

  factory KeyValueRow.submenu(
    BuildContext context, {
    Key? key,
    required String label,
    required VoidCallback? onTap,
  }) {
    return KeyValueRow(
      key: key,
      label: label,
      trailing: Text(
        "→",
        style: AppTypography.captionSans.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.rowVertical),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelSans.copyWith(
                color: context.colors.textLabel,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.gapMedium),
          trailing,
        ],
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: onTap == null
          ? row
          : GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: row,
            ),
    );
  }
}

class _RowValueText extends StatelessWidget {
  final String value;

  const _RowValueText(this.value);

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: AppTypography.serifValue.copyWith(
        color: context.colors.textPrimary,
      ),
    );
  }
}

class KeyValueRowGroup extends StatelessWidget {
  final List<Widget> children;

  const KeyValueRowGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1)
            Container(height: AppSpacing.hairline, color: colors.borderSubtle),
        ],
        Container(height: AppSpacing.hairline, color: colors.borderStrong),
      ],
    );
  }
}
