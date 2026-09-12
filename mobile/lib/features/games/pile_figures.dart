import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Which of a pile's two resistances is doing most of the work.
enum Carry { tip, shaft, even }

/// A pile and the two ways it holds a load up: bearing at the tip and
/// friction along the shaft. Each has its own unit resistance and its own
/// area, and mixing those up is the lesson's named trap.
@immutable
class Pile {
  const Pile({
    required this.tipResistance,
    required this.tipArea,
    required this.skinFriction,
    required this.shaftArea,
  });

  /// Kilopascals and square meters.
  final double tipResistance;
  final double tipArea;
  final double skinFriction;
  final double shaftArea;

  /// Kilonewtons.
  double get endBearing => tipResistance * tipArea;
  double get shaftResistance => skinFriction * shaftArea;
  double get ultimate => endBearing + shaftResistance;

  double get shaftShare => shaftResistance / ultimate;

  Carry get carries {
    if (shaftShare > 0.65) return Carry.shaft;
    if (shaftShare < 0.35) return Carry.tip;
    return Carry.even;
  }
}

/// A pile in section with its two resistances drawn as arrows: friction
/// along the shaft, bearing under the tip. Which one is larger is the
/// question in several rounds, so the arrows are all one size until the
/// answer is in, and only then do the numbers appear.
class PilePainter extends CustomPainter {
  const PilePainter({
    required this.pile,
    this.downdrag = false,
    this.showResistances = true,
    this.showDirection = true,
    this.bearsOnRock = false,
    this.answered = false,
  });

  final Pile pile;

  /// When the soil around the shaft settles more than the pile, the shaft
  /// friction turns round and hangs on it instead of holding it up.
  final bool downdrag;

  /// Whether a pile holds a load up in one place or two is itself a round,
  /// so that round draws the pile with nothing on it.
  final bool showResistances;

  /// Which way the friction acts is the whole question in one item, so that
  /// item keeps the arrowheads off until the round is answered.
  final bool showDirection;

  /// Draws rock under the tip rather than more soil.
  final bool bearsOnRock;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width * 0.44;
    final top = 30.0;
    final tip = size.height - 52;
    final ground = top + 8;

    // The ground, and rock under the tip if the round has any.
    canvas.drawRect(
        Rect.fromLTRB(10, ground, size.width - 10, tip + 14),
        Paint()..color = AppColors.ink2.withValues(alpha: 0.18));
    groundLine(canvas, Offset(10, ground), Offset(size.width - 10, ground));
    if (bearsOnRock) {
      final rock = Rect.fromLTRB(10, tip, size.width - 10, tip + 24);
      canvas.drawRect(
          rock, Paint()..color = AppColors.charcoal.withValues(alpha: 0.30));
      hatchIn(canvas, Path()..addRect(rock), color: AppColors.charcoal);
      writeOn(canvas, size, 'rock', Offset(14, tip + 10), AppColors.ink3,
          fontSize: 9.5);
    }

    // The pile.
    canvas.drawRect(Rect.fromLTRB(x - 7, top, x + 7, tip),
        Paint()..color = AppColors.charcoal.withValues(alpha: 0.8));

    if (!showResistances) {
      writeOn(canvas, size, 'where it gets its hold comes out\nafter the '
          'answer', Offset(10, ground + 30), AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.section, note: 'the pile');
      return;
    }

    // Friction along the shaft. Up when it is holding the pile, down when
    // the ground is settling past it.
    final rub = downdrag ? AppColors.error : AppColors.info;
    for (var y = ground + 16.0; y < tip - 8; y += 22) {
      for (final side in [x - 13, x + 13]) {
        if (showDirection) {
          final from = downdrag ? y - 7 : y + 7;
          final to = downdrag ? y + 7 : y - 7;
          _arrow(canvas, Offset(side, from), Offset(side, to), rub);
        } else {
          // A plain rub mark: the surface is gripping, and which way it
          // pushes is what the round is asking.
          canvas.drawLine(
              Offset(side, y - 7),
              Offset(side, y + 7),
              Paint()
                ..color = AppColors.ink3
                ..strokeWidth = 1.8);
        }
      }
    }
    writeOn(
        canvas,
        size,
        showDirection
            ? (downdrag
                ? 'the ground settles past it'
                : 'friction along the shaft')
            : 'the shaft grips the soil',
        Offset(x + 22, ground + 14),
        showDirection ? rub : AppColors.ink3,
        fontSize: 9.5);

    // Bearing under the tip, which always pushes up.
    _arrow(canvas, Offset(x, tip + 16), Offset(x, tip + 2), AppColors.forest);
    writeOn(canvas, size, 'bearing under the tip', Offset(x + 22, tip - 6),
        AppColors.forest, fontSize: 9.5);

    if (!answered) {
      writeOn(
          canvas,
          size,
          showDirection
              ? 'the two numbers come out\nafter the answer'
              : 'which way it rubs comes out\nafter the answer',
          Offset(10, ground + 30),
          AppColors.ink3,
          fontSize: 9.5);
      viewTag(canvas, size, Looking.section, note: 'the pile');
      return;
    }

    writeOn(
        canvas,
        size,
        'shaft ${pile.shaftResistance.toStringAsFixed(0)} kN',
        Offset(10, ground + 30),
        AppColors.info,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'tip ${pile.endBearing.toStringAsFixed(0)} kN',
        Offset(10, tip - 22),
        AppColors.forest,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        downdrag
            ? 'the drag is a LOAD, not a resistance'
            : 'together ${pile.ultimate.toStringAsFixed(0)} kN',
        Offset(10, size.height - 16),
        downdrag ? AppColors.error : AppColors.charcoal,
        fontSize: 9.5);

    viewTag(canvas, size, Looking.section, note: 'the pile');
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8;
    canvas.drawLine(from, to, paint);
    final dir = to.dy > from.dy ? 1.0 : -1.0;
    canvas.drawPath(
        Path()
          ..moveTo(to.dx, to.dy)
          ..lineTo(to.dx - 3.5, to.dy - 5 * dir)
          ..lineTo(to.dx + 3.5, to.dy - 5 * dir)
          ..close(),
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(PilePainter old) =>
      old.pile != pile ||
      old.downdrag != downdrag ||
      old.showDirection != showDirection ||
      old.bearsOnRock != bearsOnRock ||
      old.answered != answered;
}

/// Soft ground over firm ground, with either a footing on top of it or
/// piles through it. What the load does to the soft layer is the point, so
/// the settlement and the stressed zone are drawn once the round is over.
class DepthPainter extends CustomPainter {
  const DepthPainter({
    this.piles = 1,
    this.onFooting = false,
    this.answered = false,
  });

  /// How many piles to draw. More than one makes it a group.
  final int piles;

  /// Draws a shallow footing on the soft layer instead.
  final bool onFooting;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final top = 34.0;
    final firm = size.height * 0.66;
    final bottom = size.height - 26;

    canvas
      ..drawRect(Rect.fromLTRB(10, top, size.width - 10, firm),
          Paint()..color = AppColors.ink2.withValues(alpha: 0.16))
      ..drawRect(Rect.fromLTRB(10, firm, size.width - 10, bottom),
          Paint()..color = AppColors.ink2.withValues(alpha: 0.40));
    groundLine(canvas, Offset(10, top), Offset(size.width - 10, top));
    writeOn(canvas, size, 'soft clay', Offset(14, top + 6), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, 'dense gravel', Offset(14, firm + 6), AppColors.ink3,
        fontSize: 9.5);

    final middle = size.width * 0.52;
    if (onFooting) {
      canvas.drawRect(Rect.fromLTRB(middle - 34, top - 12, middle + 34, top),
          Paint()..color = AppColors.charcoal.withValues(alpha: 0.8));
      writeOn(canvas, size, 'a footing', Offset(middle - 30, top - 26),
          AppColors.charcoal, fontSize: 9.5);
    } else {
      final spread = piles == 1 ? 0.0 : 26.0;
      for (var i = 0; i < piles; i++) {
        final x = middle + (i - (piles - 1) / 2) * spread;
        canvas.drawRect(Rect.fromLTRB(x - 5, top - 10, x + 5, firm + 22),
            Paint()..color = AppColors.charcoal.withValues(alpha: 0.8));
      }
      if (piles > 1) {
        canvas.drawRect(
            Rect.fromLTRB(middle - spread * piles / 2 - 8, top - 18,
                middle + spread * piles / 2 + 8, top - 8),
            Paint()..color = AppColors.charcoal.withValues(alpha: 0.8));
        writeOn(canvas, size, 'one cap, several piles',
            Offset(middle - 50, top - 32), AppColors.charcoal, fontSize: 9.5);
      } else {
        writeOn(canvas, size, 'one pile', Offset(middle - 20, top - 24),
            AppColors.charcoal, fontSize: 9.5);
      }
    }

    if (!answered) {
      writeOn(canvas, size, 'what the load reaches comes out\nafter the '
          'answer', Offset(14, top + 22), AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.section, note: 'the ground');
      return;
    }

    // Where the load actually goes.
    if (onFooting) {
      final zone = Path()
        ..moveTo(middle - 34, top)
        ..lineTo(middle + 34, top)
        ..lineTo(middle + 58, firm - 6)
        ..lineTo(middle - 58, firm - 6)
        ..close();
      canvas.drawPath(
          zone, Paint()..color = AppColors.error.withValues(alpha: 0.18));
      writeOn(canvas, size, 'all of it into the soft layer',
          Offset(10, size.height - 14), AppColors.error, fontSize: 9.5);
    } else {
      final half = piles == 1 ? 26.0 : 26.0 * piles;
      final zone = Path()
        ..moveTo(middle - half * 0.5, firm + 10)
        ..lineTo(middle + half * 0.5, firm + 10)
        ..lineTo(middle + half, math.min(bottom, firm + 10 + half))
        ..lineTo(middle - half, math.min(bottom, firm + 10 + half))
        ..close();
      canvas.drawPath(
          zone, Paint()..color = AppColors.forest.withValues(alpha: 0.20));
      writeOn(
          canvas,
          size,
          piles == 1
              ? 'down to the gravel, past the soft layer'
              : 'one wide zone, and it reaches deeper',
          Offset(10, size.height - 14),
          AppColors.forest,
          fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'the ground');
  }

  @override
  bool shouldRepaint(DepthPainter old) =>
      old.piles != piles ||
      old.onFooting != onFooting ||
      old.answered != answered;
}
