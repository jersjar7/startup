import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A driver seeing something ahead, and the two quite separate distances it
/// takes to get stopped. Everything here is worked out rather than quoted,
/// so a round cannot claim a distance its own numbers do not give.
@immutable
class Braking {
  const Braking({
    required this.speed,
    this.reactionTime = 2.5,
    this.deceleration = 11.2,
    this.grade = 0,
  });

  /// Miles per hour, seconds, feet per second squared, and grade as a
  /// fraction: uphill positive, downhill negative.
  final double speed;
  final double reactionTime;
  final double deceleration;
  final double grade;

  /// Thinking, at full speed the whole time. The 1.47 is miles per hour
  /// turned into feet per second.
  double get reactionDistance => 1.47 * speed * reactionTime;

  double get brakingDistance =>
      speed * speed / (30 * (deceleration / 32.2 + grade));

  double get total => reactionDistance + brakingDistance;

  bool get uphill => grade > 0;
  bool get downhill => grade < 0;
}

/// The road in elevation with the two stretches laid out along it: the one
/// spent thinking and the one spent braking. Which is which is a question
/// in one round, so the labels and the lengths wait for the answer.
class StoppingPainter extends CustomPainter {
  const StoppingPainter({
    required this.stop,
    this.against,
    this.answered = false,
  });

  final Braking stop;

  /// A second case to lay underneath at the same scale, for the rounds that
  /// compare a grade against the level road.
  final Braking? against;
  final bool answered;

  double get _longest => math.max(stop.total, against?.total ?? stop.total);

  @override
  void paint(Canvas canvas, Size size) {
    final left = 26.0;
    final right = size.width - 22;
    double lengthOf(double feet) => feet / _longest * (right - left);

    // Two roads need room for a heading over each one, so they sit higher
    // and further apart than a single road does.
    final y = against == null ? size.height * 0.46 : size.height * 0.28;
    _oneRoad(canvas, size, stop, left, y, lengthOf, 'this road');
    if (against != null) {
      _oneRoad(canvas, size, against!, left, size.height * 0.66, lengthOf,
          against!.grade == 0 && against!.reactionTime == 2.5
              ? 'for comparison'
              : 'the other road');
    }

    if (!answered) {
      writeOn(canvas, size, 'how far it runs, and how it splits,\ncomes out '
          'after the answer', Offset(left - 16, size.height - 32),
          AppColors.ink3, fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.elevation, note: 'the road');
  }

  void _oneRoad(Canvas canvas, Size size, Braking b, double left, double y,
      double Function(double) lengthOf, String which) {
    // Before the answer every road is drawn the same length, because how
    // far this one runs, and how it splits, is what the rounds are asking.
    final run = answered ? lengthOf(b.total) : lengthOf(_longest);
    final rise = -b.grade * 240;
    final endY = y + rise;
    canvas.drawLine(
        Offset(left, y),
        Offset(left + run, endY),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2);

    if (answered) {
      final thinking = lengthOf(b.reactionDistance);
      final braking = lengthOf(b.brakingDistance);
      for (final (from, width, color) in [
        (left, thinking, AppColors.info),
        (left + thinking, braking, AppColors.ember),
      ]) {
        canvas.drawRect(Rect.fromLTWH(from, y - 16, width, 10),
            Paint()..color = color.withValues(alpha: 0.45));
        canvas
          ..drawLine(
              Offset(from, y - 20),
              Offset(from, y - 2),
              Paint()
                ..color = color
                ..strokeWidth = 1.2)
          ..drawLine(
              Offset(from + width, y - 20),
              Offset(from + width, y - 2),
              Paint()
                ..color = color
                ..strokeWidth = 1.2);
      }
    }

    // The car at the start, and what it is stopping for at the end.
    canvas.drawRect(Rect.fromLTWH(left, y - 30, 16, 8),
        Paint()..color = AppColors.charcoal.withValues(alpha: 0.8));
    canvas.drawRect(Rect.fromLTWH(left + run - 6, endY - 14, 6, 14),
        Paint()..color = AppColors.error.withValues(alpha: 0.8));

    final label = b.grade == 0
        ? 'level'
        : '${(b.grade.abs() * 100).toStringAsFixed(0)} per cent '
            '${b.uphill ? 'uphill' : 'downhill'}';
    writeOn(
        canvas,
        size,
        '${b.speed.toStringAsFixed(0)} mph, $label, '
            '${b.reactionTime.toStringAsFixed(1)} s to react',
        Offset(left, y + 16),
        AppColors.ink3,
        fontSize: 9.5);
    if (against != null) {
      writeOn(canvas, size, which, Offset(left - 16, y - 44), AppColors.ink3,
          fontSize: 9.5);
    }

    if (!answered) return;
    writeOn(
        canvas,
        size,
        'thinking ${b.reactionDistance.toStringAsFixed(0)} ft',
        Offset(left, y - 34),
        AppColors.info,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'braking ${b.brakingDistance.toStringAsFixed(0)} ft',
        Offset(left + lengthOf(b.reactionDistance), y - 34),
        AppColors.ember,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'in all ${b.total.toStringAsFixed(0)} ft',
        Offset(left, y + 30),
        AppColors.charcoal,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(StoppingPainter old) =>
      old.stop != stop ||
      old.against != against ||
      old.answered != answered;
}

/// An hour of traffic counted in four quarters, one of them busier than the
/// rest. The peak hour factor and the flow rate both come out of it.
@immutable
class Hour {
  const Hour({required this.counts});

  /// Four fifteen minute counts, in vehicles.
  final List<double> counts;

  double get volume => counts.fold(0, (a, b) => a + b);
  double get worstQuarter => counts.reduce(math.max);

  /// The worst quarter, stretched out to an hour. Always at least the
  /// hourly volume, and equal to it only when all four quarters match.
  double get flowRate => 4 * worstQuarter;

  double get phf => volume / flowRate;

  bool get uniform => phf > 0.999;
}

/// The four quarter hours as bars, with the busiest one marked. What that
/// busiest quarter would come to if the whole hour ran that way is drawn
/// once the round is answered.
class PeakPainter extends CustomPainter {
  const PeakPainter({required this.hour, this.answered = false});

  final Hour hour;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 40.0;
    final right = size.width - 96;
    // Room under the axis for its label and for the line that says what is
    // still to come.
    final base = size.height - 54;
    final top = 30.0;
    final tallest = hour.worstQuarter * 1.25;
    final wide = (right - left) / 4;

    canvas.drawLine(
        Offset(left, base),
        Offset(right, base),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1.4);
    writeOn(canvas, size, 'four quarter hours', Offset(left, base + 8),
        AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'vehicles counted', const Offset(4, 8),
        AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'an hour, counted in quarters',
        Offset(left + 60, 8), AppColors.ink3, fontSize: 9.5);

    for (var i = 0; i < hour.counts.length; i++) {
      final v = hour.counts[i];
      final h = v / tallest * (base - top);
      final busiest = v == hour.worstQuarter;
      final bar = Rect.fromLTWH(left + i * wide + 4, base - h, wide - 8, h);
      canvas.drawRect(
          bar,
          Paint()
            ..color = (busiest ? AppColors.ember : AppColors.ink2)
                .withValues(alpha: busiest ? 0.55 : 0.35));
      writeOn(canvas, size, v.toStringAsFixed(0), Offset(bar.left, bar.top - 13),
          busiest ? AppColors.ember : AppColors.ink3, fontSize: 9.5);
    }

    if (!answered) {
      writeOn(canvas, size, 'what the busiest quarter means\nfor the hour '
          'comes out after the answer', Offset(left, base + 22),
          AppColors.ink3, fontSize: 9.5);
      return;
    }

    // The hour as counted, against the hour the peak quarter implies.
    final scale = (base - top) / (4 * tallest);
    for (final (value, label, color, dx) in [
      (hour.volume, 'counted ${hour.volume.toStringAsFixed(0)} in the hour',
          AppColors.ink3, 6.0),
      (
        hour.flowRate,
        'at that rate ${hour.flowRate.toStringAsFixed(0)} an hour',
        AppColors.ember,
        6.0
      ),
    ]) {
      final y = base - value * scale;
      for (var x = right + 4; x < size.width - 10; x += 8) {
        canvas.drawLine(
            Offset(x, y),
            Offset(x + 4, y),
            Paint()
              ..color = color
              ..strokeWidth = 1.4);
      }
      writeOn(canvas, size, label, Offset(right + dx, y - 13), color,
          fontSize: 9.5);
    }
    writeOn(
        canvas,
        size,
        'peak hour factor ${hour.phf.toStringAsFixed(2)}',
        Offset(left, top - 22),
        AppColors.charcoal,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(PeakPainter old) =>
      old.hour != hour || old.answered != answered;
}
