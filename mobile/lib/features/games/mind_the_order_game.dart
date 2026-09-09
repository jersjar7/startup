import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'expectation_figures.dart';
import 'lesson_brief.dart';

/// Mind the Order — the second item for `expected-value-weighted-averages`.
///
/// The lesson's medium problem is the variance shortcut, and both of its named
/// traps are handing in a half-finished intermediate: the mean, or the mean of
/// the squares. The scratch work is two columns and a subtraction, and the
/// subtraction is the only part that can go wrong in a way the calculator will
/// not catch, because E of X squared and E of X, squared, are two different
/// numbers written almost the same way.
///
/// So both columns are already totalled and the totals are on screen. The
/// question is which one goes in front of the minus sign and which goes
/// behind it, and getting that backwards produces a negative variance, which
/// is the one answer that cannot possibly be right.
class MindTheOrderGame extends StatefulWidget {
  const MindTheOrderGame({super.key});

  @override
  State<MindTheOrderGame> createState() => _MindTheOrderGameState();
}

/// One value the worked table hands you, named the way the table names it.
@immutable
class Total {
  const Total(this.latex, this.role);

  final String latex;

  /// What it is, in the formula's own terms. The two that matter are
  /// `eSquared` and `meanSquared`; the rest are real totals of the same table
  /// that answer nothing.
  final TotalRole role;
}

enum TotalRole { mean, eSquared, meanSquared, rawSquares, other }

@immutable
class OrderRound {
  const OrderRound({
    required this.subject,
    required this.outcomes,
    required this.totals,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The distribution the totals were computed from, so the table on screen
  /// and the numbers beside it can never disagree.
  final List<Outcome> outcomes;

  /// Five candidates, in the order they sit on the board.
  final List<Total> totals;
  final String why;
  final String source;

  double get mean =>
      outcomes.fold<double>(0, (a, o) => a + o.value * o.percent / 100);

  double get meanOfSquares => outcomes.fold<double>(
    0,
    (a, o) => a + o.value * o.value * o.percent / 100,
  );

  double get variance => meanOfSquares - mean * mean;

  int get first => totals.indexWhere((t) => t.role == TotalRole.eSquared);
  int get second => totals.indexWhere((t) => t.role == TotalRole.meanSquared);
}

const orderRounds = <OrderRound>[
  OrderRound(
    subject: 'trucks per minute at a toll plaza',
    outcomes: [Outcome(1, 10), Outcome(2, 30), Outcome(3, 40), Outcome(4, 20)],
    totals: [
      Total(r'\sum x^2 P(x)', TotalRole.eSquared),
      Total(r'\sum x P(x)', TotalRole.mean),
      Total(r'\left(\sum x P(x)\right)^2', TotalRole.meanSquared),
      Total(r'\sum x^2', TotalRole.rawSquares),
      Total(r'\sum x', TotalRole.other),
    ],
    why:
        'The mean of the squares comes first, and what is taken away is the '
        'square of the mean. Handing in 2.70 is handing in the mean, and '
        'handing in 8.10 is stopping halfway.',
    source: 'stat-ev-q2',
  ),
  OrderRound(
    subject: 'lanes closed on a night shift',
    outcomes: [Outcome(0, 50), Outcome(1, 30), Outcome(2, 20)],
    totals: [
      Total(r'\sum x P(x)', TotalRole.mean),
      Total(r'\left(\sum x P(x)\right)^2', TotalRole.meanSquared),
      Total(r'\sum x^2 P(x)', TotalRole.eSquared),
      Total(r'\sum x', TotalRole.other),
      Total(r'\sum x^2', TotalRole.rawSquares),
    ],
    why:
        'An outcome of zero contributes nothing to either column and still '
        'counts in the probabilities, which is what keeps the mean below one.',
    source: 'stat-ev-q2',
  ),
  OrderRound(
    subject: 'cylinders per set that come in under strength',
    outcomes: [Outcome(2, 25), Outcome(4, 50), Outcome(6, 25)],
    totals: [
      Total(r'\left(\sum x P(x)\right)^2', TotalRole.meanSquared),
      Total(r'\sum x^2 P(x)', TotalRole.eSquared),
      Total(r'\sum x P(x)', TotalRole.mean),
      Total(r'\sum x^2', TotalRole.rawSquares),
      Total(r'\sum x', TotalRole.other),
    ],
    why:
        'Eighteen and sixteen sit close enough together that swapping them '
        'looks harmless, and it is the difference between a variance of two '
        'and a variance of minus two.',
    source: 'stat-ev-q2',
  ),
  OrderRound(
    subject: 'delay in minutes at a work zone',
    outcomes: [Outcome(10, 20), Outcome(20, 50), Outcome(30, 30)],
    totals: [
      Total(r'\sum x^2 P(x)', TotalRole.eSquared),
      Total(r'\sum x^2', TotalRole.rawSquares),
      Total(r'\left(\sum x P(x)\right)^2', TotalRole.meanSquared),
      Total(r'\sum x', TotalRole.other),
      Total(r'\sum x P(x)', TotalRole.mean),
    ],
    why:
        'Bigger outcomes make every total bigger and change nothing about the '
        'order. Four hundred and ninety take four hundred and forty one is '
        'forty nine, and the size of the numbers is not the difficulty.',
    source: 'stat-ev-q2',
  ),
  OrderRound(
    subject: 'a two-way outcome on a repair decision',
    outcomes: [Outcome(1, 50), Outcome(5, 50)],
    totals: [
      Total(r'\sum x P(x)', TotalRole.mean),
      Total(r'\sum x^2 P(x)', TotalRole.eSquared),
      Total(r'\sum x^2', TotalRole.rawSquares),
      Total(r'\left(\sum x P(x)\right)^2', TotalRole.meanSquared),
      Total(r'\sum x', TotalRole.other),
    ],
    why:
        'Two outcomes, equally likely. The unweighted sum of squares is on the '
        'board and it is twenty six, which is not thirteen; the probabilities '
        'belong in both columns, not just the first.',
    source: 'stat-ev-q2',
  ),
  OrderRound(
    subject: 'crews available on a given morning',
    outcomes: [Outcome(1, 20), Outcome(2, 20), Outcome(3, 60)],
    totals: [
      Total(r'\sum x', TotalRole.other),
      Total(r'\left(\sum x P(x)\right)^2', TotalRole.meanSquared),
      Total(r'\sum x P(x)', TotalRole.mean),
      Total(r'\sum x^2 P(x)', TotalRole.eSquared),
      Total(r'\sum x^2', TotalRole.rawSquares),
    ],
    why:
        'A tight distribution has a small variance, and the two totals in the '
        'formula are nearly equal because of it. Nearly equal is exactly when '
        'the order stops being obvious.',
    source: 'stat-ev-q2',
  ),
];

class _MindTheOrderGameState extends State<MindTheOrderGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'mind-the-order',
    chapterId: 'statistics',
    total: orderRounds.length,
    sourceProblemIdOf: (round) => orderRounds[round].source,
  )..addListener(_onSession);

  /// The two slots, in the order the formula reads them.
  final _slots = <int>[];

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  OrderRound get _round => orderRounds[_session.round];

  void _tap(int i) {
    setState(() {
      if (_slots.contains(i)) {
        _slots.remove(i);
      } else if (_slots.length < 2) {
        _slots.add(i);
      }
    });
  }

  /// What a total is worth for this round, so the number beside a name is
  /// always the number that name describes.
  double _valueOf(OrderRound r, Total total) => switch (total.role) {
    TotalRole.mean => r.mean,
    TotalRole.eSquared => r.meanOfSquares,
    TotalRole.meanSquared => r.mean * r.mean,
    TotalRole.rawSquares => r.outcomes
        .fold<double>(0, (a, o) => a + (o.value * o.value).toDouble()),
    TotalRole.other =>
      r.outcomes.fold<double>(0, (a, o) => a + o.value.toDouble()),
  };

  static String _write(double v) =>
      v == v.roundToDouble() && v.abs() < 10000
      ? v.toStringAsFixed(v.abs() < 100 ? 2 : 0)
      : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Mind the Order',
        closing:
            'The mean of the squares, take away the square of the mean. In '
            'that order, every time. The other way round gives a negative '
            'variance, which is the cheapest error to spot and the easiest to '
            'make.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: varianceShortcutBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_slots.clear);
              _session.next();
            }
          : (_slots.length != 2
                ? null
                : () => _session.submit(
                    ok: _slots[0] == r.first && _slots[1] == r.second,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILL THE FORMULA, IN ORDER',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          _Table(outcomes: r.outcomes),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MathBlock(r'\text{Var}(X) =', fontSize: 15),
                const SizedBox(width: 8),
                _Slot(
                  value: _slots.isNotEmpty
                      ? _write(_valueOf(r, r.totals[_slots[0]]))
                      : null,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '−',
                    style: TextStyle(fontSize: 17, color: AppColors.charcoal),
                  ),
                ),
                _Slot(
                  value: _slots.length > 1
                      ? _write(_valueOf(r, r.totals[_slots[1]]))
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < r.totals.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _TotalRow(
              key: ValueKey('total-$i'),
              total: r.totals[i],
              value: _write(_valueOf(r, r.totals[i])),
              slot: _slots.indexOf(i),
              locked: answered,
              isTruth: i == r.first || i == r.second,
              onTap: answered ? null : () => _tap(i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'THE VARIANCE IS',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 6),
            MathBlock(
              '\\text{Var}(X) = ${_write(r.meanOfSquares)} - '
              '${_write(r.mean * r.mean)} = ${_write(r.variance)}',
              fontSize: 15,
            ),
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'IN THAT ORDER' : 'NOT LIKE THAT',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The distribution, exactly as the exam hands it over.
class _Table extends StatelessWidget {
  const _Table({required this.outcomes});

  final List<Outcome> outcomes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                child: Text('x', style: AppTheme.overline(color: AppColors.ink3)),
              ),
              for (final o in outcomes)
                Expanded(
                  child: Center(
                    widthFactor: 1,
                    child: Text('${o.value}', style: AppTheme.code(size: 13)),
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  'P(x)',
                  style: AppTheme.overline(color: AppColors.ink3),
                ),
              ),
              for (final o in outcomes)
                Expanded(
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      (o.percent / 100).toStringAsFixed(2),
                      style: AppTheme.code(size: 13),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value != null ? AppColors.white : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value != null ? AppColors.ember : AppColors.line,
          width: value != null ? 1.5 : 1,
        ),
      ),
      child: Text(value ?? '', style: AppTheme.code(size: 14)),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    super.key,
    required this.total,
    required this.value,
    required this.slot,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Total total;
  final String value;

  /// Which slot this one is in, or minus one when it is not in either.
  final int slot;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final selected = slot >= 0;
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: selected
                    ? Text(
                        '${slot + 1}',
                        style: AppTheme.mono(size: 12, color: AppColors.ember),
                      )
                    : null,
              ),
              Expanded(child: MathBlock(total.latex, fontSize: 14)),
              const SizedBox(width: 8),
              Text(value, style: AppTheme.code(size: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
