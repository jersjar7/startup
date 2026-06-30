import 'package:flutter/widgets.dart';

/// FE for Raccoons brand color tokens.
///
/// These mirror the website (`CLAUDE.md`) and the locked mobile visual
/// language ("calm canvas, confident color"): a neutral cream/white canvas
/// carries most of every screen; color appears only at hero, status, and
/// action moments.
abstract final class AppColors {
  // Canvas
  static const cream = Color(0xFFFFF9F0);
  static const creamDark = Color(0xFFF5EDE0);
  static const white = Color(0xFFFFFFFF);

  // Type
  static const charcoal = Color(0xFF2C2C2C); // primary text
  static const ink2 = Color(0xFF6B6358); // secondary
  static const ink3 = Color(0xFF9C9488); // tertiary

  // The standing accent (primary action, active tab, mastery ring, hand-off)
  static const ember = Color(0xFFE8683A);
  static const emberBg = Color(0xFFFEF0EA);

  // Mastery / correct / the reveal payoff
  static const forest = Color(0xFF2D7A5F);
  static const forestBg = Color(0xFFE8F5EE);

  // Streak / highlight (the one warm pop)
  static const sunbeam = Color(0xFFF5B731);
  static const sunbeamBg = Color(0xFFFEF7E0);

  // The struck-through wrong answer / error states
  static const error = Color(0xFFD64045);
  static const errorBg = Color(0xFFFCECEC);

  // Informational (e.g. "session expired")
  static const info = Color(0xFF3B82B8);
  static const infoBg = Color(0xFFEAF3F9);

  // Hairline divider — prefer 1px lines over boxes
  static const line = Color(0x1F2C2C2C); // rgba(44,44,44,.12)

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
