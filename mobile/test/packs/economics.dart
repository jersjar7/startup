import 'package:mobile/features/games/breakeven_figures.dart';
import 'package:mobile/features/games/cash_flow_figures.dart';
import 'package:mobile/features/games/do_they_agree_game.dart';
import 'package:mobile/features/games/how_long_to_compare_game.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/what_is_the_saving_game.dart';
import 'package:mobile/features/games/where_does_it_go_game.dart';
import 'package:mobile/features/games/which_bucket_game.dart';
import 'package:mobile/features/games/which_rate_game.dart';
import 'package:mobile/features/games/which_side_wins_game.dart';
import 'package:mobile/features/games/which_way_it_pushes_game.dart';

import 'builder.dart';
import 'pick_one_adapter.dart';

/// The Economics games, each laid out as its own screen of blocks (see the
/// pack's pick-one game). Most answer with the app's titled row: a title
/// with its condition written small beneath.

/// The shaded box the Economics games quote a problem in.
Map<String, Object?> shaded(String words, {num size = 15, num line = 1.45}) => {
  'box': [
    {'text': words, 'size': size, 'line': line},
  ],
  'pad': [14, 14, 14, 14],
  'fill': 'creamDark',
  'radius': 14,
  'border': false,
};

/// The titled answers, a gap of [space] between them, then once answered
/// a gap of 16 and the feedback.
List<Map<String, Object?>> titled({num space = 8}) => [
  {'choices': true, 'space': space},
  ...feedbackAfter(16),
];

Map<String, Object?> whichRate() => pickScreen(
  id: 'which-rate',
  chapter: 'economics',
  title: 'Which Rate',
  closing:
      'Three numbers, one label. The periodic rate goes beside a '
      'matching n, the effective rate is what a year actually costs and '
      'is the only one worth comparing across offers, and the quoted '
      'rate is the one on the paperwork and answers almost nothing.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT ONE',
  brief: briefJson(ratesBrief, 'ratesBrief'),
  rounds: [
    for (final r in rateRounds)
      (
        options: [for (final rate in Rate.values) r.valueOf(rate)],
        notes: const [
          'the periodic rate, one compounding period',
          'the nominal rate, as quoted',
          'the effective rate, what a year costs',
        ],
        tex: null,
        answer: Rate.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'THREE NUMBERS, ONE LABEL', 'color': 'ember'},
          gap(8),
          {
            'box': [
              {'code': r.quoted, 'size': 14},
            ],
            'pad': [12, 10, 12, 10],
            'fill': 'creamDark',
            'border': false,
          },
          gap(10),
          {'text': r.ask, 'size': 15.5},
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(16),
          ...titled(),
        ],
      ),
  ],
);

Map<String, Object?> doTheyAgree() => pickScreen(
  id: 'do-they-agree',
  chapter: 'economics',
  title: 'Do They Agree',
  closing:
      'The three methods are one comparison on three clocks and they '
      'cannot disagree about the same alternatives, over the same '
      'period, at the same rate. When they do, one of those three was '
      'not actually the same.',
  right: 'THAT IS WHY',
  wrong: 'SOMETHING ELSE',
  brief: briefJson(methodsAgreeBrief, 'methodsAgreeBrief'),
  rounds: [
    for (final r in agreeRounds)
      (
        options: const [
          'Nothing can. Somebody slipped.',
          'They covered different periods',
          'They used different rates',
        ],
        notes: const [
          'same alternatives, period and rate',
          'unequal lives, compared as they stand',
          'a present worth is a number at a rate',
        ],
        tex: null,
        answer: Cause.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'WHY DO THEY DISAGREE', 'color': 'ember'},
          gap(10),
          shaded(r.report, line: 1.5),
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(16),
          ...titled(),
        ],
      ),
  ],
);

Map<String, Object?> whereDoesItGo() => pickScreen(
  id: 'where-does-it-go',
  chapter: 'economics',
  title: 'Where Does It Go',
  closing:
      'Benefits and disbenefits are what happens to the public and live '
      'on top; costs are what the agency spends and live underneath, '
      'operating costs included. A disbenefit comes off the benefits '
      'rather than joining the costs, and the two are different '
      'divisions.',
  right: 'THAT IS WHERE',
  wrong: 'SOMEWHERE ELSE',
  brief: briefJson(ratioBrief, 'ratioBrief'),
  rounds: [
    for (final r in slotRounds)
      (
        options: const [
          'A benefit, on top',
          'A disbenefit, taken off the top',
          'A cost, underneath',
        ],
        notes: const [
          'value to the public',
          'harm to the public',
          'money the agency spends',
        ],
        tex: null,
        answer: Slot.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'WHERE IN THE RATIO', 'color': 'ember'},
          gap(10),
          shaded(r.item),
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(16),
          ...titled(),
        ],
      ),
  ],
);

Map<String, Object?> whichWayItPushes() => pickScreen(
  id: 'which-way-it-pushes',
  chapter: 'economics',
  title: 'Which Way It Pushes',
  closing:
      'Costs push the annual figure up and money coming back pushes it '
      'down, salvage included. And anything already spent, whichever way '
      'the decision goes, does not belong in the comparison at all.',
  right: 'THAT WAY',
  wrong: 'THE OTHER WAY',
  brief: briefJson(annualCostBrief, 'annualCostBrief'),
  rounds: [
    for (final r in pushRounds)
      (
        options: const ['Up', 'Down', 'Neither. It stays out.'],
        notes: const [
          'a cost inside the life',
          'money coming back',
          'already spent, whatever is decided',
        ],
        tex: null,
        answer: Push.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'WHICH WAY DOES THE ANNUAL COST MOVE', 'color': 'ember'},
          gap(10),
          shaded(r.item, size: 15.5),
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(16),
          ...titled(),
        ],
      ),
  ],
);

Map<String, Object?> howLongToCompare() => pickScreen(
  id: 'how-long-to-compare',
  chapter: 'economics',
  title: 'How Long to Compare Over',
  closing:
      'Present worth prices a period, so the period has to be the same '
      'one for both. Equal lives need nothing; unequal lives need '
      'repeating until they end together. Annual worth is a rate and '
      'sidesteps the whole business.',
  right: 'THAT PERIOD',
  wrong: 'NOT THAT ONE',
  brief: briefJson(studyPeriodBrief, 'studyPeriodBrief'),
  rounds: [
    for (final (n, r) in studyRounds.indexed)
      (
        options: const [
          'Their own life',
          'Repeat until they end together',
          'It does not matter. Use annual worth.',
        ],
        notes: const [
          'they already cover the same period',
          'the least common multiple of the two lives',
          'a rate compares to a rate',
        ],
        tex: null,
        answer: Study.values.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'OVER WHAT PERIOD', 'color': 'ember'},
          gap(8),
          {'text': r.setting},
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(12),
          figure(
            (answered) => LivesPainter(
              lifeA: r.lifeA,
              lifeB: r.lifeB,
              span: r.span,
              nameA: r.nameA,
              nameB: r.nameB,
              bracket: answered && r.answer == Study.multiple
                  ? r.multiple
                  : null,
            ).paint,
            120,
            frame: 'clip',
            radius: 16,
            what: 'how-long-to-compare round $n',
          ),
          gap(14),
          ...titled(),
        ],
      ),
  ],
);

Map<String, Object?> whichSideWins() => pickScreen(
  id: 'which-side-wins',
  chapter: 'economics',
  title: 'Which Side Wins',
  closing:
      'Below the crossing the cheap start wins and above it the cheap '
      'rate does. Comparing the per unit rates on their own ignores '
      'where each line starts, and when one option starts higher and '
      'rises faster there is no crossing to find at all.',
  right: 'CHEAPER THERE',
  wrong: 'THE OTHER SIDE',
  brief: briefJson(breakEvenBrief, 'breakEvenBrief'),
  rounds: [
    for (final (n, r) in winsRounds.indexed)
      (
        options: [r.lines[0].name, r.lines[1].name, 'They cost the same'],
        notes: [
          describeSide(r, 0),
          describeSide(r, 1),
          'the marked volume is the crossing',
        ],
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'CHEAPER AT THE MARKED VOLUME', 'color': 'ember'},
          gap(8),
          {'text': r.setting},
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(12),
          figure(
            (answered) => BreakEvenPainter(
              lines: r.lines,
              qTo: r.qTo,
              at: r.at,
              revealed: answered,
            ).paint,
            190,
            frame: 'clip',
            radius: 16,
            what: 'which-side-wins round $n',
          ),
          gap(14),
          ...titled(),
        ],
      ),
  ],
);

Map<String, Object?> whatIsTheSaving() => pickScreen(
  id: 'what-is-the-saving',
  chapter: 'economics',
  title: 'What Is the Saving',
  closing:
      'Everything coming in, less everything new going out, and only the '
      'part that repeats every year. If the new cost is bigger than the '
      'saving there is no payback period, whatever a formula hands back.',
  right: 'THAT ONE',
  wrong: 'A DIFFERENT ONE',
  brief: briefJson(paybackBrief, 'paybackBrief'),
  rounds: [
    for (final r in savingRounds)
      (
        options: [for (final o in r.options) o.$1],
        notes: [for (final o in r.options) o.$2],
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'WHAT GOES UNDERNEATH', 'color': 'ember'},
          gap(8),
          {'text': r.scenario},
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(14),
          ...titled(),
        ],
      ),
  ],
);

Map<String, Object?> whichBucket() => pickScreen(
  id: 'which-bucket',
  chapter: 'economics',
  title: 'Which Bucket',
  closing:
      'Fixed is where the line starts and variable is how steeply it '
      'rises. Sunk is already gone and stays out. Opportunity cost never '
      'appears on an invoice and belongs in anyway, and marginal is the '
      'next unit rather than the average of them all.',
  right: 'THAT BUCKET',
  wrong: 'A DIFFERENT BUCKET',
  brief: briefJson(costTypesBrief, 'costTypesBrief'),
  rounds: [
    for (final r in bucketRounds)
      (
        options: [for (final b in buckets) b.$1],
        notes: [for (final b in buckets) b.$2],
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'WHAT KIND OF COST IS THIS', 'color': 'ember'},
          gap(10),
          shaded(r.cost),
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(14),
          ...titled(space: 7),
        ],
      ),
  ],
);

final adapters = <String, Map<String, Object?> Function()>{
  'which-rate': whichRate,
  'do-they-agree': doTheyAgree,
  'where-does-it-go': whereDoesItGo,
  'which-way-it-pushes': whichWayItPushes,
  'how-long-to-compare': howLongToCompare,
  'which-side-wins': whichSideWins,
  'what-is-the-saving': whatIsTheSaving,
  'which-bucket': whichBucket,
};
