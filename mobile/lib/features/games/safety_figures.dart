import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// What has to be done about a hole in the ground, by its depth.
enum Protection { none, anySystem, engineerDesigned }

/// A trench on a site, and what the rules ask for at that depth.
@immutable
class Trench {
  const Trench({required this.depth, this.protected = false});

  /// Feet.
  final double depth;

  /// Whether a protective system is actually in place.
  final bool protected;

  Protection get required_ {
    if (depth > 20) return Protection.engineerDesigned;
    if (depth > 5) return Protection.anySystem;
    return Protection.none;
  }

  bool get violation =>
      required_ != Protection.none && !protected;
}

/// A worker at a height, and whether fall protection is required.
@immutable
class Working {
  const Working({required this.height, this.steelConnector = false});

  /// Feet above the level below.
  final double height;

  /// Steel erection connectors have their own, higher, trigger.
  final bool steelConnector;

  double get trigger => steelConnector ? 15 : 6;
  bool get needsProtection => height >= trigger;
}

/// The trench in section with a depth scale beside it, and the two
/// thresholds marked once the round is answered.
class TrenchPainter extends CustomPainter {
  const TrenchPainter({required this.trench, this.answered = false});

  final Trench trench;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final ground = 34.0;
    final bottom = size.height - 34;
    const scaleTop = 25.0;
    final perFoot = (bottom - ground) / math.max(trench.depth, 1) *
        math.min(trench.depth / 24, 1);
    final deep = math.min(trench.depth * perFoot, bottom - ground);
    final left = size.width * 0.30;
    final right = size.width * 0.62;

    // The ground and the hole in it.
    canvas
      ..drawRect(Rect.fromLTRB(10, ground, left, bottom + 10),
          Paint()..color = AppColors.ink2.withValues(alpha: 0.35))
      ..drawRect(Rect.fromLTRB(right, ground, size.width - 10, bottom + 10),
          Paint()..color = AppColors.ink2.withValues(alpha: 0.35));
    groundLine(canvas, Offset(10, ground), Offset(left, ground));
    groundLine(canvas, Offset(right, ground), Offset(size.width - 10, ground));
    canvas.drawLine(
        Offset(left, ground + deep),
        Offset(right, ground + deep),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 1.6);

    if (trench.protected) {
      for (final x in [left + 3, right - 6]) {
        canvas.drawRect(
            Rect.fromLTWH(x, ground + 2, 3, deep - 4),
            Paint()..color = AppColors.forest.withValues(alpha: 0.8));
      }
      writeOn(canvas, size, 'shored', Offset(left + 8, ground + 6),
          AppColors.forest, fontSize: 9.5);
    }

    // A depth scale down the left hand side.
    canvas.drawLine(
        Offset(22, ground),
        Offset(22, ground + deep),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1.2);
    writeOn(
        canvas,
        size,
        '${trench.depth.toStringAsFixed(0)} ft deep',
        Offset(6, scaleTop - 18),
        AppColors.charcoal,
        fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'what the rules ask for comes out',
          Offset(10, size.height - 28), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(10, size.height - 14),
          AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.section, note: 'the trench');
      return;
    }

    // The two depths that change what is required.
    for (final (at, label) in [(5.0, 'five feet'), (20.0, 'twenty feet')]) {
      if (at > trench.depth) continue;
      final y = ground + at * perFoot;
      for (var x = 14.0; x < size.width - 12; x += 9) {
        canvas.drawLine(
            Offset(x, y),
            Offset(x + 5, y),
            Paint()
              ..color = AppColors.error
              ..strokeWidth = 1.2);
      }
      writeOn(canvas, size, label, Offset(size.width - 74, y - 13),
          AppColors.error, fontSize: 9.5);
    }

    writeOn(
        canvas,
        size,
        switch (trench.required_) {
          Protection.none => 'under five feet: no system required',
          Protection.anySystem =>
            'over five feet: sloping, shoring or a trench box',
          Protection.engineerDesigned =>
            'over twenty feet: an engineer has to design the system',
        },
        Offset(10, size.height - 28),
        AppColors.charcoal,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        trench.violation
            ? 'and there is nothing in this one: a violation'
            : 'and this one has what it needs',
        Offset(10, size.height - 14),
        trench.violation ? AppColors.error : AppColors.forest,
        fontSize: 9.5);

    viewTag(canvas, size, Looking.section, note: 'the trench');
  }

  @override
  bool shouldRepaint(TrenchPainter old) =>
      old.trench != trench || old.answered != answered;
}

/// A worker on a platform with the trigger height marked once the round is
/// answered.
class HeightPainter extends CustomPainter {
  const HeightPainter({required this.work, this.answered = false});

  final Working work;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height - 42;
    final top = 40.0;
    final tallest = math.max(work.height, work.trigger) * 1.25;
    double yOf(double feet) =>
        groundY - feet / tallest * (groundY - top);

    canvas.drawLine(
        Offset(12, groundY),
        Offset(size.width - 12, groundY),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2);

    // The platform and the worker on it.
    final deck = yOf(work.height);
    canvas
      ..drawRect(Rect.fromLTRB(size.width * 0.42, deck, size.width - 24,
          deck + 6), Paint()..color = AppColors.charcoal.withValues(alpha: 0.7))
      ..drawRect(
          Rect.fromLTWH(size.width * 0.58, deck - 18, 9, 18),
          Paint()..color = AppColors.charcoal.withValues(alpha: 0.85));
    writeOn(
        canvas,
        size,
        '${work.height.toStringAsFixed(0)} ft up'
            '${work.steelConnector ? ', connecting steel' : ''}',
        Offset(size.width * 0.42, deck - 34),
        AppColors.charcoal,
        fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'whether anything is required comes out',
          Offset(10, size.height - 28), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(10, size.height - 14),
          AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.elevation, note: 'the work');
      return;
    }

    final y = yOf(work.trigger);
    for (var x = 14.0; x < size.width - 12; x += 9) {
      canvas.drawLine(
          Offset(x, y),
          Offset(x + 5, y),
          Paint()
            ..color = AppColors.error
            ..strokeWidth = 1.2);
    }
    writeOn(
        canvas,
        size,
        '${work.trigger.toStringAsFixed(0)} ft, where protection starts',
        Offset(12, y - 13),
        AppColors.error,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        work.needsProtection
            ? 'guardrails, a net or a harness are required here'
            : 'below the trigger: nothing is required by the rule',
        Offset(10, size.height - 14),
        work.needsProtection ? AppColors.error : AppColors.forest,
        fontSize: 9.5);

    viewTag(canvas, size, Looking.elevation, note: 'the work');
  }

  @override
  bool shouldRepaint(HeightPainter old) =>
      old.work != work || old.answered != answered;
}
