import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocabulaire/controllers/settings_controller.dart';
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
  late final ReviewController _reviewController;
  final _settingsController = SettingsController();
  final _player = AudioPlayer();
  late AppLocalizations _l10n;
  bool _flipped = false;
  bool _wasFinished = false;

  @override
  void initState() {
    super.initState();
    _reviewController = ReviewController(
      boxKey: widget.boxKey,
      onlyTimely: widget.onlyTimely,
      learningMethod: widget.learningMethod,
    );
    _reviewController.addListener(_onControllerUpdate);
    _reviewController.load();
  }

  @override
  void dispose() {
    _reviewController.removeListener(_onControllerUpdate);
    _reviewController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  /// Reloads the state on change of list.
  /// Navigates the user back if session finished.
  /// Because this function can be called multiple times after session finish, only the first call results in back navigation.
  void _onControllerUpdate() {
    final isFinished =
        _reviewController.box == null || _reviewController.isFinished;

    if (isFinished) {
      if (_wasFinished) return;
      _wasFinished = true;
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
    final current = _reviewController.current;
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
    final bool animation = _settingsController.getCardAnimations();

    return GestureDetector(
      onTap: () => setState(() => _flipped = !_flipped),
      child: AnimatedSwitcher(
        duration: animation ? const Duration(milliseconds: 300) : Duration.zero,
        transitionBuilder: animation
            ? (child, animation) =>
                  RotationTransition(turns: animation, child: child)
            : (child, _) => child,
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
    final current = _reviewController.current;
    if (current == null) return;
    await _player.play(DeviceFileSource(AppPaths.audioFilePath(current.id)));
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
                  _reviewController.applyRating(Rating.again),
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
                  _reviewController.applyRating(Rating.hard),
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
                  _reviewController.applyRating(Rating.good),
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
                  _reviewController.applyRating(Rating.easy),
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
              _reviewController.skip();
              _flipped = false;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _reviewController.length;
    final indexDisplay = total == 0 ? 0 : (_reviewController.index + 1);

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
