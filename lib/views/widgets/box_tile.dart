import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/review_session.dart';
import 'package:vocabulaire/views/widgets/text_link_button.dart';

import '../../models/vocabulary_box.dart';
import '../../theme/app_page_route.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';
import '../review_view.dart';
import 'due_refresh_mixin.dart';

/// A flat, hairline-bordered row representing a box in a list.
class BoxTile extends StatefulWidget {
  final VocabularyBox box;
  final VoidCallback onTap;

  const BoxTile({super.key, required this.box, required this.onTap});

  @override
  State<BoxTile> createState() => _BoxTileState();
}

class _BoxTileState extends State<BoxTile> with DueRefreshMixin<BoxTile> {
  VoidCallback? _startSession(BuildContext context) {
    final box = widget.box;
    final matchingCards = ReviewSession.filterVocabularies(
      box.vocabularies,
      onlyTimely: true,
      method: LearningMethod.all,
      dailyLimitEnabled: box.dailyLimitEnabled,
      remainingNewCards: box.remainingNewCardsToday,
    );

    if (matchingCards.isEmpty) return null;

    return () {
      Navigator.of(context).push(
        AppPageRoute(
          builder: (_) => ReviewView(
            boxKey: box.id,
            onlyTimely: true,
            learningMethod: LearningMethod.all,
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final colors = context.colors;
    final box = widget.box;

    scheduleDueRebuild(box.vocabularies);

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: widget.onTap,
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
                          : l10n.boxTileNoDescription,
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
                l10n.cardsCounter(box.vocabularies.length),
                style: AppTypography.serifValue.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              TextLinkButton(
                label: l10n.boxDetailStart,
                onPressed: _startSession(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
