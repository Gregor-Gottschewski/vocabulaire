import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/controllers/create_box_draft.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/models/box_color.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/views/create_box_detail_view.dart';
import 'package:vocabulaire/views/widgets/primary_action_button.dart';
import 'package:vocabulaire/views/widgets/selectable_option_card.dart';

/// Step 1 of the box-creation flow: choose between a vocabulary box and a
/// flashcard box.
class CreateBoxTypeView extends StatefulWidget {
  final CreateBoxDraft draft;

  const CreateBoxTypeView({super.key, required this.draft});

  @override
  State<CreateBoxTypeView> createState() => _CreateBoxTypeViewState();
}

class _CreateBoxTypeViewState extends State<CreateBoxTypeView> {
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
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => CreateBoxDetailView(draft: widget.draft)));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_l10n.createBoxNavTitle),
        padding: const EdgeInsetsDirectional.only(start: 0.0),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.createBoxTypeTitle,
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                _l10n.createBoxTypeSubtitle,
                style: TextStyle(
                  fontSize: 14.0,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey,
                    context,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              SelectableOptionCard(
                icon: CupertinoIcons.globe,
                iconBackgroundColor: Color(BoxColor.purple.argb),
                title: BoxType.vocabulary.title(_l10n),
                subtitle: BoxType.vocabulary.subtitle(_l10n),
                selected: _selected == BoxType.vocabulary,
                selectedColor: Color(BoxColor.purple.argb),
                onTap: () => setState(() => _selected = BoxType.vocabulary),
              ),
              const SizedBox(height: 12.0),
              SelectableOptionCard(
                icon: CupertinoIcons.folder,
                iconBackgroundColor: Color(BoxColor.orange.argb),
                title: BoxType.flashcard.title(_l10n),
                subtitle: BoxType.flashcard.subtitle(_l10n),
                selected: _selected == BoxType.flashcard,
                selectedColor: Color(BoxColor.orange.argb),
                onTap: () => setState(() => _selected = BoxType.flashcard),
              ),
              const Spacer(),
              PrimaryActionButton(label: _l10n.commonNext, onPressed: _onNext),
            ],
          ),
        ),
      ),
    );
  }
}
