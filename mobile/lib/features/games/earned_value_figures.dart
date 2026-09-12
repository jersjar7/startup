import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Where a project stands on one date, in the three numbers earned value
/// management keeps, and everything that comes out of them.
@immutable
class Progress {
  const Progress({
    required this.planned,
    required this.earned,
    required this.actual,
    this.budget,
  });

  /// What the plan said would be done by now, in dollars of budget.
  final double planned;

  /// What the work actually done is worth, at budgeted rates.
  final double earned;

  /// What has actually been spent.
  final double actual;

  /// The whole job's budget, when a round is about forecasting.
  final double? budget;

  /// Earned less spent: how the money is going.
  double get costVariance => earned - actual;

  /// Earned less planned: how the calendar is going.
  double get scheduleVariance => earned - planned;

  bool get overBudget => costVariance < 0;
  bool get behindSchedule => scheduleVariance < 0;

  /// Value earned for each dollar spent, and for each dollar planned.
  double get costIndex => actual <= 0 ? 0 : earned / actual;
  double get scheduleIndex => planned <= 0 ? 0 : earned / planned;

  /// What the rest of the job will cost if it goes on as it has been.
  double get toComplete =>
      budget == null || costIndex <= 0 ? 0 : (budget! - earned) / costIndex;

  /// And what the whole job will cost by then.
  double get atCompletion => actual + toComplete;

  /// What the rest would cost at budgeted rates, which is the wrong answer
  /// the lesson prints.
  double get remainingAtBudget => budget == null ? 0 : budget! - earned;
}

/// The three numbers as bars on one date, with the two variances drawn
/// between them once the round is answered.
class ValuePainter extends CustomPainter {
  const ValuePainter({required this.progress, this.answered = false});

  final Progress progress;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 108.0;
    final right = size.width - 74;
    final biggest = math.max(
        progress.planned, math.max(progress.earned, progress.actual));
    double lengthOf(double v) =>
        biggest <= 0 ? 0 : v / biggest * (right - left);

    var y = 40.0;
    for (final (label, value, color) in [
      ('planned by now', progress.planned, AppColors.ink3),
      ('earned so far', progress.earned, AppColors.ember),
      ('actually spent', progress.actual, AppColors.info),
    ]) {
      writeOn(canvas, size, label, Offset(6, y - 2), AppColors.ink3,
          fontSize: 9.5);
      canvas.drawRect(
          Rect.fromLTWH(left, y - 2, math.max(lengthOf(value), 1), 14),
          Paint()..color = color.withValues(alpha: 0.45));
      writeOn(
          canvas,
          size,
          '${(value / 1000).toStringAsFixed(0)}k',
          Offset(left + lengthOf(value) + 6, y - 2),
          color,
          fontSize: 9.5);
      y += 30;
    }

    writeOn(canvas, size, 'everything in dollars, on one date',
        const Offset(6, 8), AppColors.ink3, fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'the two variances come out after the answer',
          Offset(6, size.height - 16), AppColors.ink3, fontSize: 9.5);
      return;
    }

    final cv = progress.costVariance;
    final sv = progress.scheduleVariance;
    writeOn(
        canvas,
        size,
        'cost: earned less spent, '
            '${(cv / 1000).toStringAsFixed(0)}k, '
            '${progress.overBudget ? 'over budget' : 'under budget'}',
        Offset(6, size.height - 30),
        progress.overBudget ? AppColors.error : AppColors.forest,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'schedule: earned less planned, '
            '${(sv / 1000).toStringAsFixed(0)}k, '
            '${progress.behindSchedule ? 'behind' : 'ahead'}',
        Offset(6, size.height - 16),
        progress.behindSchedule ? AppColors.error : AppColors.forest,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(ValuePainter old) =>
      old.progress != progress || old.answered != answered;
}

/// The budget as one long bar, with what has been spent, what the work so
/// far was worth, and the forecast total once the round is answered.
class ForecastPainter extends CustomPainter {
  const ForecastPainter({required this.progress, this.answered = false});

  final Progress progress;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final budget = progress.budget ?? progress.planned;
    final left = 92.0;
    final right = size.width - 66;
    final worst = math.max(budget, answered ? progress.atCompletion : budget);
    double lengthOf(double v) => v / worst * (right - left);

    var y = 46.0;
    final rows = <(String, double, Color)>[
      ('the budget', budget, AppColors.ink3),
      ('spent so far', progress.actual, AppColors.info),
      ('earned so far', progress.earned, AppColors.ember),
      if (answered) ('forecast total', progress.atCompletion, AppColors.error),
    ];
    for (final (label, value, color) in rows) {
      writeOn(canvas, size, label, Offset(6, y - 2), AppColors.ink3,
          fontSize: 9.5);
      canvas.drawRect(
          Rect.fromLTWH(left, y - 2, math.max(lengthOf(value), 1), 14),
          Paint()..color = color.withValues(alpha: 0.45));
      writeOn(
          canvas,
          size,
          '${(value / 1000000).toStringAsFixed(2)}M',
          Offset(left + lengthOf(value) + 6, y - 2),
          color,
          fontSize: 9.5);
      y += 28;
    }

    // The budget line, drawn across everything for comparison.
    canvas.drawLine(
        Offset(left + lengthOf(budget), 34),
        Offset(left + lengthOf(budget), y - 8),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 1.4);

    writeOn(canvas, size, 'the whole job, in dollars', const Offset(6, 8),
        AppColors.ink3, fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'what the rest will cost comes out after the '
          'answer', Offset(6, size.height - 16), AppColors.ink3,
          fontSize: 9.5);
      return;
    }

    writeOn(
        canvas,
        size,
        'earning ${progress.costIndex.toStringAsFixed(2)} of value for each '
            'dollar spent',
        Offset(6, size.height - 30),
        AppColors.charcoal,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'so the rest costs '
            '${(progress.toComplete / 1000000).toStringAsFixed(2)}M, not '
            '${(progress.remainingAtBudget / 1000000).toStringAsFixed(2)}M',
        Offset(6, size.height - 16),
        AppColors.error,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(ForecastPainter old) =>
      old.progress != progress || old.answered != answered;
}
