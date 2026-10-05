// The pictures on the Structural Engineering concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles. The few painters that exist only
// here draw a comparison no game in the chapter needed to draw.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'figure_ink.dart';
import 'beam_figures.dart' show Prop;
import 'composite_figures.dart' show Spread3, StressBlockPainter;
import 'determinacy_figures.dart';
import 'influence_figures.dart';
import 'load_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture, ConceptPair;
import 'rc_figures.dart';
import 'redundant_figures.dart';
import 'steel_figures.dart' as steel;
import 'stress_figures.dart' show boxSection;
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

// Stacked rather than side by side: the painter writes its own count across
// the top of the panel, and at half width that line runs into the elevation
// label in the corner.
Widget countPicture() => const Column(
  children: [
    ConceptPicture(
      painter: SkeletonPainter(skeleton: _pinnedTruss, showCount: true),
      caption: 'hinged corners: a truss, two equations per joint',
      height: 170,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: SkeletonPainter(skeleton: _rigidFrame, showCount: true),
      caption: 'welded corners: a frame, three equations per joint',
      height: 170,
    ),
  ],
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

Widget stabilityPicture() => const Column(
  children: [
    ConceptPicture(
      painter: SkeletonPainter(skeleton: _parallelHeld, showWhy: true),
      caption: 'three rollers: the count says fine, a sideways push slides it',
      height: 175,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: SkeletonPainter(skeleton: _properlyHeld),
      caption: 'one of them a pin: now a sideways push has something to hold',
      height: 160,
    ),
  ],
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

// Stacked, not side by side: this painter writes four labels round one
// joint, and at half width they land on each other.
Widget jointForcePicture() => const Column(
  children: [
    ConceptPicture(
      painter: CornerPainter(
        corner: Corner(load: 500, degrees: 45),
        answered: true,
      ),
      caption: 'a steep diagonal carries the 500 with room to spare',
      height: 190,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: CornerPainter(
        corner: Corner(load: 500, degrees: 15),
        answered: true,
      ),
      caption: 'the same 500 on a flat one needs a far bigger pull',
      height: 190,
    ),
  ],
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
  // The four bars that meet at joint B, which is the free body the question
  // is describing when it names a connection.
  right: TrussPainter(
    truss: _routeTruss,
    mode: TrussMode.members,
    chosen: {0, 1, 5, 6},
    truths: {0, 1, 5, 6},
  ),
  leftCaption: 'one bar deep inside: cut straight to it',
  rightCaption: 'several bars at one joint: work that joint instead',
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

Widget termSignPicture() => const Column(
  children: [
    ConceptPicture(
      painter: _AgreePainter(),
      caption:
          'two pulls on the same bar. pulling the same way they help each '
          'other; opposite ways they fight',
      height: 200,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: ContributionPainter(
        term: Contribution(member: 1, real: 50, virt: 0.5),
        answered: true,
      ),
      caption: 'in the sum: both pulling, so this term adds',
      height: 190,
    ),
  ],
);

// ---------------------------------------------------------------------------
// 98 Indeterminate structures

// Stacked: at half width this painter's note wraps onto the beam and the
// name of the released force runs into the view tag.
Widget redundantPicture() => const Column(
  children: [
    ConceptPicture(
      painter: ReleasePainter(span: Span(ends: Ends.fixedRoller)),
      caption:
          'built in at one end and propped at the other: one unknown too many',
      height: 165,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: ReleasePainter(
        span: Span(ends: Ends.fixedRoller),
        release: Release.theProp,
        answered: true,
      ),
      caption: 'let the prop go and a plain cantilever is left',
      height: 185,
    ),
  ],
);

// Stacked: this painter writes a note over the beam as well as one above
// it, and at half width the two land on the supports.
Widget fixityPicture() => const Column(
  children: [
    ConceptPicture(
      painter: SplitPainter(
        ends: Ends.pinRoller,
        marked: Marked.midMoment,
        topNote: 'simply supported',
        answered: true,
      ),
      caption: 'ends hold nothing, so the middle carries it all',
      height: 175,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: SplitPainter(
        ends: Ends.fixedFixed,
        marked: Marked.midMoment,
        topNote: 'both ends built in',
        answered: true,
      ),
      caption: 'stiff ends take a share, and the middle drops to a third of it',
      height: 175,
    ),
  ],
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
    const SizedBox(height: 10),
    // The step is the one feature of the three that decides answers, and at
    // the scale above it is a few pixels. This is that step, close up.
    const ConceptPicture(
      painter: _StepZoomPainter(),
      caption:
          'the step, close up. walk the load past the spot and the shear '
          'flips, and the drop from one side to the other is exactly 1',
      height: 190,
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

// The stress through the depth, drawn by the painter the plastic-moment item
// already uses, so the wedge and the blocks read the same way here as they do
// in the round.
Widget modulusPicture() {
  final section = boxSection(100, 200);
  // Full width, stacked: at half width the painter's own yield label runs off
  // the edge of the panel.
  return Column(
    children: [
      ConceptPicture(
        painter: StressBlockPainter(
          profile: section,
          state: Spread3.firstYield,
        ),
        caption: 'a wedge, just touching the limit at the faces: that is S',
        height: 150,
      ),
      const SizedBox(height: 12),
      ConceptPicture(
        painter: StressBlockPainter(profile: section, state: Spread3.fully),
        caption: 'solid blocks, yielded right through: that is Z',
        height: 150,
      ),
    ],
  );
}

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

// Stacked: each panel already holds two columns of its own, and at half
// width the name of one ran into the name of the other.
Widget axisPicture() => const Column(
  children: [
    ConceptPicture(
      painter: steel.AxisPainter(
        post: steel.Post(height: 24, rx: 6.0, ry: 2.5),
        answered: true,
      ),
      caption: 'free both ways: it folds the shallow way, as it always does',
      height: 200,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: steel.AxisPainter(
        post: steel.Post(height: 24, rx: 6.0, ry: 2.5, weakBraces: 2),
        answered: true,
      ),
      caption: 'braced halfway the shallow way: now the deep way may take over',
      height: 200,
    ),
  ],
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

Widget shearLagPicture() => const Column(
  children: [
    ConceptPicture(
      painter: _TowelPainter(),
      caption:
          'pull a towel by one corner. near your hand it is taut; the far '
          'corner hangs slack, because the pull has not spread across yet',
      height: 200,
    ),
    SizedBox(height: 12),
    ConceptPair(
      left: GripPainter(grip: Grip.allOfIt, answered: true),
      right: GripPainter(grip: Grip.oneLeg, answered: true),
      leftCaption: 'bolted right across: every bit of steel pulls its share',
      rightCaption: 'bolted through one leg: the far side is the slack corner',
      height: 210,
    ),
  ],
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
      inkLabel(canvas, head, Offset(left, 14));

      // the load bar
      final loadTop = 44.0;
      _bar(
        canvas,
        Rect.fromLTWH(left, loadTop, wide * loadShare, 22),
        AppColors.ember,
      );
      final l = _text(loadLabel, size: 10.5, color: AppColors.charcoal);
      inkLabel(canvas, l, Offset(left, loadTop + 27));

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
      inkLabel(canvas, s, Offset(left, strengthTop + 27));

      // The gap between where the load ends and where the strength ends IS
      // the margin, and it is the subject of the sheet, so it is shaded and
      // named rather than left as a hairline nobody notices.
      final loadEnd = left + wide * loadShare;
      final strengthEnd = left + wide * strengthShare;
      final bandTop = loadTop + 46;
      final bandBottom = strengthTop - 6;
      canvas.drawRect(
        Rect.fromLTRB(loadEnd, bandTop, strengthEnd, bandBottom),
        _fill(AppColors.forest.withValues(alpha: 0.20)),
      );
      for (final x in [loadEnd, strengthEnd]) {
        canvas.drawLine(
          Offset(x, bandTop),
          Offset(x, bandBottom),
          _stroke(AppColors.forest, 1.8),
        );
      }
      // Named down the band itself: the gap is narrow, so a horizontal label
      // would either overflow it or land on a bar.
      final gap = _text(
        'margin',
        size: 8.5,
        color: AppColors.forest,
        bold: true,
      );
      canvas
        ..save()
        ..translate((loadEnd + strengthEnd) / 2, (bandTop + bandBottom) / 2)
        ..rotate(-math.pi / 2);
      inkLabel(canvas, gap, Offset(-gap.width / 2, -gap.height / 2));
      canvas.restore();
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
      inkLabel(canvas, name, Offset(left, y - 17));
      final got = _text(
        'count on ${(phi * 100).round()}%',
        size: 10,
        color: AppColors.cream,
      );
      inkLabel(canvas, got, Offset(left + 8, y + 7));
      // The leftover strip is what you may not lean on. Label it only when
      // the strip is wide enough to hold the words without spilling onto the
      // dark bar beside it.
      final lost = _text('not this', size: 9.5, color: AppColors.ember);
      final strip = wide * (1 - phi);
      if (strip > lost.width + 12) {
        inkLabel(
          canvas,
          lost,
          Offset(left + wide * phi + (strip - lost.width) / 2, y + 8),
        );
      }
    }

    final cap = _text('what it can really do', size: 10, color: AppColors.ink2);
    inkLabel(canvas, cap, Offset(left, 12));
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
      inkLabel(canvas, a, Offset(cx - a.width / 2, y - 16));
      final b = _text(bottom, size: 9.5, color: ink);
      inkLabel(canvas, b, Offset(cx - b.width / 2, y + 2));
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
      'the safety factor is already in there',
      size: 10.5,
      color: AppColors.ember,
    );
    inkLabel(
      canvas,
      note,
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
    inkLabel(canvas, bolt, Offset(cx - bolt.width / 2, cy - 6));

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
    inkLabel(canvas, cost, Offset(cx - cost.width / 2, markY - 22));

    final rule = _text(
      'off the WIDTH, then times the thickness',
      size: 10,
      color: AppColors.ink2,
    );
    inkLabel(
      canvas,
      rule,
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

/// Two pulls on one bar. Whether they agree is the whole of the sign rule,
/// and agreeing or fighting is something a reader can see without knowing
/// what virtual work is.
class _AgreePainter extends CustomPainter {
  const _AgreePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final each = size.width / 2;

    /// One bar with a pair of arrows on it: outward is a pull, inward a push.
    void bar(double left, double right, double y, bool pulling, Color tone) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left + 22, y - 6, right - 22, y + 6),
          const Radius.circular(3),
        ),
        _fill(AppColors.charcoal),
      );
      void arrow(double from, double to) {
        canvas.drawLine(Offset(from, y), Offset(to, y), _stroke(tone, 2.6));
        final way = to > from ? 1 : -1;
        final head = Path()
          ..moveTo(to, y)
          ..lineTo(to - way * 8, y - 4.5)
          ..lineTo(to - way * 8, y + 4.5)
          ..close();
        canvas.drawPath(head, _fill(tone));
      }

      if (pulling) {
        arrow(left + 22, left + 2);
        arrow(right - 22, right - 2);
      } else {
        arrow(left + 2, left + 22);
        arrow(right - 2, right - 22);
      }
    }

    void panel(double x0, bool agree) {
      final mid = x0 + each / 2;
      final left = x0 + 14;
      final right = x0 + each - 14;

      final head = _text(
        agree ? 'they agree' : 'they fight',
        size: 12.5,
        color: AppColors.charcoal,
        bold: true,
      );
      inkLabel(canvas, head, Offset(mid - head.width / 2, size.height * 0.05));

      // The SAME bar under each load in turn. Agreeing means the two arrows
      // point the same way, which is something a reader can simply see.
      for (final (i, label, pulling, tone) in [
        (0, 'real load: pulls', true, AppColors.ember),
        (
          1,
          agree ? 'pretend load: pulls too' : 'pretend load: pushes',
          agree,
          AppColors.info,
        ),
      ]) {
        final y = size.height * (0.34 + i * 0.26);
        bar(left, right, y, pulling, tone);
        final t = _text(label, size: 9, color: AppColors.ink3);
        inkLabel(canvas, t, Offset(mid - t.width / 2, y + 12));
      }

      final verdict = _text(
        agree ? 'the term ADDS' : 'the term TAKES AWAY',
        size: 11,
        color: agree ? AppColors.forest : AppColors.error,
        bold: true,
      );
      inkLabel(
        canvas,
        verdict,
        Offset(mid - verdict.width / 2, size.height * 0.84),
      );
    }

    panel(0, true);
    panel(each, false);
    canvas.drawLine(
      Offset(each, size.height * 0.04),
      Offset(each, size.height * 0.96),
      _stroke(AppColors.ink3.withValues(alpha: 0.4), 1),
    );
  }

  @override
  bool shouldRepaint(_AgreePainter old) => false;
}

/// The shear influence line's step, close up. On the full span it is a few
/// pixels tall, and it is the feature that decides answers.
class _StepZoomPainter extends CustomPainter {
  const _StepZoomPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.12;
    final right = size.width * 0.88;
    final spot = (left + right) / 2;
    final zero = size.height * 0.52;
    final unit = size.height * 0.26;

    // the baseline and the spot the shear is taken at
    canvas.drawLine(
      Offset(left, zero),
      Offset(right, zero),
      _stroke(AppColors.ink3, 1.2),
    );
    canvas.drawLine(
      Offset(spot, zero - unit - 14),
      Offset(spot, zero + unit + 14),
      _stroke(AppColors.ink3.withValues(alpha: 0.5), 1),
    );

    // the two slopes either side, and the step between them
    final belowAtSpot = zero + unit * 0.62;
    final aboveAtSpot = belowAtSpot - unit;
    canvas
      ..drawLine(
        Offset(left, zero),
        Offset(spot, belowAtSpot),
        _stroke(AppColors.info, 3),
      )
      ..drawLine(
        Offset(spot, aboveAtSpot),
        Offset(right, zero),
        _stroke(AppColors.info, 3),
      )
      ..drawCircle(Offset(spot, belowAtSpot), 3.5, _fill(AppColors.info))
      ..drawCircle(Offset(spot, aboveAtSpot), 3.5, _fill(AppColors.info));

    // the step itself, bracketed and named
    final x = spot + 26;
    canvas
      ..drawLine(
        Offset(x, aboveAtSpot),
        Offset(x, belowAtSpot),
        _stroke(AppColors.ember, 2.4),
      )
      ..drawLine(
        Offset(x - 6, aboveAtSpot),
        Offset(x + 6, aboveAtSpot),
        _stroke(AppColors.ember, 2.4),
      )
      ..drawLine(
        Offset(x - 6, belowAtSpot),
        Offset(x + 6, belowAtSpot),
        _stroke(AppColors.ember, 2.4),
      );
    final one = _text('1', size: 20, color: AppColors.ember, bold: true);
    inkLabel(canvas, one, Offset(x + 12, (aboveAtSpot + belowAtSpot) / 2 - 12));
    // Clear of the 20pt "1" above it: at +10 the two patches met and the
    // word lost its top.
    final exactly = _text('exactly', size: 9.5, color: AppColors.ember);
    inkLabel(
      canvas,
      exactly,
      Offset(x + 12, (aboveAtSpot + belowAtSpot) / 2 + 17),
    );

    for (final (at, label) in [
      (left + (spot - left) / 2, 'load left of the spot'),
      (spot + (right - spot) / 2, 'load right of it'),
    ]) {
      final t = _text(label, size: 9, color: AppColors.ink3);
      inkLabel(canvas, t, Offset(at - t.width / 2, size.height * 0.90));
    }
    final here = _text('the spot', size: 9.5, color: AppColors.charcoal);
    inkLabel(canvas, here, Offset(spot - here.width / 2, size.height * 0.06));
  }

  @override
  bool shouldRepaint(_StepZoomPainter old) => false;
}

/// A towel pulled by one corner: taut where the hand is, slack at the far
/// corner. That is shear lag, before any steel is mentioned.
class _TowelPainter extends CustomPainter {
  const _TowelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final left = size.width * 0.26;
    final right = size.width * 0.80;
    final top = size.height * 0.24;
    final bottom = size.height * 0.76;

    // the cloth
    final cloth = Rect.fromLTRB(left, top, right, bottom);
    canvas
      ..drawRect(cloth, _fill(AppColors.creamDark))
      ..drawRect(cloth, _stroke(AppColors.charcoal, 1.8));

    // how hard each thread is working, fading away from the held corner
    const threads = 7;
    for (var k = 0; k < threads; k++) {
      final t = k / (threads - 1);
      final y = top + (bottom - top) * (0.10 + 0.80 * t);
      final pull = 1.0 - t;
      canvas.drawLine(
        Offset(left + 6, y),
        Offset(right - 6, y),
        _stroke(
          AppColors.ember.withValues(alpha: 0.18 + 0.72 * pull),
          1.0 + 3.0 * pull,
        ),
      );
    }

    // the hand pulling one corner
    final grip = Offset(left, top + (bottom - top) * 0.10);
    canvas.drawCircle(grip, 7, _fill(AppColors.charcoal));
    canvas.drawLine(
      Offset(grip.dx - 8, grip.dy),
      Offset(size.width * 0.06, grip.dy),
      _stroke(AppColors.charcoal, 3),
    );
    final head = Path()
      ..moveTo(size.width * 0.04, grip.dy)
      ..lineTo(size.width * 0.04 + 10, grip.dy - 5)
      ..lineTo(size.width * 0.04 + 10, grip.dy + 5)
      ..close();
    canvas.drawPath(head, _fill(AppColors.charcoal));

    final taut = _text(
      'taut: doing the work',
      size: 9.5,
      color: AppColors.ember,
      bold: true,
    );
    inkLabel(canvas, taut, Offset(left + 10, top - 15));
    final slack = _text(
      'slack: barely joined in',
      size: 9.5,
      color: AppColors.ink3,
    );
    inkLabel(canvas, slack, Offset(left + 10, bottom + 6));
    final pull = _text('you pull here', size: 9.5, color: AppColors.charcoal);
    inkLabel(canvas, pull, Offset(size.width * 0.04, grip.dy - 20));
  }

  @override
  bool shouldRepaint(_TowelPainter old) => false;
}
