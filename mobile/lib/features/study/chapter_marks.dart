import 'package:flutter/material.dart';

/// A line drawing for each chapter, drawn on the chapter card.
///
/// Fifteen chapter names set in the same weight of type all look the same,
/// and a student has to read every one to find the one they want. Fifteen
/// drawings do not: a truss is Statics, a manometer is Fluids, a footing on
/// layered ground is Geotechnical. After a couple of days a chapter is found
/// by its shape, which is faster than reading.
///
/// **They are designed on a 512 square and scaled down.** The first version
/// was drawn straight into the 46 points a card gives it, and it showed: the
/// Geotechnical mark came out as a scribble because four hatch ticks will not
/// fit in 46 points, and every drawing was really a diagram of a diagram.
/// Drawing them at a size where the geometry can be correct, and then
/// shrinking, gives icons that are right first and small second. It also
/// means these same paths can be used anywhere bigger later without redrawing
/// them.
///
/// The mark is NOT put in a box. Its COLOR says where the chapter stands
/// (quiet when untouched, forest once started, ember for the one in flight,
/// mint on charcoal when cleared), which is the job a tinted panel behind it
/// used to do badly.
///
/// Conventions, so that fifteen drawings by the same hand look like it:
/// - the design square is 512 by 512 and the drawing lives inside a 64 point
///   margin, so nothing touches the edge;
/// - `_heavy` (20) is structure, `_fine` (13) is annotation, `_bar` (34) is
///   a filled bar;
/// - round caps and joins throughout, no fills except small solid markers;
/// - each drawing is a thing an engineer would recognize from the chapter,
///   not a symbol standing in for one.
const double _canvas = 512;
const double _heavy = 20;
const double _fine = 13;
const double _bar = 34;

class ChapterMark extends StatelessWidget {
  const ChapterMark({
    super.key,
    required this.chapterId,
    required this.color,
    this.size = 44,
  });

  final String chapterId;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ChapterMarkPainter(chapterId: chapterId, color: color),
      ),
    );
  }
}

@visibleForTesting
class ChapterMarkPainter extends CustomPainter {
  const ChapterMarkPainter({required this.chapterId, required this.color});

  final String chapterId;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _canvas;
    canvas
      ..save()
      ..translate(
        (size.width - _canvas * scale) / 2,
        (size.height - _canvas * scale) / 2,
      )
      ..scale(scale);

    final ink = _stroke(_heavy);
    final thin = _stroke(_fine);
    final solid = Paint()..color = color;

    switch (chapterId) {
      case 'mathematics':
        _mathematics(canvas, ink, thin);
      case 'statistics':
        _statistics(canvas, ink, thin);
      case 'ethics':
        _ethics(canvas, ink, solid);
      case 'economics':
        _economics(canvas, ink, thin);
      case 'statics':
        _statics(canvas, ink, thin);
      case 'dynamics':
        _dynamics(canvas, ink, thin, solid);
      case 'mechanics-materials':
        _mechanicsMaterials(canvas, ink, thin);
      case 'materials':
        _materials(canvas, ink, thin, solid);
      case 'fluid-mechanics':
        _fluids(canvas, ink, thin);
      case 'surveying':
        _surveying(canvas, ink);
      case 'waterResources':
      case 'water-resources':
        _water(canvas, ink, thin, solid);
      case 'structural':
        _structural(canvas, ink, thin);
      case 'geotechnical':
        _geotechnical(canvas, ink, thin);
      case 'transportation':
        _transportation(canvas, ink, thin);
      case 'construction':
        _construction(canvas, ink, thin);
      default:
        _fallback(canvas, ink);
    }

    canvas.restore();
  }

  Paint _stroke(double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // ── 01 Mathematics ────────────────────────────────────────────────
  /// A parabola standing on its axes. The chapter opens on analytic
  /// geometry and this is the first curve in it.
  void _mathematics(Canvas canvas, Paint ink, Paint thin) {
    canvas
      ..drawLine(const Offset(128, 64), const Offset(128, 424), thin)
      ..drawLine(const Offset(80, 400), const Offset(456, 400), thin)
      ..drawPath(
          Path()
            ..moveTo(176, 120)
            ..quadraticBezierTo(288, 464, 424, 120),
          ink);
  }

  // ── 02 Probability & Statistics ───────────────────────────────────
  /// A normal curve with its mean dropped through it.
  void _statistics(Canvas canvas, Paint ink, Paint thin) {
    canvas
      ..drawLine(const Offset(72, 400), const Offset(456, 400), thin)
      ..drawPath(
          Path()
            ..moveTo(88, 400)
            ..cubicTo(200, 400, 186, 136, 264, 136)
            ..cubicTo(342, 136, 328, 400, 440, 400),
          ink);
    _dashed(canvas, const Offset(264, 152), const Offset(264, 400), thin);
  }

  // ── 03 Ethics & Professional Practice ─────────────────────────────
  /// A balance, with pans that actually hang off the beam.
  void _ethics(Canvas canvas, Paint ink, Paint solid) {
    final thin = _stroke(_fine);
    canvas
      ..drawCircle(const Offset(256, 108), 16, solid)
      ..drawLine(const Offset(256, 124), const Offset(256, 396), ink)
      ..drawLine(const Offset(184, 404), const Offset(328, 404), ink)
      ..drawLine(const Offset(112, 156), const Offset(400, 156), ink);
    for (final x in [112.0, 400.0]) {
      canvas
        ..drawLine(Offset(x, 156), Offset(x, 224), thin)
        ..drawPath(
            Path()
              ..moveTo(x - 68, 224)
              ..quadraticBezierTo(x, 316, x + 68, 224),
            ink);
    }
  }

  // ── 04 Engineering Economics ──────────────────────────────────────
  /// A cash flow diagram: the cost down at time zero, the returns up.
  void _economics(Canvas canvas, Paint ink, Paint thin) {
    canvas.drawLine(const Offset(72, 288), const Offset(452, 288), ink);
    _arrow(canvas, const Offset(104, 288), const Offset(104, 420), ink);
    for (final (x, top) in [(200.0, 200.0), (296.0, 152.0), (392.0, 96.0)]) {
      _arrow(canvas, Offset(x, 288), Offset(x, top), ink);
    }
    for (final x in [104.0, 200.0, 296.0, 392.0]) {
      canvas.drawLine(Offset(x, 276), Offset(x, 300), thin);
    }
  }

  // ── 05 Statics ────────────────────────────────────────────────────
  /// A Warren truss on a pin and a roller, joints drawn.
  void _statics(Canvas canvas, Paint ink, Paint thin) {
    const bottom = 328.0;
    const top = 168.0;
    canvas
      ..drawLine(const Offset(72, bottom), const Offset(440, bottom), ink)
      ..drawLine(const Offset(164, top), const Offset(348, top), ink)
      ..drawPath(
          Path()
            ..moveTo(72, bottom)
            ..lineTo(164, top)
            ..lineTo(256, bottom)
            ..lineTo(348, top)
            ..lineTo(440, bottom),
          ink);
    for (final p in const [
      Offset(72, bottom),
      Offset(164, top),
      Offset(256, bottom),
      Offset(348, top),
      Offset(440, bottom),
    ]) {
      canvas
        ..drawCircle(p, 13, Paint()..color = const Color(0x00000000))
        ..drawCircle(p, 13, thin);
    }
    // A pin on the left, a roller on the right, which is what makes it a
    // statics problem rather than a shape.
    canvas
      ..drawPath(
          Path()
            ..moveTo(72, bottom + 14)
            ..lineTo(36, bottom + 76)
            ..lineTo(108, bottom + 76)
            ..close(),
          thin)
      ..drawCircle(const Offset(440, bottom + 42), 28, thin);
    _ground(canvas, 20, 124, bottom + 80, thin);
    _ground(canvas, 388, 492, bottom + 74, thin);
  }

  // ── 06 Dynamics ───────────────────────────────────────────────────
  /// A projectile at the top of its flight, with the height it reached.
  ///
  /// The first version put a launch-velocity arrow on the curve and the two
  /// ran into each other at the one place the drawing is busiest. The
  /// dropped height line says the same thing about the motion and sits in
  /// empty space.
  void _dynamics(Canvas canvas, Paint ink, Paint thin, Paint solid) {
    canvas
      ..drawLine(const Offset(56, 424), const Offset(456, 424), thin)
      ..drawPath(
          Path()
            ..moveTo(104, 424)
            ..quadraticBezierTo(256, 32, 408, 424),
          ink)
      ..drawCircle(const Offset(256, 228), 28, solid);
    _dashed(canvas, const Offset(256, 264), const Offset(256, 424), thin);
  }

  // ── 07 Mechanics of Materials ─────────────────────────────────────
  /// A beam that has bent under its load. The deflected shape is the whole
  /// subject, so the beam is drawn sagging rather than straight.
  void _mechanicsMaterials(Canvas canvas, Paint ink, Paint thin) {
    const seat = 236.0;
    const base = 320.0;
    canvas.drawPath(
        Path()
          ..moveTo(88, seat)
          ..quadraticBezierTo(256, 372, 424, seat),
        ink);
    _arrow(canvas, const Offset(256, 76), const Offset(256, 268), ink);
    canvas
      ..drawPath(
          Path()
            ..moveTo(88, seat + 10)
            ..lineTo(44, base)
            ..lineTo(132, base)
            ..close(),
          thin)
      ..drawCircle(const Offset(424, base - 30), 30, thin);
    _ground(canvas, 26, 150, base + 4, thin);
    _ground(canvas, 362, 486, base + 4, thin);
  }

  // ── 08 Materials ──────────────────────────────────────────────────
  /// A stress-strain curve: the straight elastic run, the yield knee, the
  /// plateau, the ultimate, and the drop to fracture.
  void _materials(Canvas canvas, Paint ink, Paint thin, Paint solid) {
    canvas
      ..drawLine(const Offset(112, 72), const Offset(112, 424), thin)
      ..drawLine(const Offset(112, 424), const Offset(456, 424), thin)
      ..drawPath(
          Path()
            ..moveTo(112, 424)
            ..lineTo(208, 216)
            ..quadraticBezierTo(248, 138, 320, 152)
            ..quadraticBezierTo(378, 164, 400, 116)
            ..lineTo(440, 200),
          ink)
      ..drawCircle(const Offset(208, 216), 17, solid);
  }

  // ── 09 Fluid Mechanics ────────────────────────────────────────────
  /// A U-tube manometer standing at two different heights.
  ///
  /// Drawn as an outline alone it read as the letter U. The liquid is given
  /// a body, which is what makes it an instrument with a reading on it: the
  /// left column stands higher than the right, and the difference is the
  /// pressure the whole chapter is about.
  void _fluids(Canvas canvas, Paint ink, Paint thin) {
    const outerL = 134.0;
    const innerL = 198.0;
    const innerR = 314.0;
    const outerR = 378.0;
    const leftLevel = 176.0;
    const rightLevel = 258.0;

    final liquid = Path()
      ..moveTo(outerL, leftLevel)
      ..lineTo(outerL, 336)
      ..quadraticBezierTo(outerL, 420, 218, 420)
      ..lineTo(294, 420)
      ..quadraticBezierTo(outerR, 420, outerR, 336)
      ..lineTo(outerR, rightLevel)
      ..lineTo(innerR, rightLevel)
      ..lineTo(innerR, 330)
      ..quadraticBezierTo(innerR, 356, 272, 356)
      ..lineTo(240, 356)
      ..quadraticBezierTo(innerL, 356, innerL, 330)
      ..lineTo(innerL, leftLevel)
      ..close();
    canvas.drawPath(
        liquid, Paint()..color = color.withValues(alpha: color.a * 0.3));

    canvas
      ..drawPath(
          Path()
            ..moveTo(outerL, 88)
            ..lineTo(outerL, 336)
            ..quadraticBezierTo(outerL, 420, 218, 420)
            ..lineTo(294, 420)
            ..quadraticBezierTo(outerR, 420, outerR, 336)
            ..lineTo(outerR, 140),
          ink)
      ..drawPath(
          Path()
            ..moveTo(innerL, 88)
            ..lineTo(innerL, 330)
            ..quadraticBezierTo(innerL, 356, 240, 356)
            ..lineTo(272, 356)
            ..quadraticBezierTo(innerR, 356, innerR, 330)
            ..lineTo(innerR, 140),
          ink)
      // The two readings, at full weight so they survive the shrink.
      ..drawLine(const Offset(outerL, leftLevel), const Offset(innerL, leftLevel), ink)
      ..drawLine(const Offset(innerR, rightLevel), const Offset(outerR, rightLevel), ink);
  }

  // ── 10 Surveying ──────────────────────────────────────────────────
  /// A closed traverse with its stations, and the angle turned at one of
  /// them.
  ///
  /// The first version drew an instrument on a tripod sighting a graduated
  /// rod. At 512 it was a nice drawing; at 44 it was a smudge, because it
  /// had a tripod, a telescope, a dashed sight line and five graduations
  /// inside a space the size of a fingernail. A traverse is the other half
  /// of the chapter and it is four lines and four dots.
  void _surveying(Canvas canvas, Paint ink) {

    const a = Offset(104, 344);
    const b = Offset(216, 152);
    const c = Offset(400, 232);
    const d = Offset(344, 424);
    canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy)
          ..lineTo(d.dx, d.dy)
          ..close(),
        ink);
    // North, because a closed figure with dots on it is a shape and a
    // closed figure with north on it is a plan. The angle arc that was here
    // instead came out at 44 points as a hook nobody could place.
    canvas
      ..drawLine(const Offset(96, 176), const Offset(96, 104), ink)
      ..drawPath(
          Path()
            ..moveTo(96, 72)
            ..lineTo(75, 118)
            ..lineTo(117, 118)
            ..close(),
          Paint()..color = color);
    for (final p in const [a, b, c, d]) {
      canvas
        ..drawCircle(p, 17, Paint()..color = const Color(0x00000000))
        ..drawCircle(p, 17, ink);
    }
  }

  // ── 11 Water Resources & Environmental ────────────────────────────
  /// A trapezoidal channel running with water in it.
  void _water(Canvas canvas, Paint ink, Paint thin, Paint solid) {
    canvas
      ..drawPath(
          Path()
            ..moveTo(72, 128)
            ..lineTo(168, 384)
            ..lineTo(344, 384)
            ..lineTo(440, 128),
          ink)
      ..drawLine(const Offset(116, 246), const Offset(396, 246), ink)
      // The mark that says this line is a water surface and not a ledge.
      ..drawPath(
          Path()
            ..moveTo(226, 200)
            ..lineTo(286, 200)
            ..lineTo(256, 246)
            ..close(),
          solid);
    _ground(canvas, 24, 96, 128, thin);
    _ground(canvas, 416, 488, 128, thin);
  }

  // ── 12 Structural Engineering ─────────────────────────────────────
  /// A portal frame under a distributed load, fixed at both feet.
  void _structural(Canvas canvas, Paint ink, Paint thin) {
    const base = 392.0;
    canvas
      ..drawLine(const Offset(128, base), const Offset(128, 184), ink)
      ..drawLine(const Offset(384, base), const Offset(384, 184), ink)
      ..drawLine(const Offset(128, 184), const Offset(384, 184), ink)
      ..drawLine(const Offset(128, 76), const Offset(384, 76), thin);
    for (final x in [156.0, 206.0, 256.0, 306.0, 356.0]) {
      _arrow(canvas, Offset(x, 84), Offset(x, 164), thin);
    }
    _ground(canvas, 80, 176, base, thin);
    _ground(canvas, 336, 432, base, thin);
  }

  // ── 13 Geotechnical Engineering ───────────────────────────────────
  /// A spread footing bearing on layered ground.
  ///
  /// Two strata, hatched differently, because what is under the footing is
  /// the whole question. The surface line stops at the footing rather than
  /// running through it: a footing is founded ON the ground, and a line
  /// drawn straight across made it look like a sticker.
  void _geotechnical(Canvas canvas, Paint ink, Paint thin) {
    const surface = 236.0;
    canvas
      ..drawPath(
          Path()
            ..moveTo(228, 72)
            ..lineTo(228, 168)
            ..lineTo(160, 168)
            ..lineTo(160, surface)
            ..lineTo(352, surface)
            ..lineTo(352, 168)
            ..lineTo(284, 168)
            ..lineTo(284, 72),
          ink)
      ..drawLine(const Offset(40, surface), const Offset(160, surface), ink)
      ..drawLine(const Offset(352, surface), const Offset(472, surface), ink)
      ..drawLine(const Offset(40, 336), const Offset(472, 336), ink)
      ..drawLine(const Offset(40, 432), const Offset(472, 432), thin);

    // Upper stratum: back-slanted hatching, well spaced so it reads as
    // hatching and not as texture.
    for (final x in [96.0, 424.0]) {
      canvas.drawLine(Offset(x, surface + 20), Offset(x - 48, surface + 76), thin);
    }
    // Lower stratum: the horizontal dashes a clay is drawn with.
    for (final (x, y) in [(88.0, 376.0), (216.0, 404.0), (344.0, 376.0)]) {
      canvas.drawLine(Offset(x, y), Offset(x + 72, y), thin);
    }
  }

  // ── 14 Transportation Engineering ─────────────────────────────────
  /// A road bending away in plan, with its centerline down the middle.
  ///
  /// The first version drew a horizontal curve as a surveyor lays it out:
  /// two tangents, an arc, and the point of intersection they meet at. It
  /// was correct and it read as a hockey stick. A road with a centerline is
  /// the same chapter and nobody has to be told what it is.
  void _transportation(Canvas canvas, Paint ink, Paint thin) {
    Path spine(double dy) => Path()
      ..moveTo(48, 336 + dy)
      ..cubicTo(176, 336 + dy, 216, 248 + dy, 300, 224 + dy)
      ..cubicTo(372, 204 + dy, 388, 152 + dy, 464, 144 + dy);
    canvas
      ..drawPath(spine(-56), ink)
      ..drawPath(spine(56), ink);
    _dashPath(canvas, spine(0), thin);
  }

  // ── 15 Construction Engineering ───────────────────────────────────
  /// A bar schedule with the activities overlapping down the page, and
  /// today's line cutting through it.
  void _construction(Canvas canvas, Paint ink, Paint thin) {
    final bar = _stroke(_bar);
    canvas.drawLine(const Offset(72, 128), const Offset(448, 128), thin);
    for (final x in [72.0, 166.0, 260.0, 354.0, 448.0]) {
      canvas.drawLine(Offset(x, 116), Offset(x, 140), thin);
    }
    canvas
      ..drawLine(const Offset(106, 208), const Offset(244, 208), bar)
      ..drawLine(const Offset(186, 296), const Offset(360, 296), bar)
      ..drawLine(const Offset(282, 384), const Offset(430, 384), bar);
    _dashed(canvas, const Offset(260, 156), const Offset(260, 424), thin);
  }

  /// Only reachable if a chapter id stops matching the catalog, which the
  /// test in study_tab_test.dart exists to stop.
  void _fallback(Canvas canvas, Paint ink) {
    canvas.drawRect(const Rect.fromLTRB(128, 128, 384, 384), ink);
  }

  // ── shared pieces ─────────────────────────────────────────────────

  /// An arrow from [from] to [to], head at [to].
  void _arrow(Canvas canvas, Offset from, Offset to, Paint ink) {
    final span = to - from;
    final length = span.distance;
    if (length < 1) return;
    final along = span / length;
    final side = Offset(-along.dy, along.dx);
    const head = 34.0;
    const half = 15.0;
    canvas
      ..drawLine(from, to, ink)
      ..drawLine(to, to - along * head + side * half, ink)
      ..drawLine(to, to - along * head - side * half, ink);
  }

  /// A fixed surface: the line, and the back-slanted ticks under it that say
  /// it is the ground and not another member.
  void _ground(Canvas canvas, double fromX, double toX, double y, Paint ink) {
    canvas.drawLine(Offset(fromX, y), Offset(toX, y), ink);
    for (var x = fromX + 20; x < toX; x += 26) {
      canvas.drawLine(Offset(x, y), Offset(x - 18, y + 22), ink);
    }
  }

  /// A dashed run along a PATH, for a centerline that bends. Same idea as
  /// [_dashed], walked with PathMetrics so the dashes follow the curve.
  void _dashPath(Canvas canvas, Path path, Paint ink) {
    const on = 34.0;
    const off = 26.0;
    for (final metric in path.computeMetrics()) {
      var at = 0.0;
      while (at < metric.length) {
        final end = (at + on).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(at, end), ink);
        at = end + off;
      }
    }
  }

  /// A dashed run. Flutter has no dash support on a stroke, so the segments
  /// are stepped by hand.
  void _dashed(Canvas canvas, Offset from, Offset to, Paint ink) {
    const on = 26.0;
    const off = 20.0;
    final span = to - from;
    final length = span.distance;
    if (length == 0) return;
    final step = span / length;
    var at = 0.0;
    while (at < length) {
      final end = (at + on).clamp(0.0, length);
      canvas.drawLine(from + step * at, from + step * end, ink);
      at = end + off;
    }
  }

  @override
  bool shouldRepaint(ChapterMarkPainter old) =>
      old.chapterId != chapterId || old.color != color;
}
