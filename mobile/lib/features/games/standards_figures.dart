import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Which rule a limit belongs to.
enum Tier { primary, secondary, discharge }

extension TierWords on Tier {
  String get heading => switch (this) {
        Tier.primary => 'PRIMARY',
        Tier.secondary => 'SECONDARY',
        Tier.discharge => 'NPDES',
      };

  String get gist => switch (this) {
        Tier.primary => 'health, enforceable',
        Tier.secondary => 'aesthetic, advisory',
        Tier.discharge => 'what a plant may release',
      };
}

/// The two tiers of drinking water standard side by side, with the
/// contaminant the round names filed into one of them once the reader has
/// committed.
class TierPainter extends CustomPainter {
  const TierPainter({required this.label, this.settled});

  /// The contaminant and its limit, as a card.
  final String label;

  /// Where it belongs, drawn only after the round is answered.
  final Tier? settled;

  @override
  void paint(Canvas canvas, Size size) {
    final boxes = <Tier, Rect>{};
    const tiers = [Tier.primary, Tier.secondary];
    for (var i = 0; i < tiers.length; i++) {
      final width = (size.width - 36) / 2;
      boxes[tiers[i]] = Rect.fromLTWH(
          12 + i * (width + 12), 56, width, size.height - 108);
    }

    boxes.forEach((tier, rect) {
      final chosen = settled == tier;
      canvas
        ..drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(8)),
            Paint()
              ..color = chosen
                  ? AppColors.forest.withValues(alpha: 0.12)
                  : AppColors.cream)
        ..drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(8)),
            Paint()
              ..color = chosen ? AppColors.forest : AppColors.ink3
              ..style = PaintingStyle.stroke
              ..strokeWidth = chosen ? 2.4 : 1.4);
      writeOn(canvas, size, tier.heading, Offset(rect.left + 10, rect.top + 8),
          chosen ? AppColors.forest : AppColors.ink2, fontSize: 10);
      writeOn(canvas, size, tier.gist, Offset(rect.left + 10, rect.top + 24),
          AppColors.ink3, fontSize: 9);
    });

    // The card being filed.
    final card = Rect.fromLTWH(size.width / 2 - 92, size.height - 44, 184, 30);
    canvas
      ..drawRRect(
          RRect.fromRectAndRadius(card, const Radius.circular(6)),
          Paint()..color = AppColors.white)
      ..drawRRect(
          RRect.fromRectAndRadius(card, const Radius.circular(6)),
          Paint()
            ..color = AppColors.ember
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8);
    writeOn(canvas, size, label, Offset(card.left + 10, card.top + 9),
        AppColors.charcoal, fontSize: 10);

    if (settled != null && boxes[settled] != null) {
      final to = boxes[settled]!;
      canvas.drawLine(
          Offset(card.center.dx, card.top),
          Offset(to.center.dx, to.bottom),
          Paint()
            ..color = AppColors.forest
            ..strokeWidth = 1.6);
    }

    writeOn(canvas, size, 'SAFE DRINKING WATER ACT', const Offset(12, 14),
        AppColors.ink3, fontSize: 9);
  }

  @override
  bool shouldRepaint(TierPainter old) =>
      old.label != label || old.settled != settled;
}

/// A hardness ion: what is in the water and what it counts for once it is
/// put on a calcium carbonate basis.
@immutable
class Ion {
  const Ion({
    required this.name,
    required this.concentration,
    required this.equivalentWeight,
  });

  final String name;

  /// Milligrams a liter of the ion itself.
  final double concentration;

  /// Milligrams per milliequivalent. Calcium is 20, magnesium 12.15.
  final double equivalentWeight;

  /// The multiplier that puts it on a common basis with everything else:
  /// 50 over its own equivalent weight.
  double get factor => 50 / equivalentWeight;

  /// What it contributes to the hardness. A magnesium ion counts for more
  /// than a calcium one of the same mass, because it is lighter.
  double get asCaCO3 => concentration * factor;
}

/// The raw concentrations beside what they count for, so the conversion is
/// a picture: two bars that start different lengths and end different
/// lengths, and not in the same order.
class HardnessPainter extends CustomPainter {
  const HardnessPainter({required this.ions, this.converted = false});

  final List<Ion> ions;

  /// Whether the bars show the converted values.
  final bool converted;

  @override
  void paint(Canvas canvas, Size size) {
    final most = ions
        .map((i) => math.max(i.concentration, i.asCaCO3))
        .reduce(math.max);
    final left = 74.0;
    final room = size.width - left - 76;
    var y = 52.0;

    for (final ion in ions) {
      final value = converted ? ion.asCaCO3 : ion.concentration;
      final width = math.max(room * value / most, 4.0);
      canvas
        ..drawRect(Rect.fromLTWH(left, y, width, 22),
            Paint()
              ..color = (converted ? AppColors.forest : AppColors.info)
                  .withValues(alpha: 0.5))
        ..drawRect(
            Rect.fromLTWH(left, y, width, 22),
            Paint()
              ..color = AppColors.ink2
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2);
      writeOn(canvas, size, ion.name, Offset(8, y + 5), AppColors.charcoal,
          fontSize: 10);
      writeOn(canvas, size, '${value.toStringAsFixed(1)} mg/L',
          Offset(left + width + 6, y + 5),
          converted ? AppColors.forest : AppColors.info,
          fontSize: 9.5);
      if (converted) {
        writeOn(canvas, size, 'x ${ion.factor.toStringAsFixed(2)}',
            Offset(left + 6, y + 5), AppColors.charcoal, fontSize: 9);
      }
      y += 34;
    }

    if (converted) {
      final total = ions.fold(0.0, (sum, i) => sum + i.asCaCO3);
      writeOn(
          canvas,
          size,
          'total hardness ${total.toStringAsFixed(0)} mg/L as CaCO3, '
              '${_band(total)}',
          Offset(8, y + 6),
          AppColors.forest,
          fontSize: 9.5);
    }

    writeOn(
        canvas,
        size,
        converted
            ? 'ON A CALCIUM CARBONATE BASIS'
            : 'AS THE IONS COME',
        const Offset(8, 14),
        AppColors.ink3,
        fontSize: 9);
  }

  static String _band(double hardness) {
    if (hardness < 60) return 'soft';
    if (hardness < 120) return 'moderately hard';
    if (hardness < 180) return 'hard';
    return 'very hard';
  }

  @override
  bool shouldRepaint(HardnessPainter old) =>
      old.ions != ions || old.converted != converted;
}

/// What a treatment step has to take out, and what it is allowed to leave.
@immutable
class Removal {
  const Removal({required this.influent, required this.limit});

  final double influent;
  final double limit;

  double get efficiency => (influent - limit) / influent;

  double get remaining => limit / influent;
}

/// The influent as a bar, cut where the limit falls: taken out above,
/// allowed to leave below. The percentage a question asks for is one of the
/// two pieces, and which one is the whole trap.
class RemovalPainter extends CustomPainter {
  const RemovalPainter({required this.removal, this.answered = false});

  final Removal removal;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final baseY = size.height - 44;
    final topY = 52.0;
    final left = size.width / 2 - 52;
    const width = 74.0;
    final cut = baseY - (baseY - topY) * removal.remaining;

    canvas
      ..drawRect(Rect.fromLTRB(left, topY, left + width, cut),
          Paint()..color = AppColors.forest.withValues(alpha: 0.35))
      ..drawRect(Rect.fromLTRB(left, cut, left + width, baseY),
          Paint()..color = AppColors.error.withValues(alpha: 0.35))
      ..drawRect(
          Rect.fromLTRB(left, topY, left + width, baseY),
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);

    writeOn(canvas, size, 'taken out', Offset(left + width + 8,
        (topY + cut) / 2 - 6), AppColors.forest, fontSize: 9.5);
    writeOn(canvas, size, 'allowed to leave',
        Offset(left + width + 8, (cut + baseY) / 2 - 6), AppColors.error,
        fontSize: 9.5);
    writeOn(canvas, size, 'in ${_num(removal.influent)} mg/L',
        Offset(left - 96, topY - 4), AppColors.ink2, fontSize: 9.5);
    writeOn(canvas, size, 'limit ${_num(removal.limit)} mg/L',
        Offset(left - 96, cut - 6), AppColors.ink2, fontSize: 9.5);

    if (answered) {
      writeOn(
          canvas,
          size,
          'removal ${(removal.efficiency * 100).toStringAsFixed(1)} percent, '
              'left ${(removal.remaining * 100).toStringAsFixed(1)}',
          Offset(8, size.height - 18),
          AppColors.forest,
          fontSize: 9.5);
    }
    writeOn(canvas, size, 'WHAT THE STEP HAS TO DO', const Offset(8, 14),
        AppColors.ink3, fontSize: 9);
  }

  @override
  bool shouldRepaint(RemovalPainter old) =>
      old.removal != removal || old.answered != answered;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
