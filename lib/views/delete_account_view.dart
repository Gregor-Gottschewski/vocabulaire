import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/services/local_data_deletion_service.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/services/auth_service.dart';
import 'package:vocabulaire/theme/app_spacing.dart';
import 'package:vocabulaire/theme/app_typography.dart';
import 'package:vocabulaire/theme/theme_context_ext.dart';
import 'package:vocabulaire/views/widgets/app_dialog.dart';
import 'package:vocabulaire/views/widgets/app_scaffold.dart';
import 'package:vocabulaire/views/widgets/app_text_field.dart';
import 'package:vocabulaire/views/widgets/label_text_field.dart';
import 'package:vocabulaire/views/widgets/primary_action_button.dart';

/// Account deletion view.
class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  @override
  State<StatefulWidget> createState() => _DeleteAccountView();
}

class _DeleteAccountView extends State<DeleteAccountView> {
  final TextEditingController _passwordController = TextEditingController();
  late AppLocalizations _l10n;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<void> _confirmAndDelete() async {
    final password = _passwordController.text;

    await showAppDialog(
      context: context,
      title: _l10n.deleteAccountConfirmTitle,
      message: _l10n.deleteAccountConfirmMessage,
      actions: [
        AppDialogAction(label: _l10n.commonCancel, onPressed: () {}),
        AppDialogAction(
          label: _l10n.deleteAccountConfirmButton,
          destructive: true,
          onPressed: () => _deleteAccount(password),
        ),
      ],
    );
  }

  Future<void> _deleteAccount(String password) async {
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.deleteAccount(currentPassword: password);
      await LocalDataDeletionService.instance.clearLocalData();
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
      if (e.error == AppError.authWrongPassword) {
        _passwordController.text = "";
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppScaffold(
      backLabel: _l10n.settingsTitle,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.deleteAccountTitle,
              style: AppTypography.headlineSerif.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.gapSmall),
            Text(
              _l10n.deleteAccountSubtitle,
              style: AppTypography.bodySans.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            LabelTextField(
              label: _l10n.deleteAccountPasswordLabel.toUpperCase(),
              textField: AppTextField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _confirmAndDelete(),
              ),
            ),
            const Spacer(),
            PrimaryActionButton(
              label: _l10n.deleteAccountSubmitButton,
              onPressed: _isLoading ? null : _confirmAndDelete,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
