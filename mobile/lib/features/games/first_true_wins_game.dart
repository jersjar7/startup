import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// First True Wins — the second item for `structured-programming`.
///
/// A chain of conditions is checked from the top and stops at the first one
/// that holds; everything under it is skipped whether or not it would also
/// have been true. Students who read the whole chain before deciding end up in
/// the final ELSE, which is the trap the lesson names. So the chain is on
/// screen as code and the student taps the branch that actually runs. Half the
/// rounds sit exactly on a boundary, because that is where a strict greater
/// than and a greater-or-equal stop being the same thing.
class FirstTrueWinsGame extends StatefulWidget {
  const FirstTrueWinsGame({super.key});

  @override
  State<FirstTrueWinsGame> createState() => _FirstTrueWinsGameState();
}

@immutable
class Branch {
  const Branch({required this.test, required this.body});

  /// The condition as written, or null for the closing ELSE.
  final String? test;
  final String body;
}

@immutable
class ChainRound {
  const ChainRound({
    required this.given,
    required this.branches,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// The line setting up the variable, shown above the chain.
  final String given;
  final List<Branch> branches;

  /// Which branch runs.
  final int answer;
  final String why;
  final String source;
}

const chainRounds = <ChainRound>[
  ChainRound(
    given: 'x = 7',
    branches: [
      Branch(test: 'x > 10', body: 'y = 1'),
      Branch(test: 'x > 5', body: 'y = 2'),
      Branch(test: null, body: 'y = 3'),
    ],
    answer: 1,
    why:
        'Seven is not over ten, so the first test fails, but seven is over '
        'five, so the second one holds and the chain stops there. The closing '
        'ELSE never gets looked at.',
    source: 'math-prg-q2',
  ),
  ChainRound(
    given: 'x = 10',
    branches: [
      Branch(test: 'x > 10', body: 'y = 1'),
      Branch(test: 'x > 5', body: 'y = 2'),
      Branch(test: null, body: 'y = 3'),
    ],
    answer: 1,
    why:
        'Ten is not greater than ten. A strict greater than excludes the '
        'number itself, so the first test fails on the boundary and the '
        'second one picks it up.',
    source: 'math-prg-q2',
  ),
  ChainRound(
    given: 'x = 3',
    branches: [
      Branch(test: 'x > 10', body: 'y = 1'),
      Branch(test: 'x > 5', body: 'y = 2'),
      Branch(test: null, body: 'y = 3'),
    ],
    answer: 2,
    why:
        'Both tests fail this time, so the closing ELSE is what runs. It is '
        'the right answer here and the wrong one everywhere else in this set, '
        'which is exactly why it gets picked too often.',
    source: 'math-prg-q2',
  ),
  ChainRound(
    given: 'n = 40',
    branches: [
      Branch(test: 'n >= 90', body: 'grade = "A"'),
      Branch(test: 'n >= 40', body: 'grade = "B"'),
      Branch(test: 'n >= 20', body: 'grade = "C"'),
      Branch(test: null, body: 'grade = "D"'),
    ],
    answer: 1,
    why:
        'Forty is at least forty, so the second test holds. The third one '
        'would ALSO have held, and it never runs, because the chain stops at '
        'the first thing that is true rather than the best fit.',
    source: 'math-prg-q2',
  ),
  ChainRound(
    given: 'v = 5',
    branches: [
      Branch(test: 'v < 0', body: 'flag = "under"'),
      Branch(test: 'v > 5', body: 'flag = "over"'),
      Branch(test: null, body: 'flag = "in range"'),
    ],
    answer: 2,
    why:
        'Five is not under zero and not over five, so both tests fail and the '
        'closing ELSE runs. Sitting exactly on a strict boundary means '
        'neither side claims you.',
    source: 'math-prg-q2',
  ),
  ChainRound(
    given: 'd = 12',
    branches: [
      Branch(test: 'd >= 20', body: 'size = 3'),
      Branch(test: 'd >= 12', body: 'size = 2'),
      Branch(test: 'd >= 8', body: 'size = 1'),
      Branch(test: null, body: 'size = 0'),
    ],
    answer: 1,
    why:
        'Twelve is not at least twenty, and it is exactly twelve, so the '
        'second test holds on its boundary. A chain like this is how a '
        'schedule of sizes gets written, and getting the boundary wrong '
        'specifies the wrong bar.',
    source: 'math-prg-q2',
  ),
];

class _FirstTrueWinsGameState extends State<FirstTrueWinsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'first-true-wins',
    chapterId: 'mathematics',
    total: chainRounds.length,
    sourceProblemIdOf: (round) => chainRounds[round].source,
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

  ChainRound get _round => chainRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'First True Wins',
        closing:
            'Conditions are read from the top and the chain stops at the '
            'first one that holds. A later test that would also have been '
            'true never gets its turn, and the closing ELSE only runs when '
            'every test above it has failed.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: selectionBrief,
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
            'TOP TO BOTTOM, STOP AT THE FIRST',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the branch that actually runs.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              r.given,
              style: AppTheme.code(size: 14, color: AppColors.cream),
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < r.branches.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _BranchRow(
              key: ValueKey('branch-$i'),
              lead: r.branches[i].test == null
                  ? 'ELSE'
                  : (i == 0 ? 'IF' : 'ELSE IF'),
              test: r.branches[i].test,
              body: r.branches[i].body,
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
              title: _session.correct! ? 'THAT BRANCH' : 'NOT THAT BRANCH',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _BranchRow extends StatelessWidget {
  const _BranchRow({
    super.key,
    required this.lead,
    required this.test,
    required this.body,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String lead;
  final String? test;
  final String body;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                width: 58,
                child: Text(
                  lead,
                  style: AppTheme.overline(color: AppColors.ink2),
                ),
              ),
              Expanded(
                child: Text(
                  test == null ? body : '$test  →  $body',
                  style: AppTheme.code(size: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
