import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// The shape cut in the weir plate, which is the only thing that decides
/// which formula measures the flow over it.
enum Notch { fullWidth, contracted, vee }

extension NotchWords on Notch {
  String get plain => switch (this) {
        Notch.fullWidth => 'a suppressed rectangular weir',
        Notch.contracted => 'a contracted rectangular weir',
        Notch.vee => 'a 90 degree V-notch weir',
      };
}

/// A weir: a plate across the channel with the water spilling over it.
@immutable
class Weir {
  const Weir({
    required this.notch,
    required this.head,
    this.crest = 4,
    this.channel = 8,
    this.metric = false,
  });

  final Notch notch;

  /// H, the head of water standing above the crest.
  final double head;

  /// L, the length of the crest the water pours over. Meaningless on a
  /// V-notch, which has no flat crest at all.
  final double crest;

  /// How wide the channel is. A suppressed weir spans the whole of it.
  final double channel;
  final bool metric;

  String get units => metric ? 'm' : 'ft';

  /// The coefficient the handbook gives for this shape and unit system.
  double get coefficient => switch (notch) {
        Notch.fullWidth || Notch.contracted => metric ? 1.84 : 3.33,
        Notch.vee => metric ? 1.40 : 2.54,
      };

  /// How the head is powered. Three halves for anything with a flat crest,
  /// five halves for a V, because a V gets WIDER as the water rises and a
  /// rectangle does not.
  double get exponent => notch == Notch.vee ? 2.5 : 1.5;

  /// The crest the water actually uses. End contractions pull the nappe in
  /// from each side by a tenth of the head, so a contracted weir loses two
  /// tenths of it.
  double get effectiveCrest =>
      notch == Notch.contracted ? crest - 0.2 * head : crest;

  double get flow => notch == Notch.vee
      ? coefficient * math.pow(head, 2.5).toDouble()
      : coefficient * effectiveCrest * math.pow(head, 1.5).toDouble();

  /// What the same weir passes at another head, for the rounds that ask how
  /// much a weir notices a change.
  double flowAt(double h) =>
      Weir(notch: notch, head: h, crest: crest, channel: channel,
              metric: metric)
          .flow;
}

/// The plate seen from upstream: the channel walls either side, the notch
/// cut in it, and the water standing above the crest. This is the view that
/// tells the two rectangular weirs apart, because the difference between
/// them is whether the opening reaches the walls.
class WeirPainter extends CustomPainter {
  const WeirPainter({
    required this.weir,
    this.showFlow = false,
    this.thenHead,
    this.tag,
  });

  final Weir weir;

  /// A second water level, drawn dashed, for a round that asks what a
  /// change in head does. The drawing has to carry the change or the
  /// question is being asked about something the reader cannot see.
  final double? thenHead;

  /// A name for this drawing, when two are shown together.
  final String? tag;

  /// Whether the discharge is written on the drawing. Held back while the
  /// round is still asking about it.
  final bool showFlow;

  // Room outside the channel walls for the head dimension, which used to
  // run off the right of the panel.
  static const _pad = 46.0;
  static const _floor = 32.0;

  @override
  void paint(Canvas canvas, Size size) {
    final tallest = math.max(weir.head, thenHead ?? 0);
    final scale = math.min(
      (size.width - 2 * _pad) / weir.channel,
      (size.height - _floor - 46) / (tallest + 2.2),
    );
    final floorY = size.height - _floor;
    final middle = size.width / 2;
    final half = weir.channel / 2 * scale;
    // The crest sits well up the plate so there is a plate to see.
    final crestY = floorY - 1.6 * scale;
    final waterY = crestY - weir.head * scale;

    final plateTop = crestY - math.max(tallest * scale + 16, 26);

    // The channel walls, as material.
    for (final side in [-1, 1]) {
      final outer = middle + side * (half + 14);
      final inner = middle + side * half;
      final wall = Path()
        ..addRect(Rect.fromLTRB(math.min(outer, inner), plateTop - 12,
            math.max(outer, inner), floorY));
      hatchIn(canvas, wall, step: 5);
      canvas.drawPath(
          wall,
          Paint()
            ..color = AppColors.ink2
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3);
    }

    // The plate, with the notch taken out of it.
    final opening = _openingPath(middle, half, crestY, plateTop, scale);
    final plate = Path.combine(
        PathOperation.difference,
        Path()
          ..addRect(Rect.fromLTRB(middle - half, plateTop, middle + half,
              floorY)),
        opening);
    hatchIn(canvas, plate, step: 5, slope: -1);
    canvas.drawPath(
        plate,
        Paint()
          ..color = AppColors.charcoal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);

    // The water standing behind the plate, seen through the opening.
    final wet = Path.combine(
        PathOperation.intersect,
        opening,
        Path()
          ..addRect(
              Rect.fromLTRB(middle - half, waterY, middle + half, floorY)));
    canvas.drawPath(wet, waterFill);
    waterLevel(canvas, Offset(middle - half - 12, waterY),
        Offset(middle + half + 12, waterY),
        markAt: middle - half - 2);

    // Where the water would stand after the change the round describes.
    if (thenHead != null) {
      final thenY = crestY - thenHead! * scale;
      for (var x = middle - half - 12; x < middle + half + 12; x += 9) {
        canvas.drawLine(
            Offset(x, thenY),
            Offset(x + 5, thenY),
            Paint()
              ..color = AppColors.forest
              ..strokeWidth = 1.6);
      }
      writeOn(canvas, size, 'then H ${_num(thenHead!)}',
          Offset(middle - half - 10, thenY - 13), AppColors.forest,
          fontSize: 9);
    }

    // The head above the crest, which every weir formula runs on.
    final dim = math.min(middle + half + 22, size.width - 8);
    canvas
      ..drawLine(
          Offset(dim, waterY),
          Offset(dim, crestY),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 1.4)
      ..drawLine(
          Offset(dim - 5, crestY),
          Offset(dim + 5, crestY),
          Paint()
            ..color = AppColors.ember
            ..strokeWidth = 1.4);
    // Above the dimension rather than beside it, so it never needs room
    // the panel does not have.
    writeOn(canvas, size, 'H ${_num(weir.head)} ${weir.units}',
        Offset(dim - 20, waterY - 14), AppColors.ember, fontSize: 9.5);

    // The crest, and whether it reaches the walls.
    if (weir.notch != Notch.vee) {
      final reach = weir.notch == Notch.fullWidth ? half : half * 0.62;
      canvas.drawLine(
          Offset(middle - reach, crestY + 9),
          Offset(middle + reach, crestY + 9),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1);
      writeOn(canvas, size, 'L ${_num(weir.crest)} ${weir.units}',
          Offset(middle - 22, crestY + 12), AppColors.ink3, fontSize: 9.5);
      if (weir.notch == Notch.contracted) {
        for (final side in [-1, 1]) {
          writeOn(canvas, size, 'gap',
              Offset(middle + side * half - 12, crestY - 14), AppColors.ink3,
              fontSize: 8.5);
        }
      }
    } else {
      writeOn(canvas, size, '90 degrees', Offset(middle - 26, crestY - 16),
          AppColors.ink3, fontSize: 9);
    }

    writeOn(
        canvas,
        size,
        tag == null
            ? weir.notch.plain.toUpperCase()
            : '$tag   ${weir.notch.plain.toUpperCase()}',
        const Offset(8, 8),
        AppColors.ember,
        fontSize: 9);
    if (showFlow) {
      writeOn(
          canvas,
          size,
          'Q ${weir.flow.toStringAsFixed(1)} '
              '${weir.metric ? 'm3/s' : 'cfs'}',
          const Offset(8, 22),
          AppColors.forest,
          fontSize: 9.5);
    }
    viewTag(canvas, size, Looking.elevation, note: 'the plate from upstream');
  }

  /// The hole in the plate the water goes through.
  Path _openingPath(
      double middle, double half, double crestY, double plateTop, double scale) {
    switch (weir.notch) {
      case Notch.fullWidth:
        return Path()
          ..addRect(
              Rect.fromLTRB(middle - half, plateTop, middle + half, crestY));
      case Notch.contracted:
        final reach = half * 0.62;
        return Path()
          ..addRect(
              Rect.fromLTRB(middle - reach, plateTop, middle + reach, crestY));
      case Notch.vee:
        // A right angle at the bottom, so the opening is as wide as it is
        // deep at every level. That is where the five halves comes from.
        final rise = crestY - plateTop;
        return Path()
          ..moveTo(middle, crestY)
          ..lineTo(middle - rise, plateTop)
          ..lineTo(middle + rise, plateTop)
          ..close();
    }
  }

  @override
  bool shouldRepaint(WeirPainter old) =>
      old.weir != weir ||
      old.showFlow != showFlow ||
      old.thenHead != thenHead ||
      old.tag != tag;
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();
