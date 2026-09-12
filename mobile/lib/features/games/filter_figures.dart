import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A rectangular filter bed, seen from above, and the rate the water goes
/// down through it.
@immutable
class FilterBed {
  const FilterBed({
    required this.length,
    required this.width,
    required this.flowGpm,
    this.rapid = true,
  });

  /// Feet, feet, gallons a minute.
  final double length;
  final double width;
  final double flowGpm;

  /// Rapid sand runs a few gallons a minute to the square foot. Slow sand
  /// runs a fiftieth of that.
  final bool rapid;

  double get area => length * width;

  /// Gallons a minute for every square foot of bed.
  double get loadingRate => area <= 0 ? 0 : flowGpm / area;

  /// What the rate would be if only one dimension were used, which is the
  /// mistake the units catch.
  double get perFootOfLength => length <= 0 ? 0 : flowGpm / length;

  bool get withinRapidRange => loadingRate >= 2 && loadingRate <= 10;
}

/// The bed in plan with its dimensions, and the loading rate written on it
/// once the round is answered.
class FilterPainter extends CustomPainter {
  const FilterPainter({required this.bed, this.answered = false});

  final FilterBed bed;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 46.0;
    final top = 46.0;
    final room = math.min(size.width - 110, 210.0);
    final scale = room / math.max(bed.length, 1);
    final wide = bed.length * scale;
    final tall = math.min(bed.width * scale, size.height - 120);

    final bedRect = Rect.fromLTWH(left, top, wide, tall);
    canvas
      ..drawRect(bedRect, Paint()..color = AppColors.ink2.withValues(alpha: 0.30))
      ..drawRect(
          bedRect,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);
    // Sand, suggested by a few strokes.
    for (var x = bedRect.left + 6; x < bedRect.right - 4; x += 12) {
      canvas.drawLine(
          Offset(x, bedRect.top + 4),
          Offset(x, bedRect.bottom - 4),
          Paint()
            ..color = AppColors.ink3.withValues(alpha: 0.35)
            ..strokeWidth = 1);
    }

    writeOn(canvas, size, '${bed.length.toStringAsFixed(0)} ft',
        Offset(bedRect.center.dx - 16, bedRect.bottom + 6), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, '${bed.width.toStringAsFixed(0)} ft',
        Offset(4, bedRect.center.dy - 6), AppColors.ink3, fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${bed.flowGpm.toStringAsFixed(0)} gallons a minute onto the bed',
        Offset(left - 30, 10),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        bed.rapid ? 'a rapid sand filter' : 'a slow sand filter',
        Offset(left - 30, 24),
        AppColors.ink3,
        fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'the rate through the sand comes out',
          Offset(left - 30, size.height - 30), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer',
          Offset(left - 30, size.height - 16), AppColors.ink3, fontSize: 9.5);
      return;
    }

    writeOn(
        canvas,
        size,
        '${bed.area.toStringAsFixed(0)} square feet of bed, so '
            '${bed.loadingRate.toStringAsFixed(1)} gpm to the square foot',
        Offset(left - 30, size.height - 30),
        AppColors.ember,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        bed.rapid
            ? (bed.withinRapidRange
                ? 'inside the usual two to ten for rapid sand'
                : 'outside the usual two to ten for rapid sand')
            : 'slow sand runs nearer a tenth of a gallon',
        Offset(left - 30, size.height - 16),
        bed.rapid && !bed.withinRapidRange
            ? AppColors.error
            : AppColors.forest,
        fontSize: 9.5);

    viewTag(canvas, size, Looking.plan, note: 'the bed');
  }

  @override
  bool shouldRepaint(FilterPainter old) =>
      old.bed != bed || old.answered != answered;
}
