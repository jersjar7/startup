import 'dart:convert';

import 'package:flutter/material.dart' hide Path, TextPainter;

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/games/channel_figures.dart';
import 'package:mobile/features/games/does_any_of_it_run_off_game.dart';
import 'package:mobile/features/games/hazen_figures.dart';
import 'package:mobile/features/games/helps_or_hurts_game.dart';
import 'package:mobile/features/games/hydrograph_figures.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/flow_figures.dart';
import 'package:mobile/features/games/pump_figures.dart';
import 'package:mobile/features/games/runoff_figures.dart';
import 'package:mobile/features/games/smoother_or_rougher_game.dart';
import 'package:mobile/features/games/weir_figures.dart';
import 'package:mobile/features/games/what_does_the_storm_do_game.dart';
import 'package:mobile/features/games/what_happens_to_the_power_game.dart';
import 'package:mobile/features/games/what_moves_the_critical_depth_game.dart';
import 'package:mobile/features/games/what_survives_the_jump_game.dart';
import 'package:mobile/features/games/what_the_water_touches_game.dart';
import 'package:mobile/features/games/where_the_blend_lands_game.dart';
import 'package:mobile/features/games/which_formula_fits_this_weir_game.dart';
import 'package:mobile/features/games/which_number_goes_in_front_game.dart';
import 'package:mobile/features/games/which_one_runs_faster_game.dart';
import 'package:mobile/features/games/which_one_sheds_more_game.dart';
import 'package:mobile/features/games/which_way_does_the_ripple_go_game.dart';
import 'package:mobile/features/games/which_weir_notices_more_game.dart';
import 'package:mobile/features/games/why_is_this_peak_smaller_game.dart';
import 'package:mobile/features/packs/drawing/figure_hatch.dart';

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';

/// The Water Resources games, first half: open channels and Manning's,
/// specific energy and the jump, weirs and Hazen-Williams, pumps, the
/// rational method and curve numbers, and hydrographs. Every one is the
/// same screen: the problem, a drawing (or two) in the games' white panel,
/// usually a formula under it, and the answers as plain rows. What the
/// Water Touches is answered on the drawing instead, by tapping a piece of
/// the channel's boundary; Which Formula Fits This Weir's answers are the
/// formulas themselves.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'what-the-water-touches': _hatched(whatTheWaterTouches),
  'which-one-runs-faster': _hatched(whichOneRunsFaster),
  'which-number-goes-in-front': _hatched(whichNumberGoesInFront),
  'which-way-does-the-ripple-go': _hatched(whichWayDoesTheRippleGo),
  'what-moves-the-critical-depth': _hatched(whatMovesTheCriticalDepth),
  'what-survives-the-jump': _hatched(whatSurvivesTheJump),
  'which-formula-fits-this-weir': _hatched(whichFormulaFitsThisWeir),
  'which-weir-notices-more': _hatched(whichWeirNoticesMore),
  'smoother-or-rougher': _hatched(smootherOrRougher),
  'what-happens-to-the-power': _hatched(whatHappensToThePower),
  'helps-or-hurts': _hatched(helpsOrHurts),
  'which-one-sheds-more': _hatched(whichOneShedsMore),
  'where-the-blend-lands': _hatched(whereTheBlendLands),
  'does-any-of-it-run-off': _hatched(doesAnyOfItRunOff),
  'what-does-the-storm-do': _hatched(whatDoesTheStormDo),
  'why-is-this-peak-smaller': _hatched(whyIsThisPeakSmaller),
};

/// [game], with the figures' hatching recorded as one step a shape (see
/// figure_hatch.dart): a channel's lining and a weir's plate are hatched
/// from the bounds of a path, and line by line no width rule lands on the
/// single precision numbers those bounds are.
Map<String, Object?> Function() _hatched(
  Map<String, Object?> Function() game,
) => () {
  final was = recordHatches;
  recordHatches = true;
  try {
    return game();
  } finally {
    recordHatches = was;
  }
};

/// One round of the usual screen: what the problem says, the answers, and
/// what sits between the two. [right] names the round's own verdict when
/// the game words it by the round.
typedef WaterRound = ({
  String subject,
  String setting,
  List<String> options,
  int answer,
  String why,
  String source,
  List<Map<String, Object?>> middle,
  String? right,
  String? wrong,
});

/// The usual screen: the overline, the subject and the setting, 12 below
/// them what [WaterRound.middle] holds, then the answer rows 8 apart and,
/// once answered, the feedback 14 below the last. With [rows] false the
/// middle holds the answers itself.
Map<String, Object?> waterGame({
  required String id,
  required String title,
  required String closing,
  required String overline,
  required String right,
  required String wrong,
  required BriefSection brief,
  required String briefName,
  required List<WaterRound> rounds,
  bool rows = true,
}) {
  final sheet = briefJson(brief, briefName);
  final game = pickScreen(
    id: id,
    chapter: 'water-resources',
    title: title,
    closing: closing,
    right: right,
    wrong: wrong,
    brief: sheet,
    rounds: [
      for (final r in rounds)
        (
          options: r.options,
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: [
            ...heading(overline, r.subject, r.setting),
            gap(12),
            ...r.middle,
            if (rows) {'choices': true, 'space': 8},
            ...feedbackAfter(14),
          ],
        ),
    ],
  );
  final packed = (game['rounds']! as List).cast<Map<String, Object?>>();
  for (final (i, r) in rounds.indexed) {
    if (r.right != null) packed[i]['right'] = r.right;
    // A miss worded by the round: the same words whatever was picked.
    if (r.wrong != null) {
      packed[i]['wrong'] = [for (final _ in r.options) r.wrong];
    }
  }
  return game;
}

/// The games' white panel round a drawing on the grid, its border a pixel
/// wider (and the drawing a pixel smaller each way) once it is [won].
/// [grid] false for a strip with no grid behind it.
Node panelOf(
  Draw Function(bool answered) paint,
  double h, {
  bool won = false,
  bool grid = true,
  required String what,
}) {
  Object at(bool answered) => record(
    paint(answered),
    h - (answered && won ? 4 : 2),
    what: '$what ${answered ? 'answered' : 'asked'}',
  );
  final ask = at(false), done = at(true);
  // A drawing that does not change once answered is kept once.
  final d = jsonEncode(ask) == jsonEncode(done) ? ask : askDone(ask, done);
  final inside = draw(d);
  return box(
    h: h,
    fill: 'white',
    radius: 12,
    border: won ? askDone('line', 'forest') : 'line',
    stroke: won ? askDone(1, 2) : null,
    child: clip(grid ? _grid(inside) : inside, 11),
  );
}

Node _grid(Node child) => {
  'k': 'grid',
  'child': child,
  'minor': 18,
  'major': 90,
};

/// A formula centred under the drawing, [size] in charcoal, 10 under the
/// drawing and 12 over the answers.
List<Map<String, Object?>> formulaUnder(String tex, num size) => [
  gap(10),
  {'math': tex, 'size': size},
  gap(12),
];

/// A number as the hydrograph games write one: whole without a point.
String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

/// A channel section answered by tapping a piece of its boundary, drawn in
/// layers: the section once, each piece for whether it is picked and
/// whether the round is answered, then the dimensions and words over them.
/// The game measures a tap to every piece and takes the nearest within 22
/// pixels, so each piece is a line target with that reach. It hit-tests
/// the whole panel, border and all, so each piece is laid out on the outer
/// size and moved in by the border.
Node _pieces({
  required double h,
  required Channel channel,
  required List<Edge> parts,
  required SectionPainter Function(Edge? pick, bool answered) painter,
  required String what,
}) => {
  'k': 'tapdraw',
  'layers': [
    {
      'd': record(
        painter(null, false).paintSection,
        h,
        what: '$what section',
      ),
    },
    for (final (m, part) in parts.indexed)
      {
        'mark': m,
        'd': {
          for (final picked in [false, true])
            for (final answered in [false, true])
              '${picked ? 1 : 0}|${answered ? 1 : 0}': record(
                (canvas, size) => painter(
                  picked ? part : null,
                  answered,
                ).paintPiece(canvas, size, part),
                h,
                what:
                    '$what ${part.name}${picked ? ' picked' : ''}'
                    '${answered ? ' answered' : ''}',
              ),
        },
      },
    {
      'd': record(
        painter(null, false).paintNotes,
        h,
        what: '$what notes',
      ),
    },
  ],
  'targets': record(
    (canvas, size) {
      final outer = Size(size.width + 2, size.height + 2);
      for (final (_, a, b) in SectionPainter.segmentsOf(outer, channel)) {
        canvas.drawLine(
          a - const Offset(1, 1),
          b - const Offset(1, 1),
          Paint()..strokeWidth = 22,
        );
      }
    },
    h,
    what: '$what targets',
  ),
  'hits': [for (var k = 0; k < parts.length; k++) k],
  'h': h,
};

Map<String, Object?> whatTheWaterTouches() => waterGame(
  id: 'what-the-water-touches',
  title: 'What the Water Touches',
  closing:
      'The wetted perimeter is the boundary the water is rubbing '
      'against, and two rules settle it every time. The free surface '
      'never counts, because air does not hold water back. Nothing '
      'above the water line counts, however tall the wall is built. '
      'Everything else the water is in contact with does, measured '
      'along the surface rather than straight up.',
  overline: 'TAP THE PIECE THEY GOT WRONG',
  right: 'THAT ONE WAS MISSED',
  wrong: 'ANOTHER PIECE',
  brief: wettedBrief,
  briefName: 'wettedBrief',
  rows: false,
  rounds: [
    for (final (i, r) in touchRounds.indexed)
      () {
        const h = 250.0;
        // The pieces this channel has, in the order the game measures
        // them (a channel with no freeboard has no dry wall). The game
        // hit-tests the whole panel, border and all, so each piece is laid
        // out on the outer size and moved in by the border.
        final parts = [
          for (final s in SectionPainter.segmentsOf(
            const Size(400, h),
            r.channel,
          ))
            s.$1,
        ];
        return (
          subject: r.subject,
          setting:
              'The orange line is the boundary somebody added up for the '
              'wetted perimeter. It is wrong by exactly one piece: either '
              'they counted something the water is not touching, or they '
              'left out something it is.',
          options: [for (final p in parts) p.plain],
          answer: parts.indexOf(r.answer),
          why: r.why,
          source: r.source,
          right: r.isExtra ? 'THAT ONE IS NOT WET' : 'THAT ONE WAS MISSED',
          wrong: null,
          middle: <Map<String, Object?>>[
            box(
              h: h,
              fill: 'white',
              radius: 12,
              border: 'line',
              child: clip(
                _grid(
                  _pieces(
                    h: h - 2,
                    channel: r.channel,
                    parts: parts,
                    painter: (pick, answered) => SectionPainter(
                      channel: r.channel,
                      traced: r.traced,
                      picked: pick,
                      answer: answered ? r.answer : null,
                      locked: answered,
                    ),
                    what: 'what-the-water-touches round $i',
                  ),
                ),
                11,
              ),
            ),
            gap(10),
            {'math': r'$R_H = \dfrac{A}{P}$', 'size': 16},
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichOneRunsFaster() => waterGame(
  id: 'which-one-runs-faster',
  title: 'Which One Runs Faster',
  closing:
      'Three things set the speed and they do not pull equally. '
      'Roughness is underneath, so halving n doubles the velocity. '
      'Slope is under a square root, so four times the grade is only '
      'twice the speed. The hydraulic radius is to the two thirds '
      'power, and it rewards shapes that hold a lot of water against '
      'not much boundary. A pipe half full runs at exactly the speed it '
      'does when full.',
  overline: 'WHICH CARRIES THE QUICKER WATER',
  right: 'THAT IS THE QUICKER ONE',
  wrong: 'THE OTHER ONE',
  brief: manningBrief,
  briefName: 'manningBrief',
  rounds: [
    for (final (i, r) in swiftRounds.indexed)
      (
        subject: r.subject,
        setting:
            'One thing differs between these two: ${r.changed}. '
            '${r.sameSection ? 'The cut is identical, so the difference is '
                      'in the numbers written on each one.' : 'Both are drawn to '
                      'the same scale.'}',
        options: [for (final o in Swifter.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (_) => SectionPainter(
              channel: r.top,
              alongside: r.bottom,
              caption: 'A    ${r.caption(true)}',
              note: 'channel A',
            ).paint,
            168,
            won: r.answer != Swifter.bottom,
            what: 'which-one-runs-faster round $i A',
          ),
          gap(8),
          panelOf(
            (_) => SectionPainter(
              channel: r.bottom,
              alongside: r.top,
              caption: 'B    ${r.caption(false)}',
              note: r.sameSection
                  ? 'channel B, the same cut as A'
                  : 'channel B',
            ).paint,
            168,
            won: r.answer != Swifter.top,
            what: 'which-one-runs-faster round $i B',
          ),
          ...formulaUnder(r'$v = \dfrac{K}{n} R_H^{2/3} S^{1/2}$', 16),
        ],
      ),
  ],
);

Map<String, Object?> whichNumberGoesInFront() => waterGame(
  id: 'which-number-goes-in-front',
  title: 'Which Number Goes In Front',
  closing:
      'The constant is the only place the unit system appears in '
      'Manning\'s equation. Feet take 1.486, meters take 1.0, and the '
      'lengths on the drawing are what decide it: not the roughness, '
      'which is dimensionless, not the slope, which is dimensionless '
      'too, and not the units somebody wants the answer reported in. '
      'Inches and millimeters are not lengths the equation accepts, so '
      'they get fixed before anything goes in front of it.',
  overline: 'WHAT GOES IN FRONT OF MANNING\'S',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: unitFactorBrief,
  briefName: 'unitFactorBrief',
  rounds: [
    for (final (i, r) in kayRounds.indexed)
      (
        subject: r.subject,
        setting: r.setting,
        options: [for (final o in Kay.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (_) => SectionPainter(channel: r.channel).paint,
            210,
            what: 'which-number-goes-in-front round $i',
          ),
          ...formulaUnder(r'$Q = \dfrac{K}{n} A R_H^{2/3} S^{1/2}$', 16),
        ],
      ),
  ],
);

Map<String, Object?> whichWayDoesTheRippleGo() => waterGame(
  id: 'which-way-does-the-ripple-go',
  title: 'Which Way Does the Ripple Go',
  closing:
      'The Froude number is the water speed divided by the ripple '
      'speed, and the ripple speed is set by the depth alone. Below one '
      'the flow is subcritical and a disturbance can travel upstream, '
      'so what happens downstream is felt above it. Above one it is '
      'supercritical and nothing gets back up. At exactly one the '
      'upstream edge of a ring stands still, and that is critical '
      'depth.',
  overline: 'A STONE GOES IN. WHAT HAPPENS TO THE RING',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: froudeBrief,
  briefName: 'froudeBrief',
  rounds: [
    for (final (i, r) in ringRounds.indexed)
      (
        subject: r.subject,
        setting:
            'The two arrows are drawn to the same scale: how fast the water '
            'is moving, and how fast a ripple travels over water of this '
            'depth.',
        options: [for (final o in Ring.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: 'YES, THIS IS ${r.answer.regime.toUpperCase()} FLOW',
        wrong: 'IT IS ${r.answer.regime.toUpperCase()} FLOW',
        middle: [
          panelOf(
            (answered) =>
                RipplePainter(flume: r.flume, answered: answered).paint,
            230,
            what: 'which-way-does-the-ripple-go round $i',
          ),
          ...formulaUnder(r'$Fr = \dfrac{v}{\sqrt{g y}}$', 16),
        ],
      ),
  ],
);

Map<String, Object?> whatMovesTheCriticalDepth() => waterGame(
  id: 'what-moves-the-critical-depth',
  title: 'What Moves the Critical Depth',
  closing:
      'Two things move the critical depth of a rectangular channel: '
      'how much water is coming down it and how wide it is, and both '
      'of them only through the flow per unit width. The slope, the '
      'lining, the length and the depth the water happens to be '
      'running at do not appear in the formula and do not move it. They '
      'move where the flow SITS on the curve, which is a different '
      'question and usually the one worth asking next.',
  overline: 'WHERE DOES THE NOSE OF THE CURVE GO',
  right: 'THAT IS WHERE IT GOES',
  wrong: 'NOT THAT WAY',
  brief: criticalBrief,
  briefName: 'criticalBrief',
  rounds: [
    for (final (i, r) in shiftRounds.indexed)
      (
        subject: r.subject,
        setting: r.change,
        options: [for (final o in Shifted.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (answered) => EnergyCurvePainter(
              flume: r.before,
              after: answered && r.moved ? r.after : null,
              label: !answered
                  ? 'q ${r.before.unitFlow.toStringAsFixed(1)} m2/s'
                  : (r.moved
                        ? 'green: after the change'
                        : 'the curve did not move'),
            ).paint,
            250,
            what: 'what-moves-the-critical-depth round $i',
          ),
          ...formulaUnder(
            r'$y_c = \left(\dfrac{q^2}{g}\right)^{1/3}, \; q = \dfrac{Q}{B}$',
            15,
          ),
        ],
      ),
  ],
);

Map<String, Object?> whatSurvivesTheJump() => waterGame(
  id: 'what-survives-the-jump',
  title: 'What Survives the Jump',
  closing:
      'Across a hydraulic jump the discharge and the momentum function '
      'come through unchanged, the depth goes up, and the velocity, '
      'the energy and the Froude number all come down. Energy is lost '
      'on purpose, which is why a jump is built at the foot of a '
      'spillway, and why the conjugate depths have to be found from '
      'momentum rather than from energy.',
  overline: 'ACROSS THE JUMP, WHAT HAPPENS TO IT',
  right: 'THAT IS WHAT IT DOES',
  wrong: 'NOT QUITE',
  brief: hydraulicJumpBrief,
  briefName: 'hydraulicJumpBrief',
  rounds: [
    for (final (i, r) in wayRounds.indexed)
      (
        subject: r.subject,
        setting:
            'Water arrives fast and shallow on the left and leaves slow and '
            'deep on the right. What becomes of ${r.asked.plain}?',
        options: [for (final o in Crossing.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (answered) => JumpPainter(
              surge: r.surge,
              asked: r.asked,
              answered: answered,
            ).paint,
            220,
            what: 'what-survives-the-jump round $i',
          ),
          ...formulaUnder(
            r'$y_2 = \dfrac{y_1}{2}\left(-1 + \sqrt{1 + 8Fr_1^2}\right)$',
            15,
          ),
        ],
      ),
  ],
);

Map<String, Object?> whichFormulaFitsThisWeir() => waterGame(
  id: 'which-formula-fits-this-weir',
  title: 'Which Formula Fits This Weir',
  closing:
      'The shape of the opening picks the formula. A crest running '
      'wall to wall takes C L H to the three halves. A crest that stops '
      'short loses a tenth of the head off each end first. A V has no '
      'crest length at all and takes C H to the five halves, because '
      'the opening widens as the water rises. The coefficients differ '
      'too, and they differ again between feet and meters.',
  overline: 'WHICH FORMULA MEASURES THIS ONE',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT SHAPE',
  brief: weirBrief,
  briefName: 'weirBrief',
  rows: false,
  rounds: [
    for (final (i, r) in weirRounds.indexed)
      (
        subject: r.subject,
        setting:
            'You are looking at the weir plate from upstream, with the water '
            'standing behind it.',
        options: [for (final o in Rule3.values) o.latex],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (answered) => WeirPainter(weir: r.weir, showFlow: answered).paint,
            232,
            what: 'which-formula-fits-this-weir round $i',
          ),
          gap(12),
          // Each answer is a formula on its own row, its border following
          // the answer as the plain rows' does.
          for (final o in Rule3.values) ...[
            answer(
              o.index,
              box(
                w: 'max',
                pad: const [14, 14, 14, 14],
                radius: 10,
                border: tone('line', 'ember', 'forest', 'error'),
                stroke: tone(1, 2, 2, 2),
                child: math(o.latex, 16),
              ),
              radius: 10,
              fill: 'white',
            ),
            if (o != Rule3.values.last) gap(8),
          ],
        ],
      ),
  ],
);

Map<String, Object?> whichWeirNoticesMore() => waterGame(
  id: 'which-weir-notices-more',
  title: 'Which Weir Notices More',
  closing:
      'The exponent is a sensitivity. Doubling the head multiplies a '
      'rectangular weir by about 2.8 and a V-notch by about 5.7, and '
      'halving it cuts them by the same factors the other way. Only '
      'the ratio the head changed by matters, never where it started, '
      'and the crest length sits outside the power so it never changes '
      'the response at all.',
  overline: 'WHICH FLOW MOVES BY THE BIGGER FACTOR',
  right: 'THAT IS THE STEEPER ONE',
  wrong: 'THE OTHER ONE',
  brief: exponentBrief,
  briefName: 'exponentBrief',
  rounds: [
    for (final (i, r) in noticeRounds.indexed)
      (
        subject: r.subject,
        setting:
            '${r.change} The dashed green line is where the water ends up.',
        options: [for (final o in Notices.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (_) =>
                WeirPainter(weir: r.top, thenHead: r.thenTop, tag: 'A').paint,
            176,
            won: r.answer != Notices.bottom,
            what: 'which-weir-notices-more round $i A',
          ),
          gap(8),
          panelOf(
            (_) => WeirPainter(
              weir: r.bottom,
              thenHead: r.thenBottom,
              tag: 'B',
            ).paint,
            176,
            won: r.answer != Notices.top,
            what: 'which-weir-notices-more round $i B',
          ),
          ...formulaUnder(r'$Q \propto H^{3/2}$  or  $H^{5/2}$', 16),
        ],
      ),
  ],
);

Map<String, Object?> smootherOrRougher() => waterGame(
  id: 'smoother-or-rougher',
  title: 'Smoother or Rougher',
  closing:
      'A bigger Hazen-Williams C is a smoother pipe carrying more '
      'water, which is the opposite of Manning\'s n underneath. C '
      'enters in the first power, so two otherwise identical mains '
      'carry flows in the plain ratio of their coefficients: no 0.63, '
      'no 0.54, no square root. Those powers belong to the hydraulic '
      'radius and the gradient.',
  overline: 'WHICH MAIN CARRIES MORE',
  right: 'THAT IS THE SMOOTHER ONE',
  wrong: 'THE OTHER WAY',
  brief: hazenBrief,
  briefName: 'hazenBrief',
  rounds: [
    for (final (i, r) in carryRounds.indexed)
      (
        subject: r.subject,
        setting:
            'Same diameter, same length, same hydraulic gradient. The only '
            'difference between the two is what they are made of.',
        options: [for (final o in Carries.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (answered) => MainsPainter(
              top: r.top,
              bottom: r.bottom,
              answered: answered,
            ).paint,
            250,
            what: 'smoother-or-rougher round $i',
          ),
          ...formulaUnder(r'$Q = k_1 C A R_H^{0.63} S_v^{0.54}$', 15),
        ],
      ),
  ],
);

Map<String, Object?> whatHappensToThePower() => waterGame(
  id: 'what-happens-to-the-power',
  title: 'What Happens to the Power',
  closing:
      'Flow, head and unit weight all multiply, so doubling any of '
      'them doubles the power. Efficiency divides, so a worse '
      'efficiency means a bigger number, never a smaller one: the '
      'shaft always works harder than the water does, and the meter '
      'harder still. A motor rating is a ceiling and changes nothing '
      'about what gets drawn.',
  overline: 'BIGGER, SMALLER, OR THE SAME',
  right: 'THAT IS THE WAY IT MOVES',
  wrong: 'THE OTHER WAY',
  brief: pumpPowerBrief,
  briefName: 'pumpPowerBrief',
  rounds: [
    for (final (i, r) in dutyRounds.indexed)
      (
        subject: r.subject,
        setting: r.change,
        options: [for (final o in Draws.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (_) => const PumpSystemPainter(above: false).paint,
            196,
            what: 'what-happens-to-the-power round $i',
          ),
          gap(8),
          // The powers get their own strip, with no grid behind it.
          panelOf(
            (answered) => PowerBarPainter(
              duty: answered ? r.after : r.before,
              caption: answered ? 'AFTER THE CHANGE' : 'AS IT STANDS NOW',
            ).paint,
            74,
            grid: false,
            what: 'what-happens-to-the-power round $i powers',
          ),
          ...formulaUnder(r'$\dot W_{brake} = \dfrac{\gamma Q H}{\eta}$', 16),
        ],
      ),
  ],
);

Map<String, Object?> helpsOrHurts() => waterGame(
  id: 'helps-or-hurts',
  title: 'Helps or Hurts',
  closing:
      'NPSH available is the margin the water has left before it '
      'boils at the pump inlet. The atmosphere adds to it and so does '
      'water standing above the pump. A suction lift, friction in the '
      'suction line, and the vapor pressure of the water all take from '
      'it, and warm water takes a great deal. Anything on the '
      'discharge side belongs to a different question entirely.',
  overline: 'DOES IT HELP OR HURT THE MARGIN',
  right: 'THAT IS WHAT IT DOES',
  wrong: 'THE OTHER WAY',
  brief: npshBrief,
  briefName: 'npshBrief',
  rounds: [
    for (final (i, r) in marginRounds.indexed)
      (
        subject: r.subject,
        setting:
            'NPSH available is how much head the water has left above '
            'boiling when it reaches the pump. What does ${r.piece.plain} do '
            'to it?',
        options: [for (final o in Helps.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (_) => PumpSystemPainter(above: r.above, highlight: r.piece).paint,
            236,
            what: 'helps-or-hurts round $i',
          ),
          ...formulaUnder(r'$NPSH_A = H_{pa} + H_s - \sum h_L - H_{vp}$', 14),
        ],
      ),
  ],
);

Map<String, Object?> whichOneShedsMore() => waterGame(
  id: 'which-one-sheds-more',
  title: 'Which One Sheds More',
  closing:
      'With the same storm on both, the Rational Method comes down to '
      'the coefficient times the area. Neither is the stronger lever on '
      'its own: a small hard site can beat a large soft one and a large '
      'soft one can beat a small hard one, and two quite different '
      'catchments can come to exactly the same peak.',
  overline: 'WHICH SENDS MORE TO THE INLET',
  right: 'THAT IS THE BIGGER PEAK',
  wrong: 'THE OTHER ONE',
  brief: rationalBrief,
  briefName: 'rationalBrief',
  rounds: [
    for (final (i, r) in shedRounds.indexed)
      (
        subject: r.subject,
        setting:
            'The same storm falls on both, ${r.rain} inches an hour. Both '
            'plans are to one scale and shaded by how much of the rain each '
            'cover sheds, so the dark ink IS the peak.',
        options: [for (final o in Sheds.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          for (final (k, c) in [r.top, r.bottom].indexed) ...[
            if (k == 1) gap(8),
            panelOf(
              (answered) => CatchmentPainter(
                catchment: c,
                intensity: r.rain,
                scaleTo: r.biggest,
                showWeighted: answered && c.patches.length > 1,
                tag: 'CATCHMENT ${k == 0 ? 'A' : 'B'}',
              ).paint,
              150,
              won: r.answer != (k == 0 ? Sheds.bottom : Sheds.top),
              what: 'which-one-sheds-more round $i ${k == 0 ? 'A' : 'B'}',
            ),
          ],
          ...formulaUnder(r'$Q = C I A$', 16),
        ],
      ),
  ],
);

Map<String, Object?> whereTheBlendLands() => waterGame(
  id: 'where-the-blend-lands',
  title: 'Where the Blend Lands',
  closing:
      'A catchment with two covers takes one coefficient weighted by '
      'AREA, and it always leans toward whichever cover has more ground '
      'under it. It lands halfway only when the areas are equal, which '
      'is the single case where the plain average happens to be right. '
      'Knowing which way it leans is usually enough to throw out half '
      'the choices on offer.',
  overline: 'WHERE DOES THE ONE COEFFICIENT SIT',
  right: 'THAT IS WHERE IT LANDS',
  wrong: 'IT LEANS THE OTHER WAY',
  brief: catchmentBrief,
  briefName: 'catchmentBrief',
  rounds: [
    for (final (i, r) in blendRounds.indexed)
      (
        subject: r.subject,
        setting:
            'This catchment has two covers on it and drains to one inlet, so '
            'it needs one coefficient standing for the whole. Where does that '
            'number sit?',
        options: [for (final o in Leans.values) r.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (answered) => CatchmentPainter(
              catchment: r.catchment,
              showWeighted: answered,
            ).paint,
            176,
            what: 'where-the-blend-lands round $i',
          ),
          ...formulaUnder(r'$C = \dfrac{\sum C_i A_i}{\sum A_i}$', 16),
        ],
      ),
  ],
);

Map<String, Object?> doesAnyOfItRunOff() => waterGame(
  id: 'does-any-of-it-run-off',
  title: 'Does Any of It Run Off',
  closing:
      'The SCS method has a threshold the Rational Method does not. '
      'The ground takes the first fifth of its retention, and below '
      'that the runoff is a hard zero. Above it the fraction that runs '
      'off climbs with the storm and with the curve number: paving at '
      '98 passes nearly everything, woodland at 55 passes very little, '
      'and the answer comes out as a DEPTH in inches rather than a '
      'discharge.',
  overline: 'HOW MUCH OF THIS STORM REACHES THE DRAIN',
  right: 'THAT IS HOW MUCH',
  wrong: 'NOT THAT MUCH',
  brief: curveNumberBrief,
  briefName: 'curveNumberBrief',
  rounds: [
    for (final (i, r) in soakRounds.indexed)
      (
        subject: r.subject,
        setting:
            '${r.setting} The dashed line is what the ground takes before '
            'anything runs off at all.',
        options: [for (final o in Runoff3.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (answered) => SoakPainter(soak: r.soak, answered: answered).paint,
            250,
            what: 'does-any-of-it-run-off round $i',
          ),
          ...formulaUnder(r'$Q = \dfrac{(P - 0.2S)^2}{P + 0.8S}$', 15),
        ],
      ),
  ],
);

Map<String, Object?> whatDoesTheStormDo() => waterGame(
  id: 'what-does-the-storm-do',
  title: 'What Does the Storm Do to the Curve',
  closing:
      'A unit hydrograph answers for one inch of excess rain over a '
      'stated duration. For a deeper storm of the SAME duration, '
      'multiply every flow and leave the times alone: the watershed '
      'routes water at its own speed whatever the storm does. For a '
      'storm of a different duration, no amount of scaling will do. '
      'Depth sets the volume; duration sets the shape.',
  overline: 'HOW DO YOU GET THIS STORM OUT OF THAT CURVE',
  right: 'THAT IS THE WAY ACROSS',
  wrong: 'NOT THAT WAY',
  brief: unitHydrographBrief,
  briefName: 'unitHydrographBrief',
  rounds: [
    for (final (i, r) in stormRounds.indexed)
      (
        subject: r.subject,
        setting: r.setting,
        options: [for (final o in Scaling.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (answered) {
              final scaled = answered && r.answer == Scaling.flows;
              return HydrographPainter(
                waves: scaled ? [r.unit, r.result] : [r.unit],
                names: scaled
                    ? const ['the unit hydrograph', 'this storm']
                    : const ['the unit hydrograph'],
                tones: const [AppColors.ink3, AppColors.forest],
                topFlow: scaled ? null : r.unit.peak * 1.18,
                note:
                    '${_num(r.unitHours)} hour unit hydrograph, '
                    'peak ${_num(r.unit.peak)} cfs',
              ).paint;
            },
            226,
            what: 'what-does-the-storm-do round $i',
          ),
          gap(12),
        ],
      ),
  ],
);

Map<String, Object?> whyIsThisPeakSmaller() => waterGame(
  id: 'why-is-this-peak-smaller',
  title: 'Why Is This Peak Smaller',
  closing:
      'The Rational Method peaks when the storm lasts exactly as long '
      'as the time of concentration. Shorter, and the far ground never '
      'joins in: high intensity on part of the area. Longer, and the '
      'whole area is in but the intensity for that duration is lower. '
      'Both fall short of the design case, and knowing which reason '
      'applies tells you what to change.',
  overline: 'AGAINST THE DESIGN PEAK, WHY',
  right: 'THAT IS THE REASON',
  wrong: 'THE OTHER REASON',
  brief: concentrationBrief,
  briefName: 'concentrationBrief',
  rounds: [
    for (final (i, r) in basinRounds.indexed)
      (
        subject: r.subject,
        setting:
            '${r.setting} The bands are ground that drains to the outlet in '
            'the same time, and the filled ones are contributing when the '
            'rain stops.',
        options: [for (final o in Falls.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        right: null,
        wrong: null,
        middle: [
          panelOf(
            (_) => BasinPainter(basin: r.basin).paint,
            236,
            what: 'why-is-this-peak-smaller round $i',
          ),
          ...formulaUnder(r'$\text{design storm} : D = t_c$', 15),
        ],
      ),
  ],
);
