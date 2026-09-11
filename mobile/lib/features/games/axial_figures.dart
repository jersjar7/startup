import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// What a bar is made of, and the only property of it this lesson needs.
enum Stuff { steel, aluminum, timber }

extension StuffFacts on Stuff {
  /// Young's modulus in megapascals, which is newtons per square millimeter.
  double get e => switch (this) {
        Stuff.steel => 200000,
        Stuff.aluminum => 70000,
        Stuff.timber => 11000,
      };

  String get name_ => switch (this) {
        Stuff.steel => 'steel',
        Stuff.aluminum => 'aluminum',
        Stuff.timber => 'timber',
      };
}

/// One bar under an axial pull.
///
/// Everything the items ask is a property of this, so a round declares the
/// bar and the answers are worked out from it rather than stated beside it.
@immutable
class Bar {
  const Bar({
    required this.length,
    required this.area,
    required this.load,
    required this.stuff,
  });

  /// In millimeters.
  final double length;

  /// In square millimeters.
  final double area;

  /// In newtons, positive for a pull.
  final double load;

  final Stuff stuff;

  /// How far it stretches, in millimeters. Newtons, millimeters and
  /// megapascals together, which is the one set of units that never needs
  /// converting.
  double get stretch => load * length / (area * stuff.e);

  double get stress => load / area;

  /// How thick to draw it, so that a bar with four times the area looks twice
  /// as thick rather than four times.
  double get thickness => math.sqrt(area);
}

/// How a bar is held at its ends, which is all that decides whether heating
/// it stretches it or squeezes it.
enum Held {
  /// One end built in, the other free to move.
  oneEnd,

  /// Built in at both ends, with no room to grow into.
  bothEnds,

  /// Built in at one end with a wall a stated distance from the other.
  withGap,
}

/// What a temperature change does to a held bar.
enum Outcome { nothing, squeezed, stretched }

/// A bar between walls, warmed or cooled.
@immutable
class Rod {
  const Rod({
    required this.length,
    required this.stuff,
    required this.held,
    required this.warmBy,
    this.gap = 0,
  });

  /// In millimeters.
  final double length;

  final Stuff stuff;
  final Held held;

  /// Degrees celsius, negative for a cooling.
  final double warmBy;

  /// The room it has to grow into before it touches, in millimeters.
  final double gap;

  /// Coefficient of thermal expansion, per degree celsius.
  double get alpha => switch (stuff) {
        Stuff.steel => 11.7e-6,
        Stuff.aluminum => 23.0e-6,
        Stuff.timber => 5.0e-6,
      };

  /// How much it WOULD move if nothing were in its way.
  double get freeMove => alpha * length * warmBy;

  /// What actually happens to it, worked out from how it is held and how far
  /// it would have moved, never declared beside the round.
  Outcome get outcome {
    if (held == Held.oneEnd) return Outcome.nothing;
    if (held == Held.withGap && freeMove.abs() <= gap) return Outcome.nothing;
    if (warmBy == 0) return Outcome.nothing;
    return warmBy > 0 ? Outcome.squeezed : Outcome.stretched;
  }

  /// The stress it ends up carrying, in megapascals. A bar with room to grow
  /// into uses up the gap first and only fights for what is left.
  double get stress {
    if (outcome == Outcome.nothing) return 0;
    final fought = held == Held.withGap
        ? freeMove.abs() - gap
        : freeMove.abs();
    return stuff.e * fought / length;
  }
}

/// Two bars drawn one above the other to be compared.
///
/// They share ONE scale, so a bar twice as long looks twice as long and a bar
/// with four times the area looks twice as thick. Each stretched to fill its
/// own row, they could not be compared at all, and comparing them is the
/// whole item.
class BarPairPainter extends CustomPainter {
  const BarPairPainter({
    required this.bars,
    required this.labels,
    this.picked,
    this.truth = -1,
    this.locked = false,
  });

  final List<Bar> bars;
  final List<String> labels;
  final int? picked;
  final int truth;
  final bool locked;

  static const _room = EdgeInsets.fromLTRB(16, 16, 58, 16);

  /// The scale the LENGTHS are drawn at, shared, so a bar twice as long looks
  /// twice as long.
  static double scaleFor(List<Bar> bars, Size size) {
    var longest = 0.0;
    for (final b in bars) {
      longest = math.max(longest, b.length);
    }
    return (size.width - _room.horizontal) / math.max(longest, 0.001);
  }

  /// The scale the THICKNESSES are drawn at, also shared but much larger.
  ///
  /// A structural bar is thousands of millimetres long and tens across, so
  /// one scale for both leaves every bar a hairline and the round about area
  /// has nothing on the screen to look at. Two scales, each shared across the
  /// pair, keeps both comparisons honest even though the shape is not to
  /// scale, which is how a long member is always drawn.
  static double thickScaleFor(List<Bar> bars, Size size) {
    var fattest = 0.0;
    for (final b in bars) {
      fattest = math.max(fattest, b.thickness);
    }
    final row = (size.height - _room.vertical) / bars.length;
    return math.min(30.0, row * 0.34) / math.max(fattest, 0.001);
  }

  /// The row one bar is drawn in, which is also where it is tapped.
  static Rect rowFor(List<Bar> bars, Size size, int i) {
    final row = (size.height - _room.vertical) / bars.length;
    return Rect.fromLTWH(
        _room.left, _room.top + i * row, size.width - _room.horizontal, row);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = scaleFor(bars, size);
    final t = thickScaleFor(bars, size);
    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final row = rowFor(bars, size, i);
      final Color edge;
      if (locked && i == truth) {
        edge = AppColors.forest;
      } else if (locked && picked == i) {
        edge = AppColors.error;
      } else if (picked == i) {
        edge = AppColors.ember;
      } else {
        edge = AppColors.charcoal;
      }

      final long = bar.length * s;
      final thick = bar.thickness * t;
      final mid = row.top + row.height * 0.40;
      final body = Rect.fromLTWH(row.left + 12, mid - thick / 2, long, thick);

      canvas.drawRect(body, Paint()..color = AppColors.sunbeamBg);
      canvas.drawRect(
        body,
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = (picked == i || (locked && i == truth)) ? 3 : 2,
      );
      _wall(canvas, Offset(body.left, mid), thick);
      _pull(canvas, Offset(body.right, mid), edge);

      _write(canvas, labels[i], Offset(body.left, mid + thick / 2 + 14),
          AppColors.ink3, size);
    }
  }

  void _wall(Canvas canvas, Offset at, double thick) {
    final tall = math.max(thick * 0.75, 15.0);
    canvas.drawLine(
      at - Offset(0, tall),
      at + Offset(0, tall),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2.2,
    );
    final hatch = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.2;
    for (var y = -tall; y < tall; y += 8) {
      canvas.drawLine(at + Offset(0, y), at + Offset(-7, y + 6), hatch);
    }
  }

  void _pull(Canvas canvas, Offset at, Color colour) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final tip = at + const Offset(40, 0);
    canvas.drawLine(at, tip, paint);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 9, tip.dy - 4.5)
        ..lineTo(tip.dx - 9, tip.dy + 4.5)
        ..close(),
      Paint()..color = colour,
    );
  }

  void _write(Canvas canvas, String text, Offset at, Color colour, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    tp.paint(canvas, Offset(x, at.dy));
  }

  @override
  bool shouldRepaint(BarPairPainter old) =>
      old.bars != bars || old.picked != picked || old.locked != locked;
}

/// A rod between walls, warmed or cooled.
class RodPainter extends CustomPainter {
  const RodPainter({required this.rod, this.showOutcome = false});

  final Rod rod;
  final bool showOutcome;

  static const _room = EdgeInsets.fromLTRB(30, 40, 30, 44);

  @override
  void paint(Canvas canvas, Size size) {
    final long = size.width - _room.horizontal;
    final mid = _room.top + (size.height - _room.vertical) / 2;
    const thick = 30.0;
    final left = _room.left;
    // A gap is drawn to scale against the rod, blown up so a fraction of a
    // millimeter is something you can see. It is a real gap either way.
    final gapPx = rod.held == Held.withGap
        ? (rod.gap / rod.length * long * 260).clamp(6.0, 34.0)
        : 0.0;
    final body =
        Rect.fromLTWH(left, mid - thick / 2, long - gapPx, thick);

    final Color edge = showOutcome
        ? switch (rod.outcome) {
            Outcome.nothing => AppColors.ink2,
            Outcome.squeezed => AppColors.error,
            Outcome.stretched => AppColors.info,
          }
        : AppColors.charcoal;

    canvas.drawRect(body, Paint()..color = AppColors.sunbeamBg);
    canvas.drawRect(
      body,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    _wall(canvas, Offset(left, mid), out: -1);
    if (rod.held != Held.oneEnd) {
      _wall(canvas, Offset(left + long, mid), out: 1);
    }

    final taken = <Rect>[];
    if (gapPx > 0) {
      // The gap gets its own dimension, because how big it is against the
      // free growth is the whole question on those rounds.
      final from = Offset(body.right, mid + thick / 2 + 16);
      final to = Offset(left + long, mid + thick / 2 + 16);
      final ink = Paint()
        ..color = AppColors.ember
        ..strokeWidth = 1.6;
      canvas.drawLine(from, to, ink);
      for (final at in [from, to]) {
        canvas.drawLine(
            at - const Offset(0, 6), at + const Offset(0, 6), ink);
      }
      taken.add(_write(canvas, 'gap', Offset((from.dx + to.dx) / 2, to.dy + 5),
          AppColors.ember, size, taken));
    }

    // What is being done to it, said on the drawing and not only in the words.
    final warmer = rod.warmBy > 0;
    final heat = warmer ? AppColors.error : AppColors.info;
    final arrows = Offset(left + long / 2, mid - thick / 2 - 22);
    for (final way in [-1.0, 1.0]) {
      final root = arrows + Offset(way * 22, 0);
      final tip = root + Offset(way * (warmer ? 18 : -14), 0);
      final paint = Paint()
        ..color = heat
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(root, tip, paint);
      final back = tip.dx > root.dx ? -1.0 : 1.0;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + back * 8, tip.dy - 4)
          ..lineTo(tip.dx + back * 8, tip.dy + 4)
          ..close(),
        Paint()..color = heat,
      );
    }
    taken.add(_write(
      canvas,
      warmer ? 'warmed' : 'cooled',
      arrows - const Offset(0, 20),
      heat,
      size,
      taken,
    ));
  }

  void _wall(Canvas canvas, Offset at, {required double out}) {
    const tall = 30.0;
    canvas.drawLine(
      at - const Offset(0, tall),
      at + const Offset(0, tall),
      Paint()
        ..color = AppColors.charcoal
        ..strokeWidth = 2.6,
    );
    final hatch = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 1.3;
    for (var y = -tall; y < tall; y += 9) {
      canvas.drawLine(at + Offset(0, y), at + Offset(out * 8, y + 7), hatch);
    }
  }

  Rect _write(Canvas canvas, String text, Offset at, Color colour, Size size,
      List<Rect> avoid) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTheme.mono(size: 11, color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = at.dx - tp.width / 2;
    var y = at.dy;
    if (x < 2) x = 2;
    if (x + tp.width > size.width - 2) x = size.width - 2 - tp.width;
    Rect box() => Rect.fromLTWH(x - 2, y, tp.width + 4, tp.height);
    for (var tries = 0; tries < 3; tries++) {
      if (!avoid.any((r) => r.overlaps(box()))) break;
      y -= tp.height + 3;
    }
    canvas.drawRect(
        box(), Paint()..color = AppColors.cream.withValues(alpha: 0.92));
    tp.paint(canvas, Offset(x, y));
    return box();
  }

  @override
  bool shouldRepaint(RodPainter old) =>
      old.rod != rod || old.showOutcome != showOutcome;
}

/// A unit as it is actually written down in a substitution.
///
/// The lesson names mixing meters and millimeters as the single commonest
/// source of wrong answers, and that mistake is dimensionally PERFECT: the
/// units cancel exactly as they should and the number is out by a thousand.
/// So a unit here carries which length it is written in as well as what it
/// measures.
enum Written { newton, mm, mmSq, mpa, meter, mSq, celsius, perCelsius }

extension WrittenFacts on Written {
  /// Powers of force, length and temperature.
  (int, int, int) get dims => switch (this) {
        Written.newton => (1, 0, 0),
        Written.mm || Written.meter => (0, 1, 0),
        Written.mmSq || Written.mSq => (0, 2, 0),
        Written.mpa => (1, -2, 0),
        Written.celsius => (0, 0, 1),
        Written.perCelsius => (0, 0, -1),
      };

  /// Which length this unit is written in: one for millimeters, two for
  /// meters, zero for units that carry no length at all.
  int get base => switch (this) {
        Written.mm || Written.mmSq || Written.mpa => 1,
        Written.meter || Written.mSq => 2,
        Written.newton || Written.celsius || Written.perCelsius => 0,
      };

  String get shown => switch (this) {
        Written.newton => 'N',
        Written.mm => 'mm',
        Written.mmSq => r'mm^2',
        Written.mpa => r'N/mm^2',
        Written.meter => 'm',
        Written.mSq => r'm^2',
        Written.celsius => r'^\circ C',
        Written.perCelsius => r'1/^\circ C',
      };
}

/// What an expression hands back.
enum Gives {
  /// Force over an area.
  stress,

  /// A distance.
  length,

  /// A ratio with nothing left on it, which is what a strain is.
  pureNumber,

  /// The units cancel correctly and the answer is still out by a factor of a
  /// thousand, because two different lengths were written into one sum.
  mixedUnits,
}

/// One quantity as it appears in a substitution.
@immutable
class Term {
  const Term(this.symbol, this.unit);
  final String symbol;
  final Written unit;
}

/// A substitution: what is on the top of the fraction and what is underneath.
@immutable
class Sum {
  const Sum({required this.over, this.under = const []});

  final List<Term> over;
  final List<Term> under;

  /// Whether two different lengths have been written into the one expression.
  /// Checked FIRST, because a mixed sum is wrong however tidily it cancels.
  bool get mixed {
    final bases = <int>{};
    for (final t in [...over, ...under]) {
      if (t.unit.base != 0) bases.add(t.unit.base);
    }
    return bases.length > 1;
  }

  /// Worked out from the units written on the terms, never declared.
  Gives get gives {
    if (mixed) return Gives.mixedUnits;
    var f = 0;
    var l = 0;
    var t = 0;
    for (final term in over) {
      final (a, b, c) = term.unit.dims;
      f += a;
      l += b;
      t += c;
    }
    for (final term in under) {
      final (a, b, c) = term.unit.dims;
      f -= a;
      l -= b;
      t -= c;
    }
    if (f == 1 && l == -2 && t == 0) return Gives.stress;
    if (f == 0 && l == 1 && t == 0) return Gives.length;
    if (f == 0 && l == 0 && t == 0) return Gives.pureNumber;
    // Nothing else is reachable from the quantities this lesson deals in, and
    // a test holds every round to that.
    return Gives.pureNumber;
  }

  /// The substitution as LaTeX, units and all.
  String get latex {
    String row(List<Term> ts) => ts
        .map((t) => '${t.symbol}\\,[\\mathrm{${t.unit.shown}}]')
        .join(' \\times ');
    if (under.isEmpty) return row(over);
    return '\\dfrac{${row(over)}}{${row(under)}}';
  }
}
