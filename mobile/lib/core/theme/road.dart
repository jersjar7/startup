import 'dart:math' as math;
import 'dart:ui';

import 'app_colors.dart';

/// The isometric chapter path (mobile/design/road/ROAD.md, owner 2026-11-03):
/// the `road` block of tokens.json, in logical points.
///
/// Shared by the road painter, the raccoon pin, the completion moment and
/// the lesson platforms, so the road and the platforms are built from one
/// set of numbers and can never drift apart.
abstract final class AppRoad {
  /// Ground depth on screen: depth is squashed to half, about a 30 degree
  /// view from above. Left and right are not squashed. Widths and curves are
  /// worked out on the ground, then projected; heights are added on screen.
  static const double k = 0.5;

  /// A ground point seen from above, raised [height] points.
  static Offset project(Offset ground, [double height = 0]) =>
      Offset(ground.dx, ground.dy * k - height);

  // ── the completion moment (ROAD.md, "The finishing moment") ──
  // Times run from when the finished lesson settles (its own pop has
  // played). Each value is milliseconds into the moment.

  /// The whole moment: 2.1 s.
  static const momentMs = 2100.0;

  /// 1. The next platform rises from [aheadScale] to 100% with a [lift]
  ///    point lift, ease out with a slight overshoot.
  static const riseStartMs = 0.0;
  static const riseEndMs = 300.0;

  /// 2. The road fills from pale to dark, ease in-out.
  static const fillStartMs = 150.0;
  static const fillEndMs = 1200.0;

  /// 3. The centre line reveals behind the fill, ease in-out.
  static const lineStartMs = 400.0;
  static const lineEndMs = 1200.0;

  /// 4. A small spring pulse runs the road to the next platform.
  static const pulseStartMs = 1200.0;
  static const pulseEndMs = 1800.0;

  /// 5. The next platform does one small bounce, to [arriveScale] and back.
  static const arriveStartMs = 1800.0;
  static const arriveEndMs = 2100.0;

  /// Reduce Motion: the segment and the pin cross-fade, nothing else moves.
  static const reducedFadeMs = 180.0;

  // ── the platforms' own motion, for the node widget ──

  /// A platform the walked road has not reached rests at 95%.
  static const aheadScale = 0.95;

  /// When `ahead` turns false the platform rises to 100% over [riseMs] with
  /// a lift of this many points (up and back down, a half sine).
  static const lift = 4.0;
  static const riseMs = 300.0;

  /// `arrive`: one bounce to 105% and back over [arriveMs].
  static const arriveScale = 1.05;
  static const arriveMs = 300.0;

  /// The rise's scale, `t` 0..1 over [riseMs]: 0.95 to 1 with a slight
  /// overshoot (ease out back, c = 1.7). Exactly the mockup's curve.
  static double riseScale(double t) {
    const c = 1.7;
    final u = t - 1;
    final back = 1 + (c + 1) * u * u * u + c * u * u;
    return aheadScale + (1 - aheadScale) * back;
  }

  /// The rise's lift in points, `t` 0..1: up [lift] and back down.
  static double riseLift(double t) =>
      lift * _sinPi(t.clamp(0.0, 1.0).toDouble());

  /// The arrival bounce's scale, `t` 0..1 over [arriveMs]: up to about 105%
  /// and back, easing out. Exactly the mockup's curve.
  static double arriveBounce(double t) {
    final b = t.clamp(0.0, 1.0).toDouble();
    return 1 + (arriveScale - 1) * _sinPi(b) * (1 - b * 0.3);
  }

  static double _sinPi(double t) => math.sin(math.pi * t);

  // ── the raccoon pin ──

  /// The spring ring around the coin, day and night.
  static const pinRing = 3.0;

  /// The contact shadow: black at 38%, blurred 1.2.
  static const pinShadowAlpha = 0.38;
  static const pinShadowBlur = 1.2;

  /// Labels start this far from the platform's edge, phone and tablet.
  static const labelGap = 28.0;
}

/// One device's road and platform sizes (ROAD.md, "The view"; TABLET.md,
/// "The path gets bigger").
///
/// Geometry of a platform, which the node widget and the road share:
/// - the face is the node circle squashed to half height: [platform] wide,
///   `platform * AppRoad.k` tall;
/// - it stands on a plinth [plinth] tall; the plinth's foot is the face's
///   ellipse moved straight down by [plinth];
/// - the node widget's box is `platform` wide and `platform * k + plinth`
///   tall: the face centre is at (platform / 2, platform * k / 2) in the
///   box, the foot's centre [plinth] below it ([PlatformBox]).
class RoadSize {
  const RoadSize._({
    required this.platform,
    required this.plinth,
    required this.road,
    required this.width,
    required this.rim,
    required this.line,
    required this.dash,
    required this.gap,
    required this.blur,
    required this.shadowY,
    required this.row,
    required this.sectionGap,
    required this.amp,
    required this.coin,
    required this.pinRest,
  });

  static const phone = RoadSize._(
    platform: 84,
    plinth: 14,
    road: 8,
    width: 20,
    rim: 2,
    line: 2,
    dash: 7,
    gap: 9,
    blur: 3,
    shadowY: 4,
    row: 120,
    sectionGap: 48,
    amp: 70,
    coin: 32,
    pinRest: 0.72,
  );

  static const tablet = RoadSize._(
    platform: 92,
    plinth: 16,
    road: 9,
    width: 24,
    rim: 2,
    line: 2.5,
    dash: 9,
    gap: 10,
    blur: 3.5,
    shadowY: 5,
    row: 150,
    sectionGap: 54,
    amp: 110,
    coin: 36,
    pinRest: 0.55,
  );

  /// The platform's face, node width (the face ellipse's long axis).
  final double platform;

  /// How tall a platform stands: its plinth.
  final double plinth;

  /// How tall the road's slab stands, a little over half a platform.
  final double road;

  /// The road's width on the ground, about a quarter of a platform.
  final double width;

  /// The lit rim on both edges of the road's top.
  final double rim;

  /// The dashed centre line: width, dash, gap.
  final double line;
  final double dash;
  final double gap;

  /// The road's shadow on the ground: blur and how far below the road.
  final double blur;
  final double shadowY;

  /// Rows apart on screen, and what a section name adds.
  final double row;
  final double sectionGap;

  /// The weave either side of the middle line, at most.
  final double amp;

  /// The raccoon pin's coin, and where it rests: this far into the segment
  /// leading to the lesson the student goes to next.
  final double coin;
  final double pinRest;

  /// The contact shadow under the pin: a ground circle the width of the
  /// road's top plus 2, squashed like everything on the ground.
  double get pinFoot => width - 2 * rim + 2;
}

/// Where the parts of one platform sit inside the node widget's box, for a
/// platform [width] wide standing [plinth] tall.
class PlatformBox {
  const PlatformBox(this.width, this.plinth);

  final double width;
  final double plinth;

  double get rx => width / 2;
  double get ry => width / 2 * AppRoad.k;

  /// The box: the face's top to the foot's bottom.
  Size get size => Size(width, 2 * ry + plinth);

  /// The face's centre, and the foot's (on the ground).
  Offset get face => Offset(rx, ry);
  Offset get foot => Offset(rx, ry + plinth);

  /// The face ellipse, the foot ellipse.
  Rect get faceRect =>
      Rect.fromCenter(center: face, width: width, height: 2 * ry);
  Rect get footRect =>
      Rect.fromCenter(center: foot, width: width, height: 2 * ry);

  /// The point the rise and the bounce scale around: the middle of the side.
  Offset get scaleOrigin => Offset(rx, ry + plinth / 2);
}

/// The road's colours by role (ROAD.md, "One material"), day and night.
/// The road and the platforms are one material: a top over the plinth tan.
abstract final class RoadColors {
  /// The platforms' sides and the road's side wall.
  static const plinth = ThemedColor(0xFFCDBFA8, 0xFF5A544C);

  /// Walked road: the top, its lit rim on both edges, the centre line.
  static const walkedTop = ThemedColor(0xFF2C2C2C, 0xFF34312C);
  static const walkedRim = ThemedColor(0xFF47453F, 0xFF4A463F);
  static const centreLine = ThemedColor(0xFFFFF9F0, 0xFFF2ECE2);

  /// Road ahead: the top and its rim.
  static const aheadTop = ThemedColor(0xFFF5EDE0, 0xFF272522);
  static const aheadRim = ThemedColor(0xFFFFF9F0, 0xFF3A3732);

  /// The road's shadow on the ground: pipOff by day, black at 50% at night.
  static const shadow = ThemedColor(0x382C2C2C, 0x80000000);

  /// The pulse that runs ahead, and the pin's ring: spring in both modes.
  static const pulse = AppColors.spring;

  /// The pin's coin: the brand charcoal in both modes (an object, like the
  /// badge coins, not a surface).
  static const pinCoin = Color(0xFF2C2C2C);
}
