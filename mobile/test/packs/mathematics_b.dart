import 'package:flutter/material.dart' hide Path, TextPainter;

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/games/both_sides_game.dart' show sidesRounds;
import 'package:mobile/features/games/can_it_start_game.dart'
    show bracketRounds;
import 'package:mobile/features/games/copy_it_down_game.dart'
    show copyRounds, sheetValues;
import 'package:mobile/features/games/cross_figures.dart'
    show Region, RegionPainter, Turn, TurnGlyphPainter;
import 'package:mobile/features/games/fill_the_trace_game.dart'
    show traceRounds;
import 'package:mobile/features/games/first_true_wins_game.dart'
    show chainRounds;
import 'package:mobile/features/games/fix_the_sign_game.dart' show expansions;
import 'package:mobile/features/games/follow_the_tangent_game.dart'
    show tangentRounds;
import 'package:mobile/features/games/grid_figures.dart' show GridGeometry;
import 'package:mobile/features/games/happens_first_game.dart'
    show precedenceRounds;
import 'package:mobile/features/games/land_the_resultant_game.dart'
    show resultantRounds;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/next_line_game.dart' show nextLines;
import 'package:mobile/features/games/open_or_closed_game.dart'
    show DotSign, signRounds;
import 'package:mobile/features/games/pick_u_game.dart' show uSubRounds;
import 'package:mobile/features/games/reaches_further_game.dart'
    show Reach, reachRounds;
import 'package:mobile/features/games/root_figures.dart' show RootPainter;
import 'package:mobile/features/games/run_the_loop_game.dart'
    show LoopMove, loopRounds, loopSlipWhy;
import 'package:mobile/features/games/shadow_falls_game.dart' show shadowRounds;
import 'package:mobile/features/games/stretch_it_game.dart' show stretchRounds;
import 'package:mobile/features/games/take_the_diagonal_game.dart'
    show diagonalRounds;
import 'package:mobile/features/games/vector_figures.dart';
import 'package:mobile/features/games/what_shows_game.dart' show showsRounds;
import 'package:mobile/features/games/whats_missing_game.dart'
    show missingRounds, missingVerdicts;
import 'package:mobile/features/games/where_it_stops_game.dart'
    show whileRounds;
import 'package:mobile/features/games/which_method_game.dart'
    show MethodPick, methodRounds;
import 'package:mobile/features/games/which_region_game.dart' show regionRounds;
import 'package:mobile/features/games/which_way_simpler_game.dart'
    show partsRounds;
import 'package:mobile/features/games/which_way_turns_game.dart'
    show turnRounds;

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show perPick;

/// The Mathematics games, second half: integrals, l'Hopital's rule,
/// vectors, the dot and cross products, spreadsheets, programming and
/// numerical methods. Among the first games built, and laid out each its
/// own way, so every screen is written as screen nodes (nodes.dart) with
/// the widgets the built-in games use. Several play in ways no earlier
/// chapter did: a lattice point tapped out of 169 (Land the Resultant), a
/// multiplier stepped up and down (Stretch It to Fit), a run of moves
/// (Run the Loop), and rows filled in turn from a strip of values (Fill
/// the Trace). See docs/mobile/content-packs.md for what each needed.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'pick-u': pickU,
  'which-way-simpler': whichWaySimpler,
  'whats-missing': whatsMissing,
  'run-the-loop': runTheLoop,
  'next-line': nextLine,
  'both-sides': bothSides,
  'land-the-resultant': landTheResultant,
  'stretch-it': stretchIt,
  'reaches-further': reachesFurther,
  'take-the-diagonal': takeTheDiagonal,
  'open-or-closed': openOrClosed,
  'shadow-falls': shadowFalls,
  'which-way-turns': whichWayTurns,
  'which-region': whichRegion,
  'fix-the-sign': fixTheSign,
  'copy-it-down': copyItDown,
  'happens-first': happensFirst,
  'what-shows': whatShows,
  'fill-the-trace': fillTheTrace,
  'first-true-wins': firstTrueWins,
  'where-it-stops': whereItStops,
  'follow-the-tangent': followTheTangent,
  'can-it-start': canItStart,
  'which-method': whichMethod,
};

// ---------------------------------------------------------------------------
// The pieces every screen here is made of

/// A game whose rounds each carry their own screen.
Map<String, Object?> _game({
  required String id,
  String type = 'pick-one',
  required String title,
  required String closing,
  required String right,
  required String wrong,
  required Map<String, Object?> brief,
  required List<Map<String, Object?>> rounds,
  String? button,
}) => {
  'type': type,
  'id': id,
  'chapter': 'mathematics',
  'title': title,
  'closing': closing,
  'right': right,
  'wrong': wrong,
  'button': ?button,
  'brief': brief,
  'rounds': rounds,
};

/// One round: its answers, the right one (or ones), why, where it came
/// from, its screen, and anything else the round sets.
Map<String, Object?> _round({
  required List<String> options,
  required Object answer,
  required String why,
  required String source,
  required List<Map<String, Object?>> screen,
  Map<String, Object?> more = const {},
}) => {
  'options': options,
  'answer': answer,
  'why': why,
  'source': source,
  ...more,
  'screen': screen,
};

/// A value drawn before the answer and after it.
Map<String, Object?> _both(Object Function(bool answered) of) =>
    askDone(of(false), of(true));

Map<String, Object?> _overline(String words) => {
  'overline': words,
  'color': 'ember',
};

/// The question in body text, 15 on 1.55 or 16 on 1.5.
Map<String, Object?> _ask(String words, {num size = 15, num line = 1.55}) => {
  'text': words,
  'size': size,
  'line': line,
};

Map<String, Object?> _note(String words) => {
  'mono': words,
  'size': 11.5,
  'color': 'ink3',
};

/// Once answered: a gap and the feedback.
List<Map<String, Object?>> _feedback([num space = 16]) => feedbackAfter(space);

/// A white bordered card holding one thing, as the games quote a formula.
Node _card(
  Node child, {
  List<num> pad = const [12, 16, 12, 16],
  num radius = 14,
  String fill = 'white',
  bool border = true,
}) => box(
  w: 'max',
  pad: pad,
  fill: fill,
  radius: radius,
  border: border ? 'line' : null,
  child: child,
);

/// The games' answer buttons: white, ember once picked, then forest or
/// red once answered, the border a pixel thicker once anything but idle.
/// [tones] replaces the four looks (fill, border) for a game that shows a
/// state its own way.
Node _button(
  int i, {
  Node? child,
  List<Node>? c,
  num radius = 12,
  Object? w = 'max',
  num? h,
  num? minH,
  num? minW,
  List<num>? pad,
  String? align,
  String? cross,
  List<(String, String)>? tones,
  String? key,
  bool painted = false,
}) {
  final looks =
      tones ??
      const [
        ('white', 'line'),
        ('emberBg', 'ember'),
        ('forestBg', 'forest'),
        ('errorBg', 'error'),
      ];
  Object of(String Function((String, String)) pick) =>
      tone(pick(looks[0]), pick(looks[1]), pick(looks[2]), pick(looks[3]));
  return answer(
    i,
    box(
      w: w,
      h: h,
      minH: minH,
      minW: minW,
      pad: pad,
      align: align,
      cross: cross,
      radius: radius,
      fill: painted ? of((l) => l.$1) : null,
      border: of((l) => l.$2),
      stroke: tone(
        looks[0].$2 == 'line' ? 1 : 2,
        looks[1].$2 == 'line' ? 1 : 2,
        looks[2].$2 == 'line' ? 1 : 2,
        looks[3].$2 == 'line' ? 1 : 2,
      ),
      child: child,
      c: c,
    ),
    radius: radius,
    fill: painted ? null : of((l) => l.$1),
    key: key,
    plain: painted,
  );
}

/// Answers one under another, [space] apart.
List<Node> _stacked(List<Node> answers, {num space = 8}) => [
  for (final (i, a) in answers.indexed) ...[if (i > 0) gapH(space), a],
];

/// Answers side by side in equal shares, 8 apart.
Node _side(List<Node> answers, {num space = 8, String? cross}) => row([
  for (final (i, a) in answers.indexed) ...[if (i > 0) gapW(space), flex(a)],
], cross: cross);

/// A drawing on the 18 pixel grid, clipped to a 16 pixel corner.
Node _pictured(Draw paint, double h, String what) =>
    pictured(record(paint, h, what: what), h);

/// The dark code box the programming games set their pseudocode in.
Node _code(List<Node> lines) => box(
  w: 'max',
  pad: [14, 12, 14, 12],
  fill: 'screen',
  radius: 12,
  cross: 'start',
  c: lines,
);

// ---------------------------------------------------------------------------
// 09 integrals

Map<String, Object?> pickU() {
  Node row3(String label, List<String> latex, int first, bool open) => fade(
    has(6, 0.4, 1),
    col([
      t(label, font: 'overline', color: 'ink2'),
      gapH(8),
      row([
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) gapW(8),
          flex(
            _button(
              first + i,
              w: null,
              h: 62,
              pad: [6, 0, 6, 0],
              child: center(tex(latex[i], 15)),
              // With no substitution to find, the halves are never marked:
              // a pair picked anyway stays ember once answered.
              tones: open
                  ? const [
                      ('white', 'line'),
                      ('emberBg', 'ember'),
                      ('forestBg', 'forest'),
                      ('emberBg', 'ember'),
                    ]
                  : null,
            ),
          ),
        ],
      ]),
    ], cross: 'start'),
  );

  return _game(
    id: 'pick-u',
    type: 'pick-several',
    title: 'Pick u, Pick du',
    closing:
        'Substitution works when the derivative of the inside is already '
        'in the integrand. Choosing u and du is the decision; carrying it '
        'through, limits and all, is desk work.',
    right: 'BOTH HALVES',
    wrong: 'NOT THIS PAIR',
    brief: briefJson(substitutionBrief, 'substitutionBrief'),
    rounds: [
      for (final r in uSubRounds)
        _round(
          options: [...r.uOptions, ...r.duOptions, 'none'],
          answer: r.noSub ? [6] : [r.uAnswer, 3 + r.duAnswer],
          why: r.why,
          source: r.source,
          more: {
            'groups': [
              [0, 1, 2],
              [3, 4, 5],
            ],
            'alone': [6],
            'need': 2,
            if (r.noSub) 'right': 'NO SUBSTITUTION, CORRECTLY',
            // Half right is its own verdict: which half went wrong.
            'wrong': {
              for (var u = 0; u < 3; u++)
                for (var du = 0; du < 3; du++)
                  '$u,${3 + du}': r.noSub
                      ? 'THERE IS NO du'
                      : u == r.uAnswer && du != r.duAnswer
                      ? 'RIGHT u, WRONG du'
                      : u != r.uAnswer && du == r.duAnswer
                      ? 'THAT du, BUT NOT THAT u'
                      : 'NOT THIS PAIR',
              '6': r.noSub
                  ? 'NO SUBSTITUTION, CORRECTLY'
                  : 'THERE IS A '
                        'SUBSTITUTION HERE',
            },
          },
          screen: [
            _overline('BOTH HALVES HAVE TO AGREE'),
            gap(8),
            _ask('Set u, then set du. They only work as a pair.'),
            gap(12),
            _card(tex(r.integrand, 19)),
            gap(16),
            row3('LET u =', r.uOptions, 0, r.noSub),
            gap(14),
            row3('THEN du =', r.duOptions, 3, r.noSub),
            gap(14),
            _button(
              6,
              h: 52,
              align: 'center',
              child: t(
                'No substitution fits this one',
                font: 'heading',
                size: 14.5,
              ),
            ),
            ..._feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichWaySimpler() => _game(
  id: 'which-way-simpler',
  title: 'Which Way Gets Simpler',
  closing:
      'By parts trades one integral for another. The choice of u is '
      'right when the trade leaves you better off, which is all LIATE '
      'is telling you. Carrying it out belongs on paper.',
  right: 'SIMPLER',
  wrong: 'THAT WAY IS HARDER',
  brief: briefJson(byPartsBrief, 'byPartsBrief'),
  rounds: [
    for (final r in partsRounds)
      _round(
        options: [for (final b in r.branches) b.u],
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          _overline('ONE STEP OF BY PARTS'),
          gap(8),
          _ask(
            'Both choices are legal. Tap the one that leaves you better off '
            'than you started.',
          ),
          gap(12),
          _card(tex(r.integral, 19)),
          gap(16),
          ..._stacked(space: 10, [
            for (final (i, b) in r.branches.indexed)
              _button(
                i,
                radius: 14,
                pad: [16, 14, 16, 14],
                cross: 'start',
                c: [
                  row([
                    tex('u = ${b.u}', 15, fit: false),
                    gapW(16),
                    flex(tex('dv = ${b.dv}', 15, align: 'left'), 1, true),
                  ]),
                  gapH(10),
                  t('LEAVES YOU WITH', font: 'overline', color: 'ink3'),
                  gapH(6),
                  tex(b.left, 17, align: 'left'),
                ],
              ),
          ]),
          ..._feedback(),
        ],
      ),
  ],
);

Map<String, Object?> whatsMissing() => _game(
  id: 'whats-missing',
  title: "What's Missing",
  closing:
      'Getting the antiderivative right is most of the work and none of '
      'the marks. Plus C on an indefinite one, both limits on a '
      'definite one, and limits in whatever variable you ended up in.',
  right: 'CAUGHT IT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(finishingBrief, 'finishingBrief'),
  rounds: [
    for (final r in missingRounds)
      _round(
        options: missingVerdicts,
        answer: r.answer,
        why: r.why,
        source: r.source,
        more: {if (r.answer == 0) 'right': 'NOTHING WRONG WITH IT'},
        screen: [
          _overline('THE INTEGRATION IS CORRECT'),
          gap(8),
          _ask(
            'Run the checklist. What, if anything, is wrong with how this was '
            'written down?',
          ),
          gap(12),
          box(
            w: 'max',
            pad: [14, 16, 14, 16],
            fill: 'white',
            radius: 14,
            border: 'line',
            cross: 'start',
            c: [tex(r.problem, 17), gapH(10), tex(r.work, 17)],
          ),
          gap(16),
          ..._stacked([
            for (final (i, v) in missingVerdicts.indexed)
              _button(
                i,
                minH: 52,
                pad: [16, 12, 16, 12],
                align: 'left',
                child: t(v, size: 14.5, line: 1.4),
              ),
          ]),
          ..._feedback(),
        ],
      ),
  ],
);

// ---------------------------------------------------------------------------
// 10 l'Hopital's rule

Map<String, Object?> runTheLoop() {
  // The moves never show a pick: once the round is over the right move
  // for the step it stopped at turns forest, and a wrong one taken red.
  const looks = [
    ('white', 'line'),
    ('white', 'line'),
    ('forestBg', 'forest'),
    ('errorBg', 'error'),
  ];
  return _game(
    id: 'run-the-loop',
    title: 'Run the Loop',
    closing:
        'Substitute, look, and only then decide. The rule is a loop with '
        'a test in it, and both of the ways it goes wrong are ways of '
        'skipping the test.',
    right: 'LOOP FINISHED',
    wrong: 'NOT THAT MOVE',
    button: 'Pick a move',
    brief: briefJson(formCheckBrief, 'formCheckBrief'),
    rounds: [
      for (final r in loopRounds)
        _round(
          options: [for (final m in LoopMove.values) m.label],
          answer: r.steps.last.move.index,
          why: r.why,
          source: r.source,
          more: {
            'steps': [
              for (final s in r.steps)
                {
                  'answer': s.move.index,
                  'why': [
                    for (final m in LoopMove.values)
                      m == s.move ? '' : loopSlipWhy(s.move, m),
                  ],
                },
            ],
          },
          screen: [
            _overline('ONE MOVE AT A TIME'),
            gap(8),
            t(
              perStep([
                for (var i = 0; i < r.steps.length; i++)
                  'Step ${i + 1}. What happens next?',
              ]),
              size: 15,
              line: 1.55,
            ),
            gap(12),
            box(
              w: 'max',
              pad: [14, 18, 14, 18],
              fill: 'white',
              radius: 14,
              border: 'line',
              c: [
                perStep([
                  for (var i = 0; i < r.steps.length; i++)
                    i == 0 ? null : fade(0.45, tex(r.opening, 14)),
                ]),
                perStep([
                  for (var i = 0; i < r.steps.length; i++)
                    i == 0 ? null : gapH(12),
                ]),
                tex(perStep([for (final s in r.steps) s.shown]), 22),
                outcome(null, gapH(14), null),
                outcome(
                  null,
                  t('THE LIMIT IS', font: 'overline', color: 'forest'),
                  null,
                ),
                outcome(null, gapH(6), null),
                outcome(null, tex(r.result, 20), null),
              ],
            ),
            gap(16),
            ..._stacked([
              for (final m in LoopMove.values)
                _button(
                  m.index,
                  h: 56,
                  pad: [16, 0, 16, 0],
                  align: 'left',
                  tones: looks,
                  child: t(m.label, font: 'heading', size: 15),
                ),
            ]),
            ..._feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> nextLine() => _game(
  id: 'next-line',
  title: 'Which Line Comes Next',
  closing:
      'Differentiate the top on its own and the bottom on its own. The '
      'quotient rule is for the derivative of a fraction; this is the '
      'limit of one, and they are not the same job.',
  right: 'TOP AND BOTTOM',
  wrong: 'NOT THAT LINE',
  brief: briefJson(separatelyBrief, 'separatelyBrief'),
  rounds: [
    for (final r in nextLines)
      _round(
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          _overline('THE FORM IS INDETERMINATE'),
          gap(8),
          _ask('The rule applies. Which line is the one it gives you?'),
          gap(12),
          _card(tex(r.from, 19), fill: 'creamDark', border: false),
          gap(16),
          ..._stacked([
            for (final (i, o) in r.options.indexed)
              _button(
                i,
                minH: 72,
                pad: [14, 12, 14, 12],
                child: center(tex(o, 16)),
              ),
          ]),
          ..._feedback(),
        ],
      ),
  ],
);

Map<String, Object?> bothSides() {
  Node run(int i, bool up) => _button(
    i,
    w: null,
    pad: [12, 10, 12, 10],
    child: row([
      icon(up ? 'northEast' : 'southEast', size: 18, color: 'ink2'),
      gapW(8),
      flex(
        col([
          t(up ? 'runs up' : 'runs down', font: 'heading', size: 14),
          t(
            up ? 'to a big positive' : 'to a big negative',
            font: 'mono',
            size: 10,
            color: 'ink3',
          ),
        ], cross: 'start'),
      ),
    ]),
  );
  Node side(String arrow, String title, int first) => col([
    t('$arrow  $title', font: 'overline', color: 'ink2'),
    gapH(8),
    run(first, true),
    gapH(6),
    run(first + 1, false),
  ], cross: 'stretch');

  return _game(
    id: 'both-sides',
    type: 'pick-several',
    title: 'Both Sides',
    closing:
        'A number over zero blows up, and which way it blows up depends '
        'on the side you came from. The two-sided limit exists only when '
        'the two directions agree.',
    right: 'BOTH SIDES READ RIGHT',
    wrong: 'NOT BOTH',
    brief: briefJson(bothSidesBrief, 'bothSidesBrief'),
    rounds: [
      for (final r in sidesRounds)
        _round(
          options: const ['runs up', 'runs down', 'runs up', 'runs down'],
          answer: [r.leftPositive ? 0 : 1, r.rightPositive ? 2 : 3],
          why: r.why,
          source: r.source,
          more: {
            'groups': [
              [0, 1],
              [2, 3],
            ],
            'need': 2,
          },
          screen: [
            _overline('THE RULE IS OUT'),
            gap(8),
            _ask(
              'Substituting gave a number over zero. Report which way the '
              'fraction runs from each side.',
            ),
            gap(12),
            box(
              w: 'max',
              pad: [12, 16, 12, 12],
              fill: 'white',
              radius: 14,
              border: 'line',
              c: [
                tex('\\lim_{${r.point}}${r.expr}', 20),
                gapH(10),
                t(
                  '${r.top}, and the bottom goes to zero',
                  font: 'mono',
                  size: 11.5,
                  color: 'ink3',
                ),
              ],
            ),
            gap(16),
            _side(space: 10, cross: 'start', [
              side('→', 'COMING FROM THE LEFT', 0),
              side('←', 'COMING FROM THE RIGHT', 2),
            ]),
            gap(16, when: 'done'),
            box(
              w: 'max',
              pad: [0, 14, 0, 14],
              fill: 'creamDark',
              radius: 12,
              when: 'done',
              c: [
                t('SO THE LIMIT IS', font: 'overline', color: 'ink2'),
                gapH(6),
                tex(r.verdict, 18),
              ],
            ),
            ..._feedback(12),
          ],
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// 11 vectors

const _partColors = [AppColors.ember, AppColors.forest, AppColors.info];
const _partNames = ['ember', 'forest', 'info'];

Map<String, Object?> landTheResultant() {
  const span = 6;
  const h = 300.0;
  // Every lattice point, those farthest out first: a tap exactly halfway
  // between two points then goes to the outer one, as rounding does.
  final points = [
    for (var x = -span; x <= span; x++)
      for (var y = -span; y <= span; y++) (x, y),
  ]..sort((a, b) => (b.$1.abs() + b.$2.abs()) - (a.$1.abs() + a.$2.abs()));
  Object pin(Color color) => record(
    (canvas, size) => VectorPainter.drawMark(canvas, Offset.zero, color),
    h,
    what: 'land-the-resultant mark',
  );
  final targets = record(
    (canvas, size) {
      final g = GridGeometry(size, span: span);
      for (final (x, y) in points) {
        canvas.drawCircle(g.toScreen(x, y), g.step * 0.5, Paint());
      }
    },
    h,
    what: 'land-the-resultant points',
  );
  final ember = pin(AppColors.ember);
  final error = pin(AppColors.error);
  final forest = pin(AppColors.forest);

  String part(double v, String hat) {
    final sign = v < 0 ? '-' : '';
    return '$sign${v.abs().toStringAsFixed(0)}$hat';
  }

  return _game(
    id: 'land-the-resultant',
    title: 'Land the Resultant',
    closing:
        'Vectors add component by component, never length by length. '
        'Once the resultant is placed, its size is the square root of the '
        'squares, and that part belongs at a desk.',
    right: 'THAT IS WHERE',
    wrong: 'NOT THERE',
    brief: briefJson(vectorAddBrief, 'vectorAddBrief'),
    rounds: [
      for (final (n, r) in resultantRounds.indexed)
        _round(
          options: [for (final (x, y) in points) '($x, $y)'],
          answer: points.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            _overline('PUT IT WHERE IT LANDS'),
            gap(8),
            _ask(r.ask, size: 16, line: 1.5),
            gap(6),
            _note('Tap the point where the arrows add up to.'),
            gap(12),
            clip(
              box(
                w: 'max',
                h: h,
                child: grid({
                  'k': 'tapdraw',
                  'h': h,
                  'targets': targets,
                  'hits': [for (var i = 0; i < points.length; i++) i],
                  'axis': 'box',
                  'layers': [
                    {
                      'd': _both(
                        (answered) => record(
                          VectorPainter(
                            span: span,
                            lattice: true,
                            revealed: answered,
                            arrows: [
                              if (answered) ...r.chain,
                              for (var i = 0; i < r.parts.length; i++)
                                Arrow(
                                  r.parts[i],
                                  color: _partColors[i % 3],
                                  label: r.labels[i],
                                ),
                            ],
                          ).paint,
                          h,
                          what: 'land-the-resultant round $n $answered',
                        ),
                      ),
                    },
                    {
                      'pin': {'ask': ember, 'wrong': error},
                      'at': 'pick',
                    },
                    {
                      'pin': {'done': forest},
                      'at': 'truth',
                    },
                  ],
                }),
              ),
              16,
            ),
            gap(12),
            wrap(space: 10, run: 8, [
              for (var i = 0; i < r.parts.length; i++)
                box(
                  pad: [12, 8, 12, 8],
                  fill: 'white',
                  radius: 10,
                  border: _partNames[i % 3],
                  stroke: 1.5,
                  child: t(
                    '${r.labels[i]} = ${part(r.parts[i].x, 'i')} '
                    '${r.parts[i].y < 0 ? '-' : '+'} '
                    '${r.parts[i].y.abs().toStringAsFixed(0)}j',
                    font: 'mono',
                    size: 12.5,
                  ),
                ),
            ]),
            ..._feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> stretchIt() {
  const span = 8;
  const h = 270.0;
  const ks = [-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6];
  String component(double v, String hat, {bool signed = false}) {
    final rounded = (v * 100).round() / 100;
    final size = rounded.abs();
    final text = size == size.roundToDouble()
        ? size.toStringAsFixed(0)
        : size.toStringAsFixed(1);
    return '${signed && rounded < 0 ? '-' : ''}$text$hat';
  }

  return _game(
    id: 'stretch-it',
    title: 'Stretch It to Fit',
    closing:
        'A direction and a size are two separate things. The unit vector '
        'carries the direction, the multiplier carries the size, and a '
        'negative one turns it around.',
    right: 'THAT LENGTH',
    wrong: 'NOT THAT LONG',
    brief: briefJson(unitVectorBrief, 'unitVectorBrief'),
    rounds: [
      for (final (n, r) in stretchRounds.indexed)
        () {
          // The arrow alone, over the grid and the given arrow, which do
          // not change: in ember while it is being sized, then forest or
          // red.
          Object? arrow(int k, Color color) => k == 0
              ? null
              : record(
                  (canvas, size) {
                    canvas.clipRect(Offset.zero & size);
                    VectorPainter.drawArrow(
                      canvas,
                      GridGeometry(size, span: span),
                      Arrow(r.direction * k.toDouble(), color: color),
                    );
                  },
                  h,
                  what: 'stretch-it round $n times $k',
                );
          return _round(
            options: [for (final k in ks) '$k'],
            answer: ks.indexOf(r.answer),
            why: r.why,
            source: r.source,
            more: {'start': ks.indexOf(1)},
            screen: [
              _overline('SIZE IT ALONG THE LINE'),
              gap(8),
              _ask(
                'Make an arrow ${r.wantLength.toStringAsFixed(0)} long along '
                'this direction${r.opposite ? ', pointing the OTHER way.' : '.'}',
                size: 16,
                line: 1.5,
              ),
              gap(12),
              _card(tex(r.shown, 17), pad: [12, 14, 12, 14]),
              gap(12),
              clip(
                box(
                  w: 'max',
                  h: h,
                  child: grid({
                    'k': 'draw',
                    'layers': [
                      record(
                        VectorPainter(
                          span: span,
                          guide: r.direction,
                          arrows: [
                            Arrow(
                              r.direction,
                              color: AppColors.ink3,
                              faint: true,
                              label: 'given',
                            ),
                          ],
                        ).paint,
                        h,
                        what: 'stretch-it round $n',
                      ),
                      askDone(
                        {
                          'pick': [
                            for (final k in ks) arrow(k, AppColors.ember),
                          ],
                        },
                        {
                          'pick': [
                            for (final k in ks)
                              arrow(
                                k,
                                k == r.answer
                                    ? AppColors.forest
                                    : AppColors.error,
                              ),
                          ],
                        },
                      ),
                    ],
                  }),
                ),
                16,
              ),
              gap(12),
              box(
                pad: [12, 12, 12, 12],
                fill: 'white',
                radius: 14,
                border: 'line',
                c: [
                  row([
                    stepper(
                      -1,
                      fill: 'emberBg',
                      box(
                        w: 60,
                        h: 56,
                        child: icon('remove', size: 24, color: 'ember'),
                      ),
                    ),
                    flex(
                      col([
                        t('MULTIPLIER', font: 'overline', color: 'ink3'),
                        gapH(2),
                        t(
                          {
                            'pick': [for (final k in ks) '$k'],
                          },
                          font: 'heading',
                          size: 28,
                        ),
                      ]),
                    ),
                    stepper(
                      1,
                      fill: 'emberBg',
                      box(
                        w: 60,
                        h: 56,
                        child: icon('add', size: 24, color: 'ember'),
                      ),
                    ),
                  ]),
                  gapH(10),
                  box(
                    w: 'max',
                    pad: [0, 8, 0, 8],
                    fill: 'creamDark',
                    radius: 10,
                    child: t(
                      {
                        'pick': [
                          for (final k in ks)
                            () {
                              final s = r.direction * k.toDouble();
                              return '${component(s.x, 'i', signed: true)} '
                                  '${s.y < 0 ? '-' : '+'} '
                                  '${component(s.y, 'j')}';
                            }(),
                        ],
                      },
                      font: 'mono',
                      size: 14,
                      align: 'center',
                    ),
                  ),
                ],
              ),
              ..._feedback(),
            ],
          );
        }(),
    ],
  );
}

Map<String, Object?> reachesFurther() {
  // On screen as A, Same, B.
  const order = [Reach.first, Reach.same, Reach.second];
  const labels = ['A', 'Same', 'B'];
  const colors = ['ember', 'ink2', 'forest'];
  return _game(
    id: 'reaches-further',
    title: 'Which Reaches Further',
    closing:
        'Length is the square root of the squares, so it is never the '
        'components added up. Two arrows with nothing in common can be '
        'exactly the same length.',
    right: 'READ RIGHT',
    wrong: 'NOT THAT ONE',
    brief: briefJson(magnitudeBrief, 'magnitudeBrief'),
    rounds: [
      for (final (n, r) in reachRounds.indexed)
        _round(
          options: labels,
          answer: order.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            _overline('FURTHER FROM THE ORIGIN'),
            gap(8),
            _ask(
              'Which arrow is longer? They can also be the same.',
              size: 16,
              line: 1.5,
            ),
            gap(12),
            _pictured(
              VectorPainter(
                span: 7,
                arrows: [
                  Arrow(r.a, color: AppColors.ember, label: 'A'),
                  Arrow(r.b, color: AppColors.forest, label: 'B'),
                ],
              ).paint,
              290,
              'reaches-further round $n',
            ),
            gap(14),
            _side([
              for (var i = 0; i < 3; i++)
                _button(
                  i,
                  w: null,
                  h: 62,
                  align: 'center',
                  child: t(
                    labels[i],
                    font: 'heading',
                    size: 18,
                    // The letter wears its arrow's color until answered.
                    color: askDone(colors[i], 'charcoal'),
                  ),
                ),
            ]),
            ..._feedback(),
          ],
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// 12 dot product

Map<String, Object?> takeTheDiagonal() => _game(
  id: 'take-the-diagonal',
  type: 'pick-several',
  title: 'Take the Diagonal',
  closing:
      'Matching components only, signs kept, and the result is a '
      'number. If your answer has an i or a j in it you have done the '
      'cross product instead.',
  right: 'THE DIAGONAL',
  wrong: 'NOT THOSE CELLS',
  brief: briefJson(dotProductBrief, 'dotProductBrief'),
  rounds: [
    for (final r in diagonalRounds)
      () {
        String write(String name, List<int> v) {
          final parts = <String>[];
          for (var i = 0; i < v.length; i++) {
            final sign = v[i] < 0 ? '-' : (i == 0 ? '' : '+');
            parts.add('$sign${v[i].abs()}\\hat{${r.axes[i]}}');
          }
          return '\\vec{$name} = ${parts.join(' ')}';
        }

        final n = r.axes.length;
        return _round(
          options: [
            for (var y = 0; y < n; y++)
              for (var x = 0; x < n; x++) r.cell(y, x),
          ],
          answer: [for (var i = 0; i < n; i++) i * n + i],
          why: r.why,
          source: r.source,
          screen: [
            _overline('WHICH PRODUCTS GET ADDED'),
            gap(8),
            _ask(
              'Every possible pairing is here. Tap the ones that belong in '
              'the dot product.',
            ),
            gap(12),
            box(
              w: 'max',
              pad: [12, 14, 12, 14],
              fill: 'white',
              radius: 14,
              border: 'line',
              c: [tex(write('A', r.a), 16), gapH(8), tex(write('B', r.b), 16)],
            ),
            gap(14),
            col([
              row([
                gapW(30),
                for (var c = 0; c < n; c++)
                  flex(
                    t(
                      'B${r.axes[c]}',
                      font: 'overline',
                      color: 'ink2',
                      align: 'center',
                    ),
                  ),
              ]),
              gapH(6),
              for (var y = 0; y < n; y++) ...[
                if (y > 0) gapH(6),
                row([
                  box(
                    w: 30,
                    child: t('A${r.axes[y]}', font: 'overline', color: 'ink2'),
                  ),
                  for (var c = 0; c < n; c++) ...[
                    if (c > 0) gapW(6),
                    flex(
                      _button(
                        y * n + c,
                        w: null,
                        h: 54,
                        radius: 10,
                        align: 'center',
                        child: t(r.cell(y, c), font: 'mono', size: 13),
                      ),
                    ),
                  ],
                ]),
              ],
            ]),
            ..._feedback(),
          ],
        );
      }(),
  ],
);

/// Answer buttons laid side by side and holding a heading over a line of
/// mono, as the dot product games label their three answers.
Node _labelled(int i, String label, String detail, {required num h}) => _button(
  i,
  w: null,
  h: h,
  align: 'center',
  child: col(main: 'center', [
    t(label, font: 'heading', size: 15),
    gapH(2),
    t(detail, font: 'mono', size: 10, color: 'ink3'),
  ]),
);

Map<String, Object?> openOrClosed() => _game(
  id: 'open-or-closed',
  title: 'Open or Closed',
  closing:
      'The sign of a dot product is the sign of the cosine, because the '
      'two lengths are always positive. Under ninety, positive. Over '
      'ninety, negative. Exactly ninety, zero, and that is the '
      'perpendicularity test.',
  right: 'RIGHT SIGN',
  wrong: 'NOT THAT SIGN',
  brief: briefJson(dotAngleBrief, 'dotAngleBrief'),
  rounds: [
    for (final (n, r) in signRounds.indexed)
      _round(
        options: const ['Positive', 'Zero', 'Negative'],
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        more: {if (r.answer == DotSign.zero) 'right': 'PERPENDICULAR'},
        screen: [
          _overline('NO MULTIPLYING NEEDED'),
          gap(8),
          _ask(
            'Is the dot product of these two positive, zero, or negative?',
            size: 16,
            line: 1.5,
          ),
          gap(12),
          _pictured(
            VectorPainter(
              span: 7,
              between: (r.a, r.b),
              arrows: [
                Arrow(r.a, color: AppColors.ember, label: 'A'),
                Arrow(r.b, color: AppColors.forest, label: 'B'),
              ],
            ).paint,
            290,
            'open-or-closed round $n',
          ),
          gap(14),
          _side([
            _labelled(0, 'Positive', 'under 90', h: 66),
            _labelled(1, 'Zero', 'exactly 90', h: 66),
            _labelled(2, 'Negative', 'over 90', h: 66),
          ]),
          ..._feedback(),
        ],
      ),
  ],
);

/// A ring pinned to a mark: drawn once around the origin, and placed on
/// whichever mark is picked (or is right) by the pack.
Object _ring(Color color, double h, String what) => record(
  (canvas, size) => VectorPainter.drawMark(canvas, Offset.zero, color),
  h,
  what: what,
);

Map<String, Object?> shadowFalls() {
  const span = 8;
  const from = -4;
  const to = 7;
  const h = 320.0;
  final marks = [for (var i = from; i <= to; i++) i];
  final ember = _ring(AppColors.ember, h, 'shadow-falls ember ring');
  final error = _ring(AppColors.error, h, 'shadow-falls red ring');
  final forest = _ring(AppColors.forest, h, 'shadow-falls forest ring');
  return _game(
    id: 'shadow-falls',
    title: 'Where the Shadow Falls',
    closing:
        'The component of a force along a member is the dot product '
        'divided by the MEMBER length, never the force length, and never '
        'left undivided. Working the number out belongs at a desk.',
    right: 'THAT IS THE SHADOW',
    wrong: 'NOT THAT FAR',
    brief: briefJson(projectionBrief, 'projectionBrief'),
    rounds: [
      for (final (n, r) in shadowRounds.indexed)
        _round(
          options: [for (final i in marks) '$i'],
          answer: marks.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            _overline('HOW MUCH LANDS ON THE MEMBER'),
            gap(8),
            _ask(
              'Drop the force onto the member and tap the mark its shadow '
              'reaches.',
              size: 16,
              line: 1.5,
            ),
            gap(6),
            _note(
              'The member runs along ${r.memberPlain}, marked off in whole '
              'units.',
            ),
            gap(12),
            clip(
              box(
                w: 'max',
                h: h,
                child: grid({
                  'k': 'tapdraw',
                  'h': h,
                  // A mark is taken within a mark and a half of a tap, the
                  // nearest one, the lower of two equally near.
                  'targets': record(
                    (canvas, size) {
                      final g = GridGeometry(size, span: span);
                      for (final i in marks) {
                        canvas.drawCircle(
                          g.at(r.unit.x * i, r.unit.y * i),
                          g.step * 1.5,
                          Paint(),
                        );
                      }
                    },
                    h,
                    what: 'shadow-falls round $n marks',
                  ),
                  'hits': [for (var i = 0; i < marks.length; i++) i],
                  'layers': [
                    {
                      'd': _both(
                        (answered) => record(
                          VectorPainter(
                            span: span,
                            ruler: RulerLine(unit: r.unit, from: from, to: to),
                            revealed: answered,
                            drop: answered ? r.force : null,
                            arrows: [
                              Arrow(
                                r.force,
                                color: AppColors.ember,
                                label: 'F',
                              ),
                            ],
                          ).paint,
                          h,
                          what: 'shadow-falls round $n $answered',
                        ),
                      ),
                    },
                    {
                      'pin': {'ask': ember, 'wrong': error},
                      'at': 'pick',
                    },
                    {
                      'pin': {'done': forest},
                      'at': 'truth',
                    },
                  ],
                }),
              ),
              16,
            ),
            gap(12),
            row([
              t('Shadow at', font: 'mono', size: 12, color: 'ink2'),
              gapW(8),
              box(
                pad: [14, 5, 14, 5],
                fill: 'emberBg',
                radius: 8,
                child: t(
                  {
                    'pick': [for (final i in marks) '$i'],
                    'none': '?',
                  },
                  font: 'mono',
                  size: 14,
                  color: 'ember',
                ),
              ),
            ]),
            ..._feedback(),
          ],
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// 13 cross product

/// The cross product games' cards: a drawing over a name, the drawing
/// taking the card's color (ink, then ember, forest or red).
Node _drawnCard(
  int i,
  Draw Function(Color color) paint,
  double h,
  List<Node> under,
  String what,
) {
  Object drawn(Color c, String name) =>
      record(paint(c), h, range: (40, 400), what: '$what $name');
  return _button(
    i,
    w: null,
    pad: [4, 10, 4, 10],
    child: col([
      box(
        w: 'max',
        h: h,
        child: draw(
          tone(
            drawn(AppColors.ink2, 'ink'),
            drawn(AppColors.ember, 'ember'),
            drawn(AppColors.forest, 'forest'),
            drawn(AppColors.error, 'red'),
          ),
        ),
      ),
      gapH(6),
      ...under,
    ]),
  );
}

Map<String, Object?> whichWayTurns() {
  const labels = [
    ('Counter\nclockwise', 'out of the page'),
    ('Clockwise', 'into the page'),
    ('No turn', 'the cross is zero'),
  ];
  // Each card's glyph drawn once in each of its four colors, shared by
  // every round.
  final cards = [
    for (final turn in Turn.values)
      _drawnCard(
        turn.index,
        (c) => TurnGlyphPainter(turn: turn, color: c).paint,
        46,
        [
          box(
            h: 34,
            child: t(
              labels[turn.index].$1,
              font: 'heading',
              size: 12.5,
              line: 1.2,
              align: 'center',
            ),
          ),
          gapH(2),
          t(
            labels[turn.index].$2,
            font: 'mono',
            size: 9,
            color: 'ink3',
            align: 'center',
          ),
        ],
        'which-way-turns ${turn.name}',
      ),
  ];
  return _game(
    id: 'which-way-turns',
    title: 'Which Way Does It Turn',
    closing:
        'Sweep from the first arrow to the second: counterclockwise means '
        'the cross product comes out of the page, clockwise means it goes '
        'in, and two arrows on one line turn nothing. Swapping the order '
        'swaps the answer.',
    right: 'THAT WAY',
    wrong: 'THE OTHER WAY',
    brief: briefJson(rightHandBrief, 'rightHandBrief'),
    rounds: [
      for (final (n, r) in turnRounds.indexed)
        _round(
          options: const ['Counterclockwise', 'Clockwise', 'No turn'],
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          more: {if (r.answer == Turn.none) 'right': 'NOTHING TURNS'},
          screen: [
            _overline('SWEEP FROM THE FIRST TO THE SECOND'),
            gap(8),
            _ask(r.ask, size: 16, line: 1.5),
            gap(6),
            _note(
              'Which way does ${r.firstLabel} cross ${r.secondLabel} turn?',
            ),
            gap(12),
            _pictured(
              VectorPainter(
                span: 6,
                between: (r.first, r.second),
                arrows: [
                  Arrow(r.first, color: AppColors.ember, label: r.firstLabel),
                  Arrow(
                    r.second,
                    color: AppColors.forest,
                    label: r.secondLabel,
                  ),
                ],
              ).paint,
              280,
              'which-way-turns round $n',
            ),
            gap(14),
            _side(cards),
            ..._feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichRegion() {
  const names = ['Triangle', 'Parallelogram', 'Box around it'];
  return _game(
    id: 'which-region',
    title: 'Which Region',
    closing:
        'The cross product measures the parallelogram. A triangle is half '
        'of it, and the two lengths multiplied without the sine are a box '
        'that is too big. Which one you hand in is decided by the '
        'question, not the formula.',
    right: 'THAT SHAPE',
    wrong: 'NOT THAT SHAPE',
    brief: briefJson(areaBrief, 'areaBrief'),
    rounds: [
      for (final (n, r) in regionRounds.indexed)
        _round(
          options: names,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            _overline('THE SAME TWO EDGES, THREE WAYS'),
            gap(8),
            _ask(r.ask, size: 16, line: 1.5),
            gap(12),
            _card(tex(r.formula, 18), pad: [12, 14, 12, 14]),
            gap(14),
            _side(cross: 'start', [
              for (final region in Region.values)
                _drawnCard(
                  region.index,
                  (c) => RegionPainter(
                    u: r.u,
                    v: r.v,
                    region: region,
                    color: c,
                  ).paint,
                  82,
                  [
                    t(
                      names[region.index],
                      font: 'heading',
                      size: 12,
                      line: 1.15,
                      align: 'center',
                    ),
                  ],
                  'which-region round $n ${region.name}',
                ),
            ]),
            ..._feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> fixTheSign() {
  const axes = ['i', 'j', 'k'];
  return _game(
    id: 'fix-the-sign',
    title: 'Fix the Sign',
    closing:
        'Plus, minus, plus across the three components. The middle one is '
        'subtracted every single time, and a minus in front of a negative '
        'bracket is where the moments go backwards.',
    right: 'THAT IS THE ONE',
    wrong: 'NOT THAT LINE',
    brief: briefJson(cofactorBrief, 'cofactorBrief'),
    rounds: [
      for (final r in expansions)
        _round(
          options: [
            for (var i = 0; i < r.terms.length; i++) axes[i],
            'All three signs are right',
          ],
          answer: r.bad ?? r.terms.length,
          why: r.why,
          source: r.source,
          more: {if (r.bad == null) 'right': 'ALL THREE STAND'},
          screen: [
            _overline('PLUS, MINUS, PLUS'),
            gap(8),
            _ask(
              'One line may have the wrong sign. Tap it, or say the whole '
              'thing is right.',
            ),
            gap(12),
            box(
              w: 'max',
              pad: [10, 12, 10, 12],
              fill: 'creamDark',
              radius: 12,
              child: tex(r.setup, 14),
            ),
            gap(12),
            ..._stacked([
              for (var i = 0; i < r.terms.length; i++)
                _button(
                  i,
                  pad: [12, 12, 12, 12],
                  child: row([
                    box(
                      w: 22,
                      child: t(axes[i], font: 'mono', size: 15, color: 'ink2'),
                    ),
                    flex(
                      tex(
                        '${r.terms[i].working} = ${r.terms[i].value}',
                        15,
                        align: 'left',
                      ),
                    ),
                  ]),
                ),
            ]),
            gap(10),
            _button(
              r.terms.length,
              h: 52,
              align: 'center',
              child: t(
                'All three signs are right',
                font: 'heading',
                size: 14.5,
              ),
            ),
            ..._feedback(),
          ],
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// 14 spreadsheets

/// The formula bar over the sheet: the cell, then what it holds.
Node _formulaBar(String cell, String formula) => box(
  w: 'max',
  pad: [10, 10, 10, 10],
  fill: 'white',
  radius: 10,
  border: 'line',
  child: row([
    box(
      pad: [8, 3, 8, 3],
      fill: 'sunbeamBg',
      radius: 6,
      child: t(cell, font: 'mono', size: 12),
    ),
    gapW(10),
    flex(t(formula, font: 'code', size: 14)),
  ]),
);

/// A small spreadsheet: lettered columns, numbered rows, and each cell
/// as [cell] draws it.
Node _sheet(List<String> columns, int rows, Node Function(String name) cell) =>
    box(
      fill: 'white',
      radius: 12,
      border: 'line',
      clip: true,
      c: [
        row([
          box(w: 30, h: 26),
          for (final c in columns)
            flex(
              box(
                h: 26,
                align: 'center',
                fill: 'creamDark',
                child: t(c, font: 'mono', size: 11, color: 'ink2'),
              ),
            ),
        ]),
        for (var r = 1; r <= rows; r++)
          row([
            box(
              w: 30,
              h: 42,
              align: 'center',
              fill: 'creamDark',
              child: t('$r', font: 'mono', size: 11, color: 'ink2'),
            ),
            for (final c in columns) flex(cell('$c$r')),
          ]),
      ],
    );

/// A cell as it sits, with nothing to tap.
Node _plainCell(String text) => box(
  h: 42,
  align: 'center',
  fill: 'white',
  border: 'line',
  child: t(text, font: 'mono', size: 13),
);

Map<String, Object?> copyItDown() {
  const columns = ['A', 'B', 'C', 'D'];
  const rows = 4;
  final cells = [
    for (var r = 1; r <= rows; r++)
      for (final c in columns) '$c$r',
  ];
  Node key(String color, String label) => row(min: true, [
    box(w: 11, h: 11, border: color, stroke: 2, radius: 2),
    gapW(5),
    t(label, font: 'mono', size: 10.5, color: 'ink3'),
  ]);
  return _game(
    id: 'copy-it-down',
    type: 'pick-several',
    title: 'Copy It Down',
    closing:
        'A plain reference moves with the copy and a dollar sign pins '
        'whatever comes straight after it. Nothing tells you which you '
        'need except knowing what has to stay put, and the rate is almost '
        'always the thing that stays put.',
    right: 'BOTH LANDED',
    wrong: 'NOT THOSE CELLS',
    brief: briefJson(referencesBrief, 'referencesBrief'),
    rounds: [
      for (final r in copyRounds)
        _round(
          options: cells,
          answer: [
            for (final (i, c) in cells.indexed)
              if (r.answer.contains(c)) i,
          ],
          why: r.why,
          source: r.source,
          screen: [
            _overline('WHERE DOES IT POINT AFTER THE COPY'),
            gap(8),
            _ask(
              'This formula is copied from ${r.from} to ${r.to}. Tap the '
              'cells the copy reads.',
              size: 16,
              line: 1.5,
            ),
            gap(12),
            _formulaBar(r.from, r.formula),
            gap(12),
            _sheet(columns, rows, (name) {
              // The cell holding the formula and the one it is copied
              // into wear their own look until something is picked.
              final (fill, border, width) = name == r.from
                  ? ('sunbeamBg', 'sunbeam', 2)
                  : name == r.to
                  ? ('creamDark', 'ink3', 2)
                  : ('white', 'line', 1);
              return answer(
                cells.indexOf(name),
                // The fill sits in the cell, not under it, as the
                // built-in cell paints it: a fill under it lands on
                // part pixels a shade differently.
                box(
                  h: 42,
                  align: 'center',
                  fill: tone(fill, 'emberBg', 'forestBg', 'errorBg'),
                  border: tone(border, 'ember', 'forest', 'error'),
                  stroke: tone(width, 2, 2, 2),
                  child: t(sheetValues[name] ?? '', font: 'mono', size: 13),
                ),
                radius: 0,
                key: 'cell-$name',
                // A bare tap area, as the built-in cell is: no ripple.
                plain: true,
              );
            }),
            gap(10),
            row([
              key('sunbeam', 'holds the formula'),
              gapW(14),
              key('ink3', 'copied into'),
            ]),
            ..._feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> happensFirst() {
  bool glue(String piece) =>
      piece == '=' || const ['+', '-', '*', '/', '^'].contains(piece);
  return _game(
    id: 'happens-first',
    title: 'Which Happens First',
    closing:
        'Brackets, then powers, then times and divide, then plus and '
        'minus, and same rank goes left to right. A spreadsheet never '
        'reads a formula the way you read a sentence.',
    right: 'THAT ONE FIRST',
    wrong: 'NOT FIRST',
    brief: briefJson(precedenceBrief, 'precedenceBrief'),
    rounds: [
      for (final r in precedenceRounds)
        () {
          // Only the pieces that get worked out are answers; the operators
          // between them sit in the formula with nothing to tap.
          final pieces = [
            for (final (i, p) in r.pieces.indexed)
              if (!glue(p)) i,
          ];
          return _round(
            options: [for (final i in pieces) r.pieces[i]],
            answer: pieces.indexOf(r.answer),
            why: r.why,
            source: r.source,
            screen: [
              _overline('NOT LEFT TO RIGHT'),
              gap(8),
              _ask(
                'Tap the part of this formula the spreadsheet works out '
                'first.',
                size: 16,
                line: 1.5,
              ),
              gap(6),
              _note('A1 = 2, A2 = 3, A3 = 4'),
              gap(14),
              box(
                w: 'max',
                pad: [10, 18, 10, 18],
                fill: 'white',
                radius: 14,
                border: 'line',
                child: wrap(center: true, space: 6, run: 8, [
                  for (final (i, p) in r.pieces.indexed)
                    if (glue(p))
                      box(
                        minH: 54,
                        pad: [2, 0, 2, 0],
                        child: center(
                          wf: 1,
                          t(p, font: 'mono', size: 16, color: 'ink2'),
                        ),
                      )
                    else
                      _button(
                        pieces.indexOf(i),
                        w: null,
                        minW: 54,
                        minH: 54,
                        pad: [12, 8, 12, 8],
                        radius: 10,
                        key: 'piece-$i',
                        // A tap area under a painted box, not an inked
                        // button, as the built-in piece is.
                        painted: true,
                        child: center(wf: 1, t(p, font: 'mono', size: 16)),
                      ),
                ]),
              ),
              ..._feedback(),
            ],
          );
        }(),
    ],
  );
}

Map<String, Object?> whatShows() => _game(
  id: 'what-shows',
  title: 'What Does the Cell Show',
  closing:
      'A cell holds a formula and shows a result. IF returns one '
      'branch or the other and never a 1, COUNT ignores anything that '
      'is not a number, and a colon always means every cell in between.',
  right: 'THAT IS THE DISPLAY',
  wrong: 'NOT THAT',
  brief: briefJson(functionsBrief, 'functionsBrief'),
  rounds: [
    for (final r in showsRounds)
      _round(
        options: r.options,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          _overline('THE FORMULA, AND WHAT IT DISPLAYS'),
          gap(8),
          _ask(
            'Cell ${r.cell} holds this. What does it show?',
            size: 16,
            line: 1.5,
          ),
          gap(12),
          _formulaBar(r.cell, r.formula),
          gap(12),
          _sheet(
            const ['A', 'B'],
            4,
            (name) => _plainCell(r.values[name] ?? ''),
          ),
          gap(14),
          _side([
            for (final (i, o) in r.options.indexed)
              _button(
                i,
                w: null,
                h: 58,
                align: 'center',
                child: t(o, font: 'mono', size: 16),
              ),
          ]),
          ..._feedback(),
        ],
      ),
  ],
);

// ---------------------------------------------------------------------------
// 15 programming

/// The dark box the programming games set their code in, one line each.
Node _codeLines(List<String> lines) => _code([
  for (final line in lines)
    box(
      pad: [0, 2, 0, 2],
      child: t(line, font: 'code', size: 13.5, color: 'onScreen'),
    ),
]);

Map<String, Object?> fillTheTrace() => _game(
  id: 'fill-the-trace',
  type: 'pick-several',
  title: 'Fill the Trace',
  closing:
      'A loop from one to four runs four times, both ends included, and '
      'the way to be sure is to write the rows out. The answer is the '
      'last row, not the number of rows.',
  right: 'THE WHOLE TRACE',
  wrong: 'A ROW IS WRONG',
  brief: briefJson(tracingBrief, 'tracingBrief'),
  rounds: [
    for (final r in traceRounds)
      () {
        Node head(String text) => box(
          h: 28,
          align: 'center',
          fill: 'creamDark',
          child: t(text, font: 'overline', color: 'ink2'),
        );
        Node body(String text) => box(
          h: 46,
          align: 'center',
          border: 'line',
          edge: 'top',
          child: t(text, font: 'mono', size: 14, color: 'ink2'),
        );
        // A row's value slot: ember while it is the next to fill, cream
        // once filled, then forest or red with the right value beside a
        // wrong one.
        Node slotOf(int k) {
          Object state(
            Object right,
            Object wrong,
            Object next,
            Object full,
            Object empty,
          ) => fillState(
            k,
            right: right,
            wrong: wrong,
            next: next,
            full: full,
            empty: empty,
          );
          return unslot(
            k,
            box(
              h: 46,
              align: 'center',
              fill: state(
                'forestBg',
                'errorBg',
                'emberBg',
                'creamDark',
                'white',
              ),
              border: 'line',
              edge: 'topLeft',
              child: box(
                w: 62,
                h: 32,
                align: 'center',
                radius: 8,
                border: state('forest', 'error', 'ember', 'line', 'line'),
                stroke: state(2, 2, 2, 1, 1),
                child: t(
                  state(
                    slot(k, r.choices),
                    slot(k, [for (final c in r.choices) '$c / ${r.answer[k]}']),
                    '',
                    slot(k, r.choices),
                    '',
                  ),
                  font: 'mono',
                  size: 13,
                ),
              ),
            ),
          );
        }

        return _round(
          options: r.choices,
          answer: [for (final a in r.answer) r.choices.indexOf(a)],
          why: r.why,
          source: r.source,
          more: {'order': 'fill', 'need': r.counters.length},
          screen: [
            _overline('ONE ROW PER PASS'),
            gap(8),
            _ask(
              'Fill in what ${r.variable} holds after each pass.',
              size: 16,
              line: 1.5,
            ),
            gap(12),
            _codeLines(r.code),
            gap(14),
            box(
              fill: 'white',
              radius: 12,
              border: 'line',
              clip: true,
              c: [
                row([
                  flex(head('pass')),
                  flex(head('i')),
                  flex(head(r.variable), 2),
                ]),
                for (var k = 0; k < r.counters.length; k++)
                  row([
                    flex(body('${k + 1}')),
                    flex(body('${r.counters[k]}')),
                    flex(slotOf(k), 2),
                  ]),
              ],
            ),
            gap(12),
            wrap(space: 8, run: 8, [
              for (final (i, c) in r.choices.indexed)
                answer(
                  i,
                  box(
                    w: 62,
                    h: 48,
                    align: 'center',
                    radius: 10,
                    border: 'line',
                    child: t(c, font: 'mono', size: 15),
                  ),
                  radius: 10,
                  fill: 'white',
                ),
            ]),
            ..._feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> firstTrueWins() => _game(
  id: 'first-true-wins',
  title: 'First True Wins',
  closing:
      'Conditions are read from the top and the chain stops at the '
      'first one that holds. A later test that would also have been '
      'true never gets its turn, and the closing ELSE only runs when '
      'every test above it has failed.',
  right: 'THAT BRANCH',
  wrong: 'NOT THAT BRANCH',
  brief: briefJson(selectionBrief, 'selectionBrief'),
  rounds: [
    for (final r in chainRounds)
      _round(
        options: [
          for (final b in r.branches)
            b.test == null ? b.body : '${b.test}  →  ${b.body}',
        ],
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          _overline('TOP TO BOTTOM, STOP AT THE FIRST'),
          gap(8),
          _ask('Tap the branch that actually runs.', size: 16, line: 1.5),
          gap(12),
          _code([t(r.given, font: 'code', size: 14, color: 'onScreen')]),
          gap(10),
          ..._stacked([
            for (final (i, b) in r.branches.indexed)
              _button(
                i,
                pad: [14, 12, 14, 12],
                child: row([
                  box(
                    w: 58,
                    child: t(
                      b.test == null ? 'ELSE' : (i == 0 ? 'IF' : 'ELSE IF'),
                      font: 'overline',
                      color: 'ink2',
                    ),
                  ),
                  flex(
                    t(
                      b.test == null ? b.body : '${b.test}  →  ${b.body}',
                      font: 'code',
                      size: 14,
                    ),
                  ),
                ]),
              ),
          ]),
          ..._feedback(),
        ],
      ),
  ],
);

Map<String, Object?> whereItStops() => _game(
  id: 'where-it-stops',
  title: 'Where It Stops',
  closing:
      'The condition is checked before the body, so the value left in '
      'the variable is the one that broke it. Nothing is capped at the '
      'limit, and a loop whose condition fails at the first look never '
      'runs at all.',
  right: 'THAT IS WHAT IS LEFT',
  wrong: 'NOT THAT',
  brief: briefJson(iterationBrief, 'iterationBrief'),
  rounds: [
    for (final r in whileRounds)
      _round(
        options: [for (final v in r.run) '$v'],
        answer: r.run.indexOf(r.answer),
        why: r.why,
        source: r.source,
        screen: [
          _overline('THE VALUE THAT BREAKS IT'),
          gap(8),
          _ask(
            'Tap the value left in the variable when the loop stops.',
            size: 16,
            line: 1.5,
          ),
          gap(12),
          _code([
            for (final line in [
              r.start,
              'WHILE ${r.condition}',
              '    ${r.step}',
            ])
              t(line, font: 'code', size: 13.5, color: 'onScreen'),
          ]),
          gap(14),
          t('EVERY VALUE IT TAKES', font: 'overline', color: 'ink2'),
          gap(8),
          wrap(space: 8, run: 8, [
            for (final (i, v) in r.run.indexed)
              _button(
                i,
                w: null,
                h: 52,
                minW: 62,
                pad: [10, 0, 10, 0],
                radius: 10,
                child: center(wf: 1, t('$v', font: 'mono', size: 15)),
              ),
          ]),
          ..._feedback(),
        ],
      ),
  ],
);

// ---------------------------------------------------------------------------
// 16 numerical methods

/// A number as the root finding games write one: whole when it is.
String _number(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

Map<String, Object?> followTheTangent() => _game(
  id: 'follow-the-tangent',
  title: 'Follow the Tangent',
  closing:
      'One iteration slides down the tangent to the axis and stops '
      'there. It lands short of the root, on the far side of a flat '
      'slope, or exactly on it if the function was a line. Grinding out '
      'the arithmetic belongs at a desk.',
  right: 'THAT IS THE LANDING',
  wrong: 'NOT THERE',
  brief: briefJson(newtonBrief, 'newtonBrief'),
  rounds: [
    for (final (n, r) in tangentRounds.indexed)
      _round(
        options: [for (final c in r.candidates) _number(c)],
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          _overline('ONE ITERATION, ON THE PICTURE'),
          gap(8),
          _ask('Where does one step of Newton leave you?', size: 16, line: 1.5),
          gap(12),
          _card(
            tex('${r.shown}, \\quad x_0 = ${_number(r.start)}', 16),
            pad: [12, 14, 12, 14],
          ),
          gap(12),
          pictured(
            perPick(
              (pick, answered) => RootPainter(
                poly: r.poly,
                x0: r.from,
                x1: r.to,
                tangentAt: r.start,
                candidates: r.candidates,
                picked: pick,
                truth: answered ? r.answer : null,
                revealed: answered,
              ).paint,
              r.candidates.length,
              260,
              what: 'follow-the-tangent round $n',
            ),
            260,
          ),
          gap(14),
          _side([
            for (final (i, c) in r.candidates.indexed)
              _button(
                i,
                w: null,
                h: 56,
                align: 'center',
                child: t(_number(c), font: 'mono', size: 15),
              ),
          ]),
          ..._feedback(),
        ],
      ),
  ],
);

Map<String, Object?> canItStart() => _game(
  id: 'can-it-start',
  title: 'Can It Start Here',
  closing:
      'Bisection needs the two ends on opposite sides of the axis and '
      'nothing else. A span can hold two roots and still fail the test, '
      'and a curve with no roots fails it everywhere.',
  right: 'THAT SPAN',
  wrong: 'NOT THAT SPAN',
  brief: briefJson(bisectionBrief, 'bisectionBrief'),
  rounds: [
    for (final (n, r) in bracketRounds.indexed)
      () {
        final spans = r.brackets.length;
        return _round(
          options: [
            for (var i = 0; i < spans; i++) String.fromCharCode(65 + i),
            'None of them will do',
          ],
          answer: r.answer ?? spans,
          why: r.why,
          source: r.source,
          more: {if (r.answer == null) 'right': 'NONE OF THEM, CORRECTLY'},
          screen: [
            _overline('OPPOSITE SIDES OF THE AXIS'),
            gap(8),
            _ask(
              'Which span can bisection be started on?',
              size: 16,
              line: 1.5,
            ),
            gap(6),
            _note(r.shown),
            gap(12),
            pictured(
              perPick(
                (pick, answered) => RootPainter(
                  poly: r.poly,
                  x0: r.from,
                  x1: r.to,
                  brackets: r.brackets,
                  // "None of them" is drawn as no span picked.
                  pickedBracket: pick == null
                      ? null
                      : pick == spans
                      ? -1
                      : pick,
                  truthBracket: answered ? r.answer : null,
                  revealed: answered,
                ).paint,
                spans + 1,
                280,
                what: 'can-it-start round $n',
              ),
              280,
            ),
            gap(14),
            _side([
              for (var i = 0; i < spans; i++)
                _button(
                  i,
                  w: null,
                  h: 56,
                  align: 'center',
                  child: t(
                    String.fromCharCode(65 + i),
                    font: 'heading',
                    size: 17,
                  ),
                ),
            ]),
            gap(8),
            _button(
              spans,
              h: 52,
              align: 'center',
              child: t('None of them will do', font: 'heading', size: 14.5),
            ),
            ..._feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichMethod() {
  const labels = [
    ("Newton's method", 'fast, wants the derivative'),
    ('Bisection', 'slow, wants a sign change'),
    ('Newton, but it may not converge', 'the tangent will not help here'),
  ];
  return _game(
    id: 'which-method',
    title: 'Which Method',
    closing:
        'Newton is fast and wants a derivative and a decent guess. '
        'Bisection is slow and wants nothing but a sign change. Knowing '
        'which one the situation allows is most of what this topic asks.',
    right: 'THAT IS THE ONE',
    wrong: 'NOT THAT ONE',
    brief: briefJson(methodChoiceBrief, 'methodChoiceBrief'),
    rounds: [
      for (final r in methodRounds)
        _round(
          options: [for (final (label, _) in labels) label],
          answer: MethodPick.values.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            _overline('WHAT THE SITUATION ALLOWS'),
            gap(8),
            _card(
              t(r.situation, size: 15.5, line: 1.55),
              pad: [16, 16, 16, 16],
            ),
            gap(14),
            ..._stacked([
              for (final (i, (label, detail)) in labels.indexed)
                _button(
                  i,
                  pad: [16, 12, 16, 12],
                  cross: 'start',
                  c: [
                    t(label, font: 'heading', size: 15),
                    gapH(3),
                    t(detail, font: 'mono', size: 10.5, color: 'ink3'),
                  ],
                ),
            ]),
            ..._feedback(),
          ],
        ),
    ],
  );
}
