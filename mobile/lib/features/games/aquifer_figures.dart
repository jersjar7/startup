import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Water moving through soil, described the three ways this lesson keeps
/// apart: how much goes through, how fast it would be going if the soil
/// were not there, and how fast it is actually going in the pores.
@immutable
class Seep {
  const Seep({
    required this.conductivity,
    required this.gradient,
    required this.porosity,
    required this.area,
  });

  /// K, in meters a second.
  final double conductivity;

  /// The slope of the water table, dimensionless.
  final double gradient;

  /// The fraction of the soil that is void and can carry water.
  final double porosity;

  /// The whole cross-section, pores and grains together, in square meters.
  final double area;

  /// The Darcy velocity: flow spread over the WHOLE face as if the grains
  /// were not in the way. Nothing actually moves at this speed.
  double get darcy => conductivity * gradient;

  /// What a tracer would do: the water is squeezed through the voids only,
  /// so it has to move faster. Always larger than the Darcy velocity.
  double get seepage => darcy / porosity;

  /// The volume passing, which is a flow and not a speed at all.
  double get flow => darcy * area;
}

/// A block of the aquifer with the grains drawn in, so that the difference
/// between the whole face and the part of it water can use is a picture
/// rather than a claim.
class SoilPainter extends CustomPainter {
  const SoilPainter({required this.seep, this.answered = false});

  final Seep seep;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 20.0;
    final right = size.width - 20;
    final top = 58.0;
    final bottom = size.height - 54;

    // The block, filled with water and then packed with grains.
    final block = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(block, waterFill);
    final seed = math.Random(7);
    final want = (1 - seep.porosity) * (right - left) * (bottom - top);
    var covered = 0.0;
    var guard = 0;
    while (covered < want && guard++ < 600) {
      final r = 4.0 + seed.nextDouble() * 7;
      final c = Offset(left + r + seed.nextDouble() * (right - left - 2 * r),
          top + r + seed.nextDouble() * (bottom - top - 2 * r));
      canvas
        ..drawCircle(c, r, Paint()..color = AppColors.cream)
        ..drawCircle(
            c,
            r,
            Paint()
              ..color = AppColors.ink3
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      covered += math.pi * r * r * 0.72;
    }
    canvas.drawRect(
        block,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);

    writeOn(canvas, size, 'porosity ${seep.porosity}', Offset(left, top - 16),
        AppColors.ink2, fontSize: 9.5);
    writeOn(canvas, size, 'face ${_num(seep.area)} m2',
        Offset(right - 74, top - 16), AppColors.ink2, fontSize: 9.5);

    // The two speeds, to one scale, in the clear strip under the block.
    final room = (right - left) * 0.42;
    final most = seep.seepage;
    void arrow(double y, double speed, Color tone, String text) {
      final to = left + 78 + room * speed / most;
      canvas
        ..drawLine(
            Offset(left + 78, y),
            Offset(to, y),
            Paint()
              ..color = tone
              ..strokeWidth = 2.6)
        ..drawPath(
            Path()
              ..moveTo(to + 6, y)
              ..lineTo(to - 2, y - 4.5)
              ..lineTo(to - 2, y + 4.5)
              ..close(),
            Paint()..color = tone);
      writeOn(canvas, size, text, Offset(left, y - 5), tone, fontSize: 9.5);
    }

    if (answered) {
      arrow(bottom + 16, seep.darcy, AppColors.ink3, 'Darcy q');
      arrow(bottom + 34, seep.seepage, AppColors.forest, 'seepage v');
    } else {
      writeOn(canvas, size, 'gradient ${seep.gradient}',
          Offset(left, bottom + 12), AppColors.ink2, fontSize: 9.5);
      writeOn(
          canvas,
          size,
          'K ${seep.conductivity.toStringAsExponential(0)} m/s',
          Offset(left + 110, bottom + 12),
          AppColors.ink2,
          fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'through the aquifer');
  }

  @override
  bool shouldRepaint(SoilPainter old) =>
      old.seep != seep || old.answered != answered;
}

/// The two kinds of aquifer, which take two different well formulas.
enum Ground { unconfined, confined }

/// A well pumping from an aquifer, with a head measured at the well and at
/// an observation well some way off.
@immutable
class Aquifer {
  const Aquifer({
    required this.kind,
    required this.conductivity,
    required this.headAtWell,
    required this.radiusAtWell,
    required this.headOut,
    required this.radiusOut,
    this.thickness = 20,
  });

  final Ground kind;
  final double conductivity;

  /// Heads above the bottom of the aquifer, and the radii they were
  /// measured at. The head at the well is always the lower of the two:
  /// that is what pumping does.
  final double headAtWell;
  final double radiusAtWell;
  final double headOut;
  final double radiusOut;

  /// Only a confined aquifer has a fixed thickness to multiply by.
  final double thickness;

  double get transmissivity => conductivity * thickness;

  /// Dupuit for an unconfined aquifer, where the saturated thickness falls
  /// with the water table, and Thiem for a confined one, where it cannot.
  double get discharge {
    final log = math.log(radiusOut / radiusAtWell);
    if (kind == Ground.unconfined) {
      return math.pi *
          conductivity *
          (headOut * headOut - headAtWell * headAtWell) /
          log;
    }
    return 2 * math.pi * transmissivity * (headOut - headAtWell) / log;
  }

  double get drawdown => headOut - headAtWell;

  Aquifer copyWith({
    double? conductivity,
    double? headAtWell,
    double? radiusOut,
    double? thickness,
  }) =>
      Aquifer(
        kind: kind,
        conductivity: conductivity ?? this.conductivity,
        headAtWell: headAtWell ?? this.headAtWell,
        radiusAtWell: radiusAtWell,
        headOut: headOut,
        radiusOut: radiusOut ?? this.radiusOut,
        thickness: thickness ?? this.thickness,
      );
}

/// The well and its cone of depression, cut through. A confined aquifer
/// gets its confining layer drawn in, because that is the whole of what
/// makes it confined and the only thing that picks the formula.
class AquiferPainter extends CustomPainter {
  const AquiferPainter({required this.aquifer, this.showFormula = false});

  final Aquifer aquifer;
  final bool showFormula;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = 44.0;
    final bedY = size.height - 34;
    final wellX = 46.0;
    final right = size.width - 16;
    final depth = bedY - groundY;

    // The aquifer bottom, which every head is measured from.
    canvas.drawLine(
        Offset(8, bedY),
        Offset(right, bedY),
        Paint()
          ..color = AppColors.ink2
          ..strokeWidth = 2);
    writeOn(canvas, size, 'aquifer bottom', Offset(10, bedY + 3),
        AppColors.ink3, fontSize: 9);

    double yFor(double head) =>
        bedY - depth * 0.80 * head / math.max(aquifer.headOut * 1.12, 1);

    // The cone of depression: the head climbing with the LOG of distance,
    // which is why nearly all of the drawdown is close to the well.
    final path = Path();
    for (var i = 0; i <= 60; i++) {
      final t = i / 60;
      final r = aquifer.radiusAtWell *
          math.pow(aquifer.radiusOut / aquifer.radiusAtWell, t);
      final head = aquifer.headAtWell +
          (aquifer.headOut - aquifer.headAtWell) *
              math.log(r / aquifer.radiusAtWell) /
              math.log(aquifer.radiusOut / aquifer.radiusAtWell);
      final p = Offset(wellX + (right - wellX) * t, yFor(head));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    if (aquifer.kind == Ground.unconfined) {
      // A free water table: the curve IS the top of the water, so the
      // ground under it is saturated and the ground over it is not.
      final wet = Path.from(path)
        ..lineTo(right, bedY)
        ..lineTo(wellX, bedY)
        ..close();
      canvas
        ..drawPath(wet, waterFill)
        ..drawPath(
            path,
            Paint()
              ..color = AppColors.info
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      writeOn(canvas, size, 'water table',
          Offset(right - 84, yFor(aquifer.headOut) - 15), AppColors.info,
          fontSize: 9);
      groundLine(canvas, const Offset(8, 30), Offset(right, 30));
    } else {
      // Confined: the aquifer is saturated to the underside of the clay and
      // stays that way however hard the well is pumped. The curve above is
      // a PRESSURE level, so nothing is filled under it: it is only where
      // water would stand in a pipe, and the pipe is drawn to say so.
      // The clay sits at the TOP OF THE AQUIFER, which is its thickness
      // above the bottom. That puts the piezometric line above the clay,
      // where a confined aquifer's pressure level belongs.
      final capBottom = yFor(aquifer.thickness);
      final capTop = capBottom - 15;
      canvas.drawRect(Rect.fromLTRB(8, capBottom, right, bedY), waterFill);
      final cap = Path()
        ..addRect(Rect.fromLTRB(8, capTop, right, capBottom));
      hatchIn(canvas, cap, step: 5, color: AppColors.charcoal);
      canvas
        ..drawPath(
            cap,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4)
        ..drawPath(
            path,
            Paint()
              ..color = AppColors.info
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      writeOn(canvas, size, 'clay: the aquifer is confined',
          Offset(72, capTop + 1), AppColors.charcoal, fontSize: 9);
      writeOn(canvas, size, 'where water would STAND',
          Offset(right - 190, yFor(aquifer.headOut) - 15), AppColors.info,
          fontSize: 9);
      // A standpipe at the far reading, showing what that line means.
      final pipeX = right - 34;
      final standAt = yFor(aquifer.headOut);
      canvas
        ..drawRect(Rect.fromLTRB(pipeX - 5, standAt - 6, pipeX + 5, capBottom),
            Paint()..color = AppColors.cream)
        ..drawRect(
            Rect.fromLTRB(pipeX - 5, standAt, pipeX + 5, bedY), waterFill)
        ..drawLine(Offset(pipeX - 5, standAt - 6), Offset(pipeX - 5, bedY),
            Paint()
              ..color = AppColors.ink2
              ..strokeWidth = 1.4)
        ..drawLine(Offset(pipeX + 5, standAt - 6), Offset(pipeX + 5, bedY),
            Paint()
              ..color = AppColors.ink2
              ..strokeWidth = 1.4);
    }

    // The well itself.
    canvas
      ..drawRect(Rect.fromLTRB(wellX - 7, 22, wellX + 7, bedY),
          Paint()..color = AppColors.cream)
      ..drawLine(Offset(wellX - 7, 22), Offset(wellX - 7, bedY),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 1.8)
      ..drawLine(Offset(wellX + 7, 22), Offset(wellX + 7, bedY),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 1.8)
      ..drawRect(
          Rect.fromLTRB(
              wellX - 7, yFor(aquifer.headAtWell), wellX + 7, bedY),
          waterFill);
    writeOn(canvas, size, 'pumped', Offset(wellX - 20, 8), AppColors.charcoal,
        fontSize: 9);

    // The two readings.
    for (final (x, head, label) in [
      (wellX, aquifer.headAtWell, 'h1 ${_num(aquifer.headAtWell)}'),
      (right - 4, aquifer.headOut, 'h2 ${_num(aquifer.headOut)}'),
    ]) {
      canvas.drawLine(
          Offset(x, yFor(head)),
          Offset(x, bedY),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 1.2);
      writeOn(canvas, size, label, Offset(x - 26, (yFor(head) + bedY) / 2 - 6),
          AppColors.ember, fontSize: 9.5);
    }
    writeOn(canvas, size, 'r2 ${_num(aquifer.radiusOut)}',
        Offset(right - 60, bedY - 14), AppColors.ink3, fontSize: 9);
    // The head follows the LOG of the distance, so the sheet is spaced that
    // way and says so: on a linear axis this curve would be a hook, with
    // nearly all of the drawdown crammed against the well.
    writeOn(canvas, size, 'distance from the well, log spaced',
        Offset(size.width - 176, bedY + 3), AppColors.ink3, fontSize: 8.5);

    if (showFormula) {
      writeOn(
          canvas,
          size,
          aquifer.kind == Ground.unconfined
              ? 'Dupuit: heads squared'
              : 'Thiem: heads as they are',
          Offset(8, size.height - 16),
          AppColors.forest,
          fontSize: 9.5);
    }
    viewTag(canvas, size, Looking.section, note: 'through the well');
  }

  @override
  bool shouldRepaint(AquiferPainter old) =>
      old.aquifer != aquifer || old.showFormula != showFormula;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
