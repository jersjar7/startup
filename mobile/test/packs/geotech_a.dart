import 'package:mobile/features/games/above_or_below_the_line_game.dart'
    show ChartRound, Quarter, chartRounds;
import 'package:mobile/features/games/both_or_neither_game.dart'
    show GradeRound, Graded2, wellGradedRounds;
import 'package:mobile/features/games/consolidation_figures.dart'
    show Case, DrainagePainter, ElogPPainter, StressLinePainter;
import 'package:mobile/features/games/counting_the_net_game.dart'
    show netRounds;
import 'package:mobile/features/games/drained_or_not_game.dart'
    show DrainRound, Set2, drainRounds;
import 'package:mobile/features/games/effective_stress_figures.dart'
    show DepositPainter;
import 'package:mobile/features/games/how_long_does_it_take_game.dart'
    show timeRounds;
import 'package:mobile/features/games/over_what_game.dart'
    show RatioRound2, Under, overRounds;
import 'package:mobile/features/games/phase_figures.dart'
    show PhaseDiagramPainter, UnitWeightPainter;
import 'package:mobile/features/games/reading_the_circle_game.dart'
    show triaxialRounds;
import 'package:mobile/features/games/seepage_figures.dart'
    show BoilPainter, FlowNetPainter;
import 'package:mobile/features/games/shear_strength_figures.dart'
    show EnvelopePainter;
import 'package:mobile/features/games/slope_figures.dart' show BankPainter;
import 'package:mobile/features/games/soil_class_figures.dart'
    show PlasticityPainter, SizeCurvePainter;
import 'package:mobile/features/games/steeper_than_its_friction_game.dart'
    show BankRound, Stands, bankRounds;
import 'package:mobile/features/games/stiff_until_it_remembers_game.dart'
    show indexRounds;
import 'package:mobile/features/games/the_short_way_down_game.dart'
    show profileWalkRounds;
import 'package:mobile/features/games/two_terms_game.dart'
    show Term2, TermRound2, twoTermRounds;
import 'package:mobile/features/games/what_the_water_table_does_game.dart'
    show ChangeRound, Moves3, tableMoveRounds;
import 'package:mobile/features/games/when_does_it_simplify_game.dart'
    show masterRounds;
import 'package:mobile/features/games/when_the_sand_boils_game.dart'
    show boilRounds;
import 'package:mobile/features/games/which_case_is_it_game.dart'
    show CaseRound, caseRounds;
import 'package:mobile/features/games/which_fork_first_game.dart'
    show Fork, ForkRound, forkRounds;
import 'package:mobile/features/games/which_gamma_game.dart'
    show Gamma, GammaRound, gammaRounds;
import 'package:mobile/features/games/which_stress_is_that_game.dart'
    show Stress, StressRound, stressRounds;
import 'package:mobile/features/games/lesson_brief.dart';

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';

/// The Geotechnical games, first half: phase relations, classification,
/// effective stress, consolidation, shear strength, seepage and the
/// infinite slope. Every one is the same screen: the problem, a drawing in
/// a white panel, a formula centred under it, and the answers as plain
/// rows.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'over-what': overWhat,
  'when-does-it-simplify': whenDoesItSimplify,
  'which-gamma': whichGamma,
  'which-fork-first': whichForkFirst,
  'above-or-below-the-line': aboveOrBelowTheLine,
  'both-or-neither': bothOrNeither,
  'which-stress-is-that': whichStressIsThat,
  'what-the-water-table-does': whatTheWaterTableDoes,
  'the-short-way-down': theShortWayDown,
  'which-case-is-it': whichCaseIsIt,
  'stiff-until-it-remembers': stiffUntilItRemembers,
  'how-long-does-it-take': howLongDoesItTake,
  'two-terms': twoTerms,
  'drained-or-not': drainedOrNot,
  'reading-the-circle': readingTheCircle,
  'counting-the-net': countingTheNet,
  'when-the-sand-boils': whenTheSandBoils,
  'steeper-than-its-friction': steeperThanItsFriction,
};

/// One round of the usual screen: what the problem says, the answers, and
/// what sits between the two (the drawing and the formula under it).
typedef PlainRound = ({
  String subject,
  String setting,
  List<String> options,
  int answer,
  String why,
  String source,
  List<Map<String, Object?>> middle,
});

/// The usual screen: the overline, the subject and the setting, 12 below
/// them what [PlainRound.middle] holds, then the answer rows 8 apart and,
/// once answered, the feedback 14 below the last.
Map<String, Object?> plainGame({
  required String id,
  required String title,
  required String closing,
  required String overline,
  required String right,
  required String wrong,
  required BriefSection brief,
  required String briefName,
  required List<PlainRound> rounds,
}) => pickScreen(
  id: id,
  chapter: 'geotechnical',
  title: title,
  closing: closing,
  right: right,
  wrong: wrong,
  brief: briefJson(brief, briefName),
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
          {'choices': true, 'space': 8},
          ...feedbackAfter(14),
        ],
      ),
  ],
);

/// A drawing [h] high in the games' white panel, then 10 below it the
/// formula, centred and set at [size] in charcoal (or grey ink), and 12
/// more to the answers. With [onlyDone] the formula appears only once the
/// round is answered (Over What's formula is the answer), the two gaps
/// either way.
List<Map<String, Object?>> panelAndFormula(
  Draw Function(bool answered) draw,
  num h, {
  required String formula,
  required num size,
  bool grey = false,
  bool onlyDone = false,
  required String what,
}) => [
  figure(draw, h, frame: 'panel', what: what),
  gap(10),
  if (grey)
    center(math(formula, size, color: 'ink3'))
  else
    {'math': formula, 'size': size, if (onlyDone) 'when': 'done'},
  gap(12),
];

Map<String, Object?> overWhat() => plainGame(
  id: 'over-what',
  title: 'Over What',
  closing:
      'Every index property is one part of the sample over another, and '
      'the denominators differ on purpose. Void ratio is over the '
      'solids, so it can pass one. Porosity is the same voids over the '
      'whole sample, so it cannot. Saturation is water over the voids. '
      'And water content is the odd one out, a ratio of WEIGHTS over '
      'the solids, which is why the specific gravity has to carry you '
      'between the two sides of the diagram.',
  overline: 'WHAT IS ON THE BOTTOM',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: phaseBrief,
  briefName: 'phaseBrief',
  rounds: [
    for (final (i, r) in overRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Under.values) RatioRound2.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => PhaseDiagramPainter(
            soil: r.soil,
            over: r.over,
            under: r.under,
            answered: answered,
          ).paint,
          224,
          formula:
              r'$e = \frac{V_v}{V_s}, \quad n = \frac{V_v}{V}, \quad '
              r'\omega = \frac{W_w}{W_s}$',
          size: 14,
          onlyDone: true,
          what: 'over-what round $i',
        ),
      ),
  ],
);

Map<String, Object?> whenDoesItSimplify() => plainGame(
  id: 'when-does-it-simplify',
  title: 'When Does It Simplify',
  closing:
      'Saturation times void ratio equals water content times specific '
      'gravity, and that one line is the bridge between the weight side '
      'of the diagram and the volume side. At full saturation the S '
      'drops out and the void ratio is just w times Gs, but only then: '
      'assume it when the stem has not said so and the answer comes out '
      'too small. Keep the water content a decimal.',
  overline: 'WHAT THE RELATIONSHIP GIVES',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: masterBrief,
  briefName: 'masterBrief',
  rounds: [
    for (final (i, r) in masterRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => PhaseDiagramPainter(soil: r.soil).paint,
          214,
          formula: r'$S\,e = \omega\,G_s$',
          size: 17,
          what: 'when-does-it-simplify round $i',
        ),
      ),
  ],
);

Map<String, Object?> whichGamma() => plainGame(
  id: 'which-gamma',
  title: 'Which Gamma',
  closing:
      'One soil, four unit weights, in a fixed order. Dry is the solids '
      'alone over the volume they occupy in the ground. Saturated is '
      'the heaviest, with every void full. The sample as it stands sits '
      'between them, and moves with the weather. Submerged is smallest, '
      'the saturated weight less the weight of water, and it is the one '
      'the ground works with below the water table.',
  overline: 'WHICH UNIT WEIGHT',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: gammaBrief,
  briefName: 'gammaBrief',
  rounds: [
    for (final (i, r) in gammaRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Gamma.values) GammaRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              UnitWeightPainter(soil: r.soil, answered: answered).paint,
          148,
          formula:
              r"$\gamma_d = \frac{\gamma}{1+\omega}, \quad "
              r"\gamma' = \gamma_{sat} - \gamma_w$",
          size: 15,
          what: 'which-gamma round $i',
        ),
      ),
  ],
);

Map<String, Object?> whichForkFirst() => plainGame(
  id: 'which-fork-first',
  title: 'Which Fork First',
  closing:
      'The No. 200 sieve asks the first question every time: more than '
      'half retained and the soil is coarse, judged on the shape of its '
      'grain size curve. Otherwise it is fine, judged on the plasticity '
      'chart, and its coarse grains play no part at all. Coarse soils '
      'then split at the No. 4 into gravel and sand, which matters '
      'because the gravel gets the easier gradation test.',
  overline: 'WHERE DOES THIS ONE GO',
  right: 'THAT IS THE BRANCH',
  wrong: 'NOT THAT ONE',
  brief: forkBrief,
  briefName: 'forkBrief',
  rounds: [
    for (final (i, r) in forkRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Fork.values) ForkRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              SizeCurvePainter(soil: r.soil, answered: answered).paint,
          210,
          formula: r'$\text{No. 200 first, then No. 4}$',
          size: 14,
          grey: true,
          what: 'which-fork-first round $i',
        ),
      ),
  ],
);

Map<String, Object?> aboveOrBelowTheLine() => plainGame(
  id: 'above-or-below-the-line',
  title: 'Above or Below the Line',
  closing:
      'Two lines and four quarters. Above the A-line is a clay and '
      'below it is a silt, which is a statement about behavior rather '
      'than a name: silts drain and settle quickly, clays hold water '
      'and keep moving. Right of a liquid limit of 50 is high '
      'plasticity. A high liquid limit on its own does not make a clay, '
      'which is the quarter people forget is there.',
  overline: 'WHERE DOES THE POINT LAND',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: chartBrief,
  briefName: 'chartBrief',
  rounds: [
    for (final (i, r) in chartRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Quarter.values) ChartRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              PlasticityPainter(fines: r.fines, answered: answered).paint,
          222,
          formula: r'$\text{A-line: } PI = 0.73(LL - 20)$',
          size: 14,
          what: 'above-or-below-the-line round $i',
        ),
      ),
  ],
);

Map<String, Object?> bothOrNeither() => plainGame(
  id: 'both-or-neither',
  title: 'Both or Neither',
  closing:
      'Two coefficients, and a soil is well graded only if both pass. '
      'The uniformity asks whether the sample spans a wide range of '
      'sizes, and a gravel needs only 4 where a sand needs 6. The '
      'concavity asks whether the middle of that range is actually '
      'there, and it has to land between 1 and 3. A huge uniformity '
      'with a failing concavity is a gap graded soil, and it is poorly '
      'graded however wide its range looks.',
  overline: 'WELL GRADED OR NOT',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: gradationBrief,
  briefName: 'gradationBrief',
  rounds: [
    for (final (i, r) in wellGradedRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Graded2.values) GradeRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              SizeCurvePainter(soil: r.soil, answered: answered).paint,
          210,
          formula:
              r'$C_u = \frac{D_{60}}{D_{10}}, \quad '
              r'C_c = \frac{D_{30}^2}{D_{10}D_{60}}$',
          size: 14,
          what: 'both-or-neither round $i',
        ),
      ),
  ],
);

Map<String, Object?> whichStressIsThat() => plainGame(
  id: 'which-stress-is-that',
  title: 'Which Stress Is That',
  closing:
      'Total is everything above, weighed. Water pressure is the height '
      'of water above the point, measured from the WATER TABLE and not '
      'the surface, and it is zero above the table. Effective is what '
      'is left over, and it is the only one the soil responds to. A '
      'surcharge adds to the total, leaves the water alone, and so goes '
      'entirely onto the grains.',
  overline: 'WHICH OF THE THREE',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: threeStressBrief,
  briefName: 'threeStressBrief',
  rounds: [
    for (final (i, r) in stressRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Stress.values) StressRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => DepositPainter(
            deposit: r.deposit,
            at: r.at,
            answered: answered,
          ).paint,
          232,
          formula: r"$\sigma' = \sigma - u$",
          size: 17,
          what: 'which-stress-is-that round $i',
        ),
      ),
  ],
);

Map<String, Object?> whatTheWaterTableDoes() => plainGame(
  id: 'what-the-water-table-does',
  title: 'What the Water Table Does',
  closing:
      'Lower the water table and the grains take up what buoyancy gives '
      'back, so the effective stress rises and the site settles: that '
      'is dewatering, and it is why pumping next door cracks buildings '
      'nobody has touched. Raise it and the reverse happens. A '
      'surcharge lands entirely on the grains. And standing water over '
      'a saturated site changes nothing at all, because it adds the '
      'same amount to both sides of the subtraction.',
  overline: 'WHICH WAY DOES IT GO',
  right: 'THAT IS THE WAY',
  wrong: 'THE OTHER WAY',
  brief: waterTableBrief,
  briefName: 'waterTableBrief',
  rounds: [
    for (final (i, r) in tableMoveRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Moves3.values) ChangeRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => DepositPainter(
            deposit: answered ? r.after : r.before,
            at: r.at,
            answered: answered,
          ).paint,
          232,
          formula: r"$\sigma' = \sigma - u$",
          size: 17,
          what: 'what-the-water-table-does round $i',
        ),
      ),
  ],
);

Map<String, Object?> theShortWayDown() => plainGame(
  id: 'the-short-way-down',
  title: 'The Short Way Down',
  closing:
      'Below the water table each foot of soil adds its buoyant weight '
      'to the effective stress, above it each foot adds its own weight '
      'untouched, and a surcharge adds in full. That walk gives exactly '
      'the same answer as taking the total and subtracting the water '
      'pressure, which is measured from the WATER TABLE down. The one '
      'thing never to do is buoy a layer that sits above the table.',
  overline: 'WALKING DOWN THE PROFILE',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: shortWayBrief,
  briefName: 'shortWayBrief',
  rounds: [
    for (final (i, r) in profileWalkRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => DepositPainter(
            deposit: r.deposit,
            at: r.at,
            answered: answered,
          ).paint,
          232,
          formula: r"$\sigma' = \gamma_1 H_1 + \gamma' H_2$",
          size: 16,
          what: 'the-short-way-down round $i',
        ),
      ),
  ],
);

Map<String, Object?> whichCaseIsIt() => plainGame(
  id: 'which-case-is-it',
  title: 'Which Case Is It',
  closing:
      'Everything turns on the largest pressure the clay has ever '
      'carried. Land under it and the move is all recompression, on the '
      'stiff index, and the settlement is small. Start on it and every '
      'pound is virgin ground on the soft index. Cross it and the move '
      'has to be split in two, stiff up to the memory and soft beyond '
      'it. Running a crossing move on one index alone is the wrong '
      'answer the exam offers most often.',
  overline: 'WHICH FORMULA DOES IT WANT',
  right: 'THAT IS THE CASE',
  wrong: 'NOT THAT ONE',
  brief: caseBrief,
  briefName: 'caseBrief',
  rounds: [
    for (final (i, r) in caseRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Case.values) CaseRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              StressLinePainter(squeeze: r.squeeze, answered: answered).paint,
          168,
          formula: r'$\Delta H = \frac{H_0}{1+e_0}\,C\,\log\frac{p_1}{p_0}$',
          size: 15,
          what: 'which-case-is-it round $i',
        ),
      ),
  ],
);

Map<String, Object?> stiffUntilItRemembers() => plainGame(
  id: 'stiff-until-it-remembers',
  title: 'Stiff Until It Remembers',
  closing:
      'The corner in the curve is the largest pressure the clay has '
      'ever carried. Under it the clay is stiff, on an index about a '
      'sixth of the other, because it is only going back over ground it '
      'has covered. Past it the grains rearrange in earnest. A memory '
      'comes from ground that was removed, or ice, or drying. And the '
      'log in the formula means equal ratios settle equally, so the '
      'first few hundred pounds on a soft clay are the expensive ones.',
  overline: 'THE TWO SLOPES',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: memoryBrief,
  briefName: 'memoryBrief',
  rounds: [
    for (final (i, r) in indexRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              ElogPPainter(squeeze: r.squeeze, answered: answered).paint,
          210,
          formula: r'$C_r \approx C_c / 6$',
          size: 16,
          what: 'stiff-until-it-remembers round $i',
        ),
      ),
  ],
);

Map<String, Object?> howLongDoesItTake() => plainGame(
  id: 'how-long-does-it-take',
  title: 'How Long Does It Take',
  closing:
      'How much a clay settles and how long it takes are different '
      'questions. The time turns on the drainage path, which is half '
      'the layer when water escapes both faces and the whole of it when '
      'one face is rock, and the time goes as the SQUARE of that path. '
      'So one impermeable boundary costs four times the wait, and so '
      'does doubling the thickness. The size of the load changes the '
      'settlement and not the schedule.',
  overline: 'HOW FAR THE WATER GOES',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: drainageBrief,
  briefName: 'drainageBrief',
  rounds: [
    for (final (i, r) in timeRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              DrainagePainter(drain: r.drain, answered: answered).paint,
          196,
          formula: r'$t = \frac{T_v H_{dr}^2}{c_v}$',
          size: 16,
          what: 'how-long-does-it-take round $i',
        ),
      ),
  ],
);

Map<String, Object?> twoTerms() => plainGame(
  id: 'two-terms',
  title: 'Two Terms',
  closing:
      'Strength is a constant plus something that grows with pressing. '
      'A clean sand has only the growing part, so it is worth nothing '
      'at the surface and a great deal at depth, which is why sand '
      'cannot stand in a vertical face. A saturated clay loaded quickly '
      'has only the constant part, so its envelope is flat and one '
      'number describes the whole layer. Most soils have some of each, '
      'and both terms are added.',
  overline: 'WHAT IS CARRYING IT',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: mohrCoulombBrief,
  briefName: 'mohrCoulombBrief',
  rounds: [
    for (final (i, r) in twoTermRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Term2.values) TermRound2.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => EnvelopePainter(
            failure: r.failure,
            markAt: r.markAt,
            answered: answered,
          ).paint,
          208,
          formula: r"$\tau_f = c' + \sigma_N' \tan\phi'$",
          size: 16,
          what: 'two-terms round $i',
        ),
      ),
  ],
);

Map<String, Object?> drainedOrNot() => plainGame(
  id: 'drained-or-not',
  title: 'Drained or Not',
  closing:
      'Which set a problem wants is a question about time. Faster than '
      'the water can move, a saturated clay is described by its '
      'undrained strength with total stresses and no friction angle. '
      'Given time, by effective parameters with effective stresses, and '
      'it ends up stronger than it started. A sand drains as fast as it '
      'is loaded, so the effective set applies throughout. Never take '
      'one parameter from one set and one stress from the other.',
  overline: 'WHICH SET OF PARAMETERS',
  right: 'THAT IS THE SET',
  wrong: 'NOT THAT ONE',
  brief: drainedBrief,
  briefName: 'drainedBrief',
  rounds: [
    for (final (i, r) in drainRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Set2.values) DrainRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => EnvelopePainter(
            failure: r.failure,
            reveal: answered,
            answered: answered,
          ).paint,
          200,
          formula:
              r"$c', \phi' \text{ with } \sigma' \qquad c_u, \phi_u = 0 "
              r"\text{ with } \sigma$",
          size: 13,
          what: 'drained-or-not round $i',
        ),
      ),
  ],
);

Map<String, Object?> readingTheCircle() => plainGame(
  id: 'reading-the-circle',
  title: 'Reading the Circle',
  closing:
      'The two stresses at failure sit at the ends of a diameter, so '
      'the middle is their average and the radius is half their '
      'difference. A flat undrained envelope touches the circle at its '
      'top, which makes the undrained strength the RADIUS, half the '
      'deviator. For a soil with no cohesion the envelope runs through '
      'the origin and the SINE of the friction angle is the radius over '
      'the middle. The touching point is the plane that gave way.',
  overline: 'READING THE TEST',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: mohrCircleBrief,
  briefName: 'mohrCircleBrief',
  rounds: [
    for (final (i, r) in triaxialRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => EnvelopePainter(
            failure: r.failure,
            test: r.test,
            answered: answered,
          ).paint,
          212,
          formula:
              r'$s = \frac{\sigma_1 + \sigma_3}{2}, \quad '
              r't = \frac{\sigma_1 - \sigma_3}{2}$',
          size: 14,
          what: 'reading-the-circle round $i',
        ),
      ),
  ],
);

Map<String, Object?> countingTheNet() => plainGame(
  id: 'counting-the-net',
  title: 'Counting the Net',
  closing:
      'Channels over drops, never the other way: more lanes means more '
      'water and more steps means less. A channel is the lane BETWEEN '
      'two flow lines, so the count is one less than the lines drawn. '
      'Every drop is an equal step of head. And the net itself is '
      'geometry: the same drawing serves for any uniform soil, with the '
      'conductivity waiting outside the fraction.',
  overline: 'READING THE NET',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: flowNetBrief,
  briefName: 'flowNetBrief',
  rounds: [
    for (final (i, r) in netRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => FlowNetPainter(net: r.net, answered: answered).paint,
          216,
          formula: r'$q = k H \frac{N_f}{N_d}$',
          size: 16,
          what: 'counting-the-net round $i',
        ),
      ),
  ],
);

Map<String, Object?> whenTheSandBoils() => plainGame(
  id: 'when-the-sand-boils',
  title: 'When the Sand Boils',
  closing:
      'Upward seepage drags on every grain, and when the drag matches '
      'what the grains weigh under water the effective stress reaches '
      'zero and the sand has no strength left. That gradient is the '
      'buoyant weight over the weight of water, which lands near one '
      'for almost any sand and lower for a loose one. The safety factor '
      'is critical over actual, and the fix is a longer path for the '
      'water or weight where it comes out.',
  overline: 'WHEN THE GRAINS LET GO',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: quickBrief,
  briefName: 'quickBrief',
  rounds: [
    for (final (i, r) in boilRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => BoilPainter(quick: r.quick, answered: answered).paint,
          202,
          formula: r"$i_c = \frac{\gamma'}{\gamma_w} = \frac{G_s - 1}{1 + e}$",
          size: 15,
          what: 'when-the-sand-boils round $i',
        ),
      ),
  ],
);

Map<String, Object?> steeperThanItsFriction() => plainGame(
  id: 'steeper-than-its-friction',
  title: 'Steeper Than Its Friction',
  closing:
      'A dry cohesionless slope stands as long as it is flatter than '
      'the friction angle of its soil, and the factor of safety is the '
      'tangent of one over the tangent of the other. Depth and unit '
      'weight cancel out completely: a deeper slice is driven harder '
      'and held harder in equal measure. At the friction angle exactly, '
      'the slope is at its angle of repose and its factor of safety is '
      'one, which is not a design.',
  overline: 'DOES IT STAND',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: infiniteSlopeBrief,
  briefName: 'infiniteSlopeBrief',
  rounds: [
    for (final (i, r) in bankRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Stands.values) BankRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => BankPainter(bank: r.bank, answered: answered).paint,
          204,
          formula: r'$FS = \frac{\tan\phi}{\tan\beta}$',
          size: 16,
          what: 'steeper-than-its-friction round $i',
        ),
      ),
  ],
);
