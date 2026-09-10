import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'beam_figures.dart' show Prop, Spread, Support;

/// How a beam is held.
enum Held {
  /// A pin and a roller, which may sit inside the ends and leave an overhang.
  simple,

  /// Built in at the left end, free at the right.
  cantilever,
}

/// Which diagram is being talked about.
enum Diagram { shear, moment }

/// A beam, what holds it up and what is on it, with the internal forces it
/// must therefore carry.
///
/// Every number the items ask for comes out of here, so a round declares the
/// beam and the answers are worked out rather than written down beside it.
/// Sign conventions, which are the lesson's own first heading: upward forces
/// and sagging moments are positive, and a couple is positive clockwise.
@immutable
class Loading {
  const Loading({
    required this.span,
    this.held = Held.simple,
    this.a = 0,
    double? b,
    this.points = const <(double, double)>[],
    this.spreads = const <Spread>[],
    this.couples = const <(double, double)>[],
  }) : _b = b;

  final double span;
  final Held held;

  /// Where the two supports sit on a simply supported beam. The right one
  /// defaults to the far end.
  final double a;
  final double? _b;
  double get b => _b ?? span;

  /// Point loads as (position, force DOWN).
  final List<(double, double)> points;

  /// Loads spread along the beam. A uniform load has the same intensity at
  /// both ends; a triangle does not.
  final List<Spread> spreads;

  /// Applied couples as (position, moment CLOCKWISE).
  final List<(double, double)> couples;

  double get totalDown =>
      points.fold(0.0, (t, p) => t + p.$2) +
      spreads.fold(0.0, (t, s) => t + s.total);

  /// Turning effect about the left support, clockwise positive.
  double get _aboutA =>
      points.fold(0.0, (t, p) => t + p.$2 * (p.$1 - a)) +
      spreads.fold(0.0, (t, s) => t + s.total * (s.actsAt - a)) +
      couples.fold(0.0, (t, c) => t + c.$2);

  /// The right reaction, upward positive. Zero on a cantilever.
  double get rightReaction =>
      held == Held.cantilever ? 0 : _aboutA / (b - a);

  /// The left reaction, upward positive. On a cantilever this is the whole
  /// load, taken at the built-in end.
  double get leftReaction =>
      held == Held.cantilever ? totalDown : totalDown - rightReaction;

  /// The moment the wall has to hold on a cantilever, sagging positive, so it
  /// comes out negative for a downward load, which is what hogging means.
  double get wallMoment {
    if (held != Held.cantilever) return 0;
    final about = points.fold(0.0, (t, p) => t + p.$2 * p.$1) +
        spreads.fold(0.0, (t, s) => t + s.total * s.actsAt) +
        couples.fold(0.0, (t, c) => t + c.$2);
    return -about;
  }

  /// Where the supports actually are.
  List<double> get supportsAt =>
      held == Held.cantilever ? const [0.0] : [a, b];

  /// Which side of a section a force sits on is decided by stepping a hair
  /// past it. The hair is small enough that the load it sweeps up on the way
  /// is nothing, and large enough to survive the arithmetic.
  static const _hair = 1e-12;

  /// How much of a spread lies left of x, and where that part acts.
  (double, double) _spreadLeftOf(Spread s, double x) {
    if (x <= s.from) return (0, s.from);
    final to = math.min(x, s.to);
    final t = (to - s.from) / (s.to - s.from);
    final atTo = s.atFrom + (s.atTo - s.atFrom) * t;
    final part = Spread(s.from, to, s.atFrom, atTo);
    return (part.total, part.actsAt);
  }

  /// Shear just to one side of a section: the sum of everything upward to the
  /// left of it. Sides matter, because a point load makes the two different.
  double shearAt(double x, {bool after = true}) {
    final at = after ? x + _hair : x - _hair;
    var v = 0.0;
    for (final s in supportsAt) {
      if (s < at) {
        v += s == a || held == Held.cantilever ? leftReaction : rightReaction;
      }
    }
    for (final (pos, down) in points) {
      if (pos < at) v -= down;
    }
    for (final s in spreads) {
      v -= _spreadLeftOf(s, at).$1;
    }
    return v;
  }

  /// Bending moment at a section, sagging positive.
  double momentAt(double x, {bool after = true}) {
    final at = after ? x + _hair : x - _hair;
    var m = held == Held.cantilever && at > 0 ? wallMoment : 0.0;
    for (final s in supportsAt) {
      if (s < at) {
        final r = s == a || held == Held.cantilever
            ? leftReaction
            : rightReaction;
        m += r * (at - s);
      }
    }
    for (final (pos, down) in points) {
      if (pos < at) m -= down * (at - pos);
    }
    for (final s in spreads) {
      final (total, acts) = _spreadLeftOf(s, at);
      if (total > 0) m -= total * (at - acts);
    }
    for (final (pos, clockwise) in couples) {
      if (pos < at) m += clockwise;
    }
    return m;
  }

  /// Everywhere either diagram can change character: a support, a load, the
  /// end of a spread, a couple, and the two ends.
  List<double> get breaks {
    final out = <double>{0, span, ...supportsAt};
    for (final (pos, _) in points) {
      out.add(pos);
    }
    for (final s in spreads) {
      out
        ..add(s.from)
        ..add(s.to);
    }
    for (final (pos, _) in couples) {
      out.add(pos);
    }
    final list = out.where((x) => x >= 0 && x <= span).toList()..sort();
    return list;
  }

  /// Where the shear passes through zero, which is where the moment peaks.
  List<double> get zeroShear {
    final out = <double>[];
    final marks = breaks;
    for (var i = 0; i < marks.length - 1; i++) {
      final lo = marks[i];
      final hi = marks[i + 1];
      final vLo = shearAt(lo);
      final vHi = shearAt(hi, after: false);
      if (vLo == 0) out.add(lo);
      if (vLo * vHi < 0) {
        // Shear is linear between two breaks, so one step lands on it.
        out.add(lo + (hi - lo) * vLo.abs() / (vLo.abs() + vHi.abs()));
      }
      // A point load can carry the shear through zero without crossing it.
      if (i > 0 && shearAt(lo, after: false) * vLo < 0) out.add(lo);
    }
    return out;
  }

  /// Where the bending moment is biggest in size, which is what a beam is
  /// sized for. Found by looking at every break and every crossing rather
  /// than by trusting the middle of the span.
  double get peakMomentAt {
    var best = 0.0;
    var bestAt = 0.0;
    for (final x in [...breaks, ...zeroShear]) {
      for (final side in [true, false]) {
        final m = momentAt(x, after: side).abs();
        if (m > best + 1e-9) {
          best = m;
          bestAt = x;
        }
      }
    }
    return bestAt;
  }

  double get peakMoment => momentAt(peakMomentAt).abs();

  double valueOf(Diagram what, double x, {bool after = true}) =>
      what == Diagram.shear
          ? shearAt(x, after: after)
          : momentAt(x, after: after);

  /// The diagram as a line to draw, with both sides of every jump in it.
  List<Offset> curve(Diagram what) {
    final out = <Offset>[];
    final marks = breaks;
    for (var i = 0; i < marks.length - 1; i++) {
      final lo = marks[i];
      final hi = marks[i + 1];
      out.add(Offset(lo, valueOf(what, lo)));
      final steps = what == Diagram.moment ? 12 : 2;
      for (var k = 1; k < steps; k++) {
        final x = lo + (hi - lo) * k / steps;
        out.add(Offset(x, valueOf(what, x)));
      }
      out.add(Offset(hi, valueOf(what, hi, after: false)));
    }
    return out;
  }
}

/// The supports to hand the beam painter, so the picture and the arithmetic
/// cannot disagree about what is holding the beam up.
List<Support> supportsOf(Loading beam) => beam.held == Held.cantilever
    ? [const Support(Offset.zero, Prop.fixed)]
    : [
        Support(Offset(beam.a, 0), Prop.pin),
        Support(Offset(beam.b, 0), Prop.roller),
      ];

/// The way a value in kilonewtons is written on a drawing.
String kn(double v) {
  final rounded = (v * 10).round() / 10;
  final text = rounded == rounded.roundToDouble()
      ? rounded.round().toString()
      : rounded.toString();
  return '$text kN';
}

/// A shear or moment diagram, drawn under its beam.
class DiagramPainter extends CustomPainter {
  const DiagramPainter({
    required this.curve,
    required this.span,
    required this.peak,
    this.tone = AppColors.info,
    this.label = '',
  });

  /// The line to draw, in beam units.
  final List<Offset> curve;
  final double span;

  /// The tallest value any curve drawn beside this one reaches, so a set of
  /// choices is drawn to ONE scale and cannot be told apart by size.
  final double peak;

  final Color tone;
  final String label;

  static const _padX = 22.0;
  static const _padY = 16.0;

  static double xOf(Size size, double span, double at) =>
      _padX + at / span * (size.width - _padX * 2);

  static double yOf(Size size, double peak, double value) {
    final mid = size.height / 2;
    if (peak <= 0) return mid;
    return mid - value / peak * (size.height / 2 - _padY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final zero = yOf(size, peak, 0);
    canvas.drawLine(
      Offset(xOf(size, span, 0), zero),
      Offset(xOf(size, span, span), zero),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1.2,
    );

    final path = Path();
    for (var i = 0; i < curve.length; i++) {
      final p = Offset(
        xOf(size, span, curve[i].dx),
        yOf(size, peak, curve[i].dy),
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    // Filled to the zero line, because the area under it is the thing the
    // lesson keeps asking about.
    final shade = Path.from(path)
      ..lineTo(xOf(size, span, curve.last.dx), zero)
      ..lineTo(xOf(size, span, curve.first.dx), zero)
      ..close();
    canvas.drawPath(shade, Paint()..color = tone.withValues(alpha: 0.14));
    canvas.drawPath(
      path,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );

    if (label.isNotEmpty) {
      TextPainter(
        text: TextSpan(
          text: label,
          style: AppTheme.mono(size: 10, color: AppColors.ink3),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, const Offset(3, 2));
    }
  }

  @override
  bool shouldRepaint(DiagramPainter old) =>
      old.curve != curve || old.tone != tone || old.peak != peak;
}
