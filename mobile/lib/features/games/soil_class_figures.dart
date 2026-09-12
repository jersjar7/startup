import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A coarse-grained sample described by its sieve results, with the two
/// gradation coefficients worked out rather than quoted.
@immutable
class Graded {
  const Graded({
    required this.passing200,
    required this.passing4,
    required this.d10,
    required this.d30,
    required this.d60,
  });

  /// Percent of the whole sample passing the No. 200 and No. 4 sieves.
  final double passing200;
  final double passing4;

  /// The three grain sizes the coefficients are built from, in millimeters.
  final double d10;
  final double d30;
  final double d60;

  /// More than half retained on the No. 200 makes it coarse.
  bool get coarse => passing200 < 50;

  /// Of the coarse fraction, more than half passing the No. 4 makes it a
  /// sand rather than a gravel.
  bool get sand => passing4 > 50;

  double get cu => d60 / d10;
  double get cc => d30 * d30 / (d10 * d60);

  /// A gravel needs a uniformity of 4, a sand needs 6, and both need the
  /// concavity between 1 and 3. Failing either one makes it poorly graded.
  double get uniformityNeeded => sand ? 6 : 4;
  bool get uniformEnough => cu >= uniformityNeeded;
  bool get shapedRight => cc >= 1 && cc <= 3;
  bool get wellGraded => uniformEnough && shapedRight;

  String get symbol => '${sand ? 'S' : 'G'}${wellGraded ? 'W' : 'P'}';
}

/// The grain size curve, drawn the way a sieve analysis always is: percent
/// passing up the side, grain size along the bottom with the COARSE end on
/// the left, and the size axis logarithmic because grain sizes span four
/// orders of magnitude.
class SizeCurvePainter extends CustomPainter {
  const SizeCurvePainter({required this.soil, this.answered = false});

  final Graded soil;
  final bool answered;

  static const _from = 100.0; // millimeters, coarse end
  static const _to = 0.001; // fine end

  @override
  void paint(Canvas canvas, Size size) {
    final left = 34.0;
    final right = size.width - 18;
    final top = 22.0;
    final bottom = size.height - 30;

    double xOf(double mm) {
      final t = (math.log(_from) - math.log(mm)) /
          (math.log(_from) - math.log(_to));
      return left + t * (right - left);
    }

    double yOf(double percent) => bottom - percent / 100 * (bottom - top);

    // The frame.
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
    writeOn(canvas, size, 'percent passing', Offset(2, top - 14),
        AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'coarse', Offset(left + 2, bottom + 8),
        AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'fine', Offset(right - 22, bottom + 8),
        AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'grain size, log scale',
        Offset(left + 46, bottom + 8), AppColors.ink3, fontSize: 9.5);

    // The two sieves that decide the first two forks.
    for (final (mm, name) in [(4.75, 'No 4'), (0.075, 'No 200')]) {
      final x = xOf(mm);
      for (var y = top; y < bottom; y += 8) {
        canvas.drawLine(
            Offset(x, y),
            Offset(x, math.min(y + 4, bottom)),
            Paint()
              ..color = AppColors.info
              ..strokeWidth = 1.2);
      }
      writeOn(canvas, size, name, Offset(x - 14, top - 14), AppColors.info,
          fontSize: 9.5);
    }

    // The curve itself, through the three named sizes and the two sieves.
    final points = <Offset>[
      Offset(xOf(_from), yOf(100)),
      Offset(xOf(4.75), yOf(soil.passing4)),
      Offset(xOf(soil.d60), yOf(60)),
      Offset(xOf(soil.d30), yOf(30)),
      Offset(xOf(soil.d10), yOf(10)),
      Offset(xOf(0.075), yOf(soil.passing200)),
    ]..sort((a, b) => a.dx.compareTo(b.dx));
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.ember
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4);

    // The three sizes the coefficients are built from.
    for (final (mm, percent, name) in [
      (soil.d60, 60.0, 'D60'),
      (soil.d30, 30.0, 'D30'),
      (soil.d10, 10.0, 'D10'),
    ]) {
      final at = Offset(xOf(mm), yOf(percent));
      canvas.drawCircle(at, 3.4, Paint()..color = AppColors.ember);
      writeOn(canvas, size, '$name ${_mm(mm)}', at + const Offset(6, -12),
          AppColors.ember, fontSize: 9.5);
    }
  }

  static String _mm(double v) =>
      v >= 1 ? '${v.toStringAsFixed(1)} mm' : '${v.toStringAsFixed(2)} mm';

  @override
  bool shouldRepaint(SizeCurvePainter old) =>
      old.soil != soil || old.answered != answered;
}

/// A fine-grained sample, described by the two numbers the plasticity chart
/// wants. Where it lands is worked out here so a round cannot claim a
/// classification its own numbers do not give.
@immutable
class Fines {
  const Fines({required this.liquidLimit, required this.plasticityIndex});

  final double liquidLimit;
  final double plasticityIndex;

  /// The A-line: clays plot above it, silts below.
  double get aLine => 0.73 * (liquidLimit - 20);

  bool get clay => plasticityIndex > aLine;
  bool get high => liquidLimit >= 50;

  String get symbol => '${clay ? 'C' : 'M'}${high ? 'H' : 'L'}';
}

/// The plasticity chart: liquid limit along the bottom, plasticity index up
/// the side, the A-line across it and the LL of 50 down it. The sample is
/// plotted; which quarter it lands in is the question, so the quarters are
/// only named once the round is over.
class PlasticityPainter extends CustomPainter {
  const PlasticityPainter({required this.fines, this.answered = false});

  final Fines fines;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 34.0;
    final right = size.width - 20;
    final top = 20.0;
    final bottom = size.height - 28;

    double xOf(double ll) => left + ll / 100 * (right - left);
    double yOf(double pi) => bottom - pi / 60 * (bottom - top);

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
    writeOn(canvas, size, 'plasticity index', Offset(2, top - 16),
        AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'liquid limit', Offset(left + 30, bottom + 8),
        AppColors.ink3, fontSize: 9.5);
    for (final ll in [20.0, 50.0, 100.0]) {
      writeOn(canvas, size, ll.toStringAsFixed(0),
          Offset(xOf(ll) - 6, bottom + 8), AppColors.ink3, fontSize: 9.5);
    }
    // The other axis needs a scale too, or how far the point sits off the
    // A-line cannot be read at all.
    for (final pi in [20.0, 40.0, 60.0]) {
      writeOn(canvas, size, pi.toStringAsFixed(0),
          Offset(4, yOf(pi) - 6), AppColors.ink3, fontSize: 9.5);
      canvas.drawLine(
          Offset(left - 3, yOf(pi)),
          Offset(left + 3, yOf(pi)),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1);
    }

    // The A-line, from where it leaves the axis at LL 20.
    canvas.drawLine(
        Offset(xOf(20), yOf(0)),
        Offset(xOf(100), yOf(0.73 * 80)),
        Paint()
          ..color = AppColors.info
          ..strokeWidth = 2);
    writeOn(canvas, size, 'the A-line', Offset(xOf(72), yOf(0.73 * 52) - 16),
        AppColors.info, fontSize: 9.5);

    // The high plasticity boundary.
    for (var y = top; y < bottom; y += 8) {
      canvas.drawLine(
          Offset(xOf(50), y),
          Offset(xOf(50), math.min(y + 4, bottom)),
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 1.2);
    }
    writeOn(canvas, size, 'LL 50', Offset(xOf(50) - 12, top - 14),
        AppColors.info, fontSize: 9.5);

    // How high the point sits above the A-line, or below it, drawn as a
    // short connector. Without it a sample four points off the line is a
    // blob sitting on top of the line, and which side it is on is the whole
    // question.
    final at = Offset(xOf(fines.liquidLimit), yOf(fines.plasticityIndex));
    final onLine = Offset(at.dx, yOf(fines.aLine));
    canvas.drawLine(
        at,
        onLine,
        Paint()
          ..color = AppColors.ember.withValues(alpha: 0.6)
          ..strokeWidth = 1.2);

    // The sample itself, small enough not to swallow the line it is being
    // compared with.
    canvas
      ..drawCircle(at, 3, Paint()..color = AppColors.ember)
      ..drawCircle(
          at,
          6.5,
          Paint()
            ..color = AppColors.ember
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
    writeOn(
        canvas,
        size,
        'LL ${fines.liquidLimit.toStringAsFixed(0)}, '
            'PI ${fines.plasticityIndex.toStringAsFixed(0)}',
        at + const Offset(10, -18),
        AppColors.ember,
        fontSize: 9.5);

    if (answered) {
      for (final (ll, pi, name) in [
        (32.0, 26.0, 'CL'),
        (72.0, 46.0, 'CH'),
        (33.0, 5.0, 'ML'),
        (74.0, 17.0, 'MH'),
      ]) {
        writeOn(canvas, size, name, Offset(xOf(ll), yOf(pi)), AppColors.forest,
            fontSize: 10);
      }
    }
  }

  @override
  bool shouldRepaint(PlasticityPainter old) =>
      old.fines != fines || old.answered != answered;
}
