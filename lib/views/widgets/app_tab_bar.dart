import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// Text-only bottom tab bar.
class AppTabBar extends StatelessWidget {
  final List<String> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(
            top: BorderSide(
              color: colors.borderStrong,
              width: AppSpacing.hairline,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: Center(
                        child: Text(
                          items[i],
                          style:
                              (i == currentIndex
                                      ? AppTypography.serifValue
                                      : AppTypography.bodySans.copyWith(
                                          fontSize: 14,
                                        ))
                                  .copyWith(
                                    color: i == currentIndex
                                        ? colors.textPrimary
                                        : colors.textSecondary,
                                  ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
