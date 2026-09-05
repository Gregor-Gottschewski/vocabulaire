import 'dart:async';

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
import 'package:vocabulaire/views/widgets/primary_action_button.dart';

/// Show email address verification screen.
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  static const _pollInterval = Duration(seconds: 3);
  static const _resendCooldown = Duration(seconds: 60);

  late AppLocalizations _l10n;
  Timer? _pollTimer;
  Timer? _resendCountdownTimer;
  bool _isResending = false;
  int _resendCooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(
      _pollInterval,
      (_) => AuthService.instance.reloadUser(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _resendCountdownTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCountdownTimer?.cancel();
    setState(() => _resendCooldownSeconds = _resendCooldown.inSeconds);
    _resendCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _resendCooldownSeconds - 1;
      if (remaining <= 0) {
        _stopResendCooldown();
        return;
      }
      setState(() => _resendCooldownSeconds = remaining);
    });
  }

  void _stopResendCooldown() {
    _resendCountdownTimer?.cancel();
    _resendCountdownTimer = null;
    if (mounted) setState(() => _resendCooldownSeconds = 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context)!;
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await AuthService.instance.sendEmailVerification();
      if (!mounted) return;
      _startResendCooldown();
      await showAppDialog(
        context: context,
        title: _l10n.verifyEmailResendSuccessTitle,
        message: _l10n.verifyEmailResendSuccessMessage,
        actions: [AppDialogAction(label: _l10n.commonOk, onPressed: () {})],
      );
    } on AppException catch (e) {
      if (!mounted) return;
      await context.showAppError(e);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final email = AuthService.instance.currentUser?.email ?? '';
    return AppScaffold(
      backLabel: _l10n.settingsSignOut,
      onBack: () => AuthService.instance.signOut(),
      actions: [],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.verifyEmailTitle,
            style: AppTypography.headlineSerif.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.gapSmall),
          Text(
            _l10n.verifyEmailSubtitle(email),
            style: AppTypography.bodySans.copyWith(color: colors.textSecondary),
          ),
          const Spacer(),
          PrimaryActionButton(
            label: _resendCooldownSeconds > 0
                ? _l10n.verifyEmailResendCountdown(_resendCooldownSeconds)
                : _l10n.verifyEmailResend,
            onPressed: _isResending || _resendCooldownSeconds > 0
                ? null
                : _resendEmail,
          ),
        ],
      ),
    );
  }
}
