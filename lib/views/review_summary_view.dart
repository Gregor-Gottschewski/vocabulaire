import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'widgets/app_scaffold.dart';

/// Shown after a review session finished. Pops with `true` if the user wants
/// to continue with the next session, otherwise with `false`.
class ReviewSummaryView extends StatelessWidget {
  final int ratedCount;
  final bool hasNext;

  const ReviewSummaryView({
    super.key,
    required this.ratedCount,
    required this.hasNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final close = hasNext ? l10n.reviewCancel : l10n.finish;

    return AppScaffold(
      onBack: () => Navigator.of(context).pop(false),
      backLabel: close,
      actions: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(hasNext),
          behavior: HitTestBehavior.opaque,
          child: Text(
            '${hasNext ? l10n.reviewContinue : l10n.finish} →',
            style: AppTypography.linkSans.copyWith(color: colors.textLink),
          ),
        ),
      ],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ratedCount > 0) ...[
              Text(
                l10n.reviewSummaryTitle(ratedCount),
                textAlign: TextAlign.center,
                style: AppTypography.headlineSerif.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.gapMedium),
            ],
            Text(
              hasNext ? l10n.reviewSummaryNext : l10n.reviewNothingLeft,
              textAlign: TextAlign.center,
              style: AppTypography.labelSans.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
