import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:fsrs/fsrs.dart' hide State;
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
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  late bool _hasRecording;
  late Vocabulary _vocab;

  /// Initializes the text controllers with the existing vocabulary data when the view is created.
  @override
  void initState() {
    super.initState();
    _vocab =
        widget.vocabulary ??
        Vocabulary(
          word: '',
          meaning: '',
          example: '',
          cardData: Card(cardId: DateTime.now().millisecondsSinceEpoch).toMap(),
        );

    _frontController.text = _vocab.word;
    _backController.text = _vocab.meaning;
    _descriptionController.text = _vocab.example;

    _hasRecording = _checkExistingRecording();
    if (_hasRecording) {}
  }

  /// Checks if an audio exists for the current vocabulary entry.
  bool _checkExistingRecording() {
    return widget.newVocabulary
        ? false
        : AppPaths.audioFile(_vocab.id).existsSync();
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

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
    await _save();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveAndNextPressed() async {
    final saved = await _save();
    if (!saved) return;
    final newCard = Card(cardId: DateTime.now().millisecondsSinceEpoch).toMap();
    _vocab = Vocabulary(word: '', meaning: '', example: '', cardData: newCard);
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
    await _audioPlayer.play(
      DeviceFileSource(AppPaths.audioFilePath(_vocab.id)),
    );
  }

  void _deleteAudio() async {
    if (!_hasRecording) return;
    final file = AppPaths.audioFile(_vocab.id);
    if (file.existsSync()) {
      await file.delete();
      setState(() => _hasRecording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (result, dynamic) async {
        if (_recording) {
          await _audioRecorder.stop();
          _stopRecordTimer();
        }
        await _audioPlayer.stop();
      },
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            widget.newVocabulary ? 'Neue Vokabel' : 'Vokabel bearbeiten',
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                  textInputAction: TextInputAction.next,
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
                  textInputAction: TextInputAction.next,
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
                            size: 22,
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
                      color: _hasRecording
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.quaternarySystemFill,
                      onPressed: _hasRecording ? _playAudio : null,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Icon(
                            CupertinoIcons.play_fill,
                            color: _hasRecording
                                ? CupertinoColors.black
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
                      color: _hasRecording
                          ? CupertinoColors.destructiveRed
                          : CupertinoColors.quaternarySystemFill,
                      onPressed: _hasRecording ? _deleteAudio : null,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Icon(
                            CupertinoIcons.delete,
                            color: _hasRecording
                                ? CupertinoColors.white
                                : CupertinoColors.systemGrey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoButton.filled(
                              onPressed: _isSaving ? null : _savePressed,
                              color: CupertinoColors.inactiveGray,
                              child: _isSaving
                                  ? const CupertinoActivityIndicator()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          CupertinoIcons.check_mark,
                                          size: 20.0,
                                        ),
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
                                onPressed: _isSaving
                                    ? null
                                    : _saveAndNextPressed,
                                color: CupertinoColors.systemGreen,
                                child: _isSaving
                                    ? const CupertinoActivityIndicator()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
