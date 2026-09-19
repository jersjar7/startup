import 'package:flutter/widgets.dart';

/// FE for Raccoons color tokens for the phone.
///
/// The website's hues, moved to the roles an app needs (`mobile/design/`,
/// ADR 0016). The ground is fog, a warm light grey; charcoal is text and dark
/// tiles and is never a background; spring is the one loud accent; forest is
/// the only green allowed as text on a light surface.
///
/// Older names (`ink2`, `ink3`, `white`, `line`, the `*Bg` tints) stay so the
/// 375 game boards keep compiling. They are restyled in their own step; see
/// the "Translating our screens" table in `mobile/design/DESIGN.md`.
abstract final class AppColors {
  // Grounds and paper
  static const fog = Color(0xFFE3DFD7); // the screen ground
  static const cream = Color(0xFFFFF9F0); // paper: sheets, light tiles
  static const creamDark = Color(0xFFF5EDE0); // second light tile
  static const white = Color(0xFFFFFFFF);

  // Charcoal and its dark surfaces
  static const charcoal = Color(
    0xFF2C2C2C,
  ); // text; dark tiles, dock, round buttons
  static const tile = Color(
    0xFF3A3936,
  ); // dark surface: the dock, the mastery row
  static const tile2 = Color(0xFF47453F); // surface on tile
  static const lineOnDark = Color(
    0xFF4F4C45,
  ); // the rare divider on a dark tile

  // Type
  static const ink2 = Color(0xFF6B6358); // secondary on fog or cream
  static const ink3 = Color(0xFF9C9488); // tertiary on light
  static const mutedOnDark = Color(0xFFB5ADA3); // secondary on charcoal or tile
  static const placeholder = Color(0xFF8C8377);

  // THE accent: fills only, never text on a light surface
  static const spring = Color(0xFF63F0A8);

  // The identity accent: hot ground, warnings, the mastery figure
  static const ember = Color(0xFFE8683A);

  /// Ember's hue at L 0.84. The hot GROUND: every surface that was ember
  /// is peach (owner's call, 2026-09-18). Ember itself stays for text,
  /// strokes and the mastery figure.
  static const peach = Color(0xFFFEB89C);
  static const emberBg = Color(0xFFFEF0EA);

  // The brand green as text, marks and counts on light surfaces
  static const forest = Color(0xFF2D7A5F);
  static const forestBg = Color(0xFFE8F5EE);

  /// Forest, lightened enough to read on charcoal.
  static const mint = Color(0xFF7FC3A5);

  // Streak, days studied, highlight; the third ground
  static const sunbeam = Color(0xFFF5B731);
  static const sunbeamBg = Color(0xFFFEF7E0);

  // Errors
  static const error = Color(0xFFD64045);
  static const errorBg = Color(0xFFFCECEC);

  // Informational (e.g. "session expired")
  static const info = Color(0xFF3B82B8);
  static const infoBg = Color(0xFFEAF3F9);

  // Hairline divider. The app language has no hairlines; this stays for the
  // screens not yet restyled.
  static const line = Color(0x1F2C2C2C);

  /// Unfilled progress pip on any light or accent surface.
  static const pipOff = Color(0x382C2C2C);

  /// Mastery color by percent, matching the web exactly:
  /// forest >=90, sunbeam >=70, ember >0, neutral at 0.
  static Color masteryColor(int pct) {
    if (pct >= 90) return forest;
    if (pct >= 70) return sunbeam;
    if (pct > 0) return ember;
    return const Color(0xFFCDBFA8);
  }

  /// Mastery stage word, matching the web: Mastered >=80, Familiar >=50,
  /// Building >=10, New otherwise.
  static String masteryStage(int pct) {
    if (pct >= 80) return 'Mastered';
    if (pct >= 50) return 'Familiar';
    if (pct >= 10) return 'Building';
    return 'New';
  }
}
