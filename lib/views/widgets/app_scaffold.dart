import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// Top page bar with back-button, title and additional buttons.
class AppScaffold extends StatelessWidget {
  final String? backLabel;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget body;
  final bool scrollable;

  const AppScaffold({
    super.key,
    this.backLabel,
    this.onBack,
    this.actions = const [],
    required this.body,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.headerTopGap,
            AppSpacing.pageHorizontal,
            0,
          ),
          child: SizedBox(
            height: AppSpacing.headerRowHeight,
            child: Row(
              children: [
                Expanded(
                  child: backLabel == null
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: onBack ?? () => Navigator.of(context).maybePop(),
                          behavior: HitTestBehavior.opaque,
                          child: Text(
                            '← $backLabel',
                            style: AppTypography.captionSans.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                ),
                for (final action in actions) ...[
                  const SizedBox(width: AppSpacing.gapMedium),
                  action,
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal,
              AppSpacing.contentTop,
              AppSpacing.pageHorizontal,
              AppSpacing.contentBottom,
            ),
            child: scrollable ? SingleChildScrollView(child: body) : body,
          ),
        ),
      ],
    );

    return Material(
      color: colors.background,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: content,
        ),
      ),
    );
  }
}
