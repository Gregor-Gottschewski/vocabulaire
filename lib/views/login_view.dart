import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocabulaire/l10n/app_localizations.dart';
import 'package:vocabulaire/services/app_exception.dart';
import 'package:vocabulaire/services/app_exception_ui.dart';
import 'package:vocabulaire/services/auth_service.dart';
import 'package:vocabulaire/theme/app_page_route.dart';
import 'package:vocabulaire/theme/app_spacing.dart';
import 'package:vocabulaire/theme/app_typography.dart';
import 'package:vocabulaire/theme/theme_context_ext.dart';
import 'package:vocabulaire/views/reset_password_view.dart';
import 'package:vocabulaire/views/widgets/app_scaffold.dart';
import 'package:vocabulaire/views/widgets/app_text_field.dart';
import 'package:vocabulaire/views/widgets/label_text_field.dart';
import 'package:vocabulaire/views/widgets/primary_action_button.dart';
import 'package:vocabulaire/views/widgets/text_link_button.dart';

final _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Login screen that combines sign-in and registration in a single form, toggled via [_isRegisterMode].
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AppLocalizations _l10n;
  bool _isRegisterMode = false;
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
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!_emailRegExp.hasMatch(email)) {
      await context.showAppError(AppException(AppError.authInvalidEmail));
      return;
    }

    if (_isRegisterMode) {
      final passwordStatus = await AuthService.instance.validatePassword(
        password: password,
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
    }

    setState(() => _isLoading = true);
    try {
      UserCredential credentials;
      if (_isRegisterMode) {
        credentials = await AuthService.instance.register(
          email: email,
          password: password,
        );
      } else {
        credentials = await AuthService.instance.signIn(
          email: email,
          password: password,
        );
      }
      if (credentials.user == null) {
        throw AppException(AppError.authUnknownError);
      }
      if (!credentials.user!.emailVerified) {
        credentials.user?.sendEmailVerification();
      }
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
      if (e.error == AppError.authWrongPassword) {
        _passwordController.text = "";
      }
      if (e.error == AppError.authEmailAlreadyInUse) {
        setState(() => _isRegisterMode = false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  void _openResetPassword() {
    Navigator.of(context).push(
      AppPageRoute(
        builder: (_) => ResetPasswordView(email: _emailController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppScaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRegisterMode ? _l10n.registerTitle : _l10n.loginTitle,
                  style: AppTypography.headlineSerif.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapSmall),
                Text(
                  _l10n.loginSubtitle,
                  style: AppTypography.bodySans.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                LabelTextField(
                  label: _l10n.loginEmailLabel.toUpperCase(),
                  textField: AppTextField(
                    controller: _emailController,
                    autofillHints: const [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: AppSpacing.gapMedium),
                LabelTextField(
                  label: _l10n.loginPasswordLabel.toUpperCase(),
                  textField: AppTextField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                if (!_isRegisterMode) ...[
                  const SizedBox(height: AppSpacing.gapSmall),
                  TextLinkButton(
                    label: _l10n.loginForgotPassword,
                    onPressed: _openResetPassword,
                  ),
                ],
                const SizedBox(height: AppSpacing.sectionGap),
                PrimaryActionButton(
                  label: _isRegisterMode
                      ? _l10n.registerSubmitButton
                      : _l10n.loginSubmitButton,
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.gapMedium),
                TextLinkButton(
                  label: _isRegisterMode
                      ? _l10n.loginSwitchToLogin
                      : _l10n.loginSwitchToRegister,
                  onPressed: () =>
                      setState(() => _isRegisterMode = !_isRegisterMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
