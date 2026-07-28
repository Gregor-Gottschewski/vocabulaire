import 'package:flutter/material.dart';

/// Warm, typewriter-minimalist color palette. Values are converted from the
/// oklch() colors defined in new-design.html (Dart has no native oklch()
/// support) via the reference OKLab/OKLCH -> sRGB matrices.
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLabel;
  final Color textLink;
  final Color borderStrong;
  final Color borderSubtle;
  final Color danger;
  final Color highlight;
  final Color ratingAgain;
  final Color ratingHard;
  final Color ratingGood;
  final Color ratingEasy;

  const AppColors({
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLabel,
    required this.textLink,
    required this.borderStrong,
    required this.borderSubtle,
    required this.danger,
    required this.highlight,
    required this.ratingAgain,
    required this.ratingHard,
    required this.ratingGood,
    required this.ratingEasy,
  });

  static const light = AppColors(
    background: Color(0xFFFDFBF7),
    textPrimary: Color(0xFF14110D),
    textSecondary: Color(0xFF66635D),
    textLabel: Color(0xFF58554F),
    textLink: Color(0xFF302D28),
    borderStrong: Color(0xFFD8D4CD),
    borderSubtle: Color(0xFFE7E4E0),
    danger: Color(0xFFA7391E),
    highlight: Color(0xFF3D5A80),
    ratingAgain: Color(0xFFA7391E),
    ratingHard: Color(0xFFBD821A),
    ratingGood: Color(0xFF707836),
    ratingEasy: Color(0xFF2B6241),
  );

  static const dark = AppColors(
    background: Color(0xFF100D09),
    textPrimary: Color(0xFFE8E4DD),
    textSecondary: Color(0xFF898680),
    textLabel: Color(0xFF9B9891),
    textLink: Color(0xFFC1BDB7),
    borderStrong: Color(0xFF36322D),
    borderSubtle: Color(0xFF262421),
    danger: Color(0xFFD05F43),
    highlight: Color(0xFF8FB4E3),
    ratingAgain: Color(0xFFD05F43),
    ratingHard: Color(0xFFDEA143),
    ratingGood: Color(0xFF969F5D),
    ratingEasy: Color(0xFF57966E),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? textLabel,
    Color? textLink,
    Color? borderStrong,
    Color? borderSubtle,
    Color? danger,
    Color? highlight,
    Color? ratingAgain,
    Color? ratingHard,
    Color? ratingGood,
    Color? ratingEasy,
  }) {
    return AppColors(
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textLabel: textLabel ?? this.textLabel,
      textLink: textLink ?? this.textLink,
      borderStrong: borderStrong ?? this.borderStrong,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      danger: danger ?? this.danger,
      highlight: highlight ?? this.highlight,
      ratingAgain: ratingAgain ?? this.ratingAgain,
      ratingHard: ratingHard ?? this.ratingHard,
      ratingGood: ratingGood ?? this.ratingGood,
      ratingEasy: ratingEasy ?? this.ratingEasy,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textLabel: Color.lerp(textLabel, other.textLabel, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      ratingAgain: Color.lerp(ratingAgain, other.ratingAgain, t)!,
      ratingHard: Color.lerp(ratingHard, other.ratingHard, t)!,
      ratingGood: Color.lerp(ratingGood, other.ratingGood, t)!,
      ratingEasy: Color.lerp(ratingEasy, other.ratingEasy, t)!,
    );
  }
}
