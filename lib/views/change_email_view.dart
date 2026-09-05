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

/// User email address change view.
class ChangeEmailView extends StatefulWidget {
  const ChangeEmailView({super.key});

  @override
  State<StatefulWidget> createState() => _ChangeEmailView();
}

class _ChangeEmailView extends State<ChangeEmailView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AppLocalizations _l10n;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<void> _submit() async {
    final newEmail = _emailController.text.trim();
    final password = _passwordController.text;
    final currentEmail = AuthService.instance.currentUser?.email;

    if (!_emailRegExp.hasMatch(newEmail)) {
      await context.showAppError(AppException(AppError.authInvalidEmail));
      return;
    }

    if (newEmail.toLowerCase() == currentEmail!.toLowerCase()) {
      await context.showAppError(AppException(AppError.authEmailAlreadyInUse));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.changeEmail(
        newEmail: newEmail,
        currentPassword: password,
      );
      if (!mounted) return;
      await showAppDialog(
        context: context,
        title: _l10n.changeEmailSuccessTitle,
        message: _l10n.changeEmailSuccessMessage,
        actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      );
      if (mounted) Navigator.of(context).pop();
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
    final currentEmail = AuthService.instance.currentUser?.email ?? '';
    return AppScaffold(
      backLabel: _l10n.settingsTitle,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.changeEmailTitle,
              style: AppTypography.headlineSerif.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.gapSmall),
            Text(
              _l10n.changeEmailSubtitle(currentEmail),
              style: AppTypography.bodySans.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            LabelTextField(
              label: _l10n.changeEmailPasswordLabel.toUpperCase(),
              textField: AppTextField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: AppSpacing.gapMedium),
            LabelTextField(
              label: _l10n.changeEmailNewEmailLabel.toUpperCase(),
              textField: AppTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
            ),
            const Spacer(),
            PrimaryActionButton(
              label: _l10n.changeEmailSubmitButton,
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
