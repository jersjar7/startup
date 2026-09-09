import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Same Pick, or Not — the first item for `probability-distributions`.
///
/// The lesson's easy problem has one decision in it and the rest is a
/// calculator button: does order matter. Every student can recite that a
/// permutation cares about order and a combination does not, and plenty of
/// them still hand in 336 when the answer is 56, because the recital is not
/// the skill. The skill is looking at a scenario and seeing whether two
/// outcomes that contain the same names are one result or two.
///
/// So the two outcomes are shown, side by side, and the question is whether
/// the scenario counts them once or twice. The first two rounds show the SAME
/// two lists and have different answers, which is the whole lesson in one
/// pair: nothing about the names decides it, only what is being done with
/// them.
class SamePickGame extends StatefulWidget {
  const SamePickGame({super.key});

  @override
  State<SamePickGame> createState() => _SamePickGameState();
}

@immutable
class PickRound {
  const PickRound({
    required this.scenario,
    required this.first,
    required this.second,
    required this.slots,
    required this.ordered,
    required this.count,
    required this.why,
    required this.source,
  });

  /// What is being done with the picks.
  final String scenario;

  /// Two outcomes, each already drawn from the same pool.
  final List<String> first;
  final List<String> second;

  /// What each position means, when it means anything. Empty for a plain
  /// group, where a position is only a place on the page.
  final List<String> slots;

  /// True when the scenario counts the two lists as two different results,
  /// which is what a permutation is.
  final bool ordered;

  /// How the count is written once the decision is made.
  final String count;
  final String why;
  final String source;
}

const pickRounds = <PickRound>[
  PickRound(
    scenario:
        'Three of eight qualified engineers are chosen to form ONE inspection '
        'team for a bridge deck pour.',
    first: ['Alvarez', 'Brooks', 'Chen'],
    second: ['Chen', 'Alvarez', 'Brooks'],
    slots: [],
    ordered: false,
    count: r'C(8,3) = 56',
    why:
        'A team is a team. Writing the same three names in another order does '
        'not make a second team, so the two lists are one result and this is a '
        'combination.',
    source: 'stat-dist-q1',
  ),
  PickRound(
    scenario:
        'Three of the same eight engineers are assigned, one each, to the '
        'deck, the girders and the abutments.',
    first: ['Alvarez', 'Brooks', 'Chen'],
    second: ['Chen', 'Alvarez', 'Brooks'],
    slots: ['deck', 'girders', 'abutments'],
    ordered: true,
    count: r'P(8,3) = 336',
    why:
        'The same three names, and now the position is a job. Alvarez on the '
        'deck is a different assignment from Alvarez on the abutments, so '
        'these are two results and the count is six times bigger.',
    source: 'stat-dist-q1',
  ),
  PickRound(
    scenario:
        'Four of twelve boreholes are selected for laboratory testing.',
    first: ['B-02', 'B-05', 'B-09', 'B-11'],
    second: ['B-11', 'B-02', 'B-09', 'B-05'],
    slots: [],
    ordered: false,
    count: r'C(12,4) = 495',
    why:
        'The lab receives four samples. Which one was written down first is a '
        'fact about the paperwork, not about the selection.',
    source: 'stat-dist-q1',
  ),
  PickRound(
    scenario:
        'The three lowest bids are ranked first, second and third for award.',
    first: ['Northgate', 'Vela', 'Ridgeline'],
    second: ['Vela', 'Northgate', 'Ridgeline'],
    slots: ['first', 'second', 'third'],
    ordered: true,
    count: r'P(9,3) = 504',
    why:
        'Ranking is order made explicit. The same three firms in another order '
        'is a different award, and a contractor who came second would tell you '
        'so.',
    source: 'stat-dist-q1',
  ),
  PickRound(
    scenario:
        'Two of six trial mixes are chosen to be batched and tested together.',
    first: ['Mix C', 'Mix E'],
    second: ['Mix E', 'Mix C'],
    slots: [],
    ordered: false,
    count: r'C(6,2) = 15',
    why:
        'Both mixes get batched. There is no first and no second, only the '
        'pair, so the two lists are the same pair written twice.',
    source: 'stat-dist-q1',
  ),
  PickRound(
    scenario:
        'The four lifts of a pour are sequenced, and the schedule says which '
        'goes down first.',
    first: ['North', 'East', 'South', 'West'],
    second: ['East', 'North', 'South', 'West'],
    slots: ['1st', '2nd', '3rd', '4th'],
    ordered: true,
    count: r'4! = 24',
    why:
        'A sequence is nothing but an order. Swapping the first two lifts is a '
        'different schedule, and here every lift is used, which is why this one '
        'is a plain factorial.',
    source: 'stat-dist-q1',
  ),
];

class _SamePickGameState extends State<SamePickGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'same-pick',
    chapterId: 'statistics',
    total: pickRounds.length,
    sourceProblemIdOf: (round) => pickRounds[round].source,
  )..addListener(_onSession);

  bool? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PickRound get _round => pickRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Same Pick, or Not',
        closing:
            'Nothing about the names decides it. Ask whether the scenario '
            'counts the same picks in another order as a second result: if it '
            'does, order matters and it is nPr, and if it does not, it is nCr.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: countingBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == r.ordered,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ONE RESULT, OR TWO',
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
          const SizedBox(height: 14),
          _Outcome(
            label: 'ONE OUTCOME',
            names: r.first,
            slots: answered ? r.slots : const [],
          ),
          const SizedBox(height: 8),
          _Outcome(
            label: 'ANOTHER OUTCOME',
            names: r.second,
            slots: answered ? r.slots : const [],
          ),
          const SizedBox(height: 16),
          _Choice(
            key: const ValueKey('pick-same'),
            label: 'The same result, counted once',
            selected: _picked == false,
            locked: answered,
            isTruth: !r.ordered,
            onTap: answered ? null : () => setState(() => _picked = false),
          ),
          const SizedBox(height: 8),
          _Choice(
            key: const ValueKey('pick-different'),
            label: 'Two different results',
            selected: _picked == true,
            locked: answered,
            isTruth: r.ordered,
            onTap: answered ? null : () => setState(() => _picked = true),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              r.ordered ? 'ORDER MATTERS' : 'ORDER DOES NOT MATTER',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 6),
            MathBlock(r.count, fontSize: 17),
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({
    required this.label,
    required this.names,
    required this.slots,
  });

  final String label;
  final List<String> names;

  /// What each position means, written above the name AFTER the answer.
  /// Before it the rows are bare on purpose: a row of labelled slots would
  /// answer the question without the scenario being read at all, which is the
  /// one thing this item is trying to make somebody do.
  final List<String> slots;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.overline(color: AppColors.ink3)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < names.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    children: [
                      if (slots.isNotEmpty)
                        Text(
                          slots[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.mono(size: 9, color: AppColors.ember),
                        ),
                      const SizedBox(height: 2),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.creamDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            names[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.code(size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
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
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
