import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// A selectable row with a leading selection dot and either a single label
/// or a title/subtitle pair.
class SelectableOptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const SelectableOptionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  static const double _dotSize = 6.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = this.subtitle;
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.rowVertical),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: _dotSize,
                  height: _dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? colors.textPrimary : null,
                    border: Border.all(
                      color: selected
                          ? colors.textPrimary
                          : colors.borderStrong,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.gapMedium),
              Expanded(
                child: subtitle == null
                    ? Text(
                        title,
                        style: AppTypography.serifValue.copyWith(
                          color: colors.textPrimary,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTypography.bodySans.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.gapSmall),
                          Text(
                            subtitle,
                            style: AppTypography.captionSans.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
