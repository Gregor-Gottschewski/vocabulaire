import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vocabulaire/theme/app_theme.dart';
import 'package:vocabulaire/views/widgets/app_scaffold.dart';
import 'package:vocabulaire/views/widgets/primary_action_button.dart';
import 'package:vocabulaire/views/widgets/text_link_button.dart';

void main() {
  testWidgets('AppTheme.light and AppTheme.dark build without throwing', (
    tester,
  ) async {
    expect(AppTheme.light, isNotNull);
    expect(AppTheme.dark, isNotNull);
  });

  testWidgets('AppScaffold renders back-link, body content and reacts to taps', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: AppScaffold(
          backLabel: 'Zurück',
          body: Column(
            children: [
              const Text('Vocabulaire'),
              PrimaryActionButton(
                label: "Los geht's",
                onPressed: () => tapped = true,
              ),
              TextLinkButton(label: 'Mehr', onPressed: () {}),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Vocabulaire'), findsOneWidget);
    expect(find.text('← Zurück'), findsOneWidget);

    await tester.tap(find.text("Los geht's"));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
