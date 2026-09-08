import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// An oblique triangle: no right angle, vertices A, B, C, with side a opposite
/// angle A and so on. Everything this lesson asks turns on which parts you were
/// handed, so the figure's whole job is to show that clearly.
@immutable
class ObliqueGeometry {
  const ObliqueGeometry(this.size);

  final Size size;

  Offset get a => Offset(size.width * 0.12, size.height * 0.82);
  Offset get b => Offset(size.width * 0.88, size.height * 0.82);
  Offset get c => Offset(size.width * 0.58, size.height * 0.16);

  Offset vertex(String name) => switch (name) {
    'A' => a,
    'B' => b,
    _ => c,
  };

  /// A side is named by the lowercase of the angle it faces.
  (Offset, Offset) side(String name) => switch (name) {
    'a' => (b, c),
    'b' => (a, c),
    _ => (a, b),
  };
}

/// Draws the triangle with the given parts marked as known or wanted.
class ObliqueTrianglePainter extends CustomPainter {
  const ObliqueTrianglePainter({
    this.knownSides = const {},
    this.knownAngles = const {},
    this.wanted,
    this.labelAll = true,
  });

  /// Lowercase side names: a, b, c.
  final Set<String> knownSides;

  /// Uppercase angle names: A, B, C.
  final Set<String> knownAngles;

  /// The part being asked for: a side ('b') or an angle ('C').
  final String? wanted;

  /// Write every side and angle name, so the picture can be read on its own.
  final bool labelAll;

  @override
  void paint(Canvas canvas, Size size) {
    final g = ObliqueGeometry(size);

    canvas.drawPath(
      Path()
        ..moveTo(g.a.dx, g.a.dy)
        ..lineTo(g.b.dx, g.b.dy)
        ..lineTo(g.c.dx, g.c.dy)
        ..close(),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    for (final name in ['a', 'b', 'c']) {
      final known = knownSides.contains(name);
      final asked = wanted == name;
      if (known || asked) {
        final (p, q) = g.side(name);
        canvas.drawLine(
          p,
          q,
          Paint()
            ..color = asked ? AppColors.ember : AppColors.forest
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round,
        );
      }
      if (labelAll || known || asked) {
        _sideLabel(
          canvas,
          g,
          name,
          asked ? '$name = ?' : name,
          asked
              ? AppColors.ember
              : known
              ? AppColors.forest
              : AppColors.ink3,
        );
      }
    }

    for (final name in ['A', 'B', 'C']) {
      final known = knownAngles.contains(name);
      final asked = wanted == name;
      if (known || asked) {
        _angleArc(canvas, g, name, asked ? AppColors.ember : AppColors.forest);
      }
      if (labelAll || known || asked) {
        _angleLabel(
          canvas,
          g,
          name,
          asked ? '$name = ?' : name,
          asked
              ? AppColors.ember
              : known
              ? AppColors.forest
              : AppColors.ink3,
        );
      }
    }
  }

  /// Beside the side, turned to its angle, never across it.
  void _sideLabel(
    Canvas canvas,
    ObliqueGeometry g,
    String name,
    String text,
    Color color,
  ) {
    final (p, q) = g.side(name);
    final mid = (p + q) / 2;
    final along = q - p;
    final unit = along / along.distance;
    var normal = Offset(-unit.dy, unit.dx);
    final center = (g.a + g.b + g.c) / 3;
    if ((mid + normal - center).distance < (mid - normal - center).distance) {
      normal = -normal;
    }
    var angle = math.atan2(unit.dy, unit.dx);
    if (angle > math.pi / 2 || angle < -math.pi / 2) angle += math.pi;
    if ((angle.abs() - math.pi / 2).abs() < 0.26) angle = 0;
    // A one or two character label gains nothing from being turned and can
    // read as upside down at some angles, so it stays upright. Words follow
    // their line.
    if (text.characters.length <= 2) angle = 0;

    canvas.save();
    canvas.translate(mid.dx + normal.dx * 17, mid.dy + normal.dy * 17);
    canvas.rotate(angle);
    _text(canvas, text, Offset.zero, color, 13);
    canvas.restore();
  }

  void _angleArc(Canvas canvas, ObliqueGeometry g, String name, Color color) {
    final at = g.vertex(name);
    final others = ['A', 'B', 'C'].where((n) => n != name).toList();
    final u1 = (g.vertex(others[0]) - at);
    final u2 = (g.vertex(others[1]) - at);
    final start = math.atan2(u1.dy, u1.dx);
    final end = math.atan2(u2.dy, u2.dx);
    var sweep = end - start;
    if (sweep > math.pi) sweep -= 2 * math.pi;
    if (sweep < -math.pi) sweep += 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: at, radius: 24),
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _angleLabel(
    Canvas canvas,
    ObliqueGeometry g,
    String name,
    String text,
    Color color,
  ) {
    final at = g.vertex(name);
    final center = (g.a + g.b + g.c) / 3;
    final away = at - center;
    _text(canvas, text, at + away / away.distance * 20, color, 13.5);
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
  bool shouldRepaint(ObliqueTrianglePainter old) =>
      old.knownSides != knownSides ||
      old.knownAngles != knownAngles ||
      old.wanted != wanted;
}
