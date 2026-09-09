import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'calculus_figures.dart';

/// A curve with the things root finding needs drawn on it: the axis it is
/// hunting for a crossing of, the tangent one step of Newton's method follows,
/// candidate landing places along that axis, and brackets underneath it.
///
/// Both methods in this lesson are pictures before they are formulas. Newton
/// slides down a tangent to the axis; bisection keeps whichever half still has
/// the curve on both sides of the axis. Neither is worth memorizing as a
/// formula by somebody who has not watched it happen.
class RootPainter extends CustomPainter {
  const RootPainter({
    required this.poly,
    required this.x0,
    required this.x1,
    this.tangentAt,
    this.candidates = const [],
    this.picked,
    this.truth,
    this.revealed = false,
    this.brackets = const [],
    this.pickedBracket,
    this.truthBracket,
  });

  final Poly poly;
  final double x0;
  final double x1;

  /// Where to draw the tangent, for the rounds about Newton's method.
  final double? tangentAt;

  /// Places along the axis worth pointing at.
  final List<double> candidates;
  final int? picked;
  final int? truth;
  final bool revealed;

  /// Spans drawn under the axis, for the rounds about bracketing.
  final List<(double, double)> brackets;
  final int? pickedBracket;
  final int? truthBracket;

  @override
  void paint(Canvas canvas, Size size) {
    final (lo, hi) = poly.range(x0, x1);
    // Always keep the axis itself in view: a root hunt with no axis on screen
    // is a picture of nothing.
    final yLo = math.min(lo, -0.1 * (hi - lo));
    final yHi = math.max(hi, 0.1 * (hi - lo));

    // Brackets get a band of their own under the drawing, one row each. They
    // are allowed to overlap on the x axis, and two bars on one line with
    // their labels on top of each other is unreadable.
    final bandHeight = brackets.isEmpty ? 0.0 : brackets.length * 15.0 + 10;
    final plot = Size(size.width, size.height - bandHeight);
    final g = CurveGeometry(plot, x0: x0, x1: x1, yLo: yLo, yHi: yHi);

    canvas.drawLine(
      g.toScreen(x0, 0),
      g.toScreen(x1, 0),
      Paint()
        ..color = AppColors.ink2
        ..strokeWidth = 1.6,
    );

    // Numbers on the axis only when nothing else is claiming that space. The
    // candidate rounds label the candidates themselves instead, which is what
    // the reader actually has to match against the buttons.
    if (candidates.isEmpty) {
      for (var i = x0.ceil(); i <= x1.floor(); i++) {
        if (i == 0) continue;
        final at = g.toScreen(i.toDouble(), 0);
        canvas.drawLine(
          at,
          at + const Offset(0, 4),
          Paint()..color = AppColors.ink3,
        );
        _label(canvas, '$i', at + const Offset(0, 14));
      }
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

    final start = tangentAt;
    if (start != null) {
      final slope = poly.d.at(start);
      final y = poly.at(start);
      double lineAt(double x) => y + slope * (x - start);
      canvas.drawLine(
        g.toScreen(x0, lineAt(x0)),
        g.toScreen(x1, lineAt(x1)),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      final onCurve = g.toScreen(start, y);
      canvas.drawCircle(onCurve, 9, Paint()..color = AppColors.emberBg);
      canvas.drawCircle(onCurve, 5.5, Paint()..color = AppColors.ember);
      _label(
        canvas,
        'start',
        onCurve + const Offset(0, -18),
        color: AppColors.ember,
      );
    }

    for (final (i, span) in brackets.indexed) {
      final y = size.height - bandHeight + 12 + i * 15;
      final color = (revealed && truthBracket == i)
          ? AppColors.forest
          : (revealed && pickedBracket == i)
          ? AppColors.error
          : pickedBracket == i
          ? AppColors.ember
          : AppColors.ink3;
      final a = g.toScreen(span.$1, 0).dx;
      final b = g.toScreen(span.$2, 0).dx;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(a, y), Offset(b, y), paint);
      canvas.drawLine(Offset(a, y - 6), Offset(a, y + 6), paint);
      canvas.drawLine(Offset(b, y - 6), Offset(b, y + 6), paint);
      _label(
        canvas,
        String.fromCharCode(65 + i),
        Offset(math.min(a, b) - 12, y),
        color: color,
      );
    }

    for (final (i, x) in candidates.indexed) {
      final at = g.toScreen(x, 0);
      _label(
        canvas,
        x == x.roundToDouble() ? '${x.toInt()}' : '$x',
        at + const Offset(0, 20),
      );
      final isTruth = revealed && truth == i;
      final isWrong = revealed && picked == i && truth != i;
      final color = isTruth
          ? AppColors.forest
          : isWrong
          ? AppColors.error
          : picked == i
          ? AppColors.ember
          : AppColors.ink3;
      canvas.drawCircle(at, 8, Paint()..color = color);
      canvas.drawCircle(
        at,
        14,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset at, {
    Color color = AppColors.ink3,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(RootPainter old) =>
      old.picked != picked ||
      old.pickedBracket != pickedBracket ||
      old.revealed != revealed ||
      old.poly != poly ||
      old.tangentAt != tangentAt;
}
