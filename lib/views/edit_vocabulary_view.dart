import 'package:flutter/cupertino.dart';
import 'package:fsrs/fsrs.dart' hide State;

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
  bool _isSaving = false;
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
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _descriptionController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                              onPressed: _isSaving ? null : _saveAndNextPressed,
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
    );
  }
}
