import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A long slope of cohesionless soil, dry or with water seeping down it.
@immutable
class Bank {
  const Bank({
    required this.slopeAngle,
    required this.friction,
    this.seeping = false,
    this.saturatedWeight = 19.62,
    this.waterWeight = 9.81,
  });

  /// Degrees.
  final double slopeAngle;
  final double friction;

  /// Steady seepage running parallel to the face, which is what prolonged
  /// rain eventually produces.
  final bool seeping;

  /// Kilonewtons per cubic meter.
  final double saturatedWeight;
  final double waterWeight;

  double get buoyantWeight => saturatedWeight - waterWeight;

  /// What buoyancy leaves of the factor of safety: about a half.
  double get seepageFactor =>
      seeping ? buoyantWeight / saturatedWeight : 1;

  double get dryFactor =>
      math.tan(friction * math.pi / 180) /
      math.tan(slopeAngle * math.pi / 180);

  double get factorOfSafety => seepageFactor * dryFactor;

  bool get stands => factorOfSafety > 1;
}

/// The slope in section, with its angle marked against the friction angle
/// the soil can muster, and rain and seepage drawn when the round has them.
class BankPainter extends CustomPainter {
  const BankPainter({required this.bank, this.answered = false});

  final Bank bank;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 20.0;
    final right = size.width - 20;
    final base = size.height - 38;
    final rise = (right - left) * math.tan(bank.slopeAngle * math.pi / 180);
    final top = math.max(base - rise, 26.0);

    // The ground: flat on the left, rising to the right.
    final face = Path()
      ..moveTo(left, base)
      ..lineTo(right, top)
      ..lineTo(right, base)
      ..close();
    canvas.drawPath(
        face, Paint()..color = AppColors.ink2.withValues(alpha: 0.22));
    canvas.drawLine(
        Offset(left, base),
        Offset(right, top),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2.4);
    groundLine(canvas, Offset(left, base), Offset(right, base));

    // The slope angle, drawn where the face meets the flat.
    canvas.drawArc(
      Rect.fromCircle(center: Offset(left, base), radius: 34),
      -bank.slopeAngle * math.pi / 180,
      bank.slopeAngle * math.pi / 180,
      false,
      Paint()
        ..color = AppColors.ember
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    // The two angles, clear of the arc and of each other.
    writeOn(
        canvas,
        size,
        'slope ${bank.slopeAngle.toStringAsFixed(0)} degrees',
        Offset(left + 46, base - 26),
        AppColors.ember,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'the soil can muster ${bank.friction.toStringAsFixed(0)} degrees',
        Offset(left + 46, base - 12),
        AppColors.ink3,
        fontSize: 9.5);

    if (bank.seeping) {
      // Rain on the face and water running down inside it.
      for (var i = 0; i < 5; i++) {
        final t = 0.18 + i * 0.16;
        final x = left + (right - left) * t;
        final y = base - rise * t;
        canvas
          ..drawLine(
              Offset(x, y - 26),
              Offset(x, y - 8),
              Paint()
                ..color = AppColors.info
                ..strokeWidth = 1.4)
          ..drawLine(
              Offset(x - 10, y + 14),
              Offset(x + 12, y + 14 - 22 * math.tan(bank.slopeAngle * math.pi / 180)),
              Paint()
                ..color = AppColors.info
                ..strokeWidth = 1.6);
      }
      writeOn(canvas, size, 'rain, and seepage down the slope',
          Offset(left + 4, top - 18), AppColors.info, fontSize: 9.5);
    }

    if (answered) {
      writeOn(
          canvas,
          size,
          bank.stands
              ? 'it stands: ${bank.factorOfSafety.toStringAsFixed(2)}'
              : 'it slides: ${bank.factorOfSafety.toStringAsFixed(2)}',
          Offset(right - 120, base + 8),
          bank.stands ? AppColors.forest : AppColors.error,
          fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'the slope');
  }

  @override
  bool shouldRepaint(BankPainter old) =>
      old.bank != bank || old.answered != answered;
}

/// A wedge of soil sitting on a planar slip surface, with the three things
/// that decide whether it stays where it is.
@immutable
class Wedge2 {
  const Wedge2({
    required this.cohesionForce,
    required this.weight,
    required this.slipAngle,
    required this.friction,
  });

  /// The cohesion along the slip surface, already multiplied by its length,
  /// in kilonewtons per meter of width.
  final double cohesionForce;

  /// The weight of the wedge, same units.
  final double weight;

  /// Degrees.
  final double slipAngle;
  final double friction;

  double get _slip => slipAngle * math.pi / 180;
  double get _phi => friction * math.pi / 180;

  /// The part of the weight pressing the wedge onto the surface, and the
  /// part trying to slide it down.
  double get normal => weight * math.cos(_slip);
  double get driving => weight * math.sin(_slip);

  double get frictionForce => normal * math.tan(_phi);
  double get resisting => cohesionForce + frictionForce;

  double get factorOfSafety => resisting / driving;
}

/// The wedge, its weight broken into the part that drives it and the part
/// that holds it on, with the cohesion along the surface underneath.
class WedgePainter extends CustomPainter {
  const WedgePainter({required this.wedge, this.answered = false});

  final Wedge2 wedge;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 30.0;
    final right = size.width - 40;
    final base = size.height - 40;
    final rise = (right - left) * math.tan(wedge.slipAngle * math.pi / 180);
    final top = math.max(base - rise, 34.0);

    // The slip surface and the wedge sitting on it.
    final block = Path()
      ..moveTo(left, base)
      ..lineTo(right, top)
      ..lineTo(right, top - 34)
      ..lineTo(left + 14, base - 34)
      ..close();
    canvas
      ..drawPath(block, Paint()..color = AppColors.ink2.withValues(alpha: 0.25))
      ..drawPath(
          block,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6)
      ..drawLine(
          Offset(left - 6, base + 4),
          Offset(right + 6, top + 4),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2.6);
    writeOn(canvas, size, 'the slip surface', Offset(left + 6, base + 10),
        AppColors.ink3, fontSize: 9.5);

    // The weight, and where it goes.
    final centre = Offset((left + right) / 2 + 6, (base + top) / 2 - 16);
    canvas
      ..drawLine(
          centre,
          centre + const Offset(0, 30),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2.4)
      ..drawPath(
          Path()
            ..moveTo(centre.dx, centre.dy + 36)
            ..lineTo(centre.dx - 4, centre.dy + 28)
            ..lineTo(centre.dx + 4, centre.dy + 28)
            ..close(),
          Paint()..color = AppColors.charcoal);
    writeOn(canvas, size, 'weight ${wedge.weight.toStringAsFixed(0)}',
        centre + const Offset(6, 8), AppColors.charcoal, fontSize: 9.5);

    writeOn(
        canvas,
        size,
        'slip at ${wedge.slipAngle.toStringAsFixed(0)} degrees, '
            'friction ${wedge.friction.toStringAsFixed(0)}',
        Offset(left, 10),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'cohesion along it: ${wedge.cohesionForce.toStringAsFixed(0)}',
        Offset(left, 24),
        AppColors.ember,
        fontSize: 9.5);

    if (answered) {
      writeOn(
          canvas,
          size,
          'holds ${wedge.resisting.toStringAsFixed(0)}, '
              'drives ${wedge.driving.toStringAsFixed(0)}',
          Offset(left, base + 24),
          AppColors.forest,
          fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'the wedge');
  }

  @override
  bool shouldRepaint(WedgePainter old) =>
      old.wedge != wedge || old.answered != answered;
}
