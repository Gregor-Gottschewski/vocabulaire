import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/controllers/create_box_draft.dart';
import 'package:vocabulaire/views/create_box_type_view.dart';

/// Full-screen, multi-step box-creation flow.
class CreateBoxFlow extends StatefulWidget {
  const CreateBoxFlow({super.key});

  @override
  State<CreateBoxFlow> createState() => _CreateBoxFlowState();
}

class _CreateBoxFlowState extends State<CreateBoxFlow> {
  late final CreateBoxDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft = CreateBoxDraft();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => CupertinoPageRoute(
        builder: (_) => CreateBoxTypeView(draft: _draft),
      ),
    );
  }
}
