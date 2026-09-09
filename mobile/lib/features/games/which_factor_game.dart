import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'cash_flow_figures.dart';
import 'lesson_brief.dart';

/// Which Factor — the first item for `equivalence-interest-factors`.
///
/// The lesson's easy problem is a sinking fund and its named trap is reaching
/// for capital recovery instead. The two are the same shape written backwards
/// and they live one line apart in the handbook, which is exactly why they get
/// swapped. Nothing about the arithmetic causes it.
///
/// So nothing is computed here. The diagram is drawn with what you have as
/// solid arrows and what you want hollow, and the answer is the factor that
/// turns the one into the other. Six factors, each of them the answer once.
class WhichFactorGame extends StatefulWidget {
  const WhichFactorGame({super.key});

  @override
  State<WhichFactorGame> createState() => _WhichFactorGameState();
}

/// The six, laid out as the handbook lays them out.
const factors = <(String, String)>[
  (r'(F/P, i, n)', 'a single amount, carried forward'),
  (r'(P/F, i, n)', 'a single amount, brought back'),
  (r'(A/F, i, n)', 'a future amount, into equal deposits'),
  (r'(A/P, i, n)', 'an amount today, into equal payments'),
  (r'(F/A, i, n)', 'equal deposits, into what they become'),
  (r'(P/A, i, n)', 'equal payments, into what they are worth now'),
];

@immutable
class FactorRound {
  const FactorRound({
    required this.subject,
    required this.scenario,
    required this.flows,
    required this.periods,
    required this.unit,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scenario;

  /// Solid arrows are what the problem gives you; the hollow one is what it
  /// asks for.
  final List<CashFlow> flows;
  final int periods;
  final String unit;

  /// Index into [factors].
  final int answer;
  final String why;
  final String source;
}

const factorRounds = <FactorRound>[
  FactorRound(
    subject: 'a water main due for replacement',
    scenario:
        'A city needs 500,000 dollars in ten years to replace a water main. '
        'What equal deposit at the end of each year gets them there?',
    flows: [
      CashFlow(10, 3),
      CashFlow(1, -1, unknown: true),
      CashFlow(2, -1, unknown: true),
      CashFlow(3, -1, unknown: true),
      CashFlow(4, -1, unknown: true),
      CashFlow(5, -1, unknown: true),
      CashFlow(6, -1, unknown: true),
      CashFlow(7, -1, unknown: true),
      CashFlow(8, -1, unknown: true),
      CashFlow(9, -1, unknown: true),
      CashFlow(10, -1, unknown: true),
    ],
    periods: 10,
    unit: 'years',
    answer: 2,
    why:
        'A known amount out at the end and a series of equal deposits to build '
        'it, which is a sinking fund. Capital recovery is the same shape read '
        'the other way and it is the answer people give: that one starts from '
        'money you already have.',
    source: 'econ-eif-q1',
  ),
  FactorRound(
    subject: 'equipment bought on credit',
    scenario:
        'An engineer borrows 25,000 dollars today for equipment. What equal '
        'payment clears it over the term?',
    flows: [
      CashFlow(0, 3),
      CashFlow(1, -1, unknown: true),
      CashFlow(2, -1, unknown: true),
      CashFlow(3, -1, unknown: true),
      CashFlow(4, -1, unknown: true),
      CashFlow(5, -1, unknown: true),
      CashFlow(6, -1, unknown: true),
    ],
    periods: 6,
    unit: 'periods',
    answer: 3,
    why:
        'Money in hand today turned into a series of equal payments is capital '
        'recovery, and it is the factor behind every loan payment anybody has '
        'ever made.',
    source: 'econ-eif-q2',
  ),
  FactorRound(
    subject: 'a reserve that has been building',
    scenario:
        'A district has put the same amount into a reserve at the end of every '
        'year for eight years. What is in the account at the end?',
    flows: [
      CashFlow(1, -1),
      CashFlow(2, -1),
      CashFlow(3, -1),
      CashFlow(4, -1),
      CashFlow(5, -1),
      CashFlow(6, -1),
      CashFlow(7, -1),
      CashFlow(8, -1),
      CashFlow(8, 3, unknown: true),
    ],
    periods: 8,
    unit: 'years',
    answer: 4,
    why:
        'Equal deposits going in and one amount coming out at the end. This is '
        'the sinking fund read forwards, and the two are reciprocals of each '
        'other.',
    source: 'econ-eif-q1',
  ),
  FactorRound(
    subject: 'a salvage value years out',
    scenario:
        'A machine will be sold for 80,000 dollars at the end of year twelve. '
        'What is that worth in today\'s money?',
    flows: [
      CashFlow(12, 3),
      CashFlow(0, 2.2, unknown: true),
    ],
    periods: 12,
    unit: 'years',
    answer: 1,
    why:
        'One amount, one move, backwards. Discounting a single future sum is '
        'the plainest thing in the whole set, and it is the piece every other '
        'factor is built out of.',
    source: 'econ-eif-q3',
  ),
  FactorRound(
    subject: 'maintenance for the next decade',
    scenario:
        'A bridge costs the same amount to maintain at the end of each of the '
        'next ten years. What is the whole programme worth today?',
    flows: [
      CashFlow(1, -1),
      CashFlow(2, -1),
      CashFlow(3, -1),
      CashFlow(4, -1),
      CashFlow(5, -1),
      CashFlow(6, -1),
      CashFlow(7, -1),
      CashFlow(8, -1),
      CashFlow(9, -1),
      CashFlow(10, -1),
      CashFlow(0, -2.6, unknown: true),
    ],
    periods: 10,
    unit: 'years',
    answer: 5,
    why:
        'An equal series brought back to today. Adding the ten payments up '
        'gives a number that is too big, and by a lot: money spent in year ten '
        'costs less than money spent this afternoon.',
    source: 'econ-eif-q3',
  ),
  FactorRound(
    subject: 'a fund left alone',
    scenario:
        'A trust holds 200,000 dollars today and nothing is added or taken '
        'out. What will it hold in fifteen years?',
    flows: [
      CashFlow(0, 2.2),
      CashFlow(15, 3, unknown: true),
    ],
    periods: 15,
    unit: 'years',
    answer: 0,
    why:
        'One amount carried forward, which is compounding and nothing else. '
        'Every other factor in the set is this one applied repeatedly and then '
        'tidied up.',
    source: 'econ-eif-q1',
  ),
];

class _WhichFactorGameState extends State<WhichFactorGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-factor',
    chapterId: 'economics',
    total: factorRounds.length,
    sourceProblemIdOf: (round) => factorRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FactorRound get _round => factorRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Factor',
        closing:
            'Read the picture, not the words. What have you got, a single '
            'amount or an equal series, and which do you want instead. The two '
            'that get swapped are the sinking fund and capital recovery, and '
            'the difference is whether the known amount is at the end or in '
            'your hand.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: factorsBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOLID IS WHAT YOU HAVE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.scenario,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: CashFlowPainter(
                    flows: r.flows,
                    periods: r.periods,
                    unit: r.unit,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < factors.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            _FactorRow(
              key: ValueKey('factor-$i'),
              latex: factors[i].$1,
              note: factors[i].$2,
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({
    super.key,
    required this.latex,
    required this.note,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String latex;
  final String note;
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 96, child: MathBlock(latex, fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  note,
                  style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
