import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The unit circle, and the two things this lesson needs from it: a point at
/// an angle, and a quadrant.
@immutable
class CircleGeometry {
  const CircleGeometry(this.size);

  final Size size;

  Offset get center => Offset(size.width / 2, size.height / 2);
  double get radius => math.min(size.width, size.height) * 0.38;

  /// Screen position of an angle measured the mathematical way: from the
  /// positive x-axis, counter-clockwise.
  Offset pointAt(int degrees) {
    final rad = degrees * math.pi / 180;
    return center + Offset(math.cos(rad), -math.sin(rad)) * radius;
  }

  /// The angle a tap landed nearest, out of the ones on offer, or null if the
  /// tap was nowhere near the rim.
  int? angleNearest(Offset p, List<int> choices, {double tolerance = 46}) {
    int? best;
    var bestDistance = tolerance;
    for (final degrees in choices) {
      final d = (p - pointAt(degrees)).distance;
      if (d < bestDistance) {
        bestDistance = d;
        best = degrees;
      }
    }
    return best;
  }

  /// Which quadrant a tap fell in, 1 to 4, or null for a tap on an axis or
  /// well outside the circle.
  int? quadrantAt(Offset p) {
    final v = p - center;
    if (v.distance > radius * 1.45) return null;
    if (v.dx.abs() < 8 || v.dy.abs() < 8) return null;
    if (v.dx > 0 && v.dy < 0) return 1;
    if (v.dx < 0 && v.dy < 0) return 2;
    if (v.dx < 0 && v.dy > 0) return 3;
    return 4;
  }

  /// The middle of a quadrant, for drawing its label or highlight.
  Offset quadrantCenter(int quadrant) {
    final angle = switch (quadrant) {
      1 => 45,
      2 => 135,
      3 => 225,
      _ => 315,
    };
    final rad = angle * math.pi / 180;
    return center + Offset(math.cos(rad), -math.sin(rad)) * radius * 0.6;
  }
}

/// The exact coordinates the lesson asks students to know, written the way the
/// handbook writes them.
const unitCirclePoints = <int, (String, String)>{
  0: ('1', '0'),
  30: (r'\frac{\sqrt{3}}{2}', r'\frac{1}{2}'),
  45: (r'\frac{\sqrt{2}}{2}', r'\frac{\sqrt{2}}{2}'),
  60: (r'\frac{1}{2}', r'\frac{\sqrt{3}}{2}'),
  90: ('0', '1'),
  120: (r'-\frac{1}{2}', r'\frac{\sqrt{3}}{2}'),
  135: (r'-\frac{\sqrt{2}}{2}', r'\frac{\sqrt{2}}{2}'),
  150: (r'-\frac{\sqrt{3}}{2}', r'\frac{1}{2}'),
  180: ('-1', '0'),
  210: (r'-\frac{\sqrt{3}}{2}', r'-\frac{1}{2}'),
  225: (r'-\frac{\sqrt{2}}{2}', r'-\frac{\sqrt{2}}{2}'),
  240: (r'-\frac{1}{2}', r'-\frac{\sqrt{3}}{2}'),
  270: ('0', '-1'),
  300: (r'\frac{1}{2}', r'-\frac{\sqrt{3}}{2}'),
  315: (r'\frac{\sqrt{2}}{2}', r'-\frac{\sqrt{2}}{2}'),
  330: (r'\frac{\sqrt{3}}{2}', r'-\frac{1}{2}'),
};

class UnitCirclePainter extends CustomPainter {
  const UnitCirclePainter({
    this.choices = const [],
    this.picked,
    this.truth,
    this.revealed = false,
    this.highlightQuadrant,
    this.quadrantLabels = false,
    this.showRayTo,
  });

  /// The angles offered as dots on the rim.
  final List<int> choices;

  /// What the student touched, and what was right.
  final int? picked;
  final int? truth;
  final bool revealed;

  /// A quadrant shaded in, for the sign item.
  final int? highlightQuadrant;
  final bool quadrantLabels;

  /// Draws the radius out to this angle, with its drop lines.
  final int? showRayTo;

  @override
  void paint(Canvas canvas, Size size) {
    // The axes run edge to edge.
    // Clipped here rather than left to the widget, so that anything
    // leaving the panel is deliberate and the bounds check stays
    // honest.
    canvas.clipRect(Offset.zero & size);

    final g = CircleGeometry(size);

    if (highlightQuadrant != null) {
      // Screen y grows downward, so quadrant one is the sweep that ends at
      // the positive x-axis rather than the one that starts there.
      final from = switch (highlightQuadrant!) {
        1 => -math.pi / 2,
        2 => math.pi,
        3 => math.pi / 2,
        _ => 0.0,
      };
      canvas.drawArc(
        Rect.fromCircle(center: g.center, radius: g.radius),
        from,
        math.pi / 2,
        true,
        Paint()..color = AppColors.emberBg,
      );
    }

    // Axes.
    final axis = Paint()
      ..color = AppColors.ink3.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(g.center.dx - g.radius * 1.35, g.center.dy),
      Offset(g.center.dx + g.radius * 1.35, g.center.dy),
      axis,
    );
    canvas.drawLine(
      Offset(g.center.dx, g.center.dy - g.radius * 1.35),
      Offset(g.center.dx, g.center.dy + g.radius * 1.35),
      axis,
    );

    canvas.drawCircle(
      g.center,
      g.radius,
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    if (quadrantLabels) {
      for (var q = 1; q <= 4; q++) {
        _text(
          canvas,
          ['I', 'II', 'III', 'IV'][q - 1],
          g.quadrantCenter(q),
          AppColors.ink3,
          15,
        );
      }
    }

    if (showRayTo != null) {
      final p = g.pointAt(showRayTo!);
      canvas.drawLine(
        g.center,
        p,
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
      final drop = Paint()
        ..color = AppColors.ink3.withValues(alpha: 0.7)
        ..strokeWidth = 1.5;
      canvas.drawLine(p, Offset(p.dx, g.center.dy), drop);
      canvas.drawLine(p, Offset(g.center.dx, p.dy), drop);
    }

    for (final degrees in choices) {
      final at = g.pointAt(degrees);
      final isTruth = revealed && degrees == truth;
      final isWrongPick = revealed && degrees == picked && degrees != truth;
      final isPicked = !revealed && degrees == picked;

      final color = isTruth
          ? AppColors.forest
          : isWrongPick
          ? AppColors.error
          : isPicked
          ? AppColors.ember
          : AppColors.charcoal;
      final big = isTruth || isWrongPick || isPicked;

      canvas.drawCircle(at, big ? 9 : 5.5, Paint()..color = color);
      if (big) {
        canvas.drawCircle(
          at,
          14,
          Paint()
            ..color = color.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _text(Canvas canvas, String text, Offset at, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.heading(
          size: size,
          weight: FontWeight.w700,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(UnitCirclePainter old) =>
      old.choices != choices ||
      old.picked != picked ||
      old.truth != truth ||
      old.revealed != revealed ||
      old.highlightQuadrant != highlightQuadrant ||
      old.showRayTo != showRayTo;
}
