import 'acute_or_obtuse_game.dart';
import 'balance_both_sides_game.dart';
import 'both_sides_game.dart';
import 'build_the_identity_game.dart';
import 'discriminant_gate_game.dart';
import 'every_rule_game.dart';
import 'find_the_slip_game.dart';
import 'fix_the_sign_game.dart';
import 'grade_sense_game.dart';
import 'land_the_resultant_game.dart';
import 'next_line_game.dart';
import 'one_log_game.dart';
import 'open_or_closed_game.dart';
import 'order_the_moves_game.dart';
import 'perpendicular_flip_game.dart';
import 'pick_u_game.dart';
import 'place_the_center_game.dart';
import 'point_at_the_inside_game.dart';
import 'quadrant_signs_game.dart';
import 'read_the_equation_game.dart';
import 'reaches_further_game.dart';
import 'resolve_it_game.dart';
import 'rule_or_trap_game.dart';
import 'run_the_loop_game.dart';
import 'set_it_up_game.dart';
import 'sign_the_bend_game.dart';
import 'slide_to_flat_game.dart';
import 'shadow_falls_game.dart';
import 'stretch_it_game.dart';
import 'take_the_diagonal_game.dart';
import 'tap_the_side_game.dart';
import 'walk_the_circle_game.dart';
import 'what_was_asked_game.dart';
import 'whats_missing_game.dart';
import 'which_law_game.dart';
import 'which_region_game.dart';
import 'which_ratio_game.dart';
import 'which_way_turns_game.dart';
import 'which_way_simpler_game.dart';

/// A uniform description of what an item asks, so ONE gate can check every
/// item against the rules we have learned the hard way.
///
/// This deliberately says nothing about how a round is answered. Items are
/// free to invent whatever interaction their content needs; the gate only
/// checks that whatever they invented is honest: one defensible answer, no
/// repeated options, and provenance back to a real problem in the lesson.
class RoundAudit {
  const RoundAudit({
    required this.source,
    this.options = const [],
    this.answer,
    this.positional = false,
  });

  /// The web problem this round was authored from.
  final String source;

  /// The choices offered, where an item offers choices. Empty is fine: an item
  /// answered by pointing, ordering or toggling has none.
  final List<String> options;

  /// Index into [options] of the one right answer, where that applies.
  final int? answer;

  /// True when the options are PLACES rather than choices: tapping a term in
  /// an equation, for instance, where two plus signs are two different places
  /// and repeating a label is not offering the same choice twice.
  final bool positional;
}

class GameAudit {
  const GameAudit({
    required this.gameId,
    required this.lessonId,
    required this.problemPrefix,
    required this.rounds,
  });

  final String gameId;
  final String lessonId;

  /// Every source id in this lesson starts with this.
  final String problemPrefix;
  final List<RoundAudit> rounds;
}

/// Every built item, described the same way.
List<GameAudit> auditAllGames() => [
  GameAudit(
    gameId: 'perpendicular-flip',
    lessonId: 'straight-lines-quadratics',
    problemPrefix: 'math-slq-',
    rounds: [for (final r in flipRounds) RoundAudit(source: r.sourceProblemId)],
  ),
  GameAudit(
    gameId: 'discriminant-gate',
    lessonId: 'straight-lines-quadratics',
    problemPrefix: 'math-slq-',
    rounds: [
      for (final g in gateRounds)
        RoundAudit(
          source: 'math-slq-q3',
          options: g.ask == GateAsk.countFromCurve
              ? const ['no roots', 'one root', 'two roots']
              : [for (var i = 0; i < g.curves.length; i++) 'curve $i'],
          answer: g.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'grade-sense',
    lessonId: 'straight-lines-quadratics',
    problemPrefix: 'math-slq-',
    rounds: [
      for (final r in gradeRounds)
        RoundAudit(
          source: 'math-slq-q1',
          options: [for (final s in r.stretches) s.name],
          answer: r.answer.first,
        ),
    ],
  ),
  GameAudit(
    gameId: 'rule-or-trap',
    lessonId: 'logarithms',
    problemPrefix: 'math-log-',
    rounds: [
      for (final c in claims)
        RoundAudit(
          source: c.source,
          options: const ['legal', 'no such rule'],
          answer: c.legal ? 0 : 1,
        ),
    ],
  ),
  GameAudit(
    gameId: 'order-the-moves',
    lessonId: 'logarithms',
    problemPrefix: 'math-log-',
    rounds: [
      for (final m in moveSets)
        RoundAudit(source: m.source, options: m.shown, answer: m.answer.first),
    ],
  ),
  GameAudit(
    gameId: 'one-log',
    lessonId: 'logarithms',
    problemPrefix: 'math-log-',
    rounds: [
      for (final c in collapses)
        RoundAudit(source: c.source, options: c.options, answer: c.answer),
    ],
  ),
  GameAudit(
    gameId: 'tap-the-side',
    lessonId: 'right-triangle-trig',
    problemPrefix: 'math-rtt-',
    rounds: [for (final r in sideRounds) RoundAudit(source: r.source)],
  ),
  GameAudit(
    gameId: 'which-ratio',
    lessonId: 'right-triangle-trig',
    problemPrefix: 'math-rtt-',
    rounds: [
      for (final r in ratioRounds)
        RoundAudit(
          source: r.source,
          options: const ['sin', 'cos', 'tan'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'resolve-it',
    lessonId: 'right-triangle-trig',
    problemPrefix: 'math-rtt-',
    rounds: [
      for (final r in resolves)
        RoundAudit(
          source: r.source,
          options: const ['cosine', 'sine'],
          answer: r.answerIsCos ? 0 : 1,
        ),
    ],
  ),
  GameAudit(
    gameId: 'which-law',
    lessonId: 'law-of-sines-cosines',
    problemPrefix: 'math-lsc-',
    rounds: [
      for (final r in lawRounds)
        RoundAudit(
          source: r.source,
          options: const ['sines', 'cosines'],
          answer: r.sines ? 0 : 1,
        ),
    ],
  ),
  GameAudit(
    gameId: 'set-it-up',
    lessonId: 'law-of-sines-cosines',
    problemPrefix: 'math-lsc-',
    rounds: [
      for (final s in setups)
        RoundAudit(source: s.source, options: s.options, answer: s.answer),
    ],
  ),
  GameAudit(
    gameId: 'walk-the-circle',
    lessonId: 'unit-circle-trig-identities',
    problemPrefix: 'math-uci-',
    rounds: [
      for (final r in circleRounds)
        RoundAudit(
          source: r.source,
          options: [for (final c in r.choices) '$c degrees'],
          answer: r.choices.indexOf(r.answer),
        ),
    ],
  ),
  GameAudit(
    gameId: 'quadrant-signs',
    lessonId: 'unit-circle-trig-identities',
    problemPrefix: 'math-uci-',
    rounds: [
      for (final r in quadrantRounds)
        RoundAudit(
          source: r.source,
          options: const ['I', 'II', 'III', 'IV'],
          answer: r.answer - 1,
        ),
    ],
  ),
  GameAudit(
    gameId: 'build-the-identity',
    lessonId: 'unit-circle-trig-identities',
    problemPrefix: 'math-uci-',
    rounds: [
      for (final i in identities)
        RoundAudit(
          source: i.source,
          options: i.chips,
          answer: i.chips.indexOf(i.slots.first),
        ),
    ],
  ),
  GameAudit(
    gameId: 'place-the-center',
    lessonId: 'circles-conics',
    problemPrefix: 'math-cc-',
    rounds: [for (final r in centerRounds) RoundAudit(source: r.source)],
  ),
  GameAudit(
    gameId: 'read-the-equation',
    lessonId: 'circles-conics',
    problemPrefix: 'math-cc-',
    rounds: [
      for (final r in readRounds)
        RoundAudit(
          source: r.source,
          options: r.tokens,
          answer: r.answer,
          positional: true,
        ),
    ],
  ),
  GameAudit(
    gameId: 'balance-both-sides',
    lessonId: 'circles-conics',
    problemPrefix: 'math-cc-',
    rounds: [
      for (final b in balances)
        RoundAudit(
          source: b.source,
          options: b.chips,
          answer: b.chips.indexOf(b.answers.first),
        ),
    ],
  ),
  GameAudit(
    gameId: 'every-rule',
    lessonId: 'derivatives-rules',
    problemPrefix: 'math-dr-',
    rounds: [
      // The answer here is a SET, so there is no single index to point at.
      for (final r in ruleRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'point-at-the-inside',
    lessonId: 'derivatives-rules',
    problemPrefix: 'math-dr-',
    rounds: [
      for (final r in insideRounds)
        RoundAudit(
          source: r.source,
          options: r.choices,
          answer: r.choiceAnswer,
          positional: true,
        ),
    ],
  ),
  GameAudit(
    gameId: 'slide-to-flat',
    lessonId: 'applications-derivatives',
    problemPrefix: 'math-ad-',
    rounds: [
      // The answer is a place on a curve, reached by dragging: there is no
      // list of choices to describe.
      for (final r in flatRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'sign-the-bend',
    lessonId: 'applications-derivatives',
    problemPrefix: 'math-ad-',
    rounds: [
      // The answer is the sign of every region at once, so again no single
      // index points at it.
      for (final r in bendRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'what-was-asked',
    lessonId: 'applications-derivatives',
    problemPrefix: 'math-ad-',
    rounds: [
      for (final r in askedRounds)
        RoundAudit(
          source: r.source,
          options: r.quantities,
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'pick-u',
    lessonId: 'integral-calculus',
    problemPrefix: 'math-ic-',
    rounds: [
      // The u decision, including the way out when nothing fits. The second
      // decision, du, is not describable as an index into these and is
      // checked by the lesson's own tests instead.
      for (final r in uSubRounds)
        RoundAudit(
          source: r.source,
          options: [...r.uOptions, 'no substitution fits'],
          answer: r.noSub ? r.uOptions.length : r.uAnswer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'which-way-simpler',
    lessonId: 'integral-calculus',
    problemPrefix: 'math-ic-',
    rounds: [
      for (final r in partsRounds)
        RoundAudit(
          source: r.source,
          options: [for (final b in r.branches) 'u = ${b.u}'],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'whats-missing',
    lessonId: 'integral-calculus',
    problemPrefix: 'math-ic-',
    rounds: [
      for (final r in missingRounds)
        RoundAudit(
          source: r.source,
          options: missingVerdicts,
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'run-the-loop',
    lessonId: 'lhopitals-rule',
    problemPrefix: 'math-lh-',
    rounds: [
      // The answer is a SEQUENCE of moves, so no index points at it. The
      // move list is fixed and its own tests check the sequences.
      for (final r in loopRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'next-line',
    lessonId: 'lhopitals-rule',
    problemPrefix: 'math-lh-',
    rounds: [
      for (final r in nextLines)
        RoundAudit(source: r.source, options: r.options, answer: r.answer),
    ],
  ),
  GameAudit(
    gameId: 'both-sides',
    lessonId: 'lhopitals-rule',
    problemPrefix: 'math-lh-',
    rounds: [
      // One report per side, so again a pair rather than an index.
      for (final r in sidesRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'land-the-resultant',
    lessonId: 'vector-basics-unit-vectors',
    problemPrefix: 'math-vbu-',
    rounds: [
      // Answered by pointing at a place on a grid, so there is no list.
      for (final r in resultantRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'stretch-it',
    lessonId: 'vector-basics-unit-vectors',
    problemPrefix: 'math-vbu-',
    rounds: [
      // Answered by working a number up and down, not by choosing.
      for (final r in stretchRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'reaches-further',
    lessonId: 'vector-basics-unit-vectors',
    problemPrefix: 'math-vbu-',
    rounds: [
      for (final r in reachRounds)
        RoundAudit(
          source: r.source,
          options: const ['A', 'the same', 'B'],
          answer: switch (r.answer) {
            Reach.first => 0,
            Reach.same => 1,
            Reach.second => 2,
          },
        ),
    ],
  ),
  GameAudit(
    gameId: 'take-the-diagonal',
    lessonId: 'dot-product-angle',
    problemPrefix: 'math-dpa-',
    rounds: [
      // The answer is the set of diagonal cells, so no single index names it.
      for (final r in diagonalRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'open-or-closed',
    lessonId: 'dot-product-angle',
    problemPrefix: 'math-dpa-',
    rounds: [
      for (final r in signRounds)
        RoundAudit(
          source: r.source,
          options: const ['positive', 'zero', 'negative'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'shadow-falls',
    lessonId: 'dot-product-angle',
    problemPrefix: 'math-dpa-',
    rounds: [
      // Answered by pointing at a mark on the member, so there is no list.
      for (final r in shadowRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'which-way-turns',
    lessonId: 'cross-product-applications',
    problemPrefix: 'math-cpa-',
    rounds: [
      for (final r in turnRounds)
        RoundAudit(
          source: r.source,
          options: const ['counterclockwise', 'clockwise', 'no turn'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'which-region',
    lessonId: 'cross-product-applications',
    problemPrefix: 'math-cpa-',
    rounds: [
      for (final r in regionRounds)
        RoundAudit(
          source: r.source,
          options: const ['triangle', 'parallelogram', 'box around it'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'fix-the-sign',
    lessonId: 'cross-product-applications',
    problemPrefix: 'math-cpa-',
    rounds: [
      for (final r in expansions)
        RoundAudit(
          source: r.source,
          options: const ['the i line', 'the j line', 'the k line', 'nothing'],
          answer: r.bad ?? 3,
        ),
    ],
  ),
  GameAudit(
    gameId: 'find-the-slip',
    lessonId: 'derivatives-rules',
    problemPrefix: 'math-dr-',
    rounds: [
      for (final s in slips)
        RoundAudit(source: s.source, options: s.reasons, answer: s.reason),
    ],
  ),
  GameAudit(
    gameId: 'acute-or-obtuse',
    lessonId: 'law-of-sines-cosines',
    problemPrefix: 'math-lsc-',
    rounds: [
      for (final v in verdicts)
        RoundAudit(
          source: v.source,
          options: const ['acute', 'right', 'obtuse'],
          answer: v.answer.index,
        ),
    ],
  ),
];
