import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_context_ext.dart';

/// Application text field.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final TextStyle? style;
  final Widget? suffix;

  const AppTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.style,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseStyle = (style ?? AppTypography.bodySans).copyWith(
      color: colors.textPrimary,
    );
    return Material(
      type: MaterialType.transparency,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        maxLines: obscureText ? 1 : maxLines,
        maxLength: maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: baseStyle,
        cursorColor: colors.textPrimary,
        cursorWidth: 1,
        decoration: InputDecoration(
          counterText: '', // hide counter
          isDense: true,
          hintText: placeholder,
          hintStyle: baseStyle.copyWith(color: colors.textSecondary),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.gapMedium,
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colors.borderStrong,
              width: AppSpacing.hairline,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: colors.borderStrong,
              width: AppSpacing.hairline,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.textPrimary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
