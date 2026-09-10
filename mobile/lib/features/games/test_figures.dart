import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Which end of the distribution a test is watching.
enum Tail { left, both, right }

/// A small bell curve with one tail arrangement shaded.
///
/// One-tailed against two-tailed is a decision about a sentence, and the exam
/// punishes it with a wrong critical value rather than an obvious error. Drawn
/// side by side the three arrangements are impossible to confuse, and the
/// splitting of alpha across two tails stops being a rule to remember.
class TailPainter extends CustomPainter {
  const TailPainter({required this.tail, required this.color, this.at = 1.4});

  final Tail tail;
  final Color color;

  /// Where the cut sits, in z. Only the picture cares.
  final double at;

  static const _from = -3.0;
  static const _to = 3.0;

  static double _density(double z) => math.exp(-z * z / 2);

  double _x(Size size, double z) =>
      6 + (z - _from) / (_to - _from) * (size.width - 12);

  double _y(Size size, double d) =>
      size.height - 14 - d * (size.height - 24);

  Path _span(Size size, double from, double to) {
    final path = Path()..moveTo(_x(size, from), _y(size, 0));
    for (var i = 0; i <= 60; i++) {
      final z = from + (to - from) * i / 60;
      path.lineTo(_x(size, z), _y(size, _density(z)));
    }
    return path
      ..lineTo(_x(size, to), _y(size, 0))
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final spans = switch (tail) {
      Tail.left => [(_from, -at)],
      Tail.right => [(at, _to)],
      Tail.both => [(_from, -at), (at, _to)],
    };
    for (final (from, to) in spans) {
      canvas.drawPath(
        _span(size, from, to),
        Paint()..color = color.withValues(alpha: 0.42),
      );
    }

    final curve = Path()..moveTo(_x(size, _from), _y(size, _density(_from)));
    for (var i = 0; i <= 120; i++) {
      final z = _from + (_to - _from) * i / 120;
      curve.lineTo(_x(size, z), _y(size, _density(z)));
    }
    canvas.drawPath(
      curve,
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawLine(
      Offset(_x(size, _from), _y(size, 0)),
      Offset(_x(size, _to), _y(size, 0)),
      Paint()
        ..color = AppColors.ink2
        ..strokeWidth = 1.2,
    );
    for (final (from, to) in spans) {
      final cut = from == _from ? to : from;
      canvas.drawLine(
        Offset(_x(size, cut), _y(size, 0)),
        Offset(_x(size, cut), _y(size, _density(cut))),
        Paint()
          ..color = color
          ..strokeWidth = 1.8,
      );
    }
  }

  @override
  bool shouldRepaint(TailPainter old) =>
      old.tail != tail || old.color != color;
}

/// The test statistic and the critical value on one scale, with everything
/// past the critical value shaded.
///
/// Every test in this lesson ends the same way and the lesson says so: bigger
/// means reject. Z, t and chi-square all reduce to one number against one
/// threshold, and drawn on a line there is nothing left to get backwards.
class ScalePainter extends CustomPainter {
  const ScalePainter({
    required this.statistic,
    required this.critical,
    required this.twoTailed,
    required this.to,
    required this.statLabel,
    required this.critLabel,
  });

  final double statistic;
  final double critical;

  /// Two-tailed tests shade both ends and compare on size alone.
  final bool twoTailed;

  /// The right-hand end of the drawn scale.
  final double to;
  final String statLabel;
  final String critLabel;

  static const _padL = 18.0;
  static const _padR = 18.0;

  double get _from => twoTailed ? -to : 0;

  double _x(Size size, double v) =>
      _padL + (v - _from) / (to - _from) * (size.width - _padL - _padR);

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.58;

    final cuts = twoTailed ? [-critical, critical] : [critical];
    for (final cut in cuts) {
      final rect = cut > 0
          ? Rect.fromLTRB(_x(size, cut), y - 22, _x(size, to), y + 6)
          : Rect.fromLTRB(_x(size, _from), y - 22, _x(size, cut), y + 6);
      canvas.drawRect(
        rect,
        Paint()..color = AppColors.error.withValues(alpha: 0.10),
      );
      canvas.drawLine(
        Offset(_x(size, cut), y - 24),
        Offset(_x(size, cut), y + 8),
        Paint()
          ..color = AppColors.error
          ..strokeWidth = 2,
      );
    }
    // Inside the shaded band and hard right, so it never lands on the
    // statistic's own label however far out the statistic is.
    _write(
      canvas,
      'reject',
      Offset(size.width - _padR - 4, y - 17),
      color: AppColors.error,
      align: -1,
    );

    canvas.drawLine(
      Offset(_padL, y),
      Offset(size.width - _padR, y),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 1.6,
    );

    for (final cut in cuts) {
      _write(
        canvas,
        cut < 0 ? '-$critLabel' : critLabel,
        Offset(_x(size, cut), y + 12),
        color: AppColors.error,
      );
    }
    if (twoTailed) {
      canvas.drawLine(
        Offset(_x(size, 0), y - 6),
        Offset(_x(size, 0), y + 6),
        Paint()
          ..color = AppColors.ink2
          ..strokeWidth = 1.2,
      );
      _write(canvas, '0', Offset(_x(size, 0), y + 12), color: AppColors.ink3);
    }

    final sx = _x(size, statistic.clamp(_from, to));
    canvas.drawCircle(Offset(sx, y), 7, Paint()..color = AppColors.charcoal);
    _write(canvas, statLabel, Offset(sx, y - 46), color: AppColors.charcoal);
    canvas.drawLine(
      Offset(sx, y - 32),
      Offset(sx, y - 10),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 1.4,
    );
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
      1 => 0.0,
      -1 => tp.width,
      _ => tp.width / 2,
    };
    tp.paint(canvas, at - Offset(dx, 0));
  }

  @override
  bool shouldRepaint(ScalePainter old) =>
      old.statistic != statistic || old.critical != critical;
}

/// One category of a goodness-of-fit table.
@immutable
class Cell {
  const Cell(this.name, this.observed, this.expected);

  final String name;
  final int observed;
  final int expected;

  /// What this category adds to chi-square.
  double get contribution {
    final gap = observed - expected;
    return gap * gap / expected;
  }
}

/// Observed counts as bars, with the expected count marked across each one.
///
/// A chi-square total is a sum of cells, and which cell did the damage is the
/// part worth seeing. The contribution is the gap SQUARED and then divided by
/// what was expected, so a gap of ten against an expectation of a hundred is a
/// smaller sin than a gap of eight against twenty.
class CellsPainter extends CustomPainter {
  const CellsPainter({
    required this.cells,
    this.picked,
    this.truth,
    this.revealed = false,
  });

  final List<Cell> cells;
  final int? picked;
  final int? truth;
  final bool revealed;

  static const _padT = 14.0;
  static const _padB = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final tallest = cells
        .map((c) => math.max(c.observed, c.expected))
        .reduce(math.max)
        .toDouble();
    final slot = size.width / cells.length;
    final barW = math.min(slot * 0.56, 46.0);
    final floor = size.height - _padB;

    // Room at the top for the count that sits above the tallest thing on the
    // chart. Scaled by a flat factor instead, the biggest bar's number was
    // drawn half outside the box.
    const labelRoom = 24.0;
    double heightOf(num v) => v / tallest * (floor - _padT - labelRoom);

    for (final (i, cell) in cells.indexed) {
      final cx = slot * (i + 0.5);
      final isTruth = revealed && truth == i;
      final isWrong = revealed && picked == i && truth != i;
      final color = isTruth
          ? AppColors.forest
          : isWrong
          ? AppColors.error
          : picked == i
          ? AppColors.ember
          : AppColors.sunbeam;

      final h = heightOf(cell.observed);
      final rect = Rect.fromLTWH(cx - barW / 2, floor - h, barW, h);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = color.withValues(alpha: 0.5),
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()
          ..color = picked == i || isTruth || isWrong
              ? color
              : AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = picked == i || isTruth || isWrong ? 2 : 1.2,
      );

      // What the model said to expect, drawn across the bar it applies to.
      final ey = floor - heightOf(cell.expected);
      canvas.drawLine(
        Offset(cx - barW / 2 - 5, ey),
        Offset(cx + barW / 2 + 5, ey),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2.2,
      );

      // Above whichever is higher, the bar or the line it is being compared
      // with. Pinned to the bar alone, a count below its expected value was
      // printed straight through the expected line.
      _write(
        canvas,
        '${cell.observed}',
        Offset(cx, math.min(rect.top, ey) - 12),
        color: AppColors.ink3,
      );
      _write(canvas, cell.name, Offset(cx, floor + 6), color: AppColors.ink3);
    }
  }

  void _write(Canvas canvas, String text, Offset at, {required Color color}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, 0));
  }

  @override
  bool shouldRepaint(CellsPainter old) =>
      old.picked != picked || old.revealed != revealed || old.cells != cells;
}
