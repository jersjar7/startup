import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// Which quarter of the compass a bearing sits in.
enum Quad { ne, se, sw, nw }

extension QuadWords on Quad {
  String get letters => switch (this) {
        Quad.ne => 'NE',
        Quad.se => 'SE',
        Quad.sw => 'SW',
        Quad.nw => 'NW',
      };
}

/// The rule that turns a bearing into an azimuth. Which one applies is the
/// whole of the lesson's first problem, and the lesson's own warning is
/// about reaching for the wrong one.
enum Rule { same, fromHalf, plusHalf, fromWhole }

extension RuleWords on Rule {
  String get plain => switch (this) {
        Rule.same => 'The azimuth is that same number',
        Rule.fromHalf => '180 degrees minus it',
        Rule.plusHalf => '180 degrees plus it',
        Rule.fromWhole => '360 degrees minus it',
      };
}

/// A bearing: an angle turned off the meridian, toward the east or the west,
/// and never more than a right angle.
@immutable
class Bearing {
  const Bearing(this.quad, this.degrees);

  final Quad quad;

  /// Degrees off north or off south, 0 to 90.
  final double degrees;

  /// Clockwise from north, 0 to 360, worked out rather than declared.
  double get azimuth => switch (quad) {
        Quad.ne => degrees,
        Quad.se => 180 - degrees,
        Quad.sw => 180 + degrees,
        Quad.nw => 360 - degrees,
      };

  /// Which rule got it there.
  Rule get rule => switch (quad) {
        Quad.ne => Rule.same,
        Quad.se => Rule.fromHalf,
        Quad.sw => Rule.plusHalf,
        Quad.nw => Rule.fromWhole,
      };

  String get plain {
    final from = quad == Quad.ne || quad == Quad.nw ? 'N' : 'S';
    final to = quad == Quad.ne || quad == Quad.se ? 'E' : 'W';
    return '$from ${_num(degrees)}° $to';
  }

  /// Which way the line runs across the panel, with y down the screen.
  Offset get heading {
    final r = azimuth * math.pi / 180;
    return Offset(math.sin(r), -math.cos(r));
  }
}

/// One line off the station, with the point it runs to.
@immutable
class Shot {
  const Shot({required this.bearing, required this.name, this.long = 1});

  final Bearing bearing;

  /// The point at the far end, as it is labeled on a plan.
  final String name;

  /// A share of the full reach, so a plan does not look like a star.
  final double long;
}

/// A plan: the station, the meridian through it, and the lines run off it.
/// Drawn the way a survey plan is drawn, with north up the sheet.
class RosePainter extends CustomPainter {
  const RosePainter({
    required this.shots,
    this.picked,
    this.answer,
    this.locked = false,
    this.arcOn,
  });

  final List<Shot> shots;
  final int? picked;
  final int? answer;
  final bool locked;

  /// Which line gets its angle off the meridian drawn and written. Used by
  /// the round that shows one line and asks about it, and never used to
  /// give away an answer that has not been given yet.
  final int? arcOn;

  static Offset station(Size size) =>
      Offset(size.width * 0.5, size.height * 0.52);

  static double _reach(Size size) =>
      math.min(size.width * 0.40, size.height * 0.38);

  /// Where the far point of line `i` sits.
  static Offset spotOf(Size size, List<Shot> shots, int i) =>
      station(size) + shots[i].bearing.heading * (_reach(size) * shots[i].long);

  static int? at(Size size, List<Shot> shots, Offset tap) {
    for (var i = 0; i < shots.length; i++) {
      if ((spotOf(size, shots, i) - tap).distance < 26) return i;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final o = station(size);
    final reach = _reach(size);

    // The meridian and the line square to it, dashed, the way a plan shows
    // the reference directions.
    final thin = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1;
    void dashed(Offset from, Offset to) {
      final run = to - from;
      final steps = (run.distance / 7).floor();
      final unit = run / run.distance;
      for (var k = 0; k < steps; k += 2) {
        canvas.drawLine(from + unit * (k * 7), from + unit * (k * 7 + 4), thin);
      }
    }

    // Each arm runs as far as the panel allows, so the letter on the end of
    // it is always inside the drawing.
    final up = math.min(reach + 26, o.dy - 16);
    final down = math.min(reach + 26, size.height - o.dy - 30);
    final right = math.min(reach + 26, size.width - o.dx - 20);
    final left = math.min(reach + 26, o.dx - 20);
    dashed(o, o + Offset(0, -up));
    dashed(o, o + Offset(0, down));
    dashed(o, o + Offset(right, 0));
    dashed(o, o + Offset(-left, 0));
    _write(canvas, size, 'N', o + Offset(-3, -up - 12), AppColors.ink2);
    _write(canvas, size, 'S', o + Offset(-3, down + 2), AppColors.ink2);
    _write(canvas, size, 'E', o + Offset(right + 4, -5), AppColors.ink2);
    _write(canvas, size, 'W', o + Offset(-left - 12, -5), AppColors.ink2);

    // The north arrow, in the corner where a plan carries it.
    final nx = size.width - 20;
    final ny = 16.0;
    final arrow = Paint()..color = AppColors.charcoal;
    canvas
      ..drawPath(
          Path()
            ..moveTo(nx, ny)
            ..lineTo(nx - 5, ny + 20)
            ..lineTo(nx, ny + 15)
            ..lineTo(nx + 5, ny + 20)
            ..close(),
          arrow)
      ..drawLine(
          Offset(nx, ny + 15),
          Offset(nx, ny + 26),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 1.2);
    _write(canvas, size, 'N', Offset(nx - 3, ny + 27), AppColors.charcoal);

    // The angle off the meridian, when the round is showing it.
    if (arcOn != null) {
      final b = shots[arcOn!].bearing;
      final fromNorth = b.quad == Quad.ne || b.quad == Quad.nw;
      final start = fromNorth ? -math.pi / 2 : math.pi / 2;
      final sweep = (b.quad == Quad.ne || b.quad == Quad.sw ? 1 : -1) *
          b.degrees *
          math.pi /
          180;
      canvas.drawArc(
        Rect.fromCircle(center: o, radius: 34),
        start,
        sweep,
        false,
        Paint()
          ..color = AppColors.ember
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      final mid = start + sweep / 2;
      _write(
          canvas,
          size,
          '${_num(b.degrees)}°',
          o + Offset(math.cos(mid), math.sin(mid)) * 48 + const Offset(-9, -6),
          AppColors.ember);
    }

    // The lines themselves, each running to a marked point.
    for (var i = 0; i < shots.length; i++) {
      final end = spotOf(size, shots, i);
      final Color tone;
      if (locked && answer == i) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.charcoal;
      }
      canvas.drawLine(
          o,
          end,
          Paint()
            ..color = tone
            ..strokeWidth = (picked == i || (locked && answer == i)) ? 2.6 : 1.8);
      // The point at the far end, drawn as a survey point is drawn.
      canvas
        ..drawCircle(end, 11, Paint()..color = AppColors.cream)
        ..drawCircle(
            end,
            9,
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2)
        ..drawCircle(end, 2.4, Paint()..color = tone);
      _write(canvas, size, shots[i].name, end + const Offset(10, -16), tone);
    }

    // The station: the triangle a control point is drawn with.
    canvas
      ..drawPath(
          Path()
            ..moveTo(o.dx, o.dy - 7)
            ..lineTo(o.dx - 6, o.dy + 4)
            ..lineTo(o.dx + 6, o.dy + 4)
            ..close(),
          Paint()..color = AppColors.cream)
      ..drawPath(
          Path()
            ..moveTo(o.dx, o.dy - 7)
            ..lineTo(o.dx - 6, o.dy + 4)
            ..lineTo(o.dx + 6, o.dy + 4)
            ..close(),
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6)
      ..drawCircle(o, 1.6, Paint()..color = AppColors.charcoal);

    viewTag(canvas, size, Looking.plan, note: 'north up the sheet');
  }

  @override
  bool shouldRepaint(RosePainter old) =>
      old.shots != shots ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked ||
      old.arcOn != arcOn;
}

/// Which of the three lengths in a slope shot is meant.
enum Side3 { slope, flat, rise }

extension Side3Words on Side3 {
  String get plain => switch (this) {
        Side3.slope => 'the slope distance',
        Side3.flat => 'the horizontal distance',
        Side3.rise => 'the difference in elevation',
      };
}

/// One shot up or down a hillside: what the instrument reads, what the plan
/// wants, and the height between the two ends.
@immutable
class Sight {
  const Sight({required this.slope, required this.angle});

  /// Meters along the line of sight, and the vertical angle in degrees.
  /// A negative angle is a shot downhill.
  final double slope;
  final double angle;

  double get flat => slope * math.cos(angle * math.pi / 180);
  double get rise => slope * math.sin(angle * math.pi / 180);
}

/// The shot drawn in section: the ground, the instrument, the target, and
/// the three lengths of the triangle they make.
class SlopePainter extends CustomPainter {
  const SlopePainter({
    required this.sight,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final Sight sight;
  final Side3? picked;
  final Side3? answer;
  final bool locked;

  static Offset _instrument(Size size) =>
      Offset(size.width * 0.16, size.height * 0.62);

  static Offset _target(Size size, Sight sight) {
    final long = size.width * 0.62;
    final up = long * math.tan(sight.angle * math.pi / 180);
    return _instrument(size) + Offset(long, -up);
  }

  /// Where each of the three lengths is tapped: the middle of its own side.
  static Offset spotOf(Size size, Sight sight, Side3 side) {
    final a = _instrument(size);
    final b = _target(size, sight);
    final corner = Offset(b.dx, a.dy);
    // Uphill the slope line runs above the horizontal and downhill it runs
    // below, so each marker is pushed off its own line on the side away
    // from the other one. On a downhill shot they otherwise land together.
    final up = sight.angle >= 0 ? 1 : -1;
    return switch (side) {
      Side3.slope =>
        Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 - 13 * up),
      Side3.flat => Offset((a.dx + corner.dx) / 2, a.dy + 16 * up),
      Side3.rise => Offset(corner.dx + 16, (corner.dy + b.dy) / 2),
    };
  }

  static Side3? at(Size size, Sight sight, Offset tap) {
    for (final side in Side3.values) {
      if ((spotOf(size, sight, side) - tap).distance < 25) return side;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final a = _instrument(size);
    final b = _target(size, sight);
    final corner = Offset(b.dx, a.dy);

    // The hillside the two ends stand on, hatched as ground.
    final groundA = a.dy + 26;
    final groundB = b.dy + 26;
    final hill = Path()
      ..moveTo(6, groundA + 6)
      ..lineTo(a.dx, groundA)
      ..lineTo(b.dx, groundB)
      ..lineTo(size.width - 6, groundB - 4)
      ..lineTo(size.width - 6, size.height)
      ..lineTo(6, size.height)
      ..close();
    hatchIn(canvas, hill, step: 8);
    canvas.drawPath(
        hill,
        Paint()
          ..color = AppColors.ink2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);

    // The instrument on its tripod, and the rod at the far end.
    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.6;
    canvas
      ..drawLine(a, Offset(a.dx - 8, groundA), ink)
      ..drawLine(a, Offset(a.dx + 8, groundA), ink)
      ..drawLine(a, Offset(a.dx, groundA), ink)
      ..drawRect(
          Rect.fromCenter(center: a + const Offset(0, -5), width: 14, height: 9),
          Paint()..color = AppColors.charcoal)
      ..drawLine(b, Offset(b.dx, groundB), ink)
      ..drawRect(
          Rect.fromCenter(center: b, width: 7, height: 12),
          Paint()..color = AppColors.charcoal);

    // The horizontal through the instrument, which is what the angle is
    // measured from, and the upright at the far end.
    final dash = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.2;
    for (var x = a.dx; x < corner.dx; x += 8) {
      canvas.drawLine(Offset(x, a.dy), Offset(x + 4, a.dy), dash);
    }
    canvas.drawLine(corner, b, dash);

    // The three lengths, each in its own color when it is the one picked.
    Color toneFor(Side3 side) {
      if (locked && answer == side) return AppColors.forest;
      if (locked && picked == side) return AppColors.error;
      if (picked == side) return AppColors.ember;
      return AppColors.charcoal;
    }

    canvas
      ..drawLine(
          a,
          b,
          Paint()
            ..color = toneFor(Side3.slope)
            ..strokeWidth = picked == Side3.slope ? 3.4 : 2.4)
      ..drawLine(
          a,
          corner,
          Paint()
            ..color = toneFor(Side3.flat)
            ..strokeWidth = picked == Side3.flat ? 3.4 : 2.4)
      ..drawLine(
          corner,
          b,
          Paint()
            ..color = toneFor(Side3.rise)
            ..strokeWidth = picked == Side3.rise ? 3.4 : 2.4);

    // The vertical angle at the instrument.
    final sweep = -sight.angle * math.pi / 180;
    canvas.drawArc(Rect.fromCircle(center: a, radius: 30), 0, sweep, false,
        Paint()
          ..color = AppColors.ember
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4);
    _write(canvas, size, '${_num(sight.angle.abs())}°',
        a + Offset(34, sight.angle >= 0 ? -20 : 10), AppColors.ember);

    for (final side in Side3.values) {
      final spot = spotOf(size, sight, side);
      final tone = toneFor(side);
      canvas
        ..drawCircle(spot, 9, Paint()..color = AppColors.cream)
        ..drawCircle(
            spot,
            7.5,
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
    }

    viewTag(canvas, size, Looking.section);
  }

  @override
  bool shouldRepaint(SlopePainter old) =>
      old.sight != sight ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
  var x = at.dx;
  if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
  if (x < 2) x = 2;
  final patch =
      Rect.fromLTWH(x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
  canvas.drawRect(
      patch, Paint()..color = AppColors.cream.withValues(alpha: 0.92));
  painter.paint(canvas, Offset(x, at.dy));
}
