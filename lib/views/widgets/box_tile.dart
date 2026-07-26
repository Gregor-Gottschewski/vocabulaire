import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import '../../models/vocabulary_box.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// A flat, hairline-bordered row representing a box in a list.
class BoxTile extends StatelessWidget {
  final VocabularyBox box;
  final VoidCallback onTap;

  const BoxTile({super.key, required this.box, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.borderSubtle,
                width: AppSpacing.hairline,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.rowVertical,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      box.name,
                      style: AppTypography.bodySans.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.gapSmall),
                    Text(
                      box.description.isNotEmpty
                          ? box.description
                          : AppLocalizations.of(context)!.boxTileNoDescription,
                      style: AppTypography.captionSans.copyWith(
                        color: colors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.gapMedium),
              Text(
                AppLocalizations.of(context)!.cardsCounter(box.vocabularies.length),
                style: AppTypography.serifValue.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
