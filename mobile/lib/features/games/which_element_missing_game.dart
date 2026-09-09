import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Which Element Is Missing — the second item for `professional-liability`.
///
/// Four elements, all four required, and the lesson names the two things that
/// go wrong. Intent gets added to the list, where it does not belong, and
/// causation gets dropped off it, which is the one most often forgotten and
/// the one most claims actually fail on.
///
/// So each round is a claim that fails, and the question is which of the four
/// the plaintiff cannot prove. One claim has all four, because a board where
/// something is always missing teaches somebody to hunt rather than to check.
class WhichElementMissingGame extends StatefulWidget {
  const WhichElementMissingGame({super.key});

  @override
  State<WhichElementMissingGame> createState() =>
      _WhichElementMissingGameState();
}

/// The four, in the order a claim is walked.
const elements = <(String, String)>[
  ('Duty', 'somebody was owed the standard of care'),
  ('Breach', 'the standard was not met'),
  ('Causation', 'the breach is what caused the harm'),
  ('Damages', 'there is measurable loss'),
  ('Nothing. All four hold.', 'the claim is made out'),
];

@immutable
class ElementRound {
  const ElementRound({
    required this.subject,
    required this.claim,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String claim;

  /// Index into [elements].
  final int answer;
  final String why;
  final String source;
}

const elementRounds = <ElementRound>[
  ElementRound(
    subject: 'a crack that cost nothing',
    claim:
        'An engineer plainly skipped a required check and a hairline crack '
        'appeared because of it. The owner is annoyed. Nothing has to be '
        'repaired and nothing has lost any value.',
    answer: 3,
    why:
        'Three of the four are there and the claim still fails. Negligence is '
        'not actionable in the abstract; somebody has to have lost something '
        'measurable, and being annoyed is not that.',
    source: 'eth-liab-q2',
  ),
  ElementRound(
    subject: 'a wall that was going to fail anyway',
    claim:
        'An engineer missed a drainage detail. The wall failed, expensively. '
        'The investigation shows it failed because the contractor backfilled '
        'with the wrong material, and would have failed with the detail in '
        'place.',
    answer: 2,
    why:
        'There was a duty, it was breached, and the loss is real. What is '
        'missing is the link between them, and this is the element that is '
        'forgotten most and that defeats claims most.',
    source: 'eth-liab-q2',
  ),
  ElementRound(
    subject: 'a stranger reading a report',
    claim:
        'A buyer found an old geotechnical report online, relied on it for a '
        'different site, and lost money. The engineer prepared it years '
        'earlier for a different client and had never heard of the buyer.',
    answer: 0,
    why:
        'The engineer owed the standard of care to somebody, and not to '
        'everybody who might ever find the document. Without a duty running to '
        'this plaintiff there is nothing for the other three to attach to.',
    source: 'eth-liab-q2',
  ),
  ElementRound(
    subject: 'a settlement within tolerance',
    claim:
        'A building settled and cracked a finish. The engineer\'s design met '
        'the code and matched what any competent peer would have produced, and '
        'the settlement is inside the tolerance the design allowed for.',
    answer: 1,
    why:
        'A duty was owed and the loss is real, and the engineer did what a '
        'competent peer would have done. Nothing was breached, which is the '
        'whole of what the standard of care protects.',
    source: 'eth-liab-q1',
  ),
  ElementRound(
    subject: 'a canopy in a storm',
    claim:
        'An engineer for the owner never ran the wind uplift check the code '
        'requires. The canopy lifted in the first storm and the owner paid to '
        'rebuild it.',
    answer: 4,
    why:
        'A duty to the client, a required check not run, a direct line from '
        'the one to the other, and a bill for the rebuild. All four, which is '
        'what a claim that succeeds looks like.',
    source: 'eth-liab-q2',
  ),
  ElementRound(
    subject: 'a report nobody acted on',
    claim:
        'An engineer\'s report understated a slope risk. The owner never read '
        'it, never did anything differently, and the slope has not moved.',
    answer: 3,
    why:
        'Nothing has happened yet. There may well be a breach sitting there, '
        'and until it costs somebody something there is no claim, which is why '
        'the repose clock matters so much in this trade.',
    source: 'eth-liab-q2',
  ),
];

class _WhichElementMissingGameState extends State<WhichElementMissingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-element-missing',
    chapterId: 'ethics',
    total: elementRounds.length,
    sourceProblemIdOf: (round) => elementRounds[round].source,
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

  ElementRound get _round => elementRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Element Is Missing',
        closing:
            'Duty, breach, causation, damages. All four or no claim, and '
            'intent is not among them. Causation is the one that goes missing '
            'quietly: a real breach and a real loss that had nothing to do '
            'with each other is still not negligence.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: negligenceBrief,
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
            'WHAT CANNOT BE PROVED',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.claim,
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
          const SizedBox(height: 14),
          for (var i = 0; i < elements.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            LiabilityRow(
              key: ValueKey('element-$i'),
              title: elements[i].$1,
              note: elements[i].$2,
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
              title: _session.correct! ? 'THAT IS THE GAP' : 'LOOK AGAIN',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
