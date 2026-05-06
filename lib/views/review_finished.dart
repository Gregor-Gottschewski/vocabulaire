import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';

/// View shown when a review session is completed.
class ReviewFinishedView extends StatelessWidget {
  final VocabularyBox box;
  final dynamic boxKey;

  const ReviewFinishedView({
    super.key,
    required this.box,
    required this.boxKey,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Lernen beendet'),
        previousPageTitle: 'Zurück',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: double.infinity,
              height: 260,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CupertinoColors.systemGrey4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Alle Karten gelernt!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  CupertinoButton.filled(
                    color: CupertinoColors.activeBlue,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Zur Box'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}