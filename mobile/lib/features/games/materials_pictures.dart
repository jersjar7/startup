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
import 'coupon_figures.dart';
import 'crack_figures.dart';
import 'curve_figures.dart';
import 'figure_ink.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'thermal_figures.dart';

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
};
