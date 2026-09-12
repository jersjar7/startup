import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Which of the three settlement cases a layer is in, decided by where the
/// stresses sit against the pressure the clay remembers.
enum Case { recompression, normally, crossing }

/// A clay layer about to be loaded: what it carries now, what it remembers
/// carrying, and what is being added.
@immutable
class Squeeze {
  const Squeeze({
    required this.now,
    required this.remembered,
    required this.added,
    this.thickness = 10,
    this.voidRatio = 0.9,
    this.cc = 0.30,
    this.cr = 0.05,
  });

  /// All in pounds per square foot.
  final double now;
  final double remembered;
  final double added;

  final double thickness;
  final double voidRatio;
  final double cc;
  final double cr;

  double get after => now + added;

  /// A clay that has carried more in the past than it carries now is
  /// overconsolidated, and it is stiff until the load passes that memory.
  bool get overconsolidated => remembered > now + 0.001;

  Case get which {
    if (!overconsolidated) return Case.normally;
    return after <= remembered + 0.001 ? Case.recompression : Case.crossing;
  }

  /// Settlement in feet, by whichever of the three the layer is in.
  double get settlement {
    final scale = thickness / (1 + voidRatio);
    return switch (which) {
      Case.recompression => scale * cr * _log10(after / now),
      Case.normally => scale * cc * _log10(after / now),
      Case.crossing => scale *
          (cr * _log10(remembered / now) + cc * _log10(after / remembered)),
    };
  }

  static double _log10(double v) => math.log(v) / math.ln10;
}

/// The three pressures on one axis, which is all the case decision is: where
/// the load ends up against what the clay remembers.
class StressLinePainter extends CustomPainter {
  const StressLinePainter({required this.squeeze, this.answered = false});

  final Squeeze squeeze;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 34.0;
    final right = size.width - 34;
    final y = size.height * 0.52;
    final top = math.max(squeeze.after, squeeze.remembered) * 1.25;

    double xOf(double p) => left + p / top * (right - left);

    canvas.drawLine(
        Offset(left, y),
        Offset(right, y),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1.4);
    writeOn(canvas, size, 'effective stress, pounds per square foot',
        Offset(left - 8, size.height - 16), AppColors.ink3, fontSize: 9.5);

    // What the clay carries now, and where the load takes it.
    final a = xOf(squeeze.now);
    final b = xOf(squeeze.after);
    canvas.drawRect(
        Rect.fromLTRB(a, y - 9, b, y + 9),
        Paint()..color = AppColors.ember.withValues(alpha: 0.30));
    for (final (x, label, drop) in [
      (a, 'carries now ${squeeze.now.toStringAsFixed(0)}', -34.0),
      (b, 'after the load ${squeeze.after.toStringAsFixed(0)}', -20.0),
    ]) {
      canvas.drawLine(
          Offset(x, y - 12),
          Offset(x, y + 12),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 2);
      writeOn(canvas, size, label, Offset(x - 34, y + drop), AppColors.ember,
          fontSize: 9.5);
    }

    // What it remembers, which is the line the case turns on.
    final pc = xOf(squeeze.remembered);
    for (var t = y - 22.0; t < y + 22; t += 7) {
      canvas.drawLine(
          Offset(pc, t),
          Offset(pc, math.min(t + 4, y + 22)),
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 2);
    }
    writeOn(
        canvas,
        size,
        'remembers ${squeeze.remembered.toStringAsFixed(0)}',
        Offset(pc - 30, y + 26),
        AppColors.info,
        fontSize: 9.5);

    if (answered) {
      writeOn(
          canvas,
          size,
          'settles ${(squeeze.settlement * 12).toStringAsFixed(1)} inches',
          Offset(left, 10),
          AppColors.forest,
          fontSize: 9.5);
    }
  }

  @override
  bool shouldRepaint(StressLinePainter old) =>
      old.squeeze != squeeze || old.answered != answered;
}

/// The void ratio against the log of the stress: a shallow line while the
/// clay is only being pushed back to where it has been, and a steep one once
/// it is asked to go further than it ever has.
class ElogPPainter extends CustomPainter {
  const ElogPPainter({required this.squeeze, this.answered = false});

  final Squeeze squeeze;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 40.0;
    final right = size.width - 24;
    final top = 24.0;
    final bottom = size.height - 30;

    final from = squeeze.now / 2;
    final to = math.max(squeeze.after, squeeze.remembered) * 2.4;
    double xOf(double p) =>
        left +
        (math.log(p) - math.log(from)) /
            (math.log(to) - math.log(from)) *
            (right - left);

    // The void ratio drops as the stress rises, so the curve runs downhill.
    double yOf(double e) =>
        top + (squeeze.voidRatio + 0.12 - e) / 0.30 * (bottom - top);

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
    writeOn(canvas, size, 'void ratio', Offset(2, top - 14), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, 'stress, log scale', Offset(left + 6, bottom + 8),
        AppColors.ink3, fontSize: 9.5);

    // The flat recompression line up to what the clay remembers, then the
    // steep virgin line beyond it.
    final e0 = squeeze.voidRatio;
    final pc = squeeze.remembered;
    final eAtPc = e0 - squeeze.cr * Squeeze._log10(pc / squeeze.now);
    final ink = Paint()
      ..color = AppColors.ember
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas
      ..drawLine(Offset(xOf(from), yOf(e0 + squeeze.cr * Squeeze._log10(squeeze.now / from))),
          Offset(xOf(pc), yOf(eAtPc)), ink)
      ..drawLine(Offset(xOf(pc), yOf(eAtPc)),
          Offset(xOf(to), yOf(eAtPc - squeeze.cc * Squeeze._log10(to / pc))), ink);

    // Where the memory sits.
    for (var t = top; t < bottom; t += 7) {
      canvas.drawLine(
          Offset(xOf(pc), t),
          Offset(xOf(pc), math.min(t + 4, bottom)),
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 1.2);
    }
    writeOn(canvas, size, 'what it remembers', Offset(xOf(pc) - 30, top - 14),
        AppColors.info, fontSize: 9.5);

    if (answered) {
      writeOn(canvas, size, 'shallow: recompression',
          Offset(left + 4, yOf(e0) - 16), AppColors.forest, fontSize: 9.5);
      writeOn(canvas, size, 'steep: virgin compression',
          Offset(xOf(pc) + 6, yOf(eAtPc - squeeze.cc * 0.5) + 4),
          AppColors.forest, fontSize: 9.5);
    }
  }

  @override
  bool shouldRepaint(ElogPPainter old) =>
      old.squeeze != squeeze || old.answered != answered;
}

/// Where the squeezed-out water can get to. The drainage path is half the
/// layer when it can leave both ways and the whole of it when it cannot, and
/// the time goes as the square of it.
@immutable
class Drainage {
  const Drainage({
    required this.thickness,
    required this.topDrains,
    required this.bottomDrains,
  });

  /// Feet.
  final double thickness;
  final bool topDrains;
  final bool bottomDrains;

  bool get bothWays => topDrains && bottomDrains;

  double get path => bothWays ? thickness / 2 : thickness;

  /// How long this arrangement takes against two-way drainage of the same
  /// layer: four times as long when the water can only leave one way.
  double get timesLonger => bothWays ? 1 : 4;
}

/// The clay layer between its neighbors, with arrows where water can leave
/// and a hatched cap where it cannot.
class DrainagePainter extends CustomPainter {
  const DrainagePainter({required this.drain, this.answered = false});

  final Drainage drain;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.16;
    final right = size.width * 0.72;
    final top = size.height * 0.30;
    final bottom = size.height * 0.74;

    final clay = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(
        clay,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    hatchIn(canvas, Path()..addRect(clay), step: 8, color: AppColors.ink2);
    writeOn(canvas, size, 'clay, ${drain.thickness.toStringAsFixed(0)} ft',
        Offset(left + 8, (top + bottom) / 2 - 6), AppColors.ink3,
        fontSize: 9.5);

    for (final (edge, drains, name) in [
      (top, drain.topDrains, 'above'),
      (bottom, drain.bottomDrains, 'below'),
    ]) {
      final outward = edge == top ? -1.0 : 1.0;
      if (drains) {
        for (var x = left + 14; x < right; x += 26) {
          canvas
            ..drawLine(
                Offset(x, edge + outward * 4),
                Offset(x, edge + outward * 20),
                Paint()
                  ..color = AppColors.info
                  ..strokeWidth = 2)
            ..drawPath(
                Path()
                  ..moveTo(x, edge + outward * 26)
                  ..lineTo(x - 3.5, edge + outward * 18)
                  ..lineTo(x + 3.5, edge + outward * 18)
                  ..close(),
                Paint()..color = AppColors.info);
        }
        writeOn(canvas, size, 'sand $name: water gets out',
            Offset(right + 6, edge + outward * 14 - 6), AppColors.info,
            fontSize: 9.5);
      } else {
        final cap = Rect.fromLTRB(
            left, edge == top ? edge - 12 : edge, right,
            edge == top ? edge : edge + 12);
        canvas.drawRect(
            cap,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4);
        hatchIn(canvas, Path()..addRect(cap), step: 5, slope: -1);
        writeOn(canvas, size, 'rock $name: nothing gets out',
            Offset(right + 6, (cap.top + cap.bottom) / 2 - 6),
            AppColors.charcoal, fontSize: 9.5);
      }
    }

    if (answered) {
      writeOn(
          canvas,
          size,
          'drainage path ${drain.path.toStringAsFixed(0)} ft',
          Offset(left, bottom + 26),
          AppColors.forest,
          fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'the layer');
  }

  @override
  bool shouldRepaint(DrainagePainter old) =>
      old.drain != drain || old.answered != answered;
}
