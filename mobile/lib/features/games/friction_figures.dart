import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// One block, one surface, one push on it.
///
/// Everything the three friction items ask is a property of this and nothing
/// else, so the rounds declare the situation and the answers are worked out
/// from it. A round cannot draw one scene and grade another.
@immutable
class Rig {
  const Rig({
    required this.weight,
    required this.mu,
    this.rampDeg = 0,
    this.pushDeg = 0,
    this.uphill = true,
    this.wide = false,
  });

  /// In newtons.
  final double weight;

  final double mu;

  /// How far the surface is tilted from level.
  final double rampDeg;

  /// The angle of the push, measured from the SURFACE. Zero runs along it,
  /// positive lifts away from it, negative presses into it. A horizontal push
  /// on a ramp is therefore minus the ramp angle, which is the whole of the
  /// lesson's hardest problem.
  final double pushDeg;

  /// Whether the push is trying to move it up the slope or down it.
  final bool uphill;

  /// Drawn lying on its wide side rather than standing on its end. Nothing in
  /// any formula here reads it, which is exactly the point of the round that
  /// uses it.
  final bool wide;

  double get _tilt => rampDeg * math.pi / 180;
  double get _shove => pushDeg * math.pi / 180;

  /// What the weight alone presses into the surface with.
  double get seat => weight * math.cos(_tilt);

  /// The most this surface can hold back before it lets go, under the weight
  /// alone. A ceiling, never a value: friction is whatever it has to be up to
  /// here and not a newton more.
  double get ceiling => mu * seat;

  /// What is trying to slide it when nothing is pushing: the part of its own
  /// weight that runs down the slope.
  double get slideDemand => weight * math.sin(_tilt);

  /// The slope at which it lets go on its own, which is where the demand
  /// catches the ceiling. Nothing to do with how heavy it is.
  bool get atRepose => (math.tan(_tilt) - mu).abs() < 0.002;

  /// The push needed to put it on the verge of moving.
  ///
  /// The push does two things at once and both belong in here: a part of it
  /// runs along the surface and helps, and a part of it presses into the
  /// surface and makes the friction it has to beat bigger.
  double get pushToSlide {
    final along = uphill
        ? math.sin(_tilt) + mu * math.cos(_tilt)
        : mu * math.cos(_tilt) - math.sin(_tilt);
    final split = math.cos(_shove) + mu * math.sin(_shove);
    return weight * along / split;
  }
}

/// What friction is doing at this instant.
enum Grip {
  /// Matching whatever is trying to slide it, and no more than that.
  matching,

  /// All the way up at its ceiling, which is the only time it equals mu N.
  atTheLimit,

  /// Nothing, because nothing is trying to slide it.
  none,
}

/// Where everything in a block figure lands, worked out once so the painter
/// and anything that has to point at the drawing agree.
@immutable
class BlockLayout {
  const BlockLayout({
    required this.foot,
    required this.peak,
    required this.corners,
    required this.along,
    required this.up,
  });

  /// The two ends of the sloping surface.
  final Offset foot;
  final Offset peak;

  /// The block, starting at its lower back corner and going round.
  final List<Offset> corners;

  /// Unit vectors up the surface and square out of it.
  final Offset along;
  final Offset up;

  Offset get seat => (corners[0] + corners[1]) / 2;
  Offset get middle => (corners[0] + corners[2]) / 2;

  /// The face the push lands on, which is the back of the block.
  Offset get backFace => (corners[0] + corners[3]) / 2;
}

/// A block on a surface, drawn the way a drafter would.
class BlockPainter extends CustomPainter {
  const BlockPainter({
    required this.rig,
    this.showPush = false,
    this.pushLabel,
    this.showWeight = true,
    this.grip,
    this.frameDeg,
  });

  final Rig rig;
  final bool showPush;
  final String? pushLabel;
  final bool showWeight;

  /// Draws the friction arrow at the length this state calls for.
  final Grip? grip;

  /// The angle to SIZE the figure for, when it is one of a pair that has to
  /// be compared. Two ramps drawn side by side, each stretched to fill its own
  /// box, are two ramps you cannot compare: the steeper one comes out smaller
  /// and the difference the round is asking about disappears.
  final double? frameDeg;

  /// Room round the drawing for the arrows and labels hung off it, scaled to
  /// the box. A fixed inset is most of a small panel and none of a big one.
  static EdgeInsets _roomFor(Size size) => EdgeInsets.fromLTRB(
        math.min(30, size.width * 0.11),
        math.min(40, size.height * 0.16),
        math.min(30, size.width * 0.11),
        math.min(38, size.height * 0.15),
      );

  static BlockLayout layout(Rig rig, Size size, {double? frameDeg}) {
    final tilt = rig.rampDeg * math.pi / 180;
    final frame = (frameDeg ?? rig.rampDeg) * math.pi / 180;

    // The wedge is measured, never pinned: as long as it can be and still
    // leave room for everything hung off it.
    final room = _roomFor(size);
    final wide = size.width - room.horizontal;
    final tall = size.height - room.vertical;
    final run = math.min(wide, tall / math.max(math.tan(frame), 0.001));
    final rise = run * math.tan(tilt);
    final framedRise = run * math.tan(frame);

    // The block is sized off the surface it stands on, so it never swamps a
    // short ramp or gets lost on a long one.
    final base = (run * 0.30).clamp(30.0, 56.0);
    final half = rig.wide ? base * 0.86 : base * 0.46;
    final high = rig.wide ? base * 0.50 : base * 0.92;
    const perch = 0.44;

    // Framed to what is actually drawn rather than to the wedge. A level
    // floor has no wedge at all, and centring on one leaves the block sitting
    // in the top half of an empty box.
    // Measured from the FRAME rather than from this rig, so both halves of a
    // comparison share a baseline. Sized for the tallest the block can be, so
    // laying it on its side lowers the block and not the floor under it.
    const hatchDeep = 8.0;
    final topExtent =
        math.max(framedRise, framedRise * perch + base * 0.92);
    final ground =
        room.top + topExtent + (tall - topExtent - hatchDeep) / 2;

    final left = room.left + (wide - run) / 2;
    final foot = Offset(left, ground);
    final peak = Offset(left + run, ground - rise);

    final along = (peak - foot) / (peak - foot).distance;
    final up = Offset(-math.sin(tilt), -math.cos(tilt));
    final seat = foot + along * (run * perch);

    return BlockLayout(
      foot: foot,
      peak: peak,
      along: along,
      up: up,
      corners: [
        seat - along * half,
        seat + along * half,
        seat + along * half + up * high,
        seat - along * half + up * high,
      ],
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final l = layout(rig, size, frameDeg: frameDeg);

    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (rig.rampDeg > 0.01) {
      canvas.drawPath(
        Path()
          ..moveTo(l.foot.dx, l.foot.dy)
          ..lineTo(l.peak.dx, l.peak.dy)
          ..lineTo(l.peak.dx, l.foot.dy)
          ..close(),
        ink,
      );
    } else {
      canvas.drawLine(l.foot, l.peak, ink);
    }
    _hatch(canvas, l.foot, Offset(l.peak.dx, l.foot.dy));

    canvas.drawPath(
      Path()..addPolygon(l.corners, true),
      Paint()..color = AppColors.cream,
    );
    canvas.drawPath(
      Path()..addPolygon(l.corners, true),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    final taken = <Rect>[];
    final tall = (l.corners[3] - l.corners[0]).distance;

    if (showWeight) {
      // Long enough to read as a force. Drawn from the top of the block it is
      // a vector; drawn from the middle it is a stub half hidden inside its
      // own block.
      final from = l.middle - Offset(0, tall * 0.34);
      final tip = l.middle + Offset(0, tall * 0.52 + 12);
      _arrow(canvas, from, tip, AppColors.ink2);
      // Clear of the block on one side and clear of the ground on the other.
      // Under the arrowhead is the hatching, and a label written across the
      // hatching cuts it in half. Measured before it is placed, and put on
      // whichever side of the block it actually fits.
      final text = '${rig.weight.round()} N';
      final wide = _widthOf(text);
      final right = l.corners.map((c) => c.dx).reduce(math.max);
      final leftSide = l.corners.map((c) => c.dx).reduce(math.min);
      final fits = right + 8 + wide < size.width - 4;
      taken.add(_write(
        canvas,
        text,
        Offset(fits ? right + 8 : leftSide - 8 - wide, l.middle.dy - 6),
        AppColors.ink3,
        size,
        taken,
        fromLeft: true,
      ));
    }

    if (showPush) {
      final lean = rig.pushDeg * math.pi / 180;
      final dir = l.along * math.cos(lean) + l.up * math.sin(lean);
      final tip = l.backFace;
      final tail = tip - dir * 50;
      _arrow(canvas, tail, tip, AppColors.ember);
      if (pushLabel != null) {
        // Above the middle of the shaft, so a long one does not get shoved
        // against the side of the figure and clipped there.
        final mid = (tail + tip) / 2;
        taken.add(_write(canvas, pushLabel!, mid - const Offset(0, 20),
            AppColors.ember, size, taken));
      }
    }

    if (grip != null && grip != Grip.none) {
      // Friction acts along the surface, back against whatever is winning.
      final reach = grip == Grip.atTheLimit ? 46.0 : 25.0;
      final root = l.seat + l.up * 6;
      _arrow(canvas, root, root + l.along * reach, AppColors.forest);
    }
  }

  void _hatch(Canvas canvas, Offset from, Offset to) {
    final ink = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.3;
    for (var x = from.dx; x < to.dx; x += 9) {
      canvas.drawLine(Offset(x, to.dy), Offset(x - 6, to.dy + 7), ink);
    }
    canvas.drawLine(from, Offset(to.dx, from.dy), ink);
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color colour) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    final run = to - from;
    if (run.distance < 1) return;
    final unit = run / run.distance;
    final side = Offset(-unit.dy, unit.dx);
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - unit.dx * 9 + side.dx * 4.5,
            to.dy - unit.dy * 9 + side.dy * 4.5)
        ..lineTo(to.dx - unit.dx * 9 - side.dx * 4.5,
            to.dy - unit.dy * 9 - side.dy * 4.5)
        ..close(),
      Paint()..color = colour,
    );
  }

  double _widthOf(String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10.5)),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  Rect _write(Canvas canvas, String text, Offset at, Color colour, Size size,
      List<Rect> avoid, {bool fromLeft = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10.5, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = fromLeft ? at.dx : at.dx - tp.width / 2;
    var y = at.dy;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    Rect box() => Rect.fromLTWH(x - 2, y, tp.width + 4, tp.height);
    for (var tries = 0; tries < 4; tries++) {
      if (!avoid.any((r) => r.overlaps(box()))) break;
      y -= tp.height + 3;
    }
    if (y < 1) y = 1;
    if (y + tp.height > size.height - 1) y = size.height - 1 - tp.height;
    canvas.drawRect(
        box(), Paint()..color = AppColors.cream.withValues(alpha: 0.92));
    tp.paint(canvas, Offset(x, y));
    return box();
  }

  @override
  bool shouldRepaint(BlockPainter old) =>
      old.rig != rig || old.grip != grip || old.showPush != showPush;
}

/// Which way the belt is being dragged around the drum.
enum Creep { clockwise, counter }

/// A belt, rope or band lying on a drum, with a free end hanging off each side.
///
/// Angles are the ordinary ones: zero points right and they grow the way a
/// clock does not. The belt lies from [startDeg] and sweeps that way for
/// [sweepDeg], which may be more than a full turn.
@immutable
class Lap {
  const Lap({
    required this.startDeg,
    required this.sweepDeg,
    required this.creep,
    required this.startLabel,
    required this.endLabel,
  });

  final double startDeg;
  final double sweepDeg;
  final Creep creep;

  /// What is hanging off each free end, in the round's own words.
  final String startLabel;
  final String endLabel;

  double get endDeg => startDeg + sweepDeg;

  /// How far round it lies, in radians, which is the only unit the belt
  /// formula will take.
  double get contact => sweepDeg * math.pi / 180;

  /// The end carrying the bigger pull.
  ///
  /// Friction drags backward on the belt the whole way round, so the tension
  /// climbs from the end the belt is coming FROM to the end it is heading
  /// TOWARD. The tight side is the downstream one, and downstream is set by
  /// which way the belt is creeping, not by which end looks busier.
  bool get tightIsEnd => creep == Creep.counter;
}

/// The drum, the belt on it, and a free end hanging off each side.
class DrumPainter extends CustomPainter {
  const DrumPainter({
    required this.lap,
    this.picked,
    this.locked = false,
  });

  final Lap lap;

  /// false for the start end, true for the finish end.
  final bool? picked;
  final bool locked;

  static const _room = 30.0;
  static const _tail = 0.95;
  static const _seat = 1.12;

  /// Where the belt lies at a point along the lap, with the drum a unit
  /// circle. A rope taken round a post more than once has to be drawn as more
  /// than one turn or the figure says something it does not mean, so the lap
  /// creeps outward as it goes.
  static Offset _unitOn(Lap lap, double fraction) {
    final grow = lap.sweepDeg <= 361 ? 1.0 : 1 + 0.34 * fraction;
    final a = (lap.startDeg + lap.sweepDeg * fraction) * math.pi / 180;
    final out = _seat * grow;
    return Offset(math.cos(a) * out, -math.sin(a) * out);
  }

  static Offset _unitEnd(Lap lap, bool isEnd) {
    final deg = isEnd ? lap.endDeg : lap.startDeg;
    final a = deg * math.pi / 180;
    // The belt leaves along the tangent: forward at the finish, backward at
    // the start, because that is the way it came in.
    final tangent = isEnd
        ? Offset(-math.sin(a), -math.cos(a))
        : Offset(math.sin(a), math.cos(a));
    return _unitOn(lap, isEnd ? 1 : 0) + tangent * _tail;
  }

  /// The figure is framed to everything it draws, drum and tails together,
  /// and then centred. Framed to the drum alone it sits off to one side,
  /// because both free ends usually leave the same way.
  static ({double r, Offset centre}) _fit(Lap lap, Size size) {
    var box = Rect.fromCircle(center: Offset.zero, radius: 1);
    void take(Offset p) =>
        box = box.expandToInclude(Rect.fromCircle(center: p, radius: 0.001));
    for (var i = 0; i <= 72; i++) {
      take(_unitOn(lap, i / 72));
    }
    take(_unitEnd(lap, false));
    take(_unitEnd(lap, true));

    final r = math.min(
      (size.width - _room * 2) / box.width,
      (size.height - _room * 2) / box.height,
    );
    return (
      r: r,
      centre: Offset(
        size.width / 2 - box.center.dx * r,
        size.height / 2 - box.center.dy * r,
      ),
    );
  }

  static double radiusFor(Lap lap, Size size) => _fit(lap, size).r;

  static Offset _on(Lap lap, double fraction, Size size) {
    final f = _fit(lap, size);
    return f.centre + _unitOn(lap, fraction) * f.r;
  }

  /// Where a free end finishes, which is where it is tapped.
  static Offset endPoint(Lap lap, Size size, bool isEnd) {
    final f = _fit(lap, size);
    return f.centre + _unitEnd(lap, isEnd) * f.r;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final f = _fit(lap, size);
    final centre = f.centre;
    final r = f.r;

    canvas.drawCircle(centre, r, Paint()..color = AppColors.cream);
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..color = AppColors.ink2
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    canvas.drawCircle(centre, 3.5, Paint()..color = AppColors.ink2);

    final path = Path()..moveTo(_on(lap, 0, size).dx, _on(lap, 0, size).dy);
    const steps = 200;
    for (var i = 1; i <= steps; i++) {
      final p = _on(lap, i / steps, size);
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );

    final taken = <Rect>[];
    for (final isEnd in [false, true]) {
      final root = _on(lap, isEnd ? 1 : 0, size);
      final tip = endPoint(lap, size, isEnd);
      final chosen = picked == isEnd;
      final truth = lap.tightIsEnd == isEnd;
      final Color colour;
      if (locked && truth) {
        colour = AppColors.forest;
      } else if (locked && chosen) {
        colour = AppColors.error;
      } else if (chosen) {
        colour = AppColors.ember;
      } else {
        colour = AppColors.charcoal;
      }
      canvas.drawLine(
        root,
        tip,
        Paint()
          ..color = colour
          ..strokeWidth = chosen || (locked && truth) ? 4.6 : 3.4
          ..strokeCap = StrokeCap.round,
      );
      // The label goes on further along the belt's own line, so it never
      // lands back on the drum or on top of the other end.
      final run = tip - root;
      final unit = run / run.distance;
      taken.add(_write(
        canvas,
        isEnd ? lap.endLabel : lap.startLabel,
        tip + unit * 17 - const Offset(0, 6),
        colour,
        size,
        taken,
      ));
    }

    _creepMark(canvas, size, r, taken);
  }

  /// Chevrons ON the belt, pointing the way it is creeping.
  ///
  /// Drawn on the belt and not inside the drum on purpose. An arrow in the
  /// middle of the circle reads as the drum turning, and on a bollard the
  /// post never turns at all: it is the rope that slides.
  void _creepMark(Canvas canvas, Size size, double r, List<Rect> labels) {
    final forward = lap.creep == Creep.counter;
    // These decide the answer, so they are drawn like it: sized off the drum
    // rather than off a number, and heavy enough to read at a glance.
    final arm = (r * 0.20).clamp(7.0, 13.0);
    final step = math.min(0.05, 40 / math.max(lap.sweepDeg, 1));
    for (final want in [0.25, 0.5, 0.75]) {
      // Slid along the belt until it is clear of the labels. A chevron drawn
      // under a word is the one mark on the figure the answer depends on, put
      // where it cannot be read.
      var at = want;
      for (var tries = 0; tries < 10; tries++) {
        final box = Rect.fromCircle(center: _on(lap, at, size), radius: arm);
        if (!labels.any((l) => l.overlaps(box))) break;
        at = (want + (tries.isEven ? 1 : -1) * 0.035 * (tries ~/ 2 + 1))
            .clamp(0.06, 0.94);
      }
      final here = _on(lap, at, size);
      final ahead = _on(lap, at + (forward ? step : -step), size);
      final run = ahead - here;
      if (run.distance < 0.5) continue;
      final unit = run / run.distance;
      final side = Offset(-unit.dy, unit.dx);
      final tip = here + unit * arm * 0.7;
      final ink = Paint()
        ..color = AppColors.ember
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(tip, tip - unit * arm + side * arm * 0.78, ink);
      canvas.drawLine(tip, tip - unit * arm - side * arm * 0.78, ink);
    }
  }

  Rect _write(Canvas canvas, String text, Offset at, Color colour, Size size,
      List<Rect> avoid) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 10.5, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - tp.width / 2;
    var y = at.dy;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    Rect box() => Rect.fromLTWH(x - 2, y, tp.width + 4, tp.height);
    for (var tries = 0; tries < 4; tries++) {
      if (!avoid.any((r) => r.overlaps(box()))) break;
      y -= tp.height + 3;
    }
    if (y < 1) y = 1;
    if (y + tp.height > size.height - 1) y = size.height - 1 - tp.height;
    canvas.drawRect(
        box(), Paint()..color = AppColors.cream.withValues(alpha: 0.92));
    tp.paint(canvas, Offset(x, y));
    return box();
  }

  @override
  bool shouldRepaint(DrumPainter old) =>
      old.lap != lap || old.picked != picked || old.locked != locked;
}
