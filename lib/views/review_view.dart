import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fsrs/fsrs.dart' hide State;
import 'package:vocabulaire/controllers/review_controller.dart';
import 'package:vocabulaire/models/review_session.dart';
import 'package:vocabulaire/views/review_finished.dart';

class ReviewView extends StatefulWidget {
  final dynamic boxKey;
  final bool onlyTimely;
  final LearningMethod learningMethod;

  const ReviewView({
    super.key,
    required this.boxKey,
    required this.onlyTimely,
    required this.learningMethod,
  });

  @override
  State<ReviewView> createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  late final ReviewController reviewController;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    reviewController = ReviewController(
      boxKey: widget.boxKey,
      onlyTimely: widget.onlyTimely,
      learningMethod: widget.learningMethod,
    );
    reviewController.addListener(_onControllerUpdate);
    reviewController.load();
  }

  void _onControllerUpdate() {
    if (reviewController.box == null) {
      Navigator.of(context).pop();
      return;
    }

    if (reviewController.isFinished) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (_) => ReviewFinishedView(
              box: reviewController.box!,
              boxKey: widget.boxKey,
            ),
          ),
        );
      });
      return;
    }

    setState(() {});
  }

  Widget _buildCardView() {
    final current = reviewController.current;
    if (current == null) {
      return const SizedBox(
        width: double.infinity,
        height: 260,
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    final front = current.word;
    final back = current.meaning;
    final example = current.example.isNotEmpty
        ? '\n\nBeispiel: ${current.example}'
        : '';

    return GestureDetector(
      onTap: () => setState(() => _flipped = !_flipped),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            RotationTransition(turns: animation, child: child),
        child: Container(
          key: ValueKey(_flipped),
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
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_flipped)
                    Text(
                      front,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  else
                    Column(
                      children: [
                        Text(
                          back,
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        if (example.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              example,
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Again
            Expanded(
              child: CupertinoButton.filled(
                color: CupertinoColors.destructiveRed,
                onPressed: () => {
                  reviewController.applyRating(Rating.again),
                  _flipped = false,
                },
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.xmark, size: 20),
                    SizedBox(width: 8),
                    Text('Nochmal'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Hard
            Expanded(
              child: CupertinoButton.filled(
                color: CupertinoColors.systemYellow,
                onPressed: () => {
                  reviewController.applyRating(Rating.hard),
                  _flipped = false,
                },
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.exclamationmark, size: 20),
                    SizedBox(width: 8),
                    Text('Schwer'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Good
            Expanded(
              child: CupertinoButton.filled(
                color: Color.fromARGB(255, 0, 100, 0),
                onPressed: () => {
                  reviewController.applyRating(Rating.good),
                  _flipped = false,
                },
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.smiley, size: 20),
                    SizedBox(width: 8),
                    Text('Gut'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Easy
            Expanded(
              child: CupertinoButton.filled(
                color: CupertinoColors.systemGreen,
                onPressed: () => {
                  reviewController.applyRating(Rating.easy),
                  _flipped = false,
                },
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.check_mark_circled, size: 20),
                    SizedBox(width: 8),
                    Text('Einfach'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Skip
        SizedBox(
          width: double.infinity,
          child: CupertinoButton.tinted(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(CupertinoIcons.forward, size: 20),
                SizedBox(width: 8),
                Text('Überspringen'),
              ],
            ),
            onPressed: () {
              reviewController.skip();
              _flipped = false;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = reviewController.length;
    final indexDisplay = total == 0 ? 0 : (reviewController.index + 1);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lernen'),
        previousPageTitle: 'Zurück',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Karte $indexDisplay / $total',
                style: const TextStyle(color: CupertinoColors.systemGrey),
              ),
              const SizedBox(height: 12),
              Expanded(child: Center(child: _buildCardView())),
              const SizedBox(height: 12),
              _ratingButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
