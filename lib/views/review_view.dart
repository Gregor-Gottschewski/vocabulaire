import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:fsrs/fsrs.dart' hide State;
import 'package:vocabulaire/controllers/review_controller.dart';
import 'package:vocabulaire/models/review_session.dart';
import 'package:vocabulaire/services/app_paths.dart';

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
  final player = AudioPlayer();
  late AppLocalizations _l10n;
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

  @override
  void dispose() {
    reviewController.removeListener(_onControllerUpdate);
    reviewController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
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
        Navigator.of(context).pop();
      });
      return;
    }

    if (!mounted) return;
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
    final exampleText = current.example;
    final hasRecording = AppPaths.audioFile(current.id).existsSync();

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
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemBackground,
              context,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey4,
                context,
              ),
            ),
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
                        if (exampleText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _l10n.reviewExample(exampleText),
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (hasRecording) ...[
                          const SizedBox(height: 16),
                          CupertinoButton.filled(
                            onPressed: _playAudio,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.play_arrow_solid,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(_l10n.reviewPlay),
                              ],
                            ),
                          ),
                        ],
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

  void _playAudio() async {
    final current = reviewController.current;
    if (current == null) return;
    await player.play(DeviceFileSource(AppPaths.audioFilePath(current.id)));
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
                  children: [
                    const Icon(CupertinoIcons.xmark, size: 20),
                    const SizedBox(width: 8),
                    Text(_l10n.reviewAgain),
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
                  children: [
                    const Icon(CupertinoIcons.exclamationmark, size: 20),
                    const SizedBox(width: 8),
                    Text(_l10n.reviewHard),
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
                  children: [
                    const Icon(CupertinoIcons.smiley, size: 20),
                    const SizedBox(width: 8),
                    Text(_l10n.reviewGood),
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
                  children: [
                    const Icon(CupertinoIcons.check_mark_circled, size: 20),
                    const SizedBox(width: 8),
                    Text(_l10n.reviewEasy),
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
              children: [
                const Icon(CupertinoIcons.forward, size: 20),
                const SizedBox(width: 8),
                Text(_l10n.reviewSkip),
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
        middle: Text(_l10n.reviewTitle),
        previousPageTitle: _l10n.reviewBack,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _l10n.reviewCard(indexDisplay, total),
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
