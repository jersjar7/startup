import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'beam_figures.dart';
import 'diagram_figures.dart';

/// The entries in the handbook's deflection tables that this lesson uses.
///
/// The lesson is explicit that nothing here is derived: you match the beam in
/// front of you to a line in a table. So the table is the model.
enum Entry {
  /// Simply supported, one load at midspan.
  ssPoint,

  /// Simply supported, load spread evenly over the whole span.
  ssUdl,

  /// Simply supported, one load somewhere other than the middle.
  ssOffset,

  /// Built in at one end, load at the free end.
  cantPoint,

  /// Built in at one end, load spread over the whole length.
  cantUdl,
}

extension EntryFacts on Entry {
  /// The formula as the handbook writes it.
  String get tex => switch (this) {
        Entry.ssPoint => r'\dfrac{PL^3}{48EI}',
        Entry.ssUdl => r'\dfrac{5wL^4}{384EI}',
        Entry.ssOffset => r'\dfrac{Pa^2b^2}{3EIL}',
        Entry.cantPoint => r'\dfrac{PL^3}{3EI}',
        Entry.cantUdl => r'\dfrac{wL^4}{8EI}',
      };

  String get plain => switch (this) {
        Entry.ssPoint => 'simply supported, load at midspan',
        Entry.ssUdl => 'simply supported, load spread evenly',
        Entry.ssOffset => 'simply supported, load off center',
        Entry.cantPoint => 'cantilever, load at the free end',
        Entry.cantUdl => 'cantilever, load spread evenly',
      };

  bool get cantilever => this == Entry.cantPoint || this == Entry.cantUdl;
  bool get spread => this == Entry.ssUdl || this == Entry.cantUdl;

  /// How far the beam sags, in the units the numbers are given in: newtons,
  /// millimeters, megapascals.
  ///
  /// [load] is a force for the point cases and a force per millimeter for the
  /// spread ones. [at] is how far along a load that is not at the middle sits.
  double sag({
    required double load,
    required double span,
    required double e,
    required double i,
    double at = 0,
  }) {
    final l = span;
    return switch (this) {
      Entry.ssPoint => load * l * l * l / (48 * e * i),
      Entry.ssUdl => 5 * load * math.pow(l, 4) / (384 * e * i),
      Entry.ssOffset => load *
          at *
          at *
          (l - at) *
          (l - at) /
          (3 * e * i * l),
      Entry.cantPoint => load * l * l * l / (3 * e * i),
      Entry.cantUdl => load * math.pow(l, 4) / (8 * e * i),
    };
  }

  /// The beam this entry belongs to, so the picture and the formula cannot
  /// disagree about what is being held up and where the load sits.
  Loading beamOf({required double span, double load = 1, double at = 0}) =>
      switch (this) {
        Entry.ssPoint => Loading(span: span, points: [(span / 2, load)]),
        Entry.ssOffset => Loading(span: span, points: [(at, load)]),
        Entry.ssUdl =>
          Loading(span: span, spreads: [Spread(0, span, load, load)]),
        Entry.cantPoint => Loading(
            span: span,
            held: Held.cantilever,
            points: [(span, load)],
          ),
        Entry.cantUdl => Loading(
            span: span,
            held: Held.cantilever,
            spreads: [Spread(0, span, load, load)],
          ),
      };

  /// The shape the beam takes, as a list of (position, sag) with sag positive
  /// downward, normalized so the worst point is one.
  ///
  /// Drawn shapes only: a real beam sags a few millimeters over meters of
  /// span and at true scale every one of these is a straight line.
  List<Offset> shape({required double span, double at = 0}) {
    final out = <Offset>[];
    const steps = 48;
    for (var k = 0; k <= steps; k++) {
      final x = span * k / steps;
      out.add(Offset(x, _sagAt(x, span, at)));
    }
    var peak = 0.0;
    for (final p in out) {
      if (p.dy.abs() > peak) peak = p.dy.abs();
    }
    if (peak == 0) return out;
    return [for (final p in out) Offset(p.dx, p.dy / peak)];
  }

  /// The elastic curve, to a constant. Standard results, not derived here.
  double _sagAt(double x, double l, double a) {
    switch (this) {
      case Entry.ssPoint:
        final t = x <= l / 2 ? x : l - x;
        return t * (3 * l * l - 4 * t * t);
      case Entry.ssUdl:
        return x * (l * l * l - 2 * l * x * x + x * x * x);
      case Entry.ssOffset:
        final b = l - a;
        if (x <= a) {
          return b * x * (l * l - b * b - x * x);
        }
        final u = l - x;
        return a * u * (l * l - a * a - u * u);
      case Entry.cantPoint:
        return x * x * (3 * l - x);
      case Entry.cantUdl:
        return x * x * (6 * l * l - 4 * l * x + x * x);
    }
  }
}

/// A beam drawn with the shape it sags into, exaggerated so it can be seen.
class SagPainter extends CustomPainter {
  const SagPainter({
    required this.entry,
    required this.span,
    this.at = 0,
    this.tone = AppColors.ember,
    this.ghost = true,
  });

  final Entry entry;
  final double span;
  final double at;
  final Color tone;

  /// Draw the straight beam it started as, behind the sagged one.
  final bool ghost;

  static const _padX = 26.0;
  static const _drop = 34.0;

  double _x(Size size, double along) =>
      _padX + along / span * (size.width - _padX * 2);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2 - _drop / 2;
    if (ghost) {
      canvas.drawLine(
        Offset(_x(size, 0), y),
        Offset(_x(size, span), y),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
    }

    final path = Path();
    final points = entry.shape(span: span, at: at);
    for (var k = 0; k < points.length; k++) {
      final p = Offset(_x(size, points[k].dx), y + points[k].dy * _drop);
      k == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Where it is held, drawn on the line it started at.
    if (entry.cantilever) {
      final x = _x(size, 0);
      final ink = Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 1.8;
      canvas.drawLine(Offset(x, y - 16), Offset(x, y + 16), ink);
      for (var v = y - 16; v < y + 16; v += 7) {
        canvas.drawLine(Offset(x, v), Offset(x - 7, v + 6), ink);
      }
    } else {
      for (final along in [0.0, span]) {
        final x = _x(size, along);
        canvas.drawPath(
          Path()
            ..moveTo(x, y + 2)
            ..lineTo(x - 9, y + 15)
            ..lineTo(x + 9, y + 15)
            ..close(),
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }

    TextPainter(
      text: TextSpan(
        text: 'sag drawn far larger than life',
        style: AppTheme.mono(size: 10, color: AppColors.ink3),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, Offset(_padX, size.height - 14));
  }

  @override
  bool shouldRepaint(SagPainter old) =>
      old.entry != entry || old.span != span || old.tone != tone;
}

/// Two beams drawn side by side with a plus between them: one loading taken
/// apart into the two table entries that add up to it.
class PairPainter2 extends CustomPainter {
  const PairPainter2({required this.left, required this.right});

  final Loading left;
  final Loading right;

  @override
  void paint(Canvas canvas, Size size) {
    final half = Size(size.width / 2 - 14, size.height);
    for (final (i, beam) in [left, right].indexed) {
      canvas.save();
      canvas.translate(i == 0 ? 0 : size.width / 2 + 14, 0);
      BeamPainter(
        span: beam.span,
        supports: supportsOf(beam),
        spreads: beam.spreads,
        loads: [for (final p in beam.points) (p.$1, '')],
      ).paint(canvas, half);
      canvas.restore();
    }
    final plus = TextPainter(
      text: TextSpan(
        text: '+',
        style: AppTheme.mono(size: 18, color: AppColors.ink2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    plus.paint(
      canvas,
      Offset(size.width / 2 - plus.width / 2, size.height / 2 - plus.height),
    );
  }

  @override
  bool shouldRepaint(PairPainter2 old) =>
      old.left != left || old.right != right;
}
