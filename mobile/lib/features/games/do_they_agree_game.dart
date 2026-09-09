import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Do They Agree — the third item for `pw-fw-aw-analysis`.
///
/// Present worth, future worth and annual worth are the same comparison told
/// on three different clocks, and for the same alternatives at the same rate
/// over the same period they cannot disagree. Somebody who does not know that
/// spends the exam checking their arithmetic when the real problem is that
/// their two calculations covered different amounts of time.
///
/// So each round reports a disagreement and asks what caused it. Sometimes
/// nothing did and the arithmetic is simply wrong; sometimes the two
/// comparisons were never comparing the same thing.
class DoTheyAgreeGame extends StatefulWidget {
  const DoTheyAgreeGame({super.key});

  @override
  State<DoTheyAgreeGame> createState() => _DoTheyAgreeGameState();
}

enum Cause { arithmetic, periods, rate }

@immutable
class AgreeRound {
  const AgreeRound({
    required this.subject,
    required this.report,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What somebody says they found.
  final String report;
  final Cause answer;
  final String why;
  final String source;
}

const agreeRounds = <AgreeRound>[
  AgreeRound(
    subject: 'two culverts over twenty years',
    report:
        'Both options run for twenty years and both were evaluated at eight '
        'percent. Present worth prefers A. Annual worth prefers B.',
    answer: Cause.arithmetic,
    why:
        'Nothing can make that happen. The same alternatives, the same period '
        'and the same rate give the same ranking whichever clock you convert '
        'to, so the disagreement is a slip and not a finding.',
    source: 'econ-pfa-q1',
  ),
  AgreeRound(
    subject: 'a six year pump against a four year one',
    report:
        'Both were evaluated at eight percent. Present worth was taken over '
        'each pump\'s own life. Present worth prefers the four year pump and '
        'annual worth prefers the six year one.',
    answer: Cause.periods,
    why:
        'Six years of service and four years of service were priced against '
        'each other, which makes the shorter one look cheap because it is '
        'buying less. Annual worth is the one to trust here, and present worth '
        'over twelve years would agree with it.',
    source: 'econ-pfa-q3',
  ),
  AgreeRound(
    subject: 'a project revisited by the finance office',
    report:
        'The same alternative over the same ten years came back with a '
        'positive present worth in the engineer\'s note and a negative one in '
        'the finance office\'s.',
    answer: Cause.rate,
    why:
        'A present worth is only a number at a stated rate. Raise the rate '
        'enough and any project with its costs early and its benefits late '
        'turns negative, and the two offices are almost certainly using '
        'different MARRs.',
    source: 'econ-pfa-q1',
  ),
  AgreeRound(
    subject: 'a lease against a purchase',
    report:
        'A seven year purchase and a three year lease were each brought back '
        'over their own terms at the same rate. Present worth prefers the '
        'lease. Annual worth prefers the purchase.',
    answer: Cause.periods,
    why:
        'Three years of a vehicle against seven of one, and the cheaper number '
        'belongs to the one that stops sooner. Either repeat the lease to '
        'twenty one years or use annual worth and stop worrying about it.',
    source: 'econ-pfa-q3',
  ),
  AgreeRound(
    subject: 'the same excavator, twice',
    report:
        'The same excavator over the same ten years at the same eight percent '
        'came out at one annual worth on Monday and a different one on '
        'Tuesday.',
    answer: Cause.arithmetic,
    why:
        'One set of cash flows, one period, one rate, one answer. When '
        'everything that could differ is the same, the difference is in the '
        'working, and the usual culprit is the salvage having changed sign.',
    source: 'econ-pfa-q2',
  ),
  AgreeRound(
    subject: 'a road scheme and a bond desk',
    report:
        'A highway scheme over thirty years was accepted by the engineers and '
        'rejected by the treasury, on identical cash flows and an identical '
        'thirty year horizon.',
    answer: Cause.rate,
    why:
        'A treasury judging projects against what borrowing costs will use a '
        'higher threshold than an engineering office using a policy rate. '
        'Neither is wrong, and both should say which rate they used.',
    source: 'econ-pfa-q1',
  ),
];

class _DoTheyAgreeGameState extends State<DoTheyAgreeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'do-they-agree',
    chapterId: 'economics',
    total: agreeRounds.length,
    sourceProblemIdOf: (round) => agreeRounds[round].source,
  )..addListener(_onSession);

  Cause? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  AgreeRound get _round => agreeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Do They Agree',
        closing:
            'The three methods are one comparison on three clocks and they '
            'cannot disagree about the same alternatives, over the same '
            'period, at the same rate. When they do, one of those three was '
            'not actually the same.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: methodsAgreeBrief,
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
            'WHY DO THEY DISAGREE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              r.report,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 16),
          for (final c in Cause.values) ...[
            if (c != Cause.values.first) const SizedBox(height: 8),
            LiabilityRow(
              key: ValueKey('cause-${c.name}'),
              title: switch (c) {
                Cause.arithmetic => 'Nothing can. Somebody slipped.',
                Cause.periods => 'They covered different periods',
                Cause.rate => 'They used different rates',
              },
              note: switch (c) {
                Cause.arithmetic => 'same alternatives, period and rate',
                Cause.periods => 'unequal lives, compared as they stand',
                Cause.rate => 'a present worth is a number at a rate',
              },
              selected: _picked == c,
              locked: answered,
              isTruth: c == r.answer,
              onTap: answered ? null : () => setState(() => _picked = c),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHY' : 'SOMETHING ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
