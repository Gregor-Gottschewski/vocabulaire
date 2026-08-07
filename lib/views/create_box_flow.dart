import 'package:flutter/widgets.dart';
import 'package:vocabulaire/controllers/box_draft.dart';
import 'package:vocabulaire/theme/app_page_route.dart';
import 'package:vocabulaire/views/create_box_type_view.dart';

/// Full-screen, multi-step box-creation flow.
class CreateBoxFlow extends StatefulWidget {
  const CreateBoxFlow({super.key});

  @override
  State<CreateBoxFlow> createState() => _CreateBoxFlowState();
}

class _CreateBoxFlowState extends State<CreateBoxFlow> {
  late final BoxDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft = BoxDraft();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => AppPageRoute(
        builder: (_) => CreateBoxTypeView(draft: _draft),
      ),
    );
  }
}
