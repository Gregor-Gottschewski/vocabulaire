import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/views/review_view.dart';

import '../models/review_session.dart';
import '../models/vocabulary.dart';
import '../models/vocabulary_box.dart';
import '../theme/app_page_route.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'vocabulary_list_view.dart';
import 'widgets/app_bottom_sheet.dart';
import 'widgets/daily_limit_stepper.dart';
import 'widgets/key_value_row.dart';
import 'widgets/pill_toggle.dart';
import 'widgets/primary_action_button.dart';
import 'widgets/selectable_option_card.dart';
import 'widgets/text_link_button.dart';

/// The [BoxDetailView] contains a box description, review options, start
/// session button and edit vocabulary list button.
class BoxDetailView extends StatefulWidget {
  final VocabularyBox box;
  final String boxKey;

  const BoxDetailView({super.key, required this.box, required this.boxKey});

  @override
  State<BoxDetailView> createState() => _BoxDetailWidget();
}

class _BoxDetailWidget extends State<BoxDetailView> {
  late final ValueNotifier<List<MapEntry<String, VocabularyBox>>> _boxNotifier;
  late AppLocalizations _l10n;
  bool _onlyTimely = true;
  LearningMethod _selectedOption = LearningMethod.all;
  bool _dailyLimitEnabled = false;
  int _dailyLimit = 20;
  Timer? _dueRefreshTimer;
  DateTime? _scheduledDueRefresh;

  @override
  void initState() {
    super.initState();
    _boxNotifier = BoxController().listenableForKeys([widget.boxKey]);
    _dailyLimitEnabled = widget.box.dailyLimitEnabled;
    _dailyLimit = widget.box.dailyLimit;
  }

  /// Persists the daily-limit settings, reading the box fresh from
  /// [BoxController] rather than relying on the possibly stale [widget.box].
  void _persistDailyLimit({bool? enabled, int? limit}) {
    final current = BoxController().getBox(widget.boxKey) ?? widget.box;
    final updated = current.copyWith(
      dailyLimitEnabled: enabled,
      dailyLimit: limit,
    );
    BoxController().updateBox(widget.boxKey, updated);
  }

  @override
  void dispose() {
    _dueRefreshTimer?.cancel();
    _boxNotifier.dispose();
    super.dispose();
  }

  /// Schedules a rebuild for the next moment a vocabulary in [vocabularies]
  /// transitions from not-due to due
  void _scheduleRebuild(List<Vocabulary> vocabularies) {
    final now = DateTime.now();
    DateTime? nextDue;
    for (final v in vocabularies) {
      if (v.card.due.isAfter(now)) {
        if (nextDue == null || v.card.due.isBefore(nextDue)) {
          nextDue = v.card.due;
        }
      }
    }

    if (nextDue == _scheduledDueRefresh) return;

    _dueRefreshTimer?.cancel();
    _scheduledDueRefresh = nextDue;
    if (nextDue == null) return;

    final delay = nextDue.difference(now);
    _dueRefreshTimer = Timer(delay.isNegative ? Duration.zero : delay, () {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<void> _pickMethod() async {
    final result = await showAppPicker<LearningMethod>(
      context: context,
      title: _l10n.boxDetailMethod,
      children: [
        for (final method in LearningMethod.values)
          SelectableOptionCard(
            title: method.label(_l10n),
            selected: method == _selectedOption,
            onTap: () => Navigator.of(context).pop(method),
          ),
      ],
    );
    if (result != null) setState(() => _selectedOption = result);
  }

  Future<void> _editDailyLimit() async {
    var enabled = _dailyLimitEnabled;
    var limit = _dailyLimit;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final colors = sheetContext.colors;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.sectionGap,
                  AppSpacing.pageHorizontal,
                  AppSpacing.sectionGap,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _l10n.boxDetailDailyLimitEnable,
                            style: AppTypography.bodySans.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        PillToggle(
                          value: enabled,
                          onChanged: (v) => setSheetState(() => enabled = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    Opacity(
                      opacity: enabled ? 1 : 0.35,
                      child: IgnorePointer(
                        ignoring: !enabled,
                        child: DailyLimitStepper(
                          value: limit,
                          onChanged: (v) => setSheetState(() => limit = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    setState(() {
      _dailyLimitEnabled = enabled;
      _dailyLimit = limit;
    });
    _persistDailyLimit(enabled: enabled, limit: limit);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final box = widget.box;

    _scheduleRebuild(box.vocabularies);

    final hasMatchingCards = ReviewSession.filterVocabularies(
      box.vocabularies,
      onlyTimely: _onlyTimely,
      method: _selectedOption,
      dailyLimitEnabled: box.dailyLimitEnabled,
      remainingNewCards: box.remainingNewCardsToday,
    ).isNotEmpty;

    final dueCount = ReviewSession.dueVocabularyCount(box);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          box.name,
          style: AppTypography.headlineSerif.copyWith(
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _l10n.boxDetailSubline(box.vocabularies.length, dueCount),
          style: AppTypography.captionSans.copyWith(
            color: colors.textSecondary,
          ),
        ),
        if (box.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          Text(
            _l10n.boxDetailDescription,
            style: AppTypography.labelSans.copyWith(color: colors.textLabel),
          ),
          const SizedBox(height: 6),
          Text(
            box.description,
            style: AppTypography.bodySans.copyWith(color: colors.textPrimary),
          ),
        ],
        const SizedBox(height: AppSpacing.sectionGap),
        KeyValueRowGroup(
          children: [
            KeyValueRow.toggle(
              label: _l10n.boxDetailDueVocabs,
              value: _onlyTimely,
              onChanged: (v) => setState(() => _onlyTimely = v),
            ),
            KeyValueRow.value(
              label: _l10n.boxDetailMethod,
              value: _selectedOption.label(_l10n),
              onTap: _pickMethod,
            ),
            KeyValueRow.value(
              label: _l10n.boxDetailDailyLimit,
              value: _dailyLimitEnabled
                  ? _l10n.boxDetailDailyLimitValue(_dailyLimit)
                  : _l10n.boxDetailDailyLimitOff,
              onTap: _editDailyLimit,
            ),
          ],
        ),
        const Spacer(),
        Column(
          children: [
            PrimaryActionButton(
              label: _l10n.boxDetailStart,
              onPressed: hasMatchingCards
                  ? () {
                      Navigator.of(context).push(
                        AppPageRoute(
                          builder: (_) => ReviewView(
                            boxKey: widget.boxKey,
                            onlyTimely: _onlyTimely,
                            learningMethod: _selectedOption,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
            TextLinkButton(
              label: _l10n.boxDetailEditVocabs,
              onPressed: () {
                Navigator.of(context).push(
                  AppPageRoute(
                    builder: (_) => VocabularyListView(
                      multipleBoxes: false,
                      boxListenable: _boxNotifier,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
