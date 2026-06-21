import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fsrs/fsrs.dart' hide State;
import 'package:vocabulaire/controllers/review_controller.dart';
import 'package:vocabulaire/models/review_session.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/ui/tokens.dart';

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

    setState(() {});
  }

  void _playAudio() async {
    final current = reviewController.current;
    if (current == null) return;
    await player.play(DeviceFileSource(AppPaths.audioFilePath(current.id)));
  }

  Widget _buildProgressBar() {
    final total = reviewController.length;
    final index = reviewController.index;
    final progress = total == 0 ? 0.0 : index / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Karte ${total == 0 ? 0 : index + 1} von $total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).round()} %',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.progressFill,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.progressTrack,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.progressFill),
          ),
        ),
      ],
    );
  }

  Widget _buildCardView(Brightness brightness) {
    final current = reviewController.current;
    if (current == null) {
      return const SizedBox(
        width: double.infinity,
        height: 260,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.progressFill,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final front = current.word;
    final back = current.meaning;
    final example = current.example.isNotEmpty ? current.example : null;
    final hasRecording = AppPaths.audioFile(current.id).existsSync();
    final cardColor = AppColors.card(brightness);

    return GestureDetector(
      onTap: () => setState(() => _flipped = !_flipped),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            RotationTransition(turns: animation, child: child),
        child: Container(
          key: ValueKey(_flipped),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 220),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: SingleChildScrollView(
              child: _flipped
                  ? _buildBack(back, example, hasRecording)
                  : _buildFront(front),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFront(String word) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          word,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Tippen zum Umdrehen',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBack(String meaning, String? example, bool hasRecording) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          meaning,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
        if (example != null) ...[
          const SizedBox(height: AppSpacing.sm),
          const Divider(color: AppColors.progressTrack, height: 24),
          Text(
            example,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (hasRecording) ...[
          const SizedBox(height: AppSpacing.md),
          _AudioButton(onPressed: _playAudio),
        ],
      ],
    );
  }

  Widget _buildRatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                label: 'Nochmal',
                icon: CupertinoIcons.xmark,
                color: AppColors.again,
                onPressed: () {
                  reviewController.applyRating(Rating.again);
                  setState(() => _flipped = false);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _RatingButton(
                label: 'Schwer',
                icon: CupertinoIcons.exclamationmark,
                color: AppColors.hard,
                onPressed: () {
                  reviewController.applyRating(Rating.hard);
                  setState(() => _flipped = false);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _RatingButton(
                label: 'Gut',
                icon: CupertinoIcons.smiley,
                color: AppColors.good,
                onPressed: () {
                  reviewController.applyRating(Rating.good);
                  setState(() => _flipped = false);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _RatingButton(
                label: 'Einfach',
                icon: CupertinoIcons.check_mark_circled,
                color: AppColors.easy,
                onPressed: () {
                  reviewController.applyRating(Rating.easy);
                  setState(() => _flipped = false);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _SkipButton(
          onPressed: () {
            reviewController.skip();
            setState(() => _flipped = false);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final bgColor = AppColors.bg(brightness);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoDynamicColor.resolve(
        CupertinoColors.systemGroupedBackground,
        context,
      ),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Lernen'),
        previousPageTitle: 'Zurück',
      ),
      child: SafeArea(
        child: ColoredBox(
          color: bgColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              children: [
                _buildProgressBar(),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: Center(child: _buildCardView(brightness)),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildRatingButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _RatingButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.textOnColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textOnColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SkipButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.forward, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  'Überspringen',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AudioButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.progressFill.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.play_arrow_solid, size: 16, color: AppColors.progressFill),
                SizedBox(width: 6),
                Text(
                  'Abspielen',
                  style: TextStyle(
                    color: AppColors.progressFill,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
