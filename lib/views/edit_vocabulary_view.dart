import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
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

    _backController.addListener(_onBackTextChanged);
  }

  @override
  void dispose() {
    _backController.removeListener(_onBackTextChanged);
    _frontController.dispose();
    _backController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _playerCompleteSub?.cancel();
    super.dispose();
  }

  /// Rebuilds on every keystroke to update char counter
  void _onBackTextChanged() {
    if (mounted) setState(() {});
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
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(_l10n.editVocabMissingInput),
          content: Text(_l10n.editVocabMissingInputMessage),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_l10n.commonOk),
            ),
          ],
        ),
      );
      return false;
    }

    setState(() => _isSaving = true);

    _vocab.word = front;
    _vocab.meaning = back;
    _vocab.example = description;

    if (widget.newVocabulary) {
      if (widget.box.vocabularies.any((e) => e.word == front)) {
        final shouldAdd = await showCupertinoDialog<bool>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text(_l10n.editVocabExists),
            content: Text(_l10n.editVocabExistsMessage),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(_l10n.commonCancel),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(_l10n.editVocabAddAnyway),
              ),
            ],
          ),
        );

        // this line looks confusing, however it handles shouldAdd == false
        // that can happen if user closes pop-up without pressing a defined option
        if (shouldAdd != true) {
          if (mounted) setState(() => _isSaving = false);
          return false;
        }
      }
      _boxController.addVocabularyToBox(widget.boxKey, _vocab);
    } else {
      _boxController.updateVocabularyInBox(widget.boxKey, _vocab);
    }

    if (mounted) {
      setState(() => _isSaving = false);
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
      await showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(_l10n.editVocabNoPermission),
          content: Text(_l10n.editVocabMicPermission),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(_l10n.commonOk),
            ),
          ],
        ),
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
      setState(() => _hasRecording = false);
    }
  }

  /// Generates an AI pronunciation of the back text.
  Future<void> _generateTtsAudio() async {
    if (!_canGenerateTts) return;
    if (widget.box.targetAppLanguage == null) return;
    final text = _backController.text.trim();

    if (_hasRecording) {
      final confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(_l10n.editVocabOverwriteAudioTitle),
          content: Text(_l10n.editVocabOverwriteAudioMessage),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(_l10n.commonCancel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(_l10n.editVocabOverwriteAudioConfirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
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
      await _initAudioPlayer();
      if (mounted) {
        setState(() {
          _hasRecording = true;
          _isGeneratingTts = false;
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (result, dynamic) async {
        await _onPop();
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            widget.newVocabulary ? _l10n.editVocabNew : _l10n.editVocabEdit,
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _deleteVocabulary,
            child: const Icon(
              CupertinoIcons.delete,
              color: CupertinoColors.systemRed,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Front (word)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _l10n.editVocabFront,
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _frontController,
                          placeholder: _l10n.editVocabFrontHint,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          textInputAction: TextInputAction.newline,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 12),

                        // Back (meaning)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _l10n.editVocabBack,
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _backController,
                          placeholder: _l10n.editVocabBackHint,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          textInputAction: TextInputAction.newline,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!_canGenerateTts &&
                                _backController.text.trim().isNotEmpty)
                              Expanded(
                                child: Text(
                                  _l10n.editVocabTtsTooLongHint(
                                    _backController.text.trim().length,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: CupertinoColors.systemOrange,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Description / Example
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _l10n.editVocabDescriptionLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoTextField(
                          controller: _descriptionController,
                          placeholder: _l10n.editVocabDescriptionHint,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                        ),

                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _l10n.editVocabAudio,
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(30),
                              color: _recording
                                  ? CupertinoColors.systemRed
                                  : CupertinoColors.activeBlue,
                              onPressed: _isGeneratingTts ? null : _recordAudio,
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: Icon(
                                    CupertinoIcons.mic_fill,
                                    color: CupertinoColors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            if (widget.box.boxType == BoxType.vocabulary &&
                                widget.box.targetAppLanguage != null)
                              Semantics(
                                label: _l10n.editVocabGenerateAudio,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient:
                                        (_canGenerateTts &&
                                            !_recording &&
                                            !_isGeneratingTts)
                                        ? const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              CupertinoColors.systemPurple,
                                              CupertinoColors.systemPink,
                                              CupertinoColors.systemOrange,
                                            ],
                                          )
                                        : null,
                                    color:
                                        (_canGenerateTts &&
                                            !_recording &&
                                            !_isGeneratingTts)
                                        ? null
                                        : CupertinoColors.systemGrey4,
                                  ),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    borderRadius: BorderRadius.circular(30),
                                    onPressed:
                                        (_canGenerateTts &&
                                            !_recording &&
                                            !_isGeneratingTts)
                                        ? _generateTtsAudio
                                        : null,
                                    child: Center(
                                      child: _isGeneratingTts
                                          ? const CupertinoActivityIndicator(
                                              color: CupertinoColors.white,
                                            )
                                          : const Icon(
                                              CupertinoIcons.wand_stars,
                                              color: CupertinoColors.white,
                                              size: 20,
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                            const Spacer(),

                            Text(
                              _formatDuration(_recordDuration),
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(width: 12),

                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(30),
                              onPressed: (_hasRecording && !_isGeneratingTts)
                                  ? _playAudio
                                  : null,
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(
                                  child: Icon(
                                    _isPlaying
                                        ? CupertinoIcons.stop_fill
                                        : CupertinoIcons.play_fill,
                                    color: _hasRecording
                                        ? CupertinoColors.systemBlue
                                        : CupertinoColors.systemGrey,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(30),
                              onPressed: (_hasRecording && !_isGeneratingTts)
                                  ? _deleteAudio
                                  : null,
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(
                                  child: Icon(
                                    CupertinoIcons.delete,
                                    color: _hasRecording
                                        ? CupertinoColors.systemRed
                                        : CupertinoColors.systemGrey,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (!widget.newVocabulary) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _l10n.editVocabStats,
                              style: TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
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
                              return Text(_l10n.editVocabDue(dueDate));
                            },
                          ),
                          if (_vocab.card.difficulty != null)
                            Text(
                              _l10n.editVocabDifficulty(
                                _vocab.card.difficulty!.toStringAsFixed(2),
                              ),
                            ),
                          if (_vocab.card.stability != null)
                            Text(
                              _l10n.editVocabStability(
                                _vocab.card.stability!.toStringAsFixed(2),
                              ),
                            ),
                        ],

                        const SizedBox(height: 88),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton.filled(
                        onPressed: _isSaving ? null : _savePressed,
                        color: CupertinoColors.systemGreen,
                        child: _isSaving
                            ? const CupertinoActivityIndicator()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    CupertinoIcons.check_mark,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Flexible(child: Text(_l10n.editVocabSave)),
                                ],
                              ),
                      ),
                    ),
                    if (widget.newVocabulary) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: CupertinoButton.filled(
                          onPressed: _isSaving ? null : _saveAndNextPressed,
                          color: CupertinoColors.systemGreen,
                          child: _isSaving
                              ? const CupertinoActivityIndicator()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.arrow_right_to_line,
                                      size: 20.0,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Flexible(child: Text(_l10n.editVocabNext)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
