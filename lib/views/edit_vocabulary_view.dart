import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/services/tts_service.dart';

import '../controllers/box_controller.dart';
import '../models/vocabulary.dart';
import '../models/vocabulary_box.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'widgets/app_dialog.dart';
import 'widgets/app_progress_indicator.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/app_text_field.dart';
import 'widgets/label_text_field.dart';
import 'widgets/primary_action_button.dart';
import 'widgets/section_title.dart';
import 'widgets/text_link_button.dart';

enum _UnsavedChangesAction { saveAndLeave, discard }

/// Editing view (create or edit) for a vocabulary entry, allowing users to input front, back, and description/example fields.
class EditVocabularyView extends StatefulWidget {
  final dynamic boxKey;
  final VocabularyBox box;
  final Vocabulary? vocabulary;
  final bool newVocabulary;

  const EditVocabularyView({
    super.key,
    required this.boxKey,
    required this.box,
    this.vocabulary,
  }) : newVocabulary = (vocabulary == null);

  @override
  State<EditVocabularyView> createState() => _EditVocabularyViewState();
}

class _EditVocabularyViewState extends State<EditVocabularyView> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final BoxController _boxController = BoxController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RecordConfig _audioConfig = RecordConfig(
    encoder: AudioEncoder.aacLc,
    bitRate: 16000,
    sampleRate: 16000,
    numChannels: 1,
  );
  late bool _hasRecording;
  late Vocabulary _vocab;
  late AppLocalizations _l10n;
  bool _isSaving = false;
  bool _recording = false;
  bool _isPlaying = false;
  bool _isGeneratingTts = false;
  bool _isDirty = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  StreamSubscription<void>? _playerCompleteSub;

  /// Initializes the text controllers with the existing vocabulary data when the view is created.
  @override
  void initState() {
    super.initState();
    _vocab = widget.vocabulary ?? _boxController.createVocabulary();

    _frontController.text = _vocab.word;
    _backController.text = _vocab.meaning;
    _descriptionController.text = _vocab.example;

    _hasRecording = _checkExistingRecording();
    if (_hasRecording) {
      _initAudioPlayer();
    }

    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });

    _frontController.addListener(_onInputChanged);
    _backController.addListener(_onInputChanged);
    _descriptionController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _frontController.removeListener(_onInputChanged);
    _backController.removeListener(_onInputChanged);
    _descriptionController.removeListener(_onInputChanged);
    _frontController.dispose();
    _backController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _playerCompleteSub?.cancel();
    super.dispose();
  }

  /// Rebuilds on every keystroke and marks the form as dirty.
  /// Also updates the character counter
  void _onInputChanged() {
    if (mounted) setState(() => _isDirty = true);
  }

  /// Returns `true` if the back text is eligible for TTS generation, `false` otherwise.
  /// Text must have x chars with 0 < x < [TtsService.maxChars].
  bool get _canGenerateTts {
    final length = _backController.text.trim().length;
    return length > 0 && length <= TtsService.maxChars;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setSourceDeviceFile(AppPaths.audioFilePath(_vocab.id));
    if (!mounted) return;
    final duration = await _audioPlayer.getDuration();
    if (mounted) {
      setState(() {
        _recordDuration = duration ?? Duration.zero;
      });
    }
  }

  /// Checks if an audio exists for the current vocabulary entry.
  bool _checkExistingRecording() {
    return widget.newVocabulary
        ? false
        : AppPaths.audioFile(_vocab.id).existsSync();
  }

  Future<Duration> getRecordingDuration() async {
    if (!_hasRecording) return Duration.zero;
    return await _audioPlayer.getDuration() ?? Duration.zero;
  }

  /// Saves the current flash card. Saving process includes:
  ///   1. Cancel process if missing required fields not set
  ///   2. If no new vocabulary: overwrite existing values -> process finished
  ///   3. If new vocabulary
  ///     3.1. If flash card (front site) already exists: show error message
  ///           (user can save anyways)
  ///     3.2. If flash card is new: save new vocabulary
  ///
  /// Returns true if process can be marked as successful (logically).
  /// Note: The process is marked as successful if vocabulary front site
  /// already exists and is therefore dismissed.
  Future<bool> _save() async {
    final front = _frontController.text.trim();
    final back = _backController.text.trim();
    final description = _descriptionController.text.trim();

    if (front.isEmpty || back.isEmpty) {
      showAppDialog(
        context: context,
        title: _l10n.editVocabMissingInput,
        message: _l10n.editVocabMissingInputMessage,
        actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      );
      return false;
    }

    setState(() => _isSaving = true);

    _vocab.word = front;
    _vocab.meaning = back;
    _vocab.example = description;

    if (widget.newVocabulary) {
      if (widget.box.vocabularies.any((e) => e.word == front)) {
        var shouldAdd = false;
        await showAppDialog(
          context: context,
          title: _l10n.editVocabExists,
          message: _l10n.editVocabExistsMessage,
          actions: [
            AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
            AppDialogAction(
              label: _l10n.editVocabAddAnyway,
              destructive: true,
              onPressed: () => shouldAdd = true,
            ),
          ],
        );

        if (!shouldAdd) {
          if (mounted) setState(() => _isSaving = false);
          return false;
        }
      }
      _boxController.addVocabularyToBox(widget.boxKey, _vocab);
    } else {
      _boxController.updateVocabularyInBox(widget.boxKey, _vocab);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isDirty = false;
      });
    }

    return true;
  }

  Future<void> _savePressed() async {
    if (await _save()) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _saveAndNextPressed() async {
    final saved = await _save();
    if (!saved) return;
    _vocab = _boxController.createVocabulary();
    _hasRecording = false;
    _recordDuration = Duration.zero;
    _frontController.clear();
    _backController.clear();
    _descriptionController.clear();
    if (mounted) setState(() => _isDirty = false);
  }

  /// Delete vocabulary from box and close edit view.
  void _deleteVocabulary() {
    _boxController.removeVocabularyFromBox(widget.boxKey, _vocab.id);
    Navigator.of(context).pop();
  }

  void _recordAudio() async {
    if (await _audioRecorder.hasPermission()) {
      if (_recording) {
        await _audioRecorder.stop();
        _hasRecording = true;
        _isDirty = true;
        _stopRecordTimer();
      } else {
        await _audioRecorder.start(
          _audioConfig,
          path: AppPaths.audioFilePath(_vocab.id),
        );
        _startRecordTimer();
      }
      setState(() => _recording = !_recording);
    } else {
      await showAppDialog(
        context: context,
        title: _l10n.editVocabNoPermission,
        message: _l10n.editVocabMicPermission,
        actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      );
    }
  }

  /// Starts a timer to track the duration of the current audio recording, updating the UI every second.
  void _startRecordTimer() {
    _recordTimer?.cancel();
    _recordDuration = Duration.zero;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordDuration = _recordDuration + const Duration(seconds: 1);
      });
    });
  }

  /// Stops the recording timer and resets the duration tracking.
  void _stopRecordTimer() {
    _recordTimer?.cancel();
    _recordTimer = null;
  }

  /// Formats the given duration to following format: mm:ss
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _playAudio() async {
    if (!_hasRecording) return;

    if (_isPlaying) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    await _audioPlayer.play(
      DeviceFileSource(AppPaths.audioFilePath(_vocab.id)),
    );

    if (mounted) setState(() => _isPlaying = true);
  }

  void _deleteAudio() async {
    if (!_hasRecording) return;
    final file = AppPaths.audioFile(_vocab.id);
    if (file.existsSync()) {
      await file.delete();
      _recordDuration = Duration.zero;
      setState(() {
        _hasRecording = false;
        _isDirty = true;
      });
    }
  }

  /// Generates an AI pronunciation of the back text.
  Future<void> _generateTtsAudio() async {
    if (!_canGenerateTts) return;
    if (widget.box.targetAppLanguage == null) return;
    final text = _backController.text.trim();

    if (_hasRecording) {
      var confirmed = false;
      await showAppDialog(
        context: context,
        title: _l10n.editVocabOverwriteAudioTitle,
        message: _l10n.editVocabOverwriteAudioMessage,
        actions: [
          AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
          AppDialogAction(
            label: _l10n.editVocabOverwriteAudioConfirm,
            destructive: true,
            onPressed: () => confirmed = true,
          ),
        ],
      );
      if (!confirmed) return;
    }

    if (_isPlaying) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _isPlaying = false);
    }

    setState(() => _isGeneratingTts = true);
    try {
      await TtsService.instance.synthesizeAndSave(
        text: text,
        cardId: _vocab.id,
        languageId: widget.box.targetAppLanguage!.code,
      );
      if (!mounted) return;
      await _initAudioPlayer();
      if (mounted) {
        setState(() {
          _hasRecording = true;
          _isGeneratingTts = false;
          _isDirty = true;
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _isGeneratingTts = false);
        await context.showAppError(e);
      }
    }
  }

  Future<void> _onPop() async {
    if (_recording) {
      await _audioRecorder.stop();
      _stopRecordTimer();
    }
    await _audioPlayer.stop();
  }

  /// Deletes the audio file belonging to the current vocabulary from disk.
  Future<void> _deleteAudioFileFromDisk() async {
    final file = AppPaths.audioFile(_vocab.id);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Shown when the user tries to leave the screen while [_isDirty] is true.
  Future<void> _handleUnsavedChanges() async {
    _UnsavedChangesAction? action;
    await showAppDialog(
      context: context,
      title: _l10n.editVocabUnsavedChangesTitle,
      actions: [
        AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
        AppDialogAction(
          label: _l10n.editVocabUnsavedChangesSaveAndLeave,
          onPressed: () => action = _UnsavedChangesAction.saveAndLeave,
        ),
        AppDialogAction(
          label: _l10n.editVocabUnsavedChangesDiscard,
          destructive: true,
          onPressed: () => action = _UnsavedChangesAction.discard,
        ),
      ],
    );

    switch (action) {
      case _UnsavedChangesAction.saveAndLeave:
        if (await _save() && mounted) {
          Navigator.of(context).pop();
        }
      case _UnsavedChangesAction.discard:
        await _deleteAudioFileFromDisk();
        if (mounted) Navigator.of(context).pop();
      case null:
        break;
    }
  }

  Widget _buildAudioRow(BuildContext context) {
    final colors = context.colors;
    final showGenerate =
        widget.box.boxType == BoxType.vocabulary &&
        widget.box.targetAppLanguage != null;
    final canGenerate = _canGenerateTts && !_recording && !_isGeneratingTts;
    final canPlay = _hasRecording && !_isGeneratingTts;
    final canDelete = _hasRecording && !_isGeneratingTts;

    return Material(
      type: MaterialType.transparency,
      child: Row(
        children: [
          GestureDetector(
            onTap: canPlay ? _playAudio : null,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Icon(
                _isPlaying ? Icons.stop : Icons.play_arrow,
                size: 24,
                color: canPlay ? colors.textPrimary : colors.borderStrong,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.gapMedium),
          GestureDetector(
            onTap: _isGeneratingTts ? null : _recordAudio,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Container(
                  width: _recording ? 20 : 14,
                  height: _recording ? 20 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.danger,
                    border: _recording
                        ? Border.all(
                            color: colors.danger.withValues(alpha: 0.3),
                            width: 3,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.gapMedium),
          Text(
            _formatDuration(_recordDuration),
            style: AppTypography.captionSans.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (showGenerate)
            if (_isGeneratingTts)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.gapMedium),
                child: AppProgressIndicator(size: 16),
              )
            else
              Opacity(
                opacity: canGenerate ? 1 : 0.35,
                child: TextLinkButton(
                  label: _l10n.editVocabGenerateAudio,
                  onPressed: canGenerate ? _generateTtsAudio : null,
                ),
              ),
          // TextLinkButton carries its own EdgeInsets.all(gapMedium) hit
          // padding (intentional, larger tap target). Shift the trailing
          // one back by that amount so its visible edge lines up with the
          // page's right margin instead of shrinking the tap target.
          Transform.translate(
            offset: const Offset(AppSpacing.gapMedium, 0),
            child: Opacity(
              opacity: canDelete ? 1 : 0.35,
              child: TextLinkButton(
                label: _l10n.boxDetailDelete,
                color: colors.danger,
                onPressed: canDelete ? _deleteAudio : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _onPop();
          return;
        }
        await _handleUnsavedChanges();
      },
      child: AppScaffold(
        backLabel: _l10n.vocabListTitle,
        actions: [
          TextLinkButton(
            label: _l10n.boxDetailDelete,
            onPressed: _deleteVocabulary,
          ),
        ],
        body: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.newVocabulary
                            ? _l10n.editVocabNew
                            : _l10n.editVocabEdit,
                        style: AppTypography.headlineSerif.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),

                      LabelTextField(
                        label: _l10n.editVocabFront.toUpperCase(),
                        textField: AppTextField(
                          controller: _frontController,
                          placeholder: _l10n.editVocabFrontHint,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),

                      LabelTextField(
                        label: _l10n.editVocabBack.toUpperCase(),
                        textField: AppTextField(
                          controller: _backController,
                          placeholder: _l10n.editVocabBackHint,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      if (!_canGenerateTts &&
                          _backController.text.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.gapSmall),
                        Text(
                          _l10n.editVocabTtsTooLongHint(
                            _backController.text.trim().length,
                          ),
                          style: AppTypography.captionSans.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sectionGap),

                      LabelTextField(
                        label: _l10n.editVocabDescriptionLabel.toUpperCase(),
                        textField: AppTextField(
                          controller: _descriptionController,
                          placeholder: _l10n.editVocabDescriptionHint,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),

                      SectionTitle(text: _l10n.editVocabAudio),
                      const SizedBox(height: AppSpacing.gapMedium),
                      _buildAudioRow(context),

                      if (!widget.newVocabulary) ...[
                        const SizedBox(height: AppSpacing.sectionGap),
                        SectionTitle(text: _l10n.editVocabStats),
                        const SizedBox(height: AppSpacing.gapMedium),
                        Builder(
                          builder: (context) {
                            final dueDate =
                                _vocab.card.due.isAfter(DateTime.now())
                                ? DateFormat.yMd(
                                    Localizations.localeOf(
                                      context,
                                    ).toString(),
                                  ).add_Hm().format(_vocab.card.due.toLocal())
                                : _l10n.editVocabOverdue;
                            return Text(
                              _l10n.editVocabDue(dueDate),
                              style: AppTypography.bodySans.copyWith(
                                color: colors.textSecondary,
                              ),
                            );
                          },
                        ),
                        if (_vocab.card.difficulty != null)
                          Text(
                            _l10n.editVocabDifficulty(
                              _vocab.card.difficulty!.toStringAsFixed(2),
                            ),
                            style: AppTypography.bodySans.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        if (_vocab.card.stability != null)
                          Text(
                            _l10n.editVocabStability(
                              _vocab.card.stability!.toStringAsFixed(2),
                            ),
                            style: AppTypography.bodySans.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                      ],

                      const SizedBox(height: 88),
                    ],
                  ),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: PrimaryActionButton(
                    label: _l10n.editVocabSave,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _savePressed,
                  ),
                ),
                if (widget.newVocabulary) ...[
                  const SizedBox(width: AppSpacing.gapMedium),
                  Expanded(
                    child: PrimaryActionButton(
                      label: _l10n.editVocabNext,
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _saveAndNextPressed,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
