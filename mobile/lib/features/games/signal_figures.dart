import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'figure_ink.dart';

/// Miles per hour into feet per second, which is the conversion this whole
/// lesson turns on.
const double feetPerSecondPerMph = 1.467;

/// The yellow interval: a moment to react, and then the time it takes to
/// shed the approach speed.
@immutable
class Yellow {
  const Yellow({
    required this.speedMph,
    this.reaction = 1.0,
    this.deceleration = 10,
    this.grade = 0,
  });

  /// Miles per hour, seconds, feet per second squared, grade as a fraction.
  final double speedMph;
  final double reaction;
  final double deceleration;
  final double grade;

  double get speedFps => speedMph * feetPerSecondPerMph;

  /// The slowing part: speed over twice the deceleration, with the grade
  /// helping or hindering through the 64.4, which is twice gravity.
  double get slowing => speedFps / (2 * deceleration + 64.4 * grade);

  double get seconds => reaction + slowing;

  /// The lesson's own wrong answers, so no round can invent one.
  double get usingMilesPerHour => reaction + speedMph / (2 * deceleration);
  double get withoutReaction => slowing;
  double get halvingNothing => reaction + speedFps / deceleration;
}

/// The all-red: long enough for a vehicle that entered on yellow to get the
/// whole way across, its own length included.
@immutable
class Clearance {
  const Clearance({
    required this.width,
    required this.vehicleLength,
    required this.speedMph,
  });

  /// Feet, feet, miles per hour.
  final double width;
  final double vehicleLength;
  final double speedMph;

  double get speedFps => speedMph * feetPerSecondPerMph;
  double get distance => width + vehicleLength;
  double get seconds => distance / speedFps;

  double get forgettingTheCar => width / speedFps;
  double get usingMilesPerHour => distance / speedMph;
}

/// The pedestrian green: a moment to start, the walk itself, and a little
/// more when a crowd has to leave the curb.
@immutable
class Walk {
  const Walk({
    required this.crosswalk,
    this.pace = 3.5,
    required this.people,
  });

  /// Feet, feet per second, and a count.
  final double crosswalk;
  final double pace;
  final double people;

  static const double startUp = 3.2;

  double get walking => crosswalk / pace;
  double get forTheCrowd => 0.27 * people;
  double get seconds => startUp + walking + forTheCrowd;
}

/// The yellow interval as a strip of time: the reacting part and the
/// slowing part laid end to end. Which parts there are is the question in
/// one round, so the strip is blank until the answer is in.
class YellowPainter extends CustomPainter {
  const YellowPainter({required this.yellow, this.answered = false});

  final Yellow yellow;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 34.0;
    final right = size.width - 30;
    final y = size.height * 0.52;
    // A six second strip, so a four and a half second yellow does not fill
    // it and the reader can see it is a quantity rather than a bar chart.
    const span = 6.0;
    double lengthOf(double seconds) =>
        math.min(seconds / span, 1) * (right - left);

    canvas.drawRect(
        Rect.fromLTRB(left, y - 14, right, y + 14),
        Paint()
          ..color = AppColors.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    for (var s = 1; s < span; s++) {
      final x = left + lengthOf(s.toDouble());
      canvas.drawLine(
          Offset(x, y + 14),
          Offset(x, y + 19),
          Paint()
            ..color = AppColors.ink3
            ..strokeWidth = 1);
      writeOn(canvas, size, '$s', Offset(x - 3, y + 20), AppColors.ink3,
          fontSize: 9.5);
    }
    writeOn(canvas, size, 'seconds', Offset(left - 8, y + 34), AppColors.ink3,
        fontSize: 9.5);

    writeOn(
        canvas,
        size,
        '${yellow.speedMph.toStringAsFixed(0)} mph coming up to the light',
        Offset(left - 8, 8),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'that is ${yellow.speedFps.toStringAsFixed(1)} feet a second',
        Offset(left - 8, 22),
        AppColors.ink3,
        fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'what the yellow is made of comes out',
          Offset(left - 8, y - 40), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(left - 8, y - 26),
          AppColors.ink3, fontSize: 9.5);
      return;
    }

    final reacting = lengthOf(yellow.reaction);
    final slowing = lengthOf(yellow.seconds) - reacting;
    canvas
      ..drawRect(Rect.fromLTWH(left, y - 14, reacting, 28),
          Paint()..color = AppColors.info.withValues(alpha: 0.45))
      ..drawRect(Rect.fromLTWH(left + reacting, y - 14, slowing, 28),
          Paint()..color = AppColors.ember.withValues(alpha: 0.5));
    writeOn(
        canvas,
        size,
        'reacting ${yellow.reaction.toStringAsFixed(1)}',
        Offset(left + 2, y - 30),
        AppColors.info,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'slowing ${yellow.slowing.toStringAsFixed(1)}',
        Offset(left + reacting + 4, y - 30),
        AppColors.ember,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${yellow.seconds.toStringAsFixed(1)} seconds of yellow',
        Offset(left - 8, size.height - 16),
        AppColors.charcoal,
        fontSize: 9.5);
  }

  @override
  bool shouldRepaint(YellowPainter old) =>
      old.yellow != yellow || old.answered != answered;
}

/// The intersection from above, with the vehicle that entered on yellow and
/// the distance it still has to cover. How far that is is the question, so
/// the dimension line waits for the answer.
class CrossingPainter extends CustomPainter {
  const CrossingPainter({required this.clearance, this.answered = false});

  final Clearance clearance;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    // One scale for the whole drawing: the vehicle has to fit on the near
    // side of the intersection as well as the intersection itself.
    final usable = size.width - 70;
    final perFoot = usable / clearance.distance;
    final carLength = clearance.vehicleLength * perFoot;
    final left = 34.0 + carLength;
    final right = left + clearance.width * perFoot;
    final top = size.height * 0.30;
    final bottom = size.height * 0.66;

    final box = Rect.fromLTRB(left, top, right, bottom);
    canvas
      ..drawRect(box, Paint()..color = AppColors.ink2.withValues(alpha: 0.18))
      ..drawLine(
          Offset(left, top),
          Offset(left, bottom),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 1.6)
      ..drawLine(
          Offset(right, top),
          Offset(right, bottom),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 1.6);
    writeOn(
        canvas,
        size,
        '${clearance.width.toStringAsFixed(0)} ft curb to curb',
        Offset(left + 4, top - 16),
        AppColors.ink3,
        fontSize: 9.5);

    // The vehicle, just short of the near curb, pointing across.
    final carY = (top + bottom) / 2;
    canvas.drawRect(
        Rect.fromLTWH(left - carLength - 2, carY - 7, carLength, 14),
        Paint()..color = AppColors.charcoal.withValues(alpha: 0.8));
    writeOn(
        canvas,
        size,
        '${clearance.vehicleLength.toStringAsFixed(0)} ft of vehicle',
        Offset(4, carY + 12),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'entered on yellow at ${clearance.speedMph.toStringAsFixed(0)} mph',
        Offset(4, 8),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        'that is ${clearance.speedFps.toStringAsFixed(1)} ft a second',
        Offset(4, 22),
        AppColors.ink3,
        fontSize: 9.5);

    if (!answered) {
      writeOn(canvas, size, 'how far it still has to go comes out',
          Offset(4, bottom + 10), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(4, bottom + 24),
          AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.plan, note: 'the intersection');
      return;
    }

    // The distance the back bumper has to travel: the width and the car.
    final dimY = bottom + 14;
    canvas.drawLine(
        Offset(left - carLength - 2, dimY),
        Offset(right, dimY),
        Paint()
          ..color = AppColors.ember
          ..strokeWidth = 2);
    writeOn(
        canvas,
        size,
        '${clearance.distance.toStringAsFixed(0)} ft altogether, '
            '${clearance.seconds.toStringAsFixed(1)} seconds',
        Offset(4, dimY + 6),
        AppColors.ember,
        fontSize: 9.5);
    viewTag(canvas, size, Looking.plan, note: 'the intersection');
  }

  @override
  bool shouldRepaint(CrossingPainter old) =>
      old.clearance != clearance || old.answered != answered;
}

/// The pedestrian green as three pieces stacked end to end: getting going,
/// the walk itself, and the extra for a crowd. Which pieces there are is
/// the question, so they arrive with the answer.
class WalkPainter extends CustomPainter {
  const WalkPainter({required this.walk, this.answered = false});

  final Walk walk;
  final bool answered;

  @override
  void paint(Canvas canvas, Size size) {
    final left = 30.0;
    // A ninety foot crossing has to look wider than a fifty six foot one,
    // so the stripes are drawn to scale against the widest road any round
    // uses.
    final right = left +
        (size.width - 56) * math.min(walk.crosswalk / 90, 1).toDouble();
    final curbY = size.height * 0.34;

    // The crosswalk in plan: two curbs and the stripes between them.
    canvas
      ..drawLine(
          Offset(left, curbY),
          Offset(right, curbY),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2)
      ..drawLine(
          Offset(left, curbY + 34),
          Offset(right, curbY + 34),
          Paint()
            ..color = AppColors.charcoal
            ..strokeWidth = 2);
    for (var x = left + 8; x < right - 6; x += 14) {
      canvas.drawRect(
          Rect.fromLTWH(x, curbY + 4, 6, 26),
          Paint()..color = AppColors.ink2.withValues(alpha: 0.35));
    }
    writeOn(
        canvas,
        size,
        '${walk.crosswalk.toStringAsFixed(0)} ft to cross at '
            '${walk.pace.toStringAsFixed(1)} ft a second',
        Offset(left - 8, 8),
        AppColors.ink3,
        fontSize: 9.5);
    writeOn(
        canvas,
        size,
        '${walk.people.toStringAsFixed(0)} people waiting',
        Offset(left - 8, 22),
        AppColors.ink3,
        fontSize: 9.5);

    final barY = size.height - 52;
    if (!answered) {
      canvas.drawRect(
          Rect.fromLTRB(left, barY, right, barY + 16),
          Paint()
            ..color = AppColors.line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
      writeOn(canvas, size, 'what the green is made of comes out',
          Offset(left, barY + 22), AppColors.ink3, fontSize: 9.5);
      writeOn(canvas, size, 'after the answer', Offset(left, barY + 36),
          AppColors.ink3, fontSize: 9.5);
      viewTag(canvas, size, Looking.plan, note: 'the crosswalk');
      return;
    }

    final wide = right - left;
    var x = left;
    for (final (part, label, color) in [
      (Walk.startUp, 'getting going', AppColors.info),
      (walk.walking, 'walking', AppColors.ember),
      (walk.forTheCrowd, 'for the crowd', AppColors.forest),
    ]) {
      final w = part / walk.seconds * wide;
      canvas.drawRect(Rect.fromLTWH(x, barY, w, 16),
          Paint()..color = color.withValues(alpha: 0.45));
      writeOn(canvas, size, '${part.toStringAsFixed(1)} $label',
          Offset(x + 2, barY + (label == 'walking' ? -14 : 22)), color,
          fontSize: 9.5);
      x += w;
    }
    writeOn(
        canvas,
        size,
        '${walk.seconds.toStringAsFixed(1)} seconds of green',
        Offset(left, size.height - 16),
        AppColors.charcoal,
        fontSize: 9.5);
    viewTag(canvas, size, Looking.plan, note: 'the crosswalk');
  }

  @override
  bool shouldRepaint(WalkPainter old) =>
      old.walk != walk || old.answered != answered;
}
