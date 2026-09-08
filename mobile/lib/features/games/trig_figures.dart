import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Which side of a right triangle, named relative to the marked angle. The
/// whole lesson turns on the fact that these names move when the angle moves,
/// so nothing here is tied to up, down, left or right.
enum TriSide { opposite, adjacent, hypotenuse }

extension TriSideName on TriSide {
  String get label => switch (this) {
    TriSide.opposite => 'Opposite',
    TriSide.adjacent => 'Adjacent',
    TriSide.hypotenuse => 'Hypotenuse',
  };
}

/// The three ratios, as the lesson prints them.
enum TriRatio { sin, cos, tan }

extension TriRatioName on TriRatio {
  String get label => switch (this) {
    TriRatio.sin => 'sin',
    TriRatio.cos => 'cos',
    TriRatio.tan => 'tan',
  };

  String get latex => switch (this) {
    TriRatio.sin => r'\sin\theta = \frac{\text{opp}}{\text{hyp}}',
    TriRatio.cos => r'\cos\theta = \frac{\text{adj}}{\text{hyp}}',
    TriRatio.tan => r'\tan\theta = \frac{\text{opp}}{\text{adj}}',
  };

  /// The two sides this ratio connects.
  Set<TriSide> get sides => switch (this) {
    TriRatio.sin => {TriSide.opposite, TriSide.hypotenuse},
    TriRatio.cos => {TriSide.adjacent, TriSide.hypotenuse},
    TriRatio.tan => {TriSide.opposite, TriSide.adjacent},
  };
}

/// Where the triangle sits and which corner carries the marked angle.
///
/// The right angle is always the square corner; the marked angle is one of the
/// other two. Flipping [angleAtTop] swaps which physical side is opposite and
/// which is adjacent without moving a single line, which is the point.
@immutable
class TriangleGeometry {
  const TriangleGeometry(
    this.size, {
    this.angleAtTop = false,
    this.mirror = false,
  });

  final Size size;
  final bool angleAtTop;
  final bool mirror;

  double get _left => size.width * 0.14;
  double get _right => size.width * 0.86;
  double get _top => size.height * 0.16;
  double get _bottom => size.height * 0.84;

  /// The right-angle corner.
  Offset get square =>
      mirror ? Offset(_left, _bottom) : Offset(_right, _bottom);

  /// The far corner along the horizontal leg.
  Offset get flat => mirror ? Offset(_right, _bottom) : Offset(_left, _bottom);

  /// The corner above the right angle.
  Offset get peak => mirror ? Offset(_left, _top) : Offset(_right, _top);

  /// The corner carrying the marked angle.
  Offset get marked => angleAtTop ? peak : flat;

  /// The other non-right corner.
  Offset get other => angleAtTop ? flat : peak;

  (Offset, Offset) endsOf(TriSide side) {
    // The vertical leg runs square -> peak; the horizontal leg square -> flat.
    final vertical = (square, peak);
    final horizontal = (square, flat);
    final hyp = (flat, peak);
    return switch (side) {
      TriSide.hypotenuse => hyp,
      TriSide.opposite => angleAtTop ? horizontal : vertical,
      TriSide.adjacent => angleAtTop ? vertical : horizontal,
    };
  }

  Offset midOf(TriSide side) {
    final (a, b) = endsOf(side);
    return (a + b) / 2;
  }

  /// Which side a tap landed on, or null if it landed on none of them. The
  /// tolerance is generous on purpose: a fat thumb must not have to be precise.
  TriSide? hitTest(Offset p, {double tolerance = 26}) {
    TriSide? best;
    var bestDistance = tolerance;
    for (final side in TriSide.values) {
      final (a, b) = endsOf(side);
      final d = _distanceToSegment(p, a, b);
      if (d < bestDistance) {
        bestDistance = d;
        best = side;
      }
    }
    return best;
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final lengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lengthSquared == 0) return (p - a).distance;
    var t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / lengthSquared;
    t = t.clamp(0.0, 1.0);
    return (p - (a + ab * t)).distance;
  }
}

/// A right triangle with one angle marked, optionally with a side picked out
/// and its sides labelled.
class TrianglePainter extends CustomPainter {
  const TrianglePainter({
    required this.angleAtTop,
    required this.mirror,
    this.highlight,
    this.highlightColor = AppColors.ember,
    this.known,
    this.wanted,
    this.showNames = false,
    this.angleLabel = 'θ',
  });

  final bool angleAtTop;
  final bool mirror;

  /// A side drawn in [highlightColor], used for answers and for pointing.
  final TriSide? highlight;
  final Color highlightColor;

  /// The side whose length is given, and the side being asked for.
  final TriSide? known;
  final TriSide? wanted;

  /// Write "Opposite", "Adjacent", "Hypotenuse" beside each side.
  final bool showNames;
  final String angleLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final g = TriangleGeometry(size, angleAtTop: angleAtTop, mirror: mirror);

    final stroke = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(g.flat.dx, g.flat.dy)
        ..lineTo(g.square.dx, g.square.dy)
        ..lineTo(g.peak.dx, g.peak.dy)
        ..close(),
      stroke,
    );

    if (highlight != null) {
      final (a, b) = g.endsOf(highlight!);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = highlightColor
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
    }

    _rightAngleMark(canvas, g);
    _angleArc(canvas, g);

    if (known != null) _tag(canvas, g, known!, 'known', AppColors.charcoal);
    if (wanted != null) _tag(canvas, g, wanted!, '?', AppColors.ember);
    if (showNames) {
      for (final side in TriSide.values) {
        _tag(canvas, g, side, side.label, AppColors.ink2, small: true);
      }
    }
  }

  void _rightAngleMark(Canvas canvas, TriangleGeometry g) {
    const s = 13.0;
    final toFlat = (g.flat - g.square) / (g.flat - g.square).distance * s;
    final toPeak = (g.peak - g.square) / (g.peak - g.square).distance * s;
    canvas.drawPath(
      Path()
        ..moveTo(g.square.dx + toFlat.dx, g.square.dy + toFlat.dy)
        ..lineTo(
          g.square.dx + toFlat.dx + toPeak.dx,
          g.square.dy + toFlat.dy + toPeak.dy,
        )
        ..lineTo(g.square.dx + toPeak.dx, g.square.dy + toPeak.dy),
      Paint()
        ..color = AppColors.ink3
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke,
    );
  }

  void _angleArc(Canvas canvas, TriangleGeometry g) {
    final at = g.marked;
    final toSquare = (g.square - at) / (g.square - at).distance;
    final toOther = (g.other - at) / (g.other - at).distance;
    final start = math.atan2(toSquare.dy, toSquare.dx);
    final end = math.atan2(toOther.dy, toOther.dx);
    var sweep = end - start;
    if (sweep > math.pi) sweep -= 2 * math.pi;
    if (sweep < -math.pi) sweep += 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: at, radius: 26),
      start,
      sweep,
      false,
      Paint()
        ..color = AppColors.ember
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    final bisect = (toSquare + toOther) / 2;
    final at2 = at + bisect / bisect.distance * 40;
    _text(canvas, angleLabel, at2, AppColors.ember, 15, bold: true);
  }

  void _tag(
    Canvas canvas,
    TriangleGeometry g,
    TriSide side,
    String text,
    Color color, {
    bool small = false,
  }) {
    final mid = g.midOf(side);
    final center = Offset(g.size.width / 2, g.size.height / 2);
    final away = (mid - center);
    final at =
        mid + (away.distance == 0 ? Offset.zero : away / away.distance * 20);
    _text(canvas, text, at, color, small ? 10.5 : 13);
  }

  void _text(
    Canvas canvas,
    String text,
    Offset at,
    Color color,
    double size, {
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.heading(
          size: size,
          weight: bold ? FontWeight.w700 : FontWeight.w600,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(TrianglePainter old) =>
      old.angleAtTop != angleAtTop ||
      old.mirror != mirror ||
      old.highlight != highlight ||
      old.known != known ||
      old.wanted != wanted ||
      old.showNames != showNames;
}

/// A force arrow at an angle, with its two components drawn faintly. The angle
/// can be measured from the horizontal or from the vertical, which is exactly
/// what swaps sine and cosine on the exam.
class ForcePainter extends CustomPainter {
  const ForcePainter({
    required this.degrees,
    required this.fromVertical,
    this.highlightHorizontal,
    this.magnitude,
  });

  final double degrees;
  final bool fromVertical;

  /// Picks out one component in ember; null draws both faintly.
  final bool? highlightHorizontal;
  final String? magnitude;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.16, size.height * 0.82);
    final fromHorizontal = fromVertical ? 90 - degrees : degrees;
    final rad = fromHorizontal * math.pi / 180;
    final length = math.min(size.width * 0.62, size.height * 0.72);
    final tip = origin + Offset(math.cos(rad), -math.sin(rad)) * length;

    final axis = Paint()
      ..color = AppColors.ink3.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    canvas.drawLine(origin, Offset(size.width * 0.92, origin.dy), axis);
    canvas.drawLine(origin, Offset(origin.dx, size.height * 0.1), axis);

    // Components.
    final corner = Offset(tip.dx, origin.dy);
    void component(Offset a, Offset b, bool horizontal) {
      final on = highlightHorizontal == horizontal;
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = on
              ? AppColors.ember
              : AppColors.ink3.withValues(alpha: 0.55)
          ..strokeWidth = on ? 5 : 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    component(origin, corner, true);
    component(corner, tip, false);

    // The force itself.
    final arrow = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(origin, tip, arrow);
    final back = (origin - tip) / (origin - tip).distance;
    final left = Offset(
      back.dx * math.cos(0.4) - back.dy * math.sin(0.4),
      back.dx * math.sin(0.4) + back.dy * math.cos(0.4),
    );
    final right = Offset(
      back.dx * math.cos(-0.4) - back.dy * math.sin(-0.4),
      back.dx * math.sin(-0.4) + back.dy * math.cos(-0.4),
    );
    canvas.drawLine(tip, tip + left * 14, arrow);
    canvas.drawLine(tip, tip + right * 14, arrow);

    // The angle, swept from whichever axis it is measured from: up from the
    // horizontal, or across from the vertical.
    final degreesRad = degrees * math.pi / 180;
    canvas.drawArc(
      Rect.fromCircle(center: origin, radius: 30),
      fromVertical ? -math.pi / 2 : 0.0,
      fromVertical ? degreesRad : -degreesRad,
      false,
      Paint()
        ..color = AppColors.ember
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    final label =
        '${degrees.toStringAsFixed(0)}° from '
        '${fromVertical ? 'vertical' : 'horizontal'}';
    _text(
      canvas,
      label,
      Offset(size.width * 0.5, size.height * 0.06),
      AppColors.ink2,
      11.5,
    );
    if (magnitude != null) {
      final mid = (origin + tip) / 2;
      _text(
        canvas,
        magnitude!,
        mid + const Offset(-22, -16),
        AppColors.charcoal,
        12.5,
      );
    }
  }

  void _text(Canvas canvas, String text, Offset at, Color color, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTheme.heading(
          size: size,
          weight: FontWeight.w600,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(ForcePainter old) =>
      old.degrees != degrees ||
      old.fromVertical != fromVertical ||
      old.highlightHorizontal != highlightHorizontal;
}
