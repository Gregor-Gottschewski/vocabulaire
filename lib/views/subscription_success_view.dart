import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';

import '../theme/app_typography.dart';
import '../theme/theme_context_ext.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/header_text_button.dart';

/// Shown right after a subscription purchase has been successfully verified.
class SubscriptionSuccessView extends StatelessWidget {
  const SubscriptionSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AppScaffold(
      actions: [
        HeaderTextButton(
          label: "${l10n.commonNext} →",
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
      body: Center(
        child: Text(
          l10n.subscriptionSuccessTitle,
          textAlign: TextAlign.center,
          style: AppTypography.headlineSerif.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
