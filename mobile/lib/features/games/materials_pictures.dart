// The pictures on the Materials concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'aggregate_figures.dart';
import 'asphalt_figures.dart';
import 'concrete_figures.dart';
import 'corrosion_figures.dart';
import 'coupon_figures.dart';
import 'crack_figures.dart';
import 'curve_figures.dart';
import 'fiber_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'thermal_figures.dart';
import 'wood_figures.dart';

// ---------------------------------------------------------------------------
// The tensile test

const _coupon = Coupon(
  areaBefore: 150,
  lengthBefore: 50,
  stretch: 0.125,
  thinnedTo: 0.99,
);

Widget underneathPicture() => const ConceptPicture(
  painter: CouponPainter(coupon: _coupon, answer: Dim.areaBefore, locked: true),
  caption:
      'one test bar, measured before and while it is pulled. the marked '
      'measurement is the one engineering stress keeps dividing by',
  height: 210,
);

const _mild = Specimen(
  label: 'mild steel',
  e: 200000,
  yieldStress: 250,
  ultimate: 400,
  fractureStrain: 0.25,
  plateau: 0.014,
  necksTo: 0.86,
);

Widget trueStressPicture() => ConceptPicture(
  painter: BothPainter(
    specimen: _mild,
    frame: Frame.over([_mild]),
    named: true,
    waistLine: true,
  ),
  caption:
      'one test, plotted twice. the two lines sit on top of each other until '
      'the bar starts to thin',
  height: 220,
);

const _castIron = Specimen(
  label: 'cast iron',
  e: 170000,
  yieldStress: 170,
  ultimate: 200,
  fractureStrain: 0.02,
  necksTo: 1,
);

const _aluminumAlloy = Specimen(
  label: 'aluminum alloy',
  e: 70000,
  yieldStress: 400,
  ultimate: 480,
  fractureStrain: 0.12,
  necksTo: 0.92,
);

Widget stiffnessPicture() => const ConceptPicture(
  painter: PairPainter(left: _castIron, right: _aluminumAlloy),
  caption:
      'cast iron starts up steeply and stops low. the aluminum alloy starts '
      'shallow and climbs far higher',
  height: 220,
);

// ---------------------------------------------------------------------------
// Fracture

Widget crackPicture() => const ConceptPair(
  left: PlatePainter(
    plate: Plate(
      flaw: Flaw.edgeLeft,
      crackMm: 10,
      stress: 200,
      toughness: 46,
      material: 'steel',
    ),
  ),
  right: PlatePainter(
    plate: Plate(
      flaw: Flaw.internal,
      crackMm: 10,
      stress: 200,
      toughness: 46,
      material: 'steel',
    ),
  ),
  leftCaption: 'a crack in from the edge. a is the whole of what you see',
  rightCaption: 'a crack buried inside. a is half of what you see',
  height: 220,
);

Widget toughnessPicture() => const ConceptPair(
  left: PlatePainter(
    plate: Plate(
      flaw: Flaw.internal,
      crackMm: 40,
      stress: 100,
      toughness: 46,
      material: 'steel',
    ),
  ),
  right: PlatePainter(
    plate: Plate(
      flaw: Flaw.internal,
      crackMm: 10,
      stress: 200,
      toughness: 46,
      material: 'steel',
    ),
  ),
  leftCaption: 'a long crack pulled gently',
  rightCaption: 'a short crack pulled hard. both are in the same danger',
  height: 220,
);

// ---------------------------------------------------------------------------
// Heat: expansion, cooling rate, the lever rule

Widget expandPicture() => const ConceptPicture(
  painter: MemberPainter(
    members: [
      Member(stuff: Stuff.steel, meters: 12, from: 0, to: 30),
      Member(stuff: Stuff.aluminum, meters: 12, from: 0, to: 30),
      Member(stuff: Stuff.concrete, meters: 12, from: 0, to: 30),
    ],
    longest: 12,
    // The painter measures movement in millimeters, so the biggest of the
    // three is the aluminum one: 23e-6 x 12 m x 1000 x 30 degrees.
    biggest: 8.28,
    answer: 1,
    locked: true,
  ),
  caption:
      'three bars, same length, same warming. the aluminum one grows about '
      'twice as far as the steel',
  height: 210,
);

Widget furnacePicture() => const ConceptPair(
  left: CoolPainter(
    cool: Cool(
      legs: [
        Offset(0, 20),
        Offset(0.8, 900),
        Offset(2, 900),
        Offset(2.1, 20),
        Offset(2.6, 20),
      ],
      outcome: Comes.hardBrittle,
    ),
  ),
  right: CoolPainter(
    cool: Cool(
      legs: [
        Offset(0, 20),
        Offset(0.8, 900),
        Offset(2, 900),
        Offset(9, 20),
        Offset(9.6, 20),
      ],
      outcome: Comes.softDuctile,
    ),
  ),
  leftCaption: 'hot, then dropped in water: the line falls off a cliff',
  rightCaption: 'hot, then left in the furnace: the line strolls down',
  height: 200,
);

Widget tieLinePicture() => const ConceptPicture(
  painter: TiePainter(
    tie: Tie(solid: 10, overall: 30, liquid: 40),
    answer: Arm.toSolid,
    locked: true,
  ),
  caption:
      'the alloy sits between two boundaries. the marked arm is the one that '
      'gives the liquid share, and it points the other way',
  height: 210,
);

// ---------------------------------------------------------------------------
// Concrete: the mix, and what exposure costs

Widget mixPicture() => const ConceptPicture(
  painter: MixPainter(marks: [Mix(wc: 0.40), Mix(wc: 0.80)], showMarks: true),
  caption:
      'strength against water over cement. the same materials, wetter, land '
      'far down the slope',
  height: 210,
);

Widget exposurePicture() => const ConceptPicture(
  painter: MixPainter(
    marks: [Mix(wc: 0.45), Mix(wc: 0.45, air: 6)],
    showMarks: true,
  ),
  caption:
      'the same ratio, with and without entrained air. the lower curve is '
      'the price the air charges',
  height: 210,
);

// ---------------------------------------------------------------------------
// Curing

Widget curingPicture() => const ConceptPicture(
  painter: _PercentPainter(),
  caption:
      'the same slab at seven days and at twenty eight. going left you '
      'multiply, coming back you divide',
  height: 200,
);

Widget fieldPicture() => const ConceptPicture(
  painter: PourPainter(
    pours: [
      Pour(name: 'Mix A', lab: 5400, factor: 0.92, curing: '14 days moist'),
      Pour(name: 'Mix B', lab: 4600, factor: 0.85, curing: '7 days moist'),
    ],
    needs: 4500,
    answer: [true, false],
    locked: true,
  ),
  caption:
      'what the lab cylinders reached, and what the curing leaves in the '
      'slab. the line is what the job needs',
  height: 210,
);

// ---------------------------------------------------------------------------
// Aggregate

Widget weighingPicture() => const ConceptPicture(
  painter: SamplePainter(
    sample: Sample(dry: 480, ssd: 500, submerged: 300),
    answer: Weighing.submerged,
    locked: true,
  ),
  caption:
      'one stone, weighed three ways: dry, soaked and wiped, and hanging in '
      'water. every number on the page comes from these',
  height: 210,
);

Widget gradingPicture() => const ConceptPair(
  left: GradingPainter(
    gradings: [
      Grading(name: 'coarse', passing: [96, 78, 58, 38, 20, 8, 2]),
    ],
  ),
  right: GradingPainter(
    gradings: [
      Grading(name: 'fine', passing: [100, 100, 95, 82, 58, 25, 8]),
    ],
  ),
  leftCaption: 'a coarse sand: less gets through each sieve',
  rightCaption: 'a fine sand: most of it goes through. its modulus is smaller',
  height: 200,
);

// ---------------------------------------------------------------------------
// Asphalt

Widget voidsPicture() => const ConceptPicture(
  painter: PuckPainter(
    puck: Puck(air: 4, binder: 11),
    answer: Piece2.vma,
    locked: true,
  ),
  caption:
      'a compacted specimen by volume: stone, then binder, then air. the '
      'bracket is the space between the stones',
  height: 220,
);

Widget checkPicture() => const ConceptPicture(
  painter: PuckPainter(
    puck: Puck(air: 4, binder: 11),
    answer: Piece2.air,
    locked: true,
  ),
  caption:
      'the air is the thin band marked at the top. the bracket beside it is '
      'the air AND the binder, so it can only ever be bigger',
  height: 220,
);

// ---------------------------------------------------------------------------
// Wood and masonry

Widget moisturePicture() => const ConceptPicture(
  painter: DryingPainter(move: Drying(from: 60, to: 12)),
  caption:
      'timber drying out. nothing happens to its strength until it drops '
      'past the saturation point at thirty percent',
  height: 200,
);

Widget mortarPicture() => const ConceptPicture(
  painter: _MortarPainter(),
  caption:
      'the four mortars, strongest first. the odd letters of MaSoN wOrK are '
      'the only reason the order is rememberable',
  height: 200,
);

Widget factorPicture() => const ConceptPicture(
  painter: _DurationPainter(),
  caption:
      'the load duration factor. the briefer the load, the more the wood is '
      'allowed to carry',
  height: 210,
);

// ---------------------------------------------------------------------------
// Composites

const _carbon = Blend(
  fiberE: 230,
  matrixE: 3.5,
  fiberShare: 0.40,
  fiberName: 'carbon fiber',
  matrixName: 'epoxy',
);

Widget blendPicture() => const ConceptPair(
  left: BlendPainter(blend: _carbon, lay: Lay.along),
  right: BlendPainter(blend: _carbon, lay: Lay.across),
  leftCaption: 'pulled ALONG the fibers: they take the load',
  rightCaption: 'pulled ACROSS them: the soft glue between has to take it',
  height: 210,
);

Widget isostrainPicture() => const ConceptPicture(
  painter: BlendPainter(blend: _carbon, lay: Lay.along, stretched: true),
  caption:
      'glued together and pulled along, both must stretch the same amount. '
      'the stiff fiber needs far more stress to do it',
  height: 210,
);

// ---------------------------------------------------------------------------
// Corrosion

Widget galvanicPicture() => const ConceptPicture(
  painter: CouplePainter(
    couple: Couple(left: Metal.zinc, right: Metal.steel),
    answer: 0,
    locked: true,
  ),
  caption:
      'zinc bolted to steel in wet weather. the marked one is the more '
      'active, so it is the one eaten away',
  height: 210,
);

Widget pickingPicture() => const ConceptPicture(
  painter: _TablePainter(),
  caption:
      'four metals against three requirements. no column has the same winner, '
      'so you cross off rather than pick',
  height: 210,
);

// ---------------------------------------------------------------------------
// Painters that exist only for a sheet

TextPainter _label(String s, {double size = 11, Color color = AppColors.ink2}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(size: size, color: color),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

Paint _stroke(Color color, [double width = 2.4]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _arrow(Canvas canvas, Offset from, Offset to, Paint paint) {
  canvas.drawLine(from, to, paint);
  final d = to - from;
  final len = d.distance;
  if (len < 1) return;
  final u = d / len;
  final n = Offset(-u.dy, u.dx);
  final head = Path()
    ..moveTo(to.dx, to.dy)
    ..lineTo(to.dx - u.dx * 8 + n.dx * 4.5, to.dy - u.dy * 8 + n.dy * 4.5)
    ..lineTo(to.dx - u.dx * 8 - n.dx * 4.5, to.dy - u.dy * 8 - n.dy * 4.5)
    ..close();
  canvas.drawPath(head, Paint()..color = paint.color);
}

/// The same concrete at seven days and at twenty eight, as two bars, with
/// the multiply and the divide drawn as the two directions between them.
class _PercentPainter extends CustomPainter {
  const _PercentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height * 0.74;
    final top = size.height * 0.18;
    final tall = base - top;
    final wide = size.width * 0.2;
    final leftX = size.width * 0.2;
    final rightX = size.width * 0.62;

    void bar(double x, double share, String head, String foot, Color fill) {
      final box = Rect.fromLTWH(x, base - tall * share, wide, tall * share);
      canvas
        ..drawRect(box, Paint()..color = fill)
        ..drawRect(box, _stroke(AppColors.charcoal, 1.6));
      final h = _label(head, size: 12, color: AppColors.charcoal);
      h.paint(
        canvas,
        Offset(x + wide / 2 - h.width / 2, box.top - h.height - 6),
      );
      final f = _label(foot, color: AppColors.ink2);
      f.paint(canvas, Offset(x + wide / 2 - f.width / 2, base + 8));
    }

    bar(
      leftX,
      0.70,
      '70%',
      'at 7 days',
      AppColors.sunbeam.withValues(alpha: 0.4),
    );
    bar(
      rightX,
      1.0,
      '100%',
      'at 28 days',
      AppColors.forest.withValues(alpha: 0.3),
    );

    // The two directions: toward the smaller number you multiply, back to the
    // bigger one you divide.
    final midY = top + tall * 0.22;
    _arrow(
      canvas,
      Offset(rightX - 6, midY),
      Offset(leftX + wide + 6, midY),
      _stroke(AppColors.ember, 2.4),
    );
    final down = _label('x 0.70', size: 12, color: AppColors.ember);
    down.paint(
      canvas,
      Offset(
        (leftX + wide + rightX) / 2 - down.width / 2,
        midY - down.height - 6,
      ),
    );

    final backY = base - tall * 0.16;
    _arrow(
      canvas,
      Offset(leftX + wide + 6, backY),
      Offset(rightX - 6, backY),
      _stroke(AppColors.charcoal, 2.4),
    );
    final up = _label('divide by 0.70', size: 12, color: AppColors.charcoal);
    up.paint(
      canvas,
      Offset((leftX + wide + rightX) / 2 - up.width / 2, backY + 6),
    );
  }

  @override
  bool shouldRepaint(_PercentPainter old) => false;
}

/// The four mortars as a descending stair, with the letters of the phrase
/// that fixes their order picked out.
class _MortarPainter extends CustomPainter {
  const _MortarPainter();

  // The use lines are kept to about ten characters: at this slot width
  // anything longer runs into its neighbour.
  static const _steps = <(String, String)>[
    ('M', 'below grade'),
    ('S', 'soil load'),
    ('N', 'general'),
    ('O', 'old walls'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height * 0.80;
    final top = size.height * 0.16;
    final tall = base - top;
    final slot = (size.width - 40) / _steps.length;
    for (var i = 0; i < _steps.length; i++) {
      final (letter, use) = _steps[i];
      final h = tall * (1 - i * 0.22);
      final box = Rect.fromLTWH(20 + i * slot + 6, base - h, slot - 12, h);
      canvas
        ..drawRect(
          box,
          Paint()..color = AppColors.sunbeam.withValues(alpha: 0.32),
        )
        ..drawRect(box, _stroke(AppColors.charcoal, 1.6));
      final l = _label(letter, size: 20, color: AppColors.charcoal);
      l.paint(canvas, Offset(box.center.dx - l.width / 2, box.top + 8));
      final u = _label(use, size: 9, color: AppColors.ink2);
      u.paint(canvas, Offset(box.center.dx - u.width / 2, base + 6));
    }
    final head = _label('strongest', size: 10, color: AppColors.ink2);
    head.paint(canvas, Offset(20, top - head.height - 2));
    final tail = _label('weakest', size: 10, color: AppColors.ink2);
    tail.paint(
      canvas,
      Offset(size.width - 20 - tail.width, top - tail.height - 2),
    );

    // The phrase, with the letters that name the mortars picked out.
    var x = 20.0;
    final y = size.height * 0.90;
    for (final (piece, ink) in <(String, Color)>[
      ('M', AppColors.ember),
      ('a', AppColors.ink3),
      ('S', AppColors.ember),
      ('o', AppColors.ink3),
      ('N', AppColors.ember),
      (' w', AppColors.ink3),
      ('O', AppColors.ember),
      ('rK', AppColors.ink3),
    ]) {
      final t = _label(piece, size: 13, color: ink);
      t.paint(canvas, Offset(x, y));
      x += t.width;
    }
  }

  @override
  bool shouldRepaint(_MortarPainter old) => false;
}

/// The load duration factor as a ladder: the briefer the load, the higher
/// the wood is allowed to go.
class _DurationPainter extends CustomPainter {
  const _DurationPainter();

  static const _rungs = <(String, double)>[
    ('permanent', 0.9),
    ('normal, ten years', 1.0),
    ('two months of snow', 1.15),
    ('seven days', 1.25),
    ('wind or earthquake', 1.6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.44;
    final right = size.width - 46;
    final top = size.height * 0.12;
    final gap = (size.height * 0.72) / _rungs.length;
    // The bars run from 0.8 so the difference between 0.9 and 1.6 shows.
    double xOf(double cd) => left + (right - left) * (cd - 0.8) / 0.9;

    // The line the reference values were quoted at.
    final oneX = xOf(1.0);
    canvas.drawLine(
      Offset(oneX, top - 4),
      Offset(oneX, top + gap * _rungs.length + 4),
      _stroke(AppColors.ink3, 1.2),
    );

    for (var i = 0; i < _rungs.length; i++) {
      final (name, cd) = _rungs[i];
      final y = top + gap * (i + 0.5);
      final tone = cd > 1
          ? AppColors.forest
          : (cd < 1 ? AppColors.error : AppColors.charcoal);
      canvas.drawLine(
        Offset(left, y),
        Offset(xOf(cd), y),
        _stroke(tone.withValues(alpha: 0.85), 9),
      );
      final n = _label(name, size: 10, color: AppColors.charcoal);
      n.paint(canvas, Offset(left - 8 - n.width, y - n.height / 2));
      final v = _label(cd.toStringAsFixed(2), size: 11, color: tone);
      v.paint(canvas, Offset(xOf(cd) + 6, y - v.height / 2));
    }
    final note = _label(
      'the line is 1.00, what the book value already assumes',
      size: 9.5,
      color: AppColors.ink2,
    );
    note.paint(canvas, Offset(14, size.height - note.height - 6));
  }

  @override
  bool shouldRepaint(_DurationPainter old) => false;
}

/// Four metals against three requirements, as a grid of ticks and crosses.
class _TablePainter extends CustomPainter {
  const _TablePainter();

  static const _cols = <String>['conducts heat', 'light', 'resists seawater'];
  static const _rows = <(String, List<bool>)>[
    ('copper', [true, false, true]),
    ('aluminum', [true, true, true]),
    ('steel', [false, false, false]),
    ('titanium', [false, false, true]),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.26;
    final top = size.height * 0.26;
    final rowH = (size.height * 0.60) / _rows.length;
    final colW = (size.width - left - 14) / _cols.length;

    for (var c = 0; c < _cols.length; c++) {
      final t = _label(_cols[c], size: 9, color: AppColors.ink2);
      t.paint(
        canvas,
        Offset(left + colW * (c + 0.5) - t.width / 2, top - t.height - 8),
      );
    }
    for (var r = 0; r < _rows.length; r++) {
      final (name, flags) = _rows[r];
      final y = top + rowH * (r + 0.5);
      final n = _label(name, size: 11, color: AppColors.charcoal);
      n.paint(canvas, Offset(left - 10 - n.width, y - n.height / 2));
      for (var c = 0; c < flags.length; c++) {
        final x = left + colW * (c + 0.5);
        final ok = flags[c];
        final paint = _stroke(ok ? AppColors.forest : AppColors.error, 2.4);
        if (ok) {
          canvas.drawPath(
            Path()
              ..moveTo(x - 6, y)
              ..lineTo(x - 1, y + 5)
              ..lineTo(x + 7, y - 6),
            paint,
          );
        } else {
          canvas
            ..drawLine(Offset(x - 5, y - 5), Offset(x + 5, y + 5), paint)
            ..drawLine(Offset(x + 5, y - 5), Offset(x - 5, y + 5), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_TablePainter old) => false;
}

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const materialsPictures = <String, Widget Function()>{
  'underneath': underneathPicture,
  'true-stress': trueStressPicture,
  'stiffness': stiffnessPicture,
  'crack': crackPicture,
  'toughness': toughnessPicture,
  'expand': expandPicture,
  'furnace': furnacePicture,
  'tie-line': tieLinePicture,
  'mix': mixPicture,
  'exposure': exposurePicture,
  'curing': curingPicture,
  'field': fieldPicture,
  'weighing': weighingPicture,
  'grading': gradingPicture,
  'voids': voidsPicture,
  'check': checkPicture,
  'moisture': moisturePicture,
  'mortar': mortarPicture,
  'factor': factorPicture,
  'blend': blendPicture,
  'isostrain': isostrainPicture,
  'galvanic': galvanicPicture,
  'picking': pickingPicture,
};
