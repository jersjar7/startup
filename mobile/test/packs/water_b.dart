import 'package:mobile/features/games/aquifer_figures.dart'
    show AquiferPainter, SoilPainter;
import 'package:mobile/features/games/bod_figures.dart' show BodPainter;
import 'package:mobile/features/games/chlorine_figures.dart'
    show ContactPainter, DosePainter;
import 'package:mobile/features/games/clarifier_figures.dart'
    show ClarifierPainter, PlantPainter;
import 'package:mobile/features/games/does_it_settle_out_game.dart'
    show Settles, SettlesWords, captureRounds;
import 'package:mobile/features/games/double_the_drawdown_game.dart'
    show Buys, BuysWords, drawRounds;
import 'package:mobile/features/games/filling_or_emptying_game.dart'
    show Store, StoreWords, pondRounds;
import 'package:mobile/features/games/filter_figures.dart' show FilterPainter;
import 'package:mobile/features/games/health_or_taste_game.dart'
    show tierRounds;
import 'package:mobile/features/games/hours_or_days_game.dart'
    show Stay, StayWords, twoClockRounds;
import 'package:mobile/features/games/how_fast_through_the_sand_game.dart'
    show filterRounds;
import 'package:mobile/features/games/how_much_is_used_up_game.dart'
    show Used, UsedWords, usedRounds;
import 'package:mobile/features/games/hydrograph_figures.dart' show PondPainter;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/multiply_or_divide_game.dart'
    show Step3, Step3Words, bodStepRounds;
import 'package:mobile/features/games/removed_or_remaining_game.dart'
    show Duty3, Duty3Words, dutyRounds2;
import 'package:mobile/features/games/standards_figures.dart'
    show HardnessPainter, RemovalPainter, Tier, TierPainter;
import 'package:mobile/features/games/warmer_or_colder_game.dart'
    show Rate3, Rate3Words, warmRounds;
import 'package:mobile/features/games/what_buys_the_ct_game.dart'
    show Credit, CreditWords, creditRounds;
import 'package:mobile/features/games/what_do_you_feed_game.dart'
    show Portion, PortionWords, feedRounds;
import 'package:mobile/features/games/what_moves_the_ratio_game.dart'
    show Ratio3, Ratio3Words, fmRounds;
import 'package:mobile/features/games/which_ion_counts_more_game.dart'
    show Counts, CountsWords, ionRounds;
import 'package:mobile/features/games/which_speed_is_that_game.dart'
    show Quantity3, Quantity3Words, seepRounds;
import 'package:mobile/features/games/which_well_formula_game.dart'
    show Formula2, Formula2Words, wellRounds;

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';

/// The Water Resources games, second half: storage routing, groundwater
/// and wells, BOD, clarifiers and activated sludge, chlorine, filters,
/// and the drinking water standards. Every one is the same screen: the
/// problem, a drawing in a white panel on the 18 pixel grid, mostly a
/// formula under it, then the answers as plain white rows 8 apart (or,
/// in Which Well Formula, the two formulas themselves as the answers) and
/// 14 below the last, the feedback.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'filling-or-emptying': fillingOrEmptying,
  'which-speed-is-that': whichSpeedIsThat,
  'which-well-formula': whichWellFormula,
  'double-the-drawdown': doubleTheDrawdown,
  'how-much-is-used-up': howMuchIsUsedUp,
  'multiply-or-divide': multiplyOrDivide,
  'warmer-or-colder': warmerOrColder,
  'does-it-settle-out': doesItSettleOut,
  'hours-or-days': hoursOrDays,
  'what-moves-the-ratio': whatMovesTheRatio,
  'what-do-you-feed': whatDoYouFeed,
  'how-fast-through-the-sand': howFastThroughTheSand,
  'what-buys-the-ct': whatBuysTheCt,
  'health-or-taste': healthOrTaste,
  'which-ion-counts-more': whichIonCountsMore,
  'removed-or-remaining': removedOrRemaining,
};

/// One round of the chapter's screen.
typedef _Round = ({
  String subject,
  String setting,
  List<String> options,
  int answer,
  String why,
  String source,
  Draw Function(bool answered) paint,
});

/// A game of this chapter: every round the problem, its drawing in a
/// panel [h] high, then [formula] (set at [size]) 10 below it and 12 more
/// to the answers, or with no formula [below] to the answers. [answers]
/// replaces the plain answer rows when the game draws its own.
Map<String, Object?> _game({
  required String id,
  required String title,
  required String closing,
  required String overline,
  required String right,
  required String wrong,
  required BriefSection brief,
  required String briefName,
  required double h,
  String? formula,
  num size = 16,
  num below = 12,
  List<Map<String, Object?>>? answers,
  required List<_Round> rounds,
}) {
  if (captureDraws case final capture?) {
    for (final (i, r) in rounds.indexed) {
      for (final answered in [false, true]) {
        capture(
          '$id round $i ${answered ? 'done' : 'ask'}',
          r.paint(answered),
          h - 2,
        );
      }
    }
    return const {};
  }
  return pickScreen(
    id: id,
    chapter: 'water-resources',
    title: title,
    closing: closing,
    right: right,
    wrong: wrong,
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
            ...heading(overline, r.subject, r.setting),
            gap(12),
            figure(r.paint, h, frame: 'panel', what: '$id round $i'),
            if (formula != null) ...[
              gap(10),
              {'math': formula, 'size': size},
              gap(12),
            ] else
              gap(below),
            ...?answers,
            if (answers == null) {'choices': true, 'space': 8},
            ...feedbackAfter(14),
          ],
        ),
    ],
  );
}

/// Set by a check that wants each round's drawing to paint for itself
/// rather than recorded (to hash the built-in drawings before and after a
/// painter changes): every round's drawing is handed to it instead, at the
/// size the panel gives it.
void Function(String what, Draw draw, double h)? captureDraws;

/// As the BOD games write a day: whole days without a decimal point.
String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

Map<String, Object?> fillingOrEmptying() => _game(
  id: 'filling-or-emptying',
  title: 'Filling or Emptying',
  closing:
      'Inflow minus outflow is the rate the storage changes, and the '
      'sign is the whole answer: more in than out means the pond is '
      'filling. It fills through the rising limb, is at its fullest at '
      'the single moment the two flows are equal, and empties after '
      'that. Subtracting the other way round gives the right number '
      'with the wrong story attached.',
  overline: 'WHAT IS THE STORAGE DOING',
  right: 'THAT IS WHAT IT IS DOING',
  wrong: 'THE OTHER WAY',
  brief: routingBrief,
  briefName: 'routingBrief',
  h: 226,
  formula: r'$I - O = \dfrac{\Delta S}{\Delta t}$',
  rounds: [
    for (final r in pondRounds)
      (
        subject: r.subject,
        setting: r.setting,
        options: [for (final o in Store.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            PondPainter(pond: r.pond, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whichSpeedIsThat() => _game(
  id: 'which-speed-is-that',
  title: 'Which Speed Is That',
  closing:
      'Three quantities and they are easy to hand to the wrong '
      'question. The Darcy velocity, or specific discharge, is K times '
      'the gradient: the units of a speed, and the speed of nothing. '
      'The seepage velocity is that divided by the porosity, and it is '
      'what a tracer travels at, always the larger of the two. '
      'Multiply the Darcy velocity by the area and you have a volume a '
      'second, which is not a speed at all.',
  overline: 'WHICH OF THE THREE IS BEING ASKED FOR',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT ONE',
  brief: seepageBrief,
  briefName: 'seepageBrief',
  h: 226,
  formula: r'$q = K i, \quad v = \dfrac{q}{n}, \quad Q = qA$',
  size: 14,
  rounds: [
    for (final r in seepRounds)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Quantity3.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            SoilPainter(seep: r.seep, answered: answered).paint,
      ),
  ],
);

/// Which Well Formula's answers are the two formulas, each set left in a
/// white row 16 above and below, its border following the answer.
List<Map<String, Object?>> _formulaAnswers(List<String> latex) => [
  for (final (i, f) in latex.indexed) ...[
    if (i > 0) gapH(8),
    answer(
      i,
      box(
        w: 'max',
        pad: [14, 16, 14, 16],
        radius: 10,
        border: tone('line', 'ember', 'forest', 'error'),
        stroke: tone(1, 2, 2, 2),
        child: math(f, 15),
      ),
      radius: 10,
      fill: 'white',
    ),
  ],
];

Map<String, Object?> whichWellFormula() {
  const order = [Formula2.dupuit, Formula2.thiem];
  return _game(
    id: 'which-well-formula',
    title: 'Which Well Formula',
    closing:
        'One question picks the formula: is there something impermeable '
        'over the aquifer. Clay on top means confined, the thickness is '
        'fixed, the transmissivity is K times b, and the heads go in as '
        'they are. A free water table means the saturated thickness falls '
        'as the water table does, and the squared heads in Dupuit are '
        'what account for it.',
    overline: 'WHICH FORMULA DOES THIS WELL TAKE',
    right: 'THAT IS THE ONE',
    wrong: 'THE OTHER ONE',
    brief: wellBrief,
    briefName: 'wellBrief',
    h: 234,
    answers: _formulaAnswers([for (final o in order) o.latex]),
    rounds: [
      for (final r in wellRounds)
        (
          subject: r.subject,
          setting: r.setting,
          options: [for (final o in order) o.latex],
          answer: order.indexOf(r.answer),
          why: r.why,
          source: r.source,
          paint: (answered) =>
              AquiferPainter(aquifer: r.aquifer, showFormula: answered).paint,
        ),
    ],
  );
}

Map<String, Object?> doubleTheDrawdown() => _game(
  id: 'double-the-drawdown',
  title: 'Double the Drawdown',
  closing:
      'In a confined aquifer every term is a plain proportion: twice '
      'the drawdown, the conductivity or the thickness is twice the '
      'water. In an unconfined one the heads are squared, and the '
      'difference of two squares is the difference times the SUM, so '
      'pulling the well down harder buys less than proportionally and a '
      'higher water table buys more. The squared form is the aquifer '
      'getting thinner, written down.',
  overline: 'WHAT DOES THE CHANGE BUY',
  right: 'THAT IS WHAT IT BUYS',
  wrong: 'NOT QUITE',
  brief: wellBrief,
  briefName: 'wellBrief',
  h: 234,
  formula: r'$h_2^2 - h_1^2 = (h_2 - h_1)(h_2 + h_1)$',
  size: 15,
  rounds: [
    for (final r in drawRounds)
      (
        subject: r.subject,
        setting: r.change,
        options: [for (final o in Buys.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => AquiferPainter(
          aquifer: answered ? r.after : r.before,
          showFormula: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> howMuchIsUsedUp() => _game(
  id: 'how-much-is-used-up',
  title: 'How Much Is Used Up',
  closing:
      'The five day BOD is never the ultimate BOD, and how much of it '
      'the test catches depends on the decay rate: 68 percent at the '
      'standard 0.23 a day, under 40 percent in slow cold water, and '
      'nearly all of it in a fast warm sample. What is always true is '
      'that the exerted and the remaining add up to the ultimate, so '
      'naming which one a question wants is the first move.',
  overline: 'BY THAT DAY, HOW FAR HAS IT GOT',
  right: 'THAT IS HOW FAR',
  wrong: 'NOT THAT FAR',
  brief: bodBrief,
  briefName: 'bodBrief',
  h: 226,
  formula: r'$BOD_t = L_0\left(1 - e^{-kt}\right)$',
  size: 15,
  rounds: [
    for (final r in usedRounds)
      (
        subject: r.subject,
        setting: r.setting,
        options: [for (final o in Used.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            BodPainter(demand: r.demand, day: r.day, showSplit: answered).paint,
      ),
  ],
);

Map<String, Object?> multiplyOrDivide() => _game(
  id: 'multiply-or-divide',
  title: 'Multiply or Divide',
  closing:
      'The fraction the equation gives is always less than one. Going '
      'from the ultimate to the measurement you multiply by it and the '
      'answer gets smaller; going the other way you divide and it gets '
      'larger. The ultimate is always the bigger number, which is the '
      'check that catches a division done upside down. And the fraction '
      'belongs to the day the bottle was actually read at.',
  overline: 'WHICH WAY DOES THE FRACTION GO',
  right: 'THAT IS THE WAY',
  wrong: 'THE OTHER WAY',
  brief: bodBrief,
  briefName: 'bodBrief',
  h: 214,
  formula: r'$BOD_t = L_0\left(1 - e^{-kt}\right)$',
  size: 15,
  rounds: [
    for (final r in bodStepRounds)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Step3.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => BodPainter(
          demand: r.demand,
          day: r.day,
          showSplit: answered,
          note: answered
              ? 'the fraction at day ${_num(r.day)} is '
                    '${r.demand.fractionAt(r.day).toStringAsFixed(3)}'
              : 'k ${r.demand.rate} per day',
        ).paint,
      ),
  ],
);

Map<String, Object?> warmerOrColder() => _game(
  id: 'warmer-or-colder',
  title: 'Warmer or Colder',
  closing:
      'Temperature corrects the RATE and never the ultimate: the same '
      'organic matter needs the same oxygen, it just gets there sooner '
      'in warm water. The exponent is T minus 20, so above the '
      'reference k rises and below it k falls, and turning the exponent '
      'around gives a slower rate for a warmer river, which cannot '
      'happen. Which theta to use depends on the process and the range.',
  overline: 'WHAT DOES THE TEMPERATURE CHANGE',
  right: 'THAT IS WHAT IT DOES',
  wrong: 'NOT THAT',
  brief: temperatureBrief,
  briefName: 'temperatureBrief',
  h: 222,
  formula: r'$k_T = k_{20}\,\theta^{(T-20)}$',
  rounds: [
    for (final r in warmRounds)
      (
        subject: r.subject,
        setting: r.setting,
        options: [for (final o in Rate3.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => BodPainter(
          demand: r.base,
          day: 5,
          warmer: answered ? r.corrected : null,
          showSplit: false,
          note: answered
              ? 'red: the same sample at ${_num(r.celsius)} degrees'
              : 'black: k ${r.base.rate} at 20 degrees',
        ).paint,
      ),
  ],
);

Map<String, Object?> doesItSettleOut() => _game(
  id: 'does-it-settle-out',
  title: 'Does It Settle Out',
  closing:
      'The overflow rate is a velocity: the speed the water rises '
      'through the tank. A particle falling faster than it reaches the '
      'floor, and one falling slower goes over the weir. It is Q over '
      'the SURFACE area, so the depth of the tank is nowhere in it: '
      'deeper buys detention time and captures nothing extra, while '
      'wider buys capture.',
  overline: 'CAUGHT, OR OVER THE WEIR',
  right: 'THAT IS WHAT BECOMES OF IT',
  wrong: 'THE OTHER WAY',
  brief: overflowBrief,
  briefName: 'overflowBrief',
  h: 240,
  formula: r'$v_o = \dfrac{Q}{A_{surface}}$',
  rounds: [
    for (final r in captureRounds)
      (
        subject: r.subject,
        setting: r.setting,
        options: [for (final o in Settles.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => ClarifierPainter(
          clarifier: r.clarifier,
          settlingFeetPerHour: r.falling,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> hoursOrDays() => _game(
  id: 'hours-or-days',
  title: 'Hours or Days',
  closing:
      'Two clocks, two paths. The water goes through once and is out '
      'in hours: volume over flow. The solids settle, are returned, and '
      'go round until they are wasted, which takes days: the mass held '
      'over the mass leaving each day. The units tell them apart, and '
      'so does the diagram, and the operator changes one of them with '
      'the waste pump without touching the other.',
  overline: 'WHICH OF THE TWO CLOCKS',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER CLOCK',
  brief: residenceBrief,
  briefName: 'residenceBrief',
  h: 224,
  formula:
      r'$\theta = \dfrac{V}{Q} \quad\quad \theta_c = \dfrac{V X_A}{Q_w X_w + Q_e X_e}$',
  size: 13,
  rounds: [
    for (final r in twoClockRounds)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Stay.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => PlantPainter(
          highlight: answered ? r.highlight : null,
          note: answered
              ? 'the path in ember is the one the round names'
              : 'water across the top, solids round the bottom',
        ).paint,
      ),
  ],
);

Map<String, Object?> whatMovesTheRatio() => _game(
  id: 'what-moves-the-ratio',
  title: 'What Moves the Ratio',
  closing:
      'Food over microorganisms, and the four quantities sort '
      'themselves by which side of the line they sit on. The flow and '
      'the influent strength are the food, and only their PRODUCT '
      'matters, so a storm that doubles one and halves the other '
      'changes nothing. The basin volume and the mixed liquor solids '
      'are the bugs, and their product is the biomass the plant is '
      'carrying.',
  overline: 'WHERE DOES THE RATIO GO',
  right: 'THAT IS WHERE IT GOES',
  wrong: 'THE OTHER WAY',
  brief: foodRatioBrief,
  briefName: 'foodRatioBrief',
  h: 214,
  formula: r'$F{:}M = \dfrac{Q S_0}{V X_A}$',
  rounds: [
    for (final r in fmRounds)
      (
        subject: r.subject,
        setting: r.change,
        options: [for (final o in Ratio3.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => PlantPainter(
          note: answered
              ? 'F:M was ${r.before.toStringAsFixed(3)}, now '
                    '${r.after.toStringAsFixed(3)} per day'
              : 'F:M ${r.before.toStringAsFixed(3)} per day before '
                    'the change',
        ).paint,
      ),
  ],
);

Map<String, Object?> whatDoYouFeed() => _game(
  id: 'what-do-you-feed',
  title: 'What Do You Feed',
  closing:
      'The demand belongs to the water and is consumed first. The '
      'residual is what has to survive to the tap, and it is the only '
      'one anybody can measure out in the system. The dose is what the '
      'pump is set to and it is the sum of the other two. Feed only the '
      'demand and nothing reaches the customer; feed only the residual '
      'and the water eats it before it leaves the works.',
  overline: 'WHICH OF THE THREE IS THAT',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT ONE',
  brief: doseBrief,
  briefName: 'doseBrief',
  h: 214,
  formula: r'$\text{dose} = \text{demand} + \text{residual}$',
  size: 15,
  rounds: [
    for (final r in feedRounds)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Portion.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => DosePainter(
          chlorine: r.chlorine,
          highlight: answered ? r.answer.key : null,
        ).paint,
      ),
  ],
);

Map<String, Object?> howFastThroughTheSand() => _game(
  id: 'how-fast-through-the-sand',
  title: 'How Fast Through the Sand',
  closing:
      'The loading rate is the flow over the PLAN area of the bed, so '
      'a number per foot rather than per square foot is wrong before '
      'it is checked. Rapid sand runs a few gallons a minute to the '
      'square foot and slow sand a fraction of that. It is the same '
      'sum as a clarifier overflow rate and not the same number.',
  overline: 'DOWN THROUGH THE BED',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: filterRateBrief,
  briefName: 'filterRateBrief',
  h: 226,
  rounds: [
    for (final r in filterRounds)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            FilterPainter(bed: r.bed, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whatBuysTheCt() => _game(
  id: 'what-buys-the-ct',
  title: 'What Buys the CT',
  closing:
      'Credit is the residual times the contact time, so more of '
      'either buys the same thing and they trade off exactly. The '
      'residual is what counts, not the dose: chlorine consumed by the '
      'demand buys nothing. And the time is the tenth percentile rather '
      'than volume over flow, because the fastest water sets the '
      'protection for all of it. Baffles are the cheap way to close '
      'that gap.',
  overline: 'WHAT HAPPENS TO THE DISINFECTION CREDIT',
  right: 'THAT IS WHAT IT DOES',
  wrong: 'THE OTHER WAY',
  brief: contactBrief,
  briefName: 'contactBrief',
  h: 224,
  formula: r'$CT = C \times t_{10}$',
  rounds: [
    for (final r in creditRounds)
      (
        subject: r.subject,
        setting: r.change,
        options: [for (final o in Credit.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => ContactPainter(
          contact: answered ? r.after : r.before,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> healthOrTaste() {
  const order = [Tier.primary, Tier.secondary];
  return _game(
    id: 'health-or-taste',
    title: 'Health or Taste',
    closing:
        'Primary standards are health based and enforceable: arsenic, '
        'nitrate, lead, the pathogens. Secondary standards are about '
        'taste, color, staining and scale: iron, manganese, dissolved '
        'solids, chloride, pH. The size of the number tells you nothing '
        'about which tier it is in, and a utility exceeding a secondary '
        'guideline has a complaint on its hands rather than a violation.',
    overline: 'WHICH SHELF DOES THIS LIMIT GO ON',
    right: 'THAT IS THE SHELF',
    wrong: 'THE OTHER SHELF',
    brief: standardsBrief,
    briefName: 'standardsBrief',
    h: 210,
    below: 14,
    rounds: [
      for (final r in tierRounds)
        (
          subject: r.label,
          setting: r.asked,
          options: const [
            'Primary: health based, and enforceable',
            'Secondary: aesthetic, and advisory',
          ],
          answer: order.indexOf(r.answer),
          why: r.why,
          source: r.source,
          paint: (answered) => TierPainter(
            label: r.label,
            settled: answered ? r.answer : null,
          ).paint,
        ),
    ],
  );
}

Map<String, Object?> whichIonCountsMore() => _game(
  id: 'which-ion-counts-more',
  title: 'Which Ion Counts More',
  closing:
      'Hardness is reported as calcium carbonate so that different '
      'ions can be added on one basis, and the conversion is 50 over '
      'the ion\'s equivalent weight: 2.5 for calcium and 4.12 for '
      'magnesium. Magnesium therefore counts for more milligram for '
      'milligram, the conversion can reverse which ion dominates, and '
      'adding the raw concentrations understates the hardness every '
      'time.',
  overline: 'WHICH CONTRIBUTES MORE HARDNESS',
  right: 'THAT IS THE BIGGER SHARE',
  wrong: 'THE OTHER ONE',
  brief: hardnessBrief,
  briefName: 'hardnessBrief',
  h: 196,
  formula: r'$\text{as CaCO}_3 = C \times \dfrac{50}{EW}$',
  size: 15,
  rounds: [
    for (final r in ionRounds)
      (
        subject: r.subject,
        setting:
            'The bars are the raw concentrations as they come out of the '
            'laboratory. Hardness is reported on a calcium carbonate basis.',
        options: [for (final o in Counts.values) o.plainFor(r.ions)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            HardnessPainter(ions: r.ions, converted: answered).paint,
      ),
  ],
);

Map<String, Object?> removedOrRemaining() => _game(
  id: 'removed-or-remaining',
  title: 'Removed or Remaining',
  closing:
      'Removal efficiency is what came out over what went in, and the '
      'fraction still there is one minus it: an 87.5 percent plant '
      'leaves 12.5 percent, and both numbers turn up in the choices. '
      'The flow cancels, so only the ratio of the limit to the influent '
      'matters, and near the top of the range five percentage points '
      'halve the discharge. Think in what is left.',
  overline: 'WHAT HAPPENS TO THE REQUIRED REMOVAL',
  right: 'THAT IS WHAT IT DOES',
  wrong: 'THE OTHER WAY',
  brief: efficiencyBrief,
  briefName: 'efficiencyBrief',
  h: 214,
  formula: r'$E = \dfrac{S_0 - S}{S_0}$',
  rounds: [
    for (final r in dutyRounds2)
      (
        subject: r.subject,
        setting: r.change,
        options: [for (final o in Duty3.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => RemovalPainter(
          removal: answered ? r.after : r.before,
          answered: answered,
        ).paint,
      ),
  ],
);
