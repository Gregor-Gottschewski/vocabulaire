import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vocabulaire/views/box_detail_page.dart';
import 'package:vocabulaire/views/widgets/box_tile.dart';

import '../controllers/box_controller.dart';
import '../models/vocabulary_box.dart';
import '../theme/app_page_route.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'create_box_flow.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/text_link_button.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => HomeViewWidget();
}

class HomeViewWidget extends State<HomeView> {
  final BoxController _boxController = BoxController();
  late AppLocalizations _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<void> _createBox() async {
    final result = await Navigator.of(context, rootNavigator: true)
        .push<({VocabularyBox box, dynamic key})>(
          AppPageRoute(builder: (context) => const CreateBoxFlow()),
        );
    if (result == null || !mounted) return;
    Navigator.of(context).push(
      AppPageRoute(
        builder: (context) =>
            BoxDetailPage(box: result.box, boxKey: result.key),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppScaffold(
      actions: [TextLinkButton(label: _l10n.addBox, onPressed: _createBox)],
      body: ValueListenableBuilder(
        valueListenable: _boxController.listenable,
        builder: (context, Box<VocabularyBox> box, _) {
          final keys = box.keys.cast<dynamic>().toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _l10n.tabBoxen,
                style: AppTypography.headlineSerif.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              if (keys.isEmpty)
                Text(
                  _l10n.homeEmpty,
                  style: AppTypography.bodySans.copyWith(
                    color: colors.textSecondary,
                  ),
                )
              else
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colors.borderStrong,
                          width: AppSpacing.hairline,
                        ),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: keys.length,
                      itemBuilder: (context, index) {
                        final b = box.get(keys[index]) as VocabularyBox;
                        return BoxTile(
                          box: b,
                          onTap: () {
                            Navigator.of(context).push(
                              AppPageRoute(
                                builder: (context) =>
                                    BoxDetailPage(box: b, boxKey: keys[index]),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
