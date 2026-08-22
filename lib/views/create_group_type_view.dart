import 'package:flutter/material.dart';
import 'package:vocabulaire/controllers/group_draft.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/theme/app_page_route.dart';
import 'package:vocabulaire/theme/app_spacing.dart';
import 'package:vocabulaire/theme/app_typography.dart';
import 'package:vocabulaire/theme/theme_context_ext.dart';
import 'package:vocabulaire/views/create_group_detail_view.dart';
import 'package:vocabulaire/views/widgets/app_scaffold.dart';
import 'package:vocabulaire/views/widgets/key_value_row.dart';
import 'package:vocabulaire/views/widgets/selectable_option_card.dart';
import 'package:vocabulaire/views/widgets/header_text_button.dart';

/// Step 1 of the group-creation flow: choose the group's type. Unlike boxes,
/// groups have no import option — the type is fixed for the group's
/// lifetime once chosen here.
class CreateGroupTypeView extends StatefulWidget {
  final GroupDraft draft;

  const CreateGroupTypeView({super.key, required this.draft});

  @override
  State<CreateGroupTypeView> createState() => _CreateGroupTypeViewState();
}

class _CreateGroupTypeViewState extends State<CreateGroupTypeView> {
  late BoxType _selected;
  late AppLocalizations _l10n;

  @override
  void initState() {
    super.initState();
    _selected = widget.draft.type;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  void _onNext() {
    widget.draft.type = _selected;
    Navigator.of(context).push(
      AppPageRoute(builder: (_) => CreateGroupDetailView(draft: widget.draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppScaffold(
      backLabel: _l10n.commonCancel,
      onBack: () => Navigator.of(context, rootNavigator: true).pop(),
      actions: [
        HeaderTextButton(label: "${_l10n.commonNext} →", onPressed: _onNext),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.createGroupTypeTitle,
            style: AppTypography.headlineSerif.copyWith(
              fontSize: 24,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.gapSmall),
          Text(
            _l10n.createGroupTypeSubtitle,
            style: AppTypography.bodySans.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          KeyValueRowGroup(
            children: [
              SelectableOptionCard(
                title: _l10n.groupTypeVocabularyTitle,
                subtitle: _l10n.groupTypeVocabularySubtitle,
                selected: _selected == BoxType.vocabulary,
                onTap: () => setState(() => _selected = BoxType.vocabulary),
              ),
              SelectableOptionCard(
                title: _l10n.groupTypeFlashcardTitle,
                subtitle: _l10n.groupTypeFlashcardSubtitle,
                selected: _selected == BoxType.flashcard,
                onTap: () => setState(() => _selected = BoxType.flashcard),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
