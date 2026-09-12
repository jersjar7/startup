import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// One of the three phases a soil sample is made of, plus the two totals a
/// ratio can be taken against.
enum Phase { air, water, solids, voids, whole }

/// A soil sample described the way the lab describes it, with everything
/// else worked out rather than written down beside the drawing.
@immutable
class Soil {
  const Soil({
    required this.gs,
    required this.water,
    required this.voidRatio,
  });

  /// Specific gravity of the solids.
  final double gs;

  /// Water content, as a decimal and not a percentage.
  final double water;

  /// Void ratio: the volume of voids over the volume of SOLIDS.
  final double voidRatio;

  static const unitWeightOfWater = 62.4;

  /// Porosity: the same voids, but over the whole volume this time.
  double get porosity => voidRatio / (1 + voidRatio);

  /// Degree of saturation, from the master relationship.
  double get saturation => water * gs / voidRatio;

  bool get saturated => (saturation - 1).abs() < 0.005;

  double get dryUnitWeight => gs * unitWeightOfWater / (1 + voidRatio);
  double get totalUnitWeight => dryUnitWeight * (1 + water);
  double get saturatedUnitWeight =>
      (gs + voidRatio) * unitWeightOfWater / (1 + voidRatio);
  double get submergedUnitWeight => saturatedUnitWeight - unitWeightOfWater;
}

/// The phase diagram: volumes stacked on the left, weights on the right, air
/// at the top and solids at the bottom. Once the round is over, the two
/// parts the asked ratio compares are picked out, one filled and one ringed,
/// so the reader can see which is over which.
class PhaseDiagramPainter extends CustomPainter {
  const PhaseDiagramPainter({
    required this.soil,
    this.over,
    this.under,
    this.answered = false,
  });

  final Soil soil;

  /// The top of the ratio and the bottom of it.
  final Phase? over;
  final Phase? under;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 78.0;
    final right = size.width - 78;
    final top = 32.0;
    final bottom = size.height - 34;
    final height = bottom - top;

    // The three blocks, in proportion to the sample they describe.
    final solidsPart = 1 / (1 + soil.voidRatio);
    final waterPart = (1 - solidsPart) * math.min(soil.saturation, 1);
    final airPart = 1 - solidsPart - waterPart;

    final airTo = top + height * airPart;
    final waterTo = airTo + height * waterPart;

    final blocks = <(Phase, double, double, String)>[
      (Phase.air, top, airTo, 'air'),
      (Phase.water, airTo, waterTo, 'water'),
      (Phase.solids, waterTo, bottom, 'solids'),
    ];

    for (final (phase, a, b, name) in blocks) {
      if (b - a < 0.5) continue;
      final rect = Rect.fromLTRB(left, a, right, b);
      final fill = switch (phase) {
        Phase.air => AppColors.cream,
        Phase.water => AppColors.info.withValues(alpha: 0.22),
        _ => AppColors.ink2.withValues(alpha: 0.35),
      };
      canvas
        ..drawRect(rect, Paint()..color = fill)
        ..drawRect(
            rect,
            Paint()
              ..color = AppColors.charcoal
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4);
      writeOn(canvas, size, name, Offset(left + 8, (a + b) / 2 - 6),
          AppColors.ink3, fontSize: 9.5);

      // Each block is measured on both sides, which is the whole point of
      // the drawing: a volume on the left, a weight on the right, and air
      // weighing nothing at all.
      final middle = (a + b) / 2 - 6;
      final volume = switch (phase) {
        Phase.air => 'Va',
        Phase.water => 'Vw',
        _ => 'Vs',
      };
      final weight = switch (phase) {
        Phase.air => 'nothing',
        Phase.water => 'Ww',
        _ => 'Ws',
      };
      writeOn(canvas, size, volume, Offset(left - 26, middle), AppColors.ink3,
          fontSize: 9.5);
      writeOn(canvas, size, weight, Offset(right + 6, middle), AppColors.ink3,
          fontSize: 9.5);
    }

    // What each side of the drawing measures.
    writeOn(canvas, size, 'VOLUME', Offset(4, top - 18), AppColors.ink3,
        fontSize: 9.5);
    writeOn(canvas, size, 'WEIGHT', Offset(right - 6, top - 18),
        AppColors.ink3, fontSize: 9.5);
    writeOn(canvas, size, 'the whole sample', Offset(left - 4, bottom + 8),
        AppColors.ink3, fontSize: 9.5);

    if (!answered || over == null || under == null) return;

    // The top of the ratio, filled, and the bottom of it, bracketed.
    _span(canvas, size, over!, left - 40, top, airTo, waterTo, bottom,
        AppColors.ember, 'over this', true);
    _span(canvas, size, under!, right + 34, top, airTo, waterTo, bottom,
        AppColors.forest, 'under this', false);
  }

  void _span(Canvas canvas, Size size, Phase phase, double x, double top,
      double airTo, double waterTo, double bottom, Color tone, String label,
      bool onTheLeft) {
    final (a, b) = switch (phase) {
      Phase.air => (top, airTo),
      Phase.water => (airTo, waterTo),
      Phase.solids => (waterTo, bottom),
      Phase.voids => (top, waterTo),
      Phase.whole => (top, bottom),
    };
    final ink = Paint()
      ..color = tone
      ..strokeWidth = 2.6;
    canvas
      ..drawLine(Offset(x, a), Offset(x, b), ink)
      ..drawLine(Offset(x - 5, a), Offset(x + 5, a), ink)
      ..drawLine(Offset(x - 5, b), Offset(x + 5, b), ink);
    writeOn(canvas, size, label,
        Offset(onTheLeft ? x - 52 : x + 7, (a + b) / 2 - 6), tone,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(PhaseDiagramPainter old) =>
      old.soil != soil ||
      old.over != over ||
      old.under != under ||
      old.answered != answered;
}

/// The four unit weights of one soil, drawn as bars to one scale. Which is
/// biggest is a matter of what is in the voids and whether the water outside
/// is helping to hold the sample up.
class UnitWeightPainter extends CustomPainter {
  const UnitWeightPainter({required this.soil, this.answered = false});

  final Soil soil;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = <(String, double)>[
      ('dry', soil.dryUnitWeight),
      ('as it is', soil.totalUnitWeight),
      ('saturated', soil.saturatedUnitWeight),
      ('submerged', soil.submergedUnitWeight),
    ];
    final top = rows.fold(0.0, (t, r) => math.max(t, r.$2));
    final left = 78.0;
    final wide = size.width - left - 56;

    writeOn(canvas, size, 'pounds per cubic foot, all one scale',
        const Offset(8, 6), AppColors.ink3, fontSize: 9.5);

    var y = 26.0;
    for (final (name, value) in rows) {
      writeOn(canvas, size, name, Offset(8, y - 1), AppColors.ink3,
          fontSize: 9.5);
      // The lengths ARE the answer to the first two rounds, so before the
      // round is over there is only an empty rail to show what is being
      // compared.
      if (answered) {
        final length = value / top * wide;
        canvas.drawRect(
            Rect.fromLTWH(left, y, math.max(length, 1), 13),
            Paint()..color = AppColors.charcoal.withValues(alpha: 0.55));
        writeOn(canvas, size, value.toStringAsFixed(0),
            Offset(left + length + 6, y - 1), AppColors.ember, fontSize: 9.5);
      } else {
        canvas.drawRect(
            Rect.fromLTWH(left, y, wide, 13),
            Paint()
              ..color = AppColors.line
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1);
      }
      y += 22;
    }

    if (!answered) {
      writeOn(canvas, size, 'the four of them, for one soil at one void ratio',
          Offset(8, y + 2), AppColors.ink3, fontSize: 9.5);
    }
  }

  @override
  bool shouldRepaint(UnitWeightPainter old) =>
      old.soil != soil || old.answered != answered;
}
