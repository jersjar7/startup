import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';
import 'virtual_work_figures.dart' show pinMark, rollerMark;

/// Which single answer the line is about. An influence line is drawn for ONE
/// of these at ONE place, which is the thing everybody has to be told twice.
enum Response { leftReaction, rightReaction, shearAt, momentAt }

/// The influence line for one response on a simply supported span. Every
/// ordinate an item draws or quotes comes out of here.
@immutable
class Influence {
  const Influence({
    required this.span,
    required this.response,
    this.at = 0,
  });

  final double span;
  final Response response;

  /// Where the section is, measured from the left support. Ignored for the
  /// two reactions.
  final double at;

  /// The height of the line when the unit load stands at [x]. Shear is
  /// discontinuous at the section, so [fromRight] says which side of it the
  /// load is standing on.
  double ordinateAt(double x, {bool fromRight = true}) {
    switch (response) {
      case Response.leftReaction:
        return (span - x) / span;
      case Response.rightReaction:
        return x / span;
      case Response.shearAt:
        if (x < at || (x == at && !fromRight)) return -x / span;
        return 1 - x / span;
      case Response.momentAt:
        return x <= at ? x * (span - at) / span : at * (span - x) / span;
    }
  }

  /// The biggest height the line reaches, ignoring sign.
  double get peak => switch (response) {
        Response.leftReaction || Response.rightReaction => 1,
        Response.shearAt => math.max(1 - at / span, at / span),
        Response.momentAt => at * (span - at) / span,
      };

  /// What the line is worth in the plainest words.
  String get plain => switch (response) {
        Response.leftReaction => 'the reaction at the left support',
        Response.rightReaction => 'the reaction at the right support',
        Response.shearAt => 'the shear at the section',
        Response.momentAt => 'the moment at the section',
      };

  /// Whether the line has a step in it, which only shear does.
  bool get jumps => response == Response.shearAt;
}

/// The beam with the section marked, and the influence line under it. The
/// horizontal axis is where the UNIT LOAD is standing, which is written on
/// the drawing every time, because reading it as a position along a bending
/// moment diagram is the mistake the whole lesson is trying to prevent.
class InfluencePainter extends CustomPainter {
  const InfluencePainter({
    required this.line,
    this.loads = const [],
    this.showSection = true,
    this.showOrdinates = false,
    this.named = true,
  });

  final Influence line;

  /// Where the moving loads are standing, as (position, label).
  final List<(double, String)> loads;

  /// Whether to mark and name the section the line is drawn for.
  final bool showSection;

  /// Whether to write the height under each load, which is only honest once
  /// the round is over.
  final bool showOrdinates;

  /// Whether to name what the up-axis is measuring. An item that asks the
  /// reader to name it turns this off.
  final bool named;

  static const _padX = 34.0;

  @override
  void paint(Canvas canvas, Size size) {
    final beamY = size.height * 0.22;
    final zero = size.height * 0.66;
    final left = _padX;
    final right = size.width - _padX;

    double xOf(double at) => left + at / line.span * (right - left);

    // The beam itself, with its two supports.
    canvas.drawLine(
        Offset(left, beamY),
        Offset(right, beamY),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 3);
    pinMark(canvas, Offset(left, beamY));
    rollerMark(canvas, Offset(right, beamY));

    if (showSection &&
        (line.response == Response.shearAt ||
            line.response == Response.momentAt)) {
      final sx = xOf(line.at);
      for (var y = beamY - 16.0; y < zero + 16; y += 8) {
        canvas.drawLine(
            Offset(sx, y),
            Offset(sx, y + 4),
            Paint()
              ..color = AppColors.info
              ..strokeWidth = 1.4);
      }
      // With loads standing on the beam their labels own the space above it,
      // so the section names itself down by the plot instead.
      writeOn(
          canvas,
          size,
          'the section',
          loads.isEmpty
              ? Offset(sx - 24, beamY - 30)
              : Offset(sx - 24, zero + 18),
          AppColors.info,
          fontSize: 9.5);
    }

    // The base line of the plot, and what its across-ness means.
    canvas.drawLine(
        Offset(left, zero),
        Offset(right, zero),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1.2);
    writeOn(canvas, size, 'across: where the unit load is standing',
        Offset(left - 6, size.height - 16), AppColors.ink3, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        named ? 'up: ${line.plain}' : 'up: one answer, at the marked place',
        Offset(left - 6, zero - 74),
        AppColors.ink3,
        fontSize: 9.5);

    // The line itself.
    // The plot has to finish above the caption at the foot of the panel,
    // because a shear line with its section near the far end reaches a long
    // way below the axis.
    final tall = math.min(
        math.min(zero - beamY - 26, size.height - 26 - zero), 52.0);
    double yOf(double v) => zero - v / line.peak * tall;

    final ink = Paint()
      ..color = AppColors.ember
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    switch (line.response) {
      case Response.leftReaction:
        canvas.drawLine(Offset(left, yOf(1)), Offset(right, yOf(0)), ink);
      case Response.rightReaction:
        canvas.drawLine(Offset(left, yOf(0)), Offset(right, yOf(1)), ink);
      case Response.momentAt:
        final path = Path()
          ..moveTo(left, yOf(0))
          ..lineTo(xOf(line.at), yOf(line.peak))
          ..lineTo(right, yOf(0));
        canvas.drawPath(path, ink);
      case Response.shearAt:
        final sx = xOf(line.at);
        final below = yOf(-line.at / line.span);
        final above = yOf(1 - line.at / line.span);
        canvas
          ..drawLine(Offset(left, yOf(0)), Offset(sx, below), ink)
          ..drawLine(Offset(sx, above), Offset(right, yOf(0)), ink);
        // The step of exactly one at the section, dashed so it reads as the
        // jump it is rather than as a piece of the structure.
        for (var y = above; y < below; y += 7) {
          canvas.drawLine(
              Offset(sx, y),
              Offset(sx, math.min(y + 4, below)),
              Paint()
                ..color = AppColors.ember
                ..strokeWidth = 1.6);
        }
    }

    // Where the moving loads are standing, dropped onto the line.
    for (final (at, label) in loads) {
      final x = xOf(at);
      final v = line.ordinateAt(at);
      canvas
        ..drawLine(
            Offset(x, beamY - 26),
            Offset(x, beamY - 5),
            Paint()
              ..color = AppColors.forest
              ..strokeWidth = 2.4)
        ..drawPath(
            Path()
              ..moveTo(x, beamY - 1)
              ..lineTo(x - 4, beamY - 9)
              ..lineTo(x + 4, beamY - 9)
              ..close(),
            Paint()..color = AppColors.forest)
        ..drawCircle(Offset(x, yOf(v)), 3.4, Paint()..color = AppColors.forest);
      writeOn(canvas, size, label, Offset(x + 5, beamY - 34), AppColors.forest,
          fontSize: 9.5);
      if (showOrdinates) {
        writeOn(canvas, size, _num(v), Offset(x + 5, yOf(v) - 4),
            AppColors.forest, fontSize: 9.5);
      }
    }
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  bool shouldRepaint(InfluencePainter old) =>
      old.line != line ||
      old.loads != loads ||
      old.showSection != showSection ||
      old.showOrdinates != showOrdinates ||
      old.named != named;
}
