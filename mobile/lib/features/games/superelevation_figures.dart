import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A vehicle going round a curve, and the two things that keep it there:
/// the tilt of the pavement and the sideways grip of the tires.
@immutable
class Superelevation {
  const Superelevation({
    required this.speed,
    required this.radius,
    required this.friction,
  });

  /// Miles per hour, feet, and the side friction factor.
  final double speed;
  final double radius;
  final double friction;

  /// What the curve asks for altogether, as a decimal. The 15 carries the
  /// units: miles per hour and feet in, a plain number out.
  double get demand => speed * speed / (15 * radius);

  /// What is left for the pavement to supply once the tires have done what
  /// they can, as a decimal and then as a per cent.
  double get fromTilt => demand - friction;
  double get ratePerCent => fromTilt * 100;

  /// Whether the tires could hold it on a flat road.
  bool get flatWouldDo => demand <= friction;

  /// The lesson's own wrong answers, kept here so a round cannot invent
  /// one the numbers do not give.
  double get forgettingFriction => demand * 100;
  double get leavingItDecimal => fromTilt;
}

/// The road in section, tilted, with a bar underneath that splits what the
/// curve asks for into the part the tires hold and the part the tilt holds.
/// That split is the question, so the bar is empty until the answer is in.
class SuperPainter extends CustomPainter {
  const SuperPainter({
    required this.curve,
    this.answered = false,
  });

  final Superelevation curve;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 40.0;
    final right = size.width - 36;
    final road = size.height * 0.34;

    // The pavement, tilted toward the inside of the curve. The tilt is
    // drawn far steeper than any real road, so that it can be seen at all.
    final drop = curve.flatWouldDo
        ? 0.0
        : math.min(curve.ratePerCent * 2.4, 34.0);
    final outer = Offset(right, road - drop / 2);
    final inner = Offset(left, road + drop / 2);
    canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 3);
    writeOn(canvas, size, 'inside of the curve', Offset(left - 8, road + 22),
        AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'outside', Offset(right - 42, road - 30),
        AppColors.ink3, fontSize: 9.5);

    // The car, sitting on the tilt.
    final at = Offset((left + right) / 2, road);
    canvas.save();
    canvas
      ..translate(at.dx, at.dy)
      ..rotate(math.atan2(outer.dy - inner.dy, outer.dx - inner.dx))
      ..drawRect(const Rect.fromLTWH(-14, -11, 28, 10),
          Paint()..color = AppColors.charcoal.withValues(alpha: 0.8))
      ..restore();

    writeOn(
        canvas,
        size,
        '${curve.speed.toStringAsFixed(0)} mph round '
            '${curve.radius.toStringAsFixed(0)} ft',
        Offset(left - 8, 8),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'tires can hold ${curve.friction.toStringAsFixed(2)} of it',
        Offset(left - 8, 22),
        AppColors.ink3,
        fontSize: 9.5);

    // The bar: what the curve asks for, and who supplies it.
    final barTop = size.height - 58;
    final barLeft = left - 8;
    final barRight = right + 10;
    final bar = Rect.fromLTRB(barLeft, barTop, barRight, barTop + 16);
    if (!answered) {
      canvas.drawRect(
          bar,
          Paint()
            ..color = AppColors.line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
      writeOn(canvas, size, 'what the curve asks for, and who supplies it,',
          Offset(barLeft, barTop + 22), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'comes out after the answer',
          Offset(barLeft, barTop + 36), AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.section, note: 'the pavement');
      return;
    }

    final share = curve.demand <= 0
        ? 0.0
        : (curve.friction / curve.demand).clamp(0.0, 1.0);
    final split = barLeft + (barRight - barLeft) * share;
    canvas
      ..drawRect(Rect.fromLTRB(barLeft, barTop, split, barTop + 16),
          Paint()..color = AppColors.info.withValues(alpha: 0.45))
      ..drawRect(Rect.fromLTRB(split, barTop, barRight, barTop + 16),
          Paint()..color = AppColors.ember.withValues(alpha: 0.5))
      ..drawRect(
          bar,
          Paint()
            ..color = AppColors.ink3
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    writeOn(
        canvas,
        size,
        'the curve asks for ${curve.demand.toStringAsFixed(3)}',
        Offset(barLeft, barTop - 14),
        AppColors.charcoal,
        fontSize: 9.5);
    writeOn(canvas, size, 'tires ${curve.friction.toStringAsFixed(2)}',
        Offset(barLeft + 4, barTop + 22), AppColors.info, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        curve.flatWouldDo
            ? 'the tires alone could hold it'
            : 'the tilt, ${curve.ratePerCent.toStringAsFixed(1)} per cent',
        Offset(curve.flatWouldDo ? barLeft + 90 : split + 4, barTop + 22),
        curve.flatWouldDo ? AppColors.info : AppColors.ember,
        fontSize: 9.5);

    viewTag(canvas, size, Looking.section, note: 'the pavement');
  }

  @override
  bool shouldRepaint(SuperPainter old) =>
      old.curve != curve || old.answered != answered;
}
