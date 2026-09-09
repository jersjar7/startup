import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One interval on the axis: a centre and a half-width, with a name.
@immutable
class Band {
  const Band({required this.margin, required this.label, required this.tone});

  final double margin;
  final String label;

  /// What the band is for: the one being built, the one it is compared with,
  /// or the answer.
  final BandTone tone;
}

enum BandTone { live, before, truth, wrong }

/// A confidence interval drawn to scale around a sample mean.
///
/// The whole lesson is about WIDTH, and width is the one thing a formula on a
/// page will not show you. Dividing by n instead of the root of n is not a
/// small slip when you can see the interval collapse to a sliver, and raising
/// the confidence is not free when you can watch the interval grow.
class IntervalPainter extends CustomPainter {
  const IntervalPainter({
    required this.centre,
    required this.bands,
    required this.widest,
    required this.unit,
  });

  /// The sample mean, which never moves.
  final double centre;
  final List<Band> bands;

  /// The half-width that fills the axis, so bands stay comparable between
  /// rounds and between each other.
  final double widest;

  final String unit;

  static const _padL = 16.0;
  static const _padR = 16.0;

  double _x(Size size, double v) =>
      _padL +
      (v - (centre - widest)) /
          (2 * widest) *
          (size.width - _padL - _padR);

  Color _colorOf(BandTone tone) => switch (tone) {
    BandTone.live => AppColors.ember,
    BandTone.before => AppColors.ink3,
    BandTone.truth => AppColors.forest,
    BandTone.wrong => AppColors.error,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final rowH = math.min(46.0, (size.height - 44) / bands.length);
    final top = 22.0;

    for (final (i, band) in bands.indexed) {
      final y = top + rowH * (i + 0.5);
      final color = _colorOf(band.tone);
      final from = _x(size, centre - band.margin);
      final to = _x(size, centre + band.margin);

      canvas.drawLine(
        Offset(from, y),
        Offset(to, y),
        Paint()
          ..color = color
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
      for (final end in [from, to]) {
        canvas.drawLine(
          Offset(end, y - 8),
          Offset(end, y + 8),
          Paint()
            ..color = color
            ..strokeWidth = 2,
        );
      }
      _write(canvas, band.label, Offset(_padL, y - 22), color: color, align: 1);
    }

    // The mean, drawn last so it sits over every band that crosses it.
    final cx = _x(size, centre);
    canvas.drawLine(
      Offset(cx, top - 6),
      Offset(cx, top + rowH * bands.length + 6),
      Paint()
        ..color = AppColors.charcoal.withValues(alpha: 0.45)
        ..strokeWidth = 1.2,
    );
    _write(
      canvas,
      unit,
      Offset(cx, top + rowH * bands.length + 8),
      color: AppColors.ink3,
    );
  }

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
      1 => 0.0,
      -1 => tp.width,
      _ => tp.width / 2,
    };
    tp.paint(canvas, at - Offset(dx, 0));
  }

  @override
  bool shouldRepaint(IntervalPainter old) =>
      old.bands != bands || old.widest != widest;
}

/// Margin of error against sample size, which is the shape of the whole
/// sample-size question.
///
/// The margin falls with the ROOT of n, and drawn out that is a curve that
/// drops fast and then flattens. Four times the samples for half the margin is
/// obvious on the picture and invisible in the formula, and so is the reason
/// the answer rounds up: the curve crosses the target between two whole
/// numbers, and the one below the line is the one you can order.
class MarginCurvePainter extends CustomPainter {
  const MarginCurvePainter({
    required this.k,
    required this.target,
    required this.candidates,
    required this.nFrom,
    required this.nTo,
    this.picked,
    this.truth,
    this.revealed = false,
  });

  /// The margin at a sample size of one, so the margin at n is k over root n.
  final double k;

  /// The margin the round is asking for.
  final double target;
  final List<int> candidates;

  /// The window the curve is drawn over. A round decided by one sample needs
  /// to start near its candidates, or 61 and 62 land on the same pixel.
  final int nFrom;
  final int nTo;

  final int? picked;
  final int? truth;
  final bool revealed;

  static const _padL = 34.0;
  static const _padR = 18.0;
  static const _padT = 14.0;
  static const _padB = 28.0;

  double _margin(double n) => k / math.sqrt(n);

  double _x(Size size, double n) =>
      _padL +
      (n - nFrom) / (nTo - nFrom) * (size.width - _padL - _padR);

  double _y(Size size, double m) =>
      size.height - _padB - (m / (target * 2.4)).clamp(0.0, 1.0) *
          (size.height - _padB - _padT);

  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = AppColors.ink2
      ..strokeWidth = 1.4;
    canvas.drawLine(
      Offset(_padL, size.height - _padB),
      Offset(size.width - _padR, size.height - _padB),
      axis,
    );
    canvas.drawLine(
      Offset(_padL, size.height - _padB),
      Offset(_padL, _padT),
      axis,
    );

    // What the round is asking for, as a line to get under.
    final ty = _y(size, target);
    var x = _padL;
    while (x < size.width - _padR) {
      canvas.drawLine(
        Offset(x, ty),
        Offset(math.min(x + 5, size.width - _padR), ty),
        Paint()
          ..color = AppColors.sunbeam
          ..strokeWidth = 2,
      );
      x += 10;
    }
    _write(
      canvas,
      'wanted',
      Offset(size.width - _padR, ty - 13),
      color: const Color(0xFFB07C0C),
      align: -1,
    );

    final curve = Path();
    for (var i = 0; i <= 240; i++) {
      final n = nFrom + (nTo - nFrom) * (i / 240);
      if (n < 0.4) continue;
      final p = Offset(_x(size, n), _y(size, _margin(n)));
      if (curve.getBounds().isEmpty) {
        curve.moveTo(p.dx, p.dy);
      } else {
        curve.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      curve,
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (final (i, n) in candidates.indexed) {
      final isTruth = revealed && truth == i;
      final isWrong = revealed && picked == i && truth != i;
      final color = isTruth
          ? AppColors.forest
          : isWrong
          ? AppColors.error
          : picked == i
          ? AppColors.ember
          : AppColors.ink3;
      final px = _x(size, n.toDouble());
      final py = _y(size, _margin(n.toDouble()));
      canvas.drawLine(
        Offset(px, py),
        Offset(px, size.height - _padB),
        Paint()
          ..color = color.withValues(alpha: picked == i || isTruth ? 0.8 : 0.3)
          ..strokeWidth = 1.4,
      );
      canvas.drawCircle(Offset(px, py), 5, Paint()..color = color);
      _write(canvas, '$n', Offset(px, size.height - _padB + 6), color: color);
    }

    _write(
      canvas,
      'margin',
      const Offset(2, _padT - 12),
      color: AppColors.ink3,
      align: 1,
    );
    _write(
      canvas,
      'samples',
      Offset(size.width - _padR, size.height - _padB + 16),
      color: AppColors.ink3,
      align: -1,
    );
  }

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
      1 => 0.0,
      -1 => tp.width,
      _ => tp.width / 2,
    };
    tp.paint(canvas, at - Offset(dx, 0));
  }

  @override
  bool shouldRepaint(MarginCurvePainter old) =>
      old.picked != picked || old.revealed != revealed || old.k != k;
}
