import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A circular shaft in cross-section, solid or bored out.
///
/// Everything the torsion items ask is a property of this, so a round declares
/// the shaft and the answers are worked out from it rather than stated beside
/// it.
@immutable
class Shaft {
  const Shaft({
    required this.outerD,
    this.innerD = 0,
    this.length = 1000,
    this.g = 80000,
    this.torque = 500000,
    this.e = 200000,
  });

  /// In millimeters.
  final double outerD;

  /// Nought for a solid shaft.
  final double innerD;

  final double length;

  /// Shear modulus in megapascals.
  final double g;

  /// In newton millimeters. Negative simply means the other way round.
  final double torque;

  /// Young's modulus, in megapascals. Nothing in torsion reads it, which is
  /// exactly why it is here: the round that changes it and nothing else has
  /// to have something to change.
  final double e;

  bool get hollow => innerD > 0;

  /// The distance from the middle out to where the stress is highest, which
  /// is the OUTER RADIUS. Every problem in this lesson names the diameter and
  /// half of them are got wrong by using it.
  double get c => outerD / 2;

  /// The POLAR second moment. Not the area one: that is half this, and using
  /// it halves the stress.
  double get j =>
      math.pi * (math.pow(outerD, 4) - math.pow(innerD, 4)) / 32;

  /// The area second moment, for comparison. J is exactly twice it.
  double get i => j / 2;

  double get shearStress => (torque * c / j).abs();

  /// In radians.
  double get twist => (torque * length / (g * j)).abs();

  /// Torque per radian.
  double get stiffness => g * j / length;
}

/// A shaft cross-section, with the dimensions that matter marked on it.
class ShaftPainter extends CustomPainter {
  const ShaftPainter({required this.shaft, this.markC = false});

  final Shaft shaft;

  /// Draws the radius that goes into the formula, once the round is answered.
  final bool markC;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) * 0.33;
    final mid = Offset(size.width / 2, size.height * 0.46);

    canvas.drawCircle(mid, r, Paint()..color = AppColors.sunbeamBg);
    canvas.drawCircle(
      mid,
      r,
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    if (shaft.hollow) {
      final inner = r * shaft.innerD / shaft.outerD;
      canvas.drawCircle(mid, inner, Paint()..color = AppColors.cream);
      canvas.drawCircle(
        mid,
        inner,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
      _across(canvas, mid, inner, 'inner ${shaft.innerD.round()}',
          AppColors.ink3, size, below: true);
    }
    _across(canvas, mid, r, 'outer ${shaft.outerD.round()}',
        AppColors.charcoal, size);

    if (markC) {
      // The radius, drawn as the thing it is, because half this lesson's
      // wrong answers are a diameter used where a radius belongs.
      final tip = mid + Offset(r * 0.707, -r * 0.707);
      canvas.drawLine(
        mid,
        tip,
        Paint()
          ..color = AppColors.forest
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(mid, 3, Paint()..color = AppColors.forest);
      _write(canvas, 'c = ${shaft.c.round()}',
          mid + Offset(r * 0.36, -r * 0.55), AppColors.forest, size);
    }
  }

  /// A diameter drawn across the circle with its value on it.
  void _across(Canvas canvas, Offset mid, double r, String label, Color color,
      Size size, {bool below = false}) {
    final y = mid.dy + (below ? 0 : 0);
    final from = Offset(mid.dx - r, y);
    final to = Offset(mid.dx + r, y);
    final ink = Paint()
      ..color = color
      ..strokeWidth = 1.4;
    canvas.drawLine(from, to, ink);
    for (final (tip, way) in [(from, 1.0), (to, -1.0)]) {
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + way * 8, tip.dy - 3.4)
          ..lineTo(tip.dx + way * 8, tip.dy + 3.4)
          ..close(),
        Paint()..color = color,
      );
    }
    _write(canvas, label, Offset(mid.dx, y + (below ? 4 : -17)), color, size);
  }

  void _write(Canvas canvas, String text, Offset at, Color color, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - tp.width / 2;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    canvas.drawRect(
      Rect.fromLTWH(x - 3, at.dy, tp.width + 6, tp.height),
      Paint()..color = AppColors.cream.withValues(alpha: 0.94),
    );
    tp.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(ShaftPainter old) =>
      old.shaft != shaft || old.markC != markC;
}

/// The shape of a thin-walled tube in cross-section.
enum TubeShape { round, square, oblong }

/// Which region of a tube a panel has shaded.
enum Region {
  /// The metal itself, which is what the word "area" usually means and is
  /// NOT what this formula wants.
  material,

  /// Everything inside the outer surface.
  outer,

  /// Everything inside the middle of the wall, which is the one the formula
  /// calls A sub m.
  median,

  /// Everything inside the bore.
  inner,
}

/// A thin-walled tube, given by its outside size and its wall.
@immutable
class Tube {
  const Tube({
    required this.shape,
    required this.width,
    required this.height,
    required this.wall,
  });

  final TubeShape shape;

  /// Outside dimensions, in millimeters. A round tube uses width as its
  /// outside diameter.
  final double width;
  final double height;

  final double wall;

  /// The area the formula wants: enclosed by the middle of the wall.
  double get medianArea => switch (shape) {
        TubeShape.round => math.pi * math.pow((width - wall) / 2, 2).toDouble(),
        _ => (width - wall) * (height - wall),
      };

  /// The area of the metal, which is what people reach for instead.
  double get materialArea => switch (shape) {
        TubeShape.round => math.pi *
            (math.pow(width / 2, 2) - math.pow(width / 2 - wall, 2))
                .toDouble(),
        _ => width * height - (width - 2 * wall) * (height - 2 * wall),
      };

  /// Thin enough for the thin-walled formula to be worth using.
  bool get thin => wall < 0.1 * width / 2;
}

/// One tube with one region shaded, for choosing between.
class TubePainter extends CustomPainter {
  const TubePainter({
    required this.tube,
    required this.region,
    this.tone = AppColors.info,
  });

  final Tube tube;
  final Region region;
  final Color tone;

  /// One scale for the whole panel, so the three panels of a row measure the
  /// same tube the same way. Public because the test measures with it rather
  /// than assuming what the painter did.
  static double scaleFor(Tube tube, Size size) => math.min(
        (size.width - 22) / tube.width,
        (size.height - 22) / tube.height,
      );

  /// The wall AS DRAWN, which is not always the wall as measured.
  ///
  /// A genuinely thin wall is a pixel or two at this size, and then the three
  /// candidate outlines land on top of one another and the question cannot be
  /// answered by looking, which is the opposite of the point. So the wall is
  /// opened up to a floor and the panel says so underneath. Nothing else
  /// moves: the shape, the outside size and which line bounds which region are
  /// all exactly as they were, and the areas were never read off the drawing.
  static double drawnWall(Tube tube, Size size) {
    final scale = scaleFor(tube, size);
    final floor = _wallFloor / scale;
    return math.max(tube.wall, floor);
  }

  /// In logical pixels. Enough that the median line has daylight on both sides
  /// of it at the size these panels are drawn.
  static const _wallFloor = 13.0;

  /// The outline a given distance in from the outside face: zero is the
  /// outside, half the wall is the median line, a full wall is the bore.
  static Path outlineAt(Tube tube, Size size, double inset) {
    final scale = scaleFor(tube, size);
    final mid = Offset(size.width / 2, size.height / 2);
    if (tube.shape == TubeShape.round) {
      final r = (tube.width / 2 - inset) * scale;
      return Path()..addOval(Rect.fromCircle(center: mid, radius: r));
    }
    return Path()
      ..addRect(Rect.fromCenter(
        center: mid,
        width: (tube.width - 2 * inset) * scale,
        height: (tube.height - 2 * inset) * scale,
      ));
  }

  Path _at(Size size, double inset) => outlineAt(tube, size, inset);

  @override
  void paint(Canvas canvas, Size size) {
    final wall = drawnWall(tube, size);
    final outer = _at(size, 0);
    final inner = _at(size, wall);
    final median = _at(size, wall / 2);

    // The region this panel is offering.
    final shaded = switch (region) {
      Region.material =>
        Path.combine(PathOperation.difference, outer, inner),
      Region.outer => outer,
      Region.median => median,
      Region.inner => inner,
    };
    canvas.drawPath(shaded, Paint()..color = tone.withValues(alpha: 0.30));

    // The tube itself, always drawn the same, so only the shading differs.
    for (final p in [outer, inner]) {
      canvas.drawPath(
        p,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }
    // The middle of the wall, dashed, because it is the line the formula is
    // named after and it is invisible otherwise.
    _dash(canvas, median);

    canvas.drawPath(
      shaded,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
  }

  void _dash(Canvas canvas, Path path) {
    final paint = Paint()
      ..color = AppColors.ink3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 8) {
        canvas.drawPath(m.extractPath(d, math.min(d + 4, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(TubePainter old) =>
      old.tube != tube || old.region != region || old.tone != tone;
}
