import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// Centered, underlined secondary action
class TextLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const TextLinkButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.colors.textLink;
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gapMedium),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTypography.linkSans.copyWith(color: color),
                  ),
                  const SizedBox(height: 3),
                  Container(height: AppSpacing.hairline, color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
