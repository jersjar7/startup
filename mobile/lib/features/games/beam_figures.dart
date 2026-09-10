import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// What a support is, which on a free body diagram is the same question as
/// what it hands you.
///
/// A roller gives one force square to the surface it rolls on, a pin gives
/// two, and a fixed end gives two and a moment. Those counts are the whole of
/// the lesson's support content, and they are what decides whether three
/// equations are enough.
enum Prop {
  /// One force, straight up out of the ground it sits on.
  roller,

  /// One force square to a sloped surface, which is not vertical and is where
  /// this gets lost.
  slopedRoller,

  /// Two forces, and no moment.
  pin,

  /// Two forces and a moment.
  fixed,

  /// One force, along the cable's own line.
  cable,
}

/// How many unknowns a support puts into the equations.
int unknownsIn(Prop kind) => switch (kind) {
      Prop.roller || Prop.slopedRoller || Prop.cable => 1,
      Prop.pin => 2,
      Prop.fixed => 3,
    };

@immutable
class Support {
  const Support(this.at, this.kind, {this.slope = 0, this.label = ''});

  /// Where it holds the beam, in world units.
  final Offset at;

  final Prop kind;

  /// The surface angle in degrees, for a sloped roller. Zero everywhere else.
  final double slope;

  final String label;
}

/// A load spread along the beam rather than sitting at a point.
///
/// Held as an intensity at each end, so one shape covers the uniform case, the
/// triangle and everything between. Where its resultant acts is the centroid
/// of that trapezoid, which is the thing the lesson's own problem is lost on.
@immutable
class Spread {
  const Spread(this.from, this.to, this.atFrom, this.atTo, {this.label = ''});

  final double from;
  final double to;

  /// Intensity at each end, in whatever the round is counting in.
  final double atFrom;
  final double atTo;

  final String label;

  double get total => (atFrom + atTo) / 2 * (to - from);

  /// Where the single equivalent force acts: the centroid of the trapezoid.
  /// Uniform gives the middle, a triangle gives a third from the heavy end.
  double get actsAt {
    final a = atFrom;
    final b = atTo;
    if (a + b == 0) return (from + to) / 2;
    return from + (to - from) * (a + 2 * b) / (3 * (a + b));
  }
}

/// A point on the beam somebody might tap.
@immutable
class Station {
  const Station(this.at, this.label);

  final double at;
  final String label;
}

/// A beam, what holds it up, and what is pushing on it.
///
/// Shares nothing with the moment figures but the habit: measure, then lay out
/// from the measurement.
class BeamPainter extends CustomPainter {
  const BeamPainter({
    required this.span,
    required this.supports,
    this.spreads = const [],
    this.loads = const [],
    this.couples = const [],
    this.stations = const [],
    this.selected,
    this.locked = false,
    this.truth = -1,
    this.markResultant = false,
  });

  /// How long the beam is, in its own units. It always starts at zero.
  final double span;

  final List<Support> supports;
  final List<Spread> spreads;

  /// Point loads, as (position, label). All of them point down.
  final List<(double, String)> loads;

  /// Couples, as (position, counterclockwise, label).
  final List<(double, bool, String)> couples;

  /// Places on the beam that can be tapped.
  final List<Station> stations;

  final int? selected;
  final bool locked;
  final int truth;

  /// Draw the resultant of the first spread once the answer is out.
  final bool markResultant;

  static const _padX = 30.0;
  static const _padBottom = 46.0;

  double _x(Size size, double at) =>
      _padX + at / span * (size.width - _padX * 2);

  double _beamY(Size size) => size.height - _padBottom;

  /// Where a station sits on the canvas, so the tap targets can be put over
  /// the marks rather than beside them.
  static Offset stationAt(Size size, double span, double at) => Offset(
        _padX + at / span * (size.width - _padX * 2),
        size.height - _padBottom,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final y = _beamY(size);
    final left = _x(size, 0);
    final right = _x(size, span);

    for (final spread in spreads) {
      _drawSpread(canvas, size, spread, y);
    }

    // The beam, over the loads so the arrows stop at it.
    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    for (final s in supports) {
      _drawSupport(canvas, size, s, y);
    }
    for (final (at, label) in loads) {
      final x = _x(size, at);
      _arrow(canvas, Offset(x, y - 52), Offset(x, y - 4), AppColors.charcoal);
      _write(canvas, label, Offset(x, y - 68), AppColors.charcoal, size);
    }
    for (final (at, ccw, label) in couples) {
      _drawCouple(canvas, size, _x(size, at), y, ccw, label);
    }

    if (markResultant && spreads.isNotEmpty) {
      final s = spreads.first;
      final x = _x(size, s.actsAt);
      _arrow(canvas, Offset(x, y - 74), Offset(x, y - 4), AppColors.forest,
          heavy: true);
      _write(canvas, 'acts here', Offset(x, y - 90), AppColors.forest, size);
    }

    for (final (i, station) in stations.indexed) {
      final x = _x(size, station.at);
      final picked = selected == i;
      final isTruth = locked && i == truth;
      final colour = isTruth
          ? AppColors.forest
          : (locked && picked)
              ? AppColors.error
              : picked
                  ? AppColors.ember
                  : AppColors.ink3;
      final heavy = picked || isTruth;
      canvas.drawCircle(
        Offset(x, y),
        heavy ? 8 : 6,
        Paint()..color = heavy ? colour : AppColors.cream,
      );
      canvas.drawCircle(
        Offset(x, y),
        heavy ? 8 : 6,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = heavy ? 2.4 : 1.6,
      );
      _write(canvas, station.label, Offset(x, y + 14), colour, size);
    }
  }

  void _drawSpread(Canvas canvas, Size size, Spread spread, double y) {
    final a = _x(size, spread.from);
    final b = _x(size, spread.to);
    final tallest = math.max(spread.atFrom, spread.atTo);
    if (tallest <= 0) return;
    double top(double at) {
      final t = (at - spread.from) / (spread.to - spread.from);
      final here = spread.atFrom + (spread.atTo - spread.atFrom) * t;
      return y - 16 - here / tallest * 34;
    }

    final outline = Path()
      ..moveTo(a, y - 16)
      ..lineTo(a, top(spread.from))
      ..lineTo(b, top(spread.to))
      ..lineTo(b, y - 16);
    canvas.drawPath(
      outline,
      Paint()
        ..color = AppColors.ink2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // One arrow every so often, so the shape reads as load rather than as a
    // shaded box.
    const step = 7;
    for (var i = 0; i <= step; i++) {
      final at = spread.from + (spread.to - spread.from) * i / step;
      final x = _x(size, at);
      final from = top(at);
      if (y - 18 - from < 3) continue;
      _arrow(canvas, Offset(x, from), Offset(x, y - 16), AppColors.ink2,
          head: 6);
    }
    if (spread.label.isNotEmpty) {
      _write(canvas, spread.label, Offset((a + b) / 2, top((spread.from + spread.to) / 2) - 16),
          AppColors.ink2, size);
    }
  }

  void _drawSupport(Canvas canvas, Size size, Support s, double y) {
    final x = _x(size, s.at.dx);
    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    void hatch(double from, double to, double at) {
      for (var h = from; h < to; h += 7) {
        canvas.drawLine(Offset(h, at), Offset(h - 5, at + 6), ink);
      }
    }

    switch (s.kind) {
      case Prop.pin:
        canvas.drawPath(
          Path()
            ..moveTo(x, y + 2)
            ..lineTo(x - 11, y + 20)
            ..lineTo(x + 11, y + 20)
            ..close(),
          ink,
        );
        hatch(x + 15, x + 20, y + 20);
        canvas.drawLine(Offset(x - 18, y + 20), Offset(x + 18, y + 20), ink);
        hatch(x - 12, x + 19, y + 20);
      case Prop.roller:
        canvas.drawPath(
          Path()
            ..moveTo(x, y + 2)
            ..lineTo(x - 11, y + 14)
            ..lineTo(x + 11, y + 14)
            ..close(),
          ink,
        );
        canvas.drawCircle(Offset(x - 6, y + 18), 4, ink);
        canvas.drawCircle(Offset(x + 6, y + 18), 4, ink);
        canvas.drawLine(Offset(x - 18, y + 23), Offset(x + 18, y + 23), ink);
        hatch(x - 12, x + 19, y + 23);
      case Prop.slopedRoller:
        canvas.save();
        canvas.translate(x, y + 2);
        canvas.rotate(-s.slope * math.pi / 180);
        canvas.drawCircle(const Offset(0, 6), 6, ink);
        canvas.drawLine(const Offset(-18, 13), const Offset(18, 13), ink);
        for (var h = -12.0; h < 19; h += 7) {
          canvas.drawLine(Offset(h, 13), Offset(h - 5, 19), ink);
        }
        canvas.restore();
      case Prop.fixed:
        canvas.drawLine(Offset(x, y - 22), Offset(x, y + 22), ink);
        for (var v = y - 22.0; v < y + 22; v += 7) {
          canvas.drawLine(Offset(x, v), Offset(x - 7, v + 6), ink);
        }
      case Prop.cable:
        canvas.drawLine(Offset(x, y - 4), Offset(x, y - 44), ink);
        canvas.drawLine(Offset(x - 16, y - 44), Offset(x + 16, y - 44), ink);
        for (var h = x - 10.0; h < x + 17; h += 7) {
          canvas.drawLine(Offset(h, y - 44), Offset(h - 5, y - 50), ink);
        }
    }

    if (s.label.isNotEmpty) {
      final below = s.kind != Prop.cable;
      _write(canvas, s.label, Offset(x, below ? y + 28 : y - 62),
          AppColors.ink2, size);
    }
  }

  void _drawCouple(
      Canvas canvas, Size size, double x, double y, bool ccw, String label) {
    const r = 15.0;
    final rect = Rect.fromCircle(center: Offset(x, y - r - 6), radius: r);
    final from = ccw ? 0.4 : math.pi - 0.4;
    final sweep = (ccw ? -1 : 1) * math.pi * 1.5;
    canvas.drawArc(
      rect,
      from,
      sweep,
      false,
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final end = from + sweep;
    final tip = rect.center + Offset(math.cos(end), math.sin(end)) * r;
    final along = Offset(-math.sin(end), math.cos(end)) * (ccw ? -1 : 1);
    final side = Offset(-along.dy, along.dx);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo((tip - along * 8 + side * 4).dx, (tip - along * 8 + side * 4).dy)
        ..lineTo((tip - along * 8 - side * 4).dx, (tip - along * 8 - side * 4).dy)
        ..close(),
      Paint()..color = AppColors.charcoal,
    );
    _write(canvas, label, Offset(x, y - r * 2 - 24), AppColors.charcoal, size);
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color colour,
      {double head = 8, bool heavy = false}) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = heavy ? 3 : 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - head * math.cos(angle - 0.4),
            to.dy - head * math.sin(angle - 0.4))
        ..lineTo(to.dx - head * math.cos(angle + 0.4),
            to.dy - head * math.sin(angle + 0.4))
        ..close(),
      Paint()..color = colour,
    );
  }

  void _write(Canvas canvas, String text, Offset at, Color colour, Size size) {
    if (text.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10.5, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - tp.width / 2;
    var yy = at.dy;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    if (yy < 1) yy = 1;
    if (yy + tp.height > size.height - 1) yy = size.height - 1 - tp.height;
    canvas.drawRect(
      Rect.fromLTWH(x - 2, yy, tp.width + 4, tp.height),
      Paint()..color = AppColors.cream.withValues(alpha: 0.92),
    );
    tp.paint(canvas, Offset(x, yy));
  }

  @override
  bool shouldRepaint(BeamPainter old) =>
      old.supports != supports ||
      old.spreads != spreads ||
      old.selected != selected ||
      old.locked != locked ||
      old.markResultant != markResultant;
}

/// A picture of what a support hands you: the arrows, and the moment if there
/// is one.
///
/// The options in the first item are these rather than words, because "two
/// reactions and a moment" is a sentence to be memorized and three arrows on a
/// stub of beam is something you can see.
class ReactionGlyphPainter extends CustomPainter {
  const ReactionGlyphPainter({
    required this.vertical,
    required this.horizontal,
    required this.moment,
    required this.colour,
    this.slope = 0,
  });

  /// Whether the set includes a force square to the beam, along it, and a
  /// moment.
  final bool vertical;
  final bool horizontal;
  final bool moment;

  /// Tips the square-on force over, for the sloped roller.
  final double slope;

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.66;
    final cx = size.width / 2;

    canvas.drawLine(
      Offset(cx - 22, y),
      Offset(cx + 22, y),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    void arrow(Offset dir) {
      final len = dir.distance;
      final unit = dir / len;
      final to = Offset(cx, y) + unit * 26;
      final paint = Paint()
        ..color = colour
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx, y), to, paint);
      final angle = math.atan2(unit.dy, unit.dx);
      canvas.drawPath(
        Path()
          ..moveTo(to.dx, to.dy)
          ..lineTo(to.dx - 7 * math.cos(angle - 0.45),
              to.dy - 7 * math.sin(angle - 0.45))
          ..lineTo(to.dx - 7 * math.cos(angle + 0.45),
              to.dy - 7 * math.sin(angle + 0.45))
          ..close(),
        Paint()..color = colour,
      );
    }

    if (vertical) {
      final rad = slope * math.pi / 180;
      arrow(Offset(math.sin(rad), -math.cos(rad)));
    }
    if (horizontal) arrow(const Offset(1, 0));
    if (moment) {
      final rect = Rect.fromCircle(center: Offset(cx, y), radius: 13);
      canvas.drawArc(
        rect,
        -math.pi * 0.9,
        math.pi * 1.5,
        false,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final end = -math.pi * 0.9 + math.pi * 1.5;
      final tip = rect.center + Offset(math.cos(end), math.sin(end)) * 13;
      canvas.drawCircle(tip, 2.6, Paint()..color = colour);
    }
  }

  @override
  bool shouldRepaint(ReactionGlyphPainter old) =>
      old.vertical != vertical ||
      old.horizontal != horizontal ||
      old.moment != moment ||
      old.colour != colour ||
      old.slope != slope;
}
