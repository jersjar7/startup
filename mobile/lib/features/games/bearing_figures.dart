import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A strip footing and the soil it sits in, with the three terms of the
/// bearing capacity equation worked out rather than quoted.
@immutable
class Footing {
  const Footing({
    required this.width,
    required this.depth,
    required this.cohesion,
    required this.unitWeight,
    required this.nc,
    required this.nq,
    required this.nGamma,
    this.safety = 3,
  });

  /// Feet.
  final double width;
  final double depth;

  /// Pounds per square foot, and pounds per cubic foot.
  final double cohesion;
  final double unitWeight;

  /// The three factors, which an exam question always hands over.
  final double nc;
  final double nq;
  final double nGamma;

  final double safety;

  double get cohesionTerm => cohesion * nc;
  double get depthTerm => unitWeight * depth * nq;
  double get widthTerm => 0.5 * unitWeight * width * nGamma;

  double get ultimate => cohesionTerm + depthTerm + widthTerm;
  double get allowable => ultimate / safety;
}

/// The footing in section, with the width and the depth dimensioned, and
/// once the round is over the three terms drawn as a stack so their sizes
/// can be compared.
class FootingPainter extends CustomPainter {
  const FootingPainter({required this.footing, this.answered = false});

  final Footing footing;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 34.0;
    final right = size.width * 0.60;
    final ground = 42.0;
    final bottom = size.height - 34;

    // The ground, and the excavation the footing sits in.
    final soil = Rect.fromLTRB(left, ground, right, bottom);
    canvas.drawRect(
        soil, Paint()..color = AppColors.ink2.withValues(alpha: 0.18));
    groundLine(canvas, Offset(left, ground), Offset(right, ground));

    // The footing itself.
    final scale = math.min((right - left) * 0.5 / math.max(footing.width, 1),
        (bottom - ground) * 0.5 / math.max(footing.depth, 1));
    final b = math.max(footing.width * scale, 26.0);
    final d = footing.depth * scale;
    final base = ground + d;
    final middle = (left + right) / 2;
    final pad = Rect.fromLTRB(middle - b / 2, base - 12, middle + b / 2, base);
    canvas
      ..drawRect(pad, Paint()..color = AppColors.charcoal.withValues(alpha: 0.75))
      ..drawLine(
          Offset(middle, base - 12),
          Offset(middle, ground - 22),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 5);

    // The width and the depth, dimensioned.
    canvas.drawLine(
        Offset(pad.left, base + 12),
        Offset(pad.right, base + 12),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 1.6);
    writeOn(canvas, size, 'B = ${footing.width.toStringAsFixed(0)} ft',
        Offset(middle - 20, base + 16), AppColors.ember, fontSize: 9.5);
    if (footing.depth > 0) {
      canvas.drawLine(
          Offset(left + 12, ground),
          Offset(left + 12, base),
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 1.6);
      writeOn(canvas, size, 'D = ${footing.depth.toStringAsFixed(0)} ft',
          Offset(left - 8, (ground + base) / 2 - 6), AppColors.info,
          fontSize: 9.5);
    } else {
      writeOn(canvas, size, 'on the surface', Offset(left - 8, ground + 6),
          AppColors.info, fontSize: 9.5);
    }

    writeOn(
        canvas,
        size,
        'c = ${footing.cohesion.toStringAsFixed(0)}, '
            'unit weight ${footing.unitWeight.toStringAsFixed(0)}',
        Offset(left, bottom + 8),
        AppColors.ink3,
        fontSize: 9.5);

    if (answered) {
      // The three terms, to one scale, so which of them carries the load is
      // a matter of looking.
      final x = size.width * 0.64;
      final wide = size.width - x - 12;
      final top = math.max(footing.ultimate, 1);
      var y = ground;
      for (final (name, value) in [
        ('cohesion', footing.cohesionTerm),
        ('depth', footing.depthTerm),
        ('width', footing.widthTerm),
      ]) {
        canvas.drawRect(
            Rect.fromLTWH(x, y, math.max(value / top * wide, 1), 11),
            Paint()..color = AppColors.forest.withValues(alpha: 0.7));
        writeOn(canvas, size, '$name ${value.toStringAsFixed(0)}',
            Offset(x, y + 13), AppColors.forest, fontSize: 9.5);
        y += 30;
      }
    }

    viewTag(canvas, size, Looking.section, note: 'the footing');
  }

  @override
  bool shouldRepaint(FootingPainter old) =>
      old.footing != footing || old.answered != answered;
}
