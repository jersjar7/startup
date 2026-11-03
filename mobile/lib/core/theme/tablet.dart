import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// The three window sizes the app lays itself out for (TABLET.md section 1,
/// ADR 0039). Chosen by the width of the app's WINDOW, never by the device:
/// an iPad in split screen beside the Handbook is a phone-width window and
/// gets the phone, exactly.
enum SizeClass {
  /// Under 600: the phone app, byte for byte.
  compact,

  /// 600 to 899: one pane, drawn larger, with the rail.
  medium,

  /// 900 and up: two panes where a screen has two things.
  expanded;

  bool get isTablet => this != compact;
}

/// The `tablet` block of `mobile/design/tokens.json`, in logical points.
/// Everything else on a tablet uses the phone's tokens unchanged.
abstract final class AppTablet {
  // breakpoint
  static const double medium = 600;
  static const double expanded = 900;

  /// At this window width or more the concept sheet opens beside a round
  /// instead of over it.
  static const double conceptBeside = 960;

  /// Under this window height panes scroll as one column.
  static const double shortHeight = 560;

  // size
  static const double rail = 104;
  static const double pillMax = 440;

  // pane
  static const double paneLeading = 400;
  static const double paneConceptSheet = 460;
  static const double paneSheetMax = 640;

  // measure
  static const double measureBody = 620;

  // space
  static const double spaceTop = 24;
  static const double paneX = 32;
  static const double paneGap = 24;
  static const double screenX = 48;

  // figure
  /// How far a drawing's strokes and labels may grow with its box.
  static const double figureMaxScale = 1.6;

  /// The phone's figure width; a drawing's scale is its box over this.
  static const double phoneFigureWidth = 342;

  /// The width an unmoved game's single column is capped at in a wide
  /// window (TABLET.md, "A round").
  static const double roundColumnMax = 640;

  /// The right column of a round with its drawing beside it.
  static const double roundAnswerColumn = 420;

  /// The pips across the top of a round stop growing here.
  static const double pipsMax = 560;

  /// The figure scale of TABLET.md section 5: `clamp(box / 342, 1, 1.6)`.
  static double figureScale(double boxWidth) =>
      (boxWidth / phoneFigureWidth).clamp(1.0, figureMaxScale);

  static SizeClass classFor(double width) => width >= expanded
      ? SizeClass.expanded
      : width >= medium
      ? SizeClass.medium
      : SizeClass.compact;

  /// The window's class, re-read on every size change (rotation, a split
  /// divider, an iPadOS window being resized).
  static SizeClass of(BuildContext context) =>
      classFor(MediaQuery.sizeOf(context).width);

  static bool isTablet(BuildContext context) => of(context).isTablet;

  /// A window too short to lay panes side by side.
  static bool isShort(BuildContext context) =>
      MediaQuery.sizeOf(context).height < shortHeight;

  // type
  static TextStyle headlineXL({Color color = AppColors.charcoal}) =>
      GoogleFonts.dmSans(
        fontSize: 64,
        height: 0.96,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.045 * 64,
        color: color,
      );

  static TextStyle heroXL({Color color = AppColors.charcoal}) =>
      GoogleFonts.dmSans(
        fontSize: 150,
        height: 0.82,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.07 * 150,
        color: color,
      );

  static TextStyle bodyTablet({
    Color color = AppColors.charcoal,
    FontWeight weight = FontWeight.w400,
  }) => GoogleFonts.inter(
    fontSize: 17,
    height: 1.5,
    fontWeight: weight,
    color: color,
  );
}
