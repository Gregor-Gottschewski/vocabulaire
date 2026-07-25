import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

/// Widget for daily limit stepper.
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepButton(
          icon: CupertinoIcons.minus,
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        const SizedBox(width: 24),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$value ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.label,
                    context,
                  ),
                ),
              ),
              TextSpan(
                text: l10n.boxDetailNewCardsPerDay,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel,
                    context,
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(width: 24),
        _StepButton(icon: CupertinoIcons.plus, onPressed: () => onChanged(value + 1)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      onPressed: onPressed,
      child: Icon(icon, size: 24),
    );
  }
}
