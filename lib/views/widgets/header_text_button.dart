import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// Text button for menu bar action button.
class HeaderTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const HeaderTextButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: Text(
            label,
            style: AppTypography.captionSans.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
