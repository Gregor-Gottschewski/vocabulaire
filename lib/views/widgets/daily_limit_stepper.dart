import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// Stepper for daily new-card limit.
class DailyLimitStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  const DailyLimitStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Material(
      type: MaterialType.transparency,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StepButton(
            label: '−',
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          const SizedBox(width: 24),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$value ',
                  style: AppTypography.headlineSerif.copyWith(
                    fontSize: 20,
                    color: colors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: l10n.boxDetailNewCardsPerDay,
                  style: AppTypography.captionSans.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 24),
          _StepButton(label: '+', onPressed: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _StepButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: disabled ? colors.borderStrong : colors.textPrimary,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.headlineSerif.copyWith(
            fontSize: 20,
            color: disabled ? colors.borderStrong : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
