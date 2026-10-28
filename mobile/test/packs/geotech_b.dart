import 'package:mobile/features/games/after_the_rain_game.dart'
    show rainRounds;
import 'package:mobile/features/games/bearing_figures.dart'
    show FootingPainter;
import 'package:mobile/features/games/compaction_figures.dart'
    show PackingPainter, ProctorPainter, StabilizerPainter;
import 'package:mobile/features/games/double_the_wall_game.dart'
    show wallHeightRounds;
import 'package:mobile/features/games/earth_pressure_figures.dart'
    show CoefficientPainter, WallPainter, WallState;
import 'package:mobile/features/games/from_the_toe_or_the_center_game.dart'
    show landingRounds;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/lime_or_cement_game.dart'
    show soilFixRounds;
import 'package:mobile/features/games/moments_or_forces_game.dart'
    show checkRounds;
import 'package:mobile/features/games/pile_figures.dart'
    show DepthPainter, PilePainter;
import 'package:mobile/features/games/slope_figures.dart'
    show BankPainter, WedgePainter;
import 'package:mobile/features/games/steeper_than_its_friction_game.dart'
    show BankRound, Stands;
import 'package:mobile/features/games/tip_or_shaft_game.dart' show pileRounds;
import 'package:mobile/features/games/triangle_or_rectangle_game.dart'
    show shapeRounds2;
import 'package:mobile/features/games/wall_stability_figures.dart'
    show BasePainter, StabilityPainter;
import 'package:mobile/features/games/wetter_is_not_denser_game.dart'
    show proctorRounds;
import 'package:mobile/features/games/what_gets_divided_game.dart'
    show safetyRounds;
import 'package:mobile/features/games/what_holds_the_wedge_game.dart'
    show wedgeRounds;
import 'package:mobile/features/games/what_tips_the_pressure_game.dart'
    show tipRounds;
import 'package:mobile/features/games/which_measure_is_it_game.dart'
    show packingRounds;
import 'package:mobile/features/games/which_term_drops_out_game.dart'
    show Piece4, TermRound3, termGoneRounds;
import 'package:mobile/features/games/which_way_did_the_wall_move_game.dart'
    show WallMoveRound, wallMoveRounds;
import 'package:mobile/features/games/which_way_the_friction_acts_game.dart'
    show downdragRounds;
import 'package:mobile/features/games/why_go_deeper_game.dart' show deepRounds;
import 'package:mobile/features/games/wider_or_deeper_game.dart'
    show FixRound, Remedy, fixRounds;

import 'builder.dart';
import 'pick_one_adapter.dart';

/// The Geotechnical games, second half: seepage and slope stability,
/// bearing capacity, earth pressure, retaining wall stability, compaction
/// and soil improvement, and deep foundations. All seventeen have one
/// screen: the problem, a drawing in a white panel on the 18 pixel grid,
/// in some games a formula centred under it (always, or only once
/// answered), then the answers as the app's plain white rows (8 apart,
/// none after the last) and, 14 below, the feedback.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'after-the-rain': afterTheRain,
  'what-holds-the-wedge': whatHoldsTheWedge,
  'which-term-drops-out': whichTermDropsOut,
  'wider-or-deeper': widerOrDeeper,
  'what-gets-divided': whatGetsDivided,
  'which-way-did-the-wall-move': whichWayDidTheWallMove,
  'triangle-or-rectangle': triangleOrRectangle,
  'double-the-wall': doubleTheWall,
  'moments-or-forces': momentsOrForces,
  'from-the-toe-or-the-center': fromTheToeOrTheCenter,
  'what-tips-the-pressure': whatTipsThePressure,
  'wetter-is-not-denser': wetterIsNotDenser,
  'which-measure-is-it': whichMeasureIsIt,
  'lime-or-cement': limeOrCement,
  'tip-or-shaft': tipOrShaft,
  'why-go-deeper': whyGoDeeper,
  'which-way-the-friction-acts': whichWayTheFrictionActs,
};

/// One round of the chapter's screen.
typedef _Round = ({
  String subject,
  String asked,
  List<String> options,
  int answer,
  String why,
  String source,
  Draw Function(bool answered) paint,
});

/// A formula under the drawing: its TeX, its size, and whether it shows
/// only once the round is answered.
typedef _Formula = ({String tex, num size, bool afterOnly});

/// A game of this chapter: every round the problem, its drawing in a
/// panel [h] high, the [formula] under it if any, the answers and the
/// feedback.
Map<String, Object?> _game({
  required String id,
  required String title,
  required String closing,
  required String overline,
  required BriefSection brief,
  required String briefName,
  required double h,
  _Formula? formula,
  required List<_Round> rounds,
}) => pickScreen(
  id: id,
  chapter: 'geotechnical',
  title: title,
  closing: closing,
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(brief, briefName),
  rounds: [
    for (final (i, r) in rounds.indexed)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...heading(overline, r.subject, r.asked),
          gap(12),
          figure(r.paint, h, frame: 'panel', what: '$id round $i'),
          if (formula != null) ...[
            gap(10, when: formula.afterOnly ? 'done' : null),
            {
              'math': formula.tex,
              'size': formula.size,
              if (formula.afterOnly) 'when': 'done',
            },
          ],
          gap(12),
          {'choices': true, 'space': 8},
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> afterTheRain() => _game(
  id: 'after-the-rain',
  title: 'After the Rain',
  closing:
      'Seepage down a slope roughly halves its factor of safety, '
      'because buoyancy takes half the weight out of what presses the '
      'grains together while the whole weight goes on driving the '
      'slide. A dry factor of safety near one has no room for that. '
      'Flattening the slope and draining it are the two answers, and '
      'draining is worth a doubling on its own.',
  overline: 'AND NOW IT IS WET',
  brief: seepageSlopeBrief,
  briefName: 'seepageSlopeBrief',
  h: 204,
  formula: (
    tex:
        r"$FS = \frac{\gamma'}{\gamma_{sat}}\cdot"
        r"\frac{\tan\phi}{\tan\beta}$",
    size: 15,
    afterOnly: false,
  ),
  rounds: [
    for (final r in rainRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: [for (final o in Stands.values) BankRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => BankPainter(bank: r.bank, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whatHoldsTheWedge() => _game(
  id: 'what-holds-the-wedge',
  title: 'What Holds the Wedge',
  closing:
      'The weight does both jobs: its component along the plane drives '
      'the slide, its component across the plane presses the block down '
      'and buys friction, and the angle of the plane decides the split. '
      'The cohesion adds a term that depends on the LENGTH of the '
      'surface and not on the weight at all, which is what saves '
      'shallow slips. And the factor of safety is always resisting over '
      'driving.',
  overline: 'WHAT DOES WHAT',
  brief: wedgeBrief,
  briefName: 'wedgeBrief',
  h: 206,
  formula: (
    tex: r'$FS = \frac{cL_s + W\cos\alpha\tan\phi}{W\sin\alpha}$',
    size: 14,
    afterOnly: false,
  ),
  rounds: [
    for (final r in wedgeRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            WedgePainter(wedge: r.wedge, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whichTermDropsOut() => _game(
  id: 'which-term-drops-out',
  title: 'Which Term Drops Out',
  closing:
      'Three terms, and most problems kill one before the arithmetic '
      'starts. No cohesion and the first goes. On the surface and the '
      'second goes, which on a clean sand is most of the capacity. No '
      'friction angle and the third goes, because its factor is zero, '
      'which is why a wider footing on an undrained clay buys no '
      'pressure at all. When a soil has some of everything, all three '
      'are there and the cohesion one is usually the largest.',
  overline: 'WHICH OF THE THREE',
  brief: terzaghiBrief,
  briefName: 'terzaghiBrief',
  h: 216,
  formula: (
    tex:
        r"$q_{ult} = cN_c + \gamma' D_f N_q + \tfrac{1}{2}\gamma' B "
        r"N_\gamma$",
    size: 14,
    afterOnly: false,
  ),
  rounds: [
    for (final r in termGoneRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: [for (final o in Piece4.values) TermRound3.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            FootingPainter(footing: r.footing, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> widerOrDeeper() => _game(
  id: 'wider-or-deeper',
  title: 'Wider or Deeper',
  closing:
      'On a sand both help and burying helps more, because the depth '
      'factor is the larger and the width term is halved besides. On an '
      'undrained clay widening raises the pressure the soil can take by '
      'nothing at all, since that term has a factor of zero, though it '
      'still spreads the structural load. Burying works because the '
      'soil beside the footing has to be shifted before it can fail. '
      'And a rising water table halves both of the weight terms.',
  overline: 'WHAT WOULD HELP',
  brief: footingFixBrief,
  briefName: 'footingFixBrief',
  h: 216,
  formula: (
    tex: r"$N_\gamma = 0 \text{ when } \phi = 0$",
    size: 15,
    afterOnly: false,
  ),
  rounds: [
    for (final r in fixRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: [for (final o in Remedy.values) FixRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            FootingPainter(footing: r.footing, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whatGetsDivided() => _game(
  id: 'what-gets-divided',
  title: 'What Gets Divided',
  closing:
      'The equation gives a failure pressure. The factor of safety '
      'divides THAT, never the load, and the result is what the real '
      'foundation pressure is compared with, pressure against pressure. '
      'Three is the usual figure because the soil is barely sampled and '
      'fails without warning. Below the water table the weight terms '
      'use the buoyant unit weight. And passing this check says nothing '
      'about how far the building will settle.',
  overline: 'ULTIMATE OR ALLOWABLE',
  brief: allowableBrief,
  briefName: 'allowableBrief',
  h: 216,
  formula: (
    tex: r'$q_{allow} = \frac{q_{ult}}{FS}$',
    size: 16,
    afterOnly: false,
  ),
  rounds: [
    for (final r in safetyRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            FootingPainter(footing: r.footing, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whichWayDidTheWallMove() => _game(
  id: 'which-way-did-the-wall-move',
  title: 'Which Way Did the Wall Move',
  closing:
      'Active when the wall leans away, which nearly every retaining '
      'wall does, and it is the smallest pressure of the three. At rest '
      'when it cannot move at all, which is what a basement wall does. '
      'Passive when it is pushed INTO the soil, which is much the '
      'largest and takes real movement to develop. The order never '
      'changes, the active and passive coefficients multiply to one, '
      'and a looser fill leans harder.',
  overline: 'WHICH COEFFICIENT',
  brief: rankineBrief,
  briefName: 'rankineBrief',
  h: 158,
  formula: (
    tex: r'$K_a < K_0 < K_p, \quad K_a K_p = 1$',
    size: 15,
    afterOnly: true,
  ),
  rounds: [
    for (final r in wallMoveRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: [for (final o in WallState.values) WallMoveRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            CoefficientPainter(backfill: r.backfill, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> triangleOrRectangle() => _game(
  id: 'triangle-or-rectangle',
  title: 'Triangle or Rectangle',
  closing:
      'The soil presses harder the deeper you go, so its diagram is a '
      'triangle and its resultant sits a third of the way up. A '
      'surcharge presses the same everywhere, so its diagram is a '
      'rectangle and its resultant sits at mid height. The forces add, '
      'but the heights do not: for overturning, each has to be taken '
      'about its own arm. And a modest surcharge is worth more than it '
      'looks, because it acts over the whole wall.',
  overline: 'WHAT SHAPE IS IT',
  brief: diagramShapeBrief,
  briefName: 'diagramShapeBrief',
  h: 226,
  formula: (
    tex: r'$P_a = \tfrac{1}{2}K_a \gamma H^2 + K_a q H$',
    size: 15,
    afterOnly: true,
  ),
  rounds: [
    for (final r in shapeRounds2)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            WallPainter(backfill: r.backfill, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> doubleTheWall() => _game(
  id: 'double-the-wall',
  title: 'Double the Wall',
  closing:
      'The half is the area of a triangle and dropping it doubles the '
      'answer. The height is squared, so twice the wall is four times '
      'the force, and the overturning moment grows eight times because '
      'the arm doubles as well. The unit weight and the coefficient '
      'scale it straight. And the force is only the input: sliding, '
      'overturning and bearing are three separate checks after it.',
  overline: 'THE HALF AND THE SQUARE',
  brief: wallForceBrief,
  briefName: 'wallForceBrief',
  h: 222,
  formula: (
    tex: r'$P_a = \tfrac{1}{2} K_a \gamma H^2$',
    size: 16,
    afterOnly: true,
  ),
  rounds: [
    for (final r in wallHeightRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) => WallPainter(
          backfill: r.backfill,
          against: r.against,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> momentsOrForces() => _game(
  id: 'moments-or-forces',
  title: 'Moments or Forces',
  closing:
      'Three checks on one wall. Overturning compares moments about the '
      'toe, sliding compares forces along the base, and bearing '
      'compares pressures under it. What resists goes on top in all '
      'three, the minimums are different, and passing two of them says '
      'nothing at all about the third.',
  overline: 'WHICH CHECK IS IT',
  brief: threeChecksBrief,
  briefName: 'threeChecksBrief',
  h: 214,
  rounds: [
    for (final r in checkRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) => StabilityPainter(
          wall: r.wall,
          which: r.which,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> fromTheToeOrTheCenter() => _game(
  id: 'from-the-toe-or-the-center',
  title: 'From the Toe or the Center',
  closing:
      'Where the resultant crosses the base is measured from the toe. '
      'The eccentricity is measured from the MIDDLE, and it is the '
      'second of those the pressure formula wants. Keep it inside a '
      'sixth of the base either way and the whole base stays in '
      'contact with the soil.',
  overline: 'WHERE IT LANDS',
  brief: middleThirdBrief,
  briefName: 'middleThirdBrief',
  h: 196,
  rounds: [
    for (final r in landingRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        // The game draws the base the same before and after the answer.
        paint: (_) => BasePainter(
          wall: r.wall,
          showResultant: r.showResultant,
          withPressure: false,
          answered: false,
        ).paint,
      ),
  ],
);

Map<String, Object?> whatTipsThePressure() => _game(
  id: 'what-tips-the-pressure',
  title: 'What Tips the Pressure',
  closing:
      'Load dead center, and the pressure under the base is the load '
      'over the base, everywhere alike. Off center, and it tilts into a '
      'trapezoid with the most under the toe. The 6e/B term is that '
      'tilt, it vanishes when the load is centered, and it stops being '
      'true once the load leaves the middle third.',
  overline: 'UNDER THE BASE',
  brief: basePressureBrief,
  briefName: 'basePressureBrief',
  h: 226,
  rounds: [
    for (final r in tipRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            BasePainter(wall: r.wall, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> wetterIsNotDenser() => _game(
  id: 'wetter-is-not-denser',
  title: 'Wetter Is Not Denser',
  closing:
      'The Proctor curve is a hump. Dry of its peak, water helps the '
      'grains slide together. Wet of it, water holds them apart and no '
      'amount of rolling will fix that. The peak is the laboratory '
      'maximum for one soil at one compaction effort, and relative '
      'compaction is the field value over THAT, the right way up.',
  overline: 'THE PROCTOR CURVE',
  brief: proctorBrief,
  briefName: 'proctorBrief',
  h: 214,
  rounds: [
    for (final r in proctorRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) => ProctorPainter(
          test: r.test,
          showField: r.showField,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> whichMeasureIsIt() => _game(
  id: 'which-measure-is-it',
  title: 'Which Measure Is It',
  closing:
      'Relative compaction is a field density over a laboratory '
      'maximum, and it suits any soil that has a Proctor test. '
      'Relative density is for clean sands and gravels and asks how far '
      'between the loosest and tightest packings the soil sits, '
      'measured from the loose end. Different references, different '
      'formulas, and no terms in common.',
  overline: 'HOW WELL PACKED',
  brief: relativeDensityBrief,
  briefName: 'relativeDensityBrief',
  h: 200,
  rounds: [
    for (final r in packingRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) => PackingPainter(
          soil: r.soil,
          applies: r.applies,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> limeOrCement() => _game(
  id: 'lime-or-cement',
  title: 'Lime or Cement',
  closing:
      'Match the help to the soil. Lime for plastic clays, where it '
      'lowers the plasticity index and stops the swelling. Cement for '
      'granular and low-plasticity soils, where it binds the grains. A '
      'geosynthetic where the job is to separate, reinforce or drain. '
      'And drainage first, whenever water is what keeps coming back.',
  overline: 'WHAT THE SOIL NEEDS',
  brief: stabilizerBrief,
  briefName: 'stabilizerBrief',
  h: 196,
  rounds: [
    for (final r in soilFixRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            StabilizerPainter(ground: r.ground, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> tipOrShaft() => _game(
  id: 'tip-or-shaft',
  title: 'Tip or Shaft',
  closing:
      'Bearing under the tip plus friction along the shaft, each with '
      'its own area: a small tip area and a large shaft area. On rock '
      'the tip does the work. In deep uniform clay the shaft does. '
      'Reporting either half on its own is the wrong answer the lesson '
      'prints, twice.',
  overline: 'WHERE THE CAPACITY IS',
  brief: pileCapacityBrief,
  briefName: 'pileCapacityBrief',
  h: 226,
  rounds: [
    for (final r in pileRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) => PilePainter(
          pile: r.pile,
          showResistances: r.showResistances || answered,
          bearsOnRock: r.onRock,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> whyGoDeeper() => _game(
  id: 'why-go-deeper',
  title: 'Why Go Deeper',
  closing:
      'Piles are chosen to get the load past a layer that would settle, '
      'not because they are cheap, and never to press the weak layer '
      'harder. Once they come in a group the arithmetic changes again: '
      'in clay the group can carry less than the sum of its piles, and '
      'it stresses the ground deeper and settles more.',
  overline: 'WHY NOT A FOOTING',
  brief: goingDeepBrief,
  briefName: 'goingDeepBrief',
  h: 214,
  rounds: [
    for (final r in deepRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) => DepthPainter(
          piles: r.piles,
          onFooting: r.onFooting,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> whichWayTheFrictionActs() => _game(
  id: 'which-way-the-friction-acts',
  title: 'Which Way the Friction Acts',
  closing:
      'Shaft friction points whichever way the relative movement tells '
      'it to. Pile going down through still soil: it holds the pile up. '
      'Soil settling past a still pile: it drags the pile down, adds to '
      'the load, and gives no resistance over that stretch. New fill '
      'over compressible clay is the case that makes it happen.',
  overline: 'WHICH WAY IT RUBS',
  brief: downdragBrief,
  briefName: 'downdragBrief',
  h: 226,
  rounds: [
    for (final r in downdragRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) => PilePainter(
          pile: r.pile,
          downdrag: r.dragging,
          showDirection: answered,
          answered: answered,
        ).paint,
      ),
  ],
);
