import 'package:mobile/features/games/beam_or_blanket_game.dart'
    show loadPathRounds;
import 'package:mobile/features/games/damage_not_weight_game.dart'
    show loadRounds;
import 'package:mobile/features/games/demand_figures.dart'
    show Forecast, GravityPainter, StepsPainter;
import 'package:mobile/features/games/does_it_need_a_signal_game.dart'
    show warrantRounds;
import 'package:mobile/features/games/earthwork_figures.dart' show HaulPainter;
import 'package:mobile/features/games/farther_means_fewer_game.dart'
    show frictionRounds;
import 'package:mobile/features/games/how_many_yards_game.dart'
    show yardRounds;
import 'package:mobile/features/games/how_thick_must_it_be_game.dart'
    show thicknessRounds;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/los_figures.dart' show LosPainter;
import 'package:mobile/features/games/pavement_figures.dart'
    show EsalPainter, PavementPainter;
import 'package:mobile/features/games/read_it_by_its_shape_game.dart'
    show SignKindRound, signKindRounds;
import 'package:mobile/features/games/rigid_figures.dart'
    show JointPainter, SlabPainter, SupportPainter;
import 'package:mobile/features/games/sign_figures.dart'
    show SignKind, SignPainter, WarrantPainter;
import 'package:mobile/features/games/three_divisions_game.dart'
    show divideRounds;
import 'package:mobile/features/games/what_each_inch_buys_game.dart'
    show pavementSectionRounds;
import 'package:mobile/features/games/what_k_measures_game.dart'
    show supportRounds;
import 'package:mobile/features/games/what_the_bar_is_for_game.dart'
    show jointRounds;
import 'package:mobile/features/games/what_the_letter_measures_game.dart'
    show letterRounds;
import 'package:mobile/features/games/which_step_is_that_game.dart'
    show ForecastStepRound, forecastStepRounds;
import 'package:mobile/features/games/who_gets_the_trips_game.dart'
    show tripShareRounds;

import 'builder.dart';
import 'pick_one_adapter.dart';

/// The Transportation games, second half: capacity and level of service,
/// the four step model and the gravity model, signs and signal warrants,
/// flexible pavement design, earthwork in yards, and rigid pavements. All
/// fourteen have one screen: the problem, a drawing in a white panel on
/// the 18 pixel grid, then the answers as the app's plain white rows (8
/// apart, none after the last) and, 14 below, the feedback.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'three-things-to-divide-by': threeThingsToDivideBy,
  'what-the-letter-measures': whatTheLetterMeasures,
  'which-step-is-that': whichStepIsThat,
  'who-gets-the-trips': whoGetsTheTrips,
  'farther-means-fewer': fartherMeansFewer,
  'read-it-by-its-shape': readItByItsShape,
  'does-it-need-a-signal': doesItNeedASignal,
  'what-each-inch-buys': whatEachInchBuys,
  'how-thick-must-it-be': howThickMustItBe,
  'damage-not-weight': damageNotWeight,
  'how-many-yards': howManyYards,
  'beam-or-blanket': beamOrBlanket,
  'what-the-bar-is-for': whatTheBarIsFor,
  'what-k-measures': whatKMeasures,
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

/// A game of this chapter: every round the problem, its drawing in a
/// panel [h] high, the answers and the feedback.
Map<String, Object?> _game({
  required String id,
  required String title,
  required String closing,
  required String overline,
  required BriefSection brief,
  required String briefName,
  required double h,
  required List<_Round> rounds,
}) => pickScreen(
  id: id,
  chapter: 'transportation',
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
          gap(12),
          {'choices': true, 'space': 8},
          ...feedbackAfter(14),
        ],
      ),
  ],
);

Map<String, Object?> threeThingsToDivideBy() => _game(
  id: 'three-things-to-divide-by',
  title: 'Three Things to Divide By',
  closing:
      'One volume, three divisions: the peak hour factor for the surge, '
      'the lanes for one lane, and the heavy vehicle factor for cars '
      'rather than vehicles. Leave out the trucks and you get 1,630. '
      'Leave out the peak factor and you get 1,650. Leave out both and '
      'you are quoting the raw volume.',
  overline: 'ONE VOLUME, THREE DIVISIONS',
  brief: demandFlowBrief,
  briefName: 'demandFlowBrief',
  h: 226,
  rounds: [
    for (final r in divideRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            LosPainter(road: r.road, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whatTheLetterMeasures() => _game(
  id: 'what-the-letter-measures',
  title: 'What the Letter Measures',
  closing:
      'Work the flow per lane, divide by the speed to get the density, '
      'then read the letter off that. Not off the volume, not off the '
      'speed. The bands are narrow near capacity, so a single missing '
      'adjustment moves the letter, and a lane added or a speed lost '
      'moves it further still.',
  overline: 'THE LETTER ON THE ROAD',
  brief: levelOfServiceBrief,
  briefName: 'levelOfServiceBrief',
  h: 226,
  rounds: [
    for (final r in letterRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            LosPainter(road: r.road, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whichStepIsThat() => _game(
  id: 'which-step-is-that',
  title: 'Which Step Is That',
  closing:
      'Generation counts the trips. Distribution decides where they go, '
      'and that is where the gravity model works. Mode choice picks how '
      'they travel. Assignment puts them on particular roads. Each step '
      'consumes what the one before it made, which is why the order '
      'never changes.',
  overline: 'THE FOUR STEPS',
  brief: fourStepBrief,
  briefName: 'fourStepBrief',
  h: 206,
  rounds: [
    for (final r in forecastStepRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: [for (final o in Forecast.values) ForecastStepRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) => StepsPainter(
          highlight: answered ? r.highlight : null,
          answered: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> whoGetsTheTrips() => _game(
  id: 'who-gets-the-trips',
  title: 'Who Gets the Trips',
  closing:
      'Every destination gets a weight, its attractions times the '
      'friction factor for that trip. Then the origin\'s trips are '
      'shared out in proportion to those weights, which means dividing '
      'by their SUM. The shares add to one and the trips add to what '
      'the origin produced, which is the check that catches the '
      'forgotten denominator.',
  overline: 'SHARING OUT THE TRIPS',
  brief: gravityBrief,
  briefName: 'gravityBrief',
  h: 226,
  rounds: [
    for (final r in tripShareRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            GravityPainter(spread: r.spread, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> fartherMeansFewer() => _game(
  id: 'farther-means-fewer',
  title: 'Farther Means Fewer',
  closing:
      'The friction factor falls as the trip gets longer, so a high '
      'factor means an EASY trip. Big and near attracts, small and far '
      'does not, and a big enough destination can still beat a long '
      'trip. A faster road raises the factor and moves trips toward '
      'that zone, without changing how many trips there are.',
  overline: 'NEAR AGAINST BIG',
  brief: frictionBrief,
  briefName: 'frictionBrief',
  h: 226,
  rounds: [
    for (final r in frictionRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            GravityPainter(spread: r.spread, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> readItByItsShape() => _game(
  id: 'read-it-by-its-shape',
  title: 'Read It by Its Shape',
  closing:
      'Red octagon and white rectangle: regulatory, and legally '
      'binding. Yellow diamond: warning, describing what is ahead. '
      'Green: guide, asking nothing at all. The shape and color carry '
      'the category before a word is read, which is what a uniform '
      'manual is for.',
  overline: 'WHAT KIND OF SIGN',
  brief: signCategoryBrief,
  briefName: 'signCategoryBrief',
  h: 200,
  rounds: [
    for (final r in signKindRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: [for (final o in SignKind.values) SignKindRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            SignPainter(sign: r.sign, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> doesItNeedASignal() => _game(
  id: 'does-it-need-a-signal',
  title: 'Does It Need a Signal',
  closing:
      'A signal stops traffic that did not have to stop, so it buys '
      'delay and rear-end crashes and must earn its place. Meeting a '
      'warrant shows it is justified, not that it is required. The '
      'warrants cover volumes, people on foot, school crossings and '
      'crash history, and an intersection can qualify on any of them.',
  overline: 'BEFORE A SIGNAL GOES IN',
  brief: warrantBrief,
  briefName: 'warrantBrief',
  h: 196,
  rounds: [
    for (final r in warrantRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            WarrantPainter(crossing: r.crossing, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whatEachInchBuys() => _game(
  id: 'what-each-inch-buys',
  title: 'What Each Inch Buys',
  closing:
      'Coefficient times thickness times drainage, course by course, '
      'added up. An inch of asphalt does the work of about three '
      'inches of base, which is why sections are traded rather than '
      'simply thickened. The surface course takes a drainage factor of '
      'one, and the granular courses take whatever the problem says.',
  overline: 'ADDING UP THE SECTION',
  brief: structuralNumberBrief,
  briefName: 'structuralNumberBrief',
  h: 226,
  rounds: [
    for (final r in pavementSectionRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            PavementPainter(pavement: r.pavement, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> howThickMustItBe() => _game(
  id: 'how-thick-must-it-be',
  title: 'How Thick Must It Be',
  closing:
      'Take what the fixed courses give away from the target, then '
      'divide by what an inch of the missing course is worth. A poorly '
      'drained subbase gives less, so the base has to give more. And a '
      'negative answer is not an error: it means the section already '
      'meets the number.',
  overline: 'SOLVING FOR A COURSE',
  brief: layerThicknessBrief,
  briefName: 'layerThicknessBrief',
  h: 216,
  rounds: [
    for (final r in thicknessRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            PavementPainter(pavement: r.pavement, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> damageNotWeight() => _game(
  id: 'damage-not-weight',
  title: 'Damage, Not Weight',
  closing:
      'Damage climbs far faster than weight, so traffic is counted in '
      'standard eighteen kip axle loads. A car is worth a couple of ten '
      'thousandths of one and a loaded truck axle is worth three. '
      'Multiply the passes by the factor, add them up over the design '
      'life, and that is what sets the structural number.',
  overline: 'WHAT WEARS A ROAD OUT',
  brief: esalBrief,
  briefName: 'esalBrief',
  h: 196,
  rounds: [
    for (final r in loadRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            EsalPainter(axles: r.axles, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> howManyYards() => _game(
  id: 'how-many-yards',
  title: 'How Many Yards',
  closing:
      'Both formulas work in whatever units go in, so feet and '
      'square feet give cubic FEET, and a quantity is paid in cubic '
      'yards: divide by twenty seven, not by three. The end area '
      'method gives the larger number whenever the real middle '
      'section sags below the average of the two ends, and on a long '
      'corridor that difference is money.',
  overline: 'CUT AND FILL, IN YARDS',
  brief: yardsBrief,
  briefName: 'yardsBrief',
  h: 216,
  rounds: [
    for (final r in yardRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) => HaulPainter(
          haul: r.haul,
          showEndAverage: r.compareMiddle,
          locked: answered,
        ).paint,
      ),
  ],
);

Map<String, Object?> beamOrBlanket() => _game(
  id: 'beam-or-blanket',
  title: 'Beam or Blanket',
  closing:
      'A concrete slab bends across the load and hands it to a wide '
      'patch of ground, so it bridges soft spots and minds the '
      'subgrade far less. An asphalt section passes the load down '
      'course by course, so every course has to be strong. One is '
      'designed on bending strength, the other on a structural '
      'number.',
  overline: 'HOW THE LOAD GETS DOWN',
  brief: rigidVsFlexibleBrief,
  briefName: 'rigidVsFlexibleBrief',
  h: 206,
  rounds: [
    for (final r in loadPathRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) => SlabPainter(load: r.load, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whatTheBarIsFor() => _game(
  id: 'what-the-bar-is-for',
  title: 'What the Bar Is For',
  closing:
      'Smooth and greased means let go: a dowel carries the wheel load '
      'across a transverse joint while the slabs move. Deformed and '
      'bonded means hold on: a tie bar keeps a lane line shut. '
      'Contraction joints decide where the slab cracks, and where '
      'there is no steel the rough crack faces interlock instead.',
  overline: 'JOINTS AND THE STEEL IN THEM',
  brief: jointBrief,
  briefName: 'jointBrief',
  h: 206,
  rounds: [
    for (final r in jointRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            JointPainter(joint: r.joint, answered: answered).paint,
      ),
  ],
);

Map<String, Object?> whatKMeasures() => _game(
  id: 'what-k-measures',
  title: 'What k Measures',
  closing:
      'A stiffness, not a strength: the pressure it takes to push the '
      'ground down one inch. Higher k means a bed of springs that '
      'gives less, so the slab bends less and the concrete is stressed '
      'less. And because the slab spreads the load so widely to begin '
      'with, improving the ground buys less here than it would under '
      'asphalt.',
  overline: 'THE GROUND UNDER THE SLAB',
  brief: subgradeReactionBrief,
  briefName: 'subgradeReactionBrief',
  h: 206,
  rounds: [
    for (final r in supportRounds)
      (
        subject: r.subject,
        asked: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        paint: (answered) =>
            SupportPainter(stiffness: r.stiffness, answered: answered).paint,
      ),
  ],
);
