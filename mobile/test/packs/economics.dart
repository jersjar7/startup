import 'package:mobile/features/games/balance_the_rate_game.dart';
import 'package:mobile/features/games/breakeven_figures.dart';
import 'package:mobile/features/games/cash_flow_figures.dart';
import 'package:mobile/features/games/do_they_agree_game.dart';
import 'package:mobile/features/games/how_long_to_compare_game.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/games/irr_figures.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/match_the_dollars_game.dart';
import 'package:mobile/features/games/what_is_the_saving_game.dart';
import 'package:mobile/features/games/where_does_it_go_game.dart';
import 'package:mobile/features/games/which_bucket_game.dart';
import 'package:mobile/features/games/which_earns_more_game.dart';
import 'package:mobile/features/games/which_factor_game.dart';
import 'package:mobile/features/games/which_rate_game.dart';
import 'package:mobile/features/games/which_one_do_you_build_game.dart';
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

/// Answers that tint when picked, one row of cells each (see the pack's
/// pick-one tiles).
Map<String, Object?> tiles(
  List<List<Map<String, Object?>>> each, {
  required List<num> pad,
  num radius = 12,
  num? h,
  bool center = false,
  bool row = false,
  num space = 8,
}) => {
  'tiles': each,
  'pad': pad,
  'radius': radius,
  'h': ?h,
  'center': center,
  'row': row,
  'space': space,
};

Map<String, Object?> matchTheDollars() {
  String label(Adjust a) => switch (a) {
    Adjust.inflationOnly => 'the inflation rate',
    Adjust.real => 'the real rate',
    Adjust.sum => 'the two rates added',
    Adjust.combined => 'the two rates compounded',
  };
  String n(double v) => v.toStringAsFixed(0);
  return pickScreen(
    id: 'match-the-dollars',
    chapter: 'economics',
    title: 'Match the Dollars',
    closing:
        'Match the rate to the dollars. Money that will really change '
        'hands has inflation in it and meets the compounded rate; figures '
        'written in today\'s purchasing power have had it removed and meet '
        'the real one. And the compounded rate has three terms, not two.',
    right: 'THAT RATE',
    wrong: 'A DIFFERENT RATE',
    brief: briefJson(inflationBrief, 'inflationBrief'),
    rounds: [
      for (final r in dollarsRounds)
        (
          options: [for (final a in r.order) label(a)],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: [
            ...heading('DISCOUNT AT WHICH RATE', r.subject, r.situation),
            gap(14),
            tiles(
              [
                for (final a in r.order)
                  [
                    {'text': label(a), 'size': 14.5, 'fill': true},
                    {'code': '${r.valueOf(a).toStringAsFixed(2)}%', 'size': 14},
                  ],
              ],
              pad: [14, 0, 14, 0],
              h: 54,
            ),
            gap(16, when: 'done'),
            {
              'overline': r.actual ? 'ACTUAL DOLLARS' : 'CONSTANT DOLLARS',
              'color': 'ink3',
              'when': 'done',
            },
            gap(4, when: 'done'),
            {
              'code': r.actual
                  ? 'd = ${n(r.real)} + ${n(r.inflation)} + '
                        '${n(r.real)}(${n(r.inflation)})/100 = '
                        '${r.valueOf(Adjust.combined).toStringAsFixed(2)}%'
                  : 'i = ${r.real.toStringAsFixed(2)}%, and inflation stays '
                        'out of it',
              'size': 12,
              'when': 'done',
            },
            ...feedbackAfter(14),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichFactor() => pickScreen(
  id: 'which-factor',
  chapter: 'economics',
  title: 'Which Factor',
  closing:
      'Read the picture, not the words. What have you got, a single '
      'amount or an equal series, and which do you want instead. The two '
      'that get swapped are the sinking fund and capital recovery, and '
      'the difference is whether the known amount is at the end or in '
      'your hand.',
  right: 'THAT IS THE ONE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(factorsBrief, 'factorsBrief'),
  rounds: [
    for (final (n, r) in factorRounds.indexed)
      (
        options: [for (final f in factors) f.$1],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'SOLID IS WHAT YOU HAVE', 'color': 'ember'},
          gap(8),
          {'text': r.scenario},
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(12),
          figure(
            (_) => CashFlowPainter(
              flows: r.flows,
              periods: r.periods,
              unit: r.unit,
            ).paint,
            160,
            frame: 'clip',
            radius: 16,
            what: 'which-factor round $n',
          ),
          gap(12),
          tiles(
            [
              for (final f in factors)
                [
                  {'tex': f.$1, 'size': 14, 'w': 96},
                  {'gap': 6},
                  {'mono': f.$2, 'size': 10.5, 'color': 'ink3', 'fill': true},
                ],
            ],
            pad: [14, 9, 14, 9],
            space: 7,
          ),
          ...feedbackAfter(16),
        ],
      ),
  ],
);

Map<String, Object?> whichEarnsMore() {
  String pct(double i) => '${(i * 100).toStringAsFixed(1)}%';
  return pickScreen(
    id: 'which-earns-more',
    chapter: 'economics',
    title: 'Which Earns More',
    closing:
        'A rate is not a total. Money that comes back sooner earns more '
        'than the same money later, a smaller stake can earn more than a '
        'larger one, and doubling every figure in a project leaves its '
        'return exactly where it was.',
    right: 'THAT ONE',
    wrong: 'THE OTHER READING',
    brief: briefJson(timingBrief, 'timingBrief'),
    rounds: [
      for (final (n, r) in earnsRounds.indexed)
        (
          options: const ['The first', 'The second', 'The same'],
          notes: null,
          tex: null,
          answer: Earns.values.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            ...heading('WHICH RATE IS HIGHER', r.subject, r.situation),
            gap(12),
            for (final (i, project) in [r.first, r.second].indexed) ...[
              if (i > 0) gap(8),
              {
                'overline': i == 0 ? 'THE FIRST' : 'THE SECOND',
                'color': 'ink3',
              },
              gap(4),
              figure(
                (_) => DealPainter(
                  project: project,
                  periods: r.periods,
                  scale: r.scale,
                  color: AppColors.charcoal,
                ).paint,
                126,
                frame: 'clip',
                radius: 14,
                what: 'which-earns-more round $n, deal $i',
              ),
            ],
            gap(14),
            tiles(
              [
                for (final o in const ['The first', 'The second', 'The same'])
                  [
                    {'text': o, 'size': 14.5, 'one': true},
                  ],
              ],
              pad: [4, 0, 4, 0],
              h: 54,
              center: true,
              row: true,
            ),
            gap(16, when: 'done'),
            {'overline': 'WHAT THEY EARN', 'color': 'ink3', 'when': 'done'},
            gap(4, when: 'done'),
            {
              'code':
                  'the first    ${pct(r.first.irr)}\n'
                  'the second   ${pct(r.second.irr)}',
              'size': 12,
              'when': 'done',
            },
            ...feedbackAfter(14),
          ],
        ),
    ],
  );
}

Map<String, Object?> balanceTheRate() {
  String money(double v) {
    final s = v.round().toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }

  return pickScreen(
    id: 'balance-the-rate',
    chapter: 'economics',
    title: 'Balance the Rate',
    closing:
        'A rate of return is the rate at which what comes in is worth '
        'exactly what goes out. At zero percent the bars are the plain '
        'totals, which is why the total is not the return. Raise the rate '
        'and later money shrinks. Where the ends meet, the net present '
        'worth is zero.',
    right: 'THEY MEET',
    wrong: 'NOT THERE',
    brief: briefJson(irrBrief, 'irrBrief'),
    rounds: [
      for (final (n, r) in meetRounds.indexed)
        (
          options: [for (final s in r.stops) '$s%'],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: [
            ...heading('MAKE THE ENDS MEET', r.subject, r.situation),
            gap(12),
            // The bars are drawn at the rate being tried: the first stop
            // until one is picked.
            for (final (i, rate) in [null, ...r.stops].indexed)
              {
                ...figure(
                  (settled) => BalancePainter(
                    project: r.project,
                    rate: (rate ?? r.stops.first) / 100,
                    reference: r.reference,
                    settled: settled,
                  ).paint,
                  110,
                  frame: 'clip',
                  radius: 16,
                  what: 'balance-the-rate round $n, rate ${rate ?? 'none'}',
                ),
                'when': rate == null ? 'none' : 'chosen',
                if (rate != null) 'of': [i - 1],
              },
            gap(6),
            {
              'mono': 'shown at ${r.stops.first} percent. try a rate.',
              'size': 11,
              'color': 'ink3',
              'when': 'none',
            },
            for (final (i, rate) in r.stops.indexed)
              {
                'mono': 'trying $rate percent',
                'size': 11,
                'color': 'ink3',
                'when': 'chosen',
                'of': [i],
              },
            gap(12),
            tiles(
              [
                for (final s in r.stops)
                  [
                    {'code': '$s%', 'size': 13},
                  ],
              ],
              pad: [0, 0, 0, 0],
              radius: 10,
              h: 52,
              center: true,
              row: true,
              space: 6,
            ),
            gap(16, when: 'done'),
            {'overline': 'WHERE IT BALANCES', 'color': 'ink3', 'when': 'done'},
            gap(4, when: 'done'),
            for (final (stop, color) in [
              (r.stops[r.answer], 'charcoal'),
              (r.stops.first, 'ink3'),
            ])
              {
                'code':
                    'at $stop%   in ${money(r.project.pwIn(stop / 100))}'
                    '   out ${money(r.project.pwOut(stop / 100))}',
                'size': 12,
                'color': color,
                'when': 'done',
              },
            ...feedbackAfter(14),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichOneDoYouBuild() => pickScreen(
  id: 'which-one-do-you-build',
  chapter: 'economics',
  title: 'Which One Do You Build',
  closing:
      'Rank them by cost and ask of each step whether the extra benefit '
      'covers the extra cost. The highest individual ratio belongs to '
      'the cheapest option almost every time and is almost never the '
      'answer. An option that cannot clear one on its own is out before '
      'the comparison begins.',
  right: 'BUILD THAT ONE',
  wrong: 'NOT THAT ONE',
  brief: briefJson(incrementalBrief, 'incrementalBrief'),
  rounds: [
    for (final r in buildRounds)
      (
        options: [for (final o in r.options) o.name],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'MUTUALLY EXCLUSIVE. BUILD ONE.', 'color': 'ember'},
          gap(6),
          {'mono': r.subject, 'size': 11.5, 'color': 'ink3'},
          gap(2),
          {'mono': r.units, 'size': 10.5, 'color': 'ink3'},
          gap(12),
          {
            'box': [
              {
                'row': [
                  {'gap': 74},
                  for (final label in ['cost', 'benefit', 'B/C'])
                    {'overline': label, 'color': 'ink3', 'mid': true},
                ],
              },
              for (final o in r.options) ...[
                {'rule': 5},
                {
                  'row': [
                    {'code': o.name, 'size': 12.5, 'w': 74},
                    for (final v in [
                      o.cost.toStringAsFixed(0),
                      o.benefit.toStringAsFixed(0),
                      o.ratio.toStringAsFixed(2),
                    ])
                      {'code': v, 'size': 12.5, 'mid': true},
                  ],
                },
              ],
            ],
            'pad': [12, 8, 12, 8],
          },
          gap(14),
          tiles(
            [
              for (final o in r.options)
                [
                  {'text': o.name, 'size': 14.5, 'one': true},
                ],
            ],
            pad: [4, 0, 4, 0],
            h: 54,
            center: true,
            row: true,
          ),
          gap(16, when: 'done'),
          {
            'overline': 'WHAT THE ANALYSIS ASKED',
            'color': 'ink3',
            'when': 'done',
          },
          gap(4, when: 'done'),
          for (final step in r.steps) ...[
            {'code': step, 'size': 12, 'when': 'done'},
            gap(3, when: 'done'),
          ],
          ...feedbackAfter(14),
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
  'match-the-dollars': matchTheDollars,
  'which-factor': whichFactor,
  'which-earns-more': whichEarnsMore,
  'balance-the-rate': balanceTheRate,
  'which-one-do-you-build': whichOneDoYouBuild,
};
