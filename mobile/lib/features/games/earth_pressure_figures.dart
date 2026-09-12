import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Which way the wall has moved, which is what decides the coefficient.
enum WallState { active, atRest, passive }

/// A wall with soil behind it, and everything the Rankine theory says about
/// it worked out rather than quoted.
@immutable
class Backfill {
  const Backfill({
    required this.height,
    required this.unitWeight,
    required this.friction,
    this.surcharge = 0,
  });

  /// Feet, pounds per cubic foot, degrees.
  final double height;
  final double unitWeight;
  final double friction;

  /// A uniform load on the surface behind the wall, in pounds per square
  /// foot.
  final double surcharge;

  double get _phi => friction * math.pi / 180;

  double get ka => math.pow(math.tan(math.pi / 4 - _phi / 2), 2).toDouble();
  double get kp => math.pow(math.tan(math.pi / 4 + _phi / 2), 2).toDouble();
  double get k0 => 1 - math.sin(_phi);

  double coefficient(WallState push) => switch (push) {
        WallState.active => ka,
        WallState.atRest => k0,
        WallState.passive => kp,
      };

  /// The soil's own pressure grows with depth, so its force is triangular.
  double get soilForce => 0.5 * ka * unitWeight * height * height;

  /// A surcharge presses the same at every depth, so its force is a
  /// rectangle.
  double get surchargeForce => ka * surcharge * height;

  double get total => soilForce + surchargeForce;

  /// Where each resultant acts above the base.
  double get soilArm => height / 3;
  double get surchargeArm => height / 2;
}

/// The wall in section, with the pressure diagram beside it once the round
/// is answered. The shape of that diagram is the whole question in one of
/// the items, so it stays off the drawing until the answer is in.
///
/// Given a second backfill in [against], both walls are drawn to ONE scale,
/// so a wall twice as tall looks twice as tall.
class WallPainter extends CustomPainter {
  const WallPainter({
    required this.backfill,
    this.against,
    this.showSurcharge = true,
    this.answered = false,
  });

  final Backfill backfill;

  /// A second wall to set beside the first, at the same scale.
  final Backfill? against;

  /// Whether to draw the surcharge block, when the round has one.
  final bool showSurcharge;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height - 34;
    final tallest =
        math.max(backfill.height, against?.height ?? backfill.height);
    final headroom = 48.0;
    final perFoot = (base - headroom) / tallest;

    if (against == null) {
      _wall(canvas, size,
          soil: backfill,
          wallX: size.width * 0.34,
          base: base,
          perFoot: perFoot,
          room: size.width * 0.34 - 26,
          withDiagram: true);
    } else {
      // Two walls to one scale: the shorter on the left, so the taller one
      // reads as taller rather than as a relabelled copy.
      final short =
          backfill.height <= against!.height ? backfill : against!;
      final tall = backfill.height <= against!.height ? against! : backfill;
      _wall(canvas, size,
          soil: short,
          wallX: size.width * 0.30,
          base: base,
          perFoot: perFoot,
          room: 62,
          withDiagram: true);
      _wall(canvas, size,
          soil: tall,
          wallX: size.width * 0.78,
          base: base,
          perFoot: perFoot,
          room: 62,
          withDiagram: true);
    }

    canvas.drawLine(
        Offset(10, base),
        Offset(size.width - 14, base),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2);

    if (!answered) {
      writeOn(canvas, size, 'the pressure diagram comes out after the answer',
          Offset(10, base + 8), AppColors.ink3, fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'the wall');
  }

  /// One wall, its soil, and (once answered) its pressure diagram, drawn to
  /// the shared [perFoot] scale with [room] pixels for the diagram.
  void _wall(
    Canvas canvas,
    Size size, {
    required Backfill soil,
    required double wallX,
    required double base,
    required double perFoot,
    required double room,
    required bool withDiagram,
  }) {
    final top = base - soil.height * perFoot;
    final soilRight = against == null ? size.width - 14 : wallX + 54;

    canvas
      ..drawRect(
          Rect.fromLTRB(wallX - 9, top, wallX, base),
          Paint()..color = AppColors.charcoal.withValues(alpha: 0.75))
      ..drawRect(
          Rect.fromLTRB(wallX, top, soilRight, base),
          Paint()..color = AppColors.ink2.withValues(alpha: 0.20));
    groundLine(canvas, Offset(wallX, top), Offset(soilRight, top));

    writeOn(canvas, size, '${soil.height.toStringAsFixed(0)} ft of soil',
        Offset(wallX + 8, top + 8), AppColors.ink3, fontSize: 9.5);
    if (against == null) {
      writeOn(
          canvas,
          size,
          'friction ${soil.friction.toStringAsFixed(0)} degrees',
          Offset(wallX + 8, top + 22),
          AppColors.ink3,
          fontSize: 9.5);
    }

    // A surcharge on the surface.
    if (soil.surcharge > 0 && showSurcharge) {
      for (var x = wallX + 8; x < soilRight - 4; x += 20) {
        canvas.drawLine(
            Offset(x, top - 16),
            Offset(x, top - 3),
            Paint()
              ..color = AppColors.charcoal
              ..strokeWidth = 1.6);
      }
      writeOn(
          canvas,
          size,
          '${soil.surcharge.toStringAsFixed(0)} psf on the surface',
          Offset(wallX + 4, top - 30),
          AppColors.charcoal,
          fontSize: 9.5);
    }

    if (!answered || !withDiagram) return;

    // The pressure diagram, to the left of the wall: a triangle growing with
    // depth, and a rectangle for the surcharge if there is one. Both walls
    // in a comparison share one pressure scale as well, so four times the
    // force looks like four times the area.
    final soilAtBase = soil.ka * soil.unitWeight * soil.height;
    final fromSurcharge = soil.ka * soil.surcharge;
    final biggest = against == null
        ? soilAtBase + fromSurcharge
        : math.max(backfill.ka * backfill.unitWeight * backfill.height,
                against!.ka * against!.unitWeight * against!.height) +
            fromSurcharge;
    double wOf(double p) => biggest <= 0 ? 0 : p / biggest * room;

    final triangle = Path()
      ..moveTo(wallX - 10, top)
      ..lineTo(wallX - 10, base)
      ..lineTo(wallX - 10 - wOf(soilAtBase), base)
      ..close();
    canvas
      ..drawPath(
          triangle, Paint()..color = AppColors.ember.withValues(alpha: 0.35))
      ..drawPath(
          triangle,
          Paint()
            ..color = AppColors.ember
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);

    if (soil.surcharge > 0 && showSurcharge) {
      final block = Rect.fromLTRB(
          wallX - 10 - wOf(soilAtBase) - wOf(fromSurcharge),
          top,
          wallX - 10 - wOf(soilAtBase),
          base);
      canvas
        ..drawRect(
            block, Paint()..color = AppColors.info.withValues(alpha: 0.28))
        ..drawRect(
            block,
            Paint()
              ..color = AppColors.info
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4);
      writeOn(canvas, size, 'from the surcharge', Offset(6, top - 2),
          AppColors.info, fontSize: 9.5);
    }
    if (against == null) {
      writeOn(canvas, size, 'from the soil', Offset(6, base - 26),
          AppColors.ember, fontSize: 9.5);
    }

    // Where the soil resultant acts, and what the whole diagram comes to.
    final y = base - (base - top) / 3;
    canvas
      ..drawLine(
          Offset(wallX - 10 - wOf(soilAtBase) - 6, y),
          Offset(wallX - 12, y),
          Paint()
            ..color = AppColors.forest
            ..strokeWidth = 2.4)
      ..drawPath(
          Path()
            ..moveTo(wallX - 8, y)
            ..lineTo(wallX - 16, y - 4)
            ..lineTo(wallX - 16, y + 4)
            ..close(),
          Paint()..color = AppColors.forest);
    if (against == null) {
      writeOn(canvas, size, 'a third of the way up', Offset(6, y - 14),
          AppColors.forest, fontSize: 9.5);
    }
    writeOn(
        canvas,
        size,
        '${soil.total.toStringAsFixed(0)} lb per foot',
        Offset(wallX + 8, base - 16),
        AppColors.forest,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(WallPainter old) =>
      old.backfill != backfill ||
      old.against != against ||
      old.showSurcharge != showSurcharge ||
      old.answered != answered;
}

/// The three states on one scale. Before the answer each row shows what the
/// WALL did, which is the thing being asked about, and the coefficients
/// themselves stay off the drawing. After it, the three bars come out, and
/// their order and their sizes can be seen rather than remembered.
class CoefficientPainter extends CustomPainter {
  const CoefficientPainter({required this.backfill, this.answered = false});

  final Backfill backfill;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 96.0;
    final wide = size.width - left - 48;
    final top = math.max(backfill.kp, 1) * 1.1;

    writeOn(
        canvas,
        size,
        'a soil with ${backfill.friction.toStringAsFixed(0)} degrees of '
            'friction',
        const Offset(8, 6),
        AppColors.ink3,
        fontSize: 9.5);

    var y = 30.0;
    for (final (name, push) in [
      ('active', WallState.active),
      ('at rest', WallState.atRest),
      ('passive', WallState.passive),
    ]) {
      writeOn(canvas, size, name, Offset(8, y - 1), AppColors.ink3,
          fontSize: 9.5);
      if (answered) {
        final v = backfill.coefficient(push);
        final length = v / top * wide;
        canvas.drawRect(Rect.fromLTWH(left, y, math.max(length, 1), 12),
            Paint()..color = AppColors.ember.withValues(alpha: 0.6));
        writeOn(canvas, size, v.toStringAsFixed(2),
            Offset(left + length + 6, y - 1), AppColors.ember, fontSize: 9.5);
      } else {
        _whatTheWallDid(canvas, size, push, Offset(left, y + 6));
      }
      y += 26;
    }

    if (!answered) {
      writeOn(canvas, size, 'the three sizes come out after the answer',
          Offset(8, y + 4), AppColors.ink3, fontSize: 9.5);
    }
  }

  /// A wall in section, a few pixels tall, with the movement that puts the
  /// soil into this state. It says nothing about which coefficient is which
  /// size, only what the wall is doing.
  void _whatTheWallDid(
      Canvas canvas, Size size, WallState push, Offset at) {
    final ink = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.6;
    final wallTop = at.dy - 9;
    final wallBase = at.dy + 7;

    // The soil is always on the right of the wall.
    canvas
      ..drawLine(Offset(at.dx, wallTop), Offset(at.dx, wallBase), ink)
      ..drawRect(Rect.fromLTRB(at.dx + 2, wallTop, at.dx + 26, wallBase),
          Paint()..color = AppColors.ink2.withValues(alpha: 0.20));

    void arrow(double from, double to) {
      final dir = to > from ? 1.0 : -1.0;
      canvas
        ..drawLine(Offset(from, at.dy - 1), Offset(to, at.dy - 1), ink)
        ..drawPath(
            Path()
              ..moveTo(to, at.dy - 1)
              ..lineTo(to - 5 * dir, at.dy - 4)
              ..lineTo(to - 5 * dir, at.dy + 2)
              ..close(),
            Paint()..color = AppColors.ink3);
    }

    switch (push) {
      case WallState.active:
        arrow(at.dx - 4, at.dx - 22);
        writeOn(canvas, size, 'the wall leans away', Offset(at.dx + 34, at.dy - 6),
            AppColors.ink3, fontSize: 9.5);
      case WallState.atRest:
        // Props top and bottom: the wall is not going anywhere.
        canvas
          ..drawLine(Offset(at.dx - 14, wallTop), Offset(at.dx, wallTop), ink)
          ..drawLine(
              Offset(at.dx - 14, wallBase), Offset(at.dx, wallBase), ink)
          ..drawLine(Offset(at.dx - 14, wallTop - 3),
              Offset(at.dx - 14, wallBase + 3), ink);
        writeOn(canvas, size, 'held, it cannot move',
            Offset(at.dx + 34, at.dy - 6), AppColors.ink3, fontSize: 9.5);
      case WallState.passive:
        arrow(at.dx - 22, at.dx - 4);
        writeOn(canvas, size, 'the wall is pushed in',
            Offset(at.dx + 34, at.dy - 6), AppColors.ink3, fontSize: 9.5);
    }
  }

  @override
  bool shouldRepaint(CoefficientPainter old) =>
      old.backfill != backfill || old.answered != answered;
}
