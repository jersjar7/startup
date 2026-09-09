import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One region under a normal curve, in z units.
///
/// A region can be made of more than one piece, because "outside the tolerance
/// band" is a single quantity the handbook has a single column for even though
/// it is drawn as two tails.
@immutable
class CurveRegion {
  const CurveRegion({required this.spans, required this.column});

  /// Each span is a pair of z bounds, the lower inclusive and the upper
  /// exclusive, so that a finger landing exactly on a threshold belongs to one
  /// region rather than to both. The far right edge is inclusive, since there
  /// is nothing beyond it to belong to.
  final List<(double, double)> spans;

  /// Which column of the unit normal table hands you this area directly, or
  /// the arithmetic that gets you there from one that does.
  final String column;

  bool holds(double z) => spans.any(
    (s) => z >= s.$1 && (s.$2 >= zMax ? z <= s.$2 : z < s.$2),
  );
}

/// The curve is drawn over four standard deviations either side, which is as
/// much of a normal distribution as anyone ever draws.
const zMin = -4.0;
const zMax = 4.0;

/// A bell curve with thresholds drawn on it and its regions shaded.
///
/// The z-score is arithmetic and belongs on paper. WHICH area the question
/// wants is a reading decision, and it is the one the exam charges for: the
/// same curve and the same threshold answer "how many fail" and "how many
/// pass" with different halves of the picture.
class NormalPainter extends CustomPainter {
  const NormalPainter({
    required this.regions,
    required this.cuts,
    this.picked,
    this.truth,
    this.revealed = false,
    this.labels = const [],
  });

  /// The tappable regions, left to right.
  final List<CurveRegion> regions;

  /// Where the vertical threshold lines sit, in z.
  final List<double> cuts;

  final int? picked;
  final int? truth;
  final bool revealed;

  /// What to write under each cut, in the problem's own units.
  final List<String> labels;

  static const _padL = 12.0;
  static const _padR = 12.0;
  static const _padT = 16.0;
  static const _padB = 42.0;

  static double _density(double z) => math.exp(-z * z / 2);

  double _x(Size size, double z) =>
      _padL + (z - zMin) / (zMax - zMin) * (size.width - _padL - _padR);

  double _y(Size size, double d) =>
      size.height - _padB - d * (size.height - _padB - _padT);

  /// The filled outline of one span of the curve, from the baseline up.
  Path _spanPath(Size size, double from, double to) {
    final path = Path()..moveTo(_x(size, from), _y(size, 0));
    const steps = 120;
    for (var i = 0; i <= steps; i++) {
      final z = from + (to - from) * i / steps;
      path.lineTo(_x(size, z), _y(size, _density(z)));
    }
    return path
      ..lineTo(_x(size, to), _y(size, 0))
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final (i, region) in regions.indexed) {
      final isTruth = revealed && truth == i;
      final isWrong = revealed && picked == i && truth != i;
      final Color? fill;
      if (isTruth) {
        fill = AppColors.forest.withValues(alpha: 0.30);
      } else if (isWrong) {
        fill = AppColors.error.withValues(alpha: 0.28);
      } else if (!revealed && picked == i) {
        fill = AppColors.ember.withValues(alpha: 0.30);
      } else {
        fill = null;
      }
      if (fill == null) continue;
      for (final (from, to) in region.spans) {
        final path = _spanPath(size, from, to);
        canvas.drawPath(path, Paint()..color = fill);
        // A tail can be four percent of the curve, and a wash that thin is
        // hard to find on a phone. The outline is what makes a small right
        // answer as visible as a large wrong one.
        if (isTruth) {
          canvas.drawPath(
            path,
            Paint()
              ..color = AppColors.forest
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }

    final curve = Path()..moveTo(_x(size, zMin), _y(size, _density(zMin)));
    const steps = 240;
    for (var i = 0; i <= steps; i++) {
      final z = zMin + (zMax - zMin) * i / steps;
      curve.lineTo(_x(size, z), _y(size, _density(z)));
    }
    canvas.drawPath(
      curve,
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawLine(
      Offset(_x(size, zMin), _y(size, 0)),
      Offset(_x(size, zMax), _y(size, 0)),
      Paint()
        ..color = AppColors.ink2
        ..strokeWidth = 1.4,
    );

    // The mean, which is the one landmark on the picture that is never the
    // answer and is always worth seeing.
    canvas.drawLine(
      Offset(_x(size, 0), _y(size, 0)),
      Offset(_x(size, 0), _y(size, _density(0))),
      Paint()
        ..color = AppColors.ink3.withValues(alpha: 0.45)
        ..strokeWidth = 1,
    );

    for (final (i, cut) in cuts.indexed) {
      canvas.drawLine(
        Offset(_x(size, cut), _y(size, 0) + 4),
        Offset(_x(size, cut), _y(size, _density(cut)) - 4),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2.2,
      );
      if (i < labels.length) {
        _write(
          canvas,
          labels[i],
          Offset(_x(size, cut), _y(size, 0) + 15),
          color: AppColors.ember,
        );
      }
    }

    // A row of its own. A cut close to the mean would otherwise write over
    // this one, and a threshold near the mean is a perfectly normal round.
    _write(
      canvas,
      'mean',
      Offset(_x(size, 0), _y(size, 0) + 28),
      color: AppColors.ink3,
    );
  }

  void _write(Canvas canvas, String text, Offset at, {required Color color}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, 0));
  }

  /// Which region a tap at [dx] landed in, or null for none.
  static int? regionAt(double dx, double width, List<CurveRegion> regions) {
    final z = zMin +
        (dx - _padL) / (width - _padL - _padR) * (zMax - zMin);
    for (final (i, region) in regions.indexed) {
      if (region.holds(z)) return i;
    }
    return null;
  }

  @override
  bool shouldRepaint(NormalPainter old) =>
      old.picked != picked || old.revealed != revealed || old.cuts != cuts;
}
