import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The MACRS percentages, exactly as the handbook prints them on p. 231.
///
/// Keyed by recovery period. Note the lengths: a three year property is
/// depreciated over four years and a five year property over six, because the
/// half-year convention puts half a year at each end. That off-by-one is the
/// thing the table is most often misread over, so it lives in the data rather
/// than in a comment somewhere.
const macrsFactors = <int, List<double>>{
  3: [33.33, 44.45, 14.81, 7.41],
  5: [20.00, 32.00, 19.20, 11.52, 11.52, 5.76],
  7: [14.29, 24.49, 17.49, 12.49, 8.93, 8.92, 8.93, 4.46],
};

/// The whole cost of an asset as one bar, with a slice bitten out of it for
/// every year of depreciation taken and the rest left standing.
///
/// Book value is defined as a subtraction and remembered as a picture. Drawn
/// this way, the two things people hand in instead of it are visibly other
/// parts of the same bar: everything written off so far is the left-hand
/// stretch, and this year's deduction is one slice of it.
class SpentBarPainter extends CustomPainter {
  const SpentBarPainter({
    required this.cost,
    required this.factors,
    required this.through,
    required this.spans,
    required this.selected,
    required this.locked,
    required this.truth,
  });

  /// What the asset cost, which is the whole bar.
  final double cost;

  /// Every year's percentage, for the asset's whole life.
  final List<double> factors;

  /// How many years have been taken so far.
  final int through;

  /// The stretches on offer underneath, as (first year, last year) inclusive.
  /// A stretch past the end of the life is the part still on the books.
  final List<(int, int)> spans;

  final int? selected;
  final bool locked;
  final int truth;

  static const _barHeight = 30.0;
  static const _rowHeight = 34.0;
  static const _padR = 12.0;

  static double heightOf(int spanCount) =>
      _barHeight + 10 + spanCount * _rowHeight + 4;

  /// Measured from the widest amount, since every stretch writes one.
  double get _padL {
    var widest = 0.0;
    for (final (from, to) in spans) {
      final w = _measure(_money(_amountOf(from, to)), AppColors.ink2).width;
      if (w > widest) widest = w;
    }
    return widest + 20;
  }

  double _amountOf(int from, int to) {
    var pct = 0.0;
    for (var y = from; y <= to && y <= factors.length; y++) {
      pct += factors[y - 1];
    }
    return cost * pct / 100;
  }

  /// Where a year boundary falls along the bar, as a fraction.
  double _edge(int year) {
    var pct = 0.0;
    for (var y = 1; y <= year && y <= factors.length; y++) {
      pct += factors[y - 1];
    }
    return pct / 100;
  }

  static TextPainter _measure(String text, Color color) => TextPainter(
        text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
        textDirection: TextDirection.ltr,
      )..layout();

  static String _money(double v) {
    final s = v.round().toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  @override
  void paint(Canvas canvas, Size size) {
    final padL = _padL;
    final full = size.width - padL - _padR;
    double x(double fraction) => padL + fraction * full;

    // The bar. Years already taken are filled, the rest is left open, and
    // every year has its own line so the front-loading is visible.
    final taken = x(_edge(through));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(padL, 0, full, _barHeight),
        const Radius.circular(5),
      ),
      Paint()..color = AppColors.white,
    );
    canvas.drawRect(
      Rect.fromLTRB(padL, 0, taken, _barHeight),
      Paint()..color = AppColors.ink2.withValues(alpha: 0.20),
    );
    for (var y = 1; y < factors.length; y++) {
      final at = x(_edge(y));
      canvas.drawLine(
        Offset(at, 0),
        Offset(at, _barHeight),
        Paint()
          ..color = AppColors.ink3.withValues(alpha: y <= through ? 0.9 : 0.35)
          ..strokeWidth = 1,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(padL, 0, full, _barHeight),
        const Radius.circular(5),
      ),
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    _measure('cost', AppColors.ink2)
        .paint(canvas, Offset(padL - 8 - _measure('cost', AppColors.ink2).width, 9));

    // One bracket per stretch, drawn where it actually falls on the bar.
    for (final (i, (from, to)) in spans.indexed) {
      final y = _barHeight + 10 + i * _rowHeight;
      final chosen = selected == i;
      final isTruth = i == truth;
      final Color color;
      if (locked && isTruth) {
        color = AppColors.forest;
      } else if (locked && chosen) {
        color = AppColors.error;
      } else if (chosen) {
        color = AppColors.ember;
      } else {
        color = AppColors.ink2;
      }
      final heavy = chosen || (locked && isTruth);

      final left = x(_edge(from - 1));
      final right = x(_edge(to));
      final mid = y + 13;
      final stroke = Paint()
        ..color = color
        ..strokeWidth = heavy ? 2 : 1.3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(left, mid - 5), Offset(left, mid + 5), stroke);
      canvas.drawLine(Offset(right, mid - 5), Offset(right, mid + 5), stroke);
      canvas.drawLine(Offset(left, mid), Offset(right, mid), stroke);

      final label = from == to ? 'year $from' : 'years $from to $to';
      final tp = _measure(label, color);
      // Over the bracket where there is room, and beside it where there is
      // not, which is what happens to a one-year stretch late in the life.
      // Beside it means to the RIGHT until that runs off the box, and then to
      // the left, because a narrow stretch at the end of a life had its label
      // half outside the figure.
      if (tp.width + 10 < right - left) {
        tp.paint(canvas, Offset((left + right) / 2 - tp.width / 2, mid - 18));
      } else if (right + 8 + tp.width < size.width - 2) {
        tp.paint(canvas, Offset(right + 8, mid - 6));
      } else {
        tp.paint(canvas, Offset(left - 8 - tp.width, mid - 6));
      }
      _measure(_money(_amountOf(from, to)), color)
          .paint(canvas, Offset(4, mid - 6));
    }
  }

  @override
  bool shouldRepaint(SpentBarPainter old) =>
      old.selected != selected ||
      old.locked != locked ||
      old.cost != cost ||
      old.through != through;
}
