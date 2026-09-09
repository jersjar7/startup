import 'acute_or_obtuse_game.dart';
import 'balance_both_sides_game.dart';
import 'add_the_squares_game.dart';
import 'both_sides_game.dart';
import 'build_the_binomial_game.dart';
import 'build_the_identity_game.dart';
import 'can_it_start_game.dart';
import 'can_you_claim_that_game.dart';
import 'can_you_seal_it_game.dart';
import 'copy_it_down_game.dart';
import 'discriminant_gate_game.dart';
import 'does_it_hold_game.dart';
import 'enough_or_too_far_game.dart';
import 'every_rule_game.dart';
import 'find_the_slip_game.dart';
import 'fill_the_trace_game.dart';
import 'first_true_wins_game.dart';
import 'fix_the_sign_game.dart';
import 'follow_the_tangent_game.dart';
import 'grade_sense_game.dart';
import 'grounds_or_not_game.dart';
import 'happens_first_game.dart';
import 'is_there_a_deal_game.dart';
import 'is_that_negligence_game.dart';
import 'how_many_samples_game.dart';
import 'in_what_order_game.dart';
import 'land_the_resultant_game.dart';
import 'next_line_game.dart';
import 'one_log_game.dart';
import 'open_or_closed_game.dart';
import 'order_the_moves_game.dart';
import 'perpendicular_flip_game.dart';
import 'practice_or_title_game.dart';
import 'pick_u_game.dart';
import 'place_the_center_game.dart';
import 'point_at_the_inside_game.dart';
import 'quadrant_signs_game.dart';
import 'read_the_equation_game.dart';
import 'reaches_further_game.dart';
import 'mind_the_order_game.dart';
import 'r_or_r2_game.dart';
import 'read_the_line_game.dart';
import 'reject_or_not_game.dart';
import 'same_pick_game.dart';
import 'read_the_scatter_game.dart';
import 'resolve_it_game.dart';
import 'rule_or_trap_game.dart';
import 'run_the_loop_game.dart';
import 'set_it_up_game.dart';
import 'sign_the_bend_game.dart';
import 'slide_to_flat_game.dart';
import 'shade_the_tail_game.dart';
import 'shadow_falls_game.dart';
import 'stretch_it_game.dart';
import 'take_the_diagonal_game.dart';
import 'tap_the_side_game.dart';
import 'walk_the_circle_game.dart';
import 'what_was_asked_game.dart';
import 'whats_missing_game.dart';
import 'what_is_missing_yet_game.dart';
import 'what_shows_game.dart';
import 'where_it_stops_game.dart';
import 'through_the_means_game.dart';
import 'what_goes_under_game.dart';
import 'what_it_triggers_game.dart';
import 'what_weights_game.dart';
import 'where_it_balances_game.dart';
import 'which_law_game.dart';
import 'which_region_game.dart';
import 'which_section_game.dart';
import 'which_way_points_game.dart';
import 'who_has_to_agree_game.dart';
import 'who_may_do_that_game.dart';
import 'who_pays_the_overrun_game.dart';
import 'which_cell_hurts_game.dart';
import 'which_delivery_game.dart';
import 'which_clock_ran_out_game.dart';
import 'which_element_missing_game.dart';
import 'which_method_game.dart';
import 'wider_or_narrower_game.dart';
import 'which_readout_game.dart';
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
    gameId: 'copy-it-down',
    lessonId: 'spreadsheet-computations',
    problemPrefix: 'math-spr-',
    rounds: [
      // The answer is a set of cells on a grid, so no index names it.
      for (final r in copyRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'happens-first',
    lessonId: 'spreadsheet-computations',
    problemPrefix: 'math-spr-',
    rounds: [
      for (final r in precedenceRounds)
        RoundAudit(
          source: r.source,
          options: r.pieces,
          answer: r.answer,
          // The operators repeat across a formula and are places in it, not
          // choices offered twice.
          positional: true,
        ),
    ],
  ),
  GameAudit(
    gameId: 'what-shows',
    lessonId: 'spreadsheet-computations',
    problemPrefix: 'math-spr-',
    rounds: [
      for (final r in showsRounds)
        RoundAudit(source: r.source, options: r.options, answer: r.answer),
    ],
  ),
  GameAudit(
    gameId: 'fill-the-trace',
    lessonId: 'structured-programming',
    problemPrefix: 'math-prg-',
    rounds: [
      // The answer is a whole column of values, so no single index names it.
      for (final r in traceRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'first-true-wins',
    lessonId: 'structured-programming',
    problemPrefix: 'math-prg-',
    rounds: [
      for (final r in chainRounds)
        RoundAudit(
          source: r.source,
          options: [for (final b in r.branches) b.test ?? 'else'],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'where-it-stops',
    lessonId: 'structured-programming',
    problemPrefix: 'math-prg-',
    rounds: [
      for (final r in whileRounds)
        RoundAudit(
          source: r.source,
          options: [for (final v in r.run) '$v'],
          answer: r.run.indexOf(r.answer),
        ),
    ],
  ),
  GameAudit(
    gameId: 'follow-the-tangent',
    lessonId: 'numerical-methods',
    problemPrefix: 'math-num-',
    rounds: [
      for (final r in tangentRounds)
        RoundAudit(
          source: r.source,
          options: [for (final c in r.candidates) '$c'],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'can-it-start',
    lessonId: 'numerical-methods',
    problemPrefix: 'math-num-',
    rounds: [
      for (final r in bracketRounds)
        RoundAudit(
          source: r.source,
          options: [
            for (var i = 0; i < r.brackets.length; i++)
              String.fromCharCode(65 + i),
            'none of them',
          ],
          answer: r.answer ?? r.brackets.length,
        ),
    ],
  ),
  GameAudit(
    gameId: 'which-method',
    lessonId: 'numerical-methods',
    problemPrefix: 'math-num-',
    rounds: [
      for (final r in methodRounds)
        RoundAudit(
          source: r.source,
          options: const ['newton', 'bisection', 'newton may not converge'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'read-the-line',
    lessonId: 'central-tendency-dispersion',
    problemPrefix: 'stat-ctd-',
    rounds: [
      // Answered by pointing at ticks on an axis, sometimes more than one.
      for (final r in lineRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'which-readout',
    lessonId: 'central-tendency-dispersion',
    problemPrefix: 'stat-ctd-',
    rounds: [
      for (final r in readoutRounds)
        RoundAudit(
          source: r.source,
          options: [
            for (final line in readoutLines) line.$1,
            'not on the screen',
          ],
          answer: r.answer == -1 ? readoutLines.length : r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'what-weights',
    lessonId: 'central-tendency-dispersion',
    problemPrefix: 'stat-ctd-',
    rounds: [
      // The answer is a PAIR of columns, so no single index names it.
      for (final r in weightRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'read-the-scatter',
    lessonId: 'linear-regression-correlation',
    problemPrefix: 'stat-reg-',
    rounds: [
      for (final r in scatterRounds)
        RoundAudit(
          source: r.source,
          options: [for (final c in rChoices) c.toString()],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'through-the-means',
    lessonId: 'linear-regression-correlation',
    problemPrefix: 'stat-reg-',
    rounds: [
      for (final r in meansRounds)
        RoundAudit(
          source: r.source,
          options: [for (final l in r.lines) l.label ?? '?'],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'r-or-r2',
    lessonId: 'linear-regression-correlation',
    problemPrefix: 'stat-reg-',
    rounds: [
      for (final r in rRounds)
        RoundAudit(
          source: r.source,
          options: [for (final o in r.options) o.value],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'same-pick',
    lessonId: 'probability-distributions',
    problemPrefix: 'stat-dist-',
    rounds: [
      for (final r in pickRounds)
        RoundAudit(
          source: r.source,
          options: const ['one result', 'two different results'],
          answer: r.ordered ? 1 : 0,
        ),
    ],
  ),
  GameAudit(
    gameId: 'build-the-binomial',
    lessonId: 'probability-distributions',
    problemPrefix: 'stat-dist-',
    rounds: [
      // The answer is a SET of three factors, so no single index names it.
      for (final r in binomialRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'shade-the-tail',
    lessonId: 'probability-distributions',
    problemPrefix: 'stat-dist-',
    rounds: [
      for (final r in tailRounds)
        RoundAudit(
          source: r.source,
          options: [for (final region in r.regions) region.column],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'where-it-balances',
    lessonId: 'expected-value-weighted-averages',
    problemPrefix: 'stat-ev-',
    rounds: [
      for (final r in balanceRounds)
        RoundAudit(
          source: r.source,
          options: [for (final f in r.fulcrums) f.toString()],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'mind-the-order',
    lessonId: 'expected-value-weighted-averages',
    problemPrefix: 'stat-ev-',
    rounds: [
      // The answer is an ORDERED pair of totals, so no single index names it.
      for (final r in orderRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'add-the-squares',
    lessonId: 'expected-value-weighted-averages',
    problemPrefix: 'stat-ev-',
    rounds: [
      for (final r in squaresRounds)
        RoundAudit(source: r.source, options: r.options, answer: r.answer),
    ],
  ),
  GameAudit(
    gameId: 'what-goes-under',
    lessonId: 'confidence-intervals-estimation',
    problemPrefix: 'stat-ci-',
    rounds: [
      for (final r in underRounds)
        RoundAudit(source: r.source, options: r.options, answer: r.answer),
    ],
  ),
  GameAudit(
    gameId: 'wider-or-narrower',
    lessonId: 'confidence-intervals-estimation',
    problemPrefix: 'stat-ci-',
    rounds: [
      for (final r in moveRounds)
        RoundAudit(
          source: r.source,
          options: const ['narrower', 'no change', 'wider'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'how-many-samples',
    lessonId: 'confidence-intervals-estimation',
    problemPrefix: 'stat-ci-',
    rounds: [
      for (final r in sizeRounds)
        RoundAudit(
          source: r.source,
          options: [for (final n in r.candidates) '$n'],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'which-way-points',
    lessonId: 'hypothesis-testing-goodness-of-fit',
    problemPrefix: 'stat-ht-',
    rounds: [
      for (final r in pointRounds)
        RoundAudit(
          source: r.source,
          options: const ['left only', 'both ends', 'right only'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'reject-or-not',
    lessonId: 'hypothesis-testing-goodness-of-fit',
    problemPrefix: 'stat-ht-',
    rounds: [
      for (final r in verdictRounds)
        RoundAudit(source: r.source, options: r.options, answer: r.answer),
    ],
  ),
  GameAudit(
    gameId: 'which-cell-hurts',
    lessonId: 'hypothesis-testing-goodness-of-fit',
    problemPrefix: 'stat-ht-',
    rounds: [
      for (final r in hurtRounds)
        RoundAudit(
          source: r.source,
          options: [for (final c in r.cells) c.name],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'what-it-triggers',
    lessonId: 'obligations-to-the-public',
    problemPrefix: 'eth-otp-',
    rounds: [
      for (final r in triggerRounds)
        RoundAudit(
          source: r.source,
          options: [for (final d in duties) d.$1],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'in-what-order',
    lessonId: 'obligations-to-the-public',
    problemPrefix: 'eth-otp-',
    rounds: [
      // The answer is an ORDERED triple out of four, so no single index names
      // it.
      for (final r in ladderRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'enough-or-too-far',
    lessonId: 'obligations-to-the-public',
    problemPrefix: 'eth-otp-',
    rounds: [
      for (final r in proportionRounds)
        RoundAudit(
          source: r.source,
          options: const ['not enough', 'what the rules ask', 'more than that'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'can-you-seal-it',
    lessonId: 'obligations-employers-clients-peers',
    problemPrefix: 'eth-oec-',
    rounds: [
      for (final r in sealRounds)
        RoundAudit(
          source: r.source,
          options: const ['seal it', 'not yours to seal', 'seal your part'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'who-has-to-agree',
    lessonId: 'obligations-employers-clients-peers',
    problemPrefix: 'eth-oec-',
    rounds: [
      // The answer is a SET of parties whose size the student is not told, so
      // no single index names it.
      for (final r in consentRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'can-you-claim-that',
    lessonId: 'obligations-employers-clients-peers',
    problemPrefix: 'eth-oec-',
    rounds: [
      for (final r in claimRounds)
        RoundAudit(source: r.source, options: r.claims, answer: r.answer),
    ],
  ),
  GameAudit(
    gameId: 'who-may-do-that',
    lessonId: 'definitions-practice-of-engineering',
    problemPrefix: 'eth-dpe-',
    rounds: [
      for (final r in standingRounds)
        RoundAudit(
          source: r.source,
          options: const ['anyone', 'an engineer intern', 'only a licensed PE'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'does-it-hold',
    lessonId: 'definitions-practice-of-engineering',
    problemPrefix: 'eth-dpe-',
    rounds: [
      for (final r in exemptionRounds)
        RoundAudit(
          source: r.source,
          options: const [
            'the exemption holds',
            'nobody licensed is in charge',
            'they are making the final call',
          ],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'practice-or-title',
    lessonId: 'definitions-practice-of-engineering',
    problemPrefix: 'eth-dpe-',
    rounds: [
      for (final r in verdictCases)
        RoundAudit(
          source: r.source,
          options: const ['practising unlicensed', 'the title', 'neither'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'what-is-missing-yet',
    lessonId: 'licensure-path-disciplinary-action',
    problemPrefix: 'eth-lpd-',
    rounds: [
      for (final r in recordRounds)
        RoundAudit(
          source: r.source,
          options: const [...requirements, 'nothing, it is complete'],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'grounds-or-not',
    lessonId: 'licensure-path-disciplinary-action',
    problemPrefix: 'eth-lpd-',
    rounds: [
      // A round is four yes-or-no answers at once, so no single index names
      // it.
      for (final r in groundsRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'which-section',
    lessonId: 'licensure-path-disciplinary-action',
    problemPrefix: 'eth-lpd-',
    rounds: [
      for (final r in sectionRounds)
        RoundAudit(
          source: r.source,
          options: const [
            'the licensee list',
            'the unlicensed list',
            'not a ground',
          ],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'is-there-a-deal',
    lessonId: 'engineering-contracts',
    problemPrefix: 'eth-con-',
    rounds: [
      // The answer is a LINE of an exchange, or none of them, so the choices
      // are positions rather than a fixed list.
      for (final r in dealRounds) RoundAudit(source: r.source),
    ],
  ),
  GameAudit(
    gameId: 'who-pays-the-overrun',
    lessonId: 'engineering-contracts',
    problemPrefix: 'eth-con-',
    rounds: [
      for (final r in overrunRounds)
        RoundAudit(
          source: r.source,
          options: const ['the owner', 'the contractor'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'which-delivery',
    lessonId: 'engineering-contracts',
    problemPrefix: 'eth-con-',
    rounds: [
      for (final r in deliveryRounds)
        RoundAudit(
          source: r.source,
          options: const ['design bid build', 'design build', 'cm at risk'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'is-that-negligence',
    lessonId: 'professional-liability',
    problemPrefix: 'eth-liab-',
    rounds: [
      for (final r in faultRounds)
        RoundAudit(
          source: r.source,
          options: const ['negligent', 'not negligent', 'deliberate'],
          answer: r.answer.index,
        ),
    ],
  ),
  GameAudit(
    gameId: 'which-element-missing',
    lessonId: 'professional-liability',
    problemPrefix: 'eth-liab-',
    rounds: [
      for (final r in elementRounds)
        RoundAudit(
          source: r.source,
          options: [for (final e in elements) e.$1],
          answer: r.answer,
        ),
    ],
  ),
  GameAudit(
    gameId: 'which-clock-ran-out',
    lessonId: 'professional-liability',
    problemPrefix: 'eth-liab-',
    rounds: [
      for (final r in clockRounds)
        RoundAudit(
          source: r.source,
          options: const ['in time', 'limitations', 'repose'],
          answer: r.answer.index,
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
