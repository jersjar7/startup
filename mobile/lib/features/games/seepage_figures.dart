import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// A flow net under a water-retaining structure, described by the two counts
/// that are read off it.
@immutable
class FlowNet {
  const FlowNet({
    required this.channels,
    required this.drops,
    required this.head,
    required this.k,
  });

  /// How many lanes the water runs in, and how many steps the head comes
  /// down in.
  final int channels;
  final int drops;

  /// The total head lost across the structure, in meters.
  final double head;

  /// Hydraulic conductivity, in meters per second.
  final double k;

  /// Seepage per unit width. The channels are on TOP of the fraction: more
  /// lanes means more water, more steps means less.
  double get seepage => k * head * channels / drops;

  /// How much head is lost at each step.
  double get dropSize => head / drops;
}

/// The classic section: a sheet pile driven into permeable ground with water
/// standing higher on one side, the flow lines curving under it and the
/// equipotential lines crossing them.
class FlowNetPainter extends CustomPainter {
  const FlowNetPainter({required this.net, this.answered = false});

  final FlowNet net;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 16.0;
    final right = size.width - 16;
    final ground = size.height * 0.36;
    final bottom = size.height - 26;
    final middle = (left + right) / 2;

    // The permeable ground, and the impermeable base under it.
    final soil = Rect.fromLTRB(left, ground, right, bottom);
    canvas.drawRect(
        soil,
        Paint()
          ..color = AppColors.ink2.withValues(alpha: 0.18));
    groundLine(canvas, Offset(left, ground), Offset(middle - 2, ground));
    groundLine(canvas, Offset(middle + 2, ground), Offset(right, ground));
    canvas.drawLine(
        Offset(left, bottom),
        Offset(right, bottom),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 2.4);
    writeOn(canvas, size, 'rock: nothing crosses it', Offset(left + 4, bottom + 4),
        AppColors.ink3, fontSize: 9.5);

    // Water standing high on one side and low on the other.
    final high = ground - 26.0;
    final low = ground - 8.0;
    canvas
      ..drawRect(Rect.fromLTRB(left, high, middle, ground),
          Paint()..color = AppColors.info.withValues(alpha: 0.18))
      ..drawRect(Rect.fromLTRB(middle, low, right, ground),
          Paint()..color = AppColors.info.withValues(alpha: 0.18));
    waterLevel(canvas, Offset(left, high), Offset(middle - 3, high));
    waterLevel(canvas, Offset(middle + 3, low), Offset(right, low));
    writeOn(canvas, size, 'head lost across it: ${net.head.toStringAsFixed(0)} m',
        Offset(left + 4, high - 16), AppColors.info, fontSize: 9.5);

    // The sheet pile.
    final toe = ground + (bottom - ground) * 0.45;
    canvas.drawLine(
        Offset(middle, high - 6),
        Offset(middle, toe),
        Paint()
          ..color = AppColors.charcoal
          ..strokeWidth = 4);

    // The flow lines: one lane boundary per channel. Each starts further out
    // along the upstream bed than the last and dives deeper under the toe,
    // so they read as nested arcs rather than a fan from one point.
    for (var i = 0; i <= net.channels; i++) {
      final t = i / net.channels;
      final depth = toe + (bottom - toe - 6) * t;
      final start = left + 6 + (middle - left - 30) * t * 0.75;
      final end = right - 6 - (right - middle - 30) * t * 0.75;
      final path = Path()..moveTo(start, ground + 3);
      path.cubicTo(
        middle - 44,
        depth,
        middle + 44,
        depth,
        end,
        ground + 3,
      );
      canvas.drawPath(
          path,
          Paint()
            ..color = AppColors.info
            ..style = PaintingStyle.stroke
            ..strokeWidth = i == 0 || i == net.channels ? 2 : 1.3);
    }

    // The equipotential lines, crossing them: one per drop.
    for (var j = 1; j < net.drops; j++) {
      final t = j / net.drops;
      final x = left + 10 + (right - left - 20) * t;
      final sag = math.sin(math.pi * t) * 12;
      canvas.drawLine(
          Offset(x, ground + 4 + sag * 0.4),
          Offset(x, toe + (bottom - toe - 6) * math.sin(math.pi * t) + 4),
          Paint()
            ..color = AppColors.ember.withValues(alpha: 0.65)
            ..strokeWidth = 1.1);
    }

    if (answered) {
      writeOn(
          canvas,
          size,
          '${net.channels} channels, ${net.drops} drops',
          Offset(left + 4, ground + 6),
          AppColors.forest,
          fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'under the wall');
  }

  @override
  bool shouldRepaint(FlowNetPainter old) =>
      old.net != net || old.answered != answered;
}

/// An upward seepage gradient at the downstream side, and what it does to
/// the weight the grains feel.
@immutable
class Quick {
  const Quick({
    required this.gs,
    required this.voidRatio,
    required this.exitGradient,
  });

  final double gs;
  final double voidRatio;

  /// The upward gradient where the water leaves the ground.
  final double exitGradient;

  /// The gradient at which the upward drag exactly carries the grains.
  double get critical => (gs - 1) / (1 + voidRatio);

  double get factorOfSafety => critical / exitGradient;

  bool get boiling => exitGradient >= critical;
}

/// A column of sand with water seeping up through it, and the weight the
/// grains are left with drawn beside it.
class BoilPainter extends CustomPainter {
  const BoilPainter({required this.quick, this.answered = false});

  final Quick quick;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.18;
    final right = size.width * 0.54;
    final top = size.height * 0.24;
    final bottom = size.height - 34;

    final column = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(
        column,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    hatchIn(canvas, Path()..addRect(column), step: 9, color: AppColors.ink2);
    writeOn(canvas, size, 'sand', Offset(left + 6, (top + bottom) / 2 - 6),
        AppColors.ink3, fontSize: 9.5);

    // Water coming up through it.
    for (var x = left + 12; x < right; x += 22) {
      canvas
        ..drawLine(
            Offset(x, bottom + 14),
            Offset(x, top + 12),
            Paint()
              ..color = AppColors.info
              ..strokeWidth = 1.8)
        ..drawPath(
            Path()
              ..moveTo(x, top + 4)
              ..lineTo(x - 3.5, top + 13)
              ..lineTo(x + 3.5, top + 13)
              ..close(),
            Paint()..color = AppColors.info);
    }
    writeOn(canvas, size, 'water seeping UP', Offset(left, bottom + 18),
        AppColors.info, fontSize: 9.5);

    // What the round is being asked about, on the right.
    final x = size.width * 0.62;
    writeOn(canvas, size, 'exit gradient ${quick.exitGradient.toStringAsFixed(2)}',
        Offset(x, top + 6), AppColors.ember, fontSize: 9.5);
    if (answered) {
      writeOn(
          canvas,
          size,
          'critical ${quick.critical.toStringAsFixed(2)}',
          Offset(x, top + 22),
          AppColors.forest,
          fontSize: 9.5);
      writeOn(
          canvas,
          size,
          quick.boiling
              ? 'boiling: nothing left in the grains'
              : 'safety factor ${quick.factorOfSafety.toStringAsFixed(2)}',
          Offset(x, top + 38),
          AppColors.forest,
          fontSize: 9.5);
    }

    viewTag(canvas, size, Looking.section, note: 'where it comes out');
  }

  @override
  bool shouldRepaint(BoilPainter old) =>
      old.quick != quick || old.answered != answered;
}
