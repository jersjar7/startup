import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// The app theme, built on the locked visual language.
///
/// - **DM Sans** carries headings (big, confident; hierarchy by type not color).
/// - **Inter** is body and secondary text.
/// - **JetBrains Mono** is all numbers, formulas, and data — use
///   [AppTheme.mono] where a value is shown.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ember,
        primary: AppColors.ember,
        surface: AppColors.cream,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      splashFactory: InkRipple.splashFactory,
    );

    // Body text is Inter; headings get overridden to DM Sans where used.
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.charcoal,
      displayColor: AppColors.charcoal,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Heading style (DM Sans). Tight tracking, weighted for confidence.
  static TextStyle heading({
    double size = 27,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.charcoal,
    double height = 1.1,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: -0.03 * size,
    );
  }

  /// Monospace style (JetBrains Mono) for numbers, formulas, and data.
  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.charcoal,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  /// Code and formulas exactly as they are typed.
  ///
  /// The mono face draws ">=" and "->" as single glyphs, which is handsome in
  /// an editor and wrong on a page teaching somebody what to type into a
  /// spreadsheet or read off an exam paper. This is [mono] with those
  /// substitutions turned off.
  static TextStyle code({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.charcoal,
  }) {
    return mono(size: size, weight: weight, color: color).copyWith(
      fontFeatures: const [FontFeature.disable('calt')],
    );
  }

  /// Display (DM Sans 800, tight): headlines, hero numbers, tile numbers.
  /// The app language's dominant element on every screen.
  static TextStyle display({
    double size = 48,
    FontWeight weight = FontWeight.w800,
    Color color = AppColors.charcoal,
    double height = 0.98,
    double tracking = -0.045,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: tracking * size,
    );
  }

  /// Eyebrow (JetBrains Mono 600, uppercase, +0.06em): the only uppercase
  /// text in the app language. Pass the text already uppercased.
  static TextStyle eyebrow({double size = 12, Color color = AppColors.charcoal}) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.06 * size,
    );
  }

  /// Body (Inter).
  static TextStyle body({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.charcoal,
    double height = 1.4,
  }) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color, height: height);
  }

  /// Overline / kicker (DM Sans 600, uppercase, tracked).
  static TextStyle overline({Color color = AppColors.ink3}) {
    return GoogleFonts.dmSans(
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.05,
    );
  }
}
