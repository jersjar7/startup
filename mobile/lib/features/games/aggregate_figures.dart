import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The three weighings a specific gravity test takes, which are the only
/// three numbers any formula on this page is built from.
enum Weighing { dry, ssd, submerged }

extension WeighingWords on Weighing {
  /// The letter the handbook uses.
  String get letter => switch (this) {
        Weighing.dry => 'A',
        Weighing.ssd => 'B',
        Weighing.submerged => 'C',
      };

  String get title => switch (this) {
        Weighing.dry => 'oven dry',
        Weighing.ssd => 'saturated, surface dry',
        Weighing.submerged => 'submerged',
      };

  String get plain => switch (this) {
        Weighing.dry => 'pores empty, weighed in air',
        Weighing.ssd => 'pores full, surface wiped, weighed in air',
        Weighing.submerged => 'pores full, weighed hanging in water',
      };
}

/// One aggregate sample, weighed three ways.
@immutable
class Sample {
  const Sample({required this.dry, required this.ssd, required this.submerged});

  /// Grams.
  final double dry;
  final double ssd;
  final double submerged;

  double weight(Weighing which) => switch (which) {
        Weighing.dry => dry,
        Weighing.ssd => ssd,
        Weighing.submerged => submerged,
      };

  /// Water the pores hold, as a percentage of the dry mass.
  double get absorption => (ssd - dry) / dry * 100;

  /// The whole particle, pores included, is what displaced this much water.
  double get bulkDry => dry / (ssd - submerged);
  double get bulkSsd => ssd / (ssd - submerged);

  /// The apparent one leaves the water-filled pores out of the volume.
  double get apparent => dry / (dry - submerged);
}

/// The same stone drawn in each of its three states, with the balance it is
/// weighed on.
class SamplePainter extends CustomPainter {
  const SamplePainter({
    required this.sample,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final Sample sample;
  final Weighing? picked;
  final Weighing? answer;
  final bool locked;

  /// The panel is three columns, one state each.
  static Rect cellOf(Size size, Weighing which) {
    final i = Weighing.values.indexOf(which);
    final wide = size.width / 3;
    return Rect.fromLTWH(wide * i, 0, wide, size.height);
  }

  /// Which state a tap landed on.
  static Weighing? at(Size size, Offset tap) {
    if (tap.dy < 0 || tap.dy > size.height) return null;
    final i = (tap.dx / (size.width / 3)).floor().clamp(0, 2);
    return Weighing.values[i];
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final which in Weighing.values) {
      final cell = cellOf(size, which);
      final Color tone;
      if (locked && answer == which) {
        tone = AppColors.forest;
      } else if (locked && picked == which) {
        tone = AppColors.error;
      } else if (picked == which) {
        tone = AppColors.ember;
      } else {
        tone = AppColors.charcoal;
      }

      final middle = Offset(cell.center.dx, cell.top + 84);
      if (which == Weighing.submerged) _tank(canvas, cell);
      _stone(canvas, middle, which, tone);

      _write(canvas, size, which.letter, Offset(cell.left + 8, cell.top + 6),
          tone, 13);
      _write(canvas, size, which.title, Offset(cell.left + 6, cell.top + 24),
          AppColors.ink3, 9);
      _write(
        canvas,
        size,
        '${sample.weight(which).round()} g',
        Offset(cell.center.dx - 20, cell.bottom - 34),
        tone,
        11,
      );
      _write(canvas, size, which.plain, Offset(cell.left + 4, cell.bottom - 18),
          AppColors.ink3, 8);
    }
  }

  /// The water it hangs in, for the third weighing.
  void _tank(Canvas canvas, Rect cell) {
    final tank = Rect.fromLTRB(
        cell.left + 10, cell.top + 56, cell.right - 10, cell.bottom - 40);
    canvas
      ..drawRect(tank, Paint()..color = AppColors.info.withValues(alpha: 0.12))
      ..drawRect(
        tank,
        Paint()
          ..color = AppColors.info.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
  }

  /// A stone with pores in it: empty, full, or full and under water.
  void _stone(Canvas canvas, Offset at, Weighing which, Color tone) {
    final body = Path()
      ..moveTo(at.dx - 26, at.dy + 12)
      ..lineTo(at.dx - 18, at.dy - 14)
      ..lineTo(at.dx + 6, at.dy - 20)
      ..lineTo(at.dx + 26, at.dy - 2)
      ..lineTo(at.dx + 16, at.dy + 16)
      ..close();
    canvas
      ..drawPath(body, Paint()..color = AppColors.sunbeam.withValues(alpha: 0.35))
      ..drawPath(
        body,
        Paint()
          ..color = tone
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

    // The pores, which are what the whole page is about: empty when it is
    // dry, full in the other two.
    const spots = [Offset(-12, -2), Offset(2, -8), Offset(8, 6), Offset(-4, 8)];
    for (final s in spots) {
      final centre = at + s;
      canvas.drawCircle(
        centre,
        3.4,
        Paint()
          ..color = which == Weighing.dry
              ? AppColors.cream
              : AppColors.info.withValues(alpha: 0.75),
      );
      canvas.drawCircle(
        centre,
        3.4,
        Paint()
          ..color = AppColors.ink3
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // A film of surface water is the difference between SSD and wetter than
    // SSD, so nothing is drawn on the outside of the SSD stone on purpose.
    if (which == Weighing.submerged) {
      canvas.drawLine(
        Offset(at.dx, at.dy - 20),
        Offset(at.dx, at.dy - 38),
        Paint()
          ..color = AppColors.ink3
          ..strokeWidth = 1,
      );
    }
  }

  void _write(Canvas canvas, Size size, String text, Offset at, Color color,
      double points) {
    final painter = TextPainter(
      text:
          TextSpan(text: text, style: AppTheme.mono(size: points, color: color)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width / 3 - 6);
    var x = at.dx;
    if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
    if (x < 2) x = 2;
    painter.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(SamplePainter old) =>
      old.sample != sample ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}

/// A sieve analysis: how much of a sand passes each standard sieve.
@immutable
class Grading {
  const Grading({required this.name, required this.passing});

  final String name;

  /// Percent passing, in the sieve order of [sieves]: coarsest first.
  final List<double> passing;

  /// The standard sieves for a sand, coarse to fine, in millimeters.
  static const sieves = <double>[9.5, 4.75, 2.36, 1.18, 0.6, 0.3, 0.15];
  static const names = <String>[
    '3/8',
    'No 4',
    'No 8',
    'No 16',
    'No 30',
    'No 50',
    'No 100'
  ];

  /// Cumulative percent retained on each sieve.
  List<double> get retained => [for (final p in passing) 100 - p];

  /// The fineness modulus, worked out rather than declared: the cumulative
  /// retained percentages added up and divided by a hundred.
  double get fm => retained.reduce((a, b) => a + b) / 100;

  /// True when no sieve holds back a big jump, which is what a gap in the
  /// sizes looks like in the numbers.
  double get biggestJump {
    var most = 0.0;
    for (var i = 1; i < passing.length; i++) {
      final jump = passing[i - 1] - passing[i];
      if (jump > most) most = jump;
    }
    return most;
  }
}

/// Two gradings on one set of axes, drawn the way a sieve analysis is always
/// drawn: percent passing up the side, sieve size along the bottom, coarse on
/// the left.
class GradingPainter extends CustomPainter {
  const GradingPainter({
    required this.gradings,
    this.picked,
    this.answer,
    this.locked = false,
  });

  final List<Grading> gradings;
  final int? picked;
  final int? answer;
  final bool locked;

  static Rect plot(Size size) =>
      Rect.fromLTRB(34, 28, size.width - 12, size.height - 30);

  /// Where a sieve and a percentage land. The size axis is logarithmic,
  /// which is how every gradation chart in the world is drawn.
  static Offset at(Size size, int sieve, double passing) {
    final box = plot(size);
    final most = math.log(Grading.sieves.first);
    final least = math.log(Grading.sieves.last);
    final on = (math.log(Grading.sieves[sieve]) - most) / (least - most);
    return Offset(box.left + box.width * on,
        box.bottom - box.height * passing / 100);
  }

  static List<Offset> pointsOf(Size size, Grading g) =>
      [for (var i = 0; i < g.passing.length; i++) at(size, i, g.passing[i])];

  /// Which curve a tap is nearest.
  static int? nearest(Size size, List<Grading> gradings, Offset tap,
      {double within = 30}) {
    int? best;
    var bestGap = within;
    for (var i = 0; i < gradings.length; i++) {
      for (final p in pointsOf(size, gradings[i])) {
        final gap = (p - tap).distance;
        if (gap < bestGap) {
          bestGap = gap;
          best = i;
        }
      }
    }
    return best;
  }

  static const _tones = [AppColors.info, AppColors.ember];

  @override
  void paint(Canvas canvas, Size size) {
    final box = plot(size);
    final axis = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.4;
    canvas
      ..drawLine(box.bottomLeft, box.bottomRight, axis)
      ..drawLine(box.bottomLeft, box.topLeft, axis);

    for (final pc in [0, 50, 100]) {
      final y = box.bottom - box.height * pc / 100;
      canvas.drawLine(
        Offset(box.left, y),
        Offset(box.right, y),
        Paint()..color = AppColors.line..strokeWidth = 0.8,
      );
      _write(canvas, '$pc', Offset(6, y - 6), AppColors.ink3);
    }
    _write(canvas, 'percent passing', const Offset(2, 2), AppColors.ink3);
    for (var i = 0; i < Grading.sieves.length; i += 2) {
      final x = at(size, i, 0).dx;
      _write(canvas, Grading.names[i], Offset(x - 12, box.bottom + 5),
          AppColors.ink3);
    }
    _write(canvas, 'coarse', Offset(box.left, box.bottom + 17), AppColors.ink3);
    _write(canvas, 'fine', Offset(box.right - 22, box.bottom + 17),
        AppColors.ink3);

    for (var i = 0; i < gradings.length; i++) {
      final Color tone;
      if (locked && answer == i) {
        tone = AppColors.forest;
      } else if (locked && picked == i) {
        tone = AppColors.error;
      } else {
        tone = _tones[i % _tones.length];
      }
      final points = pointsOf(size, gradings[i]);
      final path = Path();
      for (var j = 0; j < points.length; j++) {
        j == 0
            ? path.moveTo(points[j].dx, points[j].dy)
            : path.lineTo(points[j].dx, points[j].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = tone
          ..style = PaintingStyle.stroke
          ..strokeWidth = picked == i || (locked && answer == i) ? 3.4 : 2.2,
      );
      for (final p in points) {
        canvas.drawCircle(p, 3, Paint()..color = tone);
      }
    }
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
  bool shouldRepaint(GradingPainter old) =>
      old.gradings != gradings ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}
