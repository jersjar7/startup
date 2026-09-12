import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// The traffic stream as a mixture of cars and trucks, and what it takes to
/// count it all in passenger cars.
@immutable
class TruckMix {
  const TruckMix({required this.trucks, required this.equivalent});

  /// The proportion of trucks, and what one truck counts as in cars: two on
  /// the level, three on rolling ground.
  final double trucks;
  final double equivalent;

  /// A hundred vehicles take up this many car spaces.
  double get carSpaces => 100 * (1 + trucks * (equivalent - 1));

  /// The adjustment factor, which is always less than one.
  double get factor => 1 / (1 + trucks * (equivalent - 1));

  bool get rolling => equivalent > 2.5;
}

/// A directional freeway, its traffic, and everything the capacity analysis
/// makes of it.
@immutable
class Freeway {
  const Freeway({
    required this.volume,
    required this.peakHourFactor,
    required this.lanes,
    required this.mix,
    this.speed = 60,
  });

  /// Vehicles an hour in the direction analyzed, the peak hour factor, the
  /// lanes in that direction, the truck mixture, and the mean speed.
  final double volume;
  final double peakHourFactor;
  final int lanes;
  final TruckMix mix;
  final double speed;

  /// Passenger cars an hour in one lane, at the rate of the busiest quarter
  /// hour.
  double get flowPerLane =>
      volume / (peakHourFactor * lanes * mix.factor);

  /// The same thing with one adjustment left out, which is how the lesson's
  /// wrong answers are made.
  double get withoutTrucks => volume / (peakHourFactor * lanes);
  double get withoutPeak => volume / (lanes * mix.factor);

  double get density => flowPerLane / speed;

  /// The level of service letter, from the density alone.
  String get level {
    final d = density;
    if (d <= 11) return 'A';
    if (d <= 18) return 'B';
    if (d <= 26) return 'C';
    if (d <= 35) return 'D';
    if (d <= 45) return 'E';
    return 'F';
  }

  String levelFor(double d) {
    if (d <= 11) return 'A';
    if (d <= 18) return 'B';
    if (d <= 26) return 'C';
    if (d <= 35) return 'D';
    if (d <= 45) return 'E';
    return 'F';
  }
}

/// A hundred vehicles drawn as the space they really take up, with trucks
/// as long as the cars they stand in for. How much room the trucks want is
/// the question, so the count waits for the answer.
class TruckPainter extends CustomPainter {
  const TruckPainter({required this.mix, this.answered = false});

  final TruckMix mix;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 24.0;
    final right = size.width - 20;
    final y = size.height * 0.44;

    // Ten vehicles standing for a hundred, with the trucks drawn to the
    // length of the cars they displace.
    const shown = 10;
    final trucksShown = (mix.trucks * shown).round();
    final slots = shown - trucksShown + trucksShown * mix.equivalent;
    final slot = (right - left) / slots;

    var x = left;
    for (var i = 0; i < shown; i++) {
      final isTruck = i >= shown - trucksShown;
      final w = slot * (isTruck ? mix.equivalent : 1) - 3;
      canvas.drawRect(
          Rect.fromLTWH(x, y - 9, math.max(w, 2), 16),
          Paint()
            ..color = (isTruck ? AppColors.ember : AppColors.charcoal)
                .withValues(alpha: isTruck ? 0.55 : 0.7));
      x += w + 3;
    }

    writeOn(
        canvas,
        size,
        '${(mix.trucks * 100).toStringAsFixed(0)} per cent trucks, '
            '${mix.rolling ? 'rolling ground' : 'level ground'}',
        Offset(left - 8, 8),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'a truck takes the room of ${mix.equivalent.toStringAsFixed(0)} cars',
        Offset(left - 8, 22),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, 'ten vehicles, drawn to the room they take',
        Offset(left - 8, y + 16), AppColors.ink3, fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'what that does to the count comes out',
          Offset(left - 8, size.height - 30), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer',
          Offset(left - 8, size.height - 16), AppColors.ink3, fontSize: 9.5);
      return;
    }

    writeOn(
        canvas,
        size,
        '100 vehicles fill ${mix.carSpaces.toStringAsFixed(0)} car spaces',
        Offset(left - 8, size.height - 30),
        AppColors.ember,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'so the factor is ${mix.factor.toStringAsFixed(3)}, and you DIVIDE '
            'by it',
        Offset(left - 8, size.height - 16),
        AppColors.ember,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(TruckPainter old) =>
      old.mix != mix || old.answered != answered;
}

/// The level of service ladder, with its six bands and where this freeway
/// lands on it. The landing point waits for the answer.
class LosPainter extends CustomPainter {
  const LosPainter({
    required this.road,
    this.showSteps = true,
    this.answered = false,
  });

  final Freeway road;

  /// Whether to list the three adjustments down the left.
  final bool showSteps;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 44.0;
    final right = size.width - 24;
    final top = size.height - 92;
    const bands = [
      ('A', 0.0, 11.0),
      ('B', 11.0, 18.0),
      ('C', 18.0, 26.0),
      ('D', 26.0, 35.0),
      ('E', 35.0, 45.0),
      ('F', 45.0, 55.0),
    ];
    double xOf(double d) => left + (d / 55) * (right - left);

    writeOn(
        canvas,
        size,
        '${road.volume.toStringAsFixed(0)} an hour, ${road.lanes} lanes, '
            'peak factor ${road.peakHourFactor.toStringAsFixed(2)}',
        Offset(left - 34, 8),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${(road.mix.trucks * 100).toStringAsFixed(0)} per cent trucks at '
            '${road.mix.equivalent.toStringAsFixed(0)} cars each, '
            '${road.speed.toStringAsFixed(0)} mph',
        Offset(left - 34, 22),
        AppColors.ink3,
        fontSize: 9.5);

    if (showSteps) {
      var y = 44.0;
      for (final (label, value) in [
        ('cars an hour in one lane', answered
            ? road.flowPerLane.toStringAsFixed(0)
            : 'after the answer'),
        ('vehicles to a mile of lane', answered
            ? road.density.toStringAsFixed(1)
            : 'after the answer'),
      ]) {
        writeOn(canvas, size, '$label: $value', Offset(left - 34, y),
            answered ? AppColors.charcoal : AppColors.ink3, fontSize: 9.5);
        y += 15;
      }
    }

    // The ladder itself.
    for (final (letter, from, to) in bands) {
      final rect = Rect.fromLTRB(xOf(from), top, xOf(to), top + 18);
      canvas
        ..drawRect(
            rect,
            Paint()
              ..color = AppColors.ink2
                  .withValues(alpha: 0.10 + bands.indexWhere(
                              (b) => b.$1 == letter) *
                          0.06))
        ..drawRect(
            rect,
            Paint()
              ..color = AppColors.line
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      writeOn(canvas, size, letter, Offset(rect.center.dx - 3, top + 3),
          AppColors.ink3, fontSize: 9.5);
      if (letter != 'F') {
        writeOn(canvas, size, to.toStringAsFixed(0),
            Offset(rect.right - 7, top + 20), AppColors.ink3, fontSize: 9.5);
      }
    }
    writeOn(canvas, size, 'vehicles to a mile of lane',
        Offset(left - 34, top + 34), AppColors.ink3, fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'where this road lands comes out after the answer',
          Offset(left - 34, top - 16), AppColors.ink3, fontSize: 9.5);
      return;
    }

    final x = xOf(math.min(road.density, 55));
    canvas.drawLine(
        Offset(x, top - 10),
        Offset(x, top + 18),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2.4);
    writeOn(
        canvas,
        size,
        '${road.density.toStringAsFixed(1)} a mile, service ${road.level}',
        Offset(math.max(x - 60, left - 34), top - 24),
        AppColors.ember,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(LosPainter old) =>
      old.road != road ||
      old.showSteps != showSteps ||
      old.answered != answered;
}
