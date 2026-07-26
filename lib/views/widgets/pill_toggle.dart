import 'package:flutter/widgets.dart';

import '../../theme/app_spacing.dart';
import '../../theme/theme_context_ext.dart';

/// Pill toggle, replaces CupertinoSwitch. Green track when on, red when off.
class PillToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const PillToggle({super.key, required this.value, this.onChanged});

  static const double _width = 38;
  static const double _height = 22;
  static const double _thumbSize = 16;
  static const double _inset = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final trackColor = value ? colors.ratingEasy : colors.danger;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: _width,
        height: _height,
        padding: const EdgeInsets.all(_inset),
        decoration: BoxDecoration(
          color: trackColor,
          border: Border.all(color: trackColor, width: AppSpacing.hairline),
          borderRadius: BorderRadius.circular(_height / 2),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: _thumbSize,
            height: _thumbSize,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
