import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vocabulaire/controllers/settings_controller.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:fsrs/fsrs.dart' hide State;
import 'package:vocabulaire/controllers/review_controller.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/models/review_session.dart';
import 'package:vocabulaire/models/vocabulary.dart';
import 'package:vocabulaire/services/app_paths.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'widgets/app_progress_indicator.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/section_title.dart';
import 'widgets/text_link_button.dart';

class ReviewView extends StatefulWidget {
  final String boxKey;
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

class _ReviewViewState extends State<ReviewView>
    with SingleTickerProviderStateMixin {
  late final ReviewController _reviewController;
  late final AnimationController _flipController;
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
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _reviewController.removeListener(_onControllerUpdate);
    _reviewController.dispose();
    _flipController.dispose();
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

  bool get _cardAnimationsEnabled => _settingsController.getCardAnimations();

  void _reveal() {
    setState(() => _flipped = true);
    if (_cardAnimationsEnabled) {
      _flipController.forward();
    } else {
      _flipController.value = 1;
    }
  }

  void _resetFlip() {
    _flipped = false;
    _flipController.value = 0;
  }

  void _playAudio() async {
    final current = _reviewController.current;
    if (current == null) return;
    await _player.play(DeviceFileSource(AppPaths.audioFilePath(current.id)));
  }

  void _rate(Rating rating) {
    _resetFlip();
    _reviewController.applyRating(rating);
  }

  void _skip() {
    _resetFlip();
    _reviewController.skip();
  }

  Widget _buildHeader(int index, int indexDisplay, int total, bool showListen) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _ProgressBar(value: total == 0 ? 0.0 : index / total),
            ),
            const SizedBox(width: AppSpacing.gapMedium),
            Text(
              _l10n.reviewCard(indexDisplay, total),
              style: AppTypography.captionSans.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gapSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showListen)
              GestureDetector(
                onTap: _playAudio,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, size: 18, color: colors.highlight),
                    const SizedBox(width: AppSpacing.gapSmall),
                    Text(
                      _l10n.reviewPlay,
                      style: AppTypography.captionSans.copyWith(
                        color: colors.highlight,
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox.shrink(),
            // TextLinkButton carries its own EdgeInsets.all(gapMedium) hit
            // padding (intentional, larger tap target). Shift it right by
            // that amount so its visible edge lines up with the progress
            // bar/label above instead of shrinking the tap target
            Transform.translate(
              offset: const Offset(AppSpacing.gapMedium, 0),
              child: TextLinkButton(label: _l10n.reviewSkip, onPressed: _skip),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(Vocabulary current, bool isVocabularyBox) {
    final colors = context.colors;
    final showBackLabel = isVocabularyBox
        ? _l10n.reviewShowTranslation
        : _l10n.reviewShowBack;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              current.word,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSerif.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
        if (!_flipped) ...[
          const SizedBox(height: AppSpacing.sectionGap),
          TextLinkButton(label: showBackLabel, onPressed: _reveal),
        ],
        SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: _flipController,
            curve: Curves.easeOut,
          ),
          alignment: Alignment.topCenter,
          child: FadeTransition(
            opacity: _flipController,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: AppSpacing.hairline,
                    color: colors.borderStrong,
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        current.meaning,
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineSerif.copyWith(
                          fontSize: 22,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (current.example.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.gapMedium),
                    Text(
                      _l10n.reviewExample(current.example),
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSans.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(text: _l10n.reviewRatingQuestion),
        const SizedBox(height: AppSpacing.gapLarge),
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                label: _l10n.reviewAgain,
                color: colors.ratingAgain,
                textColor: colors.background,
                onPressed: () => _rate(Rating.again),
              ),
            ),
            const SizedBox(width: AppSpacing.gapSmall),
            Expanded(
              child: _RatingButton(
                label: _l10n.reviewHard,
                color: colors.ratingHard,
                textColor: colors.background,
                onPressed: () => _rate(Rating.hard),
              ),
            ),
            const SizedBox(width: AppSpacing.gapSmall),
            Expanded(
              child: _RatingButton(
                label: _l10n.reviewGood,
                color: colors.ratingGood,
                textColor: colors.background,
                onPressed: () => _rate(Rating.good),
              ),
            ),
            const SizedBox(width: AppSpacing.gapSmall),
            Expanded(
              child: _RatingButton(
                label: _l10n.reviewEasy,
                color: colors.ratingEasy,
                textColor: colors.background,
                onPressed: () => _rate(Rating.easy),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _reviewController.current;
    final total = _reviewController.length;
    final indexDisplay = total == 0 ? 0 : (_reviewController.index + 1);
    final isVocabularyBox =
        _reviewController.box?.boxType == BoxType.vocabulary;
    final hasRecording =
        current != null && AppPaths.audioFile(current.id).existsSync();

    return AppScaffold(
      backLabel: _l10n.back,
      body: current == null
          ? const Center(child: AppProgressIndicator())
          : Column(
              children: [
                _buildHeader(
                  _reviewController.index,
                  indexDisplay,
                  total,
                  _flipped && hasRecording,
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: _buildCard(current, isVocabularyBox),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildRatingSection(),
              ],
            ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;

  const _ProgressBar({required this.value});

  static const double _height = 3.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: _height,
      color: colors.borderSubtle,
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(height: _height, color: colors.highlight),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _RatingButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: color,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.gapLarge),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySans.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
