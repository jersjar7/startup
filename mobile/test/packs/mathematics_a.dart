import 'dart:math' show atan2;
import 'dart:ui';

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/packs/drawing/figure_path.dart' as fp;
import 'package:mobile/features/packs/drawing/recording_canvas.dart';
import 'package:mobile/features/games/balance_both_sides_game.dart'
    show Balance, balances;
import 'package:mobile/features/games/build_the_identity_game.dart'
    show identities;
import 'package:mobile/features/games/discriminant_gate_game.dart'
    show GateAsk, Para, ParaPainter, gateRounds;
import 'package:mobile/features/games/every_rule_game.dart'
    show DerivRule, ruleRounds;
import 'package:mobile/features/games/find_the_slip_game.dart' show slips;
import 'package:mobile/features/games/grade_sense_game.dart'
    show GradeRound, Stretch, gradeRounds;
import 'package:mobile/features/games/calculus_figures.dart'
    show CurveGeometry, CurvePainter;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/sign_the_bend_game.dart'
    show ArcPainter, bendRounds;
import 'package:mobile/features/games/acute_or_obtuse_game.dart'
    show AngleKind, AngleKindName, verdicts;
import 'package:mobile/features/games/oblique_figures.dart'
    show ObliqueTrianglePainter;
import 'package:mobile/features/games/one_log_game.dart' show collapses;
import 'package:mobile/features/games/grid_figures.dart'
    show GridGeometry, GridPainter;
import 'package:mobile/features/games/place_the_center_game.dart'
    show centerRounds;
import 'package:mobile/features/games/point_at_the_inside_game.dart'
    show insideRounds;
import 'package:mobile/features/games/quadrant_signs_game.dart'
    show quadrantRounds;
import 'package:mobile/features/games/read_the_equation_game.dart'
    show readRounds;
import 'package:mobile/features/games/resolve_it_game.dart' show resolves;
import 'package:mobile/features/games/slide_to_flat_game.dart' show flatRounds;
import 'package:mobile/features/games/tap_the_side_game.dart' show sideRounds;
import 'package:mobile/features/games/trig_figures.dart'
    show
        ForcePainter,
        TriRatio,
        TriRatioName,
        TriSide,
        TriSideName,
        TriangleGeometry,
        TrianglePainter;
import 'package:mobile/features/games/unit_circle_figures.dart'
    show CircleGeometry, UnitCirclePainter, unitCirclePoints;
import 'package:mobile/features/games/what_was_asked_game.dart'
    show askedRounds;
import 'package:mobile/features/games/walk_the_circle_game.dart'
    show circleRounds;
import 'package:mobile/features/games/which_law_game.dart' show lawRounds;
import 'package:mobile/features/games/which_ratio_game.dart'
    show RatioRound, ratioRounds;
import 'package:mobile/features/games/order_the_moves_game.dart' show moveSets;
import 'package:mobile/features/games/rule_or_trap_game.dart' show claims;
import 'package:mobile/features/games/set_it_up_game.dart' show setups;
import 'package:mobile/features/games/perpendicular_flip_game.dart'
    show Ask, LinesPainter, Round, Slope, flipRounds;

import 'builder.dart';
import 'nodes.dart';
import 'pick_one_adapter.dart';

/// The Mathematics games, first half: straight lines and quadratics,
/// logarithms, trigonometry, the unit circle, identities, conics, algebra
/// rules, and the first of calculus. Each screen is written as the game's
/// own widgets are, in screen nodes, since hardly two of these games share
/// a layout.

/// Every game here, by id.
final adapters = <String, Map<String, Object?> Function()>{
  'perpendicular-flip': perpendicularFlip,
  'discriminant-gate': discriminantGate,
  'grade-sense': gradeSense,
  'order-the-moves': orderTheMoves,
  'rule-or-trap': ruleOrTrap,
  'one-log': oneLog,
  'set-it-up': setItUp,
  'tap-the-side': tapTheSide,
  'which-ratio': whichRatio,
  'resolve-it': resolveIt,
  'which-law': whichLaw,
  'acute-or-obtuse': acuteOrObtuse,
  'walk-the-circle': walkTheCircle,
  'quadrant-signs': quadrantSigns,
  'build-the-identity': buildTheIdentity,
  'place-the-center': placeTheCenter,
  'read-the-equation': readTheEquation,
  'point-at-the-inside': pointAtTheInside,
  'balance-both-sides': balanceBothSides,
  'sign-the-bend': signTheBend,
  'what-was-asked': whatWasAsked,
  'every-rule': everyRule,
  'find-the-slip': findTheSlip,
  'slide-to-flat': slideToFlat,
};

// Small builders for what these games draw that nodes.dart does not name.

/// [n] with more keys.
Node more(Node n, Map<String, Object?> extra) => {...n, ...extra};

/// A game with more keys of its own, and more on each round.
Map<String, Object?> game(
  Map<String, Object?> built,
  Map<String, Object?> extra, [
  Map<String, Object?> Function(int round)? round,
]) => {
  ...built,
  ...extra,
  if (round != null)
    'rounds': [
      for (final (i, r) in (built['rounds']! as List).indexed)
        <String, Object?>{...(r as Map), ...round(i)},
    ],
};

/// A value while the round is open, then once won, then once lost.
Map<String, Object?> openWonLost(Object? open, Object? won, Object? lost) => {
  'open': open,
  'won': won,
  'lost': lost,
};

/// A value keyed by what is picked: the picks in the order made, or with
/// [sorted] smallest first, joined by commas ('' for none).
Map<String, Object?> byPicks(
  Map<String, Object?> each, {
  bool sorted = false,
  Object? otherwise,
}) => {'picks': each, if (sorted) 'sorted': true, 'else': otherwise};

/// A value by whether answer [of] (or the answer it sits in) is picked.
Map<String, Object?> onOff(Object? on, Object? off, {int? of}) => {
  'on': on,
  'off': off,
  'of': ?of,
};

/// An overline as its own words, in a color.
Node overlineNode(String v, {String color = 'ink3'}) =>
    t(v, font: 'overline', color: color);

/// Every subset of answers 0 to [n] - 1, as the keys [byPicks] sorts to.
List<List<int>> subsets(int n) => [
  for (var mask = 0; mask < 1 << n; mask++)
    [
      for (var i = 0; i < n; i++)
        if (mask & (1 << i) != 0) i,
    ],
];

String keyOf(List<int> picks) => picks.join(',');

// Perpendicular Flip

Map<String, Object?> perpendicularFlip() {
  Slope built(Slope s, List<int> picks) {
    var b = s;
    if (picks.contains(0)) b = b.flipped;
    if (picks.contains(1)) b = b.negated;
    return b;
  }

  String explain(Round r, List<int> picks, bool won) {
    final flip = picks.contains(0), negate = picks.contains(1);
    if (won) {
      return r.ask == Ask.perpendicular
          ? 'Square. Perpendicular needs both moves: flip the fraction and '
                'change the sign.'
          : 'Parallel. Same slope, no moves at all.';
    }
    if (r.ask == Ask.parallel) {
      return 'Parallel lines have the same slope. Leave the fraction alone.';
    }
    if (flip && !negate) {
      return 'You flipped but kept the sign, so both lines still lean the '
          'same way. It is not square.';
    }
    if (!flip && negate) {
      return 'You changed the sign without flipping. That is a mirror image, '
          'not a perpendicular.';
    }
    return 'That is the same line you started with. Perpendicular needs the '
        'flip and the sign change.';
  }

  Node toggle(int i, String label, String detail) => answer(
    i,
    box(
      h: 64,
      pad: const [16, 0, 16, 0],
      radius: 14,
      border: onOff('ember', 'line'),
      stroke: onOff(1.5, 1),
      child: row([
        flex(
          col(
            [
              more(t(label, font: 'heading', size: 16), {'line': 1.2}),
              gapH(2),
              t(detail, size: 12.5, color: 'ink2'),
            ],
            main: 'center',
            cross: 'start',
          ),
        ),
        more(
          box(
            w: 26,
            h: 26,
            fill: onOff('ember', 'clear'),
            border: onOff('ember', 'line'),
            stroke: 1.5,
            child: onOff(icon('check', size: 17, color: 'pure'), null),
          ),
          {'shape': 'circle'},
        ),
      ]),
    ),
    radius: 14,
    fill: onOff('emberBg', 'white'),
  );

  final all = subsets(2);
  return game(
    pickSeveral(
      id: 'perpendicular-flip',
      chapter: 'mathematics',
      title: 'Perpendicular Flip',
      closing:
          'Perpendicular means flip the fraction and change the sign; '
          'parallel means leave it alone. Laying out a full alignment from '
          'that is still desk work.',
      right: 'CORRECT',
      wrong: 'NOT SQUARE',
      brief: briefJson(perpendicularBrief, 'perpendicularBrief'),
      rounds: [
        for (final (n, r) in flipRounds.indexed)
          (
            options: const ['Flip the fraction', 'Change the sign'],
            answer: r.ask == Ask.perpendicular ? const [0, 1] : const [],
            alone: const [],
            why: '',
            source: r.sourceProblemId,
            screen: [
              {
                'overline': r.ask == Ask.perpendicular
                    ? 'LAY IT PERPENDICULAR'
                    : 'LAY IT PARALLEL',
                'color': r.ask == Ask.perpendicular ? 'ember' : 'info',
              },
              gap(8),
              {'text': r.context, 'line': 1.55},
              gap(16),
              clip(
                box(
                  w: 'max',
                  h: 230,
                  child: grid(
                    draw(
                      askDone(
                        byPicks({
                          for (final p in all)
                            keyOf(p): record(
                              LinesPainter(
                                boundary: r.boundary.value,
                                built: built(r.boundary, p).value,
                                locked: null,
                                showBuilt: p.isNotEmpty,
                              ).paint,
                              230,
                              what: 'perpendicular-flip round $n $p',
                            ),
                        }, sorted: true),
                        byPicks({
                          for (final p in all)
                            keyOf(p): record(
                              LinesPainter(
                                boundary: r.boundary.value,
                                built: built(r.boundary, p).value,
                                locked: built(r.boundary, p).sameAs(r.target),
                                showBuilt: true,
                              ).paint,
                              230,
                              what: 'perpendicular-flip round $n $p done',
                            ),
                        }, sorted: true),
                      ),
                    ),
                    minor: 20,
                    major: 100,
                  ),
                ),
                16,
              ),
              gap(14),
              row([
                for (final (label, value, color) in [
                  (
                    'BOUNDARY',
                    'm = ${r.boundary.label}' as Object,
                    'charcoal' as Object,
                  ),
                  (
                    'YOU BUILT',
                    byPicks({
                      for (final p in all)
                        keyOf(p): 'm = ${built(r.boundary, p).label}',
                    }, sorted: true),
                    openWonLost('ember', 'forest', 'error'),
                  ),
                ])
                  flex(
                    col([
                      overlineNode(label),
                      gapH(4),
                      t(value, font: 'mono', size: 22, color: color),
                    ], cross: 'start'),
                  ),
              ]),
              gap(16),
              more(toggle(0, 'Flip the fraction', 'Swap rise and run'), {
                'when': 'ask',
              }),
              gap(10, when: 'ask'),
              more(
                toggle(
                  1,
                  'Change the sign',
                  'Plus becomes minus, minus becomes plus',
                ),
                {'when': 'ask'},
              ),
              {
                'feedback': true,
                'body': byPicks({
                  for (final p in all)
                    keyOf(p): explain(
                      r,
                      p,
                      built(r.boundary, p).sameAs(r.target),
                    ),
                }, sorted: true),
              },
            ],
          ),
      ],
    ),
    {'lock': 'Confirm this line'},
    // Locked in with anything picked or nothing: a parallel line takes
    // neither move.
    (_) => {'any': true},
  );
}

// Discriminant Gate

Map<String, Object?> discriminantGate() {
  const labels = ['No real roots', 'One root', 'Two real roots'];

  /// A parabola in its card: bordered by its state, the grid inside.
  Node card(
    Object drawing,
    double h, {
    Object border = 'line',
    Object? stroke,
  }) => box(
    radius: 16,
    border: border,
    stroke: stroke ?? 1,
    child: clip(
      box(w: 'max', h: h, child: grid(draw(drawing), minor: 16, major: 80)),
      14,
    ),
  );

  Object curve(Para p, Color color, double h, String what) => record(
    ParaPainter(para: p, color: color).paint,
    h,
    // A card in a row of three is under a third of the game's width.
    range: h < 200 ? (60, 400) : gameRange,
    what: what,
  );

  return pickScreen(
    id: 'discriminant-gate',
    chapter: 'mathematics',
    title: 'Discriminant Gate',
    closing:
        'Below the axis on both sides means two roots, touching means '
        'one, clear of it means none. On the exam that lets you throw out '
        'answers before you solve anything. Finding the roots themselves '
        'is still desk work.',
    right: 'CORRECT',
    wrong: 'NOT THAT ONE',
    brief: briefJson(discriminantBrief, 'discriminantBrief'),
    rounds: [
      for (final (n, g) in gateRounds.indexed)
        if (g.ask == GateAsk.countFromCurve)
          (
            options: labels,
            notes: null,
            tex: null,
            answer: g.answer,
            why: '',
            source: 'math-slq-q3',
            screen: [
              {'overline': 'HOW MANY REAL ROOTS', 'color': 'ember'},
              gap(8),
              {
                'text':
                    g.context ?? 'Read the curve. Where does it meet the axis?',
                'line': 1.55,
              },
              gap(16),
              card(
                curve(g.curves.single, AppColors.charcoal, 200, 'gate $n'),
                200,
              ),
              gap(16),
              for (var i = 2; i >= 0; i--) ...[
                tinted14(i, t(labels[i], font: 'heading', size: 16, line: 1.2)),
                gap(10),
              ],
              gap(16, when: 'done'),
              {
                'feedback': true,
                'body': openWonLost(
                  null,
                  _rootsTruth(g.answer),
                  'Look at where the curve sits against the axis. '
                  '${_rootsTruth(g.answer)}',
                ),
              },
            ],
          )
        else
          (
            options: const ['Left curve', 'Middle curve', 'Right curve'],
            notes: null,
            tex: null,
            answer: g.answer,
            why: '',
            source: 'math-slq-q3',
            screen: [
              {'overline': 'WHICH CURVE IS IT', 'color': 'ember'},
              gap(8),
              {
                'text':
                    'This quadratic has the discriminant below. Tap the curve '
                    'that matches it.',
                'line': 1.55,
              },
              gap(16),
              box(
                w: 'max',
                pad: const [16, 14, 16, 14],
                fill: 'white',
                radius: 14,
                border: 'line',
                child: center(tex(g.statement!, 20)),
              ),
              gap(14),
              row([
                for (var i = 0; i < g.curves.length; i++) ...[
                  flex(
                    plain(
                      i,
                      card(
                        tone(
                          curve(
                            g.curves[i],
                            AppColors.charcoal,
                            116,
                            'gate $n curve $i',
                          ),
                          curve(
                            g.curves[i],
                            AppColors.charcoal,
                            116,
                            'gate $n curve $i',
                          ),
                          curve(
                            g.curves[i],
                            AppColors.forest,
                            116,
                            'gate $n curve $i right',
                          ),
                          curve(
                            g.curves[i],
                            AppColors.error,
                            116,
                            'gate $n curve $i wrong',
                          ),
                        ),
                        116,
                        border: tone('line', 'ember', 'forest', 'error'),
                        stroke: tone(1, 2.5, 2.5, 2.5),
                      ),
                    ),
                  ),
                  if (i < g.curves.length - 1) gapW(10),
                ],
              ]),
              gap(16, when: 'done'),
              {
                'feedback': true,
                'body': openWonLost(
                  null,
                  _curveSign(g.curves[g.answer]),
                  'Not that one. ${_curveSign(g.curves[g.answer])}',
                ),
              },
            ],
          ),
    ],
  );
}

String _rootsTruth(int n) => switch (n) {
  2 =>
    'The curve passes through the axis twice, so b² − 4ac is '
        'positive and there are two real roots.',
  1 =>
    'The curve only touches the axis, so b² − 4ac is exactly zero '
        'and both roots are the same number.',
  _ =>
    'The curve never reaches the axis, so b² − 4ac is negative and '
        'there is no real root at all.',
};

String _curveSign(Para target) => target.roots == 2
    ? 'A positive discriminant cuts the axis twice.'
    : target.roots == 1
    ? 'A discriminant of zero touches the axis once.'
    : 'A negative discriminant never reaches the axis.';

/// An answer tapped with no ink, as games built on a bare tap handler are.
Node plain(int i, Node child) => {
  'k': 'answer',
  'i': i,
  'plain': true,
  'child': child,
};

/// The answer button most of these games draw: corners of 14, white and a
/// hairline until picked, then ember, forest or red with a border half a
/// pixel heavier, its words to the left.
Node tinted14(
  int i,
  Node child, {
  num h = 60,
  List<num> pad = const [16, 0, 16, 0],
  String? align = 'left',
  num stroke = 1.5,
}) => answer(
  i,
  box(
    h: h,
    pad: pad,
    align: align,
    radius: 14,
    border: tone('line', 'ember', 'forest', 'error'),
    stroke: tone(1, stroke, stroke, stroke),
    child: child,
  ),
  radius: 14,
  fill: tone('white', 'emberBg', 'forestBg', 'errorBg'),
);

/// Every order of 0 to [n] - 1.
List<List<int>> orders(int n) {
  if (n == 0) return [[]];
  return [
    for (final rest in orders(n - 1))
      for (var at = 0; at <= rest.length; at++)
        [...rest.sublist(0, at), n - 1, ...rest.sublist(at)],
  ];
}

/// A card tapped into a ranking (Grade Sense, Order the Moves): white,
/// its border ember once ranked and forest or red once answered, with a
/// round badge numbering it in the order tapped and, once answered, in the
/// right order.
Node rankedCard(
  int i, {
  required int places,
  required int truth,
  required num radius,
  required num badge,
  required num digits,
  required bool badgeRing,
  required Node body,
}) {
  Node digit(int k) =>
      t('$k', font: 'mono', size: digits, color: 'pure')..['fw'] = 700;
  return answer(
    i,
    box(
      pad: const [14, 14, 14, 14],
      radius: radius,
      border: openWonLost(
        place([for (var k = 0; k < places; k++) 'ember'], none: 'line'),
        'forest',
        'error',
      ),
      stroke: openWonLost(
        place([for (var k = 0; k < places; k++) 2], none: 1),
        2,
        2,
      ),
      child: row([
        more(
          box(
            w: badge,
            h: badge,
            align: 'center',
            fill: openWonLost(
              place([for (var k = 0; k < places; k++) 'ember'], none: 'clear'),
              'forest',
              'error',
            ),
            // Grade Sense rings a badge in its own color; Order the Moves
            // rings only an empty one.
            border: badgeRing
                ? openWonLost(
                    place([
                      for (var k = 0; k < places; k++) 'ember',
                    ], none: 'line'),
                    'forest',
                    'error',
                  )
                : openWonLost(
                    place([
                      for (var k = 0; k < places; k++) 'clear',
                    ], none: 'line'),
                    'clear',
                    'clear',
                  ),
            stroke: 1.5,
            child: openWonLost(
              place([for (var k = 0; k < places; k++) digit(k + 1)]),
              digit(truth),
              digit(truth),
            ),
          ),
          {'shape': 'circle'},
        ),
        gapW(14),
        flex(body),
      ]),
    ),
    radius: radius,
    fill: 'white',
  );
}

// Grade Sense

Map<String, Object?> gradeSense() {
  String pct(Stretch s) {
    final p = s.grade * 100;
    final text = p == p.roundToDouble()
        ? p.toStringAsFixed(0)
        : p.toStringAsFixed(1);
    return '$text percent';
  }

  bool same(List<int> a, List<int> b) => keyOf(a) == keyOf(b);

  String explain(GradeRound r, List<int> order) {
    final steep = r.stretches[r.answer.first];
    if (same(order, r.answer)) {
      return 'Steepest is ${steep.name}: ${pct(steep)}. Grade is rise over '
          'run, so a short run with the same rise is always the steeper road.';
    }
    if (same(order, r.byNaiveStation) && !same(r.byNaiveStation, r.answer)) {
      return 'That is the order you get by reading a station as a plain '
          'number. 3+00 means 300 feet, not 3. Convert the stations first, '
          'then compare.';
    }
    if (same(order, r.byRiseAlone) && !same(r.byRiseAlone, r.answer)) {
      return 'That is the order by rise alone. The longest run flattens the '
          'biggest rise, so you have to weigh them against each other.';
    }
    return 'The correct order is marked. ${steep.name} is steepest at '
        '${pct(steep)}.';
  }

  String trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  return game(
    pickSeveral(
      id: 'grade-sense',
      chapter: 'mathematics',
      title: 'Grade Sense',
      closing:
          'Grade is rise over run, and a station is hundreds of feet: '
          '3+00 is 300 feet, never 3. Getting the order right is not the '
          'same as computing a grade to two decimals, which is desk work.',
      right: 'CORRECT',
      wrong: 'NOT THE ORDER',
      brief: briefJson(gradeBrief, 'gradeBrief'),
      rounds: [
        for (final r in gradeRounds)
          (
            options: [for (final s in r.stretches) s.name],
            answer: r.answer,
            alone: const [],
            why: '',
            source: 'math-slq-q1',
            screen: [
              {'overline': 'STEEPEST FIRST', 'color': 'ember'},
              gap(8),
              {'text': r.prompt, 'line': 1.55},
              gap(6),
              t(
                'Tap them in order. Tap one again to clear back to it.',
                size: 13,
                color: 'ink2',
              ),
              gap(16),
              for (final (i, s) in r.stretches.indexed) ...[
                rankedCard(
                  i,
                  places: r.stretches.length,
                  truth: r.answer.indexOf(i) + 1,
                  radius: 16,
                  badge: 34,
                  digits: 15,
                  badgeRing: true,
                  body: col([
                    t(s.name, font: 'heading', size: 16, line: 1.2),
                    gapH(4),
                    more(
                      t(
                        'rise ${trim(s.rise)} ft · run ${s.runLabel}',
                        font: 'mono',
                        size: 12.5,
                        color: 'ink2',
                      ),
                      {'max': 1},
                    ),
                  ], cross: 'start'),
                ),
                gap(10),
              ],
              gap(6, when: 'done'),
              {
                'feedback': true,
                'body': byPicks({
                  for (final o in orders(r.stretches.length))
                    keyOf(o): explain(r, o),
                }),
              },
            ],
          ),
      ],
    ),
    {'lock': 'Lock the order'},
    (i) => {
      'order': 'list',
      'trim': true,
      'need': gradeRounds[i].stretches.length,
    },
  );
}

// Order the Moves

Map<String, Object?> orderTheMoves() => game(
  pickSeveral(
    id: 'order-the-moves',
    chapter: 'mathematics',
    title: 'Order the Moves',
    closing:
        'Knowing the order is most of the work on a log problem: clear '
        'the coefficient, log both sides, bring the exponent down, then '
        'divide. Carrying it out is desk work.',
    right: 'CORRECT',
    wrong: 'NOT THAT ORDER',
    brief: briefJson(undoExponentBrief, 'undoExponentBrief'),
    rounds: [
      for (final r in moveSets)
        (
          options: r.shown,
          answer: r.answer,
          alone: const [],
          why: r.why,
          source: r.source,
          screen: [
            {'overline': 'WHAT WOULD YOU DO FIRST', 'color': 'ember'},
            gap(10),
            box(
              w: 'max',
              pad: const [16, 16, 16, 16],
              fill: 'white',
              radius: 16,
              border: 'line',
              child: more(math(r.problem, 15), {'line': 1.6}),
            ),
            gap(12),
            t(
              'Tap the steps in the order you would actually do them. Tap one '
              'again to clear back to it.',
              size: 13,
              color: 'ink2',
            ),
            gap(14),
            for (final (i, s) in r.shown.indexed) ...[
              rankedCard(
                i,
                places: r.shown.length,
                truth: r.answer.indexOf(i) + 1,
                radius: 14,
                badge: 30,
                digits: 14,
                badgeRing: false,
                body: more(math(s, 14.5), {'line': 1.4}),
              ),
              gap(10),
            ],
            gap(4, when: 'done'),
            {'feedback': true},
          ],
        ),
    ],
  ),
  {'lock': 'Lock the order'},
  (i) => {
    'order': 'list',
    'trim': true,
    'need': moveSets[i].shown.length,
    if (moveSets[i].accepted.length > 1)
      'also': moveSets[i].accepted.sublist(1),
  },
);

/// A white box with a hairline border holding a formula in its middle, the
/// statement these games put above their answers.
Node statement(
  String latex,
  num size, {
  required List<num> pad,
  num radius = 18,
}) => box(
  w: 'max',
  pad: pad,
  fill: 'white',
  radius: radius,
  border: 'line',
  child: center(tex(latex, size)),
);

/// The usual opening: an ember overline, then the setting at 15 on 1.55.
List<Map<String, Object?>> opening(
  String overline,
  String setting, {
  num after = 8,
}) => [
  {'overline': overline, 'color': 'ember'},
  gap(after),
  {'text': setting, 'line': 1.55},
];

/// An answer that is a formula set to the left, in a card at least [minh]
/// high (One Log, Set It Up).
Node formulaCard(int i, String latex, {required num minh}) => answer(
  i,
  more(
    box(
      pad: const [18, 12, 18, 12],
      align: 'left',
      radius: 14,
      border: tone('line', 'ember', 'forest', 'error'),
      stroke: tone(1, 2, 2, 2),
      child: more(tex(latex, 18), {'align': 'left'}),
    ),
    {'minh': minh},
  ),
  radius: 14,
  fill: tone('white', 'emberBg', 'forestBg', 'errorBg'),
);

// Rule or Trap

Map<String, Object?> ruleOrTrap() => pickScreen(
  id: 'rule-or-trap',
  chapter: 'mathematics',
  title: 'Rule or Trap',
  closing:
      'Products, quotients and powers have rules. A sum inside a log '
      'does not, and no amount of algebra will give it one. Using the '
      'rules on a real problem is still desk work.',
  right: 'CORRECT',
  wrong: 'NOT QUITE',
  brief: briefJson(logRulesBrief, 'logRulesBrief'),
  rounds: [
    for (final c in claims)
      (
        options: const ['Legal', 'No such rule'],
        notes: null,
        tex: null,
        answer: c.legal ? 0 : 1,
        why: c.why,
        source: c.source,
        screen: [
          ...opening(
            'IS THIS MOVE LEGAL',
            'Same base throughout. Decide whether the step is allowed, without '
                'working anything out.',
          ),
          gap(18),
          statement(c.latex, 22, pad: const [16, 26, 16, 26]),
          gap(18),
          row([
            for (final (i, (label, glyph)) in const [
              ('Legal', 'check'),
              ('No such rule', 'close'),
            ].indexed) ...[
              if (i > 0) gapW(12),
              flex(
                answer(
                  i,
                  box(
                    h: 84,
                    radius: 16,
                    border: tone('line', 'ember', 'forest', 'error'),
                    stroke: tone(1, 2, 2, 2),
                    child: col([
                      icon(
                        glyph,
                        size: 24,
                        color: tone('ink3', 'ember', 'forest', 'error'),
                      ),
                      gapH(6),
                      t(label, font: 'heading', size: 15),
                    ], main: 'center'),
                  ),
                  radius: 16,
                  fill: tone('white', 'emberBg', 'forestBg', 'errorBg'),
                ),
              ),
            ],
          ]),
          gap(18, when: 'done'),
          {'feedback': true},
        ],
      ),
  ],
);

// One Log

Map<String, Object?> oneLog() => pickScreen(
  id: 'one-log',
  chapter: 'mathematics',
  title: 'One Log',
  closing:
      'Added terms multiply inside, subtracted terms divide inside, '
      'a coefficient becomes an exponent. Collapse first, evaluate later, '
      'and evaluating is desk work.',
  right: 'CORRECT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(combineLogsBrief, 'combineLogsBrief'),
  rounds: [
    for (final r in collapses)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...opening(
            'WRITE IT AS ONE LOG',
            'Same base throughout. Pick the single log this is equal to, '
                'without working out any values.',
          ),
          gap(16),
          statement(r.expression, 21, pad: const [16, 24, 16, 24]),
          gap(16),
          for (final (i, o) in r.options.indexed) ...[
            formulaCard(i, o, minh: 62),
            gap(10),
          ],
          gap(4, when: 'done'),
          {'feedback': true},
        ],
      ),
  ],
);

// Set It Up

Map<String, Object?> setItUp() => pickScreen(
  id: 'set-it-up',
  chapter: 'mathematics',
  title: 'Set It Up',
  closing:
      'Each side over the sine of its own angle, and the cosine term '
      'subtracted, never added. Written right, the arithmetic is the easy '
      'part, and it belongs at a desk.',
  right: 'CORRECT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(setupBrief, 'setupBrief'),
  rounds: [
    for (final r in setups)
      (
        options: r.options,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...opening('WRITE IT DOWN RIGHT', r.ask),
          gap(16),
          for (final (i, o) in r.options.indexed) ...[
            formulaCard(i, o, minh: 66),
            gap(10),
          ],
          gap(4, when: 'done'),
          {'feedback': true},
        ],
      ),
  ],
);

/// A drawing on the grid (18 and 90) clipped to 16, [h] high and the full
/// width, as most of these games frame theirs.
Node framed(Node inside, num h, {num minor = 18, num major = 90}) => clip(
  box(
    w: 'max',
    h: h,
    child: grid(inside, minor: minor, major: major),
  ),
  16,
);

/// Answers side by side, each an equal share, [space] apart.
Node besides(List<Node> answers, {num space = 10}) => row([
  for (final (i, a) in answers.indexed) ...[if (i > 0) gapW(space), flex(a)],
]);

/// The usual tinted answer in a row: [h] high, its child centred.
Node centred(
  int i,
  Node child, {
  required num h,
  num radius = 14,
  List<num>? pad,
}) => answer(
  i,
  box(
    h: h,
    pad: pad,
    align: 'center',
    radius: radius,
    border: tone('line', 'ember', 'forest', 'error'),
    stroke: tone(1, 2, 2, 2),
    child: child,
  ),
  radius: radius,
  fill: tone('white', 'emberBg', 'forestBg', 'errorBg'),
);

// Tap the Side

Map<String, Object?> tapTheSide() {
  const h = 260.0;
  String asked(TriSide s) => switch (s) {
    TriSide.hypotenuse =>
      'The hypotenuse is the side across from the right angle. It '
          'is the only name that never moves.',
    TriSide.opposite =>
      'Opposite means it does not touch the marked angle. Move the '
          'angle to the other corner and this name moves with it.',
    TriSide.adjacent =>
      'Adjacent is the side touching the marked angle that is not '
          'the hypotenuse. Cos is cozy with this one.',
  };
  return pickScreen(
    id: 'tap-the-side',
    chapter: 'mathematics',
    title: 'Tap the Side',
    closing:
        'The hypotenuse is always across from the right angle. '
        'Opposite and adjacent belong to the angle you marked, not to the '
        'page, and they swap the moment you mark the other corner.',
    right: 'CORRECT',
    wrong: 'NOT THAT SIDE',
    brief: briefJson(sideNamesBrief, 'sideNamesBrief'),
    rounds: [
      for (final (n, r) in sideRounds.indexed)
        (
          options: [for (final s in TriSide.values) s.label],
          notes: null,
          tex: null,
          answer: r.ask.index,
          why: '',
          source: r.source,
          screen: [
            {'overline': 'TAP THE SIDE', 'color': 'ember'},
            gap(8),
            {
              'text': switch (r.ask) {
                TriSide.hypotenuse => 'Tap the hypotenuse.',
                TriSide.opposite => 'Tap the side opposite the marked angle.',
                TriSide.adjacent =>
                  'Tap the side adjacent to the marked angle.',
              },
              'size': 16,
              'line': 1.5,
            },
            gap(6),
            t('Anywhere along it will do.', size: 13, color: 'ink2'),
            gap(14),
            framed({
              'k': 'tapdraw',
              'd': {
                for (final mark in [null, ...TriSide.values])
                  for (final done in [false, true])
                    if (!(done && mark == null))
                      '${mark?.index ?? '-'}|${done ? 1 : 0}': record(
                        TrianglePainter(
                          angleAtTop: r.angleAtTop,
                          mirror: r.mirror,
                          highlight: done ? r.ask : mark,
                          highlightColor: !done
                              ? AppColors.ember
                              : (mark == r.ask
                                    ? AppColors.forest
                                    : AppColors.error),
                        ).paint,
                        h,
                        what: 'tap-the-side round $n $mark $done',
                      ),
              },
              // The three sides, in the order the game tries them, each
              // taking a tap within 60 of it.
              'targets': record(
                (canvas, size) {
                  final g = TriangleGeometry(
                    size,
                    angleAtTop: r.angleAtTop,
                    mirror: r.mirror,
                  );
                  for (final side in TriSide.values) {
                    final (a, b) = g.endsOf(side);
                    canvas.drawLine(a, b, Paint()..strokeWidth = 60);
                  }
                },
                h,
                what: 'tap-the-side round $n sides',
              ),
              'reach': 'stroke',
              'hits': const [0, 1, 2],
              'h': h,
            }, h),
            gap(14, when: 'done'),
            {
              'feedback': true,
              'body': {
                'pick': [
                  for (final s in TriSide.values)
                    (s == r.ask
                            ? ''
                            : 'You picked the ${s.label.toLowerCase()}. ') +
                        asked(r.ask),
                ],
              },
            },
          ],
        ),
    ],
  );
}

// Which Ratio

Map<String, Object?> whichRatio() => pickScreen(
  id: 'which-ratio',
  chapter: 'mathematics',
  title: 'Which Ratio',
  closing:
      'Pick the ratio that connects what you have to what you want, '
      'and read opposite and adjacent off the angle rather than off the '
      'page. Working the number is desk work.',
  right: 'CORRECT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(ratiosBrief, 'ratiosBrief'),
  rounds: [
    for (final (n, r) in ratioRounds.indexed)
      (
        options: [for (final q in TriRatio.values) q.label],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why:
            '${r.known.label.toLowerCase()} and '
            '${r.wanted.label.toLowerCase()} are connected by '
            '${r.answer.label}. Remember cos is cozy with the adjacent '
            'side, the one touching the angle.',
        source: r.source,
        screen: [
          ...opening('WHICH RATIO CONNECTS THEM', r.context),
          gap(14),
          framed(
            draw(
              askDone(
                record(
                  TrianglePainter(
                    angleAtTop: r.angleAtTop,
                    mirror: r.mirror,
                    known: r.known,
                    wanted: r.wanted,
                  ).paint,
                  210,
                  what: 'which-ratio round $n',
                ),
                openWonLost(
                  null,
                  ratioAnswered(r, AppColors.forest, n),
                  ratioAnswered(r, AppColors.error, n),
                ),
              ),
            ),
            210,
          ),
          gap(16),
          besides([
            for (final q in TriRatio.values)
              centred(q.index, t(q.label, font: 'heading', size: 18), h: 62),
          ]),
          gap(16, when: 'done'),
          {'feedback': true},
          gap(12, when: 'done'),
          more(center(tex(r.answer.latex, 19)), {'when': 'done'}),
        ],
      ),
  ],
);

Object ratioAnswered(RatioRound r, Color c, int n) => record(
  TrianglePainter(
    angleAtTop: r.angleAtTop,
    mirror: r.mirror,
    known: r.known,
    wanted: r.wanted,
    highlight: r.wanted,
    highlightColor: c,
  ).paint,
  210,
  what: 'which-ratio round $n answered',
);

// Resolve It

Map<String, Object?> resolveIt() => pickScreen(
  id: 'resolve-it',
  chapter: 'mathematics',
  title: 'Resolve It',
  closing:
      'The component along the axis the angle is measured from takes '
      'the cosine, the other takes the sine. An angle quoted from the '
      'vertical swaps them, which is where the marks go missing.',
  right: 'CORRECT',
  wrong: 'THE OTHER ONE',
  brief: briefJson(componentsBrief, 'componentsBrief'),
  rounds: [
    for (final (n, r) in resolves.indexed)
      (
        options: const [r'F\cos\theta', r'F\sin\theta'],
        notes: null,
        tex: null,
        answer: r.answerIsCos ? 0 : 1,
        why: r.fromVertical
            ? 'The angle is measured from the VERTICAL, so the vertical '
                  'component is the adjacent one and takes the cosine. The '
                  'horizontal takes the sine, which is the reverse of the '
                  'usual case.'
            : 'The angle is measured from the horizontal, so the '
                  'horizontal component is the adjacent one and takes the '
                  'cosine. Cos is cozy with the side touching the angle.',
        source: r.source,
        screen: [
          ...opening(
            r.wantHorizontal
                ? 'THE HORIZONTAL COMPONENT'
                : 'THE VERTICAL COMPONENT',
            r.context,
          ),
          gap(14),
          framed(
            draw(
              record(
                ForcePainter(
                  degrees: r.degrees,
                  fromVertical: r.fromVertical,
                  highlightHorizontal: r.wantHorizontal,
                  magnitude: 'F',
                ).paint,
                210,
                what: 'resolve-it round $n',
              ),
            ),
            210,
          ),
          gap(16),
          besides([
            for (final (i, l) in const [r'F\cos\theta', r'F\sin\theta'].indexed)
              centred(i, tex(l, 20), h: 74),
          ], space: 12),
          gap(16, when: 'done'),
          {'feedback': true},
        ],
      ),
  ],
);

// Which Law

Map<String, Object?> whichLaw() => pickScreen(
  id: 'which-law',
  chapter: 'mathematics',
  title: 'Which Law',
  closing:
      'A side with its opposite angle means Sines. Two sides with '
      'the angle between them, or all three sides, means Cosines. '
      'Choosing the way in is the part worth doing on a phone.',
  right: 'CORRECT',
  wrong: 'THE OTHER ONE',
  // The sheet's angle arc meets its sides a shade off at the plain
  // tolerance on a wide phone.
  brief: closer(1e-6, () => briefJson(whichLawBrief, 'whichLawBrief')),
  rounds: [
    for (final (n, r) in lawRounds.indexed)
      (
        options: const ['Law of Sines', 'Law of Cosines'],
        notes: null,
        tex: null,
        answer: r.sines ? 0 : 1,
        why: 'This is ${r.pattern}. ${r.why}',
        source: r.source,
        screen: [
          ...opening('WHICH LAW GETS YOU IN', r.context),
          gap(6),
          {
            'mono': 'Green is given, ember is wanted.',
            'size': 11.5,
            'color': 'ink3',
          },
          gap(12),
          framed(
            draw(
              record(
                ObliqueTrianglePainter(
                  knownSides: r.knownSides,
                  knownAngles: r.knownAngles,
                  wanted: r.wanted,
                ).paint,
                220,
                what: 'which-law round $n',
              ),
            ),
            220,
          ),
          gap(16),
          besides([
            for (final (i, l) in const [
              'Law of Sines',
              'Law of Cosines',
            ].indexed)
              centred(
                i,
                t(l, font: 'heading', size: 15.5, line: 1.2, align: 'center'),
                h: 70,
                pad: const [10, 0, 10, 0],
              ),
          ], space: 12),
          gap(16, when: 'done'),
          {'feedback': true},
        ],
      ),
  ],
);

// Acute or Obtuse

Map<String, Object?> acuteOrObtuse() => pickScreen(
  id: 'acute-or-obtuse',
  chapter: 'mathematics',
  title: 'Acute or Obtuse',
  closing:
      'A negative cosine is not a mistake, it is an obtuse angle. '
      'Inverse cosine already accounts for it, so nothing needs '
      'subtracting from 180.',
  right: 'CORRECT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(obtuseBrief, 'obtuseBrief'),
  rounds: [
    for (final r in verdicts)
      (
        options: [for (final k in AngleKind.values) k.label],
        notes: null,
        tex: null,
        answer: r.answer.index,
        why: r.why,
        source: r.source,
        screen: [
          ...opening('WHAT KIND OF ANGLE', r.given),
          gap(16),
          statement(r.latex, 22, pad: const [16, 26, 16, 26]),
          gap(16),
          for (final k in AngleKind.values) ...[
            tinted14(
              k.index,
              row([
                t(k.label, font: 'heading', size: 17),
                gapW(10),
                t(k.detail, font: 'mono', size: 12.5, color: 'ink3'),
              ]),
              h: 62,
              pad: const [18, 0, 18, 0],
              align: null,
              stroke: 2,
            ),
            gap(10),
          ],
          gap(4, when: 'done'),
          {'feedback': true},
        ],
      ),
  ],
);

/// The formula some unit circle rounds show under their question.
List<Map<String, Object?>> circleFormula(String? latex) => [
  if (latex != null) ...[
    gap(12),
    box(
      w: 'max',
      pad: const [0, 18, 0, 18],
      fill: 'white',
      radius: 16,
      border: 'line',
      child: center(tex(latex, 20)),
    ),
  ],
];

// Walk the Circle

Map<String, Object?> walkTheCircle() {
  const h = 300.0;
  return pickScreen(
    id: 'walk-the-circle',
    chapter: 'mathematics',
    title: 'Walk the Circle',
    closing:
        'Cosine is the across, sine is the up, and the quadrant '
        'decides the signs. Knowing where a point sits is what makes the '
        'exact values worth memorising.',
    right: 'CORRECT',
    wrong: 'NOT THAT POINT',
    brief: briefJson(unitCircleBrief, 'unitCircleBrief'),
    rounds: [
      for (final (n, r) in circleRounds.indexed)
        (
          options: [for (final c in r.choices) '$c degrees'],
          notes: null,
          tex: null,
          answer: r.choices.indexOf(r.answer),
          why: r.why,
          source: r.source,
          screen: [
            {'overline': 'FIND IT ON THE CIRCLE', 'color': 'ember'},
            gap(8),
            {'text': r.ask, 'size': 16, 'line': 1.5},
            ...circleFormula(r.latex),
            gap(14),
            framed(
              {
                'k': 'tapdraw',
                'd': {
                  for (final mark in [
                    null,
                    ...r.choices.indexed.map((e) => e.$1),
                  ])
                    for (final done in [false, true])
                      if (!(done && mark == null))
                        '${mark ?? '-'}|${done ? 1 : 0}': record(
                          UnitCirclePainter(
                            choices: r.choices,
                            picked: mark == null ? null : r.choices[mark],
                            truth: r.answer,
                            revealed: done,
                            showRayTo: done
                                ? r.answer
                                : (mark == null ? null : r.choices[mark]),
                          ).paint,
                          h,
                          what: 'walk-the-circle round $n $mark $done',
                        ),
                },
                // Each point takes a tap within 46 of it, the nearest
                // winning.
                'targets': record(
                  (canvas, size) {
                    final g = CircleGeometry(size);
                    for (final c in r.choices) {
                      canvas.drawCircle(g.pointAt(c), 46, Paint());
                    }
                  },
                  h,
                  what: 'walk-the-circle round $n points',
                ),
                'hits': [for (var i = 0; i < r.choices.length; i++) i],
                'h': h,
              },
              h,
              minor: 20,
              major: 100,
            ),
            gap(14, when: 'done'),
            {'feedback': true},
            gap(12, when: 'done'),
            more(center(tex(_coordinates(r.answer), 19)), {'when': 'done'}),
          ],
        ),
    ],
  );
}

String _coordinates(int degrees) {
  final point = unitCirclePoints[degrees];
  if (point == null) return '';
  return r'\left(' + point.$1 + r',\;' + point.$2 + r'\right)';
}

// Quadrant Signs

Map<String, Object?> quadrantSigns() {
  const h = 290.0;
  Object drawn(int? q, String what) => record(
    UnitCirclePainter(quadrantLabels: true, highlightQuadrant: q).paint,
    h,
    what: what,
  );
  return pickScreen(
    id: 'quadrant-signs',
    chapter: 'mathematics',
    title: 'Quadrant Signs',
    closing:
        'The identity gives you the size, the quadrant gives you the '
        'sign. Forgetting the second half is how a right answer turns '
        'into a wrong one.',
    right: 'CORRECT',
    wrong: 'NOT THAT ONE',
    brief: briefJson(quadrantBrief, 'quadrantBrief'),
    rounds: [
      for (final (n, r) in quadrantRounds.indexed)
        (
          options: const ['First', 'Second', 'Third', 'Fourth'],
          notes: null,
          tex: null,
          answer: r.answer - 1,
          why: r.why,
          source: r.source,
          screen: [
            {'overline': 'WHERE DOES IT LIVE', 'color': 'ember'},
            gap(8),
            {'text': r.ask, 'size': 16, 'line': 1.5},
            ...circleFormula(r.latex),
            gap(14),
            framed(
              {
                'k': 'tapdraw',
                // One drawing, by the quadrant picked, then the right one
                // once answered.
                'layers': [
                  {
                    'd': askDone({
                      'pick': [
                        for (var q = 1; q <= 4; q++)
                          drawn(q, 'quadrant-signs round $n quadrant $q'),
                      ],
                      'none': drawn(null, 'quadrant-signs round $n'),
                    }, drawn(r.answer, 'quadrant-signs round $n answered')),
                  },
                ],
                // Each quarter of the disc out to 1.45 radii, clear of the
                // axes by 8, as the game reads a tap.
                'targets': record(
                  (canvas, size) {
                    final g = CircleGeometry(size);
                    final c = g.center;
                    const far = 4000.0;
                    for (final (sx, sy) in const [
                      (1, -1),
                      (-1, -1),
                      (-1, 1),
                      (1, 1),
                    ]) {
                      canvas.drawPath(
                        fp.Path.combine(
                          PathOperation.intersect,
                          fp.Path()..addOval(
                            Rect.fromCircle(center: c, radius: g.radius * 1.45),
                          ),
                          fp.Path()..addRect(
                            Rect.fromPoints(
                              c + Offset(sx * 8.0, sy * 8.0),
                              c + Offset(sx * far, sy * far),
                            ),
                          ),
                        ),
                        Paint(),
                      );
                    }
                  },
                  h,
                  what: 'quadrant-signs round $n quarters',
                ),
                'hits': const [0, 1, 2, 3],
                'h': h,
              },
              h,
              minor: 20,
              major: 100,
            ),
            gap(14, when: 'done'),
            {'feedback': true},
          ],
        ),
    ],
  );
}

/// [value] once answer [of] is placed in any slot, [none] while it is not.
Map<String, Object?> placedOf(int of, int slots, Object? value, Object? none) =>
    {
      ...place([for (var k = 0; k < slots; k++) value], none: none),
      'of': of,
    };

// Build the Identity

Map<String, Object?> buildTheIdentity() => game(
  pickSeveral(
    id: 'build-the-identity',
    chapter: 'mathematics',
    title: 'Build the Identity',
    closing:
        'Producing an identity is a different thing from recognising '
        'one. Putting numbers through it is desk work; knowing its shape '
        'is what you carry into the exam.',
    right: 'CORRECT',
    wrong: 'NOT QUITE',
    brief: briefJson(identitiesBrief, 'identitiesBrief'),
    rounds: [
      for (final r in identities)
        (
          options: r.chips,
          answer: [for (final s in r.slots) r.chips.indexOf(s)],
          alone: const [],
          why: r.why,
          source: r.source,
          screen: [
            {'overline': 'BUILD THE RIGHT-HAND SIDE', 'color': 'ember'},
            gap(8),
            t(
              'Tap the parts, in order. Tap one you have placed to take it '
              'back.',
              size: 14,
              line: 1.5,
              color: 'ink2',
            ),
            gap(16),
            box(
              w: 'max',
              pad: const [14, 18, 14, 18],
              fill: 'white',
              radius: 16,
              border: 'line',
              c: [
                tex(r.left, 20),
                gapH(12),
                t('=', font: 'heading', size: 18),
                gapH(12),
                {
                  'k': 'wrap',
                  'align': 'center',
                  'spacing': 8,
                  'run': 8,
                  'c': [
                    for (var k = 0; k < r.slots.length; k++)
                      {
                        'k': 'slot',
                        's': k,
                        'child': more(
                          box(
                            pad: const [12, 8, 12, 8],
                            align: 'center',
                            radius: 12,
                            fill: slot(k, [
                              for (final _ in r.chips) 'white',
                            ], empty: 'cream'),
                            border: askDone(
                              slot(k, [
                                for (final _ in r.chips) 'ember',
                              ], empty: 'line'),
                              slot(k, [
                                for (final c in r.chips)
                                  c == r.slots[k] ? 'forest' : 'error',
                              ], empty: 'error'),
                            ),
                            stroke: slot(k, [
                              for (final _ in r.chips) 2,
                            ], empty: 1.5),
                            child: slot(
                              k,
                              [for (final c in r.chips) tex(c, 17)],
                              empty: t(
                                '?',
                                font: 'heading',
                                size: 17,
                                color: 'ink3',
                              ),
                            ),
                          ),
                          {'minw': 74, 'maxw': 150, 'minh': 56},
                        ),
                      },
                  ],
                },
              ],
            ),
            gap(18),
            overlineNode('PARTS'),
            gap(10),
            {
              'k': 'wrap',
              'spacing': 10,
              'run': 10,
              'c': [
                for (var j = 0; j < r.chips.length; j++)
                  {
                    'k': 'fade',
                    'o': placedOf(j, r.slots.length, 0.3, 1),
                    'child': more(
                      answer(
                        j,
                        more(
                          box(
                            pad: const [14, 8, 14, 8],
                            align: 'center',
                            radius: 12,
                            border: 'line',
                            child: tex(r.chips[j], 17),
                          ),
                          {'minw': 68, 'maxw': 150, 'minh': 54},
                        ),
                        fill: 'white',
                      ),
                      {'off': placedOf(j, r.slots.length, true, false)},
                    ),
                  },
              ],
            },
            gap(18, when: 'done'),
            {'feedback': true},
            // The identity written out, under a miss only.
            more(
              col([
                openWonLost(null, null, gapH(12)),
                openWonLost(
                  null,
                  null,
                  center(tex('${r.left} = ${r.slots.join(' ')}', 19)),
                ),
              ], cross: 'start'),
              {'when': 'done'},
            ),
          ],
        ),
    ],
  ),
  const {},
  (i) => {
    'order': 'slots',
    'keep': true,
    'most': identities[i].slots.length,
    'need': identities[i].slots.length,
  },
);

/// Only part of what [draw] draws: its steps from [from] up to [to] (from
/// the end when negative), so one painter can be split into layers.
Draw part(Draw draw, int from, [int? to]) => (canvas, size) {
  final recording = canvas as RecordingCanvas;
  final had = recording.ops.length;
  draw(canvas, size);
  final mine = recording.ops.sublist(had);
  recording.ops
    ..removeRange(had, recording.ops.length)
    ..addAll(
      mine.sublist(
        from < 0 ? mine.length + from : from,
        to == null ? null : (to < 0 ? mine.length + to : to),
      ),
    );
};

/// How many steps [draw] takes at [size].
int stepsOf(Draw draw, Size size) {
  final recording = RecordingCanvas();
  draw(recording, size);
  return recording.ops.length;
}

// Place the Center

Map<String, Object?> placeTheCenter() {
  const span = 6;
  final points = [
    for (var y = span; y >= -span; y--)
      for (var x = -span; x <= span; x++) (x, y),
  ];

  /// The game's dot, drawn round the origin so the phone can move it onto
  /// whichever point is picked.
  Draw dot(Color color) => (canvas, size) {
    canvas.drawCircle(Offset.zero, 8, Paint()..color = color);
    canvas.drawCircle(
      Offset.zero,
      14,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  };

  // A dot is drawn in two steps at the end of the painter.
  const dotSteps = 2;
  // The drawing is as tall as it is wide, so each is drawn on the square
  // its width makes, whatever height the builder records it at.
  Object layer(Draw d, String what) => record(
    (canvas, size) => d(canvas, Size.square(size.width)),
    400,
    what: what,
  );

  return pickScreen(
    id: 'place-the-center',
    chapter: 'mathematics',
    title: 'Place the Center',
    closing:
        'The sign inside the bracket is the opposite of the '
        'coordinate, and the number on the right is the radius squared. '
        'Those two are most of what circles are worth on the exam.',
    right: 'CORRECT',
    wrong: 'NOT THERE',
    brief: briefJson(circleFormBrief, 'circleFormBrief'),
    rounds: [
      for (final (n, r) in centerRounds.indexed)
        (
          options: [for (final (x, y) in points) '($x, $y)'],
          notes: null,
          tex: null,
          answer: points.indexOf(r.center),
          why: r.why,
          source: r.source,
          screen: [
            {'overline': 'PUT A FINGER ON THE CENTER', 'color': 'ember'},
            gap(10),
            statement(r.equation, 21, pad: const [14, 20, 14, 20], radius: 16),
            gap(14),
            clip(
              box(
                fill: 'white',
                child: {
                  'k': 'tapdraw',
                  'h': 'w',
                  'layers': [
                    // The grid, its axes and their numbers.
                    {
                      'd': layer(
                        const GridPainter().paint,
                        'place-the-center round $n grid',
                      ),
                    },
                    // Once answered, the circle and its radius.
                    {
                      'd': askDone(
                        null,
                        layer((canvas, size) {
                          final full = GridPainter(
                            truth: r.center,
                            revealed: true,
                            radius: r.radius,
                          ).paint;
                          part(
                            full,
                            stepsOf(const GridPainter().paint, size),
                            -dotSteps,
                          )(canvas, size);
                        }, 'place-the-center round $n circle'),
                      ),
                    },
                    // The dot on the point picked: ember, then red once
                    // answered unless it is the center itself.
                    {
                      'moved': true,
                      'd': askDone(
                        layer(dot(AppColors.ember), 'place-the-center dot'),
                        onOff(
                          null,
                          layer(dot(AppColors.error), 'place-the-center miss'),
                          of: points.indexOf(r.center),
                        ),
                      ),
                    },
                    // Once answered, the center.
                    {
                      'd': askDone(
                        null,
                        layer(
                          part(
                            GridPainter(
                              truth: r.center,
                              revealed: true,
                              radius: r.radius,
                            ).paint,
                            -dotSteps,
                          ),
                          'place-the-center round $n center',
                        ),
                      ),
                    },
                  ],
                  // A tap picks the nearest point, within half a step of
                  // it either way: a square round every point.
                  'targets': layer((canvas, size) {
                    final g = GridGeometry(size);
                    for (final (x, y) in points) {
                      canvas.drawRect(
                        Rect.fromCenter(
                          center: g.toScreen(x, y),
                          width: g.step,
                          height: g.step,
                        ),
                        Paint(),
                      );
                    }
                  }, 'place-the-center points'),
                  'hits': [for (var i = 0; i < points.length; i++) i],
                },
              ),
              16,
            ),
            gap(14, when: 'done'),
            {'feedback': true},
          ],
        ),
    ],
  );
}

/// A piece of a formula tapped where it stands (Read the Equation, Point
/// at the Inside): clear or tinted, a hairline until picked, its formula
/// at 18 as wide as it needs.
Node piece(
  int i,
  String latex, {
  required num minw,
  required num minh,
  required List<num> pad,
  required Object idleBorder,
}) => plain(
  i,
  more(
    box(
      pad: pad,
      radius: 10,
      fill: tone('clear', 'emberBg', 'forestBg', 'errorBg'),
      border: tone(idleBorder, 'ember', 'forest', 'error'),
      stroke: tone(1, 2, 2, 2),
      child: center(more(tex(latex, 18), {'fit': false}), wf: 1),
    ),
    {'minw': minw, 'maxw': 170, 'minh': minh},
  ),
);

/// Pieces in a white box, wrapped and centred as the games set them.
Node piecesBox(List<Node> pieces, {required List<num> pad}) => box(
  w: 'max',
  pad: pad,
  fill: 'white',
  radius: 16,
  border: 'line',
  child: {
    'k': 'wrap',
    'align': 'center',
    'cross': 'center',
    'spacing': 6,
    'run': 8,
    'c': pieces,
  },
);

// Read the Equation

Map<String, Object?> readTheEquation() => pickScreen(
  id: 'read-the-equation',
  chapter: 'mathematics',
  title: 'Read the Equation',
  closing:
      'Most conic questions are read, not solved: which piece is '
      'the radius, which fixes the center, which decides the direction. '
      'Putting numbers through them is desk work.',
  right: 'CORRECT',
  wrong: 'NOT THAT PART',
  brief: briefJson(readingConicsBrief, 'readingConicsBrief'),
  rounds: [
    for (final r in readRounds)
      (
        options: r.tokens,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'POINT AT THE PART', 'color': 'ember'},
          gap(8),
          {'text': r.ask, 'size': 16, 'line': 1.5},
          gap(18),
          piecesBox(
            [
              for (final (i, token) in r.tokens.indexed)
                piece(
                  i,
                  token,
                  minw: 44,
                  minh: 52,
                  pad: const [8, 6, 8, 6],
                  idleBorder: 'line',
                ),
            ],
            pad: const [10, 18, 10, 18],
          ),
          gap(18, when: 'done'),
          {'feedback': true},
        ],
      ),
  ],
);

// Point at the Inside

Map<String, Object?> pointAtTheInside() => pickScreen(
  id: 'point-at-the-inside',
  chapter: 'mathematics',
  title: 'Point at the Inside',
  closing:
      'Find the inside first and the chain rule writes itself: '
      'derivative of the outside, times derivative of the inside. '
      'Multiplying it out is desk work.',
  right: 'CORRECT',
  wrong: 'NOT THAT PART',
  brief: briefJson(chainRuleBrief, 'chainRuleBrief'),
  rounds: [
    for (final r in insideRounds)
      (
        options: r.choices,
        notes: null,
        tex: null,
        answer: r.choiceAnswer,
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'POINT AT THE PART', 'color': 'ember'},
          gap(8),
          {'text': r.ask, 'size': 16, 'line': 1.5},
          gap(18),
          piecesBox(
            [
              for (final (i, token) in r.tokens.indexed)
                if (r.inert.contains(i))
                  // The glue between the pieces, never an answer.
                  more(
                    box(
                      pad: const [4, 0, 4, 0],
                      child: center(
                        more(tex(token, 18), {'fit': false}),
                        wf: 1,
                      ),
                    ),
                    {'minh': 54},
                  )
                else
                  piece(
                    i - r.inert.where((g) => g < i).length,
                    token,
                    minw: 46,
                    minh: 54,
                    pad: const [10, 6, 10, 6],
                    idleBorder: 'line',
                  ),
            ],
            pad: const [10, 20, 10, 20],
          ),
          gap(18, when: 'done'),
          {'feedback': true},
        ],
      ),
  ],
);

// Balance Both Sides

Map<String, Object?> balanceBothSides() {
  Node blank(Balance r, int k) => {
    'k': 'slot',
    's': k,
    'child': more(
      box(
        align: 'center',
        radius: 10,
        fill: slot(k, [for (final _ in r.chips) 'white'], empty: 'cream'),
        border: askDone(
          slot(k, [for (final _ in r.chips) 'ember'], empty: 'ink3'),
          slot(k, [
            for (final c in r.chips) c == r.answers[k] ? 'forest' : 'error',
          ], empty: 'error'),
        ),
        stroke: 2,
        child: slot(
          k,
          [
            for (final c in r.chips)
              more(t(c, font: 'mono', size: 16), {'fw': 700}),
          ],
          empty: more(t('?', font: 'mono', size: 16, color: 'ink3'), {
            'fw': 700,
          }),
        ),
      ),
      {'minw': 52, 'minh': 44},
    ),
  };

  Node side(Balance r, List<(String, bool)> parts, int first) {
    var k = first;
    final rows = <Node>[];
    for (final (latex, hasBlank) in parts) {
      final at = hasBlank ? k++ : -1;
      rows.add(
        row([
          flex(tex(latex, 18), 1, true),
          if (hasBlank) ...[gapW(10), blank(r, at)],
        ], main: 'center'),
      );
    }
    return box(
      w: 'max',
      pad: const [12, 14, 12, 14],
      fill: 'white',
      radius: 14,
      border: 'line',
      c: [
        for (final (i, row) in rows.indexed) ...[if (i > 0) gapH(10), row],
      ],
    );
  }

  return game(
    pickSeveral(
      id: 'balance-both-sides',
      chapter: 'mathematics',
      title: 'Balance Both Sides',
      closing:
          'Whatever you add to complete a square has to appear on both '
          'sides. Getting the number right and dropping it from the '
          'right-hand side gives a circle of the wrong size.',
      right: 'BALANCED',
      wrong: 'NOT BALANCED',
      brief: briefJson(completeSquareBrief, 'completeSquareBrief'),
      rounds: [
        for (final r in balances)
          (
            options: r.chips,
            answer: [for (final a in r.answers) r.chips.indexOf(a)],
            alone: const [],
            why: r.why,
            source: r.source,
            screen: [
              {'overline': 'KEEP IT BALANCED', 'color': 'ember'},
              gap(8),
              t(
                'Complete the square. Every blank has to be filled, on both '
                'sides of the equals.',
                size: 15,
                line: 1.5,
                color: 'ink2',
              ),
              gap(16),
              side(r, r.left, 0),
              gap(10),
              center(t('=', font: 'heading', size: 20)),
              gap(10),
              side(r, r.right, r.slotsOnLeft),
              gap(18),
              overlineNode('NUMBERS'),
              gap(10),
              {
                'k': 'wrap',
                'spacing': 10,
                'run': 10,
                'c': [
                  for (final (j, c) in r.chips.indexed)
                    answer(
                      j,
                      more(
                        box(
                          align: 'center',
                          radius: 12,
                          border: 'line',
                          child: more(t(c, font: 'mono', size: 17), {
                            'fw': 700,
                          }),
                        ),
                        {'minw': 62, 'minh': 52},
                      ),
                      fill: 'white',
                    ),
                ],
              },
              gap(18, when: 'done'),
              {'feedback': true},
            ],
          ),
      ],
    ),
    const {},
    (i) => {
      'order': 'slots',
      'reuse': true,
      'most': balances[i].answers.length,
      'need': balances[i].answers.length,
    },
  );
}

// Sign the Bend

Map<String, Object?> signTheBend() {
  // The arc in a button, as the button's border leaves room for it: a
  // hairline of 1 until picked, then 2.
  Object arc(bool up, Color color, double h, String what) => record(
    ArcPainter(up: up, color: color).paint,
    h,
    range: (20, 600),
    what: what,
  );
  final arcs = {
    for (final up in [false, true])
      up: tone(
        arc(up, AppColors.ink2, 44, 'sign-the-bend arc $up idle'),
        arc(up, AppColors.ember, 42, 'sign-the-bend arc $up picked'),
        arc(up, AppColors.forest, 42, 'sign-the-bend arc $up right'),
        arc(up, AppColors.error, 42, 'sign-the-bend arc $up wrong'),
      ),
  };

  Node bend(int i, bool up) => answer(
    i,
    box(
      h: 46,
      w: 'max',
      radius: 10,
      border: tone('line', 'ember', 'forest', 'error'),
      stroke: tone(1, 2, 2, 2),
      child: draw(arcs[up]!),
    ),
    radius: 10,
    fill: tone('white', 'emberBg', 'forestBg', 'errorBg'),
  );

  return game(
    pickSeveral(
      id: 'sign-the-bend',
      chapter: 'mathematics',
      title: 'Sign the Bend',
      closing:
          'An inflection point needs the second derivative to be zero AND '
          'to change sign through it. Where the bend never changes there is '
          'no inflection point, however many flat spots the curve has.',
      right: 'FLIP FOUND',
      wrong: 'NOT THE BEND IT HAS',
      brief: briefJson(concavityBrief, 'concavityBrief'),
      rounds: [
        for (final (n, r) in bendRounds.indexed)
          (() {
            final (yLo, yHi) = r.poly.range(r.x0, r.x1);
            Object curve(double? reveal, String what) => record(
              CurvePainter(
                poly: r.poly,
                x0: r.x0,
                x1: r.x1,
                yLo: yLo,
                yHi: yHi,
                cuts: r.cuts,
                reveal: reveal,
                revealIsRight: true,
              ).paint,
              210,
              what: what,
            );
            final regions = r.regions;
            return (
              options: [
                for (final (a, b) in regions) ...[
                  '${a.toInt()} to ${b.toInt()}: frowns',
                  '${a.toInt()} to ${b.toInt()}: smiles',
                ],
              ],
              answer: [
                for (final (i, up) in r.bendsUp.indexed) 2 * i + (up ? 1 : 0),
              ],
              alone: const <int>[],
              why: r.why,
              source: r.source,
              screen: <Map<String, Object?>>[
                ...opening(
                  'SIGN EVERY REGION',
                  'Mark each region: does the curve smile or frown through '
                      'it? Then the flip, if there is one, is the inflection '
                      'point.',
                ),
                gap(12),
                box(
                  w: 'max',
                  pad: const [12, 12, 12, 12],
                  fill: 'white',
                  radius: 14,
                  border: 'line',
                  child: tex(r.subject, 16),
                ),
                gap(12),
                framed(
                  draw(
                    askDone(
                      curve(null, 'sign-the-bend round $n'),
                      curve(r.inflection, 'sign-the-bend round $n answered'),
                    ),
                  ),
                  210,
                ),
                gap(8),
                box(
                  pad: const [CurveGeometry.padX, 0, CurveGeometry.padX, 0],
                  child: row([
                    for (final (i, (a, b)) in regions.indexed) ...[
                      if (i > 0) gapW(6),
                      flex(
                        col([
                          t(
                            '${a.toInt()} to ${b.toInt()}',
                            font: 'mono',
                            size: 10.5,
                            color: 'ink3',
                            align: 'center',
                          ),
                          gapH(4),
                          bend(2 * i, false),
                          gapH(5),
                          bend(2 * i + 1, true),
                        ], cross: 'stretch'),
                        ((b - a) * 10).round(),
                      ),
                    ],
                  ]),
                ),
                gap(8),
                t(r.unit, font: 'mono', size: 11, color: 'ink3'),
                gap(16, when: 'done'),
                {'feedback': true},
              ],
            );
          })(),
      ],
    ),
    const {},
    (i) => {
      'groups': [
        for (var k = 0; k < bendRounds[i].regions.length; k++)
          [2 * k, 2 * k + 1],
      ],
      'need': bendRounds[i].regions.length,
      if (bendRounds[i].inflection == null) 'right': 'NO FLIP, CORRECTLY',
    },
  );
}

// What Was Asked

Map<String, Object?> whatWasAsked() => pickScreen(
  id: 'what-was-asked',
  chapter: 'mathematics',
  title: 'What Was Asked',
  closing:
      'The calculus is the easy half. Where it happens and how much it '
      'is are two different answers out of the same working, and the '
      'exam is happy to offer you both.',
  right: 'THAT IS THE ONE',
  wrong: 'TRUE, BUT NOT ASKED',
  brief: briefJson(askedForBrief, 'askedForBrief'),
  rounds: [
    for (final r in askedRounds)
      (
        options: r.quantities,
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          {'overline': 'ALL OF IT IS TRUE', 'color': 'ember'},
          gap(8),
          {'text': r.question, 'size': 16, 'line': 1.5},
          gap(12),
          box(
            w: 'max',
            pad: const [12, 12, 12, 12],
            fill: 'creamDark',
            radius: 12,
            child: tex(r.working, 14),
          ),
          gap(6),
          t(
            'The working is already done and correct.',
            font: 'mono',
            size: 11.5,
            color: 'ink3',
          ),
          gap(12),
          for (final (i, q) in r.quantities.indexed) ...[
            if (i > 0) gap(8),
            tinted(
              i,
              more(tex(q, 16), {'align': 'left'}),
              h: 58,
              pad: const [16, 0, 16, 0],
              align: 'left',
            ),
          ],
          gap(16, when: 'done'),
          {'feedback': true},
        ],
      ),
  ],
);

// Every Rule It Needs

Map<String, Object?> everyRule() {
  const labels = ['Product rule', 'Quotient rule', 'Chain rule'];
  const table = 3;

  // A toggle: a check box that is ember while the toggle is on, answered
  // or not, then the rule's name.
  Node toggle(int i, String label) => answer(
    i,
    box(
      w: 'max',
      h: 62,
      pad: const [16, 0, 16, 0],
      radius: 14,
      border: tone('line', 'ember', 'forest', 'error'),
      stroke: tone(1, 2, 2, 2),
      child: row([
        box(
          w: 26,
          h: 26,
          radius: 7,
          fill: onOff('ember', 'clear'),
          border: onOff('ember', 'line'),
          stroke: 1.5,
          child: icon('check', size: 17, color: onOff('pure', 'clear')),
        ),
        gapW(14),
        t(label, font: 'heading', size: 16),
      ]),
    ),
    radius: 14,
    fill: tone('white', 'emberBg', 'forestBg', 'errorBg'),
  );

  return game(
    pickSeveral(
      id: 'every-rule',
      chapter: 'mathematics',
      title: 'Every Rule It Needs',
      closing:
          'Ask two questions of any derivative: is anything multiplied '
          'or divided, and is any argument something other than plain x. '
          'Most FE problems answer yes to the second one.',
      right: 'CORRECT',
      wrong: 'NOT THE FULL SET',
      brief: briefJson(whichRuleBrief, 'whichRuleBrief'),
      rounds: [
        for (final r in ruleRounds)
          (
            options: [...labels, 'Just the table'],
            answer: r.rules.isEmpty
                ? const [table]
                : [
                    for (final rule in DerivRule.values)
                      if (r.rules.contains(rule)) rule.index,
                  ],
            alone: const [table],
            why: r.why,
            source: r.source,
            screen: [
              {'overline': 'TAP EVERY RULE YOU NEED', 'color': 'ember'},
              gap(8),
              t(
                'More than one can apply. Tap all of them, or say it comes '
                'straight off the table.',
                size: 14,
                line: 1.5,
                color: 'ink2',
              ),
              gap(16),
              statement(
                r.function,
                21,
                pad: const [14, 22, 14, 22],
                radius: 16,
              ),
              gap(16),
              for (final (i, label) in labels.indexed) ...[
                toggle(i, label),
                gap(10),
              ],
              toggle(table, 'Just the table'),
              gap(16, when: 'done'),
              {'feedback': true},
            ],
          ),
      ],
    ),
    const {},
    (_) => {'touched': true, 'stay': true},
  );
}

// Find the Slip

Map<String, Object?> findTheSlip() => game(
  pickSeveral(
    id: 'find-the-slip',
    chapter: 'mathematics',
    title: 'Find the Slip',
    closing:
        'Seeing a wrong line means holding the right one in your '
        'head. Dropped chain factors, swapped quotient terms and '
        'unsquared denominators are where the marks actually go.',
    right: 'CORRECT',
    wrong: 'NOT QUITE',
    brief: briefJson(quotientOrderBrief, 'quotientOrderBrief'),
    rounds: [
      for (final r in slips)
        (
          // The lines first, then the reasons after them.
          options: [
            for (final (i, _) in r.lines.indexed) 'Line ${i + 1}',
            ...r.reasons,
          ],
          answer: [r.badLine, r.lines.length + r.reason],
          alone: const <int>[],
          why: r.why,
          source: r.source,
          screen: [
            {'overline': 'ONE LINE IS WRONG', 'color': 'ember'},
            gap(8),
            t(
              'Tap the line that does not follow, then say what went wrong.',
              size: 14,
              line: 1.5,
              color: 'ink2',
            ),
            gap(14),
            statement(r.problem, 19, pad: const [12, 14, 12, 14], radius: 16),
            gap(12),
            for (final (i, line) in r.lines.indexed) ...[
              tinted(
                i,
                row([
                  t('${i + 1}', font: 'mono', size: 13, color: 'ink3'),
                  gapW(12),
                  flex(more(tex(line, 16), {'align': 'left'})),
                ]),
                w: null,
                pad: const [12, 12, 12, 12],
              ),
              gap(8),
            ],
            gap(10),
            overlineNode('AND WHAT WENT WRONG'),
            gap(10),
            for (final (i, reason) in r.reasons.indexed) ...[
              tinted(
                r.lines.length + i,
                t(reason, size: 14, line: 1.45),
                w: null,
                pad: const [14, 14, 14, 14],
              ),
              gap(8),
            ],
            gap(12, when: 'done'),
            {'feedback': true},
          ],
        ),
    ],
  ),
  const {},
  (i) => {
    'groups': [
      [for (var k = 0; k < slips[i].lines.length; k++) k],
      [
        for (var k = 0; k < slips[i].reasons.length; k++)
          slips[i].lines.length + k,
      ],
    ],
    'need': 2,
  },
);

// Slide to the Flat Spot

/// The marker steps with the tangent (the second step) drawn as a short
/// upright line on a canvas moved to its middle and turned. Drawn straight,
/// its ends sit 42 pixels from the curve along a direction scaled to unit
/// length, which bends with the width at every point and cost 600 KB to
/// download. Turned, the move is a straight line in the width and the turn
/// is the slope angle form: atan2 of the tangent's across and up, the up
/// part fixed by the curve's height alone.
Draw turnedTangent(Draw marker) => (canvas, size) {
  final recording = canvas as RecordingCanvas;
  final had = recording.ops.length;
  marker(canvas, size);
  final mine = recording.ops.sublist(had);
  recording.ops.removeRange(had, recording.ops.length);
  final tangent = mine[1];
  final a = Offset(tangent[1]! as double, tangent[2]! as double);
  final b = Offset(tangent[3]! as double, tangent[4]! as double);
  final middle = (a + b) / 2;
  final along = b - a;
  recording.ops.add(mine[0]);
  canvas
    ..save()
    ..translate(middle.dx, middle.dy)
    // Turned a quarter less, so the line is drawn up the canvas and the
    // angle's run is the tangent's height, which does not follow the width.
    ..rotate(atan2(-along.dx, along.dy));
  recording.ops.add([
    'line',
    0.0,
    -along.distance / 2,
    0.0,
    along.distance / 2,
    tangent[5],
  ]);
  canvas.restore();
  recording.ops.addAll(mine.sublist(2));
};

Map<String, Object?> slideToFlat() {
  const h = 240.0;
  return game(
    pickScreen(
      id: 'slide-to-flat',
      chapter: 'mathematics',
      title: 'Slide to the Flat Spot',
      closing:
          'Maximum and minimum both sit where the slope is zero. Which one '
          'you are standing on is decided by the way the curve bends, not '
          'by the flat spot itself. Solving for it belongs on paper.',
      right: 'FLAT',
      wrong: 'STILL SLOPING',
      brief: briefJson(criticalPointBrief, 'criticalPointBrief'),
      rounds: [
        for (final (n, r) in flatRounds.indexed)
          (() {
            final (yLo, yHi) = r.poly.range(r.x0, r.x1);
            final xs = [for (var x = r.x0.toInt(); x <= r.x1.toInt(); x++) x];
            CurvePainter curve({double? marker, double? reveal}) =>
                CurvePainter(
                  poly: r.poly,
                  x0: r.x0,
                  x1: r.x1,
                  yLo: yLo,
                  yHi: yHi,
                  markerX: marker,
                  showTangent: true,
                  reveal: reveal,
                  revealIsRight: true,
                );
            // The axis and the curve are its first two steps; the right
            // spot and the marker are drawn after them.
            const base = 2;
            return (
              options: [for (final x in xs) '$x'],
              notes: null,
              tex: null,
              answer: r.answer - r.x0.toInt(),
              why: r.why,
              source: r.source,
              screen: [
                {'overline': 'FIND THE FLAT SPOT', 'color': 'ember'},
                gap(8),
                {'text': r.ask, 'size': 16, 'line': 1.5},
                gap(12),
                box(
                  w: 'max',
                  pad: const [12, 14, 12, 14],
                  fill: 'white',
                  radius: 14,
                  border: 'line',
                  child: tex(r.subject, 17),
                ),
                gap(10),
                t(
                  'Drag the marker. The short line is the slope where you '
                  'are.',
                  font: 'mono',
                  size: 11.5,
                  color: 'ink3',
                ),
                gap(12),
                framed({
                  'k': 'tapdraw',
                  'layers': [
                    // The axis and the curve.
                    {
                      'd': record(
                        curve().paint,
                        h,
                        what: 'slide-to-flat round $n',
                      ),
                    },
                    // Once answered, the flat spot.
                    {
                      'd': askDone(
                        null,
                        record(
                          part(curve(reveal: r.answer.toDouble()).paint, base),
                          h,
                          what: 'slide-to-flat round $n flat',
                        ),
                      ),
                    },
                    // The marker, its tangent and its line, where it is.
                    {
                      'd': {
                        'pick': [
                          for (final x in xs)
                            record(
                              turnedTangent(
                                part(curve(marker: x.toDouble()).paint, base),
                              ),
                              h,
                              what: 'slide-to-flat round $n marker $x',
                            ),
                        ],
                        'none': null,
                      },
                    },
                  ],
                  // The marker goes to the whole number nearest the finger,
                  // however high or low it is, and to an end past either
                  // end.
                  'targets': record(
                    (canvas, size) {
                      final g = CurveGeometry(
                        size,
                        x0: r.x0,
                        x1: r.x1,
                        yLo: yLo,
                        yHi: yHi,
                      );
                      for (final x in xs) {
                        canvas.drawCircle(
                          g.toScreen(x.toDouble(), r.poly.at(x.toDouble())),
                          10000,
                          Paint(),
                        );
                      }
                    },
                    h,
                    what: 'slide-to-flat round $n spots',
                  ),
                  'axis': 'x',
                  'drag': true,
                  'hits': [for (var i = 0; i < xs.length; i++) i],
                  'h': h,
                }, h),
                gap(6),
                box(
                  pad: const [CurveGeometry.padX, 0, CurveGeometry.padX, 0],
                  child: row([
                    for (final v in [
                      '${r.x0.toInt()}',
                      r.unit,
                      '${r.x1.toInt()}',
                    ])
                      t(v, font: 'mono', size: 11, color: 'ink3'),
                  ], main: 'between'),
                ),
                gap(12),
                row([
                  t('Marker at', font: 'mono', size: 12, color: 'ink2'),
                  gapW(8),
                  box(
                    pad: const [12, 5, 12, 5],
                    fill: 'emberBg',
                    radius: 8,
                    child: t(
                      {
                        'pick': [for (final x in xs) '$x'],
                        'none': '${r.startAt}',
                      },
                      font: 'mono',
                      size: 14,
                      color: 'ember',
                    ),
                  ),
                ]),
                gap(16, when: 'done'),
                {'feedback': true},
              ],
            );
          })(),
      ],
    ),
    const {},
    (i) => {
      'start': flatRounds[i].startAt - flatRounds[i].x0.toInt(),
      'any': true,
    },
  );
}
