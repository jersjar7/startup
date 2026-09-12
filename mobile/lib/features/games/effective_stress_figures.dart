import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// One stratum of a soil profile.
@immutable
class Stratum {
  const Stratum({
    required this.name,
    required this.thickness,
    required this.unitWeight,
    this.saturated = false,
  });

  final String name;

  /// Feet.
  final double thickness;

  /// Pounds per cubic foot: the total unit weight of the layer as it is.
  final double unitWeight;

  /// Whether the layer sits below the water table.
  final bool saturated;
}

/// A soil profile with a water table in it, and the three stresses at any
/// depth worked out from the layers rather than quoted.
@immutable
class Deposit {
  const Deposit({
    required this.layers,
    required this.waterDepth,
    this.surcharge = 0,
    this.standing = 0,
  });

  final List<Stratum> layers;

  /// How far down the water table sits, in feet from the surface.
  final double waterDepth;

  /// A uniform load on the surface, in pounds per square foot.
  final double surcharge;

  /// Open water standing over the site, in feet. It weighs on everything
  /// below it and pressurizes the pore water by the same amount, which is
  /// why it changes no effective stress anywhere.
  final double standing;

  static const unitWeightOfWater = 62.4;

  double get depth => layers.fold(0.0, (t, l) => t + l.thickness);

  /// Everything above the point, weighed.
  double totalAt(double at) {
    var stress = surcharge + standing * unitWeightOfWater;
    var top = 0.0;
    for (final layer in layers) {
      final inThis = math.max(0.0, math.min(at, top + layer.thickness) - top);
      stress += inThis * layer.unitWeight;
      top += layer.thickness;
    }
    return stress;
  }

  /// Water pressure, which exists only below the water table and is measured
  /// from the water table rather than from the surface.
  double poreAt(double at) => standing * unitWeightOfWater +
      (at <= waterDepth ? 0 : (at - waterDepth) * unitWeightOfWater);

  /// What the grains actually feel.
  double effectiveAt(double at) => totalAt(at) - poreAt(at);
}

/// The profile in section: layers down the page, the water table marked with
/// its own symbol, and the depth in question called out. The three stresses
/// are only written once the round is over.
class DepositPainter extends CustomPainter {
  const DepositPainter({
    required this.deposit,
    required this.at,
    this.answered = false,
  });

  final Deposit deposit;

  /// The depth the round is asking about, in feet.
  final double at;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 46.0;
    final right = size.width * 0.62;
    final standingDrawn = deposit.standing > 0 ? 22.0 : 0.0;
    final top = 34.0 + standingDrawn;
    final bottom = size.height - 26;

    double yOf(double feet) =>
        top + feet / deposit.depth * (bottom - top);

    // The layers.
    var run = 0.0;
    for (final layer in deposit.layers) {
      final a = yOf(run);
      final b = yOf(run + layer.thickness);
      final rect = Rect.fromLTRB(left, a, right, b);
      canvas.drawRect(
          rect,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
      hatchIn(canvas, Path()..addRect(rect),
          step: layer.saturated ? 7 : 10,
          color: layer.saturated ? AppColors.info : AppColors.ink2,
          slope: layer.saturated ? -1 : 1);
      writeOn(
          canvas,
          size,
          '${layer.name}, ${layer.unitWeight.toStringAsFixed(0)} pcf',
          Offset(left + 6, (a + b) / 2 - 6),
          AppColors.ink3,
          fontSize: 9.5);
      writeOn(canvas, size, '${layer.thickness.toStringAsFixed(0)} ft',
          Offset(right + 6, (a + b) / 2 - 6), AppColors.ink3, fontSize: 9.5);
      run += layer.thickness;
    }

    groundLine(canvas, Offset(left - 8, yOf(0)), Offset(right + 8, yOf(0)));

    // A surcharge, if the round has one, drawn as a row of little arrows.
    if (deposit.surcharge > 0) {
      for (var x = left + 6; x < right; x += 18) {
        canvas
          ..drawLine(
              Offset(x, top - 20),
              Offset(x, top - 6),
              Paint()
                ..color = AppColors.charcoal
                ..strokeWidth = 1.6)
          ..drawPath(
              Path()
                ..moveTo(x, top - 2)
                ..lineTo(x - 3, top - 8)
                ..lineTo(x + 3, top - 8)
                ..close(),
              Paint()..color = AppColors.charcoal);
      }
      writeOn(
          canvas,
          size,
          '${deposit.surcharge.toStringAsFixed(0)} psf on top',
          Offset(left, top - 32),
          AppColors.charcoal,
          fontSize: 9.5);
    }

    // Open water standing over the site, drawn above the ground.
    if (standingDrawn > 0) {
      final surface = yOf(0) - standingDrawn;
      canvas.drawRect(
          Rect.fromLTRB(left - 8, surface, right + 8, yOf(0)),
          Paint()..color = AppColors.info.withValues(alpha: 0.20));
      waterLevel(canvas, Offset(left - 8, surface), Offset(right + 8, surface));
      writeOn(
          canvas,
          size,
          '${deposit.standing.toStringAsFixed(0)} ft of open water',
          Offset(left, surface - 14),
          AppColors.info,
          fontSize: 9.5);
    }

    // The water table, with the triangle that says what it is.
    final wt = yOf(deposit.waterDepth);
    canvas.drawLine(
        Offset(left - 10, wt),
        Offset(right + 10, wt),
        Paint()
          ..color = AppColors.info
          ..strokeWidth = 1.6);
    canvas.drawPath(
      Path()
        ..moveTo(left - 2, wt - 7)
        ..lineTo(left + 6, wt - 7)
        ..lineTo(left + 2, wt)
        ..close(),
      Paint()..color = AppColors.info,
    );
    writeOn(canvas, size, 'water table', Offset(left - 34, wt - 16),
        AppColors.info, fontSize: 9.5);

    // The point in question.
    final y = yOf(at);
    canvas
      ..drawLine(
          Offset(left - 14, y),
          Offset(right + 14, y),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 2)
      ..drawCircle(Offset(right, y), 4, Paint()..color = AppColors.ember);
    writeOn(canvas, size, '${at.toStringAsFixed(0)} ft down',
        Offset(left - 40, y - 16), AppColors.ember, fontSize: 9.5);

    if (answered) {
      final x = size.width * 0.70;
      var row = top + 6;
      for (final (name, value) in [
        ('total', deposit.totalAt(at)),
        ('water', deposit.poreAt(at)),
        ('effective', deposit.effectiveAt(at)),
      ]) {
        writeOn(canvas, size, '$name ${value.toStringAsFixed(0)}',
            Offset(x, row), AppColors.forest, fontSize: 9.5);
        row += 15;
      }
    }

    viewTag(canvas, size, Looking.section, note: 'the ground');
  }

  @override
  bool shouldRepaint(DepositPainter old) =>
      old.deposit != deposit || old.at != at || old.answered != answered;
}
