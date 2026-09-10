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

/// A direction with whole-number marks along it: the member a force is being
/// projected onto. [unit] must be one long, so mark `i` really is `i` away
/// from the origin.
@immutable
class RulerLine {
  const RulerLine({required this.unit, required this.from, required this.to});

  final Vec unit;
  final int from;
  final int to;
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
    this.between,
    this.ruler,
    this.rulerPick,
    this.rulerTruth,
    this.drop,
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

  /// Two arrows to sweep an arc between, so the angle is a thing on the page
  /// rather than something the reader has to imagine.
  final (Vec, Vec)? between;

  /// A line with whole-number marks along it, for the rounds answered by
  /// pointing at a distance rather than at a lattice point.
  final RulerLine? ruler;
  final int? rulerPick;
  final int? rulerTruth;

  /// A point to drop a dashed perpendicular from onto the ruler, drawn once
  /// the answer is out. This is the whole definition of a projection, so it
  /// is worth showing rather than describing.
  final Vec? drop;

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
      // The x-axis writes its numbers below the line, so the first y number
      // below the origin lands in among them. Skip that one; the lattice is
      // still there to count on.
      if (i < 0 && i.abs() * g.step < 30) continue;
      _tick(canvas, '$i', g.toScreen(0, i) + const Offset(-15, 0));
    }

    final rule = ruler;
    if (rule != null) {
      final u = rule.unit;
      _dashed(
        canvas,
        g.at(u.x * (rule.from - 0.7), u.y * (rule.from - 0.7)),
        g.at(u.x * (rule.to + 0.7), u.y * (rule.to + 0.7)),
      );
      final side = Offset(-u.y, u.x);
      final tickPaint = Paint()
        ..color = AppColors.ink2
        ..strokeWidth = 1.5;
      for (var i = rule.from; i <= rule.to; i++) {
        final at = g.at(u.x * i, u.y * i);
        canvas.drawLine(at - side * 7, at + side * 7, tickPaint);
        canvas.drawCircle(at, 2.2, Paint()..color = AppColors.ink2);
        // Number every other mark, off to one side of the line, so a student
        // can say which mark they are aiming at rather than counting from the
        // origin every time.
        // Above the line rather than below it: a member lying along an axis
        // would otherwise stack its numbers on top of the axis numbers.
        if (i % 2 == 0 && i != 0) {
          _tick(canvas, '$i', at - side * 18);
        }
      }
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

    final arc = between;
    if (arc != null) {
      final (u, v) = arc;
      if (u.length > 0 && v.length > 0) {
        final radius = g.step * 2.0;
        final a0 = math.atan2(-u.y, u.x);
        final a1 = math.atan2(-v.y, v.x);
        var sweep = a1 - a0;
        while (sweep > math.pi) {
          sweep -= 2 * math.pi;
        }
        while (sweep < -math.pi) {
          sweep += 2 * math.pi;
        }
        canvas.drawArc(
          Rect.fromCircle(center: g.origin, radius: radius),
          a0,
          sweep,
          false,
          Paint()
            ..color = AppColors.ink2.withValues(alpha: 0.8)
            ..strokeWidth = 1.6
            ..style = PaintingStyle.stroke,
        );
      }
    }

    final tip = drop;
    if (tip != null && rule != null) {
      final u = rule.unit;
      final along = tip.x * u.x + tip.y * u.y;
      final foot = Vec(u.x * along, u.y * along);
      _dashed(canvas, g.at(tip.x, tip.y), g.at(foot.x, foot.y));
    }

    if (rule != null) {
      void tick(int i, Color color) {
        final at = g.at(rule.unit.x * i, rule.unit.y * i);
        canvas.drawCircle(at, 7, Paint()..color = color);
        canvas.drawCircle(
          at,
          13,
          Paint()
            ..color = color.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      if (rulerPick != null && (!revealed || rulerPick != rulerTruth)) {
        tick(rulerPick!, revealed ? AppColors.error : AppColors.ember);
      }
      if (revealed && rulerTruth != null) {
        tick(rulerTruth!, AppColors.forest);
      }
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
    // Beside the head, and pushed off whichever axis the arrow runs along. A
    // label set beyond the head of an arrow lying on the x-axis lands exactly
    // where that axis writes its numbers, which is where "A" was coming out
    // as "A 6".
    final flat = unit.dy.abs() < 0.35;
    final upright = unit.dx.abs() < 0.35;
    final Offset place;
    if (flat) {
      place = to + unit * 7 + Offset(0, -tp.height - 5);
    } else if (upright) {
      place = to + Offset(tp.width / 2 + 10, unit.dy * 7);
    } else {
      place = to + unit * 12 + left * 10;
    }
    tp.paint(canvas, place - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(VectorPainter old) =>
      old.picked != picked ||
      old.truth != truth ||
      old.revealed != revealed ||
      old.guide != guide ||
      old.rulerPick != rulerPick ||
      old.rulerTruth != rulerTruth ||
      old.drop != drop ||
      old.arrows != arrows;
}
