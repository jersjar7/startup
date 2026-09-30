// The pictures on the Structural Engineering concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles. The few painters that exist only
// here draw a comparison no game in the chapter needed to draw.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'beam_figures.dart' show Prop;
import 'determinacy_figures.dart';
import 'influence_figures.dart';
import 'load_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'rc_figures.dart';
import 'redundant_figures.dart';
import 'steel_figures.dart' as steel;
import 'tension_figures.dart';
import 'truss_figures.dart';
import 'truss_section_figures.dart';
import 'virtual_work_figures.dart';

// ---------------------------------------------------------------------------
// 95 Determinacy

/// A pin-jointed truss: every joint is a hinge, so the count is the truss one.
const _pinnedTruss = Skeleton(
  joints: [
    Offset(0, 0),
    Offset(2, 0),
    Offset(4, 0),
    Offset(1, 1.4),
    Offset(3, 1.4),
  ],
  members: [(0, 1), (1, 2), (3, 4), (0, 3), (1, 3), (1, 4), (2, 4)],
  holds: {0: Hold.pin, 2: Hold.roller},
);

/// The same outline with welded corners, which makes it a frame.
const _rigidFrame = Skeleton(
  joints: [Offset(0, 0), Offset(0, 2), Offset(3, 2), Offset(3, 0)],
  members: [(0, 1), (1, 2), (2, 3)],
  holds: {0: Hold.pin, 3: Hold.fixed},
  rigid: true,
);

Widget countPicture() => const ConceptPair(
  left: SkeletonPainter(skeleton: _pinnedTruss, showCount: true),
  right: SkeletonPainter(skeleton: _rigidFrame, showCount: true),
  leftCaption: 'hinged corners: a truss, two equations per joint',
  rightCaption: 'welded corners: a frame, three equations per joint',
  height: 200,
);

/// Three vertical rollers: the count comes out right and it slides sideways.
const _parallelHeld = Skeleton(
  joints: [
    Offset(0, 0),
    Offset(2, 0),
    Offset(4, 0),
    Offset(0.5, 1.2),
    Offset(2, 1.2),
    Offset(3.5, 1.2),
  ],
  members: [
    (0, 1),
    (1, 2),
    (3, 4),
    (4, 5),
    (0, 3),
    (3, 1),
    (1, 4),
    (1, 5),
    (2, 5),
  ],
  holds: {0: Hold.roller, 1: Hold.roller, 2: Hold.roller},
  parallelReactions: true,
);

/// The same truss with one roller swapped for a pin.
const _properlyHeld = Skeleton(
  joints: [
    Offset(0, 0),
    Offset(2, 0),
    Offset(4, 0),
    Offset(0.5, 1.2),
    Offset(2, 1.2),
    Offset(3.5, 1.2),
  ],
  members: [
    (0, 1),
    (1, 2),
    (3, 4),
    (4, 5),
    (0, 3),
    (3, 1),
    (1, 4),
    (1, 5),
    (2, 5),
  ],
  holds: {0: Hold.pin, 1: Hold.roller, 2: Hold.roller},
);

Widget stabilityPicture() => const ConceptPair(
  left: SkeletonPainter(skeleton: _parallelHeld, showWhy: true),
  right: SkeletonPainter(skeleton: _properlyHeld),
  leftCaption: 'three rollers: the count says fine, a sideways push slides it',
  rightCaption:
      'one of them a pin: now a sideways push has something to hold it',
  height: 200,
);

// ---------------------------------------------------------------------------
// 96 Truss methods

const _sectionTruss = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('B', Offset(4, 0)),
    Joint('C', Offset(8, 0)),
    Joint('D', Offset(12, 0)),
    Joint('E', Offset(16, 0)),
    Joint('F', Offset(4, 3)),
    Joint('G', Offset(8, 3)),
    Joint('H', Offset(12, 3)),
  ],
  supports: {0: Prop.pin, 4: Prop.roller},
  members: [
    (0, 1),
    (1, 2),
    (2, 3),
    (3, 4),
    (5, 6),
    (6, 7),
    (0, 5),
    (4, 7),
    (1, 5),
    (2, 6),
    (3, 7),
    (5, 2),
    (7, 2),
  ],
);

Widget pivotPicture() => const ConceptPicture(
  painter: SectionPointsPainter(
    truss: _sectionTruss,
    cut: Cut('section', Offset(6, -1.2), Offset(6, 4.2)),
    target: 1,
    anchors: [Anchor('P', Offset(4, 3)), Anchor('Q', Offset(8, 0))],
    picked: 0,
    answer: 0,
    locked: true,
  ),
  caption:
      'one cut, three bars severed. P is where the two bars you do not want cross',
  height: 210,
);

Widget jointForcePicture() => const ConceptPair(
  left: CornerPainter(corner: Corner(load: 500, degrees: 45), answered: true),
  right: CornerPainter(corner: Corner(load: 500, degrees: 15), answered: true),
  leftCaption: 'a steep diagonal carries the 500 with room to spare',
  rightCaption: 'the same 500 on a flat one needs a far bigger pull',
  height: 200,
);

const _routeTruss = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('B', Offset(4, 0)),
    Joint('C', Offset(8, 0)),
    Joint('D', Offset(12, 0)),
    Joint('E', Offset(4, 3)),
    Joint('F', Offset(8, 3)),
  ],
  supports: {0: Prop.pin, 3: Prop.roller},
  members: [
    (0, 1),
    (1, 2),
    (2, 3),
    (4, 5),
    (0, 4),
    (1, 4),
    (1, 5),
    (2, 5),
    (3, 5),
  ],
);

Widget trussRoutePicture() => const ConceptPair(
  left: TrussPainter(
    truss: _routeTruss,
    mode: TrussMode.cuts,
    cuts: [Cut('cut', Offset(6, -1.2), Offset(6, 4.2))],
    selected: 0,
    truth: 0,
    locked: true,
  ),
  right: TrussPainter(
    truss: _routeTruss,
    mode: TrussMode.oneMember,
    spotlight: 4,
  ),
  leftCaption: 'one bar deep inside: cut straight to it',
  rightCaption: 'everything meeting at one joint: work that joint',
  height: 200,
);

// ---------------------------------------------------------------------------
// 97 Deflection by virtual work

Widget unitLoadPicture() => const ConceptPicture(
  painter: ProbePainter(
    probe: Probe(
      stand: Stand.cantilever,
      measured: Measured.drop,
      at: 1,
      loadAt: 1,
      realLoad: 'the real load',
    ),
    answered: true,
  ),
  caption:
      'the question is how far the tip drops, so a single downward 1 goes at the tip',
  height: 210,
);

Widget termSignPicture() => const ConceptPair(
  left: ContributionPainter(
    term: Contribution(member: 1, real: 50, virt: 0.5),
    answered: true,
  ),
  right: ContributionPainter(
    term: Contribution(member: 1, real: -50, virt: 0.5),
    answered: true,
  ),
  leftCaption: 'both pulling: the term adds',
  rightCaption: 'one pulling, one pushing: the term takes away',
  height: 200,
);

// ---------------------------------------------------------------------------
// 98 Indeterminate structures

Widget redundantPicture() => const ConceptPair(
  left: ReleasePainter(span: Span(ends: Ends.fixedRoller)),
  right: ReleasePainter(
    span: Span(ends: Ends.fixedRoller),
    release: Release.theProp,
    answered: true,
  ),
  leftCaption:
      'built in at one end and propped at the other: one unknown too many',
  rightCaption: 'let the prop go and a plain cantilever is left',
  height: 200,
);

Widget fixityPicture() => const ConceptPair(
  left: SplitPainter(
    ends: Ends.pinRoller,
    marked: Marked.midMoment,
    topNote: 'simply supported',
    answered: true,
  ),
  right: SplitPainter(
    ends: Ends.fixedFixed,
    marked: Marked.midMoment,
    topNote: 'both ends built in',
    answered: true,
  ),
  leftCaption: 'ends hold nothing, so the middle carries it all',
  rightCaption:
      'stiff ends take a share, and the middle drops to a third of it',
  height: 200,
);

// ---------------------------------------------------------------------------
// 99 Design loads

Widget lrfdPicture() => const ConceptPicture(
  painter: _TwoRoutesPainter(),
  caption:
      'two ways to buy the same margin. take one route the whole way, never half of each',
  height: 210,
);

Widget controlsPicture() => const ConceptPair(
  left: LoadBarPainter(
    bundle: Bundle(dead: 20, live: 40),
    unit: 'kips',
    answered: true,
  ),
  right: LoadBarPainter(
    bundle: Bundle(dead: 20, live: 5, snow: 40),
    unit: 'kips',
    answered: true,
  ),
  leftCaption: 'the floor load is the big one, so the 1.6 belongs on it',
  rightCaption: 'snow is the big one here, so the 1.6 moves onto the snow',
  height: 220,
);

Widget reductionPicture() => const ConceptPicture(
  painter: TributaryPainter(
    left: Tributary(area: 600, column: true),
    right: Tributary(area: 600, column: false),
    answered: true,
  ),
  caption: 'the same 600 square feet. the column is allowed the bigger cut',
  height: 210,
);

// ---------------------------------------------------------------------------
// 100 Influence lines

Widget influencePicture() => const ConceptPicture(
  painter: InfluencePainter(
    line: Influence(span: 24, response: Response.momentAt, at: 8),
    loads: [(8, '1')],
    showOrdinates: true,
  ),
  caption:
      'across is where the wheel is standing. the height is what the marked spot feels',
  height: 210,
);

Widget shapesPicture() => Column(
  children: [
    const ConceptPicture(
      painter: InfluencePainter(
        line: Influence(span: 24, response: Response.leftReaction),
        showOrdinates: true,
      ),
      caption:
          'a reaction: straight from 1 over its own support down to nothing',
      height: 130,
    ),
    const SizedBox(height: 10),
    const ConceptPicture(
      painter: InfluencePainter(
        line: Influence(span: 24, response: Response.momentAt, at: 8),
        showOrdinates: true,
      ),
      caption: 'a moment at a spot: a triangle peaking over that spot',
      height: 130,
    ),
    const SizedBox(height: 10),
    const ConceptPicture(
      painter: InfluencePainter(
        line: Influence(span: 24, response: Response.shearAt, at: 8),
        showOrdinates: true,
      ),
      caption:
          'a shear at a spot: two slopes with a step of exactly 1 between them',
      height: 130,
    ),
  ],
);

Widget placePicture() => const ConceptPair(
  left: InfluencePainter(
    line: Influence(span: 24, response: Response.momentAt, at: 8),
    loads: [(8, 'P')],
    showOrdinates: true,
  ),
  right: InfluencePainter(
    line: Influence(span: 24, response: Response.momentAt, at: 8),
    loads: [(18, 'P')],
    showOrdinates: true,
  ),
  leftCaption: 'parked on the peak: the whole height counts',
  rightCaption: 'parked off it: the same load, far less effect',
  height: 200,
);

// ---------------------------------------------------------------------------
// 101 Reinforced concrete beams

const _rcBeam = RcSection(width: 12, height: 21);

Widget whichDepthPicture() => const ConceptPair(
  left: SectionMarkPainter(section: _rcBeam, marked: Depth.height),
  right: SectionMarkPainter(
    section: _rcBeam,
    marked: Depth.effective,
    answered: true,
  ),
  leftCaption: 'h: the whole height, which no formula wants',
  rightCaption: 'd: down to the middle of the bars, which every formula wants',
  height: 210,
);

Widget stirrupPicture() => const ConceptPicture(
  painter: ShearLadderPainter(
    check: ShearCheck(concrete: 26.3, demand: 22),
    answered: true,
  ),
  caption:
      'one ladder with four rungs. the demand lands in a band and the band answers',
  height: 220,
);

Widget phiPicture() => const ConceptPicture(
  painter: _NominalDesignPainter(),
  caption:
      'what the beam can really do, and the smaller amount you may count on',
  height: 200,
);

// ---------------------------------------------------------------------------
// 102 Reinforced concrete columns

Widget columnFactorPicture() => const ConceptPair(
  left: CagePainter(
    cage: Cage(width: 16, depth: 16, bars: 8, barArea: 1.0),
    answered: true,
  ),
  right: CagePainter(
    cage: Cage(width: 16, depth: 16, bars: 8, barArea: 1.0, spiral: true),
    answered: true,
  ),
  leftCaption: 'square ties: 0.80 for being off center, then 0.65 on top',
  rightCaption: 'a spiral holds the core together, so both numbers improve',
  height: 210,
);

Widget steelWindowPicture() => const ConceptPair(
  left: CagePainter(cage: Cage(width: 16, depth: 16, bars: 4, barArea: 0.44)),
  right: CagePainter(cage: Cage(width: 16, depth: 16, bars: 12, barArea: 1.56)),
  leftCaption:
      'too little steel: it behaves like plain concrete and gives no warning',
  rightCaption:
      'too much: no room to lap the bars or get concrete between them',
  height: 210,
);

// ---------------------------------------------------------------------------
// 103 Steel beams

Widget bracingPicture() => const ConceptPair(
  left: steel.BracePainter(
    beam: steel.Braced(
      span: 30,
      braceEvery: 0,
      lp: 8,
      lr: 25,
      continuous: true,
    ),
    answered: true,
  ),
  right: steel.BracePainter(
    beam: steel.Braced(span: 30, braceEvery: 30, lp: 8, lr: 25),
    answered: true,
  ),
  leftCaption: 'held all along: the beam reaches everything it has',
  rightCaption: 'held only at the ends: the flange goes over long before that',
  height: 210,
);

Widget modulusPicture() => const ConceptPicture(
  painter: _ModuliPainter(),
  caption:
      'first yield uses S. yielded right through uses Z, and Z is the bigger one',
  height: 200,
);

Widget flangePicture() => const ConceptPair(
  left: steel.ShapePainter(part: steel.Part2.topFlange, answered: true),
  right: steel.ShapePainter(
    part: steel.Part2.bottomFlange,
    sagging: false,
    answered: true,
  ),
  leftCaption: 'sagging: the top is squashed, and a slab holds it for free',
  rightCaption:
      'hogging over a support: the bottom is squashed, and nothing holds it',
  height: 210,
);

// ---------------------------------------------------------------------------
// 104 Steel columns

Widget axisPicture() => const ConceptPair(
  left: steel.AxisPainter(
    post: steel.Post(height: 24, rx: 6.0, ry: 2.5),
    answered: true,
  ),
  right: steel.AxisPainter(
    post: steel.Post(height: 24, rx: 6.0, ry: 2.5, weakBraces: 2),
    answered: true,
  ),
  leftCaption: 'free both ways: it folds the shallow way, as it always does',
  rightCaption:
      'braced halfway the shallow way: now the deep way may take over',
  height: 220,
);

Widget columnTablePicture() => const ConceptPicture(
  painter: _TableRowPainter(),
  caption:
      'the table hands you a design stress already. multiply by the area and stop',
  height: 200,
);

// ---------------------------------------------------------------------------
// 105 Tension members

const _tie = Tie(
  width: 8,
  thickness: 0.5,
  holes: 2,
  boltDiameter: 0.75,
  fy: 50,
  fu: 65,
);

Widget twoLimitsPicture() => const ConceptPicture(
  painter: TiePainter(tie: _tie, answered: true),
  caption:
      'the whole bar can stretch, or it can tear across the holes. both are checked',
  height: 210,
);

Widget netAreaPicture() => const ConceptPicture(
  painter: _HoleWidthPainter(),
  caption:
      'the hole costs more width than the bolt fills, and it comes off the width',
  height: 190,
);

Widget shearLagPicture() => const ConceptPair(
  left: GripPainter(grip: Grip.allOfIt, answered: true),
  right: GripPainter(grip: Grip.oneLeg, answered: true),
  leftCaption: 'bolted right across: every bit of steel pulls its share',
  rightCaption: 'bolted through one leg: the far side has not joined in yet',
  height: 210,
);

// ---------------------------------------------------------------------------
// The painters that exist only for a sheet

TextPainter _text(
  String s, {
  double size = 11,
  Color color = AppColors.ink2,
  bool bold = false,
}) {
  return TextPainter(
    text: TextSpan(
      text: s,
      style: AppTheme.mono(
        size: size,
        color: color,
        weight: bold ? FontWeight.w700 : FontWeight.w500,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
}

Paint _fill(Color c) => Paint()..color = c;

Paint _stroke(Color color, [double width = 2]) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

void _bar(Canvas canvas, Rect r, Color c, {double radius = 5}) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(r, Radius.circular(radius)),
    _fill(c),
  );
}

/// Two routes to the same margin: loads pushed up against a strength cut
/// down, and loads left alone against a strength divided.
class _TwoRoutesPainter extends CustomPainter {
  const _TwoRoutesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final half = size.width / 2;
    void route(
      double x0,
      String name,
      String loadLabel,
      double loadShare,
      String strengthLabel,
      double strengthShare,
    ) {
      final left = x0 + 18;
      final wide = half - 44;
      final head = _text(name, size: 12, color: AppColors.charcoal, bold: true);
      head.paint(canvas, Offset(left, 14));

      // the load bar
      final loadTop = 44.0;
      _bar(
        canvas,
        Rect.fromLTWH(left, loadTop, wide * loadShare, 22),
        AppColors.ember,
      );
      final l = _text(loadLabel, size: 10.5, color: AppColors.charcoal);
      l.paint(canvas, Offset(left, loadTop + 27));

      // the strength bar
      final strengthTop = size.height - 74;
      _bar(
        canvas,
        Rect.fromLTWH(left, strengthTop, wide, 22),
        AppColors.creamDark,
      );
      _bar(
        canvas,
        Rect.fromLTWH(left, strengthTop, wide * strengthShare, 22),
        AppColors.charcoal,
      );
      final s = _text(strengthLabel, size: 10.5, color: AppColors.charcoal);
      s.paint(canvas, Offset(left, strengthTop + 27));

      // the gap between them is the margin
      canvas.drawLine(
        Offset(left + wide * loadShare + 6, loadTop + 11),
        Offset(left + wide * strengthShare - 6, strengthTop + 11),
        _stroke(AppColors.ink3, 1.5),
      );
    }

    route(0, 'LRFD', 'loads pushed UP', 0.62, 'strength cut down', 0.86);
    route(half, 'ASD', 'loads as they come', 0.44, 'strength divided', 0.60);

    canvas.drawLine(
      Offset(half, 10),
      Offset(half, size.height - 10),
      _stroke(AppColors.ink3.withValues(alpha: 0.4), 1),
    );
  }

  @override
  bool shouldRepaint(_TwoRoutesPainter old) => false;
}

/// What a section can really reach, and the smaller number design is allowed
/// to lean on, for bending and for shear.
class _NominalDesignPainter extends CustomPainter {
  const _NominalDesignPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.20;
    final wide = size.width * 0.64;
    void row(double y, String what, double phi) {
      _bar(canvas, Rect.fromLTWH(left, y, wide, 26), AppColors.creamDark);
      _bar(canvas, Rect.fromLTWH(left, y, wide * phi, 26), AppColors.charcoal);
      final name = _text(what, size: 11, color: AppColors.charcoal, bold: true);
      name.paint(canvas, Offset(left, y - 17));
      final got = _text(
        'you may count on ${(phi * 100).round()}%',
        size: 10,
        color: AppColors.cream,
      );
      got.paint(canvas, Offset(left + 8, y + 7));
      final rest = _text('phi = $phi', size: 10, color: AppColors.ink2);
      rest.paint(canvas, Offset(left + wide + 8, y + 7));
    }

    final cap = _text('what it can really do', size: 10, color: AppColors.ink2);
    cap.paint(canvas, Offset(left, 12));
    canvas.drawLine(
      Offset(left, 30),
      Offset(left + wide, 30),
      _stroke(AppColors.ink3, 1),
    );

    row(size.height * 0.36, 'bending, which sags first and warns you', 0.90);
    row(size.height * 0.70, 'shear, which arrives with no warning', 0.75);
  }

  @override
  bool shouldRepaint(_NominalDesignPainter old) => false;
}

/// The stress through the depth at first yield and yielded right through:
/// the triangle that S belongs to, and the blocks that Z belongs to.
class _ModuliPainter extends CustomPainter {
  const _ModuliPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final half = size.width / 2;
    void block(double x0, String name, bool plastic) {
      final cx = x0 + half / 2;
      final top = 44.0;
      final bottom = size.height - 34;
      final mid = (top + bottom) / 2;
      final reach = half * 0.26;

      // the section itself, a plain rectangle
      final web = Rect.fromLTWH(cx - half * 0.30, top, 16, bottom - top);
      _bar(canvas, web, AppColors.charcoal, radius: 2);

      // the stress running through the depth beside it
      final path = Path()..moveTo(cx, top);
      if (plastic) {
        path
          ..lineTo(cx + reach, top)
          ..lineTo(cx + reach, mid)
          ..lineTo(cx - reach, mid)
          ..lineTo(cx - reach, bottom)
          ..lineTo(cx, bottom);
      } else {
        path
          ..lineTo(cx + reach, top)
          ..lineTo(cx, mid)
          ..lineTo(cx - reach, bottom)
          ..lineTo(cx, bottom);
      }
      canvas.drawPath(path, _fill(AppColors.ember.withValues(alpha: 0.28)));
      canvas.drawPath(path, _stroke(AppColors.ember, 2.5));
      canvas.drawLine(
        Offset(cx - reach - 8, mid),
        Offset(cx + reach + 8, mid),
        _stroke(AppColors.ink3, 1),
      );

      final head = _text(name, size: 11, color: AppColors.charcoal, bold: true);
      head.paint(canvas, Offset(cx - head.width / 2, 16));
    }

    block(0, 'first yield: S', false);
    block(half, 'yielded through: Z', true);
    canvas.drawLine(
      Offset(half, 12),
      Offset(half, size.height - 12),
      _stroke(AppColors.ink3.withValues(alpha: 0.4), 1),
    );
  }

  @override
  bool shouldRepaint(_ModuliPainter old) => false;
}

/// One row of the column table: a slenderness in, a design stress out, and
/// the resistance factor already inside it.
class _TableRowPainter extends CustomPainter {
  const _TableRowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final boxW = size.width * 0.26;
    final y = size.height * 0.40;
    Rect box(double cx) =>
        Rect.fromCenter(center: Offset(cx, y), width: boxW, height: 52);

    void panel(double cx, String top, String bottom, Color fill, Color ink) {
      _bar(canvas, box(cx), fill, radius: 12);
      final a = _text(top, size: 12, color: ink, bold: true);
      a.paint(canvas, Offset(cx - a.width / 2, y - 16));
      final b = _text(bottom, size: 9.5, color: ink);
      b.paint(canvas, Offset(cx - b.width / 2, y + 2));
    }

    final lx = size.width * 0.18;
    final mx = size.width * 0.50;
    final rx = size.width * 0.82;
    panel(lx, 'KL/r', 'how slender', AppColors.creamDark, AppColors.charcoal);
    panel(mx, 'table', 'design stress', AppColors.charcoal, AppColors.cream);
    panel(rx, 'x Ag', 'the capacity', AppColors.creamDark, AppColors.charcoal);

    for (final (from, to) in [
      (lx + boxW / 2, mx - boxW / 2),
      (mx + boxW / 2, rx - boxW / 2),
    ]) {
      canvas.drawLine(
        Offset(from + 4, y),
        Offset(to - 8, y),
        _stroke(AppColors.ink2, 2),
      );
      final head = Path()
        ..moveTo(to - 4, y)
        ..lineTo(to - 12, y - 5)
        ..lineTo(to - 12, y + 5)
        ..close();
      canvas.drawPath(head, _fill(AppColors.ink2));
    }

    final note = _text(
      'phi is already inside the table stress: do not apply it twice',
      size: 10,
      color: AppColors.ember,
    );
    note.paint(
      canvas,
      Offset(size.width / 2 - note.width / 2, size.height - 30),
    );
  }

  @override
  bool shouldRepaint(_TableRowPainter old) => false;
}

/// A bolt sitting in its hole, with the extra width the hole costs marked
/// either side of it.
class _HoleWidthPainter extends CustomPainter {
  const _HoleWidthPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.42;
    final cy = size.height * 0.46;
    final holeR = size.height * 0.24;
    final boltR = holeR * 0.78;

    // the plate
    _bar(
      canvas,
      Rect.fromLTWH(
        size.width * 0.10,
        cy - holeR * 1.9,
        size.width * 0.64,
        holeR * 3.8,
      ),
      AppColors.creamDark,
      radius: 6,
    );

    canvas.drawCircle(Offset(cx, cy), holeR, _fill(AppColors.cream));
    canvas.drawCircle(Offset(cx, cy), holeR, _stroke(AppColors.ember, 2.5));
    canvas.drawCircle(Offset(cx, cy), boltR, _fill(AppColors.charcoal));

    final bolt = _text('the bolt', size: 10, color: AppColors.cream);
    bolt.paint(canvas, Offset(cx - bolt.width / 2, cy - 6));

    // what the hole costs, marked across the top
    final markY = cy - holeR - 16;
    canvas.drawLine(
      Offset(cx - holeR, markY),
      Offset(cx + holeR, markY),
      _stroke(AppColors.ember, 2),
    );
    for (final x in [cx - holeR, cx + holeR]) {
      canvas.drawLine(
        Offset(x, markY - 5),
        Offset(x, markY + 5),
        _stroke(AppColors.ember, 2),
      );
    }
    final cost = _text(
      'bolt + 1/8 inch',
      size: 10.5,
      color: AppColors.ember,
      bold: true,
    );
    cost.paint(canvas, Offset(cx - cost.width / 2, markY - 22));

    final rule = _text(
      'off the WIDTH, then times the thickness',
      size: 10,
      color: AppColors.ink2,
    );
    rule.paint(
      canvas,
      Offset(size.width / 2 - rule.width / 2, size.height - 24),
    );
  }

  @override
  bool shouldRepaint(_HoleWidthPainter old) => false;
}

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const structuralPictures = <String, Widget Function()>{
  'count': countPicture,
  'stability': stabilityPicture,
  'pivot': pivotPicture,
  'joint': jointForcePicture,
  'route': trussRoutePicture,
  'unit': unitLoadPicture,
  'terms': termSignPicture,
  'release': redundantPicture,
  'fixity': fixityPicture,
  'method': lrfdPicture,
  'controls': controlsPicture,
  'reduction': reductionPicture,
  'reading': influencePicture,
  'shapes': shapesPicture,
  'placing': placePicture,
  'depth': whichDepthPicture,
  'stirrups': stirrupPicture,
  'phi': phiPicture,
  'factors': columnFactorPicture,
  'window': steelWindowPicture,
  'bracing': bracingPicture,
  'moduli': modulusPicture,
  'flanges': flangePicture,
  'axis': axisPicture,
  'table': columnTablePicture,
  'limits': twoLimitsPicture,
  'net': netAreaPicture,
  'lag': shearLagPicture,
};
