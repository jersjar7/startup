import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'test_figures.dart';

/// Reject or Not — the second item for `hypothesis-testing-goodness-of-fit`.
///
/// Three different tests in this lesson end the same way, and the lesson says
/// so in one line: bigger means reject. The statistic is arithmetic and
/// belongs on paper. What the exam charges for is the sentence afterwards, and
/// the lesson prints a warning about it: failing to reject does not make the
/// null true.
///
/// So both numbers are given and drawn on one scale, and the answer is the
/// conclusion in words. Every round offers the right decision dressed in the
/// wrong reasoning alongside the two real ones.
class RejectOrNotGame extends StatefulWidget {
  const RejectOrNotGame({super.key});

  @override
  State<RejectOrNotGame> createState() => _RejectOrNotGameState();
}

@immutable
class VerdictRound {
  const VerdictRound({
    required this.subject,
    required this.setup,
    required this.statistic,
    required this.critical,
    required this.twoTailed,
    required this.statLabel,
    required this.critLabel,
    required this.to,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What was tested and what came back, with the arithmetic already done.
  final String setup;
  final double statistic;
  final double critical;
  final bool twoTailed;
  final String statLabel;
  final String critLabel;
  final double to;
  final List<String> options;
  final int answer;
  final String why;
  final String source;

  /// Whether the numbers say to reject, which is the only thing that decides
  /// it: bigger than the critical value, on size alone.
  bool get rejects => statistic.abs() > critical;
}

const verdictRounds = <VerdictRound>[
  VerdictRound(
    subject: 'bearing capacity claimed to exceed 200 kPa',
    setup: 't = 2.4 against t(0.05, 15) = 1.753, one-tailed right',
    statistic: 2.4,
    critical: 1.753,
    twoTailed: false,
    statLabel: 't = 2.4',
    critLabel: '1.753',
    to: 4,
    options: [
      'Reject H0. There is evidence the mean exceeds 200 kPa.',
      'Fail to reject H0. Not enough evidence that it exceeds 200 kPa.',
      'Reject H0. The mean is proven to be above 200 kPa.',
    ],
    answer: 0,
    why:
        'Bigger than the critical value, so reject. Evidence FOR a claim is not '
        'proof of it, and an exam choice that says proven is wrong however '
        'right the decision beside it is.',
    source: 'stat-ht-q2',
  ),
  VerdictRound(
    subject: 'uniform arrivals across four periods',
    setup: 'chi-square = 5.0 against 7.815 at three degrees of freedom',
    statistic: 5.0,
    critical: 7.815,
    twoTailed: false,
    statLabel: 'X2 = 5.0',
    critLabel: '7.815',
    to: 14,
    options: [
      'Fail to reject. The arrivals really are uniform.',
      'Reject. The uniform model does not fit.',
      'Fail to reject. The uniform model is not contradicted by this data.',
    ],
    answer: 2,
    why:
        'Five is under the line, so there is nothing to reject. That is not '
        'the same as the arrivals being uniform: two hundred observations '
        'failed to catch it out, and that is all.',
    source: 'stat-ht-q3',
  ),
  VerdictRound(
    subject: 'a mix tested against 4,000 psi in both directions',
    setup: 'z = 2.0 against 1.960, two-tailed at alpha = 0.05',
    statistic: 2.0,
    critical: 1.96,
    twoTailed: true,
    statLabel: 'z = 2.0',
    critLabel: '1.960',
    to: 3.2,
    options: [
      'Fail to reject. Two and 1.96 are near enough the same.',
      'Reject H0. The mean differs from 4,000 psi.',
      'Reject H0. The mean is above 4,000 psi.',
    ],
    answer: 1,
    why:
        'Past the line is past the line, by however little. And the test was '
        'two-tailed, so what it supports is that the mean DIFFERS, not which '
        'way it went.',
    source: 'stat-ht-q1',
  ),
  VerdictRound(
    subject: 'a batch tested against a minimum',
    setup: 'z = 1.2 against 1.645, one-tailed right',
    statistic: 1.2,
    critical: 1.645,
    twoTailed: false,
    statLabel: 'z = 1.2',
    critLabel: '1.645',
    to: 3.2,
    options: [
      'Reject H0. The sample mean came out above the specified value.',
      'Fail to reject H0. Not enough evidence at this level.',
      'Fail to reject H0. The mean equals the specified value.',
    ],
    answer: 1,
    why:
        'The sample mean being on the right side of the specification is not '
        'the test; the test is whether it is far enough over to be surprising, '
        'and 1.2 is not.',
    source: 'stat-ht-q1',
  ),
  VerdictRound(
    subject: 'arrivals against a uniform model, second site',
    setup: 'chi-square = 12.4 against 7.815 at three degrees of freedom',
    statistic: 12.4,
    critical: 7.815,
    twoTailed: false,
    statLabel: 'X2 = 12.4',
    critLabel: '7.815',
    to: 18,
    options: [
      'Fail to reject. A bigger chi-square means the fit is better.',
      'Reject. The counts do not match the uniform model.',
      'Reject. The counts match the uniform model badly enough to be certain.',
    ],
    answer: 1,
    why:
        'Chi-square measures MISFIT, so bigger is worse and past the line means '
        'reject. Certainty is not on offer either: this is a five percent test '
        'and it can be wrong five times in a hundred.',
    source: 'stat-ht-q3',
  ),
  VerdictRound(
    subject: 'thickness tested against a target in both directions',
    setup: 't = -2.9 against t(0.025, 15) = 2.131, two-tailed',
    statistic: -2.9,
    critical: 2.131,
    twoTailed: true,
    statLabel: 't = -2.9',
    critLabel: '2.131',
    to: 4,
    options: [
      'Reject H0. The mean thickness differs from the target.',
      'Fail to reject. The statistic is negative and the critical value is not.',
      'Reject H0. The mean thickness is exactly 2.131 below the target.',
    ],
    answer: 0,
    why:
        'A two-tailed test compares SIZE. Minus 2.9 is further out than 2.131 '
        'and lands in the left rejection region, which the picture makes '
        'obvious and the algebra hides behind an absolute value.',
    source: 'stat-ht-q2',
  ),
];

class _RejectOrNotGameState extends State<RejectOrNotGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'reject-or-not',
    chapterId: 'statistics',
    total: verdictRounds.length,
    sourceProblemIdOf: (round) => verdictRounds[round].source,
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

  VerdictRound get _round => verdictRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Reject or Not',
        closing:
            'Bigger than the critical value means reject, for z, for t and for '
            'chi-square alike. And failing to reject is never a finding: it '
            'says the data did not catch the null out, not that the null is '
            'true.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: decisionRuleBrief,
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
            'THE ARITHMETIC IS DONE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'What is the correct conclusion?',
            style: TextStyle(
              fontSize: 16,
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
              height: 120,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: ScalePainter(
                    statistic: r.statistic,
                    critical: r.critical,
                    twoTailed: r.twoTailed,
                    to: r.to,
                    statLabel: r.statLabel,
                    critLabel: r.critLabel,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            r.setup,
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _VerdictRow(
              key: ValueKey('verdict-$i'),
              text: r.options[i],
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
              title: _session.correct! ? 'THAT IS THE CALL' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _VerdictRow extends StatelessWidget {
  const _VerdictRow({
    super.key,
    required this.text,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String text;
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
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
