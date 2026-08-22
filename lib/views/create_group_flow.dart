import 'package:flutter/widgets.dart';
import 'package:vocabulaire/controllers/group_draft.dart';
import 'package:vocabulaire/theme/app_page_route.dart';
import 'package:vocabulaire/views/create_group_type_view.dart';

/// Full-screen, multi-step group-creation flow.
class CreateGroupFlow extends StatefulWidget {
  const CreateGroupFlow({super.key});

  @override
  State<CreateGroupFlow> createState() => _CreateGroupFlowState();
}

class _CreateGroupFlowState extends State<CreateGroupFlow> {
  late final GroupDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft = GroupDraft();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) => AppPageRoute(
        builder: (_) => CreateGroupTypeView(draft: _draft),
      ),
    );
  }
}
