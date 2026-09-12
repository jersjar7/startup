import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A lane of traffic under the Greenshields model: speed falls in a
/// straight line as the lane fills up, and flow, which is speed times
/// density, therefore rises and then falls.
@immutable
class Stream {
  const Stream({
    required this.freeFlow,
    required this.jamDensity,
    this.density,
  });

  /// Miles per hour at an empty road, vehicles a mile at a standstill.
  final double freeFlow;
  final double jamDensity;

  /// The density a round is asking about, when it has one.
  final double? density;

  double speedAt(double d) => freeFlow - freeFlow / jamDensity * d;

  /// How much of the free flow speed the traffic has taken away.
  double lostAt(double d) => freeFlow / jamDensity * d;

  double flowAt(double d) => speedAt(d) * d;

  double get optimumDensity => jamDensity / 2;
  double get optimumSpeed => freeFlow / 2;
  double get maxFlow => jamDensity * freeFlow / 4;
}

/// Speed against density on top, flow against density underneath, to the
/// same horizontal scale. Where the flow peaks is the question in one item,
/// so the peak is marked only once the round is answered.
class GreenshieldsPainter extends CustomPainter {
  const GreenshieldsPainter({
    required this.stream,
    this.showPoint = true,
    this.answered = false,
  });

  final Stream stream;

  /// Whether to stand a marker at the round's own density.
  final bool showPoint;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 44.0;
    final right = size.width - 18;
    final topPlot = 24.0;
    final midline = size.height * 0.50;
    final bottomPlot = size.height - 34;

    double xOf(double d) => left + d / stream.jamDensity * (right - left);
    double speedY(double s) =>
        midline - 12 - (s / stream.freeFlow) * (midline - 12 - topPlot);
    double flowY(double v) =>
        bottomPlot - (v / stream.maxFlow) * (bottomPlot - midline - 6);

    final axis = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(Offset(left, topPlot), Offset(left, midline - 12), axis)
      ..drawLine(
          Offset(left, midline - 12), Offset(right, midline - 12), axis)
      ..drawLine(Offset(left, midline + 6), Offset(left, bottomPlot), axis)
      ..drawLine(Offset(left, bottomPlot), Offset(right, bottomPlot), axis);
    writeOn(canvas, size, 'speed', Offset(4, topPlot - 2), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, 'flow', Offset(4, midline + 8), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, 'density, up to the jam', Offset(left, bottomPlot + 6),
        AppColors.ink3, fontSize: 9.5);

    // Speed falls in a straight line from the free flow speed to nothing.
    canvas.drawLine(
        Offset(xOf(0), speedY(stream.freeFlow)),
        Offset(xOf(stream.jamDensity), speedY(0)),
        Paint()
          ..color = AppColors.info
          ..strokeWidth = 2);

    // Flow is the product of the two, so it is a parabola. Where it peaks
    // and how many densities give one flow are both questions, so the curve
    // itself waits for the answer.
    if (!answered) {
      writeOn(canvas, size, 'the flow curve comes out after the answer',
          Offset(left - 34, midline + 24), AppColors.ink3, fontSize: 9.5);
    } else {
    final curve = Path();
    for (var i = 0; i <= 50; i++) {
      final d = stream.jamDensity * i / 50;
      final p = Offset(xOf(d), flowY(stream.flowAt(d)));
      i == 0 ? curve.moveTo(p.dx, p.dy) : curve.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        curve,
        Paint()
          ..color = AppColors.ember
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    }

    writeOn(
        canvas,
        size,
        'empty road ${stream.freeFlow.toStringAsFixed(0)} mph, jam at '
            '${stream.jamDensity.toStringAsFixed(0)} a mile',
        Offset(left - 34, 8),
        AppColors.ink3,
        fontSize: 9.5);

    final d = stream.density;
    if (showPoint && d != null) {
      canvas.drawLine(
          Offset(xOf(d), topPlot),
          Offset(xOf(d), bottomPlot),
          Paint()
            ..color = AppColors.charcoal.withValues(alpha: 0.5)
            ..strokeWidth = 1.4);
      writeOn(canvas, size, '${d.toStringAsFixed(0)} a mile',
          Offset(xOf(d) - 26, bottomPlot + 6), AppColors.charcoal,
          fontSize: 9.5);
    }

    if (!answered) return;

    // The peak, and the two halves that put it there.
    final peak = Offset(xOf(stream.optimumDensity), flowY(stream.maxFlow));
    canvas.drawCircle(peak, 3.5, Paint()..color = AppColors.forest);
    writeOn(
        canvas,
        size,
        '${stream.maxFlow.toStringAsFixed(0)} an hour at '
            '${stream.optimumSpeed.toStringAsFixed(0)} mph',
        Offset(peak.dx - 60, peak.dy - 14),
        AppColors.forest,
        fontSize: 9.5);
    canvas.drawCircle(
        Offset(xOf(stream.optimumDensity), speedY(stream.optimumSpeed)),
        3,
        Paint()..color = AppColors.forest);
    if (d != null) {
      writeOn(
          canvas,
          size,
          'at ${d.toStringAsFixed(0)} a mile the speed is '
              '${stream.speedAt(d).toStringAsFixed(0)} mph',
          Offset(left - 34, midline - 8),
          AppColors.charcoal,
          fontSize: 9.5);
    }
  }

  @override
  bool shouldRepaint(GreenshieldsPainter old) =>
      old.stream != stream ||
      old.showPoint != showPoint ||
      old.answered != answered;
}

/// Crashes counted against the traffic that was exposed to them. The point
/// of the whole calculation is the size of the denominator.
@immutable
class CrashRate {
  const CrashRate({
    required this.crashes,
    required this.dailyTraffic,
    this.days = 365,
    this.miles,
  });

  /// Crashes in the period, vehicles a day, days, and the length of road
  /// when it is a segment rather than an intersection.
  final double crashes;
  final double dailyTraffic;
  final double days;
  final double? miles;

  bool get isSegment => miles != null;

  /// Entering vehicles, or vehicle miles.
  double get exposure =>
      dailyTraffic * days * (isSegment ? miles! : 1);

  double get perMillion => crashes * 1000000 / exposure;

  /// The lesson's own wrong answers.
  double get forgettingTheYear => crashes * 1000000 / dailyTraffic;
  double get forgettingTheMillion => crashes / exposure;
}

/// The crash count beside the traffic it came out of, drawn to show how
/// unlike each other the two numbers are. The rate itself waits for the
/// answer.
class ExposurePainter extends CustomPainter {
  const ExposurePainter({required this.rate, this.answered = false});

  final CrashRate rate;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 30.0;
    final right = size.width - 26;
    var y = 44.0;

    writeOn(
        canvas,
        size,
        rate.isSegment
            ? '${rate.miles!.toStringAsFixed(0)} miles of road'
            : 'one intersection',
        Offset(left - 8, 8),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${rate.crashes.toStringAsFixed(0)} crashes in '
            '${(rate.days / 365).toStringAsFixed(0)} year'
            '${rate.days > 400 ? 's' : ''}',
        Offset(left - 8, 22),
        AppColors.ink3,
        fontSize: 9.5);

    // Each crash as a tick, so a dozen of them looks like a dozen.
    for (var i = 0; i < math.min(rate.crashes, 40); i++) {
      canvas.drawRect(
          Rect.fromLTWH(left + (i % 20) * 9, y + (i ~/ 20) * 10, 5, 7),
          Paint()..color = AppColors.error.withValues(alpha: 0.75));
    }
    y += 30;

    writeOn(
        canvas,
        size,
        '${rate.dailyTraffic.toStringAsFixed(0)} vehicles a day',
        Offset(left - 8, y),
        AppColors.ink3,
        fontSize: 9.5);
    y += 16;

    // The exposure as one long bar, labeled rather than scaled: it is
    // millions against a dozen, and no drawing can show that honestly.
    // The bar is drawn against the busiest case any round uses, so four
    // times the traffic looks like four times the traffic.
    final share = math.min(rate.exposure / 33000000, 1).toDouble();
    canvas
      ..drawRect(
          Rect.fromLTRB(left, y, right, y + 14),
          Paint()
            ..color = AppColors.line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1)
      ..drawRect(Rect.fromLTRB(left, y, left + (right - left) * share, y + 14),
          Paint()..color = AppColors.info.withValues(alpha: 0.35));
    if (answered) {
      writeOn(
          canvas,
          size,
          '${(rate.exposure / 1000000).toStringAsFixed(2)} million '
              '${rate.isSegment ? 'vehicle miles' : 'entering vehicles'}',
          Offset(left + 2, y + 18),
          AppColors.info,
          fontSize: 9.5);
    } else {
      writeOn(canvas, size, 'the traffic that went through, which is',
          Offset(left + 2, y + 18), AppColors.info, fontSize: 9.5);
      writeOn(canvas, size, 'what the crashes are measured against',
          Offset(left + 2, y + 32), AppColors.info, fontSize: 9.5);
    }

    if (!answered) {
      writeOn(canvas, size, 'the rate comes out after the answer',
          Offset(left - 8, size.height - 16), AppColors.ink3, fontSize: 9.5);
      return;
    }

    writeOn(
        canvas,
        size,
        '${rate.perMillion.toStringAsFixed(2)} crashes per million '
            '${rate.isSegment ? 'vehicle miles' : 'entering'}',
        Offset(left - 8, size.height - 16),
        AppColors.charcoal,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(ExposurePainter old) =>
      old.rate != rate || old.answered != answered;
}
