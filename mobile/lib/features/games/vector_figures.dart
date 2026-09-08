import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'grid_figures.dart';

/// A vector in the plane, kept as components so the app works out lengths and
/// sums itself rather than being told them. A round states the arrows; what
/// counts as right comes out of the arithmetic here.
@immutable
class Vec {
  const Vec(this.x, this.y);

  final double x;
  final double y;

  double get length => math.sqrt(x * x + y * y);

  Vec operator +(Vec other) => Vec(x + other.x, y + other.y);
  Vec operator *(double k) => Vec(x * k, y * k);

  @override
  bool operator ==(Object other) =>
      other is Vec && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x, $y)';
}

/// One arrow on the grid. Arrows start at the origin unless a round is showing
/// a chain laid head to tail, which is the one thing worth drawing rather than
/// asserting.
@immutable
class Arrow {
  const Arrow(
    this.to, {
    this.from = const Vec(0, 0),
    this.color = AppColors.charcoal,
    this.label,
    this.faint = false,
  });

  final Vec from;
  final Vec to;
  final Color color;
  final String? label;

  /// Drawn thin and pale: a working line rather than a statement.
  final bool faint;
}

class VectorPainter extends CustomPainter {
  const VectorPainter({
    required this.arrows,
    this.span = 6,
    this.picked,
    this.truth,
    this.revealed = false,
    this.lattice = false,
    this.guide,
  });

  final List<Arrow> arrows;
  final int span;

  /// Where the student put a finger, and where the answer is, for the rounds
  /// that are answered by pointing at the grid.
  final (int, int)? picked;
  final (int, int)? truth;
  final bool revealed;

  /// Faint dots at every whole point, so a target is visible before it is hit.
  final bool lattice;

  /// A direction drawn as a dashed line right across the grid. An arrow one
  /// unit long is a stub on a grid this size; the LINE it sits on is what a
  /// student is actually sizing along, so the line gets drawn.
  final Vec? guide;

  @override
  void paint(Canvas canvas, Size size) {
    final g = GridGeometry(size, span: span);

    final fine = Paint()
      ..color = AppColors.charcoal.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var i = -span; i <= span; i++) {
      canvas.drawLine(g.toScreen(i, -span), g.toScreen(i, span), fine);
      canvas.drawLine(g.toScreen(-span, i), g.toScreen(span, i), fine);
    }

    final axis = Paint()
      ..color = AppColors.ink2
      ..strokeWidth = 1.6;
    canvas.drawLine(g.toScreen(-span, 0), g.toScreen(span, 0), axis);
    canvas.drawLine(g.toScreen(0, -span), g.toScreen(0, span), axis);

    if (lattice) {
      final dot = Paint()..color = AppColors.ink3.withValues(alpha: 0.5);
      for (var x = -span; x <= span; x++) {
        for (var y = -span; y <= span; y++) {
          canvas.drawCircle(g.toScreen(x, y), 1.9, dot);
        }
      }
    }

    // Numbers on the axes, so the length of an arrow can be counted rather
    // than guessed. Two arrows six percent apart are not tellable by eye, and
    // that is the point of the comparison rounds, not a reason to hide the
    // evidence.
    for (var i = -span; i <= span; i += 2) {
      if (i == 0) continue;
      _tick(canvas, '$i', g.toScreen(i, 0) + const Offset(0, 13));
      _tick(canvas, '$i', g.toScreen(0, i) + const Offset(-15, 0));
    }

    final line = guide;
    if (line != null && line.length > 0) {
      final unit = line * (1 / line.length);
      final reach = span * 1.35;
      _dashed(
        canvas,
        g.at(-unit.x * reach, -unit.y * reach),
        g.at(unit.x * reach, unit.y * reach),
      );
    }

    for (final a in arrows) {
      _arrow(canvas, g, a);
    }

    void mark((int, int) at, Color color) {
      final p = g.toScreen(at.$1, at.$2);
      canvas.drawCircle(p, 7, Paint()..color = color);
      canvas.drawCircle(
        p,
        13,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (picked != null && (!revealed || picked != truth)) {
      mark(picked!, revealed ? AppColors.error : AppColors.ember);
    }
    if (revealed && truth != null) mark(truth!, AppColors.forest);
  }

  void _dashed(Canvas canvas, Offset a, Offset b) {
    final paint = Paint()
      ..color = AppColors.ink3.withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    final total = (b - a).distance;
    if (total < 1) return;
    final unit = (b - a) / total;
    for (var t = 0.0; t < total; t += 11) {
      canvas.drawLine(a + unit * t, a + unit * math.min(t + 6, total), paint);
    }
  }

  void _tick(Canvas canvas, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.mono(size: 9.5, color: AppColors.ink3),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  void _arrow(Canvas canvas, GridGeometry g, Arrow a) {
    final from = g.at(a.from.x, a.from.y);
    final to = g.at(a.to.x, a.to.y);
    if ((to - from).distance < 0.5) return;

    final paint = Paint()
      ..color = a.faint ? a.color.withValues(alpha: 0.45) : a.color
      ..strokeWidth = a.faint ? 1.8 : 3
      ..strokeCap = StrokeCap.round;

    final unit = (to - from) / (to - from).distance;
    final head = a.faint ? 8.0 : 11.0;
    canvas.drawLine(from, to - unit * (head * 0.6), paint);

    final left = Offset(-unit.dy, unit.dx);
    final tip = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(
        (to - unit * head + left * head * 0.45).dx,
        (to - unit * head + left * head * 0.45).dy,
      )
      ..lineTo(
        (to - unit * head - left * head * 0.45).dx,
        (to - unit * head - left * head * 0.45).dy,
      )
      ..close();
    canvas.drawPath(tip, Paint()..color = paint.color);

    final label = a.label;
    if (label == null) return;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: AppTheme.mono(
          size: 12,
          color: a.faint ? AppColors.ink3 : a.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Sit the label just past the head, pushed clear of the shaft.
    final place = to + unit * 12 + left * 10;
    tp.paint(canvas, place - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(VectorPainter old) =>
      old.picked != picked ||
      old.truth != truth ||
      old.revealed != revealed ||
      old.guide != guide ||
      old.arrows != arrows;
}
