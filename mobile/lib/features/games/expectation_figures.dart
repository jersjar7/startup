import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One outcome and how likely it is, as a whole percent so that a set of them
/// can be checked for adding up to a hundred without any floating point.
@immutable
class Outcome {
  const Outcome(this.value, this.percent);

  /// Where the block sits on the beam.
  final int value;

  /// How heavy it is, in percent.
  final int percent;
}

/// A beam loaded with the outcomes of a distribution, and the fulcrums on
/// offer to balance it.
///
/// Expected value IS a balance point. Every wrong answer this lesson names is
/// visible as a beam that tips: put the fulcrum under the tallest block and a
/// heavy outcome further out still wins, and put it at the middle of the range
/// and the probabilities are being ignored altogether. So the beam tips on the
/// reveal, in the direction the arithmetic would have gone.
class BeamPainter extends CustomPainter {
  const BeamPainter({
    required this.outcomes,
    required this.fulcrums,
    required this.from,
    required this.to,
    required this.unit,
    this.picked,
    this.truth,
    this.revealed = false,
  });

  final List<Outcome> outcomes;

  /// Where each candidate fulcrum sits, in the beam's own units.
  final List<double> fulcrums;

  final double from;
  final double to;

  /// What one unit on the beam is called.
  final String unit;

  final int? picked;
  final int? truth;
  final bool revealed;

  static const _padL = 18.0;

  /// Wider on the right, so the unit name has a column of its own instead of
  /// sitting on top of the last value on the scale.
  static const _padR = 44.0;
  static const _beamY = 0.56;
  static const _blockMax = 0.46;

  double _x(Size size, double v) =>
      _padL + (v - from) / (to - from) * (size.width - _padL - _padR);

  /// How far the beam tips about [at], as an angle. Positive turns clockwise,
  /// which is what a load to the right of the fulcrum does.
  double _tilt(double at) {
    final moment = outcomes.fold<double>(
      0,
      (sum, o) => sum + o.percent * (o.value - at),
    );
    final span = (to - from) * 100;
    return (moment / span * 2.2).clamp(-0.19, 0.19);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final beamY = size.height * _beamY;
    final showTilt = revealed && picked != null;
    final pivot = showTilt ? fulcrums[picked!] : 0.0;
    final angle = showTilt ? _tilt(pivot) : 0.0;

    canvas.save();
    if (showTilt && angle != 0) {
      canvas.translate(_x(size, pivot), beamY);
      canvas.rotate(angle);
      canvas.translate(-_x(size, pivot), -beamY);
    }

    for (final o in outcomes) {
      final h = size.height * _blockMax * (o.percent / 100);
      final w = (size.width - _padL - _padR) / (to - from) * 0.62;
      final rect = Rect.fromLTWH(
        _x(size, o.value.toDouble()) - w / 2,
        beamY - h,
        w,
        h,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = AppColors.sunbeam.withValues(alpha: 0.55),
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      _write(
        canvas,
        '${o.percent}%',
        Offset(_x(size, o.value.toDouble()), rect.top - 11),
        color: AppColors.ink3,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(_padL, beamY, size.width - _padL - _padR, 6),
      Paint()..color = AppColors.charcoal,
    );
    canvas.restore();

    // The scale sits under the beam and does not move with it, because the
    // outcomes have values whether or not the beam is balanced. It gets a band
    // of its own above the fulcrums: a tick mark and a letter in the same
    // strip of pixels is unreadable on a phone.
    for (final o in outcomes) {
      final x = _x(size, o.value.toDouble());
      canvas.drawLine(
        Offset(x, beamY + 8),
        Offset(x, beamY + 13),
        Paint()
          ..color = AppColors.ink2
          ..strokeWidth = 1,
      );
      _write(
        canvas,
        '${o.value}',
        Offset(x, beamY + 15),
        color: AppColors.ink3,
      );
    }
    _write(
      canvas,
      unit,
      Offset(size.width - 6, beamY + 15),
      color: AppColors.ink3,
      align: -1,
    );

    for (final (i, at) in fulcrums.indexed) {
      final isTruth = revealed && truth == i;
      final isWrong = revealed && picked == i && truth != i;
      final color = isTruth
          ? AppColors.forest
          : isWrong
          ? AppColors.error
          : picked == i
          ? AppColors.ember
          : AppColors.ink3;
      final x = _x(size, at);
      final top = beamY + 32;
      // A stem up to the beam, so the wedge reads as what the beam is
      // actually resting on rather than an ornament floating below it.
      canvas.drawLine(
        Offset(x, beamY + 4),
        Offset(x, top),
        Paint()
          ..color = picked == i || isTruth
              ? color
              : color.withValues(alpha: 0.35)
          ..strokeWidth = 2,
      );
      final wedge = Path()
        ..moveTo(x, top)
        ..lineTo(x - 11, top + 20)
        ..lineTo(x + 11, top + 20)
        ..close();
      canvas.drawPath(
        wedge,
        Paint()..color = picked == i || isTruth
            ? color
            : color.withValues(alpha: 0.22),
      );
      canvas.drawPath(
        wedge,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      _write(
        canvas,
        String.fromCharCode(65 + i),
        Offset(x, top + 24),
        color: color,
      );
    }
  }

  /// [align] is 0 for centerd on [at], -1 to end there, 1 to start there.
  void _write(
    Canvas canvas,
    String text,
    Offset at, {
    required Color color,
    int align = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      -1 => tp.width,
      1 => 0.0,
      _ => tp.width / 2,
    };
    tp.paint(canvas, at - Offset(dx, 0));
  }

  @override
  bool shouldRepaint(BeamPainter old) =>
      old.picked != picked || old.revealed != revealed;
}

/// Two standard deviations as the legs of a right triangle, with the total as
/// the hypotenuse.
///
/// Variances add and standard deviations do not, which as algebra is a rule to
/// remember and as a picture is the oldest fact in the trade. Three and eight
/// give a hypotenuse that is visibly shorter than eleven, and no student who
/// has looked at the triangle hands in the sum of the legs.
class SigmaTrianglePainter extends CustomPainter {
  const SigmaTrianglePainter({
    required this.a,
    required this.b,
    required this.aLabel,
    required this.bLabel,
    this.showHypotenuse = true,
  });

  /// The two legs, in whatever units the round is working in.
  final double a;
  final double b;
  final String aLabel;
  final String bLabel;

  /// Whether the third side is drawn. Rounds that want a variance still show
  /// it: the picture never carries a number, so it cannot hand over an answer.
  final bool showHypotenuse;

  static const _padL = 54.0;
  static const _padR = 18.0;
  static const _padT = 16.0;
  static const _padB = 30.0;

  @override
  void paint(Canvas canvas, Size size) {
    // The right angle sits at the bottom, the longer leg along it. One scale
    // for both directions, always: a triangle stretched in one direction is
    // no longer making the point it was drawn to make.
    final flat = a >= b ? a : b;
    final up = a >= b ? b : a;
    final flatLabel = a >= b ? aLabel : bLabel;
    final upLabel = a >= b ? bLabel : aLabel;

    final scale = math.min(
      (size.width - _padL - _padR) / flat,
      (size.height - _padT - _padB) / up,
    );

    final left = math.max(
      _padL,
      (size.width - flat * scale) / 2,
    );
    // Centerd in both directions. Anchored to the bottom, a wide flat pair of
    // spreads sat in the lower third with the top of the box empty.
    final room = size.height - _padT - _padB;
    final corner = Offset(
      left,
      _padT + (room + up * scale) / 2,
    );
    final along = corner + Offset(flat * scale, 0);
    final rise = corner + Offset(0, -up * scale);

    canvas.drawRect(
      Rect.fromLTWH(corner.dx, corner.dy - 12, 12, 12),
      Paint()..color = AppColors.charcoal.withValues(alpha: 0.10),
    );

    final leg = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(corner, along, leg);
    canvas.drawLine(corner, rise, leg);

    if (showHypotenuse) {
      canvas.drawLine(
        along,
        rise,
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }

    _write(
      canvas,
      flatLabel,
      Offset((corner.dx + along.dx) / 2, corner.dy + 8),
    );
    _write(
      canvas,
      upLabel,
      Offset(corner.dx - 28, (corner.dy + rise.dy) / 2 - 6),
    );
    if (showHypotenuse) {
      _write(
        canvas,
        'total',
        Offset((along.dx + rise.dx) / 2 + 14, (along.dy + rise.dy) / 2 - 14),
        color: AppColors.ember,
      );
    }
  }

  void _write(
    Canvas canvas,
    String text,
    Offset at, {
    Color color = AppColors.ink3,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(SigmaTrianglePainter old) =>
      old.a != a || old.b != b || old.showHypotenuse != showHypotenuse;
}
