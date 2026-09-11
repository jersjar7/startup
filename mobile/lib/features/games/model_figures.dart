import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Which of the two similitude numbers a test has to match.
enum Law { froude, reynolds, either }

extension LawWords on Law {
  String get plain => switch (this) {
        Law.froude => 'Match the Froude number',
        Law.reynolds => 'Match the Reynolds number',
        Law.either => 'Either one: both ask the same here',
      };
}

/// What the test looks like, which is the evidence for which law governs it.
/// A free water surface means gravity is shaping the flow and Froude
/// governs. No free surface means it is not, and viscosity is what is left.
enum Bench { openChannel, closedPipe, submerged, tunnel }

extension BenchWords on Bench {
  bool get hasSurface => this == Bench.openChannel;
}

/// The test rig, drawn as a section with the water, the air and the solid
/// parts each drawn as what they are. Nothing here is a bare line: concrete
/// and steel are hatched, ground carries its ticks, and every water surface
/// carries the level mark, because the whole question is whether there IS a
/// free surface.
class BenchPainter extends CustomPainter {
  const BenchPainter({required this.bench, required this.caption});

  final Bench bench;
  final String caption;

  @override
  void paint(Canvas canvas, Size size) {
    final solid = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final left = 16.0;
    final right = size.width - 16;
    final floor = size.height - 26;

    switch (bench) {
      case Bench.openChannel:
        // A spillway cut through the middle: pool, crest, chute, apron. The
        // concrete is a hatched body sitting on the ground, the water is
        // fill with a level mark on it, and what is left above is air.
        final crestX = size.width * 0.42;
        final crestY = 52.0;
        final toeX = size.width * 0.70;
        final apronY = floor - 14;
        final dam = Path()
          ..moveTo(size.width * 0.30, floor)
          ..lineTo(size.width * 0.30, crestY + 6)
          ..quadraticBezierTo(crestX - 12, crestY - 4, crestX, crestY)
          ..quadraticBezierTo(crestX + 16, crestY + 6, toeX, apronY)
          ..lineTo(right, apronY)
          ..lineTo(right, floor)
          ..close();
        // The pool behind it, and the sheet of water over the crest.
        final poolTop = crestY - 12;
        canvas.drawRect(
            Rect.fromLTRB(left, poolTop, size.width * 0.30, floor), waterFill);
        final nappe = Path()
          ..moveTo(size.width * 0.30, poolTop)
          ..quadraticBezierTo(crestX - 12, crestY - 15, crestX, crestY - 9)
          ..quadraticBezierTo(crestX + 18, crestY - 1, toeX, apronY - 7)
          ..lineTo(right, apronY - 9)
          ..lineTo(right, apronY)
          ..lineTo(toeX, apronY)
          ..quadraticBezierTo(crestX + 16, crestY + 6, crestX, crestY)
          ..quadraticBezierTo(crestX - 12, crestY - 4, size.width * 0.30,
              crestY + 6)
          ..close();
        canvas
          ..drawPath(nappe, waterFill)
          ..drawPath(dam, Paint()..color = AppColors.cream);
        hatchIn(canvas, dam);
        canvas.drawPath(dam, solid);
        waterLevel(canvas, Offset(left, poolTop),
            Offset(size.width * 0.30, poolTop),
            markAt: size.width * 0.30 - 22);
        waterLevel(canvas, Offset(toeX + 10, apronY - 9), Offset(right, apronY - 9),
            markAt: right - 26);
        groundLine(canvas, Offset(left, floor), Offset(right, floor));
        // The air label goes over the empty sky above the crest, clear of
        // the water label on the pool side.
        writeOn(canvas, size, 'air', Offset(crestX + 30, 14), AppColors.ink3);
        writeOn(canvas, size, 'water, open to the air',
            Offset(left + 6, poolTop - 16), AppColors.info);
        writeOn(canvas, size, 'concrete', Offset(size.width * 0.34, floor - 26),
            AppColors.ink2);
        viewTag(canvas, size, Looking.section);
      case Bench.closedPipe:
        // A length of pipe cut open with a valve in it. The wall is a
        // hatched band on each side, so it reads as steel; the bore is full
        // of water from wall to wall and there is no surface anywhere.
        final middle = (floor + 20) / 2 + 6;
        const bore = 24.0;
        const wall = 7.0;
        final top = Path()
          ..addRect(
              Rect.fromLTRB(left, middle - bore - wall, right, middle - bore));
        final bottom = Path()
          ..addRect(
              Rect.fromLTRB(left, middle + bore, right, middle + bore + wall));
        canvas.drawRect(
            Rect.fromLTRB(left, middle - bore, right, middle + bore),
            waterFill);
        hatchIn(canvas, top, step: 6);
        hatchIn(canvas, bottom, step: 6);
        canvas
          ..drawPath(top, solid)
          ..drawPath(bottom, solid);
        // The valve: a disc across the bore on a stem through the bonnet.
        final vx = size.width * 0.52;
        final disc = Path()
          ..addRRect(RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(vx, middle), width: 9, height: bore * 1.7),
              const Radius.circular(2)));
        final stem = Path()
          ..addRect(Rect.fromLTRB(vx - 3, middle - bore - wall - 16,
              vx + 3, middle - bore - wall));
        hatchIn(canvas, disc, step: 5);
        hatchIn(canvas, stem, step: 5);
        canvas
          ..drawPath(disc, solid)
          ..drawPath(stem, solid)
          ..drawLine(Offset(vx - 11, middle - bore - wall - 16),
              Offset(vx + 11, middle - bore - wall - 16), solid);
        writeOn(canvas, size, 'valve', Offset(vx + 14, middle - bore - wall - 20),
            AppColors.ink2);
        writeOn(canvas, size, 'water, wall to wall',
            Offset(left + 6, middle - 6), AppColors.info);
        writeOn(canvas, size, 'steel', Offset(left + 6, middle - bore - wall - 14),
            AppColors.ink2);
        viewTag(canvas, size, Looking.section, note: 'no free surface');
      case Bench.submerged:
        // A pipeline on the sea bed. There IS a surface in this one, and it
        // is drawn, because the point is that the pipe is nowhere near it.
        // The bed gets a deeper band than the other rigs so that its label
        // sits in it rather than on the caption underneath.
        final surface = 34.0;
        final bedTop = floor - 10;
        canvas.drawRect(
            Rect.fromLTRB(left, surface, right, bedTop), waterFill);
        waterLevel(canvas, Offset(left, surface), Offset(right, surface),
            markAt: left + 40);
        final bed = Path()
          ..moveTo(left, bedTop)
          ..lineTo(right, bedTop)
          ..lineTo(right, size.height)
          ..lineTo(left, size.height)
          ..close();
        hatchIn(canvas, bed, step: 6);
        groundLine(canvas, Offset(left, bedTop), Offset(right, bedTop));
        final pipe = Path()
          ..addOval(Rect.fromCircle(
              center: Offset(size.width * 0.52, bedTop - 13), radius: 13));
        canvas
          ..drawPath(pipe, Paint()..color = AppColors.cream)
          ..drawPath(pipe, solid);
        hatchIn(canvas, pipe, step: 5);
        // The current going past it, well under the surface.
        for (var i = 0; i < 2; i++) {
          final y = surface + 20 + i * 16;
          final tip = Offset(size.width * 0.34, y);
          final ink = Paint()
            ..color = AppColors.info
            ..strokeWidth = 1.4;
          canvas
            ..drawLine(Offset(left + 8, y), tip, ink)
            ..drawLine(tip, tip - const Offset(7, 4), ink)
            ..drawLine(tip, tip - const Offset(7, -4), ink);
        }
        writeOn(canvas, size, 'current', Offset(left + 8, surface + 6),
            AppColors.info);
        writeOn(canvas, size, 'sea bed', Offset(right - 62, bedTop + 4),
            AppColors.ink2);
        viewTag(canvas, size, Looking.section, note: 'surface far off');
      case Bench.tunnel:
        // A wind tunnel working section, cut through. Air in it, no liquid
        // at all, so there is no surface to get right.
        final middle = (floor + 20) / 2 + 4;
        const half = 34.0;
        final top = Path()
          ..addRect(Rect.fromLTRB(left, middle - half - 8, right, middle - half));
        final bottom = Path()
          ..addRect(Rect.fromLTRB(left, middle + half, right, middle + half + 8));
        hatchIn(canvas, top, step: 6);
        hatchIn(canvas, bottom, step: 6);
        canvas
          ..drawPath(top, solid)
          ..drawPath(bottom, solid);
        // The deck section on its mount, drawn as a deck: a shallow box
        // with tapered noses.
        final cx = size.width * 0.54;
        final deck = Path()
          ..moveTo(cx - 46, middle)
          ..lineTo(cx - 32, middle - 8)
          ..lineTo(cx + 32, middle - 8)
          ..lineTo(cx + 46, middle)
          ..lineTo(cx + 32, middle + 8)
          ..lineTo(cx - 32, middle + 8)
          ..close();
        canvas.drawPath(deck, Paint()..color = AppColors.cream);
        hatchIn(canvas, deck, step: 5);
        canvas
          ..drawPath(deck, solid)
          ..drawLine(Offset(cx, middle + 8), Offset(cx, middle + half),
              Paint()
                ..color = AppColors.ink3
                ..strokeWidth = 1.2);
        // Moving air, shown as streamlines rather than as water.
        for (var i = 0; i < 3; i++) {
          final y = middle - 24 + i * 24;
          final tip = Offset(size.width * 0.30, y);
          final ink = Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1.2;
          canvas
            ..drawLine(Offset(left + 8, y), tip, ink)
            ..drawLine(tip, tip - const Offset(6, 3.5), ink)
            ..drawLine(tip, tip - const Offset(6, -3.5), ink);
        }
        writeOn(canvas, size, 'air', Offset(left + 8, middle - half + 4),
            AppColors.ink3);
        writeOn(canvas, size, 'deck section', Offset(cx + 4, middle + 16),
            AppColors.ink2);
        viewTag(canvas, size, Looking.section, note: 'no liquid at all');
    }

    writeOn(canvas, size, caption, Offset(16, size.height - 13),
        AppColors.ink3);
  }

  @override
  bool shouldRepaint(BenchPainter old) =>
      old.bench != bench || old.caption != caption;
}

/// A model beside the thing it stands for, and what matching one number or
/// the other asks of the model's speed.
@immutable
class Twins {
  const Twins({required this.law, required this.model, required this.proto});

  /// Which number the test is being run to match. Never `either` here: this
  /// is about what a named law asks for.
  final Law law;

  /// The two sizes, in whatever unit: only their ratio matters.
  final double model;
  final double proto;

  /// The model speed over the prototype speed, in the same fluid. Froude
  /// scales as the square root of the length ratio; Reynolds scales as its
  /// inverse, which is why a small Reynolds model has to run so fast.
  double get ratio => law == Law.froude
      ? math.sqrt(model / proto)
      : proto / model;
}

/// The two of them side by side, drawn to the scale that is claimed.
class TwinsPainter extends CustomPainter {
  const TwinsPainter({required this.twins});

  final Twins twins;

  @override
  void paint(Canvas canvas, Size size) {
    final biggest = math.max(twins.model, twins.proto);
    final middle = size.height * 0.56;
    final body = Paint()..color = AppColors.info.withValues(alpha: 0.35);
    final edge = Paint()
      ..color = AppColors.charcoal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Both stand on the same line, which is what makes the two sizes
    // comparable at a glance.
    groundLine(canvas, Offset(16, middle + 2), Offset(size.width - 16, middle + 2),
        color: AppColors.line.withValues(alpha: 0.9));

    void block(double centerX, double share, String title, String below) {
      // Nothing is drawn smaller than a few pixels, or a hundred to one
      // would be a speck with a label under it.
      final wide = math.max(10.0, 118 * share);
      final tall = math.max(7.0, 42 * share);
      final rect = Rect.fromLTWH(
          centerX - wide / 2, middle - tall, wide, tall);
      canvas
        ..drawRect(rect, body)
        ..drawRect(rect, edge);
      writeOn(canvas, size, title, Offset(centerX - 26, 10),
          AppColors.charcoal);
      writeOn(canvas, size, below, Offset(centerX - 30, middle + 12),
          AppColors.ink3);
    }

    block(size.width * 0.29, twins.proto / biggest, 'the real thing',
        '${_num(twins.proto)} across');
    block(size.width * 0.72, twins.model / biggest, 'the model',
        '${_num(twins.model)} across');
    writeOn(canvas, size, 'both drawn to one scale',
        Offset(16, size.height - 14), AppColors.ink3);
  }

  @override
  bool shouldRepaint(TwinsPainter old) => old.twins != twins;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
