import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// The four steps of a travel demand forecast, in the order they are run.
enum Forecast { generation, distribution, mode, assignment }

extension ForecastNames on Forecast {
  String get title => switch (this) {
        Forecast.generation => 'generation',
        Forecast.distribution => 'distribution',
        Forecast.mode => 'mode choice',
        Forecast.assignment => 'assignment',
      };

  String get does => switch (this) {
        Forecast.generation => 'how many trips each zone makes',
        Forecast.distribution => 'where those trips go',
        Forecast.mode => 'how they travel',
        Forecast.assignment => 'which route they take',
      };
}

/// The four steps as boxes in order, with one of them picked out. Which
/// step does what is the question, so the descriptions wait for the answer.
class StepsPainter extends CustomPainter {
  const StepsPainter({this.highlight, this.answered = false});

  /// The step this round is about, when it has one.
  final Forecast? highlight;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 16.0;
    final wide = (size.width - 32) / 4;
    final top = size.height * 0.30;

    for (var i = 0; i < Forecast.values.length; i++) {
      final step = Forecast.values[i];
      final box = Rect.fromLTWH(left + i * wide + 3, top, wide - 6, 34);
      final picked = highlight == step;
      canvas
        ..drawRect(
            box,
            Paint()
              ..color = (picked ? AppColors.ember : AppColors.ink2)
                  .withValues(alpha: picked ? 0.30 : 0.14))
        ..drawRect(
            box,
            Paint()
              ..color = picked ? AppColors.ember : AppColors.line
              ..style = PaintingStyle.stroke
              ..strokeWidth = picked ? 1.6 : 1);
      writeOn(canvas, size, '${i + 1}', Offset(box.left + 4, box.top + 3),
          AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, step.title, Offset(box.left + 4, box.top + 17),
          picked ? AppColors.ember : AppColors.ink3, fontSize: 9.5);

      if (i < 3) {
        canvas.drawLine(
            Offset(box.right + 1, box.center.dy),
            Offset(box.right + 5, box.center.dy),
            Paint()
              ..color = AppColors.ink3
              ..strokeWidth = 1.2);
      }

    }

    // What each step does, once the round is answered. These lines are far
    // wider than the boxes above them, so they are stacked down the left
    // and numbered rather than written under their own box: under the boxes
    // they ran into each other and the last one fell off the drawing.
    if (answered) {
      for (var i = 0; i < Forecast.values.length; i++) {
        final step = Forecast.values[i];
        final picked = highlight == step;
        writeOn(canvas, size, '${i + 1}  ${step.does}',
            Offset(left, top + 44 + i * 14),
            picked ? AppColors.ember : AppColors.ink3,
            fontSize: 9.5);
      }
    }

    writeOn(canvas, size, 'run in order, each one feeding the next',
        Offset(left, top - 18), AppColors.ink3, fontSize: 9.5);
    if (!answered) {
      writeOn(canvas, size, 'what each step does comes out after the answer',
          Offset(left, top + 46), AppColors.ink3, fontSize: 9.5);
    }
  }

  @override
  bool shouldRepaint(StepsPainter old) =>
      old.highlight != highlight || old.answered != answered;
}

/// One destination zone: what it attracts, and how easily it is reached.
@immutable
class Destination {
  const Destination({
    required this.name,
    required this.attractions,
    required this.friction,
  });

  final String name;
  final double attractions;

  /// The friction factor, which FALLS as the trip gets longer.
  final double friction;

  double get weight => attractions * friction;
}

/// An origin zone and the destinations its trips can go to.
@immutable
class Spread {
  const Spread({required this.produced, required this.destinations});

  final double produced;
  final List<Destination> destinations;

  double get total =>
      destinations.fold(0, (sum, d) => sum + d.weight);

  double shareOf(Destination d) => total <= 0 ? 0 : d.weight / total;
  double tripsTo(Destination d) => produced * shareOf(d);

  /// What you get by using the attractions and ignoring how far away each
  /// one is, which is one of the lesson's wrong answers.
  double attractionsOnly(Destination d) {
    final sum = destinations.fold<double>(0, (s, x) => s + x.attractions);
    return sum <= 0 ? 0 : produced * d.attractions / sum;
  }
}

/// The origin zone on the left with its destinations on the right, and the
/// share each one takes. The shares are the question, so the arrows are all
/// the same weight until the round is answered.
class GravityPainter extends CustomPainter {
  const GravityPainter({required this.spread, this.answered = false});

  final Spread spread;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final originX = 48.0;
    final destX = size.width - 96;
    final middle = size.height * 0.52;

    canvas.drawCircle(
        Offset(originX, middle), 18, Paint()..color = AppColors.ink2);
    writeOn(canvas, size, 'zone i', Offset(originX - 18, middle - 6),
        AppColors.charcoal, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${spread.produced.toStringAsFixed(0)} trips made here',
        Offset(4, middle + 24),
        AppColors.ink3,
        fontSize: 9.5);

    final count = spread.destinations.length;
    for (var i = 0; i < count; i++) {
      final d = spread.destinations[i];
      final y = middle + (i - (count - 1) / 2) * 54;
      final share = spread.shareOf(d);
      canvas
        ..drawLine(
            Offset(originX + 20, middle),
            Offset(destX - 16, y),
            Paint()
              ..color = AppColors.ember.withValues(alpha: answered ? 0.7 : 0.35)
              ..strokeWidth = answered ? math.max(share * 14, 1.2) : 1.6)
        ..drawCircle(
            Offset(destX, y), 15, Paint()..color = AppColors.ink2);
      writeOn(canvas, size, d.name, Offset(destX - 14, y - 6),
          AppColors.charcoal, fontSize: 9.5);
      writeOn(
          canvas,
          size,
          '${d.attractions.toStringAsFixed(0)} attractions, friction '
              '${d.friction.toStringAsFixed(1)}',
          Offset(destX - 100, y + 20),
          AppColors.ink3,
          fontSize: 9.5);
      if (answered) {
        writeOn(
            canvas,
            size,
            'weight ${d.weight.toStringAsFixed(0)}, '
                '${(share * 100).toStringAsFixed(1)} per cent, '
                '${spread.tripsTo(d).toStringAsFixed(0)} trips',
            Offset(destX - 100, y + 34),
            AppColors.ember,
            fontSize: 9.5);
      }
    }

    if (!answered) {
      writeOn(canvas, size, 'how the trips split comes out after the answer',
          Offset(4, size.height - 16), AppColors.ink3, fontSize: 9.5);
      return;
    }
    writeOn(
        canvas,
        size,
        'the weights add to ${spread.total.toStringAsFixed(0)}, and the '
            'shares to one',
        Offset(4, size.height - 16),
        AppColors.charcoal,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(GravityPainter old) =>
      old.spread != spread || old.answered != answered;
}
