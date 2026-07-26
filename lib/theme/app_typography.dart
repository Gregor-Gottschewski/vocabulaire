import 'package:flutter/widgets.dart';

/// Named text styles for the typewriter-minimalist design.
class AppTypography {
  AppTypography._();

  static const _serif = 'Newsreader';
  static const _sans = 'Work Sans';

  /// Page titles (e.g. box name), Newsreader 32/600.
  static const headlineSerif = TextStyle(
    fontFamily: _serif,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.1,
  );

  /// Section title with letter spacing of 1.25
  static const sectionTitle = TextStyle(
    fontFamily: _sans,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.25,
  );

  /// Right-aligned key-value row values, Newsreader 15/600.
  static const serifValue = TextStyle(
    fontFamily: _serif,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Primary full-width button label, Newsreader 17/600.
  static const serifButton = TextStyle(
    fontFamily: _serif,
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  /// Regular body text, Work Sans 16/400.
  static const bodySans = TextStyle(
    fontFamily: _sans,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  /// Row/section labels, Work Sans 13.5/400.
  static const labelSans = TextStyle(
    fontFamily: _sans,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
  );

  /// Back-link and subline captions, Work Sans 13/400.
  static const captionSans = TextStyle(
    fontFamily: _sans,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  /// Secondary text link, Work Sans 14/400.
  static const linkSans = TextStyle(
    fontFamily: _sans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}
