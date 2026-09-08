import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A plain coordinate grid you can point at.
///
/// The lesson is about reading a centre and a radius straight off an equation,
/// so the honest way to answer is to put a finger where the centre is, not to
/// pick a pair of numbers out of a list.
@immutable
class GridGeometry {
  const GridGeometry(this.size, {this.span = 6});

  final Size size;

  /// The grid runs from -span to +span on both axes.
  final int span;

  double get step => (size.shortestSide * 0.92) / (span * 2);

  Offset get origin => Offset(size.width / 2, size.height / 2);

  Offset toScreen(int x, int y) => at(x.toDouble(), y.toDouble());

  /// The same mapping for a point that is not on the lattice, which is what an
  /// arrow head needs when a vector has been scaled by something fractional.
  Offset at(double x, double y) => origin + Offset(x * step, -y * step);

  /// The lattice point nearest a tap, or null if the tap was off the grid.
  ///
  /// The pitch on a phone is about 28 points, well under the 44 a fingertip
  /// wants, so a tap resolves to whichever point it is NEAREST rather than
  /// having to land on one. A near miss then costs you the neighbouring point
  /// instead of doing nothing at all, which is the better failure.
  (int, int)? nearest(Offset p, {double tolerance = 0.5}) {
    final dx = (p.dx - origin.dx) / step;
    final dy = (origin.dy - p.dy) / step;
    final x = dx.round();
    final y = dy.round();
    if (x.abs() > span || y.abs() > span) return null;
    if ((dx - x).abs() > tolerance || (dy - y).abs() > tolerance) return null;
    return (x, y);
  }
}

class GridPainter extends CustomPainter {
  const GridPainter({
    this.span = 6,
    this.picked,
    this.truth,
    this.revealed = false,
    this.radius,
  });

  final int span;

  /// Where the student pointed, and where the answer is.
  final (int, int)? picked;
  final (int, int)? truth;
  final bool revealed;

  /// Drawn once the answer is out, so the circle the equation describes is
  /// visible rather than merely asserted.
  final double? radius;

  @override
  void paint(Canvas canvas, Size size) {
    final g = GridGeometry(size, span: span);

    final fine = Paint()
      ..color = AppColors.charcoal.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    for (var i = -span; i <= span; i++) {
      canvas.drawLine(g.toScreen(i, -span), g.toScreen(i, span), fine);
      canvas.drawLine(g.toScreen(-span, i), g.toScreen(span, i), fine);
    }

    final axis = Paint()
      ..color = AppColors.ink2
      ..strokeWidth = 2;
    canvas.drawLine(g.toScreen(-span, 0), g.toScreen(span, 0), axis);
    canvas.drawLine(g.toScreen(0, -span), g.toScreen(0, span), axis);

    for (var i = -span; i <= span; i += 2) {
      if (i == 0) continue;
      _tick(canvas, '$i', g.toScreen(i, 0) + const Offset(0, 14));
      _tick(canvas, '$i', g.toScreen(0, i) + const Offset(-16, 0));
    }

    if (revealed && truth != null && radius != null) {
      canvas.drawCircle(
        g.toScreen(truth!.$1, truth!.$2),
        radius! * g.step,
        Paint()
          ..color = AppColors.forest.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    void dot((int, int) at, Color color) {
      final p = g.toScreen(at.$1, at.$2);
      canvas.drawCircle(p, 8, Paint()..color = color);
      canvas.drawCircle(
        p,
        14,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (picked != null && (!revealed || picked != truth)) {
      dot(picked!, revealed ? AppColors.error : AppColors.ember);
    }
    if (revealed && truth != null) dot(truth!, AppColors.forest);
  }

  void _tick(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.mono(size: 10, color: AppColors.ink3),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(GridPainter old) =>
      old.picked != picked ||
      old.truth != truth ||
      old.revealed != revealed ||
      old.radius != radius;
}
