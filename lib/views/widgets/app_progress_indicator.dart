import 'package:flutter/material.dart';

import '../../theme/theme_context_ext.dart';

/// Spinner as loading indicator.
class AppProgressIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const AppProgressIndicator({super.key, this.size = 18, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(color ?? context.colors.textPrimary),
      ),
    );
  }
}
