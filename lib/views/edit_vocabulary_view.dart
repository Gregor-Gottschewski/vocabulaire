import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:fsrs/fsrs.dart' hide State;
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabulaire/models/box_type.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/services/app_paths.dart';
import 'package:vocabulaire/services/audio_sync_service.dart';
import 'package:vocabulaire/services/audio_upload_queue_service.dart';
import 'package:vocabulaire/services/tts_service.dart';
import 'package:vocabulaire/services/vocabulary_sync_service.dart';

import '../controllers/box_controller.dart';
import '../models/conjugation.dart';
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
import 'widgets/section_title.dart';
import 'widgets/text_link_button.dart';

enum _UnsavedChangesAction { saveAndLeave, discard }

/// Editing view (create or edit) for a vocabulary entry, allowing users to input front, back, and description/example fields.
class EditVocabularyView extends StatefulWidget {
  final String boxKey;
  final VocabularyBox box;
  final Vocabulary? vocabulary;
  final int number;

  const EditVocabularyView({
    super.key,
    required this.boxKey,
    required this.box,
    this.number = 0,
    this.vocabulary,
  });

  @override
  State<EditVocabularyView> createState() => _EditVocabularyViewState();
}

class _EditVocabularyViewState extends State<EditVocabularyView> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final Map<String, TextEditingController> _conjugationTempsControllers = {};
  final Map<String, TextEditingController> _conjugationFormsControllers = {};
  List<Conjugation> _conjugations = [];
  final BoxController _boxController = BoxController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RecordConfig _audioConfig = RecordConfig(
    encoder: AudioEncoder.aacLc,
    bitRate: 16000,
    sampleRate: 16000,
    numChannels: 1,
  );
  late bool _hasCommittedAudio;
  bool _hasPendingNewAudio = false;
  bool _pendingDelete = false;
  late Vocabulary _vocab;
  late AppLocalizations _l10n;
  bool _isSaving = false;
  bool _recording = false;
  bool _isPlaying = false;
  bool _isGeneratingTts = false;
  bool _isDirty = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  static const Duration _maxRecordDuration = Duration(seconds: 30);
  StreamSubscription<void>? _playerCompleteSub;
  int _vocabularyNumber = 0;

  bool get _isEditing => widget.vocabulary != null;

  bool get _hasRecording =>
      _hasPendingNewAudio || (_hasCommittedAudio && !_pendingDelete);

  /// Initializes the text controllers with the existing vocabulary data when the view is created.
  @override
  void initState() {
    super.initState();
    _vocab = widget.vocabulary ?? _boxController.createVocabulary();

    _frontController.text = _vocab.word;
    _backController.text = _vocab.meaning;
    _descriptionController.text = _vocab.example;
    _vocabularyNumber = widget.number;

    _conjugations = List<Conjugation>.from(_vocab.conjugations);
    for (final c in _conjugations) {
      _conjugationTempsControllers[c.id] = TextEditingController(text: c.temps)
        ..addListener(_onInputChanged);
      _conjugationFormsControllers[c.id] = TextEditingController(text: c.forms)
        ..addListener(_onInputChanged);
    }

    _hasCommittedAudio = _checkExistingRecording();
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
    for (final controller in _conjugationTempsControllers.values) {
      controller.dispose();
    }
    for (final controller in _conjugationFormsControllers.values) {
      controller.dispose();
    }
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

  /// Adds a new, empty conjugation row.
  void _addConjugation() {
    final conjugation = Conjugation(
      temps: '',
      forms: '',
      cardData: Card(cardId: DateTime.now().millisecondsSinceEpoch).toMap(),
      id: const Uuid().v4(),
    );
    _conjugationTempsControllers[conjugation.id] = TextEditingController()
      ..addListener(_onInputChanged);
    _conjugationFormsControllers[conjugation.id] = TextEditingController()
      ..addListener(_onInputChanged);
    setState(() {
      _conjugations = [..._conjugations, conjugation];
      _isDirty = true;
    });
  }

  /// Removes the conjugation with the given [id] and disposes its controllers.
  void _removeConjugation(String id) {
    _conjugationTempsControllers.remove(id)
      ?..removeListener(_onInputChanged)
      ..dispose();
    _conjugationFormsControllers.remove(id)
      ?..removeListener(_onInputChanged)
      ..dispose();
    setState(() {
      _conjugations = _conjugations.where((c) => c.id != id).toList();
      _isDirty = true;
    });
  }

  /// Disposes and clears all per-row conjugation controllers.
  void _resetConjugations() {
    for (final controller in _conjugationTempsControllers.values) {
      controller.dispose();
    }
    for (final controller in _conjugationFormsControllers.values) {
      controller.dispose();
    }
    _conjugationTempsControllers.clear();
    _conjugationFormsControllers.clear();
    _conjugations = [];
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

  String _activeAudioPath() => _hasPendingNewAudio
      ? AppPaths.audioTempFilePath(_vocab.id)
      : AppPaths.audioFilePath(_vocab.id);

  Future<void> _initAudioPlayer() async {
    await _audioPlayer.setSourceDeviceFile(_activeAudioPath());
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
    return _isEditing ? AppPaths.audioFile(_vocab.id).existsSync() : false;
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

    for (final c in _conjugations) {
      c.temps = _conjugationTempsControllers[c.id]!.text.trim();
      c.forms = _conjugationFormsControllers[c.id]!.text.trim();
    }
    final syncedConjugations = _conjugations
        .where((c) => c.temps.isNotEmpty || c.forms.isNotEmpty)
        .toList();
    _vocab = _vocab.copyWith(conjugations: syncedConjugations);

    if (_isEditing) {
      _boxController.updateVocabularyInBox(widget.boxKey, _vocab);
    } else {
      final currentVocabularies =
          _boxController.getBox(widget.boxKey)?.vocabularies ??
          widget.box.vocabularies;
      if (currentVocabularies.any((e) => e.word == front)) {
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
      try {
        await _boxController.addVocabularyToBox(widget.boxKey, _vocab);
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          await context.showAppError(
            e is AppException
                ? e
                : AppException(AppError.addVocabularyFailed, details: e),
          );
        }
        return false;
      }
    }

    if (_hasPendingNewAudio) {
      await _commitAudioFile(_vocab.id);
      _hasCommittedAudio = true;
      _hasPendingNewAudio = false;
    } else if (_pendingDelete) {
      final finalFile = AppPaths.audioFile(_vocab.id);
      if (finalFile.existsSync()) {
        await finalFile.delete();
        if (_isEditing && !_boxController.isLocal(widget.boxKey)) {
          AudioUploadQueueService.instance.cancel(_vocab.id);
          unawaited(AudioSyncService.instance.deleteAudio(_vocab.id));
          unawaited(
            VocabularySyncService.instance.setAudioSynced(
              widget.boxKey,
              _vocab.id,
              false,
            ),
          );
        }
      }
      _hasCommittedAudio = false;
      _pendingDelete = false;
    }

    if (!_boxController.isLocal(widget.boxKey) && _hasRecording) {
      AudioUploadQueueService.instance.enqueue(widget.boxKey, _vocab.id);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        _isDirty = false;
      });
    }

    return true;
  }

  /// Moves a temp audio from the temp location to its final location.
  Future<void> _commitAudioFile(String vocabId) async {
    final temp = AppPaths.audioTempFile(vocabId);
    if (!await temp.exists()) return;
    await temp.copy(AppPaths.audioFilePath(vocabId));
    await temp.delete();
  }

  Future<void> _saveAndNextPressed() async {
    final saved = await _save();
    if (!saved) return;

    if (_isEditing) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    _vocab = _boxController.createVocabulary();
    _hasCommittedAudio = false;
    _hasPendingNewAudio = false;
    _pendingDelete = false;
    _isGeneratingTts = false;
    _recordDuration = Duration.zero;
    _frontController.clear();
    _backController.clear();
    _descriptionController.clear();
    _resetConjugations();
    _vocabularyNumber++;
    if (mounted) setState(() => _isDirty = false);
  }

  /// Delete vocabulary from box and close edit view.
  void _deleteVocabulary() {
    showAppDialog(
      context: context,
      title: _l10n.editVocabDeleteTitle,
      message: _l10n.editVocabDeleteMessage,
      actions: [
        AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
        AppDialogAction(
          label: _l10n.editVocabDeleteConfirm,
          destructive: true,
          onPressed: () {
            _boxController.removeVocabularyFromBox(widget.boxKey, _vocab.id);
            if (_hasPendingNewAudio) {
              final temp = AppPaths.audioTempFile(_vocab.id);
              if (temp.existsSync()) unawaited(temp.delete());
            }
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _recordAudio() async {
    if (await _audioRecorder.hasPermission()) {
      if (_recording) {
        await _stopRecording();
      } else {
        await _audioRecorder.start(
          _audioConfig,
          path: AppPaths.audioTempFilePath(_vocab.id),
        );
        _startRecordTimer();
        setState(() => _recording = true);
      }
    } else {
      if (!mounted) return;
      await showAppDialog(
        context: context,
        title: _l10n.editVocabNoPermission,
        message: _l10n.editVocabMicPermission,
        actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      );
    }
  }

  /// Stops the current recording and marks the audio as pending.
  Future<void> _stopRecording() async {
    await _audioRecorder.stop();
    _hasPendingNewAudio = true;
    _pendingDelete = false;
    _isDirty = true;
    _stopRecordTimer();
    if (mounted) setState(() => _recording = false);
  }

  /// Starts a timer to track the duration of the current audio recording, updating the UI every second.
  /// Recording is capped at [_maxRecordDuration] and stops automatically once reached.
  void _startRecordTimer() {
    _recordTimer?.cancel();
    _recordDuration = Duration.zero;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final duration = _recordDuration + const Duration(seconds: 1);
      if (duration >= _maxRecordDuration) {
        unawaited(_stopRecording());
        return;
      }
      setState(() => _recordDuration = duration);
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

    await _audioPlayer.play(DeviceFileSource(_activeAudioPath()));

    if (mounted) setState(() => _isPlaying = true);
  }

  /// Removes the current audio.
  void _deleteAudio() async {
    if (!_hasRecording) return;

    if (_hasPendingNewAudio) {
      final temp = AppPaths.audioTempFile(_vocab.id);
      if (await temp.exists()) await temp.delete();
      _hasPendingNewAudio = false;
    } else {
      _pendingDelete = true;
    }

    _recordDuration = Duration.zero;
    setState(() => _isDirty = true);
  }

  /// Generates an AI pronunciation of the back text.
  Future<void> _generateTtsAudio() async {
    if (!_canGenerateTts) return;
    if (widget.box.targetAppLanguage == null) return;
    final text = _backController.text.trim();
    final generatingVocabId = _vocab.id;
    final boxKey = widget.boxKey;

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
        cardId: generatingVocabId,
        languageId: widget.box.targetAppLanguage!.code,
      );

      final stillCurrent = mounted && _vocab.id == generatingVocabId;
      if (!stillCurrent) {
        final vocabStillExists =
            _boxController
                .getBox(boxKey)
                ?.vocabularies
                .any((v) => v.id == generatingVocabId) ??
            false;
        if (vocabStillExists) {
          await _commitAudioFile(generatingVocabId);
          if (!_boxController.isLocal(boxKey)) {
            AudioUploadQueueService.instance.enqueue(boxKey, generatingVocabId);
          }
        } else {
          final orphan = AppPaths.audioTempFile(generatingVocabId);
          if (orphan.existsSync()) await orphan.delete();
        }
        return;
      }

      _hasPendingNewAudio = true;
      _pendingDelete = false;
      await _initAudioPlayer();
      if (mounted) {
        setState(() {
          _isGeneratingTts = false;
          _isDirty = true;
        });
      }
    } on AppException catch (e) {
      if (mounted && _vocab.id == generatingVocabId) {
        setState(() => _isGeneratingTts = false);
        await context.showAppError(e);
      }
    } catch (e) {
      if (mounted && _vocab.id == generatingVocabId) {
        setState(() => _isGeneratingTts = false);
        await context.showAppError(
          AppException(AppError.ttsUnknownError, details: e),
        );
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

  /// Discards any staged (not-yet-saved) audio change.
  Future<void> _discardPendingAudio() async {
    if (_hasPendingNewAudio) {
      final file = AppPaths.audioTempFile(_vocab.id);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _hasPendingNewAudio = false;
    _pendingDelete = false;
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
        await _discardPendingAudio();
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
          TextLinkButton(
            label: _l10n.editVocabSave,
            onPressed: _isSaving ? null : _saveAndNextPressed,
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
                        _isEditing
                            ? _l10n.editVocabEdit
                            : "${_l10n.editVocabNew} #${_vocabularyNumber + 1}",
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

                      if (widget.box.boxType == BoxType.vocabulary) ...[
                        SectionTitle(text: _l10n.editVocabConjugationSection),
                        const SizedBox(height: AppSpacing.gapMedium),
                        for (final c in _conjugations) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller:
                                      _conjugationTempsControllers[c.id],
                                  placeholder:
                                      _l10n.editVocabConjugationTempsHint,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.gapSmall),
                              Expanded(
                                flex: 3,
                                child: AppTextField(
                                  controller:
                                      _conjugationFormsControllers[c.id],
                                  placeholder:
                                      _l10n.editVocabConjugationFormsHint,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(AppSpacing.gapMedium, 0),
                                child: TextLinkButton(
                                  label: _l10n.boxDetailDelete,
                                  color: colors.danger,
                                  onPressed: () => _removeConjugation(c.id),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.gapSmall),
                        ],
                        TextLinkButton(
                          label: _l10n.editVocabConjugationAdd,
                          onPressed: _addConjugation,
                        ),
                        const SizedBox(height: AppSpacing.sectionGap),
                      ],

                      SectionTitle(text: _l10n.editVocabAudio),
                      const SizedBox(height: AppSpacing.gapMedium),
                      _buildAudioRow(context),

                      if (_isEditing) ...[
                        const SizedBox(height: AppSpacing.sectionGap),
                        SectionTitle(text: _l10n.editVocabStats),
                        const SizedBox(height: AppSpacing.gapMedium),
                        Builder(
                          builder: (context) {
                            final dueDate =
                                _vocab.card.due.isAfter(DateTime.now())
                                ? DateFormat.yMd(
                                    Localizations.localeOf(context).toString(),
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
          ],
        ),
      ),
    );
  }
}
