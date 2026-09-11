import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// What a pump is being asked to do, and how well it does it.
@immutable
class Duty {
  const Duty({
    required this.flow,
    required this.head,
    this.weight = 9810,
    this.pumpEfficiency = 1,
    this.motorEfficiency = 1,
  });

  /// Cubic meters a second.
  final double flow;

  /// Meters of head added.
  final double head;

  /// The unit weight of what is being pumped, newtons per cubic meter.
  /// Fresh water is 9,810 and seawater about 10,050.
  final double weight;

  final double pumpEfficiency;
  final double motorEfficiency;

  /// The power that actually ends up in the water. Everything else is
  /// bigger than this, never smaller.
  double get fluidPower => weight * flow * head;

  /// What the shaft has to deliver. Dividing by an efficiency below one
  /// always makes a number larger, which is the direction the lesson's own
  /// tip is about.
  double get shaftPower => fluidPower / pumpEfficiency;

  /// What the meter reads, once the motor's own losses are counted.
  double get inputPower => shaftPower / motorEfficiency;
}

/// Which piece of the arrangement a round is asking about.
enum Piece3 { air, lift, flooded, suctionLine, warmth, dischargeLine }

extension Piece3Words on Piece3 {
  String get plain => switch (this) {
        Piece3.air => 'the atmosphere pressing on the water surface',
        Piece3.lift => 'the pump standing above the water it draws from',
        Piece3.flooded => 'the pump standing below the water it draws from',
        Piece3.suctionLine => 'friction in the suction line',
        Piece3.warmth => 'pumping warm water rather than cold',
        Piece3.dischargeLine => 'a longer pipe on the discharge side',
      };
}

/// A pumping arrangement, drawn from the side: the water it draws from, the
/// suction line, the pump, and the delivery above it. The one thing this
/// drawing has to make unmistakable is whether the pump is above or below
/// the water it is pulling from, because the sign of a term depends on it.
class PumpSystemPainter extends CustomPainter {
  const PumpSystemPainter({
    required this.above,
    this.highlight,
    this.duty,
    this.showPower = false,
    this.note,
  });

  /// Whether the pump sits above the supply water surface, which is a
  /// suction lift, or below it, which is a flooded suction.
  final bool above;

  /// The part of the arrangement the round is about, drawn in ember.
  final Piece3? highlight;

  /// Kept for the rounds that also show the power bars beneath, so the two
  /// drawings can be told apart in a repaint.
  final Duty? duty;
  final bool showPower;
  final String? note;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height - 28;
    final sumpTop = above ? groundY - 26 : groundY - 96;
    final pumpY = above ? groundY - 74 : groundY - 40;
    const sumpLeft = 14.0;
    final sumpRight = sumpLeft + 96;
    final pumpX = sumpRight + 54;
    final tankLeft = size.width - 96;

    // The supply, as a sump with a free surface.
    final sump = Rect.fromLTRB(sumpLeft, sumpTop, sumpRight, groundY);
    canvas.drawRect(sump, waterFill);
    canvas
      ..drawLine(Offset(sumpLeft, sumpTop - 20), Offset(sumpLeft, groundY),
          Paint()
            ..color = AppColors.ink2
            ..strokeWidth = 1.6)
      ..drawLine(Offset(sumpRight, sumpTop - 20), Offset(sumpRight, groundY),
          Paint()
            ..color = AppColors.ink2
            ..strokeWidth = 1.6);
    groundLine(canvas, Offset(sumpLeft, groundY), Offset(size.width - 14,
        groundY));
    waterLevel(
        canvas, Offset(sumpLeft, sumpTop), Offset(sumpRight, sumpTop),
        markAt: sumpLeft + 24,
        color: highlight == Piece3.warmth ? AppColors.error : null);

    // The suction line, from the sump to the pump.
    final suction = highlight == Piece3.suctionLine
        ? (Paint()
          ..color = AppColors.ember
          ..strokeWidth = 3.4)
        : (Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2.4);
    canvas
      ..drawLine(Offset(sumpLeft + 46, sumpTop + 12),
          Offset(sumpLeft + 46, pumpY), suction)
      ..drawLine(Offset(sumpLeft + 46, pumpY), Offset(pumpX - 13, pumpY),
          suction);

    // The pump.
    canvas
      ..drawCircle(Offset(pumpX, pumpY), 13, Paint()..color = AppColors.cream)
      ..drawCircle(
          Offset(pumpX, pumpY),
          13,
          Paint()
            ..color = AppColors.charcoal
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2)
      ..drawPath(
          Path()
            ..moveTo(pumpX - 5, pumpY - 6)
            ..lineTo(pumpX + 7, pumpY)
            ..lineTo(pumpX - 5, pumpY + 6)
            ..close(),
          Paint()..color = AppColors.charcoal);
    writeOn(canvas, size, 'pump', Offset(pumpX - 13, pumpY + 16),
        AppColors.ink2, fontSize: 9);

    // The delivery side.
    final discharge = highlight == Piece3.dischargeLine
        ? (Paint()
          ..color = AppColors.ember
          ..strokeWidth = 3.4)
        : (Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2.4);
    final tankTop = 44.0;
    canvas
      ..drawLine(Offset(pumpX + 13, pumpY),
          Offset(tankLeft + 30, pumpY), discharge)
      ..drawLine(Offset(tankLeft + 30, pumpY),
          Offset(tankLeft + 30, tankTop + 14), discharge);
    final tank = Rect.fromLTRB(tankLeft, tankTop, size.width - 14, tankTop + 46);
    canvas.drawRect(tank, waterFill);
    canvas.drawRect(
        tank,
        Paint()
          ..color = AppColors.ink2
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    waterLevel(canvas, Offset(tankLeft, tankTop), Offset(size.width - 14,
        tankTop));

    // The lift, which is the thing the drawing exists to show.
    final dimX = pumpX + 26;
    final tone = (highlight == Piece3.lift || highlight == Piece3.flooded)
        ? AppColors.ember
        : AppColors.ink3;
    canvas
      ..drawLine(Offset(dimX, sumpTop), Offset(dimX, pumpY),
          Paint()
            ..color = tone
            ..strokeWidth = 1.4)
      ..drawLine(Offset(dimX - 5, sumpTop), Offset(dimX + 5, sumpTop),
          Paint()
            ..color = tone
            ..strokeWidth = 1.2)
      ..drawLine(Offset(dimX - 5, pumpY), Offset(dimX + 5, pumpY),
          Paint()
            ..color = tone
            ..strokeWidth = 1.2);
    writeOn(
        canvas,
        size,
        above ? 'suction LIFT' : 'flooded suction',
        Offset(dimX + 7, (sumpTop + pumpY) / 2 - 6),
        tone,
        fontSize: 9);

    if (highlight == Piece3.air) {
      for (var i = 0; i < 3; i++) {
        final x = sumpLeft + 18 + i * 28.0;
        canvas.drawLine(
            Offset(x, sumpTop - 22),
            Offset(x, sumpTop - 6),
            Paint()
              ..color = AppColors.ember
              ..strokeWidth = 1.6);
        canvas.drawPath(
            Path()
              ..moveTo(x, sumpTop - 2)
              ..lineTo(x - 4, sumpTop - 9)
              ..lineTo(x + 4, sumpTop - 9)
              ..close(),
            Paint()..color = AppColors.ember);
      }
      writeOn(canvas, size, 'air pressing down',
          Offset(sumpLeft, sumpTop - 36), AppColors.ember, fontSize: 9);
    }

    if (highlight == Piece3.warmth) {
      writeOn(canvas, size, 'warm', Offset(sumpLeft + 52, sumpTop + 6),
          AppColors.error, fontSize: 9);
    }

    if (note != null) {
      writeOn(canvas, size, note!, const Offset(8, 8), AppColors.ink3,
          fontSize: 9);
    }
    viewTag(canvas, size, Looking.elevation, note: 'the pumping arrangement');
  }

  @override
  bool shouldRepaint(PumpSystemPainter old) =>
      old.above != above ||
      old.highlight != highlight ||
      old.duty != duty ||
      old.showPower != showPower ||
      old.note != note;
}

/// The three powers as one bar each, to one scale, drawn in their own strip
/// under the arrangement. In the figure itself they landed on the delivery
/// tank and on the caption.
class PowerBarPainter extends CustomPainter {
  const PowerBarPainter({required this.duty, required this.caption});

  final Duty duty;
  final String caption;

  @override
  void paint(Canvas canvas, Size size) {
    // The motor's own losses only get a bar when there are any, or the
    // last two rows are the same number twice.
    final rows = <(String, double, Color)>[
      ('into the water', duty.fluidPower, AppColors.info),
      ('at the shaft', duty.shaftPower, AppColors.ember),
      if (duty.motorEfficiency < 0.999)
        ('off the meter', duty.inputPower, AppColors.charcoal),
    ];
    final most = rows.last.$2;
    final room = size.width - 156;
    var y = 16.0;
    for (final (label, value, tone) in rows) {
      final width = math.max(room * value / most, 4.0);
      canvas.drawRect(Rect.fromLTWH(96, y, width, 9),
          Paint()..color = tone.withValues(alpha: 0.85));
      writeOn(canvas, size, label, Offset(8, y - 2), tone, fontSize: 9);
      writeOn(canvas, size, '${(value / 1000).toStringAsFixed(1)} kW',
          Offset(100 + width, y - 2), tone, fontSize: 9);
      y += 16;
    }
    writeOn(canvas, size, caption, const Offset(8, 2), AppColors.ink3,
        fontSize: 8.5);
  }

  @override
  bool shouldRepaint(PowerBarPainter old) =>
      old.duty != duty || old.caption != caption;
}
