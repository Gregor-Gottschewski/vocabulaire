import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';
import 'app_progress_indicator.dart';

/// Full-width square primary action button
class PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fillWidth;

  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fillWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onPressed == null || isLoading;
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: fillWidth ? double.infinity : null,
        child: GestureDetector(
          onTap: disabled ? null : onPressed,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.buttonVertical,
              horizontal: AppSpacing.gapLarge,
            ),
            color: disabled
                ? colors.textPrimary.withValues(alpha: 0.35)
                : colors.textPrimary,
            alignment: fillWidth ? Alignment.center : null,
            child: isLoading
                ? AppProgressIndicator(color: colors.background)
                : Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppTypography.serifButton.copyWith(
                      color: colors.background,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
