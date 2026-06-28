import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/views/review_view.dart';

import '../models/vocabulary_box.dart';
import 'vocabulary_list_view.dart';
import '../models/review_session.dart';

/// View for displaying details of a vocabulary box, including description and options for review sessions.
class BoxDetailView extends StatefulWidget {
  final VocabularyBox box;
  final dynamic boxKey;

  const BoxDetailView({super.key, required this.box, required this.boxKey});

  @override
  State<BoxDetailView> createState() => _BoxDetailWidget();
}

class _BoxDetailWidget extends State<BoxDetailView> {
  late final ValueNotifier<List<MapEntry<dynamic, VocabularyBox>>> _boxNotifier;
  late AppLocalizations _l10n;
  bool _onlyTimely = true;
  LearningMethod _selectedOption = LearningMethod.all;

  @override
  void initState() {
    super.initState();
    _boxNotifier = BoxController().listenableForKeys([widget.boxKey]);
  }

  @override
  void dispose() {
    _boxNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  /// Builds a row with a label and a CupertinoSwitch for toggling options.
  Widget _buildToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 16))),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CupertinoSwitch(value: value, onChanged: onChanged),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.box.description.isNotEmpty) ...[
              Text(
                _l10n.boxDetailDescription,
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Text(widget.box.description, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 16),
            ],

            Text(
              _l10n.boxDetailOptions,
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),

            _buildToggleRow(_l10n.boxDetailDueVocabs, _onlyTimely, (v) {
              setState(() => _onlyTimely = v);
            }),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.boxDetailMethod,
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoSegmentedControl<LearningMethod>(
                    unselectedColor: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemBackground,
                      context,
                    ),
                    groupValue: _selectedOption,
                    children: {
                      for (final method in LearningMethod.values)
                        method: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 5.0,
                          ),
                          child: Text(method.label(_l10n)),
                        ),
                    },
                    onValueChanged: (LearningMethod value) {
                      setState(() => _selectedOption = value);
                    },
                  ),
                ],
              ),
            ),

            // Page end
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          color: CupertinoColors.activeOrange,
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => VocabularyListView(
                                  multipleBoxes: false,
                                  boxListenable: _boxNotifier,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(CupertinoIcons.book, size: 20.0),
                              const SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  _l10n.boxDetailEditVocabs,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          color: CupertinoColors.activeGreen,
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (_) => ReviewView(
                                  boxKey: widget.boxKey,
                                  onlyTimely: _onlyTimely,
                                  learningMethod: _selectedOption,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(CupertinoIcons.play, size: 20.0),
                              const SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  _l10n.boxDetailStart,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
