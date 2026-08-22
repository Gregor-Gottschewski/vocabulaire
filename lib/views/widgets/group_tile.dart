import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/app_language.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/vocabulary_group.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// A flat, hairline-bordered row representing a group in a list.
class GroupTile extends StatelessWidget {
  final VocabularyGroup group;
  final int boxCount;
  final VoidCallback onTap;

  const GroupTile({
    super.key,
    required this.group,
    required this.boxCount,
    required this.onTap,
  });

  String _subtitle(AppLocalizations l10n) {
    if (group.boxType != BoxType.vocabulary) {
      return l10n.groupTypeFlashcardTitle;
    }
    final source = AppLanguage.fromCode(group.sourceLanguage)?.displayName(l10n) ?? group.sourceLanguage ?? '';
    final target = AppLanguage.fromCode(group.targetLanguage)?.displayName(l10n) ?? group.targetLanguage ?? '';
    return '$source → $target';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.rowVertical),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      group.name,
                      style: AppTypography.bodySans.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.gapSmall),
                    Text(
                      _subtitle(l10n),
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
                l10n.groupTileBoxCount(boxCount),
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
