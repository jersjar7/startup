import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A soil's shear strength, described the way the Mohr-Coulomb criterion
/// describes it: a constant part and a part that grows with how hard the
/// grains are pressed together.
@immutable
class Failure {
  const Failure({required this.cohesion, required this.friction});

  /// Pounds per square foot, and zero for a clean sand.
  final double cohesion;

  /// Degrees, and zero for a saturated clay loaded quickly.
  final double friction;

  double get radians => friction * math.pi / 180;

  /// What the soil can carry on a plane pressed by this much normal stress.
  double strengthAt(double normal) =>
      cohesion + normal * math.tan(radians);

  bool get sand => cohesion < 0.001;
  bool get undrained => friction < 0.001;
}

/// One triaxial test taken to failure.
@immutable
class Triaxial {
  const Triaxial({required this.cell, required this.deviator});

  /// The all-round pressure in the cell, and the extra squeeze added on top
  /// of it, both in pounds per square foot.
  final double cell;
  final double deviator;

  double get minor => cell;
  double get major => cell + deviator;

  /// The middle of the Mohr circle and its radius.
  double get center => (major + minor) / 2;
  double get radius => (major - minor) / 2;

  /// For a soil with no cohesion the envelope passes through the origin, so
  /// the SINE of the friction angle is the radius over the center distance.
  double get sinPhi => radius / center;
  double get phi => math.asin(sinPhi) * 180 / math.pi;

  /// For a saturated clay loaded quickly, the strength is the radius.
  double get undrainedStrength => radius;
}

/// The failure envelope on the normal stress and shear axes, with a test
/// circle under it when the round has one. This is the drawing the whole
/// lesson is written against.
class EnvelopePainter extends CustomPainter {
  const EnvelopePainter({
    required this.failure,
    this.test,
    this.markAt,
    this.reveal = true,
    this.answered = false,
  });

  final Failure failure;

  /// A test taken to failure, drawn as a circle touching the envelope.
  final Triaxial? test;

  /// A normal stress to call out on the envelope.
  final double? markAt;

  /// Whether to draw the envelope at all. An item that asks WHICH envelope
  /// applies has to keep it back until the round is over, or the drawing
  /// answers the question.
  final bool reveal;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 40.0;
    final right = size.width - 20;
    // Two rows of writing go under the axis: the stress values on the
    // circle, then what the axis is. At 28 they were written on the same
    // line and read as one run-on word.
    final bottom = size.height - 38;
    final top = 22.0;

    final widest = math.max(
      test?.major ?? 0,
      math.max(markAt ?? 0, 2000),
    ) * 1.25;
    final tallest = math.max(
      failure.strengthAt(widest),
      math.max(test?.radius ?? 0, 1200),
    ) * 1.15;

    double xOf(double s) => left + s / widest * (right - left);
    double yOf(double t) => bottom - t / tallest * (bottom - top);

    canvas
      ..drawLine(
          Offset(left, top),
          Offset(left, bottom),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1.2)
      ..drawLine(
          Offset(left, bottom),
          Offset(right, bottom),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1.2);
    writeOn(canvas, size, 'shear', Offset(4, top - 14), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, 'normal stress on the plane',
        Offset(left + 6, bottom + 22), AppColors.ink3, fontSize: 9.5);

    if (!reveal) {
      writeOn(canvas, size, 'which envelope applies is the question',
          Offset(left + 8, (top + bottom) / 2), AppColors.ink3,
          fontSize: 9.5);
      return;
    }

    // The envelope.
    canvas.drawLine(
        Offset(xOf(0), yOf(failure.cohesion)),
        Offset(xOf(widest), yOf(failure.strengthAt(widest))),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2.4);

    // The cohesion intercept, which is what the line is worth before
    // anything presses on it at all.
    if (!failure.sand) {
      canvas.drawLine(
          Offset(xOf(0), yOf(0)),
          Offset(xOf(0), yOf(failure.cohesion)),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 3);
      writeOn(canvas, size, 'cohesion', Offset(left + 4, yOf(failure.cohesion) - 14),
          AppColors.ember, fontSize: 9.5);
    }

    // A test circle, touching the envelope where the soil gave way.
    final t = test;
    if (t != null) {
      // A semicircle, not a circle. The lower half is the mirror of the
      // upper one and carries nothing, which is why Mohr-Coulomb diagrams
      // are drawn this way; drawn full, it hung below the panel and was cut
      // off by the edge of the figure anyway.
      final radius = (xOf(t.radius) - xOf(0)).abs();
      canvas.drawArc(
          Rect.fromCircle(center: Offset(xOf(t.center), yOf(0)), radius: radius),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = AppColors.info
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8);
      for (final (v, name) in [
        (t.minor, 'cell'),
        (t.major, 'at failure'),
      ]) {
        canvas.drawLine(
            Offset(xOf(v), yOf(0) - 4),
            Offset(xOf(v), yOf(0) + 4),
            Paint()
              ..color = AppColors.info
              ..strokeWidth = 2);
        writeOn(canvas, size, '$name ${v.toStringAsFixed(0)}',
            Offset(xOf(v) - 20, bottom + 6), AppColors.info, fontSize: 9.5);
      }
    }

    // A normal stress called out on the envelope.
    final at = markAt;
    if (at != null) {
      final y = yOf(failure.strengthAt(at));
      canvas
        ..drawLine(
            Offset(xOf(at), yOf(0)),
            Offset(xOf(at), y),
            Paint()
              ..color = AppColors.info
              ..strokeWidth = 1.4)
        ..drawCircle(Offset(xOf(at), y), 3.6, Paint()..color = AppColors.info);
      writeOn(canvas, size, 'pressed by ${at.toStringAsFixed(0)}',
          Offset(xOf(at) - 30, bottom + 8), AppColors.info, fontSize: 9.5);
    }

    if (answered) {
      writeOn(
          canvas,
          size,
          failure.undrained
              ? 'flat: no friction to call on'
              : 'slope: ${failure.friction.toStringAsFixed(0)} degrees',
          Offset(right - 120, top),
          AppColors.forest,
          fontSize: 9.5);
    }
  }

  @override
  bool shouldRepaint(EnvelopePainter old) =>
      old.failure != failure ||
      old.test != test ||
      old.markAt != markAt ||
      old.reveal != reveal ||
      old.answered != answered;
}
