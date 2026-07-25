import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Builds the app's ThemeData.
class AppTheme {
  AppTheme._();

  static ThemeData _build(AppColors colors, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      fontFamily: 'Work Sans',
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      dividerColor: colors.borderSubtle,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.textPrimary,
        brightness: brightness,
        surface: colors.background,
        error: colors.danger,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.textPrimary,
        selectionColor: colors.textPrimary.withValues(alpha: 0.2),
        selectionHandleColor: colors.textPrimary,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      extensions: [colors],
    );
  }

  static final light = _build(AppColors.light, Brightness.light);
  static final dark = _build(AppColors.dark, Brightness.dark);
}
