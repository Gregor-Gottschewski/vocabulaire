import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:vocabulaire/services/app_paths.dart';

import '../controllers/box_controller.dart';
import '../models/vocabulary.dart';

/// Editing view (create or edit) for a vocabulary entry, allowing users to input front, back, and description/example fields.
class EditVocabularyView extends StatefulWidget {
  final dynamic boxKey;
  final Vocabulary? vocabulary;
  final bool newVocabulary;

  const EditVocabularyView({super.key, required this.boxKey, this.vocabulary})
    : newVocabulary = (vocabulary == null);

  @override
  State<EditVocabularyView> createState() => _EditVocabularyViewState();
}

class _EditVocabularyViewState extends State<EditVocabularyView> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final BoxController _controller = BoxController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RecordConfig _audioConfig = RecordConfig(
    encoder: AudioEncoder.aacLc,
    bitRate: 16000,
    sampleRate: 16000,
    numChannels: 1,
  );
  bool _isSaving = false;
  bool _recording = false;
  bool _isPlaying = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  late bool _hasRecording;
  late Vocabulary _vocab;
  StreamSubscription<void>? _playerCompleteSub;

  /// Initializes the text controllers with the existing vocabulary data when the view is created.
  @override
  void initState() {
    super.initState();
    _vocab = widget.vocabulary ?? _controller.createVocabulary();

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

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _playerCompleteSub?.cancel();
    super.dispose();
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
          title: const Text('Fehlende Eingabe'),
          content: const Text('Bitte Vorder- und Rückseite ausfüllen.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
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
      final box = _controller.getBox(widget.boxKey)!;
      if (box.vocabularies.any((e) => e.word == front)) {
        final shouldAdd = await showCupertinoDialog<bool>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Vokabel existiert bereits'),
            content: const Text(
              'Diese Vokabel existiert bereits in diesem Box. Soll die Vokabel trotzdem hinzugefügt werden?',
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Abbrechen'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Trotzdem hinzufügen'),
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
      _controller.addVocabularyToBox(widget.boxKey, _vocab);
    } else {
      _controller.updateVocabularyInBox(widget.boxKey, _vocab);
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
    _vocab = _controller.createVocabulary();
    _frontController.clear();
    _backController.clear();
    _descriptionController.clear();
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
          title: const Text('Keine Berechtigung'),
          content: const Text(
            'Die App benötigt Zugriff auf das Mikrofon, um Audioaufnahmen zu ermöglichen. Bitte erteilen Sie die Berechtigung in den Einstellungen.',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
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
            widget.newVocabulary ? 'Neue Vokabel' : 'Vokabel bearbeiten',
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
                            'Front',
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
                          placeholder: 'Wort / Vorderseite',
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
                            'Back',
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
                          placeholder: 'Bedeutung / Rückseite',
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          textInputAction: TextInputAction.newline,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 12),

                        // Description / Example
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Beschreibung / Beispiel',
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
                          placeholder: 'Optionales Beispiel oder Beschreibung',
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
                            'Audioaufnahme',
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
                              onPressed: _recordAudio,
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
                              onPressed: _hasRecording ? _playAudio : null,
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
                              onPressed: _hasRecording ? _deleteAudio : null,
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
                              'Statistiken',
                              style: TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Nächste Abfrage: ${_vocab.card.due.isAfter(DateTime.now()) ? DateFormat.yMd(Localizations.localeOf(context).toString()).add_Hm().format(_vocab.card.due.toLocal()) : 'überfällig'}",
                          ),
                          if (_vocab.card.difficulty != null)
                            Text(
                              "Komplexität: ${_vocab.card.difficulty!.toStringAsFixed(2)} von 10",
                            ),
                          if (_vocab.card.stability != null)
                            Text(
                              "Stabilität: ${(_vocab.card.stability!).toStringAsFixed(2)}",
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
                                children: const [
                                  Icon(CupertinoIcons.check_mark, size: 20.0),
                                  SizedBox(width: 8.0),
                                  Flexible(child: Text('Speichern')),
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
                                  children: const [
                                    Icon(
                                      CupertinoIcons.arrow_right_to_line,
                                      size: 20.0,
                                    ),
                                    SizedBox(width: 8.0),
                                    Flexible(child: Text('Nächste')),
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
