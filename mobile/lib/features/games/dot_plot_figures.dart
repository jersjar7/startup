import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A dot plot: every reading in a data set stacked over the value it took.
///
/// Almost everything in the first statistics lesson is a formula with a sum in
/// it, and a phone is the wrong place to add six numbers up. What a phone is
/// very good for is showing where the readings actually sit, because the
/// median is a POSITION, the mode is the tallest stack, and the range is the
/// distance between the two ends. None of those need a calculator, and a
/// student who can see them stops confusing them with each other.
class DotPlotPainter extends CustomPainter {
  const DotPlotPainter({
    required this.values,
    required this.from,
    required this.to,
    this.picked = const {},
    this.truth = const {},
    this.revealed = false,
  });

  /// Every reading, in any order. Repeats stack up. Whole numbers, because
  /// the axis is tapped and a tick has to be a place a finger can land.
  final List<int> values;

  /// The span the axis covers.
  final int from;
  final int to;

  /// Ticks the student has tapped, and the ones that were right.
  final Set<int> picked;
  final Set<int> truth;
  final bool revealed;

  static const _padX = 22.0;
  static const _axis = 34.0;

  double xOf(Size size, int v) =>
      _padX + (v - from) / (to - from) * (size.width - _padX * 2);

  /// The tick nearest a tap, or null when the finger was nowhere near one.
  int? nearest(Size size, Offset at) {
    var best = from;
    var bestDx = double.infinity;
    for (var v = from; v <= to; v++) {
      final dx = (xOf(size, v) - at.dx).abs();
      if (dx < bestDx) {
        bestDx = dx;
        best = v;
      }
    }
    final pitch = (size.width - _padX * 2) / (to - from);
    return bestDx <= pitch * 1.2 ? best : null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = size.height - _axis;

    canvas.drawLine(
      Offset(_padX - 8, baseline),
      Offset(size.width - _padX + 8, baseline),
      Paint()
        ..color = AppColors.ink2
        ..strokeWidth = 1.6,
    );

    for (var v = from; v <= to; v++) {
      final x = xOf(size, v);
      final marked = truth.contains(v);
      final wrong = picked.contains(v) && !marked;
      final color = revealed && marked
          ? AppColors.forest
          : revealed && wrong
          ? AppColors.error
          : picked.contains(v)
          ? AppColors.ember
          : AppColors.ink3;

      canvas.drawLine(
        Offset(x, baseline),
        Offset(x, baseline + 5),
        Paint()..color = AppColors.ink3,
      );
      if (picked.contains(v) || (revealed && marked)) {
        // A band up the whole column, so a marked value reads as a place on
        // the axis rather than as a highlighted number.
        canvas.drawRect(
          Rect.fromLTRB(x - 9, 6, x + 9, baseline),
          Paint()..color = color.withValues(alpha: 0.12),
        );
      }
      _tick(canvas, '$v', Offset(x, baseline + 17), color);
    }

    // The readings themselves, stacked.
    final counts = <int, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
      final n = counts[v]!;
      canvas.drawCircle(
        Offset(xOf(size, v), baseline - 11 - (n - 1) * 17),
        7,
        Paint()..color = AppColors.charcoal,
      );
    }
  }

  void _tick(Canvas canvas, String text, Offset at, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(DotPlotPainter old) =>
      old.picked != picked || old.revealed != revealed || old.values != values;
}
