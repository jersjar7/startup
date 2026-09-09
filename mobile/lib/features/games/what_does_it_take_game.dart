import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'cash_flow_figures.dart';
import 'lesson_brief.dart';

/// What Does It Take — the third item for `equivalence-interest-factors`.
///
/// The lesson's hard problem is maintenance that grows by the same step every
/// year, and its named trap is doing the base series and stopping. A growing
/// series is TWO cash flows drawn on top of each other, a flat one and a
/// triangle, and each of them needs its own factor.
///
/// So the diagram is drawn and the question is how many pieces it takes.
/// Answers run from one factor to three and the count is never given, because
/// being told there are two is most of the question.
class WhatDoesItTakeGame extends StatefulWidget {
  const WhatDoesItTakeGame({super.key});

  @override
  State<WhatDoesItTakeGame> createState() => _WhatDoesItTakeGameState();
}

/// The three that bring anything back to today.
const pieces = <(String, String)>[
  (r'(P/F, i, n)', 'a single amount, somewhere out there'),
  (r'(P/A, i, n)', 'the flat part of a series'),
  (r'(P/G, i, n)', 'the part that grows by the same step'),
];

@immutable
class TakeRound {
  const TakeRound({
    required this.subject,
    required this.scenario,
    required this.flows,
    required this.periods,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scenario;
  final List<CashFlow> flows;
  final int periods;

  /// Indices into [pieces].
  final List<int> answer;
  final String why;
  final String source;
}

const takeRounds = <TakeRound>[
  TakeRound(
    subject: 'maintenance that climbs every year',
    scenario:
        'Maintenance is 10,000 dollars in year one and rises by 2,000 dollars '
        'every year after, for ten years. What is the present worth of the '
        'whole programme?',
    flows: [
      CashFlow(1, -1), CashFlow(2, -1.22), CashFlow(3, -1.44), CashFlow(4, -1.67),
      CashFlow(5, -1.89), CashFlow(6, -2.11), CashFlow(7, -2.33), CashFlow(8, -2.56),
      CashFlow(9, -2.78), CashFlow(10, -3),
    ],
    periods: 10,
    answer: [1, 2],
    why:
        'A flat ten thousand every year, and a triangle of two thousand steps '
        'sitting on top of it. Two pieces, two factors, and doing the flat '
        'part and stopping is the mistake the lesson names.',
    source: 'econ-eif-q3',
  ),
  TakeRound(
    subject: 'the same cost, every year',
    scenario:
        'A pump station costs the same amount to run at the end of each of the '
        'next twelve years. What is that worth today?',
    flows: [
      CashFlow(1, -2), CashFlow(2, -2), CashFlow(3, -2), CashFlow(4, -2), CashFlow(5, -2),
      CashFlow(6, -2), CashFlow(7, -2), CashFlow(8, -2), CashFlow(9, -2), CashFlow(10, -2),
      CashFlow(11, -2), CashFlow(12, -2),
    ],
    periods: 12,
    answer: [1],
    why:
        'Flat is flat. There is no triangle here and nothing lands on its own '
        'at a single date, so one factor covers the whole diagram.',
    source: 'econ-eif-q3',
  ),
  TakeRound(
    subject: 'a rebuild in the middle, and nothing else',
    scenario:
        'A culvert needs one rebuild, at the end of year seven. There are no '
        'other costs at all.',
    flows: [CashFlow(7, -3)],
    periods: 12,
    answer: [0],
    why:
        'One arrow, one move. It is worth meeting on its own, because the same '
        'single amount turns up inside almost every other diagram as one piece '
        'of a larger sum.',
    source: 'econ-eif-q1',
  ),
  TakeRound(
    subject: 'running costs, and one big year',
    scenario:
        'A plant costs the same to operate every year for eight years, and in '
        'year five there is an overhaul on top of that year\'s operating cost.',
    flows: [
      CashFlow(1, -1.4), CashFlow(2, -1.4), CashFlow(3, -1.4), CashFlow(4, -1.4),
      CashFlow(5, -3), CashFlow(6, -1.4), CashFlow(7, -1.4), CashFlow(8, -1.4),
    ],
    periods: 8,
    answer: [0, 1],
    why:
        'The flat series covers all eight years and the overhaul is a single '
        'amount on top of year five. Two pieces added together, and neither of '
        'them is a gradient: nothing here grows by a constant step.',
    source: 'econ-eif-q3',
  ),
  TakeRound(
    subject: 'costs that start at nothing',
    scenario:
        'A new pavement needs no maintenance in year one. From year two it '
        'costs 3,000 dollars, and it rises by another 3,000 every year after '
        'that, for nine years.',
    flows: [
      CashFlow(2, -0.6), CashFlow(3, -1.2), CashFlow(4, -1.8), CashFlow(5, -2.4),
      CashFlow(6, -3), CashFlow(7, -3.6), CashFlow(8, -4.2), CashFlow(9, -4.8),
    ],
    periods: 9,
    answer: [2],
    why:
        'Nothing in year one and even steps after it, which is a gradient with '
        'no flat part underneath. This is the shape the gradient factor is '
        'actually defined on, and the usual case is that shape plus a flat '
        'series.',
    source: 'econ-eif-q3',
  ),
  TakeRound(
    subject: 'the whole life of an asset',
    scenario:
        'Operating costs start at 20,000 dollars and grow by 1,500 dollars a '
        'year for fifteen years. At the end the asset is sold for salvage.',
    flows: [
      CashFlow(1, -1), CashFlow(2, -1.14), CashFlow(3, -1.29), CashFlow(4, -1.43),
      CashFlow(5, -1.57), CashFlow(6, -1.71), CashFlow(7, -1.86), CashFlow(8, -2),
      CashFlow(9, -2.14), CashFlow(10, -2.29), CashFlow(11, -2.43), CashFlow(12, -2.57),
      CashFlow(13, -2.71), CashFlow(14, -2.86), CashFlow(15, -3),
      CashFlow(15, 2.4),
    ],
    periods: 15,
    answer: [0, 1, 2],
    why:
        'All three at once, which is what a real life-cycle looks like. The '
        'flat part, the triangle on top of it, and the salvage pointing the '
        'other way as a single amount at the end.',
    source: 'econ-eif-q3',
  ),
];

class _WhatDoesItTakeGameState extends State<WhatDoesItTakeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-does-it-take',
    chapterId: 'economics',
    total: takeRounds.length,
    sourceProblemIdOf: (round) => takeRounds[round].source,
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

  TakeRound get _round => takeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Does It Take',
        closing:
            'A growing series is two cash flows drawn on top of each other, a '
            'flat one and a triangle, and each needs its own factor. Anything '
            'landing on a single date needs a third. Count the pieces in the '
            'picture before reaching for anything.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final truth = r.answer.toSet();

    return BoardShell(
      session: _session,
      brief: piecesBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_picked.clear);
              _session.next();
            }
          : (_picked.isEmpty
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
            'TAP EVERY PIECE THIS TAKES',
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
              height: 150,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: CashFlowPainter(
                    flows: r.flows,
                    periods: r.periods,
                    unit: 'years',
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < pieces.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _PieceRow(
              key: ValueKey('piece-$i'),
              latex: pieces[i].$1,
              note: pieces[i].$2,
              selected: _picked.contains(i),
              locked: answered,
              isTruth: truth.contains(i),
              onTap: answered
                  ? null
                  : () => setState(
                      () => _picked.contains(i)
                          ? _picked.remove(i)
                          : _picked.add(i),
                    ),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'ALL THE PIECES' : 'NOT THOSE PIECES',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _PieceRow extends StatelessWidget {
  const _PieceRow({
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
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: selected || (locked && isTruth) ? border : null,
                  border: Border.all(
                    color: selected || (locked && isTruth)
                        ? border
                        : AppColors.line,
                  ),
                ),
                child: selected || (locked && isTruth)
                    ? const Icon(Icons.check_rounded,
                        size: 15, color: AppColors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              SizedBox(width: 92, child: MathBlock(latex, fontSize: 13)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  note,
                  style: AppTheme.mono(size: 10, color: AppColors.ink3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
