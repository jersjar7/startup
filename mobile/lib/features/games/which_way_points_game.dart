import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'test_figures.dart';

/// Which Way Does It Point — the first item for
/// `hypothesis-testing-goodness-of-fit`.
///
/// The lesson's medium problem names its own trap: mixing up one-tailed and
/// two-tailed, because the claim said "exceeds". Nothing about that is
/// arithmetic. It is a sentence in English deciding the shape of a picture,
/// and once the picture is chosen the critical value follows from a table.
///
/// So the claim is on screen and the three arrangements are drawn side by
/// side. The reveal says where alpha went, because a two-tailed test splits it
/// and a student who has not seen that split will read the wrong row.
class WhichWayPointsGame extends StatefulWidget {
  const WhichWayPointsGame({super.key});

  @override
  State<WhichWayPointsGame> createState() => _WhichWayPointsGameState();
}

@immutable
class PointRound {
  const PointRound({
    required this.subject,
    required this.claim,
    required this.hypotheses,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What somebody is claiming, in the words the exam would use.
  final String claim;

  /// The pair the claim sets up, revealed with the answer.
  final String hypotheses;
  final Tail answer;
  final String why;
  final String source;
}

const pointRounds = <PointRound>[
  PointRound(
    subject: 'bearing capacity of a clay deposit',
    claim: 'The engineer claims the mean bearing capacity EXCEEDS 200 kPa.',
    hypotheses: 'H0: mu <= 200      H1: mu > 200',
    answer: Tail.right,
    why:
        'Exceeds points one way. Only a sample mean far ABOVE 200 is evidence '
        'for the claim, so the whole of alpha sits in the right tail and the '
        'critical value comes from the one-tailed row.',
    source: 'stat-ht-q2',
  ),
  PointRound(
    subject: 'compressive strength against a specified minimum',
    claim:
        'The spec sets a minimum of 4,000 psi. You are testing whether the mix '
        'FALLS SHORT of it.',
    hypotheses: 'H0: mu >= 4000      H1: mu < 4000',
    answer: Tail.left,
    why:
        'A minimum spec is only ever failed downwards. A batch that comes back '
        'stronger than 4,000 is not evidence of anything wrong, so the whole '
        'of alpha sits on the left.',
    source: 'stat-ht-q1',
  ),
  PointRound(
    subject: 'lift thickness against a target',
    claim:
        'The lift is specified at 2.00 in. Too thin fails the structure and '
        'too thick wastes material, so ANY deviation matters.',
    hypotheses: 'H0: mu = 2.00      H1: mu != 2.00',
    answer: Tail.both,
    why:
        'Both directions are failures, so both tails are rejection regions and '
        'alpha is split between them. Five percent overall means two and a '
        'half percent at each end, which is a different row of the table.',
    source: 'stat-ht-q1',
  ),
  PointRound(
    subject: 'delay at a retimed signal',
    claim: 'The new timing plan is claimed to REDUCE the mean delay.',
    hypotheses: 'H0: mu >= 42 s      H1: mu < 42 s',
    answer: Tail.left,
    why:
        'Reduce is a direction. Delay coming out higher than before is not '
        'evidence that the retiming worked, however surprising it is, so there '
        'is nothing to reject on the right.',
    source: 'stat-ht-q2',
  ),
  PointRound(
    subject: 'a new mix against the standard one',
    claim: 'The supplier claims the new mix is STRONGER than the standard mix.',
    hypotheses: 'H0: mu <= 4500      H1: mu > 4500',
    answer: Tail.right,
    why:
        'The supplier is making a directional claim and carrying the burden of '
        'proof for it. Everything that is not strong enough, however weak, '
        'leaves the claim unproven rather than disproven.',
    source: 'stat-ht-q2',
  ),
  PointRound(
    subject: 'a routine check with nothing being claimed',
    claim:
        'Nobody has a direction in mind. The question is only whether the '
        'population mean is STILL 4,000 psi.',
    hypotheses: 'H0: mu = 4000      H1: mu != 4000',
    answer: Tail.both,
    why:
        'No direction in the sentence means no direction in the test. Choosing '
        'a tail after seeing which way the data went is how a five percent '
        'test quietly becomes a ten percent one.',
    source: 'stat-ht-q1',
  ),
];

class _WhichWayPointsGameState extends State<WhichWayPointsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-points',
    chapterId: 'statistics',
    total: pointRounds.length,
    sourceProblemIdOf: (round) => pointRounds[round].source,
  )..addListener(_onSession);

  Tail? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PointRound get _round => pointRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way Does It Point',
        closing:
            'The claim decides the picture. A directional word puts all of '
            'alpha in one tail, and no direction splits it between two, which '
            'is a different row of the table and a different critical value.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: hypothesesBrief,
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
            'WHERE DOES ALPHA GO',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.claim,
            style: const TextStyle(
              fontSize: 15.5,
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
          Row(
            children: [
              for (final (i, tail) in Tail.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _TailCard(
                    key: ValueKey('tail-${tail.name}'),
                    tail: tail,
                    label: switch (tail) {
                      Tail.left => 'Left only',
                      Tail.both => 'Both ends',
                      Tail.right => 'Right only',
                    },
                    selected: _picked == tail,
                    locked: answered,
                    isTruth: tail == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = tail),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'WHAT THE CLAIM SETS UP',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 6),
            Text(r.hypotheses, style: AppTheme.code(size: 13)),
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SHAPE' : 'THE OTHER SHAPE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _TailCard extends StatelessWidget {
  const _TailCard({
    super.key,
    required this.tail,
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Tail tail;
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 96,
                child: CustomPaint(
                  painter: TailPainter(
                    tail: tail,
                    // Grey is too faint to read a shaded tail at this size,
                    // and the whole item is reading the shaded tail.
                    color: border == AppColors.line
                        ? AppColors.charcoal
                        : border,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.mono(size: 11, color: AppColors.charcoal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
