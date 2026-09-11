import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';

/// A vertical curve: a parabola laid between two grades.
@immutable
class Vert {
  const Vert({
    required this.gradeIn,
    required this.gradeOut,
    required this.length,
    this.startElevation = 100,
  });

  /// Percent, positive uphill.
  final double gradeIn;
  final double gradeOut;

  /// Feet along the road, from the PVC to the PVT.
  final double length;
  final double startElevation;

  double get _g1 => gradeIn / 100;
  double get _g2 => gradeOut / 100;

  /// The algebraic difference in the grades, which is what a curve is
  /// really rated by. From plus three to minus one is a change of four,
  /// not two.
  double get change => (gradeIn - gradeOut).abs();

  /// The rate of vertical curvature: feet of curve for each percent of
  /// grade change. A bigger K is a gentler curve.
  double get k => length / math.max(change, 0.0001);

  /// The elevation of the straight tangent produced from the PVC.
  double tangentAt(double x) => startElevation + _g1 * x;

  /// The elevation of the road itself.
  double roadAt(double x) =>
      startElevation + _g1 * x + (_g2 - _g1) / (2 * length) * x * x;

  double get pviElevation => tangentAt(length / 2);

  double get endElevation => roadAt(length);

  /// How far from the PVC the road stops climbing, or stops falling. It is
  /// the midpoint only when the two grades are equal and opposite, and it
  /// is off the curve altogether when they have the same sign.
  double get turningPoint => -_g1 * length / (_g2 - _g1);

  bool get turnsOnTheCurve =>
      turningPoint > 0 && turningPoint < length;

  /// A crest tops out, a sag bottoms out.
  bool get isCrest => gradeIn > gradeOut;
}

/// The curve drawn as a profile: distance along the road across the sheet,
/// elevation up it, the two tangents meeting at the PVI, and the road
/// itself curving away from them.
class RoadProfilePainter extends CustomPainter {
  const RoadProfilePainter({
    required this.vert,
    this.markAt,
    this.showTurning = false,
    this.picked,
    this.answer,
    this.locked = false,
    this.spots = const [],
  });

  final Vert vert;

  /// A station on the curve the round is asking about, in feet from the
  /// PVC. Both the road and the tangent are marked there.
  final double? markAt;

  /// Whether the high or low point is drawn. It is the answer to one of the
  /// items, so it stays off until that round is over.
  final bool showTurning;

  /// Candidate points along the curve, in feet from the PVC, for a round
  /// that asks the reader to choose between them.
  final List<double> spots;
  final int? picked;
  final int? answer;
  final bool locked;

  /// Everything the sheet has to hold. The back tangent produced to a
  /// marked station is part of it: on a sag it dives well below the road,
  /// and leaving it out once ran the mark off the bottom of the panel.
  static List<double> _heights(Vert vert, double? mark) => [
        vert.startElevation,
        vert.pviElevation,
        vert.endElevation,
        if (vert.turnsOnTheCurve) vert.roadAt(vert.turningPoint),
        if (mark != null) vert.roadAt(mark),
        if (mark != null) vert.tangentAt(mark),
      ];

  static double xOf(Size size, Vert vert, double station) =>
      34 + (size.width - 58) * station / vert.length;

  static double yOf(Size size, Vert vert, double elevation, {double? mark}) {
    final heights = _heights(vert, mark);
    final top = heights.reduce(math.max);
    final span = math.max(top - heights.reduce(math.min), 0.5);
    return 34 + (size.height - 80) * (top - elevation) / span;
  }

  /// Where candidate `i` is tapped, on the road itself.
  static Offset spotOf(Size size, Vert vert, List<double> spots, int i) =>
      Offset(xOf(size, vert, spots[i]), yOf(size, vert, vert.roadAt(spots[i])));

  static int? at(Size size, Vert vert, List<double> spots, Offset tap) {
    for (var i = 0; i < spots.length; i++) {
      if ((spotOf(size, vert, spots, i) - tap).distance < 26) return i;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double up(double elevation) => yOf(size, vert, elevation, mark: markAt);

    final pvc = Offset(xOf(size, vert, 0), up(vert.startElevation));
    final pvt = Offset(xOf(size, vert, vert.length), up(vert.endElevation));
    final pvi = Offset(xOf(size, vert, vert.length / 2), up(vert.pviElevation));

    // The two tangents, dashed: they are a construction, not the road.
    void dashed(Offset a, Offset b, Color color, double w) {
      final run = b - a;
      if (run.distance < 1) return;
      final unit = run / run.distance;
      for (var k = 0.0; k < run.distance; k += 8) {
        canvas.drawLine(a + unit * k, a + unit * math.min(k + 4, run.distance),
            Paint()
              ..color = color
              ..strokeWidth = w);
      }
    }

    dashed(pvc, pvi, AppColors.ink3, 1.4);
    dashed(pvi, pvt, AppColors.ink3, 1.4);

    // The road: the parabola itself.
    final road = Path();
    for (var i = 0; i <= 60; i++) {
      final x = vert.length * i / 60;
      final p = Offset(xOf(size, vert, x), up(vert.roadAt(x)));
      if (i == 0) {
        road.moveTo(p.dx, p.dy);
      } else {
        road.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
        road,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6);

    // The station the round is asking about: the gap between the tangent
    // and the road, which is the whole of what a vertical curve is.
    // A mark at the middle of the curve lands on the PVI itself, and the
    // two labels were stacking on one dot.
    final markIsPvi =
        markAt != null && (markAt! - vert.length / 2).abs() < 1;

    if (markAt != null) {
      final x = xOf(size, vert, markAt!);
      final onRoad = up(vert.roadAt(markAt!));
      final onTangent = up(vert.tangentAt(markAt!));
      // The grade line is the one produced from the PVC, and past the PVI
      // that is no longer the dashed line on the sheet. Draw it out to the
      // mark so the upper dot is sitting on something.
      if (markAt! > vert.length / 2) {
        dashed(pvi, Offset(x, onTangent), AppColors.ink3, 1.4);
      }
      canvas.drawLine(
          Offset(x, math.min(onRoad, onTangent) - 6),
          Offset(x, math.max(onRoad, onTangent) + 6),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 1.4);
      if ((onRoad - onTangent).abs() < 10) {
        // At the PVC the two are the same point, and two labels on one dot
        // would read as a collision rather than as the answer.
        canvas.drawCircle(
            Offset(x, onRoad), 4.5, Paint()..color = AppColors.charcoal);
        _write(canvas, size, 'road on the grade line',
            Offset(x + 8, onRoad - 6), AppColors.charcoal);
      } else {
        canvas
          ..drawCircle(Offset(x, onTangent), 4, Paint()..color = AppColors.ink3)
          ..drawCircle(
              Offset(x, onRoad), 4.5, Paint()..color = AppColors.charcoal);
        _write(
            canvas,
            size,
            markIsPvi ? 'grade line, at the PVI' : 'grade line',
            Offset(x + 8, onTangent - 6),
            AppColors.ink3);
        _write(canvas, size, 'road', Offset(x + 8, onRoad - 6),
            AppColors.charcoal);
      }
    }

    // The high or low point, once the round is over.
    if (showTurning && vert.turnsOnTheCurve) {
      final x = xOf(size, vert, vert.turningPoint);
      final y = up(vert.roadAt(vert.turningPoint));
      dashed(Offset(x, y), Offset(x, size.height - 34), AppColors.forest, 1.2);
      // Clear of the marked point that sits on it, which is green too once
      // the round is over.
      _write(canvas, size, vert.isCrest ? 'high point' : 'low point',
          Offset(x - 26, math.max(y - 32, 22)), AppColors.forest);
    }

    // The three stations every vertical curve is held by. A station that
    // also carries one of the round's marked points gets its name hung
    // below, clear of the ring.
    final ringAtStart = spots.any((x) => x.abs() < 1);
    final ringAtEnd = spots.any((x) => (x - vert.length).abs() < 1);
    for (final (at, name, off) in [
      (pvc, 'PVC', ringAtStart ? const Offset(-16, 14) : const Offset(-30, 4)),
      // Above the point unless that is up in the legend's row.
      (pvi, markIsPvi ? '' : 'PVI', Offset(-10, pvi.dy < 46 ? 8 : -20)),
      (pvt, 'PVT', ringAtEnd ? const Offset(-12, 14) : const Offset(10, 4)),
    ]) {
      canvas
        ..drawCircle(at, 4, Paint()..color = AppColors.cream)
        ..drawCircle(
            at,
            4,
            Paint()
              ..color = AppColors.ink2
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6);
      if (name.isNotEmpty) _write(canvas, size, name, at + off, AppColors.ink2);
    }

    // The candidates a round offers, drawn on the road.
    for (var i = 0; i < spots.length; i++) {
      final at = spotOf(size, vert, spots, i);
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
        ..drawCircle(at, 11, Paint()..color = AppColors.cream)
        ..drawCircle(
            at,
            10,
            Paint()
              ..color = tone
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2);
      _write(canvas, size, '${i + 1}', at + const Offset(-3, -6), tone);
    }

    _write(
        canvas,
        size,
        'g1 ${vert.gradeIn > 0 ? '+' : ''}${_num(vert.gradeIn)}%   '
            'g2 ${vert.gradeOut > 0 ? '+' : ''}${_num(vert.gradeOut)}%   '
            'L ${_num(vert.length)} ft',
        const Offset(8, 8),
        AppColors.ink3);
    viewTag(canvas, size, Looking.elevation, note: 'profile along the road');
  }

  @override
  bool shouldRepaint(RoadProfilePainter old) =>
      old.vert != vert ||
      old.markAt != markAt ||
      old.showTurning != showTurning ||
      old.spots != spots ||
      old.picked != picked ||
      old.answer != answer ||
      old.locked != locked;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

void _write(Canvas canvas, Size size, String text, Offset at, Color color) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: AppTheme.mono(size: 10, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
  var x = at.dx;
  if (x + painter.width > size.width - 2) x = size.width - 2 - painter.width;
  if (x < 2) x = 2;
  final patch =
      Rect.fromLTWH(x - 2, at.dy - 1, painter.width + 4, painter.height + 2);
  canvas.drawRect(
      patch, Paint()..color = AppColors.cream.withValues(alpha: 0.92));
  painter.paint(canvas, Offset(x, at.dy));
}
