import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Is That Negligence — the first item for `professional-liability`.
///
/// The lesson's own sentence is that engineers are not guarantors. They are
/// measured against what a reasonably competent peer would have done in the
/// same circumstances, which means a design can turn out badly without anybody
/// having been negligent, and can be negligent without anything having gone
/// wrong yet.
///
/// The third answer separates negligence from something worse. Negligence
/// needs no intent at all, and an engineer who MEANT it has done a different
/// and more serious thing, which the exam likes to slip into the same list.
class IsThatNegligenceGame extends StatefulWidget {
  const IsThatNegligenceGame({super.key});

  @override
  State<IsThatNegligenceGame> createState() => _IsThatNegligenceGameState();
}

enum Fault { negligent, notNegligent, deliberate }

@immutable
class FaultRound {
  const FaultRound({
    required this.subject,
    required this.scene,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String scene;
  final Fault answer;
  final String why;
  final String source;
}

const faultRounds = <FaultRound>[
  FaultRound(
    subject: 'a settlement nobody could have predicted',
    scene:
        'An engineer ran the borings the code asks for, used the accepted '
        'method, and sized the footings the way any competent peer would have. '
        'A seam of soft clay nobody could have found from those borings caused '
        'settlement two years later.',
    answer: Fault.notNegligent,
    why:
        'A bad outcome is not the test. The question is what a reasonably '
        'competent engineer would have done in the same circumstances, and '
        'this engineer did it. Being wrong and being negligent are different '
        'things.',
    source: 'eth-liab-q1',
  ),
  FaultRound(
    subject: 'a load case that was never run',
    scene:
        'An engineer sized a canopy for dead and live load and never checked '
        'the wind uplift, which the code requires and which every peer would '
        'have run. The canopy lifted in the first storm.',
    answer: Fault.negligent,
    why:
        'A required check that everybody else performs is the standard of '
        'care, in the plainest form it takes. Skipping it is falling short of '
        'the standard whether or not anything had blown away.',
    source: 'eth-liab-q1',
  ),
  FaultRound(
    subject: 'a report that was written to order',
    scene:
        'An engineer knew the compaction results failed and wrote the report '
        'saying they passed, because the client asked and the schedule was '
        'tight.',
    answer: Fault.deliberate,
    why:
        'This is not a failure to be careful. Knowing the truth and writing '
        'the opposite is deliberate, and negligence is the wrong word for it '
        'in the same way that a collision is the wrong word for aiming.',
    source: 'eth-liab-q1',
  ),
  FaultRound(
    subject: 'a code edition that had moved',
    scene:
        'An engineer designed to the code edition in force when the project '
        'began. A newer edition took effect midway through and the office had '
        'circulated it. Nobody checked, and the design does not meet it.',
    answer: Fault.negligent,
    why:
        'Keeping up with the code in force is part of what a competent peer '
        'does, and the office had put it in front of them. Nothing here was '
        'meant; it was simply not done.',
    source: 'eth-liab-q1',
  ),
  FaultRound(
    subject: 'a client who wanted something else',
    scene:
        'An engineer chose a rigid pavement section where a competent peer '
        'might reasonably have chosen flexible. The section performs as '
        'designed. The client is unhappy about the cost.',
    answer: Fault.notNegligent,
    why:
        'Where competent engineers could reasonably differ, choosing one of '
        'them is not a breach. A client\'s disappointment is not a measure of '
        'the standard of care, and the exam offers it because it feels like '
        'one.',
    source: 'eth-liab-q1',
  ),
  FaultRound(
    subject: 'a seal on somebody else\'s numbers',
    scene:
        'An engineer sealed a set they had neither prepared nor supervised, '
        'knowing they had not read it, because the fee was good and the '
        'deadline was that afternoon.',
    answer: Fault.deliberate,
    why:
        'Nothing was overlooked here. The engineer knew what they had not '
        'done and sealed it anyway, which puts it outside carelessness '
        'altogether and into a category the word negligence does not reach.',
    source: 'eth-liab-q1',
  ),
];

class _IsThatNegligenceGameState extends State<IsThatNegligenceGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'is-that-negligence',
    chapterId: 'ethics',
    total: faultRounds.length,
    sourceProblemIdOf: (round) => faultRounds[round].source,
  )..addListener(_onSession);

  Fault? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FaultRound get _round => faultRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Is That Negligence',
        closing:
            'Not perfection, and not intent. The measure is what a reasonably '
            'competent engineer would have done in the same circumstances, so '
            'a design can fail without anybody being negligent, and an '
            'engineer who meant it has done something the word does not cover.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: standardOfCareBrief,
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
            'AGAINST WHAT A COMPETENT PEER WOULD DO',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.scene,
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
          const SizedBox(height: 16),
          for (final f in Fault.values) ...[
            if (f != Fault.values.first) const SizedBox(height: 8),
            LiabilityRow(
              key: ValueKey('fault-${f.name}'),
              title: switch (f) {
                Fault.negligent => 'Negligent',
                Fault.notNegligent => 'Not negligent',
                Fault.deliberate => 'Not negligence. Deliberate.',
              },
              note: switch (f) {
                Fault.negligent => 'fell short of what a peer would do',
                Fault.notNegligent => 'the standard was met, outcome aside',
                Fault.deliberate => 'they knew, and did it anyway',
              },
              selected: _picked == f,
              locked: answered,
              isTruth: f == r.answer,
              onTap: answered ? null : () => setState(() => _picked = f),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
