import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A piece of ground with one kind of cover on it.
@immutable
class Patch {
  const Patch({
    required this.cover,
    required this.acres,
    required this.coefficient,
  });

  final String cover;
  final double acres;

  /// C, the fraction of the rain that runs off rather than soaking in.
  /// Paving is near 0.95 and woodland near 0.15.
  final double coefficient;

  /// What this patch contributes to the peak: C times the area. The
  /// intensity is common to the whole catchment and cancels out of any
  /// comparison.
  double get share => coefficient * acres;
}

/// A catchment made of one or more patches draining to the same inlet.
@immutable
class Catchment {
  const Catchment(this.patches);

  final List<Patch> patches;

  double get acres =>
      patches.fold(0.0, (sum, p) => sum + p.acres);

  /// The area-weighted runoff coefficient, which is the only correct way to
  /// combine them. Averaging the coefficients without weighting is the trap
  /// this lesson names.
  double get weighted =>
      patches.fold(0.0, (sum, p) => sum + p.share) / acres;

  /// What a plain average of the coefficients would have given, for the
  /// feedback to contrast against.
  double get unweighted =>
      patches.fold(0.0, (sum, p) => sum + p.coefficient) / patches.length;

  double peakAt(double intensity) => intensity * acres * weighted;
}

/// The catchment seen from above, with each patch drawn to its share of the
/// area. Drawing them to scale is the whole point: the reader can see which
/// cover has the bigger say before any arithmetic happens.
class CatchmentPainter extends CustomPainter {
  const CatchmentPainter({
    required this.catchment,
    this.intensity,
    this.showWeighted = false,
    this.tag,
    this.scaleTo,
  });

  final Catchment catchment;

  /// Written on the plan when the round gives one.
  final double? intensity;
  final bool showWeighted;
  final String? tag;

  /// The acreage that fills the full width. When two catchments are shown
  /// together this is the larger of the two, so the smaller one is actually
  /// drawn smaller. Without it both filled their panel and a comparison of
  /// areas was impossible to see.
  final double? scaleTo;

  static const _pad = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final top = 30.0;
    final bottom = size.height - 38;
    final left = _pad + 8;
    final full = size.width - _pad;
    final right = left +
        (full - left) * catchment.acres / (scaleTo ?? catchment.acres);
    var x = left;

    for (final patch in catchment.patches) {
      final width = (right - left) * patch.acres / catchment.acres;
      final rect = Rect.fromLTRB(x, top, x + width, bottom);
      // Darker ground sheds more, and the darkness is PROPORTIONAL to the
      // coefficient with no floor under it, so the quantity of ink on a
      // block is C times A: the thing being compared, drawn.
      canvas
        ..drawRect(
            rect,
            Paint()
              ..color = AppColors.charcoal
                  .withValues(alpha: 0.60 * patch.coefficient))
        ..drawRect(
            rect,
            Paint()
              ..color = AppColors.ink2
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.3);
      writeOn(canvas, size, patch.cover, Offset(x + 5, top + 6),
          AppColors.charcoal, fontSize: 9.5);
      writeOn(canvas, size, 'C ${patch.coefficient.toStringAsFixed(2)}',
          Offset(x + 5, top + 20), AppColors.charcoal, fontSize: 9.5);
      writeOn(canvas, size, '${_num(patch.acres)} acres',
          Offset(x + 5, bottom - 16), AppColors.ink2, fontSize: 9.5);
      x += width;
    }

    // Everything drains to one inlet, which is what lets the shares be
    // added at all.
    final inletAt = Offset((left + right) / 2, bottom + 10);
    canvas
      ..drawLine(
          Offset(inletAt.dx, bottom),
          inletAt,
          Paint()
            ..color = AppColors.info
            ..strokeWidth = 2)
      ..drawCircle(inletAt, 4.5, Paint()..color = AppColors.info);
    writeOn(canvas, size, 'one inlet', Offset(inletAt.dx + 8, bottom + 4),
        AppColors.info, fontSize: 9);

    if (tag != null) {
      writeOn(canvas, size, tag!, const Offset(8, 8), AppColors.ember,
          fontSize: 9);
    }
    if (intensity != null) {
      writeOn(canvas, size, 'rain ${_num(intensity!)} in/hr',
          Offset(size.width - 90, 8), AppColors.ink3, fontSize: 9);
    }
    if (showWeighted) {
      writeOn(
          canvas,
          size,
          'area weighted C ${catchment.weighted.toStringAsFixed(3)}',
          Offset(8, size.height - 16),
          AppColors.forest,
          fontSize: 9.5);
    }
    viewTag(canvas, size, Looking.plan, note: 'the catchment');
  }

  @override
  bool shouldRepaint(CatchmentPainter old) =>
      old.catchment != catchment ||
      old.intensity != intensity ||
      old.showWeighted != showWeighted ||
      old.tag != tag ||
      old.scaleTo != scaleTo;
}

/// A storm falling on a watershed with a curve number, and what becomes of
/// it under the SCS method.
@immutable
class Soak {
  const Soak({required this.curveNumber, required this.rain});

  /// CN, from about 30 for woods on sand to 98 for paving.
  final double curveNumber;

  /// P, the depth of the storm in inches.
  final double rain;

  /// The most the ground could hold if the storm went on forever.
  double get retention => 1000 / curveNumber - 10;

  /// What the ground takes before anything at all runs off: wetting the
  /// leaves, filling the puddles, soaking the first of it in.
  double get abstraction => 0.2 * retention;

  /// The depth that runs off, in INCHES. Not a discharge.
  double get runoff {
    if (rain <= abstraction) return 0;
    final net = rain - abstraction;
    return net * net / (rain + 0.8 * retention);
  }

  double get fraction => rain == 0 ? 0 : runoff / rain;
}

/// The storm as a column, with the part the ground takes first marked off
/// at the bottom. Nothing runs off until the column clears that mark.
class SoakPainter extends CustomPainter {
  const SoakPainter({required this.soak, this.answered = false});

  final Soak soak;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height - 40;
    final topY = 34.0;
    // Tall enough to show both the storm and the threshold, whichever is
    // the greater, with a little air above.
    final tallest = math.max(soak.rain, soak.abstraction) * 1.25;
    final perInch = (baseY - topY) / math.max(tallest, 0.1);
    final left = size.width / 2 - 92;
    final width = 74.0;

    // The storm.
    final rainTop = baseY - soak.rain * perInch;
    canvas
      ..drawRect(Rect.fromLTRB(left, rainTop, left + width, baseY), waterFill)
      ..drawRect(
          Rect.fromLTRB(left, rainTop, left + width, baseY),
          Paint()
            ..color = AppColors.info
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);
    writeOn(canvas, size, 'the storm', Offset(left + 4, rainTop - 15),
        AppColors.info, fontSize: 9.5);
    writeOn(canvas, size, '${_num(soak.rain)} in',
        Offset(left + 4, rainTop + 5), AppColors.info, fontSize: 10);

    // The threshold the ground takes first.
    final markY = baseY - soak.abstraction * perInch;
    for (var x = left - 14.0; x < left + width + 96; x += 9) {
      canvas.drawLine(
          Offset(x, markY),
          Offset(x + 5, markY),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 1.8);
    }
    // On a paved catchment the threshold is a whisker off the ground, so
    // the label gets lifted clear of the hatching rather than sitting in it.
    final labelY = markY > baseY - 16 ? baseY - 30 : markY - 6;
    writeOn(
        canvas,
        size,
        'the ground takes the first ${soak.abstraction.toStringAsFixed(2)} in',
        Offset(left + width + 8, labelY),
        AppColors.ember,
        fontSize: 9);

    groundLine(canvas, Offset(left - 20, baseY),
        Offset(size.width - 12, baseY));

    if (answered) {
      final runTop = baseY - soak.runoff * perInch;
      final runLeft = left + width + 18;
      canvas
        ..drawRect(
            Rect.fromLTRB(runLeft, runTop, runLeft + 44, baseY),
            Paint()..color = AppColors.forest.withValues(alpha: 0.25))
        ..drawRect(
            Rect.fromLTRB(runLeft, runTop, runLeft + 44, baseY),
            Paint()
              ..color = AppColors.forest
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6);
      writeOn(
          canvas,
          size,
          soak.runoff <= 0
              ? 'nothing runs off'
              : 'runs off ${soak.runoff.toStringAsFixed(2)} in',
          Offset(runLeft - 2, math.max(runTop - 15, 12)),
          AppColors.forest,
          fontSize: 9.5);
    }

    writeOn(canvas, size, 'CN ${_num(soak.curveNumber)}',
        const Offset(8, 8), AppColors.ink2, fontSize: 10);
    writeOn(canvas, size, 'S ${soak.retention.toStringAsFixed(2)} in',
        const Offset(8, 22), AppColors.ink3, fontSize: 9);
    viewTag(canvas, size, Looking.elevation, note: 'depths over the ground');
  }

  @override
  bool shouldRepaint(SoakPainter old) =>
      old.soak != soak || old.answered != answered;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
