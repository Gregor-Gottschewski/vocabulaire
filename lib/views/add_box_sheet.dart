import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/controllers/box_controller.dart';
import 'package:vocabulaire/models/vocabulary_box.dart';

/// The [AddBoxSheet] is a modal sheet that allows the user to create a new vocabulary box.
/// It contains text fields for the box name and description, and buttons to cancel or add the box.
class AddBoxSheet extends StatefulWidget {
  final BoxController boxController;

  const AddBoxSheet({super.key, required this.boxController});

  @override
  State<AddBoxSheet> createState() => _AddBoxSheetState();
}

class _AddBoxSheetState extends State<AddBoxSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  bool _isAdding = false;

  /// Update the state when the name changes to enable/disable the 'add' button.
  void _onNameChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _descController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _onAdd() async {
    final name = _nameController.text.trim();
    final description = _descController.text.trim();

    if (name.isEmpty) {
      await showCupertinoDialog(
        context: context,
        builder: (_) =>
            CupertinoAlertDialog(
              title: const Text('Fehler'),
              content: const Text('Der Name darf nicht leer sein.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
      return;
    }

    setState(() => _isAdding = true);

    try {
      widget.boxController.addBox(
        VocabularyBox(name: name, description: description, vocabularies: []),
      );
      Navigator.of(context).pop();
    } catch (e) {
      await showCupertinoDialog(
        context: context,
        builder: (_) =>
            CupertinoAlertDialog(
              title: const Text('Fehler'),
              content: Text(e.toString()),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery
        .of(context)
        .viewInsets
        .bottom;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Neue Box erstellen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _nameController,
                focusNode: _nameFocus,
                placeholder: 'Name der Box',
                clearButtonMode: OverlayVisibilityMode.editing,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _descController,
                placeholder: 'Beschreibung (optional)',
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: CupertinoColors.systemGrey5,
                      onPressed: _isAdding
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Abbrechen',
                        style: TextStyle(color: CupertinoColors.systemRed),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed:
                      _isAdding || _nameController.text
                          .trim()
                          .isEmpty
                          ? null
                          : _onAdd,
                      child: _isAdding
                          ? const CupertinoActivityIndicator()
                          : const Text('Hinzufügen'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
