import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Which side of the optimum a field moisture sits on.
enum Side { dry, optimum, wet }

/// A Proctor test: the laboratory curve of dry unit weight against moisture
/// content, and a field point measured against it.
@immutable
class Proctor {
  const Proctor({
    required this.maxDryUnitWeight,
    required this.optimum,
    required this.fieldDryUnitWeight,
    required this.fieldMoisture,
    this.specification = 95,
  });

  /// Pounds per cubic foot, and per cent by weight.
  final double maxDryUnitWeight;
  final double optimum;
  final double fieldDryUnitWeight;
  final double fieldMoisture;

  /// The relative compaction the job asks for, in per cent.
  final double specification;

  double get relativeCompaction => fieldDryUnitWeight / maxDryUnitWeight * 100;

  bool get passes => relativeCompaction >= specification;

  Side get side {
    if ((fieldMoisture - optimum).abs() < 0.25) return Side.optimum;
    return fieldMoisture < optimum ? Side.dry : Side.wet;
  }

  /// The shape of a Proctor curve: a hump that peaks at the optimum. Steeper
  /// on the wet side than the dry, which is what a real one does.
  double dryUnitWeightAt(double moisture) {
    final off = moisture - optimum;
    final drop = off < 0 ? 0.32 : 0.46;
    return maxDryUnitWeight - drop * off * off;
  }
}

/// The Proctor curve, with the field point on it. Where the peak lies is the
/// question in one round, so the curve draws no peak marker until the round
/// is answered.
class ProctorPainter extends CustomPainter {
  const ProctorPainter({
    required this.test,
    this.showField = true,
    this.answered = false,
  });

  final Proctor test;

  /// Whether to plot the field measurement.
  final bool showField;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 44.0;
    final right = size.width - 18;
    final top = 26.0;
    final bottom = size.height - 30;

    final wLow = test.optimum - 6;
    final wHigh = test.optimum + 6;
    final dLow = test.maxDryUnitWeight - 19;
    final dHigh = test.maxDryUnitWeight + 3;

    double xOf(double w) => left + (w - wLow) / (wHigh - wLow) * (right - left);
    double yOf(double d) =>
        bottom - (d - dLow) / (dHigh - dLow) * (bottom - top);

    final axis = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.4;
    canvas
      ..drawLine(Offset(left, top), Offset(left, bottom), axis)
      ..drawLine(Offset(left, bottom), Offset(right, bottom), axis);
    writeOn(canvas, size, 'dry unit weight', const Offset(4, 8),
        AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'water added', Offset(right - 62, top - 16),
        AppColors.ink3, fontSize: 9.5);

    final curve = Path();
    for (var i = 0; i <= 60; i++) {
      final w = wLow + (wHigh - wLow) * i / 60;
      final d = test.dryUnitWeightAt(w);
      final p = Offset(xOf(w), yOf(d));
      i == 0 ? curve.moveTo(p.dx, p.dy) : curve.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        curve,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    if (showField) {
      final p = Offset(xOf(test.fieldMoisture), yOf(test.fieldDryUnitWeight));
      canvas.drawCircle(p, 4, Paint()..color = AppColors.ember);
      writeOn(canvas, size, 'the field test', Offset(p.dx - 22, p.dy + 8),
          AppColors.ember, fontSize: 9.5);
    }

    if (!answered) {
      writeOn(canvas, size, 'the peak and the specification come out after '
          'the answer', Offset(left - 34, bottom + 10), AppColors.ink3,
          fontSize: 9.5);
      return;
    }

    // The peak, which is the laboratory maximum at the optimum moisture.
    final peak = Offset(xOf(test.optimum), yOf(test.maxDryUnitWeight));
    canvas
      ..drawCircle(peak, 3.5, Paint()..color = AppColors.forest)
      ..drawLine(
          Offset(peak.dx, peak.dy),
          Offset(peak.dx, bottom),
          Paint()
            ..color = AppColors.forest
            ..strokeWidth = 1);
    writeOn(canvas, size, 'the laboratory maximum',
        Offset(peak.dx - 40, peak.dy - 14), AppColors.forest, fontSize: 9.5);
    writeOn(canvas, size, 'optimum moisture', Offset(peak.dx - 34, bottom + 10),
        AppColors.forest, fontSize: 9.5);

    // The line the job will not accept anything below.
    final spec = test.maxDryUnitWeight * test.specification / 100;
    final y = yOf(spec);
    for (var x = left; x < right; x += 9) {
      canvas.drawLine(
          Offset(x, y),
          Offset(x + 5, y),
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 1.4);
    }
    writeOn(
        canvas,
        size,
        '${test.specification.toStringAsFixed(0)} per cent of it',
        Offset(left + 4, y - 13),
        AppColors.info,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${test.relativeCompaction.toStringAsFixed(1)} per cent, '
            '${test.passes ? 'it passes' : 'short'}',
        Offset(left + 4, top - 18),
        test.passes ? AppColors.forest : AppColors.error,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(ProctorPainter old) =>
      old.test != test ||
      old.showField != showField ||
      old.answered != answered;
}

/// A granular soil described by how its void ratio sits between the loosest
/// and densest states it can be packed into.
@immutable
class Granular {
  const Granular({
    required this.loosest,
    required this.densest,
    required this.inPlace,
  });

  /// Void ratios: the largest the soil can hold, the smallest, and what it
  /// actually has.
  final double loosest;
  final double densest;
  final double inPlace;

  double get relativeDensity =>
      (loosest - inPlace) / (loosest - densest) * 100;

  /// What the numerator becomes if the two terms are swapped, which is the
  /// lesson's own wrong answer.
  double get upsideDown => (inPlace - densest) / (loosest - densest) * 100;

  bool get nearerDensest => (inPlace - densest) < (loosest - inPlace);

  String get state {
    final d = relativeDensity;
    if (d < 35) return 'loose';
    if (d < 65) return 'medium dense';
    return 'dense';
  }
}

/// The two extremes on a line with the soil's own void ratio standing
/// between them. Which end counts as dense is the question in one round, so
/// the reading waits for the answer.
class PackingPainter extends CustomPainter {
  const PackingPainter({
    required this.soil,
    this.applies = true,
    this.answered = false,
  });

  final Granular soil;

  /// Whether the round's soil is one this scale describes at all. A clay is
  /// not, and saying so is the point of the round that asks.
  final bool applies;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 54.0;
    final right = size.width - 44;
    final y = size.height * 0.52;


    double xOf(double e) =>
        left + (e - soil.densest) / (soil.loosest - soil.densest) * (right - left);

    canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2);
    for (final (x, label, note) in [
      (left, soil.densest, 'as tight as it packs'),
      (right, soil.loosest, 'as loose as it sits'),
    ]) {
      canvas.drawLine(
          Offset(x, y - 8),
          Offset(x, y + 8),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2);
      writeOn(canvas, size, 'e = ${label.toStringAsFixed(2)}',
          Offset(x - 22, y + 12), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, note, Offset(x - 34, y + 26), AppColors.ink3,
          fontSize: 9.5);
    }

    if (!applies) {
      // The round's soil is a clay. Saying so before the answer would give
      // the answer away, so the scale simply stands there with nothing on
      // it until the round is over.
      if (!answered) return;
      canvas.drawRect(Offset.zero & size,
          Paint()..color = AppColors.cream.withValues(alpha: 0.72));
      writeOn(canvas, size, 'a clay has no loosest and tightest packing to '
          'sit between', Offset(left - 46, y - 20), AppColors.charcoal,
          fontSize: 9.5);
      writeOn(canvas, size, 'so this scale is not the one to use',
          Offset(left - 46, y + 4), AppColors.charcoal, fontSize: 9.5);
      return;
    }

    final at = xOf(soil.inPlace);
    canvas.drawLine(
        Offset(at, y - 24),
        Offset(at, y + 4),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2.4);
    writeOn(canvas, size, 'e = ${soil.inPlace.toStringAsFixed(2)} in place',
        Offset(at - 38, y - 38), AppColors.ember, fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'the reading comes out after the answer',
          Offset(left - 30, size.height - 14), AppColors.ink3, fontSize: 9.5);
      return;
    }

    // The reading is taken from the LOOSE end, so a tight soil scores high.
    final barY = y - 56;
    canvas.drawLine(
        Offset(right, barY),
        Offset(math.max(at, left), barY),
        Paint()
          ..color = AppColors.forest
          ..strokeWidth = 5);
    writeOn(
        canvas,
        size,
        '${soil.relativeDensity.toStringAsFixed(0)} per cent, ${soil.state}',
        Offset(left - 30, barY - 14),
        AppColors.forest,
        fontSize: 9.5);
    writeOn(canvas, size, 'measured from the loose end',
        Offset(left - 30, size.height - 14), AppColors.forest, fontSize: 9.5);
  }

  @override
  bool shouldRepaint(PackingPainter old) =>
      old.soil != soil ||
      old.applies != applies ||
      old.answered != answered;
}


/// What a soil gets when compaction alone will not do.
enum Fix { lime, cement, geosynthetic, drainage }

/// A subgrade described by the two things that decide what it needs: how
/// plastic it is, and whether water is the real problem.
@immutable
class Ground {
  const Ground({
    required this.name,
    required this.plasticityIndex,
    this.wet = false,
  });

  final String name;

  /// Zero for a clean sand or gravel, high for a fat clay.
  final double plasticityIndex;

  /// Whether the trouble is water that keeps coming back.
  final bool wet;

  bool get plastic => plasticityIndex >= 15;
  bool get granular => plasticityIndex <= 6;
}

/// A scale from clean gravel to fat clay with the round's soil standing on
/// it. Which additive suits which end is the question, so the two bands are
/// drawn only once the round is answered.
class StabilizerPainter extends CustomPainter {
  const StabilizerPainter({required this.ground, this.answered = false});

  final Ground ground;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 40.0;
    final right = size.width - 30;
    final y = size.height * 0.40;
    double xOf(double pi) => left + math.min(pi, 40) / 40 * (right - left);

    canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2);
    for (final (pi, label) in [
      (0.0, 'clean sand'),
      (12.0, 'silty, a little plastic'),
      (34.0, 'fat clay'),
    ]) {
      final x = xOf(pi);
      canvas.drawLine(
          Offset(x, y - 6),
          Offset(x, y + 6),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 1.4);
      writeOn(canvas, size, label, Offset(x - 26, y + 10), AppColors.ink3,
          fontSize: 9.5);
    }
    writeOn(canvas, size, 'plasticity, left to right', Offset(left - 26, y + 30),
        AppColors.ink3, fontSize: 9.5);

    final at = xOf(ground.plasticityIndex);
    canvas.drawLine(
        Offset(at, y - 30),
        Offset(at, y - 2),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2.4);
    writeOn(canvas, size, ground.name, Offset(at - 40, y - 44),
        AppColors.ember, fontSize: 9.5);
    if (ground.wet) {
      writeOn(canvas, size, 'and the water keeps coming back',
          Offset(left - 26, y - 58), AppColors.info, fontSize: 9.5);
    }

    if (!answered) {
      writeOn(canvas, size, 'which additive suits which end comes out after '
          'the answer', Offset(left - 30, size.height - 14), AppColors.ink3,
          fontSize: 9.5);
      return;
    }

    final band = y + 50;
    void mark(double from, double to, String label, Color color) {
      final r = Rect.fromLTRB(xOf(from), band, xOf(to), band + 12);
      canvas
        ..drawRect(r, Paint()..color = color.withValues(alpha: 0.25))
        ..drawRect(
            r,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2);
      writeOn(canvas, size, label, Offset(r.left + 4, band - 12), color,
          fontSize: 9.5);
    }

    mark(0, 10, 'cement', AppColors.forest);
    mark(15, 40, 'lime', AppColors.info);
  }

  @override
  bool shouldRepaint(StabilizerPainter old) =>
      old.ground != ground || old.answered != answered;
}
