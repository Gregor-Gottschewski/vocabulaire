import 'package:firebase_auth/firebase_auth.dart';
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

/// User password change view.
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<StatefulWidget> createState() => _ChangePasswordView();
}

class _ChangePasswordView extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late AppLocalizations _l10n;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  List<String> _missingPasswordRequirements(PasswordValidationStatus status) {
    final policy = status.passwordPolicy;
    return [
      if (!status.meetsMinPasswordLength)
        _l10n.passwordRequirementMinLength(policy.minPasswordLength),
      if (!status.meetsMaxPasswordLength)
        _l10n.passwordRequirementMaxLength(policy.maxPasswordLength!),
      if (!status.meetsLowercaseRequirement) _l10n.passwordRequirementLowercase,
      if (!status.meetsUppercaseRequirement) _l10n.passwordRequirementUppercase,
      if (!status.meetsDigitsRequirement) _l10n.passwordRequirementDigit,
      if (!status.meetsSymbolsRequirement) _l10n.passwordRequirementSymbol,
    ];
  }

  Future<void> _submit() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      await context.showAppError(
        AppException(AppError.authPasswordsDoNotMatch),
      );
      return;
    }

    final passwordStatus = await AuthService.instance.validatePassword(
      password: newPassword,
    );
    if (!passwordStatus.isValid) {
      final requirements = _missingPasswordRequirements(passwordStatus);
      if (!mounted) return;
      await context.showAppError(
        AppException(
          AppError.authWeakPasswordDetailed,
          details: requirements.join(', '),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!mounted) return;
      await showAppDialog(
        context: context,
        title: _l10n.changePasswordSuccessTitle,
        message: _l10n.changePasswordSuccessMessage,
        actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      );
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
      if (e.error == AppError.authWrongPassword) {
        _currentPasswordController.text = "";
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
              _l10n.changePasswordTitle,
              style: AppTypography.headlineSerif.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.gapSmall),
            Text(
              _l10n.changePasswordSubtitle,
              style: AppTypography.bodySans.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            LabelTextField(
              label: _l10n.changePasswordCurrentPasswordLabel.toUpperCase(),
              textField: AppTextField(
                controller: _currentPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.gapMedium),
            LabelTextField(
              label: _l10n.changePasswordNewPasswordLabel.toUpperCase(),
              textField: AppTextField(
                controller: _newPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.gapMedium),
            LabelTextField(
              label: _l10n.changePasswordConfirmPasswordLabel.toUpperCase(),
              textField: AppTextField(
                controller: _confirmPasswordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const Spacer(),
            PrimaryActionButton(
              label: _l10n.changePasswordSubmitButton,
              onPressed: _isLoading ? null : _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
