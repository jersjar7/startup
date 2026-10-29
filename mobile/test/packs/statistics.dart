import 'package:mobile/features/games/add_the_squares_game.dart';
import 'package:mobile/features/games/build_the_binomial_game.dart';
import 'package:mobile/features/games/dot_plot_figures.dart';
import 'package:mobile/features/games/mind_the_order_game.dart';
import 'package:mobile/features/games/read_the_line_game.dart';
import 'package:mobile/features/games/what_weights_game.dart';
import 'package:mobile/features/games/which_readout_game.dart';
import 'package:mobile/features/games/expectation_figures.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/how_do_they_sit_game.dart';
import 'package:mobile/features/games/how_many_samples_game.dart';
import 'package:mobile/features/games/interval_figures.dart';
import 'package:mobile/features/games/normal_figures.dart';
import 'package:mobile/features/games/r_or_r2_game.dart';
import 'package:mobile/features/games/read_the_scatter_game.dart';
import 'package:mobile/features/games/reject_or_not_game.dart';
import 'package:mobile/features/games/same_pick_game.dart';
import 'package:mobile/features/games/scatter_figures.dart';
import 'package:mobile/features/games/shade_the_tail_game.dart';
import 'package:mobile/features/games/test_figures.dart';
import 'package:mobile/features/games/through_the_means_game.dart';
import 'package:mobile/features/games/venn_figures.dart';
import 'package:mobile/features/games/what_goes_under_game.dart';
import 'package:mobile/features/games/where_it_balances_game.dart';
import 'package:mobile/features/games/which_cell_hurts_game.dart';
import 'package:mobile/features/games/which_way_points_game.dart';
import 'package:mobile/features/games/wider_or_narrower_game.dart';

import 'package:flutter/material.dart' hide Path, TextPainter;
import 'package:mobile/core/theme/app_colors.dart';

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';

/// The Statistics games. Nearly every one has its own layout, so their
/// screens are written as screen nodes (see nodes.dart), the same widgets
/// the built-in games use.

/// The usual close of a round: once answered, a gap and the feedback.
List<Map<String, Object?>> feedback([num space = 16]) => feedbackAfter(space);

/// The question in the games' 16 point body text.
Map<String, Object?> ask(String words, {num size = 16}) => {
  'text': words,
  'size': size,
};

Map<String, Object?> overline(String words) => {
  'overline': words,
  'color': 'ember',
};

Map<String, Object?> subject(String words) => {
  'mono': words,
  'size': 11.5,
  'color': 'ink3',
};

/// A formula on the shaded strip the games quote one on.
Node formula(
  String latex,
  num size, {
  List<num> pad = const [12, 10, 12, 10],
}) => box(
  w: 'max',
  pad: pad,
  fill: 'creamDark',
  radius: 12,
  child: tex(latex, size),
);

/// The games' short answer buttons in a row, each a few words in [font].
Node buttons(
  List<String> options, {
  String font = 'code',
  num size = 13,
  num h = 54,
  num pad = 4,
  num radius = 12,
  num space = 8,
  bool one = true,
}) => answerRow([
  for (final (i, o) in options.indexed)
    tinted(
      i,
      t(o, font: font, size: size, one: one),
      h: h,
      pad: [pad, 0, pad, 0],
      align: 'center',
      radius: radius,
    ),
], space: space);

/// The games' answers one under another, [space] apart.
List<Node> stacked(List<Node> answers, {num space = 8}) => [
  for (final (i, a) in answers.indexed) ...[if (i > 0) gapH(space), a],
];

/// A drawing that follows the pick: one per answer, and one with nothing
/// picked, before the answer and after it.
Map<String, Object?> perPick(
  Draw Function(int? pick, bool answered) draw,
  int answers,
  double h, {
  required String what,
}) => {
  'ask': {
    'none': record(draw(null, false), h, what: '$what nothing picked'),
    'pick': [
      for (var i = 0; i < answers; i++)
        record(draw(i, false), h, what: '$what pick $i'),
    ],
  },
  'done': {
    'pick': [
      for (var i = 0; i < answers; i++)
        record(draw(i, true), h, what: '$what answered $i'),
    ],
  },
};

Map<String, Object?> doneOverline(String words) => {
  'overline': words,
  'color': 'ink3',
  'when': 'done',
};

Map<String, Object?> addTheSquares() => pickScreen(
  id: 'add-the-squares',
  chapter: 'statistics',
  title: 'Add the Squares',
  closing:
      'Variances add, standard deviations do not. Square them, add them, '
      'and take the root at the end, and any coefficient gets squared on '
      'the way through.',
  right: 'THAT IS THE ONE',
  wrong: 'NOT THAT ONE',
  brief: briefJson(combiningBrief, 'combiningBrief'),
  rounds: [
    for (final (i, r) in squaresRounds.indexed)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('TWO INDEPENDENT SPREADS'),
          gap(8),
          ask(r.ask),
          gap(6),
          subject(r.subject),
          gap(12),
          formula(r.combination, 16),
          gap(12),
          pictured(
            record(
              (canvas, size) => SigmaTrianglePainter(
                a: r.legA,
                b: r.legB,
                aLabel: r.aLabel,
                bLabel: r.bLabel,
                showHypotenuse: true,
              ).paint(canvas, size),
              240,
              what: 'add-the-squares round $i',
            ),
            240,
          ),
          gap(14),
          buttons(r.options),
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> howDoTheySit() {
  const titles = [
    'They cannot both happen',
    'One does not affect the other',
    'One changes the odds of the other',
  ];
  const notes = [
    'mutually exclusive, so nothing to subtract',
    'independent, so the two just multiply',
    'dependent, so the second one is conditional',
  ];
  Node event(String letter, String words, String fill) => box(
    w: 'max',
    pad: [14, 12, 14, 12],
    fill: fill,
    radius: 12,
    child: row([
      t(letter, font: 'mono', size: 13, color: 'ink3'),
      gapW(12),
      flex(t(words, size: 15)),
    ]),
  );
  return pickScreen(
    id: 'how-do-they-sit',
    chapter: 'statistics',
    title: 'How Do They Sit',
    closing:
        'Two questions, asked in this order. Could both happen at once? If '
        'not they are exclusive and their probabilities simply add. If so, '
        'does the first change the odds of the second? If not you may '
        'multiply them straight out, and if so you need the conditional. '
        'Exclusive and independent are not two words for one idea. They '
        'are opposites.',
    right: 'THAT IS HOW THEY SIT',
    wrong: 'NOT QUITE',
    brief: briefJson(lawsBrief, 'lawsBrief'),
    rounds: [
      for (final (n, r) in linkRounds.indexed)
        (
          options: titles,
          notes: null,
          tex: null,
          answer: Link.values.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            overline('HOW DO THESE TWO SIT TOGETHER'),
            gap(6),
            subject(r.subject),
            gap(12),
            event('A', r.first, 'emberBg'),
            gap(8),
            event('B', r.second, 'sunbeamBg'),
            gap(12, when: 'done'),
            pictured(
              record(
                (canvas, size) => VennPainter(
                  link: r.answer,
                  left: 'A',
                  right: 'B',
                ).paint(canvas, size),
                175,
                what: 'how-do-they-sit round $n',
              ),
              175,
              when: 'done',
            ),
            gap(12),
            ...stacked([
              for (var i = 0; i < titles.length; i++)
                tinted(
                  i,
                  col(
                    [
                      t(titles[i], size: 15, bold: true),
                      gapH(2),
                      t(notes[i], font: 'mono', size: 10.5, color: 'ink3'),
                    ],
                    main: 'center',
                    cross: 'start',
                  ),
                  minH: 58,
                  pad: [14, 8, 14, 8],
                  align: 'left',
                ),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> howManySamples() => pickScreen(
  id: 'how-many-samples',
  chapter: 'statistics',
  title: 'How Many Samples',
  closing:
      'The margin falls with the root of n, so halving it costs four '
      'times the samples and a third of it costs nine times. And the '
      'answer always rounds UP: a sample size that misses the spec is not '
      'a sample size.',
  right: 'THAT IS ENOUGH',
  wrong: 'NOT ENOUGH',
  brief: briefJson(sampleSizeBrief, 'sampleSizeBrief'),
  rounds: [
    for (final (n, r) in sizeRounds.indexed)
      (
        options: [for (final c in r.candidates) '$c'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('GET UNDER THE LINE'),
          gap(8),
          ask(r.ask, size: 15.5),
          gap(6),
          subject(r.subject),
          gap(12),
          pictured(
            perPick(
              (pick, answered) =>
                  (canvas, size) => MarginCurvePainter(
                    k: r.k,
                    target: r.target,
                    candidates: r.candidates,
                    nFrom: r.from,
                    nTo: (r.from + (r.candidates.last - r.from) * 1.18).round(),
                    picked: pick,
                    truth: answered ? r.answer : null,
                    revealed: answered,
                  ).paint(canvas, size),
              r.candidates.length,
              230,
              what: 'how-many-samples round $n',
            ),
            230,
          ),
          gap(14),
          buttons(
            [for (final c in r.candidates) '$c'],
            size: 16,
            pad: 0,
            one: false,
          ),
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> rOrR2() => pickScreen(
  id: 'r-or-r2',
  chapter: 'statistics',
  title: 'Which One Do They Want',
  closing:
      'Correlation is r and carries a sign. Determination is r squared, '
      'is always positive, and is the share of the variation explained. '
      'The exam asks for them in English, so the reading is the work.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT ONE',
  brief: briefJson(determinationBrief, 'determinationBrief'),
  rounds: [
    for (final r in rRounds)
      (
        options: [for (final o in r.options) o.value],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('THE REGRESSION IS ALREADY DONE'),
          gap(8),
          ask(r.ask),
          gap(12),
          formula(r.given, 17, pad: const [12, 14, 12, 14]),
          gap(14),
          ...stacked([
            for (final (i, o) in r.options.indexed)
              tinted(
                i,
                row([
                  box(w: 76, child: t(o.value, font: 'code', size: 16)),
                  flex(
                    t(
                      askDone('', o.meaning),
                      font: 'mono',
                      size: 10.5,
                      color: 'ink3',
                    ),
                  ),
                ]),
                pad: [16, 12, 16, 12],
              ),
          ]),
          ...feedback(),
        ],
      ),
  ],
);

String _writeR(double r) => r == 0
    ? 'about 0'
    : '${r > 0 ? '+' : '−'}${r.abs() == 1 ? '1' : r.abs().toString()}';

Map<String, Object?> readTheScatter() => pickScreen(
  id: 'read-the-scatter',
  chapter: 'statistics',
  title: 'Read the Scatter',
  closing:
      'The lean gives the sign and the tightness gives the size. And r '
      'only ever measures how well a STRAIGHT line fits, so a cloud can '
      'have an obvious shape and a correlation of nothing.',
  right: 'THAT IS THE READ',
  wrong: 'NOT THAT ONE',
  brief: briefJson(correlationBrief, 'correlationBrief'),
  rounds: [
    for (final (n, r) in scatterRounds.indexed)
      (
        options: [for (final c in rChoices) _writeR(c)],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('THE LEAN AND THE TIGHTNESS'),
          gap(8),
          ask('Which correlation is this closest to?'),
          gap(6),
          subject(r.subject),
          gap(12),
          pictured(
            record(
              (canvas, size) => ScatterPainter(
                points: r.points,
                xTo: r.xTo,
                yTo: r.yTo,
              ).paint(canvas, size),
              250,
              what: 'read-the-scatter round $n',
            ),
            250,
          ),
          gap(14),
          buttons(
            [for (final c in rChoices) _writeR(c)],
            font: 'mono',
            pad: 2,
            radius: 10,
            space: 6,
            one: false,
          ),
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> rejectOrNot() => pickScreen(
  id: 'reject-or-not',
  chapter: 'statistics',
  title: 'Reject or Not',
  closing:
      'Bigger than the critical value means reject, for z, for t and for '
      'chi-square alike. And failing to reject is never a finding: it '
      'says the data did not catch the null out, not that the null is '
      'true.',
  right: 'THAT IS THE CALL',
  wrong: 'NOT THAT ONE',
  brief: briefJson(decisionRuleBrief, 'decisionRuleBrief'),
  rounds: [
    for (final (n, r) in verdictRounds.indexed)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('THE ARITHMETIC IS DONE'),
          gap(8),
          ask('What is the correct conclusion?'),
          gap(6),
          subject(r.subject),
          gap(12),
          pictured(
            record(
              (canvas, size) => ScalePainter(
                statistic: r.statistic,
                critical: r.critical,
                twoTailed: r.twoTailed,
                to: r.to,
                statLabel: r.statLabel,
                critLabel: r.critLabel,
              ).paint(canvas, size),
              120,
              what: 'reject-or-not round $n',
            ),
            120,
          ),
          gap(8),
          {'mono': r.setup, 'size': 11, 'color': 'ink3'},
          gap(12),
          ...stacked([
            for (final (i, o) in r.options.indexed)
              tinted(i, t(o, size: 14, line: 1.4), pad: [14, 12, 14, 12]),
          ]),
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> samePick() {
  Node outcome(String label, List<String> names, List<String> slots) => box(
    w: 'max',
    pad: [12, 10, 12, 10],
    fill: 'white',
    radius: 12,
    border: 'line',
    cross: 'start',
    c: [
      t(label, font: 'overline', color: 'ink3'),
      gapH(8),
      row([
        for (var i = 0; i < names.length; i++) ...[
          if (i > 0) gapW(6),
          flex(
            col([
              // A round with nothing to say about the places shows none.
              if (slots.isNotEmpty)
                t(
                  slots[i],
                  font: 'mono',
                  size: 9,
                  color: 'ember',
                  one: true,
                  when: 'done',
                ),
              gapH(2),
              box(
                w: 'max',
                pad: [0, 8, 0, 8],
                fill: 'creamDark',
                radius: 8,
                child: center(
                  t(names[i], font: 'code', size: 12, one: true),
                  wf: 1,
                ),
              ),
            ]),
          ),
        ],
      ]),
    ],
  );
  const options = ['The same result, counted once', 'Two different results'];
  return pickScreen(
    id: 'same-pick',
    chapter: 'statistics',
    title: 'Same Pick, or Not',
    closing:
        'Nothing about the names decides it. Ask whether the scenario '
        'counts the same picks in another order as a second result: if it '
        'does, order matters and it is nPr, and if it does not, it is nCr.',
    right: 'THAT IS IT',
    wrong: 'THE OTHER WAY',
    brief: briefJson(countingBrief, 'countingBrief'),
    rounds: [
      for (final r in pickRounds)
        (
          options: options,
          notes: null,
          tex: null,
          answer: r.ordered ? 1 : 0,
          why: r.why,
          source: r.source,
          screen: [
            overline('ONE RESULT, OR TWO'),
            gap(8),
            ask(r.scenario, size: 15.5),
            gap(14),
            outcome('ONE OUTCOME', r.first, r.slots),
            gap(8),
            outcome('ANOTHER OUTCOME', r.second, r.slots),
            gap(16),
            ...stacked([
              for (final (i, o) in options.indexed)
                tinted(
                  i,
                  t(o, size: 15),
                  h: 54,
                  pad: [16, 0, 16, 0],
                  align: 'left',
                ),
            ]),
            gap(16, when: 'done'),
            doneOverline(r.ordered ? 'ORDER MATTERS' : 'ORDER DOES NOT MATTER'),
            gap(6, when: 'done'),
            tex(r.count, 17, when: 'done'),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichCellHurts() => pickScreen(
  id: 'which-cell-hurts',
  chapter: 'statistics',
  title: 'Which Cell Hurts Most',
  closing:
      'Each cell contributes the gap SQUARED and then divided by what was '
      'expected. That division is why a small category with a small gap '
      'can outweigh a large one with a large gap, and why the biggest bar '
      'on the chart is often not the culprit.',
  right: 'THAT IS THE ONE',
  wrong: 'LOOK AT THE E',
  brief: briefJson(goodnessOfFitBrief, 'goodnessOfFitBrief'),
  rounds: [
    for (final (n, r) in hurtRounds.indexed)
      (
        options: [for (final c in r.cells) c.name],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('WHICH CELL ADDS THE MOST'),
          gap(8),
          ask(
            'Which category contributes most to the chi-square total?',
            size: 15.5,
          ),
          gap(6),
          subject(r.model),
          gap(12),
          pictured(
            perPick(
              (pick, answered) =>
                  (canvas, size) => CellsPainter(
                    cells: r.cells,
                    picked: pick,
                    truth: answered ? r.answer : null,
                    revealed: answered,
                  ).paint(canvas, size),
              r.cells.length,
              200,
              what: 'which-cell-hurts round $n',
            ),
            200,
          ),
          gap(6),
          {
            'mono':
                'the bar is what was counted, the line is what was '
                'expected',
            'size': 10,
            'color': 'ink3',
          },
          gap(12),
          buttons(
            [for (final c in r.cells) c.name],
            h: 50,
            pad: 2,
            radius: 10,
            space: 6,
          ),
          gap(16, when: 'done'),
          doneOverline('WHAT EACH CELL ADDS'),
          gap(6, when: 'done'),
          for (final cell in r.cells) ...[
            t(
              '${cell.name.padRight(6)}'
              '(${cell.observed} - ${cell.expected})^2 / ${cell.expected}'
              '  =  ${cell.contribution.toStringAsFixed(2)}',
              font: 'code',
              size: 12,
              when: 'done',
            ),
            gap(3, when: 'done'),
          ],
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> widerOrNarrower() {
  const options = ['Narrower', 'No change', 'Wider'];
  return pickScreen(
    id: 'wider-or-narrower',
    chapter: 'statistics',
    title: 'Wider or Narrower',
    closing:
        'Three things set the width: how sure you want to be, how spread '
        'out the material is, and how many samples you took. The sample '
        'mean is not one of them, and t is always wider than z.',
    right: 'THAT IS THE WAY',
    wrong: 'THE OTHER WAY',
    brief: briefJson(zOrTBrief, 'zOrTBrief'),
    rounds: [
      for (final (n, r) in moveRounds.indexed)
        (
          options: options,
          notes: null,
          tex: null,
          answer: Move.values.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            overline('WHICH WAY DOES THE INTERVAL MOVE'),
            gap(8),
            ask(r.change, size: 15.5),
            gap(6),
            subject(r.before),
            gap(12),
            pictured(() {
              Draw drawn(BandTone? after) =>
                  (canvas, size) => IntervalPainter(
                    center: 0,
                    widest: 1.5,
                    unit: 'the true mean',
                    bands: [
                      const Band(
                        margin: 1,
                        label: 'as it stands',
                        tone: BandTone.before,
                      ),
                      if (after != null)
                        Band(
                          margin: r.after,
                          label: 'after the change',
                          tone: after,
                        ),
                    ],
                  ).paint(canvas, size);
              final what = 'wider-or-narrower round $n';
              final truth = record(
                drawn(BandTone.truth),
                130,
                what: '$what right',
              );
              final wrong = record(
                drawn(BandTone.wrong),
                130,
                what: '$what wrong',
              );
              final answer = Move.values.indexOf(r.answer);
              return askDone(record(drawn(null), 130, what: what), {
                'pick': [
                  for (var i = 0; i < options.length; i++)
                    i == answer ? truth : wrong,
                ],
              });
            }(), 130),
            gap(14),
            buttons(options, font: 'body', size: 14, pad: 2),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichWayPoints() {
  const options = ['Left only', 'Both ends', 'Right only'];
  Object tail(Tail which) {
    Object drawn(Color color) => record(
      (canvas, size) =>
          TailPainter(tail: which, color: color).paint(canvas, size),
      96,
      range: (40, 400),
      what: 'which-way-points ${which.name}',
    );
    return tone(
      drawn(AppColors.charcoal),
      drawn(AppColors.ember),
      drawn(AppColors.forest),
      drawn(AppColors.error),
    );
  }

  final tails = [for (final w in Tail.values) tail(w)];
  return pickScreen(
    id: 'which-way-points',
    chapter: 'statistics',
    title: 'Which Way Does It Point',
    closing:
        'The claim decides the picture. A directional word puts all of '
        'alpha in one tail, and no direction splits it between two, which '
        'is a different row of the table and a different critical value.',
    right: 'THAT IS THE SHAPE',
    wrong: 'THE OTHER SHAPE',
    brief: briefJson(hypothesesBrief, 'hypothesesBrief'),
    rounds: [
      for (final r in pointRounds)
        (
          options: options,
          notes: null,
          tex: null,
          answer: Tail.values.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            overline('WHERE DOES ALPHA GO'),
            gap(8),
            ask(r.claim, size: 15.5),
            gap(6),
            subject(r.subject),
            gap(14),
            answerRow([
              for (final (i, o) in options.indexed)
                tinted(
                  i,
                  col([
                    box(h: 96, child: draw(tails[i])),
                    gapH(6),
                    t(o, font: 'mono', size: 11, one: true),
                  ]),
                  radius: 14,
                  pad: [6, 10, 6, 8],
                  w: null,
                ),
            ]),
            gap(16, when: 'done'),
            doneOverline('WHAT THE CLAIM SETS UP'),
            gap(6, when: 'done'),
            {'code': r.hypotheses, 'size': 13, 'when': 'done'},
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> throughTheMeans() => pickScreen(
  id: 'through-the-means',
  chapter: 'statistics',
  title: 'Through the Means',
  closing:
      'The least-squares line always passes through the point where the '
      'two means meet. That is where the intercept comes from, and it '
      'is why a prediction is the intercept plus the slope times x and '
      'never the slope alone.',
  right: 'THROUGH THE MEANS',
  wrong: 'NOT THAT LINE',
  brief: briefJson(regressionLineBrief, 'regressionLineBrief'),
  rounds: [
    for (final (n, r) in meansRounds.indexed)
      (
        options: [for (final (i, l) in r.lines.indexed) l.label ?? '${i + 1}'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('IT HAS TO GO THROUGH THE MEANS'),
          gap(8),
          ask('Which of these could be the regression line?'),
          gap(6),
          subject(r.subject),
          gap(12),
          pictured(
            perPick(
              (pick, answered) =>
                  (canvas, size) => ScatterPainter(
                    points: r.points,
                    xTo: r.xTo,
                    yTo: r.yTo,
                    lines: r.lines,
                    meanPoint: true,
                    pickedLine: pick,
                    truthLine: answered ? r.answer : null,
                    revealed: answered,
                  ).paint(canvas, size),
              r.lines.length,
              260,
              what: 'through-the-means round $n',
            ),
            260,
          ),
          gap(14),
          buttons(
            [for (final (i, l) in r.lines.indexed) l.label ?? '${i + 1}'],
            font: 'heading',
            size: 17,
            h: 56,
            pad: 0,
            one: false,
          ),
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> whereItBalances() => pickScreen(
  id: 'where-it-balances',
  chapter: 'statistics',
  title: 'Where It Balances',
  closing:
      'An expected value is the balance point of the whole picture. It '
      'is not the most likely outcome, it is not the middle of the '
      'range, and it does not have to be a value that can actually '
      'happen.',
  right: 'IT SITS LEVEL',
  wrong: 'IT TIPS',
  brief: briefJson(expectedValueBrief, 'expectedValueBrief'),
  rounds: [
    for (final (n, r) in balanceRounds.indexed)
      (
        options: [
          for (var i = 0; i < r.fulcrums.length; i++)
            String.fromCharCode(65 + i),
        ],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('WHICH FULCRUM HOLDS IT LEVEL'),
          gap(8),
          ask(
            'Each block is an outcome, and its height is how likely it is.',
            size: 15.5,
          ),
          gap(6),
          subject(r.subject),
          gap(12),
          pictured(
            perPick(
              (pick, answered) =>
                  (canvas, size) => BeamPainter(
                    outcomes: r.outcomes,
                    fulcrums: r.fulcrums,
                    from: 0,
                    to: r.to,
                    unit: r.unit,
                    picked: pick,
                    truth: answered ? r.answer : null,
                    revealed: answered,
                  ).paint(canvas, size),
              r.fulcrums.length,
              250,
              what: 'where-it-balances round $n',
            ),
            250,
          ),
          gap(14),
          buttons(
            [
              for (var i = 0; i < r.fulcrums.length; i++)
                String.fromCharCode(65 + i),
            ],
            font: 'heading',
            size: 17,
            h: 56,
            pad: 0,
            one: false,
          ),
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> whatGoesUnder() => pickScreen(
  id: 'what-goes-under',
  chapter: 'statistics',
  title: 'What Goes Under',
  closing:
      'The margin is the multiplier times sigma over the ROOT of n. The '
      'root is what makes samples expensive, and the multiplier is what '
      'makes confidence expensive. Both show up as width.',
  right: 'THAT IS THE PIECE',
  wrong: 'LOOK AT THE WIDTH',
  brief: briefJson(marginOfErrorBrief, 'marginOfErrorBrief'),
  rounds: [
    for (final (n, r) in underRounds.indexed)
      () {
        String skeleton(String piece) => r.blank == Blank.denominator
            ? '\\bar{x} \\pm z_{\\alpha/2}\\,\\frac{\\sigma}{$piece}'
            : '\\bar{x} \\pm $piece\\,\\frac{\\sigma}{\\sqrt{n}}';
        final widest = [
          for (var i = 0; i < r.options.length; i++) marginWith(r, i),
        ].reduce((a, b) => a > b ? a : b);
        return (
          options: r.options,
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: [
            overline(
              r.blank == Blank.denominator
                  ? 'WHAT GOES UNDER SIGMA'
                  : 'WHICH MULTIPLIER',
            ),
            gap(8),
            subject(r.subject),
            gap(10),
            box(
              w: 'max',
              pad: [10, 12, 10, 12],
              fill: 'creamDark',
              radius: 12,
              c: [
                tex(r.given, 13),
                gapH(10),
                tex({
                  'pick': [for (final o in r.options) skeleton(o)],
                  'none': skeleton(r'\square'),
                }, 17),
              ],
            ),
            gap(12),
            pictured(
              perPick(
                (pick, answered) =>
                    (canvas, size) => IntervalPainter(
                      center: r.mean,
                      widest: widest * 1.12,
                      unit: r.unit,
                      bands: [
                        for (var i = 0; i < r.options.length; i++)
                          Band(
                            margin: marginWith(r, i),
                            label: r.names[i],
                            tone: answered
                                ? (i == r.answer
                                      ? BandTone.truth
                                      : (i == pick
                                            ? BandTone.wrong
                                            : BandTone.before))
                                : (i == pick ? BandTone.live : BandTone.before),
                          ),
                      ],
                    ).paint(canvas, size),
                r.options.length,
                160,
                what: 'what-goes-under round $n',
              ),
              160,
            ),
            gap(12),
            answerRow([
              for (final (i, o) in r.options.indexed)
                tinted(i, center(tex(o, 16), wf: 1), h: 54, w: null),
            ]),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> shadeTheTail() => pickScreen(
  id: 'shade-the-tail',
  chapter: 'statistics',
  title: 'Shade the Tail',
  closing:
      'The z-score is arithmetic and it belongs on paper. Which area the '
      'sentence wants is the part that gets marked wrong: left of the '
      'line, right of it, between two lines, or everything outside them.',
  right: 'THAT IS THE AREA',
  wrong: 'THE OTHER PIECE',
  brief: briefJson(normalTableBrief, 'normalTableBrief'),
  rounds: [
    for (final (n, r) in tailRounds.indexed)
      (
        options: [for (final g in r.regions) g.column],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          overline('PUT A FINGER ON THE AREA'),
          gap(8),
          ask(r.ask),
          gap(6),
          subject(r.subject),
          gap(12),
          clip(
            box(
              w: 'max',
              h: 230,
              child: grid(_regionsToTap(r, 'shade-the-tail round $n')),
            ),
            16,
          ),
          gap(12),
          formula(r.given, 15, pad: const [12, 12, 12, 12]),
          gap(16, when: 'done'),
          doneOverline('THE TABLE HANDS YOU'),
          gap(6, when: 'done'),
          tex(r.regions[r.answer].column, 16, when: 'done'),
          ...feedback(),
        ],
      ),
  ],
);

/// The bell curve answered by tapping a region: one rectangle per span,
/// full height, so a tap anywhere above a span picks its region, as the
/// game's own tap does. A region in two pieces has two rectangles.
Node _regionsToTap(TailRound r, String what) {
  const h = 230.0;
  // The game takes the first region holding the tap and the pack the last
  // rectangle, so they go in backwards.
  final spans = [
    for (final (i, g) in r.regions.indexed)
      for (final s in g.spans) (i, s),
  ].reversed.toList();
  double x(Size size, double z) =>
      12 + (z - zMin) / (zMax - zMin) * (size.width - 24);
  Draw drawn(int? pick, bool answered) =>
      (canvas, size) => NormalPainter(
        regions: r.regions,
        cuts: r.cuts,
        labels: r.labels,
        picked: pick,
        truth: answered ? r.answer : null,
        revealed: answered,
      ).paint(canvas, size);
  final hits = [for (final (i, _) in spans) i];
  return {
    'k': 'tapdraw',
    'd': {
      for (final answered in [false, true])
        for (final mark in [null, for (var m = 0; m < spans.length; m++) m])
          // Only a region's first rectangle is ever looked up.
          if (mark == null || hits.indexOf(hits[mark]) == mark)
            if (!(answered && mark == null))
              '${mark ?? '-'}|${answered ? 1 : 0}': record(
                drawn(mark == null ? null : hits[mark], answered),
                h,
                what: '$what ${mark ?? 'none'} ${answered ? 'answered' : ''}',
              ),
    },
    'targets': record(
      (canvas, size) {
        for (final (_, (from, to)) in spans) {
          canvas.drawRect(
            Rect.fromLTRB(x(size, from), 0, x(size, to), h),
            Paint(),
          );
        }
      },
      h,
      what: '$what regions',
    ),
    'hits': hits,
    'h': h,
  };
}

/// Extra settings on each round of a built game, in order.
Map<String, Object?> withRounds(
  Map<String, Object?> game,
  Map<String, Object?> Function(int round) extra,
) {
  return {
    ...game,
    'rounds': [
      for (final (i, r) in (game['rounds']! as List).indexed)
        <String, Object?>{...(r as Map), ...extra(i)},
    ],
  };
}

Map<String, Object?> buildTheBinomial() {
  Node skeleton(List<String> latex) => row([
    for (var k = 0; k < 3; k++) ...[
      if (k > 0) ...[gapW(6), t('×', size: 13, color: 'ink3'), gapW(6)],
      flex(
        box(
          h: 40,
          fill: slot(k, [for (final _ in latex) 'white']),
          radius: 8,
          border: slot(k, [for (final _ in latex) 'ember'], empty: 'line'),
          stroke: slot(k, [for (final _ in latex) 1.5], empty: 1),
          child: center(
            box(
              pad: [8, 0, 8, 0],
              child: slot(k, [
                for (final l in latex) tex(l, 13),
              ], empty: gapW(44)),
            ),
            wf: 1,
          ),
        ),
        1,
        true,
      ),
    ],
  ], main: 'center');
  return withRounds(
    pickSeveral(
      id: 'build-the-binomial',
      chapter: 'statistics',
      title: 'Build the Binomial',
      closing:
          'Three factors, every time: the number of arrangements, the '
          'successes, and the failures. The exponents add up to the number '
          'of trials, and the count in front is a combination, never an '
          'arrangement.',
      right: 'ALL THREE FACTORS',
      wrong: 'NOT THOSE THREE',
      brief: briefJson(binomialBrief, 'binomialBrief'),
      rounds: [
        for (final r in binomialRounds)
          (
            options: [for (final f in r.factors) f.latex],
            answer: r.answer.toList()..sort(),
            alone: const [],
            why: r.why,
            source: r.source,
            screen: [
              overline('PICK THE THREE FACTORS'),
              gap(8),
              ask(r.scenario, size: 15.5),
              gap(12),
              box(
                w: 'max',
                pad: [12, 12, 12, 12],
                fill: 'creamDark',
                radius: 12,
                c: [
                  t(
                    'THE CHANCE THAT ${r.ask.toUpperCase()}',
                    font: 'overline',
                    color: 'ink3',
                    align: 'center',
                  ),
                  gapH(8),
                  skeleton([for (final f in r.factors) f.latex]),
                ],
              ),
              gap(14),
              for (var line = 0; line < 3; line++) ...[
                if (line > 0) gap(8),
                answerRow([
                  for (var c = 0; c < 2; c++)
                    tinted(
                      line * 2 + c,
                      center(tex(r.factors[line * 2 + c].latex, 15), wf: 1),
                      h: 52,
                      w: null,
                    ),
                ]),
              ],
              ...feedback(),
            ],
          ),
      ],
    ),
    (_) => {'most': 3, 'need': 3},
  );
}

String _writeTotal(double v) => v == v.roundToDouble() && v.abs() < 10000
    ? v.toStringAsFixed(v.abs() < 100 ? 2 : 0)
    : v.toStringAsFixed(2);

Map<String, Object?> mindTheOrder() {
  double valueOf(OrderRound r, Total total) => switch (total.role) {
    TotalRole.mean => r.mean,
    TotalRole.eSquared => r.meanOfSquares,
    TotalRole.meanSquared => r.mean * r.mean,
    TotalRole.rawSquares => r.outcomes.fold<double>(
      0,
      (a, o) => a + (o.value * o.value).toDouble(),
    ),
    TotalRole.other => r.outcomes.fold<double>(
      0,
      (a, o) => a + o.value.toDouble(),
    ),
  };
  Node table(OrderRound r) {
    Node line(String label, List<String> cells) => row([
      box(
        w: 44,
        child: t(label, font: 'overline', color: 'ink3'),
      ),
      for (final c in cells) flex(center(t(c, font: 'code', size: 13), wf: 1)),
    ]);
    return box(
      w: 'max',
      pad: [10, 8, 10, 8],
      fill: 'white',
      radius: 12,
      border: 'line',
      c: [
        line('x', [for (final o in r.outcomes) '${o.value}']),
        gapH(6),
        rule(color: 'line'),
        gapH(6),
        line('P(x)', [
          for (final o in r.outcomes) (o.percent / 100).toStringAsFixed(2),
        ]),
      ],
    );
  }

  Node slotBox(int k, List<String> values) => box(
    h: 38,
    w: 78,
    align: 'center',
    fill: slot(k, [for (final _ in values) 'white']),
    radius: 8,
    border: slot(k, [for (final _ in values) 'ember'], empty: 'line'),
    stroke: slot(k, [for (final _ in values) 1.5], empty: 1),
    child: t(slot(k, values, empty: ''), font: 'code', size: 14),
  );

  return withRounds(
    pickSeveral(
      id: 'mind-the-order',
      chapter: 'statistics',
      title: 'Mind the Order',
      closing:
          'The mean of the squares, take away the square of the mean. In '
          'that order, every time. The other way round gives a negative '
          'variance, which is the cheapest error to spot and the easiest to '
          'make.',
      right: 'IN THAT ORDER',
      wrong: 'NOT LIKE THAT',
      brief: briefJson(varianceShortcutBrief, 'varianceShortcutBrief'),
      rounds: [
        for (final r in orderRounds)
          () {
            final values = [
              for (final total in r.totals) _writeTotal(valueOf(r, total)),
            ];
            return (
              options: [for (final total in r.totals) total.latex],
              answer: [r.first, r.second],
              alone: const <int>[],
              why: r.why,
              source: r.source,
              screen: [
                overline('FILL THE FORMULA, IN ORDER'),
                gap(8),
                subject(r.subject),
                gap(10),
                table(r),
                gap(12),
                box(
                  w: 'max',
                  pad: [10, 12, 10, 12],
                  fill: 'creamDark',
                  radius: 12,
                  child: wrap(
                    [
                      tex(r'\text{Var}(X) =', 15),
                      row([
                        slotBox(0, values),
                        gapW(8),
                        t('−', size: 17),
                        gapW(8),
                        slotBox(1, values),
                      ], min: true),
                    ],
                    space: 8,
                    run: 8,
                    center: true,
                  ),
                ),
                gap(14),
                ...stacked([
                  for (final (i, total) in r.totals.indexed)
                    tinted(
                      i,
                      row([
                        place([
                          for (final n in [1, 2])
                            box(
                              w: 22,
                              child: t(
                                '$n',
                                font: 'mono',
                                size: 12,
                                color: 'ember',
                              ),
                            ),
                        ], none: gapW(22)),
                        flex(tex(total.latex, 14)),
                        gapW(8),
                        t(values[i], font: 'code', size: 13),
                      ]),
                      pad: [12, 10, 12, 10],
                    ),
                ]),
                gap(16, when: 'done'),
                doneOverline('THE VARIANCE IS'),
                gap(6, when: 'done'),
                tex(
                  '\\text{Var}(X) = ${_writeTotal(r.meanOfSquares)} - '
                  '${_writeTotal(r.mean * r.mean)} = '
                  '${_writeTotal(r.variance)}',
                  15,
                  when: 'done',
                ),
                ...feedback(),
              ],
            );
          }(),
      ],
    ),
    (_) => {'order': 'list', 'most': 2, 'need': 2},
  );
}

Map<String, Object?> readTheLine() => pickSeveral(
  id: 'read-the-line',
  chapter: 'statistics',
  title: 'Read It Off the Line',
  closing:
      'Median, mode and range are places on the line and can be read '
      'without adding anything up. The mean cannot, which is the '
      'difference that matters when one reading is a long way out.',
  right: 'THAT IS THE SPOT',
  wrong: 'NOT THERE',
  brief: briefJson(centerBrief, 'centerBrief'),
  rounds: [
    for (final (n, r) in lineRounds.indexed)
      (
        options: [for (var v = r.from; v <= r.to; v++) '$v'],
        answer: [for (final v in r.answer) v - r.from]..sort(),
        alone: const [],
        why: r.why,
        source: r.source,
        screen: [
          overline('NOTHING HERE NEEDS ADDING UP'),
          gap(8),
          ask(r.ask),
          gap(6),
          subject(r.subject),
          gap(12),
          clip(
            box(
              w: 'max',
              h: DotPlotPainter.heightFor(r.values),
              child: grid(_lineToTap(r, 'read-the-line round $n')),
            ),
            16,
          ),
          ...feedback(),
        ],
      ),
  ],
);

/// The dot plot answered by tapping its ticks, any number of them: the
/// axis, then each value's column as picked or not, then the readings on
/// top, so no drawing is needed for every set of picks.
Node _lineToTap(LineRound r, String what) {
  final h = DotPlotPainter.heightFor(r.values);
  final ticks = [for (var v = r.from; v <= r.to; v++) v];
  DotPlotPainter plot({Set<int> picked = const {}, bool answered = false}) =>
      DotPlotPainter(
        values: r.values,
        from: r.from,
        to: r.to,
        picked: picked,
        truth: answered ? r.answer : const {},
        revealed: answered,
      );
  return {
    'k': 'tapdraw',
    'layers': [
      {
        'd': record(
          (canvas, size) => plot().paintAxis(canvas, size),
          h,
          what: '$what axis',
        ),
      },
      for (final (m, v) in ticks.indexed)
        {
          'mark': m,
          'd': {
            for (final picked in [false, true])
              for (final answered in [false, true])
                '${picked ? 1 : 0}|${answered ? 1 : 0}': record(
                  (canvas, size) => plot(
                    picked: {if (picked) v},
                    answered: answered,
                  ).paintColumn(canvas, size, v),
                  h,
                  what:
                      '$what tick $v ${picked ? 'picked' : ''}'
                      '${answered ? ' answered' : ''}',
                ),
          },
        },
      {
        'd': record(
          (canvas, size) => plot().paintReadings(canvas, size),
          h,
          what: '$what readings',
        ),
      },
    ],
    // Each tick takes the taps across from it, as far as 1.2 of the
    // spacing between ticks.
    'targets': record(
      (canvas, size) {
        final p = plot();
        final pitch = (size.width - 44) / (r.to - r.from);
        for (final v in ticks) {
          canvas.drawCircle(
            Offset(p.xOf(size, v), h - 34),
            pitch * 1.2,
            Paint(),
          );
        }
      },
      h,
      what: '$what ticks',
    ),
    'axis': 'x',
    'hits': [for (var m = 0; m < ticks.length; m++) m],
    'h': h,
  };
}

Map<String, Object?> whatWeights() => withRounds(
  pickSeveral(
    id: 'what-weights',
    chapter: 'statistics',
    title: 'What Gets Weighted',
    closing:
        'The formula never changes. What changes is which column is the '
        'thing being averaged and which is how much each row counts for, '
        'and getting that backwards runs the arithmetic perfectly to the '
        'wrong answer.',
    right: 'BOTH ROLES',
    wrong: 'NOT THOSE TWO',
    brief: briefJson(weightedBrief, 'weightedBrief'),
    rounds: [
      for (final r in weightRounds)
        (
          options: r.columns,
          answer: [r.value, r.weight],
          alone: const [],
          why: r.why,
          source: r.source,
          screen: [
            overline('NAME THE TWO COLUMNS'),
            gap(8),
            ask(r.ask),
            gap(6),
            subject(
              'Tap the column being averaged, then the one that weights it.',
            ),
            gap(12),
            _weightsTable(r),
            gap(12),
            row([
              for (final (k, (label, color)) in const [
                ('BEING AVERAGED', 'ember'),
                ('THE WEIGHT', 'info'),
              ].indexed) ...[
                if (k > 0) gapW(10),
                flex(
                  box(
                    pad: [12, 10, 12, 10],
                    fill: 'white',
                    radius: 12,
                    border: slot(k, [
                      for (final _ in r.columns) color,
                    ], empty: 'line'),
                    stroke: slot(k, [for (final _ in r.columns) 2], empty: 1),
                    cross: 'start',
                    c: [
                      t(label, font: 'overline', color: 'ink3'),
                      gapH(4),
                      t(slot(k, r.columns, empty: '?'), font: 'mono', size: 13),
                    ],
                  ),
                ),
              ],
            ]),
            ...feedback(),
          ],
        ),
    ],
  ),
  (_) => {'order': 'slots', 'most': 2, 'need': 2},
);

/// The table of columns, each but the first a tap that gives the column a
/// role, its cells tinted by the role it has.
Node _weightsTable(WeightRound r) {
  Object tint(int i) => i == 0
      ? 'creamDark'
      : {
          'idle': 'clear',
          'picked': 'clear',
          'slot0': 'emberBg',
          'slot1': 'infoBg',
          'right': 'forestBg',
          'wrong': 'errorBg',
          'of': i,
        };
  Node header(int i) {
    final cell = box(
      h: 42,
      align: 'center',
      pad: [4, 0, 4, 0],
      fill: tint(i),
      child: t(
        r.columns[i],
        font: 'overline',
        color: i == 0 ? 'ink3' : 'charcoal',
        align: 'center',
      ),
    );
    return flex(i == 0 ? cell : answer(i, cell, radius: 0), i == 0 ? 4 : 3);
  }

  return box(
    fill: 'white',
    radius: 12,
    border: 'line',
    clip: true,
    c: [
      row([for (var i = 0; i < r.columns.length; i++) header(i)]),
      for (final line in r.rows)
        row([
          for (var i = 0; i < line.length; i++)
            flex(
              box(
                h: 38,
                align: 'center',
                fill: tint(i),
                border: 'line',
                edge: 'top',
                child: t(
                  line[i],
                  font: 'mono',
                  size: 12.5,
                  color: i == 0 ? 'ink2' : 'charcoal',
                ),
              ),
              i == 0 ? 4 : 3,
            ),
        ]),
    ],
  );
}

Map<String, Object?> whichReadout() {
  const macron = '̄';
  final notThere = readoutLines.length;
  Node line(int i, String value) {
    final (name, meaning) = readoutLines[i];
    final barred = name.contains(macron);
    return answer(
      i,
      box(
        pad: [14, 11, 14, 11],
        border: 'pure/0.08',
        edge: 'top',
        child: row([
          box(
            w: 42,
            child: t(
              barred ? name.replaceAll(macron, '') : name,
              font: 'code',
              size: 15,
              color: 'cream',
              bar: barred,
            ),
          ),
          flex(t(meaning, font: 'mono', size: 10, color: 'onScreen/0.55')),
          t(value, font: 'code', size: 15, color: 'onScreen'),
        ]),
      ),
      radius: 0,
      fill: tone('clear', 'ember/0.4', 'forest/0.45', 'error/0.4'),
    );
  }

  // The right answer is named for what it is: a line, or not on screen.
  return withRounds(
    pickScreen(
      id: 'which-readout',
      chapter: 'statistics',
      title: 'Which Line Do You Read',
      closing:
          'Sx divides by n minus one and σx divides by n, and which you want '
          'is decided by whether the readings are a sample or everything '
          'there is. Variance and the coefficient of variation are not on '
          'the screen at all.',
      right: 'THAT LINE',
      wrong: 'NOT THAT LINE',
      brief: briefJson(spreadBrief, 'spreadBrief'),
      rounds: [
        for (final r in readoutRounds)
          (
            options: [
              // As shown: the bar over x is drawn, not typed.
              for (final (name, _) in readoutLines) name.replaceAll(macron, ''),
              'It is not on this screen',
            ],
            notes: null,
            tex: null,
            answer: r.answer == -1 ? notThere : r.answer,
            why: r.why,
            source: r.source,
            screen: [
              overline('ONE SCREEN, SIX NUMBERS'),
              gap(8),
              {'text': r.ask, 'size': 15.5, 'line': 1.55},
              gap(12),
              box(
                w: 'max',
                fill: 'screen',
                radius: 12,
                clip: true,
                c: [
                  box(
                    w: 'max',
                    pad: [0, 7, 0, 7],
                    fill: 'pure/0.08',
                    child: center(
                      t('1-VAR STATS', font: 'overline', color: 'onScreen'),
                    ),
                  ),
                  for (var i = 0; i < readoutLines.length; i++)
                    line(i, r.values[i]),
                ],
              ),
              gap(10),
              tinted(
                notThere,
                t('It is not on this screen', font: 'heading', size: 14.5),
                h: 52,
                align: 'center',
              ),
              ...feedback(),
            ],
          ),
      ],
    ),
    (i) => {if (readoutRounds[i].answer == -1) 'right': 'NOT ON THE SCREEN'},
  );
}

final adapters = <String, Map<String, Object?> Function()>{
  'add-the-squares': addTheSquares,
  'how-do-they-sit': howDoTheySit,
  'how-many-samples': howManySamples,
  'r-or-r2': rOrR2,
  'read-the-scatter': readTheScatter,
  'reject-or-not': rejectOrNot,
  'same-pick': samePick,
  'which-cell-hurts': whichCellHurts,
  'wider-or-narrower': widerOrNarrower,
  'which-way-points': whichWayPoints,
  'through-the-means': throughTheMeans,
  'where-it-balances': whereItBalances,
  'what-goes-under': whatGoesUnder,
  'shade-the-tail': shadeTheTail,
  'build-the-binomial': buildTheBinomial,
  'mind-the-order': mindTheOrder,
  'read-the-line': readTheLine,
  'what-weights': whatWeights,
  'which-readout': whichReadout,
};
