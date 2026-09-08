import 'acute_or_obtuse_game.dart';
import 'build_the_identity_game.dart';
import 'discriminant_gate_game.dart';
import 'grade_sense_game.dart';
import 'one_log_game.dart';
import 'order_the_moves_game.dart';
import 'perpendicular_flip_game.dart';
import 'quadrant_signs_game.dart';
import 'resolve_it_game.dart';
import 'rule_or_trap_game.dart';
import 'set_it_up_game.dart';
import 'tap_the_side_game.dart';
import 'walk_the_circle_game.dart';
import 'which_law_game.dart';
import 'which_ratio_game.dart';

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
  });

  /// The web problem this round was authored from.
  final String source;

  /// The choices offered, where an item offers choices. Empty is fine: an item
  /// answered by pointing, ordering or toggling has none.
  final List<String> options;

  /// Index into [options] of the one right answer, where that applies.
  final int? answer;
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
