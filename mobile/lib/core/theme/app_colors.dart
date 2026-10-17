import 'package:flutter/widgets.dart';

/// Which of the two palettes the app is drawing with (point 9, dark mode,
/// "Warm night", owner 2026-10-17). Set by [ThemeModeHost] before the tree
/// is rebuilt; read by every [ThemedColor] whenever anything paints.
abstract final class AppPalette {
  static bool dark = false;
}

/// A colour with a day value and a night value, still `const`.
///
/// Every token below is one, so the 375 game boards and every screen follow
/// the mode without a single call site changing: a [Paint], a [TextStyle]
/// or a decoration reads [a], [r], [g] and [b] when it is used, and those
/// answer for [AppPalette.dark] at that moment. Flipping the mode therefore
/// needs everything to build and paint again, which [ThemeModeHost] asks for.
class ThemedColor extends Color {
  const ThemedColor(super.light, this.night) : day = light;

  /// The ARGB values for each mode.
  final int day;
  final int night;

  int get _now => AppPalette.dark ? night : day;

  @override
  double get a => ((_now >> 24) & 0xff) / 255;
  @override
  double get r => ((_now >> 16) & 0xff) / 255;
  @override
  double get g => ((_now >> 8) & 0xff) / 255;
  @override
  double get b => (_now & 0xff) / 255;
}

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
  static const fog = ThemedColor(0xFFE3DFD7, 0xFF1B1A18); // the screen ground
  static const cream = ThemedColor(0xFFFFF9F0, 0xFF272522); // paper: sheets, light tiles
  static const creamDark = ThemedColor(0xFFF5EDE0, 0xFF312E2A); // second light tile
  static const white = ThemedColor(0xFFFFFFFF, 0xFF24221F);

  /// The engineering paper every figure is drawn on. By night the board
  /// ("Warm night"): every figure's ink and fills are tokens that follow the
  /// mode, so the paper has to as well.
  static const paper = ThemedColor(0xFFFDFCF8, 0xFF24221F);

  // Charcoal and its dark surfaces
  static const charcoal = ThemedColor(0xFF2C2C2C, 0xFFF2ECE2); // text; dark tiles, dock, round buttons
  static const tile = ThemedColor(0xFF3A3936, 0xFF34312C); // dark surface: the dock, the mastery row
  static const tile2 = ThemedColor(0xFF47453F, 0xFF403C36); // surface on tile
  static const lineOnDark = ThemedColor(0xFF4F4C45, 0xFF4A463F); // the rare divider on a dark tile

  // Type
  static const ink2 = ThemedColor(0xFF6B6358, 0xFFA89F93); // secondary on fog or cream
  /// The kit's name for [ink2]: secondary text on fog or cream.
  static const mutedOnLight = ink2;

  /// Text and icons on a bright fill that stays bright at night: the spring
  /// circle on a pill, the active dock item, a spring tile. Dark in both
  /// modes, since the fill under it never darkens.
  static const onAccent = Color(0xFF2C2C2C);

  /// Text on a dark tile (the streak row, the mastery row). Light in both
  /// modes, since the tile stays dark.
  static const onTile = ThemedColor(0xFFFFF9F0, 0xFFF2ECE2);
  static const ink3 = ThemedColor(0xFF9C9488, 0xFF7D756B); // tertiary on light
  static const mutedOnDark = ThemedColor(0xFFB5ADA3, 0xFFA89F93); // secondary on charcoal or tile
  static const placeholder = ThemedColor(0xFF8C8377, 0xFF7A7268);

  // THE accent: fills only, never text on a light surface
  static const spring = ThemedColor(0xFF63F0A8, 0xFF63F0A8);

  /// Spring as a FIELD: a ground, a hero tile, the right-answer panel, the
  /// chapter in flight. Bright by day; at night a deep green, so a screen
  /// keeps its colour turned down ("Warm night") instead of glaring. What
  /// sits on it is charcoal by day and light at night, so it needs nothing.
  static const springField = ThemedColor(0xFF63F0A8, 0xFF1C4532);

  /// Spring as a mark ON a charcoal fill (a round button's arrow, a check in
  /// a charcoal circle, a selected chip's label). Charcoal turns light at
  /// night, so the mark turns a deep green to stay readable on it.
  static const springOnDark = ThemedColor(0xFF63F0A8, 0xFF1E7A4E);

  /// The badge coins' colours, the same in both modes: a coin is an object,
  /// not a surface, so it does not darken.
  static const butterCoin = Color(0xFFF9D28A);
  static const forestCoin = Color(0xFF2D7A5F);

  // The identity accent: hot ground, warnings, the mastery figure
  static const ember = ThemedColor(0xFFE8683A, 0xFFF27A4C);

  /// Ember's hue at L 0.84. The hot GROUND: every surface that was ember
  /// is peach (owner's call, 2026-09-18). Ember itself stays for text,
  /// strokes and the mastery figure.
  static const peach = ThemedColor(0xFFFEB89C, 0xFF3A2219);
  static const emberBg = ThemedColor(0xFFFEF0EA, 0xFF3A2219);

  // The brand green as text, marks and counts on light surfaces
  static const forest = ThemedColor(0xFF2D7A5F, 0xFF5FD69A);
  static const forestBg = ThemedColor(0xFFE8F5EE, 0xFF1C3328);

  /// Forest, lightened enough to read on charcoal.
  static const mint = ThemedColor(0xFF7FC3A5, 0xFF7FC3A5);

  // Streak, days studied, highlight
  static const sunbeam = ThemedColor(0xFFF5B731, 0xFFF5B731);

  /// Sunbeam's hue at L 0.88: the yellow GROUND, as peach is to ember.
  /// Every surface that was sunbeam is butter (owner's call, 2026-09-18);
  /// sunbeam itself stays for pips, highlights and small marks.
  static const butter = ThemedColor(0xFFF9D28A, 0xFF2B2418);
  static const sunbeamBg = ThemedColor(0xFFFEF7E0, 0xFF2E2717);

  // Errors
  static const error = ThemedColor(0xFFD64045, 0xFFF06A6E);
  static const errorBg = ThemedColor(0xFFFCECEC, 0xFF3A1E1F);

  // Informational (e.g. "session expired")
  static const info = ThemedColor(0xFF3B82B8, 0xFF6AA8DA);
  static const infoBg = ThemedColor(0xFFEAF3F9, 0xFF1B2A36);

  // Hairline divider. The app language has no hairlines; this stays for the
  // screens not yet restyled.
  static const line = ThemedColor(0x1F2C2C2C, 0x24F2ECE2);

  /// Unfilled progress pip on any light or accent surface.
  static const pipOff = ThemedColor(0x382C2C2C, 0x33F2ECE2);

  /// Mastery color by percent, matching the web exactly:
  /// forest >=90, sunbeam >=70, ember >0, neutral at 0.
  static Color masteryColor(int pct) {
    if (pct >= 90) return forest;
    if (pct >= 70) return sunbeam;
    if (pct > 0) return ember;
    return const ThemedColor(0xFFCDBFA8, 0xFF5A544C);
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
