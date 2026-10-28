import 'dart:math' as math;

import 'package:flutter/material.dart' hide TextPainter, Path;

import '../packs/drawing/figure_corner.dart';
import '../packs/drawing/figure_path.dart';

import '../packs/drawing/figure_text.dart';
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
    // 17 off the middle on the side away from the centre, turned unless
    // the label is upright (figure_corner.dart).
    turnBeside(canvas, p, q, away: center, by: 17, turned: angle != 0);
    _text(canvas, text, const Spot(Offset.zero), color, 13);
    canvas.restore();
  }

  void _angleArc(Canvas canvas, ObliqueGeometry g, String name, Color color) {
    final at = g.vertex(name);
    final others = ['A', 'B', 'C'].where((n) => n != name).toList();
    // From the side toward the first other corner to the side toward the
    // second, the short way round (figure_corner.dart).
    drawCornerArc(
      canvas,
      at,
      g.vertex(others[0]),
      g.vertex(others[1]),
      radius: 24,
      paint: Paint()
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
    // 20 out from the corner, away from the centre.
    _text(canvas, text, Spot.pushed(at, away, 20), color, 13.5);
  }

  void _text(Canvas canvas, String text, Spot at, Color color, double size) {
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
    tp.paintCentred(canvas, at);
  }

  @override
  bool shouldRepaint(ObliqueTrianglePainter old) =>
      old.knownSides != knownSides ||
      old.knownAngles != knownAngles ||
      old.wanted != wanted;
}
