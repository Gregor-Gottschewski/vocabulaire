import 'package:flutter/cupertino.dart';
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
  bool _onlyTimely = true;
  LearningMethod _selectedOption = LearningMethod.all;

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
            Text(
              "Beschreibung",
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            Text(widget.box.description, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 16),

            Text(
              "Optionen",
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),

            _buildToggleRow("Zeitlich anstehende Vokabeln", _onlyTimely, (v) {
              setState(() => _onlyTimely = v);
            }),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lernmethode",
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoSegmentedControl<LearningMethod>(
                    groupValue: _selectedOption,
                    children: {
                      for (final method in LearningMethod.values)
                        method: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                          child: Text(method.displayName),
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
                                  boxKeys: [widget.boxKey],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(CupertinoIcons.book, size: 20.0),
                              SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  'Vokabeln bearbeiten',
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
                                builder: (_) =>
                                    ReviewView(
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
                            children: const [
                              Icon(CupertinoIcons.play, size: 20.0),
                              SizedBox(width: 8.0),
                              Flexible(
                                child: Text(
                                  'Start',
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
