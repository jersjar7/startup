import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A polynomial, kept as coefficients so the app can differentiate it rather
/// than being told the answer.
///
/// Every round in this lesson states a curve and a question; what counts as
/// right is worked out from the curve itself. That way a typo in an answer is
/// a failing test instead of a wrong round shipped to a student.
@immutable
class Poly {
  const Poly(this.c);

  /// Ascending powers: `c[0] + c[1]x + c[2]x^2 + ...`
  final List<double> c;

  double at(double x) {
    var sum = 0.0;
    for (var i = c.length - 1; i >= 0; i--) {
      sum = sum * x + c[i];
    }
    return sum;
  }

  Poly get d => c.length < 2
      ? const Poly([0])
      : Poly([for (var i = 1; i < c.length; i++) c[i] * i]);

  Poly get dd => d.d;

  /// The lowest and highest the curve gets across a span, with a little air.
  (double, double) range(double x0, double x1) {
    var lo = double.infinity;
    var hi = -double.infinity;
    for (var i = 0; i <= 200; i++) {
      final y = at(x0 + (x1 - x0) * i / 200);
      lo = math.min(lo, y);
      hi = math.max(hi, y);
    }
    final pad = (hi - lo) * 0.12;
    return (lo - pad, hi + pad);
  }
}

/// Where a curve sits inside its box. The horizontal padding is deliberately
/// small and known, because the concavity strip below the drawing has to line
/// up with the dividers on it.
@immutable
class CurveGeometry {
  const CurveGeometry(
    this.size, {
    required this.x0,
    required this.x1,
    required this.yLo,
    required this.yHi,
  });

  final Size size;
  final double x0;
  final double x1;
  final double yLo;
  final double yHi;

  static const padX = 14.0;
  static const _padTop = 14.0;
  static const _padBottom = 24.0;

  double get _w => size.width - padX * 2;
  double get _h => size.height - _padTop - _padBottom;

  Offset toScreen(double x, double y) => Offset(
    padX + (x - x0) / (x1 - x0) * _w,
    _padTop + (yHi - y) / (yHi - yLo) * _h,
  );

  /// Screen x back to the curve's own units, for a drag.
  double mathX(double dx) => x0 + ((dx - padX) / _w) * (x1 - x0);
}

/// The curve itself, plus whatever the round has put on it: a marker being
/// dragged, the short tangent at that marker, dashed dividers, and after the
/// answer is out, the place the question was pointing at.
class CurvePainter extends CustomPainter {
  const CurvePainter({
    required this.poly,
    required this.x0,
    required this.x1,
    required this.yLo,
    required this.yHi,
    this.markerX,
    this.showTangent = false,
    this.cuts = const [],
    this.reveal,
    this.revealIsRight = false,
  });

  final Poly poly;
  final double x0;
  final double x1;
  final double yLo;
  final double yHi;

  /// Where the student's finger has put the marker, in curve units.
  final double? markerX;
  final bool showTangent;

  /// Dashed verticals that split the span into regions.
  final List<double> cuts;

  /// The place the question was asking about, drawn once the answer is out.
  final double? reveal;
  final bool revealIsRight;

  @override
  void paint(Canvas canvas, Size size) {
    final g = CurveGeometry(size, x0: x0, x1: x1, yLo: yLo, yHi: yHi);

    // The baseline: the x axis if it is in view, otherwise the floor.
    final axisY = (yLo <= 0 && yHi >= 0) ? 0.0 : yLo;
    canvas.drawLine(
      g.toScreen(x0, axisY),
      g.toScreen(x1, axisY),
      Paint()
        ..color = AppColors.charcoal.withValues(alpha: 0.25)
        ..strokeWidth = 1.4,
    );

    for (final cut in cuts) {
      _dashed(canvas, g.toScreen(cut, yHi), g.toScreen(cut, yLo));
    }

    final path = Path();
    for (var i = 0; i <= 240; i++) {
      final x = x0 + (x1 - x0) * i / 240;
      final p = g.toScreen(x, poly.at(x));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    if (reveal != null) {
      final p = g.toScreen(reveal!, poly.at(reveal!));
      final color = revealIsRight ? AppColors.forest : AppColors.error;
      canvas.drawCircle(p, 9, Paint()..color = color.withValues(alpha: 0.18));
      canvas.drawCircle(p, 5.5, Paint()..color = color);
    }

    final mx = markerX;
    if (mx == null) return;
    final my = poly.at(mx);
    final onCurve = g.toScreen(mx, my);

    canvas.drawLine(
      Offset(onCurve.dx, g.toScreen(mx, yHi).dy),
      Offset(onCurve.dx, g.toScreen(mx, yLo).dy),
      Paint()
        ..color = AppColors.ember.withValues(alpha: 0.35)
        ..strokeWidth = 1.6,
    );

    if (showTangent) {
      // The tangent is drawn in screen space, so its tilt is what the student
      // sees. No number is shown: reading flat off the picture is the skill.
      final slope = poly.d.at(mx);
      final sx = g._w / (x1 - x0);
      final sy = g._h / (yHi - yLo);
      final dir = Offset(sx, -slope * sy);
      final unit = dir / dir.distance;
      canvas.drawLine(
        onCurve - unit * 42,
        onCurve + unit * 42,
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawCircle(onCurve, 10, Paint()..color = AppColors.emberBg);
    canvas.drawCircle(
      onCurve,
      6,
      Paint()
        ..color = AppColors.ember
        ..style = PaintingStyle.fill,
    );
  }

  void _dashed(Canvas canvas, Offset a, Offset b) {
    final paint = Paint()
      ..color = AppColors.ink2.withValues(alpha: 0.85)
      ..strokeWidth = 1.4;
    final total = (b - a).distance;
    final unit = (b - a) / total;
    for (var t = 0.0; t < total; t += 10) {
      canvas.drawLine(
        a + unit * t,
        a + unit * math.min(t + 5, total),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CurvePainter old) =>
      old.markerX != markerX ||
      old.poly != poly ||
      old.reveal != reveal ||
      old.revealIsRight != revealIsRight ||
      old.cuts != cuts;
}

/// The x ruler under a curve: just the ends and the dividers, so a student can
/// say where they are without the drawing turning into a graph-paper exercise.
class CurveTicks extends StatelessWidget {
  const CurveTicks({
    super.key,
    required this.x0,
    required this.x1,
    required this.unit,
  });

  final double x0;
  final double x1;

  /// What one step along the bottom means, in the round's own words.
  final String unit;

  @override
  Widget build(BuildContext context) {
    final style = AppTheme.mono(size: 11, color: AppColors.ink3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CurveGeometry.padX),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${x0.toInt()}', style: style),
          Text(unit, style: style),
          Text('${x1.toInt()}', style: style),
        ],
      ),
    );
  }
}
