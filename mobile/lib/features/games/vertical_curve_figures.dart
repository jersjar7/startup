import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A vertical curve: a parabola laid between two grades. Everything about
/// it is worked out here, so a round cannot claim a length or an offset its
/// own grades do not give.
@immutable
class Vertical {
  const Vertical({
    required this.gradeIn,
    required this.gradeOut,
    this.length = 800,
  });

  /// Grades as per cent, entering and leaving: plus uphill, minus down.
  final double gradeIn;
  final double gradeOut;

  /// Feet.
  final double length;

  /// The algebraic difference, in per cent, and always taken as a size.
  double get breakSize => (gradeOut - gradeIn).abs();

  /// A crest tips downward through the curve. A sag tips upward.
  bool get crest => gradeOut < gradeIn;
  bool get sag => !crest;

  /// How far the curve sits from the corner where the two tangents cross,
  /// in feet. Below it on a crest, above it in a sag.
  double get offsetAtMiddle => breakSize / 100 * length / 8;

  /// Feet of curve per per cent of grade change.
  double get k => breakSize == 0 ? 0 : length / breakSize;

  /// Height of the curve above the entering tangent, x feet along.
  double offsetAt(double x) =>
      (gradeOut - gradeIn) / 100 / (2 * length) * x * x;
}

/// What a curve is being asked to do: let a driver see over a hill, or let
/// headlights reach far enough into a dip.
@immutable
class Criterion {
  const Criterion({
    required this.breakSize,
    required this.sight,
    required this.sag,
  });

  /// Per cent, feet.
  final double breakSize;
  final double sight;

  /// Sag curves are set by headlights, crests by the driver's eye.
  final bool sag;

  /// Assuming the sight distance fits inside the curve, which is where a
  /// problem always starts.
  double get lengthShortSight => sag
      ? breakSize * sight * sight / (400 + 3.5 * sight)
      : breakSize * sight * sight / 2158;

  /// And the other case, for when it does not.
  double get lengthLongSight => sag
      ? 2 * sight - (400 + 3.5 * sight) / breakSize
      : 2 * sight - 2158 / breakSize;

  /// The assumption holds when the length it produces is at least the sight
  /// distance.
  bool get fitsInside => lengthShortSight >= sight;

  double get length => fitsInside ? lengthShortSight : lengthLongSight;

  /// What the same numbers would give under the other criterion, which is
  /// the lesson's own wrong answer.
  double get underTheOtherOne => sag
      ? breakSize * sight * sight / 2158
      : breakSize * sight * sight / (400 + 3.5 * sight);
}

/// The curve in profile: two tangents crossing at a corner, and the
/// parabola easing between them. The offset at the middle is a question in
/// one item, so it is drawn only once the round is answered.
class VerticalCurvePainter extends CustomPainter {
  const VerticalCurvePainter({
    required this.curve,
    this.answered = false,
  });

  final Vertical curve;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 30.0;
    final right = size.width - 24;
    final run = (right - left) / 2;

    final startRise = -curve.gradeIn / 100 * (curve.length / 2);
    const cornerRise = 0.0;
    final endRise = curve.gradeOut / 100 * (curve.length / 2);

    // Fit whatever the grades do into the panel: a profile is always
    // stretched vertically, and by however much this one needs.
    final lo = math.min(math.min(startRise, endRise), cornerRise);
    final hi = math.max(math.max(startRise, endRise), cornerRise);
    final bandTop = 34.0;
    final bandBottom = size.height - 40;
    final scale = (hi - lo) < 0.001 ? 1.0 : (bandBottom - bandTop) / (hi - lo);
    double yOf(double rise) => bandBottom - (rise - lo) * scale;

    final start = Offset(left, yOf(startRise));
    final corner = Offset(left + run, yOf(cornerRise));
    final end = Offset(right, yOf(endRise));

    // The two tangents, drawn thin, and the corner they cross at.
    final thin = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(start, corner, thin)
      ..drawLine(corner, end, thin)
      ..drawCircle(corner, 3, Paint()..color = AppColors.ink3);
    // The label goes above the corner where there is room for it, and
    // below when the corner is already near the top of the panel.
    final cornerLabelY =
        curve.crest && corner.dy - 22 < 26 ? corner.dy + 10 : corner.dy - 22;
    writeOn(canvas, size, 'the grades cross here',
        Offset(corner.dx - 50, curve.crest ? cornerLabelY : corner.dy + 10),
        AppColors.ink3, fontSize: 9.5);

    // The curve itself.
    final path = Path();
    for (var i = 0; i <= 60; i++) {
      final x = curve.length * i / 60;
      final rise = startRise + curve.gradeIn / 100 * x + curve.offsetAt(x);
      final p = Offset(left + (right - left) * i / 60, yOf(rise));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4);

    String per(double g) =>
        '${g > 0 ? '+' : ''}${g.toStringAsFixed(0)} per cent';
    writeOn(canvas, size, per(curve.gradeIn),
        Offset(left, start.dy + (curve.crest ? 6 : -16)), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, per(curve.gradeOut),
        Offset(right - 60, end.dy + (curve.crest ? -16 : 6)), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, '${curve.length.toStringAsFixed(0)} ft of curve',
        Offset(left, size.height - 16), AppColors.ink3, fontSize: 9.5);

    if (answered) {
      final middleRise = startRise +
          curve.gradeIn / 100 * (curve.length / 2) +
          curve.offsetAt(curve.length / 2);
      final onCurve = Offset(corner.dx, yOf(middleRise));
      canvas.drawLine(
          corner,
          onCurve,
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 2);
      writeOn(
          canvas,
          size,
          '${curve.offsetAtMiddle.toStringAsFixed(1)} ft '
              '${curve.crest ? 'below' : 'above'}',
          Offset(corner.dx + 8, (corner.dy + onCurve.dy) / 2 - 6),
          AppColors.ember,
          fontSize: 9.5);
      writeOn(
          canvas,
          size,
          'a ${curve.crest ? 'crest' : 'sag'}, '
              '${curve.breakSize.toStringAsFixed(0)} per cent of break',
          Offset(left, 8),
          AppColors.charcoal,
          fontSize: 9.5);
    } else {
      writeOn(canvas, size, 'the rest comes out after the answer',
          Offset(left, 8), AppColors.ink3, fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.elevation, note: 'the road');
  }

  @override
  bool shouldRepaint(VerticalCurvePainter old) =>
      old.curve != curve || old.answered != answered;
}

/// What the curve has to allow for: an eye seeing over a crest, or a
/// headlight beam reaching into a sag. Which criterion applies is the
/// question, so the beam or the sight line is drawn from the start but the
/// lengths it produces wait for the answer.
class CriterionPainter extends CustomPainter {
  const CriterionPainter({
    required this.criterion,
    this.answered = false,
  });

  final Criterion criterion;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 26.0;
    final right = size.width - 20;
    final mid = (left + right) / 2;
    final road = size.height * 0.56;
    final bulge = criterion.sag ? 26.0 : -26.0;

    // The road, humped or dipped.
    final path = Path()..moveTo(left, road);
    for (var i = 1; i <= 40; i++) {
      final t = i / 40;
      final x = left + (right - left) * t;
      final y = road + bulge * (1 - 4 * math.pow(t - 0.5, 2).toDouble());
      path.lineTo(x, y);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4);

    // The car, at the left hand end of the curve.
    final carX = left + 28;
    final carY = road + bulge * (1 - 4 * math.pow((carX - left) /
        (right - left) - 0.5, 2).toDouble());
    canvas.drawRect(Rect.fromLTWH(carX - 8, carY - 12, 18, 9),
        Paint()..color = AppColors.charcoal.withValues(alpha: 0.8));

    if (criterion.sag) {
      // A headlight beam, tipped one degree up, running into the dip.
      final beam = Path()
        ..moveTo(carX + 10, carY - 8)
        ..lineTo(right - 18, carY - 26)
        ..lineTo(right - 18, carY - 4)
        ..close();
      canvas.drawPath(
          beam, Paint()..color = AppColors.sunbeam.withValues(alpha: 0.30));
      writeOn(canvas, size, 'headlights, tipped a degree up',
          Offset(carX + 14, carY - 40), AppColors.charcoal, fontSize: 9.5);
      writeOn(canvas, size, 'the beam has to reach as far as the driver '
          'needs to stop', Offset(left, size.height - 30), AppColors.ink3,
          fontSize: 9.5);
    } else {
      // An eye at 3.5 ft seeing an object at 2 ft over the hump.
      final eye = Offset(carX + 4, carY - 16);
      final object = Offset(right - 30, road - 6);
      canvas
        ..drawLine(
            eye,
            object,
            Paint()
              ..color = AppColors.info
              ..strokeWidth = 1.6)
        ..drawRect(Rect.fromLTWH(object.dx - 3, object.dy, 6, 8),
            Paint()..color = AppColors.error.withValues(alpha: 0.8));
      writeOn(canvas, size, 'the driver\'s eye', Offset(carX - 4, eye.dy - 14),
          AppColors.info, fontSize: 9.5);
      writeOn(canvas, size, 'the sight line just grazes the hill',
          Offset(left, size.height - 30), AppColors.ink3, fontSize: 9.5);
    }

    if (!answered) {
      writeOn(canvas, size, 'the length it needs comes out after the answer',
          Offset(left, 8), AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.elevation, note: 'the road');
      return;
    }

    writeOn(
        canvas,
        size,
        '${criterion.breakSize.toStringAsFixed(0)} per cent of break, '
            '${criterion.sight.toStringAsFixed(0)} ft to see',
        Offset(left, 8),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'needs ${criterion.length.toStringAsFixed(0)} ft of curve',
        Offset(mid - 60, 24),
        AppColors.forest,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'the other rule would say '
            '${criterion.underTheOtherOne.toStringAsFixed(0)} ft',
        Offset(mid - 60, 40),
        AppColors.error,
        fontSize: 9.5);

    viewTag(canvas, size, Looking.elevation, note: 'the road');
  }

  @override
  bool shouldRepaint(CriterionPainter old) =>
      old.criterion != criterion || old.answered != answered;
}
