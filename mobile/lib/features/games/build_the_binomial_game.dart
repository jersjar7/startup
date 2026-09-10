import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Build the Binomial — the second item for `probability-distributions`.
///
/// The lesson's medium problem is one formula with three factors in it, and
/// both of its named traps are a missing or mislabeled factor: dropping the
/// C(n,x) term, or counting the wrong outcome as the success. Multiplying the
/// three together is a calculator's job. Choosing WHICH three is the whole
/// exam question, and it can be done with a thumb.
///
/// So the skeleton is on screen with three empty factors and a tray of six
/// candidates, three right and three wrong. Every wrong one is a real formula
/// that answers a slightly different question: the arrangement instead of the
/// selection, the wrong exponent, the wrong probability raised correctly.
class BuildTheBinomialGame extends StatefulWidget {
  const BuildTheBinomialGame({super.key});

  @override
  State<BuildTheBinomialGame> createState() => _BuildTheBinomialGameState();
}

enum FactorKind { choose, arrange, power }

/// One candidate factor, described rather than written out, so that the maths
/// on screen can never drift from the maths the tests check.
@immutable
class Factor {
  const Factor(this.kind, this.a, this.b);

  final FactorKind kind;

  /// The pool size for a count, or the probability in percent for a power.
  final int a;

  /// How many are chosen, or the exponent.
  final int b;

  String get latex => switch (kind) {
    FactorKind.choose => 'C($a, $b)',
    FactorKind.arrange => 'P($a, $b)',
    FactorKind.power => '(${(a / 100).toStringAsFixed(2)})^{$b}',
  };
}

@immutable
class BinomialRound {
  const BinomialRound({
    required this.scenario,
    required this.ask,
    required this.n,
    required this.x,
    required this.percent,
    required this.factors,
    required this.why,
    required this.source,
  });

  final String scenario;
  final String ask;

  /// The trials, the successes asked for, and the chance of one success as a
  /// whole percent. Everything correct on this board follows from these three.
  final int n;
  final int x;
  final int percent;

  /// Six candidates, in the order they sit in the tray.
  final List<Factor> factors;
  final String why;
  final String source;

  /// The three that belong in the formula, worked out rather than written
  /// down: the count of arrangements, the successes, and the failures.
  Set<int> get answer {
    return {
      for (final (i, f) in factors.indexed)
        if ((f.kind == FactorKind.choose && f.a == n && f.b == x) ||
            (f.kind == FactorKind.power && f.a == percent && f.b == x) ||
            (f.kind == FactorKind.power &&
                f.a == 100 - percent &&
                f.b == n - x))
          i,
    };
  }
}

const binomialRounds = <BinomialRound>[
  BinomialRound(
    scenario:
        'Ten asphalt samples are tested. Historically 90% of samples from this '
        'plant pass the Marshall stability test.',
    ask: 'exactly 8 of the 10 pass',
    n: 10,
    x: 8,
    percent: 90,
    factors: [
      Factor(FactorKind.choose, 10, 8),
      Factor(FactorKind.arrange, 10, 8),
      Factor(FactorKind.power, 90, 8),
      Factor(FactorKind.power, 90, 10),
      Factor(FactorKind.power, 10, 2),
      Factor(FactorKind.power, 10, 8),
    ],
    why:
        'Forty five arrangements, eight passes, two failures. Dropping the '
        'count is the error the lesson names first, and it leaves an answer far '
        'too small. The arrangement P of ten and eight would count the order '
        'the eight passed in, which nobody asked about.',
    source: 'stat-dist-q2',
  ),
  BinomialRound(
    scenario: 'The same ten samples, from the same plant.',
    ask: 'exactly 2 of the 10 fail',
    n: 10,
    x: 2,
    percent: 10,
    factors: [
      Factor(FactorKind.power, 90, 8),
      Factor(FactorKind.power, 90, 2),
      Factor(FactorKind.choose, 10, 2),
      Factor(FactorKind.arrange, 10, 2),
      Factor(FactorKind.power, 10, 2),
      Factor(FactorKind.power, 10, 8),
    ],
    why:
        'Calling failure the success flips p and q and flips x, and it lands on '
        'the identical product as the round before. Eight passing and two '
        'failing are the same event described from either end.',
    source: 'stat-dist-q2',
  ),
  BinomialRound(
    scenario:
        'Twenty concrete cylinders are broken. Five percent of cylinders from '
        'this mix come in under the specified strength.',
    ask: 'exactly 2 of the 20 come in under',
    n: 20,
    x: 2,
    percent: 5,
    factors: [
      Factor(FactorKind.choose, 20, 2),
      Factor(FactorKind.power, 5, 2),
      Factor(FactorKind.power, 5, 18),
      Factor(FactorKind.arrange, 20, 2),
      Factor(FactorKind.power, 95, 18),
      Factor(FactorKind.power, 95, 2),
    ],
    why:
        'A hundred and ninety ways to pick which two were weak, two under, and '
        'eighteen that held. The exponents always add up to the number of '
        'trials, which is the cheapest check there is on this formula.',
    source: 'stat-dist-q2',
  ),
  BinomialRound(
    scenario:
        'Twelve field welds are radiographed. Eighty five percent of welds by '
        'this crew pass on the first look.',
    ask: 'exactly 10 of the 12 pass',
    n: 12,
    x: 10,
    percent: 85,
    factors: [
      Factor(FactorKind.power, 15, 10),
      Factor(FactorKind.choose, 12, 10),
      Factor(FactorKind.power, 85, 10),
      Factor(FactorKind.power, 85, 12),
      Factor(FactorKind.arrange, 12, 10),
      Factor(FactorKind.power, 15, 2),
    ],
    why:
        'Ten passes and two rejects out of twelve. The tempting wrong pair is '
        'the fifteen percent raised to ten, which would be ten welds failing in '
        'a question about ten welds passing.',
    source: 'stat-dist-q2',
  ),
  BinomialRound(
    scenario:
        'Eight samples are tested at the plant that passes 90% of what it '
        'sends.',
    ask: 'all 8 of the 8 pass',
    n: 8,
    x: 8,
    percent: 90,
    factors: [
      Factor(FactorKind.power, 10, 0),
      Factor(FactorKind.choose, 8, 8),
      Factor(FactorKind.power, 90, 8),
      Factor(FactorKind.choose, 8, 1),
      Factor(FactorKind.power, 90, 1),
      Factor(FactorKind.power, 10, 8),
    ],
    why:
        'All three terms are still there; two of them are just one. There is '
        'exactly one way for everything to pass, and no failures to account '
        'for, which is why this case collapses to p to the n.',
    source: 'stat-dist-q2',
  ),
  BinomialRound(
    scenario:
        'Fifteen truck loads are weighed at a static scale. Twenty percent of '
        'loads on this route are over the legal limit.',
    ask: 'exactly 3 of the 15 are over',
    n: 15,
    x: 3,
    percent: 20,
    factors: [
      Factor(FactorKind.power, 80, 3),
      Factor(FactorKind.power, 20, 3),
      Factor(FactorKind.arrange, 15, 3),
      Factor(FactorKind.power, 80, 12),
      Factor(FactorKind.choose, 15, 3),
      Factor(FactorKind.power, 20, 12),
    ],
    why:
        'Three over and twelve legal. Both probabilities are on the tray with '
        'both exponents, and only one pairing has the small probability on the '
        'small count.',
    source: 'stat-dist-q2',
  ),
];

class _BuildTheBinomialGameState extends State<BuildTheBinomialGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'build-the-binomial',
    chapterId: 'statistics',
    total: binomialRounds.length,
    sourceProblemIdOf: (round) => binomialRounds[round].source,
  )..addListener(_onSession);

  final _picked = <int>{};

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  BinomialRound get _round => binomialRounds[_session.round];

  void _toggle(int i) {
    setState(() {
      if (_picked.contains(i)) {
        _picked.remove(i);
      } else if (_picked.length < 3) {
        _picked.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Build the Binomial',
        closing:
            'Three factors, every time: the number of arrangements, the '
            'successes, and the failures. The exponents add up to the number '
            'of trials, and the count in front is a combination, never an '
            'arrangement.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final truth = r.answer;

    return BoardShell(
      session: _session,
      brief: binomialBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_picked.clear);
              _session.next();
            }
          : (_picked.length != 3
                ? null
                : () => _session.submit(
                    ok: _picked.length == truth.length &&
                        _picked.containsAll(truth),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PICK THE THREE FACTORS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.scenario,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'THE CHANCE THAT ${r.ask.toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: AppTheme.overline(color: AppColors.ink3),
                ),
                const SizedBox(height: 8),
                _Skeleton(
                  picked: [
                    for (final i in _picked) r.factors[i].latex,
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var row = 0; row < 3; row++) ...[
            if (row > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _FactorChip(
                      key: ValueKey('factor-${row * 2 + col}'),
                      latex: r.factors[row * 2 + col].latex,
                      selected: _picked.contains(row * 2 + col),
                      locked: answered,
                      isTruth: truth.contains(row * 2 + col),
                      onTap: answered ? null : () => _toggle(row * 2 + col),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? 'ALL THREE FACTORS'
                  : 'NOT THOSE THREE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The formula with its three slots, filling in as they are chosen.
class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.picked});

  final List<String> picked;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '×',
                style: TextStyle(fontSize: 13, color: AppColors.ink3),
              ),
            ),
          Flexible(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: i < picked.length ? AppColors.white : null,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: i < picked.length ? AppColors.ember : AppColors.line,
                  width: i < picked.length ? 1.5 : 1,
                ),
              ),
              child: Center(
                widthFactor: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: i < picked.length
                      ? MathBlock(picked[i], fontSize: 13)
                      : const SizedBox(width: 44),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FactorChip extends StatelessWidget {
  const _FactorChip({
    super.key,
    required this.latex,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String latex;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Center(widthFactor: 1, child: MathBlock(latex, fontSize: 15)),
        ),
      ),
    );
  }
}
