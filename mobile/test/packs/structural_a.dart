import 'package:mobile/features/games/bigger_than_the_load_game.dart'
    show HowBig, Size3Words, webRounds;
import 'package:mobile/features/games/determinacy_figures.dart'
    show SkeletonPainter;
import 'package:mobile/features/games/does_this_one_count_game.dart'
    show Adds, TermRound, termRounds;
import 'package:mobile/features/games/enough_or_too_many_game.dart'
    show Tally, TallyWords, tallyRounds2;
import 'package:mobile/features/games/factored_or_service_game.dart'
    show designRounds;
import 'package:mobile/features/games/how_much_comes_off_game.dart'
    show reduceRounds;
import 'package:mobile/features/games/influence_figures.dart'
    show InfluencePainter, Response;
import 'package:mobile/features/games/joints_or_sections_game.dart'
    show Route3, Route3Words, routeRounds, routeTruss;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/load_figures.dart'
    show Combo, LoadBarPainter, TributaryPainter;
import 'package:mobile/features/games/more_less_or_the_same_game.dart'
    show Change, CompareRound, compareRounds;
import 'package:mobile/features/games/redundant_figures.dart'
    show ReleasePainter, SplitPainter;
import 'package:mobile/features/games/the_count_says_yes_game.dart'
    show VerdictWords, WillItStand, standRounds;
import 'package:mobile/features/games/truss_section_figures.dart'
    show CornerPainter, SectionPointsPainter;
import 'package:mobile/features/games/virtual_work_figures.dart'
    show ContributionPainter, ProbePainter;
import 'package:mobile/features/games/what_do_you_hang_on_it_game.dart'
    show hangRounds;
import 'package:mobile/features/games/what_do_you_let_go_game.dart'
    show letGoRounds;
import 'package:mobile/features/games/what_the_height_means_game.dart'
    show heightRounds;
import 'package:mobile/features/games/where_do_you_take_moments_game.dart'
    show Pivot, pivotRounds;
import 'package:mobile/features/games/which_line_is_it_game.dart'
    show LineShapeRound, ilShapeRounds;
import 'package:mobile/features/games/which_one_controls_game.dart'
    show ControlRound, controlRounds, loadRows;

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show perPick;

/// The Structural games, first half: determinacy and stability, truss
/// methods, deflection by virtual work, indeterminate beams, design loads
/// and influence lines. Every one is the same screen: the problem, a
/// drawing in a white panel (or a box of the two checks, once answered),
/// a formula under it, and the answers as plain rows.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'enough-or-too-many': enoughOrTooMany,
  'the-count-says-yes': theCountSaysYes,
  'where-do-you-take-moments': whereDoYouTakeMoments,
  'bigger-than-the-load': biggerThanTheLoad,
  'joints-or-sections': jointsOrSections,
  'what-do-you-hang-on-it': whatDoYouHangOnIt,
  'does-this-one-count': doesThisOneCount,
  'what-do-you-let-go': whatDoYouLetGo,
  'more-less-or-the-same': moreLessOrTheSame,
  'factored-or-service': factoredOrService,
  'which-one-controls': whichOneControls,
  'how-much-comes-off': howMuchComesOff,
  'what-the-height-means': whatTheHeightMeans,
  'which-line-is-it': whichLineIsIt,
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
  num top = 12,
}) => pickScreen(
  id: id,
  chapter: 'structural',
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
          gap(top),
          ...r.middle,
          {'choices': true, 'space': 8},
          ...feedbackAfter(14),
        ],
      ),
  ],
);

/// A drawing [h] high in the games' white panel (its height may differ
/// before and after the answer), then 10 below it the formula, set at
/// [size] in charcoal, or in grey ink as a centred line of text, and 12
/// more to the answers.
List<Map<String, Object?>> panelAndFormula(
  Draw Function(bool answered) draw,
  Object h, {
  required String formula,
  required num size,
  bool grey = false,
  required String what,
}) => [
  figure(draw, h, frame: 'panel', what: what),
  gap(10),
  if (grey)
    center(math(formula, size, color: 'ink3'))
  else
    {'math': formula, 'size': size},
  gap(12),
];

/// The white panel holding a drawing that follows the pick as well as
/// the answer (a mark lit as it is picked).
Node pickedPanel(
  Draw Function(int? pick, bool answered) paint,
  int answers,
  double h, {
  required String what,
}) => box(
  w: 'max',
  h: h,
  fill: 'white',
  radius: 12,
  border: 'line',
  child: clip(grid(draw(perPick(paint, answers, h - 2, what: what))), 11),
);

Map<String, Object?> enoughOrTooMany() => plainGame(
  id: 'enough-or-too-many',
  title: 'Enough or Too Many',
  closing:
      'Short of the requirement is a mechanism: it moves, and there is '
      'no solution to find. Exactly the requirement is determinate, and '
      'equilibrium alone finishes the job. Over it is indeterminate, '
      'and the excess is how many extra unknowns you have. Adding a '
      'support or a member raises the count; removing one lowers it, '
      'and one short is not a weak structure but a moving one.',
  overline: 'HOW DOES THE COUNT COME OUT',
  right: 'THAT IS HOW IT COMES OUT',
  wrong: 'NOT QUITE',
  brief: countBrief,
  briefName: 'countBrief',
  rounds: [
    for (final (i, r) in tallyRounds2.indexed)
      (
        subject: r.subject,
        setting: r.setting,
        options: [for (final o in Tally.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              SkeletonPainter(skeleton: r.skeleton, showCount: answered).paint,
          228,
          formula:
              r'$m + r \text{ vs } 2j \quad\quad 3m + r \text{ vs } 3j + c$',
          size: 13,
          what: 'enough-or-too-many round $i',
        ),
      ),
  ],
);

Map<String, Object?> theCountSaysYes() => plainGame(
  id: 'the-count-says-yes',
  title: 'The Count Says Yes',
  closing:
      'The count is necessary and never sufficient. It sees how many '
      'members, joints and reactions there are and it cannot see where '
      'they point. Reactions all parallel leave nothing to resist a '
      'load across them; reactions all through one point leave nothing '
      'to resist a turn about it. Extra restraint does not help either '
      'case, so an indeterminate structure can be just as unstable as a '
      'determinate one.',
  overline: 'WILL IT ACTUALLY STAND UP',
  right: 'THAT IS THE VERDICT',
  wrong: 'LOOK AGAIN',
  brief: stabilityBrief,
  briefName: 'stabilityBrief',
  rounds: [
    for (final (i, r) in standRounds.indexed)
      (
        subject: r.subject,
        setting: r.setting,
        options: [for (final o in WillItStand.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => SkeletonPainter(
            skeleton: r.skeleton,
            showCount: answered,
            showWhy: answered,
          ).paint,
          240,
          formula: r'$m + r = 2j \text{ is necessary, not sufficient}$',
          size: 13,
          what: 'the-count-says-yes round $i',
        ),
      ),
  ],
);

Map<String, Object?> whereDoYouTakeMoments() => plainGame(
  id: 'where-do-you-take-moments',
  title: 'Where Do You Take Moments',
  closing:
      'Put the pivot where the two members you do NOT want cross, and '
      'both of them fall out of the equation because neither has a '
      'lever arm about it. The point moves with the member you are '
      'after, and it can sit outside the piece of truss you kept. When '
      'the unwanted pair is the two chords of a parallel chord truss '
      'they never cross at all, and the vertical force equation is the '
      'way in instead.',
  overline: 'WHICH POINT KILLS THE OTHER TWO',
  right: 'THAT IS THE PIVOT',
  wrong: 'NOT THAT ONE',
  brief: momentCenterBrief,
  briefName: 'momentCenterBrief',
  rounds: [
    for (final (i, r) in pivotRounds.indexed)
      () {
        // The game's way of naming a point: 0 or 1, or none for neither.
        int? point(Pivot? p) => switch (p) {
          Pivot.first => 0,
          Pivot.second => 1,
          _ => null,
        };
        return (
          subject: r.subject,
          setting: r.asked,
          options: [for (final p in Pivot.values) r.label(p)],
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          middle: <Map<String, Object?>>[
            pickedPanel(
              (pick, answered) => SectionPointsPainter(
                truss: r.truss,
                cut: r.cut,
                target: r.target,
                anchors: r.anchors,
                picked: point(pick == null ? null : Pivot.values[pick]),
                answer: answered ? point(r.answer) : null,
                locked: answered,
              ).paint,
              Pivot.values.length,
              238,
              what: 'where-do-you-take-moments round $i',
            ),
            gap(10),
            {'math': r'$\sum M_{point} = 0$', 'size': 16},
            gap(12),
          ],
        );
      }(),
  ],
);

Map<String, Object?> biggerThanTheLoad() => plainGame(
  id: 'bigger-than-the-load',
  title: 'Bigger Than the Load',
  closing:
      'A diagonal carrying a load off a joint is always larger than '
      'the load, because only its vertical component is doing the '
      'carrying. The factor is one over the sine of the angle: 1.04 at '
      '75 degrees, 1.41 at 45, 1.67 on a three four five, and nearly '
      'six at 10 degrees. Steep is efficient, flat is expensive, and a '
      'member can never carry less than the load it is resolving.',
  overline: 'HOW BIG IS THE FORCE IN THE DIAGONAL',
  right: 'THAT IS THE SIZE OF IT',
  wrong: 'NOT THAT',
  brief: jointForceBrief,
  briefName: 'jointForceBrief',
  rounds: [
    for (final (i, r) in webRounds.indexed)
      (
        subject: r.subject,
        setting: r.setting,
        options: [for (final o in HowBig.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              CornerPainter(corner: r.corner, answered: answered).paint,
          240,
          formula: r'$F = \dfrac{P}{\sin\theta}$',
          size: 16,
          what: 'bigger-than-the-load round $i',
        ),
      ),
  ],
);

Map<String, Object?> jointsOrSections() => plainGame(
  id: 'joints-or-sections',
  title: 'Joints or Sections',
  closing:
      'One member deep in the truss wants a cut. Several members at '
      'one connection want joint equilibrium. Near a support the joints '
      'are quickest because the reaction is already there. And whatever '
      'the question, the support reactions come first, from the whole '
      'truss taken as one free body: neither method can start without '
      'them.',
  overline: 'WHAT WOULD YOU REACH FOR',
  right: 'THAT IS THE SHORT WAY',
  wrong: 'THE LONGER WAY',
  brief: trussRouteBrief,
  briefName: 'trussRouteBrief',
  rounds: [
    for (final (i, r) in routeRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Route3.values) o.plain],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: [
          figure(
            (_) =>
                SectionPointsPainter(truss: routeTruss, target: r.target).paint,
            214,
            frame: 'panel',
            what: 'joints-or-sections round $i',
          ),
          gap(14),
        ],
      ),
  ],
);

Map<String, Object?> whatDoYouHangOnIt() => plainGame(
  id: 'what-do-you-hang-on-it',
  title: 'What Do You Hang On It',
  closing:
      'The virtual load matches the quantity wanted, a force for a '
      'movement and a moment for a rotation, and it sits at the point '
      'wanted, pointing the way you want measured. It acts alone, in a '
      'second analysis with the real loads off, and the two sets of '
      'forces are multiplied together afterward. Every part of that is '
      'decided before a single number is worked out.',
  overline: 'WHAT GOES ON THE STRUCTURE',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: unitLoadBrief,
  briefName: 'unitLoadBrief',
  rounds: [
    for (final (i, r) in hangRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => ProbePainter(probe: r.probe, answered: answered).paint,
          askDone(172, 268),
          formula: r'$\delta = \sum \frac{n N L}{A E}$',
          size: 16,
          what: 'what-do-you-hang-on-it round $i',
        ),
      ),
  ],
);

Map<String, Object?> doesThisOneCount() => plainGame(
  id: 'does-this-one-count',
  title: 'Does This One Count',
  closing:
      'Either factor zero and the member is not in the sum at all, '
      'which is worth spotting early because it saves most of the work. '
      'Otherwise the two signs decide the direction: agreeing signs, '
      'including two compressions, push the joint the way the unit load '
      'points, and disagreeing signs pull it back. A negative total '
      'means the joint moved the other way, not that something went '
      'wrong.',
  overline: 'WHICH WAY DOES THIS TERM PUSH',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: termSignBrief,
  briefName: 'termSignBrief',
  rounds: [
    for (final (i, r) in termRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final a in Adds.values) TermRound.label(a)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) =>
              ContributionPainter(term: r.term, answered: answered).paint,
          200,
          formula: r'$\delta = \sum \frac{n N L}{A E}$',
          size: 16,
          what: 'does-this-one-count round $i',
        ),
      ),
  ],
);

Map<String, Object?> whatDoYouLetGo() => plainGame(
  id: 'what-do-you-let-go',
  title: 'What Do You Let Go',
  closing:
      'Release as many things as the count is over by, carry each one '
      'as an unknown, and pay for it with the movement the real support '
      'would not have allowed: a released force owes a deflection, a '
      'released moment owes a rotation. Which thing you release is your '
      'choice and the finished answer is the same either way. Then put '
      'the number back and let statics finish.',
  overline: 'WHAT DO YOU RELEASE',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: redundantBrief,
  briefName: 'redundantBrief',
  rounds: [
    for (final (i, r) in letGoRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => ReleasePainter(
            span: r.span,
            release: r.release,
            answered: answered,
          ).paint,
          askDone(158, 250),
          formula: r'$DSI = \text{unknowns} - 3$',
          size: 16,
          what: 'what-do-you-let-go round $i',
        ),
      ),
  ],
);

Map<String, Object?> moreLessOrTheSame() => plainGame(
  id: 'more-less-or-the-same',
  title: 'More, Less or the Same',
  closing:
      'Building an end in does three things and leaves one thing alone. '
      'It pulls load toward itself and away from the far end, it puts '
      'moment at the support and takes it out of the middle, and it '
      'cuts the sag. What it does not do is change the vertical split '
      'on a symmetric beam: half each, fixed or not. Every standard '
      'result in the lesson is one of those sentences with a number '
      'attached.',
  overline: 'AGAINST THE SIMPLE SPAN',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: fixityBrief,
  briefName: 'fixityBrief',
  rounds: [
    for (final (i, r) in compareRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final c in Change.values) CompareRound.label(c)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => SplitPainter(
            ends: r.ends,
            marked: r.marked,
            topNote: r.topNote,
            bottomNote: r.bottomNote,
            answered: answered,
          ).paint,
          236,
          formula:
              r'$\text{simple span: } R = \frac{wL}{2}, \; M = \frac{wL^2}{8}$',
          size: 15,
          what: 'more-less-or-the-same round $i',
        ),
      ),
  ],
);

Map<String, Object?> factoredOrService() => plainGame(
  id: 'factored-or-service',
  title: 'Factored or Service',
  closing:
      'Read the stem first. LRFD factors the loads up, dead by 1.2 '
      'because it is well known and live by 1.6 because it is not, and '
      'compares them with a design strength. Allowable stress design '
      'takes the loads exactly as they come and divides the strength '
      'instead. Both are allowed, both are safe, and the only way to go '
      'wrong is to take one half from each.',
  overline: 'WHICH CHECK IS IT',
  right: 'THAT IS THE CHECK',
  wrong: 'NOT THAT ONE',
  brief: lrfdBrief,
  briefName: 'lrfdBrief',
  top: 14,
  rounds: [
    for (final r in designRounds)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        // The two checks are the answer to half these rounds, so the game
        // shows them only once the round is over.
        middle: [
          box(
            w: 'max',
            pad: const [14, 12, 14, 12],
            fill: 'cream',
            radius: 10,
            border: 'line',
            cross: 'start',
            c: [
              t('THE TWO CHECKS', font: 'overline', color: 'ink3'),
              gapH(8),
              math(r'$\text{LRFD: } 1.2D + 1.6L \; \le \; \phi R_n$', 15),
              gapH(6),
              math(r'$\text{ASD: } D + L \; \le \; R_n / \Omega$', 15),
            ],
            when: 'done',
          ),
          gap(14, when: 'done'),
        ],
      ),
  ],
);

Map<String, Object?> whichOneControls() => plainGame(
  id: 'which-one-controls',
  title: 'Which One Controls',
  closing:
      'The big factor follows the big load. Floor live load ahead of '
      'the roof load and combination 2 wins; roof load ahead of the '
      'floor and combination 3 does; hardly any live load at all and '
      'the lonely 1.4 on the dead load beats them both. Read the shape '
      'of the loading first and the arithmetic is only there to confirm '
      'it.',
  overline: 'WHICH COMBINATION WINS',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: controlsBrief,
  briefName: 'controlsBrief',
  rounds: [
    for (final (i, r) in controlRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final c in Combo.values) ControlRound.label(c)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => LoadBarPainter(
            bundle: r.bundle,
            unit: r.unit,
            answered: answered,
          ).paint,
          askDone(
            40.0 + 20 * loadRows(r.bundle),
            90.0 + 20 * (loadRows(r.bundle) + 3),
          ),
          formula: r'$\text{the largest total is the one you design for}$',
          size: 13,
          grey: true,
          what: 'which-one-controls round $i',
        ),
      ),
  ],
);

Map<String, Object?> howMuchComesOff() => plainGame(
  id: 'how-much-comes-off',
  title: 'How Much Comes Off',
  closing:
      'The reduction is a bet that a big floor is never full '
      'everywhere at once, so the more floor a member carries the less '
      'of the load it has to be designed for. A column counts its area '
      'four times over and a beam twice. The bracket never becomes an '
      'increase, it stops at half the unreduced load for a single floor '
      'and four tenths for more than one, and it touches nothing but '
      'live load.',
  overline: 'WHAT COMES OFF THE LIVE LOAD',
  right: 'THAT IS RIGHT',
  wrong: 'NOT THAT ONE',
  brief: reductionBrief,
  briefName: 'reductionBrief',
  rounds: [
    for (final (i, r) in reduceRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => TributaryPainter(
            left: r.left,
            right: r.right,
            answered: answered,
          ).paint,
          190,
          formula: r'$L = L_o\left(0.25 + \frac{15}{\sqrt{K_{LL} A_T}}\right)$',
          size: 15,
          what: 'how-much-comes-off round $i',
        ),
      ),
  ],
);

Map<String, Object?> whatTheHeightMeans() => plainGame(
  id: 'what-the-height-means',
  title: 'What the Height Means',
  closing:
      'An influence line is one answer at one place, plotted against '
      'every position the moving load can take. Across is where the '
      'load is standing; up is the reaction, shear or moment at the '
      'fixed place the line was drawn for. It is not a picture of the '
      'beam and not a moment diagram, however alike they look. Once '
      'that is straight, using it is only multiplying and adding.',
  overline: 'READING THE LINE',
  right: 'THAT IS IT',
  wrong: 'NOT THAT ONE',
  brief: influenceBrief,
  briefName: 'influenceBrief',
  rounds: [
    for (final (i, r) in heightRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (answered) => InfluencePainter(
            line: r.line,
            loads: r.loads,
            showOrdinates: answered && r.loads.isNotEmpty,
          ).paint,
          212,
          formula: r'$R = \sum P_i \, \eta_i$',
          size: 16,
          what: 'what-the-height-means round $i',
        ),
      ),
  ],
);

Map<String, Object?> whichLineIsIt() => plainGame(
  id: 'which-line-is-it',
  title: 'Which Line Is It',
  closing:
      'Three shapes and no others. A straight run between one and '
      'nothing is a reaction, and the end it starts at names which. A '
      'triangle peaking over the section is the moment there. A line '
      'with a step of exactly one in it is the shear, and the step is '
      'the only sure way to tell a shear line from a moment line, since '
      'both of them are drawn about a section.',
  overline: 'WHAT IS THE LINE FOR',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: shapesBrief,
  briefName: 'shapesBrief',
  rounds: [
    for (final (i, r) in ilShapeRounds.indexed)
      (
        subject: r.subject,
        setting: r.asked,
        options: [for (final o in Response.values) LineShapeRound.label(o)],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        middle: panelAndFormula(
          (_) => InfluencePainter(line: r.line, named: false).paint,
          206,
          formula: r'$\text{one answer, at one place, as the load moves}$',
          size: 13,
          grey: true,
          what: 'which-line-is-it round $i',
        ),
      ),
  ],
);
