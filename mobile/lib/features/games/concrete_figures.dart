import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One concrete mix, described the way a mix sheet describes it.
@immutable
class Mix {
  const Mix({
    required this.wc,
    this.air = 0,
    this.plasticized = false,
  });

  /// Water over cement, by weight.
  final double wc;

  /// Entrained air, in percent by volume. Four to seven is the usual range.
  final double air;

  /// Whether a water reducer is doing the work that water would otherwise do.
  final bool plasticized;

  bool get entrained => air > 0;

  /// Twenty eight day compressive strength, in psi.
  ///
  /// This is the handbook's curve, fitted to the two points the lesson
  /// quotes: about 6,500 psi at a ratio of 0.40 and about 2,000 psi at 0.80,
  /// falling steeply in between. Air entrainment costs roughly a fifth of it,
  /// which is the trade the lesson warns about.
  double get strength {
    final plain = 21125 * math.pow(19, -wc).toDouble();
    return entrained ? plain * 0.8 : plain;
  }

  /// How a mix sheet would read.
  String get plain {
    final airPart = entrained ? '${_num(air)} percent air' : 'no air';
    final help = plasticized ? ', water reducer' : '';
    return 'W/C ${wc.toStringAsFixed(2)}, $airPart$help';
  }

  static String _num(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}

/// The handbook's strength against water-cement ratio, with the mixes of the
/// round marked on it.
///
/// Both curves are always drawn, the plain one and the air entrained one,
/// because the gap between them IS the lesson's second warning and it cannot
/// be read from one line.
class MixPainter extends CustomPainter {
  const MixPainter({
    required this.marks,
    this.target,
    this.picked,
    this.answer,
    this.locked = false,
    this.showMarks = true,
  });

  /// The mixes this round puts on the chart, in the order they are offered.
  final List<Mix> marks;

  /// A strength the job has to reach, drawn as a line across the chart.
  final double? target;

  final int? picked;
  final int? answer;
  final bool locked;

  /// False while a round is asking about a change rather than about a choice
  /// between drawn mixes.
  final bool showMarks;

  static const _lowWc = 0.35;
  static const _highWc = 0.85;
  // The tallest the plain curve reaches over that range, with a little room.
  static const _ceiling = 8000.0;

  static Rect plot(Size size) =>
      Rect.fromLTRB(44, 14, size.width - 12, size.height - 26);

  static Offset at(Size size, Mix mix) {
    final box = plot(size);
    final x = box.left +
        box.width * ((mix.wc - _lowWc) / (_highWc - _lowWc)).clamp(0.0, 1.0);
    final y = box.bottom -
        box.height * (mix.strength / _ceiling).clamp(0.0, 1.0);
    return Offset(x, y);
  }

  /// Which marked mix a tap is nearest, or nothing if it was near none.
  static int? nearest(Size size, List<Mix> marks, Offset tap,
      {double within = 40}) {
    int? best;
    var bestGap = within;
    for (var i = 0; i < marks.length; i++) {
      final gap = (at(size, marks[i]) - tap).distance;
      if (gap < bestGap) {
        bestGap = gap;
        best = i;
      }
    }
    return best;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final box = plot(size);
    final axis = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.4;
    canvas
      ..drawLine(box.bottomLeft, box.bottomRight, axis)
      ..drawLine(box.bottomLeft, box.topLeft, axis);

    for (final psi in [2000.0, 4000.0, 6000.0]) {
      final y = box.bottom - box.height * psi / _ceiling;
      canvas.drawLine(
        Offset(box.left, y),
        Offset(box.right, y),
        Paint()..color = AppColors.line.withValues(alpha: 0.6)..strokeWidth = 0.8,
      );
      _write(canvas, '${(psi / 1000).round()}k', Offset(4, y - 6),
          AppColors.ink3);
    }
    _write(canvas, 'psi', const Offset(4, 14), AppColors.ink3);
    for (final wc in [0.4, 0.5, 0.6, 0.7, 0.8]) {
      final x = at(size, Mix(wc: wc)).dx;
      _write(canvas, wc.toStringAsFixed(1), Offset(x - 8, box.bottom + 4),
          AppColors.ink3);
    }
    _write(canvas, 'W/C', Offset(box.right - 26, box.bottom + 14),
        AppColors.ink3);

    _curve(canvas, size, false, AppColors.info);
    _curve(canvas, size, true, AppColors.ember);
    _write(canvas, 'no air', Offset(box.left + 6, at(size, const Mix(wc: 0.38)).dy - 14),
        AppColors.info);
    _write(
        canvas,
        'with air',
        Offset(box.left + 6,
            at(size, const Mix(wc: 0.38, air: 5)).dy + 4),
        AppColors.ember);

    if (target != null) {
      final y = box.bottom - box.height * target! / _ceiling;
      final paint = Paint()
        ..color = AppColors.forest
        ..strokeWidth = 1.4;
      for (var x = box.left; x < box.right; x += 10) {
        canvas.drawLine(Offset(x, y), Offset(x + 5, y), paint);
      }
      _write(canvas, 'needs ${(target! / 1000).toStringAsFixed(1)}k',
          Offset(box.right - 62, y - 13), AppColors.forest);
    }

    if (!showMarks) return;
    for (var i = 0; i < marks.length; i++) {
      final spot = at(size, marks[i]);
      final Color tone;
      if (locked && answer == i) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else if (picked == i) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.charcoal;
      }
      canvas
        ..drawCircle(spot, 8, Paint()..color = AppColors.cream)
        ..drawCircle(spot, 6, Paint()..color = tone);
      // The number goes beside the dot rather than above it: two mixes at the
      // same ratio sit one above the other, and a label overhead would land
      // on its neighbor.
      _write(canvas, '${i + 1}', spot + const Offset(10, -6), tone);
    }
  }

  void _curve(Canvas canvas, Size size, bool air, Color tone) {
    final path = Path();
    for (var i = 0; i <= 40; i++) {
      final wc = _lowWc + (_highWc - _lowWc) * i / 40;
      final p = at(size, Mix(wc: wc, air: air ? 5 : 0));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  void _write(Canvas canvas, String text, Offset at, Color color) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 9.5, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    final patch = Rect.fromLTWH(
        at.dx - 2, at.dy - 1, painter.width + 4, painter.height + 2);
    canvas.drawRect(
        patch, Paint()..color = AppColors.cream.withValues(alpha: 0.85));
    painter.paint(canvas, at);
  }

  @override
  bool shouldRepaint(MixPainter old) =>
      old.marks != marks ||
      old.target != target ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked ||
      old.showMarks != showMarks;
}
