import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'vector_figures.dart';

/// Which way a turn goes, and the third possibility nobody expects.
enum Turn { counter, clockwise, none }

/// A curved arrow, or a barred circle when there is no turn at all. Drawn
/// rather than named, because "counterclockwise" is a word you have to
/// translate and a curl is something you just see.
class TurnGlyphPainter extends CustomPainter {
  const TurnGlyphPainter({required this.turn, required this.color});

  final Turn turn;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (turn == Turn.none) {
      canvas.drawCircle(center, radius, paint);
      canvas.drawLine(
        center + Offset(-radius, radius) * 0.75,
        center + Offset(radius, -radius) * 0.75,
        paint,
      );
      return;
    }

    // Counterclockwise sweeps the other way round, and the head goes on the
    // end the sweep finishes at.
    final ccw = turn == Turn.counter;
    const start = math.pi * 0.75;
    final sweep = (ccw ? -1 : 1) * math.pi * 1.4;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      paint,
    );

    final end = start + sweep;
    final tipAt = center + Offset(math.cos(end), math.sin(end)) * radius;
    // The tangent at the end of the sweep, pointing the way it is travelling.
    final along = Offset(-math.sin(end), math.cos(end)) * (ccw ? -1 : 1);
    final side = Offset(-along.dy, along.dx);
    const head = 9.0;
    canvas.drawPath(
      Path()
        ..moveTo(tipAt.dx, tipAt.dy)
        ..lineTo(
          (tipAt - along * head + side * head * 0.5).dx,
          (tipAt - along * head + side * head * 0.5).dy,
        )
        ..lineTo(
          (tipAt - along * head - side * head * 0.5).dx,
          (tipAt - along * head - side * head * 0.5).dy,
        )
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(TurnGlyphPainter old) =>
      old.turn != turn || old.color != color;
}

/// The shapes two edge vectors make between them.
enum Region { triangle, parallelogram, rectangle }

/// One little picture of a region, for the rounds that ask which area a
/// formula is talking about. The two edges are always drawn the same; only the
/// shaded part changes, so the three cards differ in exactly the thing being
/// asked about.
class RegionPainter extends CustomPainter {
  const RegionPainter({
    required this.u,
    required this.v,
    required this.region,
    required this.color,
  });

  final Vec u;
  final Vec v;
  final Region region;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // The three regions share one scale, so the box really does look bigger
    // than the parallelogram it is standing in for. That comparison is the
    // whole reason the box card exists.
    final all = <Vec>[
      const Vec(0, 0),
      u,
      v,
      u + v,
      ..._boxCorners(),
    ];
    final maxX = all.map((p) => p.x).reduce(math.max);
    final minX = all.map((p) => p.x).reduce(math.min);
    final maxY = all.map((p) => p.y).reduce(math.max);
    final minY = all.map((p) => p.y).reduce(math.min);
    final scale = math.min(
      (size.width - 22) / math.max(maxX - minX, 0.001),
      (size.height - 22) / math.max(maxY - minY, 0.001),
    );
    // Centred in whatever room is left over.
    final padX = (size.width - (maxX - minX) * scale) / 2;
    final padY = (size.height - (maxY - minY) * scale) / 2;
    Offset at(double x, double y) => Offset(
      padX + (x - minX) * scale,
      size.height - padY - (y - minY) * scale,
    );

    final corners = switch (region) {
      Region.triangle => [const Vec(0, 0), u, v],
      Region.parallelogram => [const Vec(0, 0), u, u + v, v],
      Region.rectangle => _boxCorners(),
    };

    final path = Path()..moveTo(at(corners.first.x, corners.first.y).dx,
        at(corners.first.x, corners.first.y).dy);
    for (final c in corners.skip(1)) {
      path.lineTo(at(c.x, c.y).dx, at(c.x, c.y).dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.22));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    // The two edges themselves, on top, so every card shows the same pair.
    final edge = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(at(0, 0), at(u.x, u.y), edge);
    canvas.drawLine(at(0, 0), at(v.x, v.y), edge);
  }

  /// The rectangle whose area is the two LENGTHS multiplied, which is what
  /// dropping the sine leaves you with: one side along u, the other square to
  /// it and as long as v.
  List<Vec> _boxCorners() {
    if (u.length < 1e-9) return const [Vec(0, 0)];
    final along = u * (1 / u.length);
    // Square to u, turned the way v leans so the box sits over the plot.
    var square = Vec(-along.y, along.x);
    if (square.x * v.x + square.y * v.y < 0) square = square * -1;
    final side = square * v.length;
    return [const Vec(0, 0), u, u + side, side];
  }

  @override
  bool shouldRepaint(RegionPainter old) =>
      old.region != region || old.u != u || old.v != v || old.color != color;
}
