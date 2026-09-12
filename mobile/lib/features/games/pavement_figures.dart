import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// One course of a flexible pavement.
@immutable
class Course {
  const Course({
    required this.name,
    required this.coefficient,
    required this.thickness,
    this.drainage = 1.0,
  });

  final String name;

  /// How much structure an inch of this material is worth.
  final double coefficient;

  /// Inches.
  final double thickness;

  /// The drainage coefficient, which is one for the surface course by
  /// convention and can be less for a base or subbase that drains poorly.
  final double drainage;

  double get contribution => coefficient * thickness * drainage;

  /// What one inch of it is worth, drainage included.
  double get perInch => coefficient * drainage;
}

/// A pavement section: the courses, and the structural number they add up
/// to.
@immutable
class Pavement {
  const Pavement({required this.courses, this.required_});

  final List<Course> courses;

  /// The structural number the design has to reach, when a round is about
  /// solving for a thickness.
  final double? required_;

  double get structuralNumber =>
      courses.fold(0, (sum, c) => sum + c.contribution);

  /// What is still missing, if a target was given.
  double get shortfall =>
      required_ == null ? 0 : required_! - structuralNumber;

  /// How many inches of a given course would close that gap.
  double inchesNeededOf(Course c) =>
      c.perInch <= 0 ? 0 : shortfall / c.perInch;
}

/// The pavement in section, its courses drawn to thickness. What each
/// course contributes is the question, so the numbers wait for the answer.
class PavementPainter extends CustomPainter {
  const PavementPainter({required this.pavement, this.answered = false});

  final Pavement pavement;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 26.0;
    final right = size.width * 0.62;
    var y = 42.0;
    final total = pavement.courses
        .fold<double>(0, (sum, c) => sum + c.thickness);
    final perInch = math.min((size.height - 92) / math.max(total, 1), 7.0);

    groundLine(canvas, Offset(left, y), Offset(right, y));
    for (var i = 0; i < pavement.courses.length; i++) {
      final c = pavement.courses[i];
      final deep = c.thickness * perInch;
      final rect = Rect.fromLTWH(left, y, right - left, deep);
      canvas
        ..drawRect(
            rect,
            Paint()
              ..color = AppColors.charcoal.withValues(alpha: 0.55 - i * 0.15))
        ..drawRect(
            rect,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      // Straight onto the course: writeOn would lay a pale patch behind
      // the lettering, which on a dark band looks like a hole.
      final label = TextPainter(
        text: TextSpan(
          text: '${c.name}, ${c.thickness.toStringAsFixed(0)} in',
          style: AppTheme.mono(size: 9.5, color: AppColors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(left + 5, y + deep / 2 - label.height / 2));
      writeOn(
          canvas,
          size,
          'a ${c.coefficient.toStringAsFixed(2)}'
              '${c.drainage != 1.0 ? ', drainage '
                  '${c.drainage.toStringAsFixed(2)}' : ''}',
          Offset(right + 6, y + deep / 2 - 6),
          AppColors.ink3,
          fontSize: 9.5);
      if (answered) {
        writeOn(
            canvas,
            size,
            'gives ${c.contribution.toStringAsFixed(2)}',
            Offset(right + 6, y + deep / 2 + 6),
            AppColors.ember,
            fontSize: 9.5);
      }
      y += deep;
    }

    writeOn(canvas, size, 'the subgrade, which carries what is left',
        Offset(left, y + 6), AppColors.ink3, fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'what each course is worth comes out',
          Offset(left - 16, size.height - 30), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer',
          Offset(left - 16, size.height - 16), AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.section, note: 'the pavement');
      return;
    }

    final target = pavement.required_;
    writeOn(
        canvas,
        size,
        'structural number '
            '${pavement.structuralNumber.toStringAsFixed(2)}'
            '${target != null ? ' of ${target.toStringAsFixed(1)} needed'
                : ''}',
        Offset(left - 16, size.height - 16),
        AppColors.charcoal,
        fontSize: 9.5);
    viewTag(canvas, size, Looking.section, note: 'the pavement');
  }

  @override
  bool shouldRepaint(PavementPainter old) =>
      old.pavement != pavement || old.answered != answered;
}

/// An axle load, and the damage it does compared with the standard one.
@immutable
class Axle {
  const Axle({
    required this.name,
    required this.kips,
    required this.factor,
    this.passes = 1,
  });

  final String name;

  /// Thousands of pounds on the axle.
  final double kips;

  /// The load equivalency factor: how many standard eighteen kip passes
  /// this one is worth.
  final double factor;

  /// How many times it comes past.
  final double passes;

  double get esals => passes * factor;
}

/// Several axles side by side, with the damage each one does drawn against
/// the standard axle. The damage is the question, so the bars wait.
class EsalPainter extends CustomPainter {
  const EsalPainter({required this.axles, this.answered = false});

  final List<Axle> axles;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 116.0;
    final right = size.width - 40;
    final biggest = axles.fold<double>(
        0.0001, (m, a) => math.max(m, a.factor));

    writeOn(canvas, size, 'damage done by one pass, against the standard',
        Offset(8, 8), AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'eighteen kip axle', Offset(8, 22), AppColors.ink3,
        fontSize: 9.5);

    var y = 46.0;
    for (final a in axles) {
      writeOn(
          canvas,
          size,
          '${a.name}, ${a.kips.toStringAsFixed(0)} kip',
          Offset(8, y),
          AppColors.ink3,
          fontSize: 9.5);
      if (answered) {
        final w = math.max(a.factor / biggest * (right - left), 1.5);
        canvas.drawRect(Rect.fromLTWH(left, y - 1, w, 12),
            Paint()..color = AppColors.ember.withValues(alpha: 0.55));
        writeOn(
            canvas,
            size,
            a.factor < 0.01
                ? a.factor.toStringAsFixed(4)
                : a.factor.toStringAsFixed(2),
            Offset(left + w + 6, y - 2),
            AppColors.ember,
            fontSize: 9.5);
      } else {
        canvas.drawRect(
            Rect.fromLTWH(left, y - 1, right - left, 12),
            Paint()
              ..color = AppColors.line
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      }
      y += 26;
    }

    if (!answered) {
      writeOn(canvas, size, 'how much damage each one does comes out',
          Offset(8, y + 4), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(8, y + 18),
          AppColors.ink3, fontSize: 9.5);
      return;
    }

    final counted = axles.where((a) => a.passes > 1);
    if (counted.isNotEmpty) {
      final a = counted.first;
      writeOn(
          canvas,
          size,
          '${a.passes.toStringAsFixed(0)} passes of the '
              '${a.kips.toStringAsFixed(0)} kip axle is '
              '${a.esals.toStringAsFixed(0)} standard loads',
          Offset(8, y + 4),
          AppColors.charcoal,
          fontSize: 9.5);
    }
  }

  @override
  bool shouldRepaint(EsalPainter old) =>
      old.axles != axles || old.answered != answered;
}
