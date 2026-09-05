import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
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

final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Lets the user request a password-reset email for an existing account.
class ResetPasswordView extends StatefulWidget {
  final String? email;

  const ResetPasswordView({super.key, this.email});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  late AppLocalizations _l10n;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email ?? "";
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (!_emailRegExp.hasMatch(email)) {
      await context.showAppError(AppException(AppError.authInvalidEmail));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.sendPasswordResetEmail(email);
      if (!mounted) return;
      await showAppDialog(
        context: context,
        title: _l10n.resetPasswordTitle,
        message: _l10n.resetPasswordSuccessMessage,
        actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      );
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppScaffold(
      backLabel: _l10n.loginTitle,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.resetPasswordTitle,
              style: AppTypography.headlineSerif.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.gapSmall),
            Text(
              _l10n.resetPasswordSubtitle,
              style: AppTypography.bodySans.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            LabelTextField(
              label: _l10n.resetPasswordEmailLabel.toUpperCase(),
              textField: AppTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const Spacer(),
            PrimaryActionButton(
              label: _l10n.resetPasswordSubmitButton,
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
