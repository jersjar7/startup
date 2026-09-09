import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Which Bucket — the first item for `cost-types-breakeven`.
///
/// The lesson opens by saying that getting the classification wrong sets the
/// whole problem up incorrectly, and then names the one the exam loves: a cost
/// already spent, described as previously invested or non-recoverable, put
/// into the comparison because it physically belongs to one of the options.
///
/// Five buckets, and the interesting ones are the two nobody reaches for. An
/// opportunity cost is real and never appears on an invoice, and a marginal
/// cost is the next unit rather than the average of all of them.
class WhichBucketGame extends StatefulWidget {
  const WhichBucketGame({super.key});

  @override
  State<WhichBucketGame> createState() => _WhichBucketGameState();
}

/// The five, in the order the lesson introduces them.
const buckets = <(String, String)>[
  ('Fixed', 'the same whatever the volume'),
  ('Variable', 'scales with how much is produced'),
  ('Sunk', 'already spent, and out of the comparison'),
  ('Opportunity', 'what choosing this gives up'),
  ('Marginal', 'what one more unit costs'),
];

@immutable
class BucketRound {
  const BucketRound({
    required this.subject,
    required this.cost,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String cost;

  /// Index into [buckets].
  final int answer;
  final String why;
  final String source;
}

const bucketRounds = <BucketRound>[
  BucketRound(
    subject: 'the plant that is already there',
    cost:
        'A county built a treatment plant five years ago for 3.2 million '
        'dollars. It is now choosing between expanding that plant and building '
        'a satellite one.',
    answer: 2,
    why:
        'Spent, gone, and unrecoverable whichever option wins. Belonging to '
        'one option physically does not put it into that option financially, '
        'and neither does depreciating it: sunk is sunk however it is '
        'accounted for.',
    source: 'econ-ctb-q1',
  ),
  BucketRound(
    subject: 'diesel for the haul',
    cost:
        'Hauling costs three dollars a cubic yard in fuel, and the contractor '
        'is deciding how much to move today.',
    answer: 1,
    why:
        'Move twice as much and it costs twice as much, which is the whole '
        'definition. It is the slope of the cost line and it decides which '
        'method wins at high volume.',
    source: 'econ-ctb-q2',
  ),
  BucketRound(
    subject: 'the lease on the yard',
    cost:
        'The contractor pays 4,200 dollars a day for the yard and the '
        'insurance on it, whether the trucks run or sit.',
    answer: 0,
    why:
        'Nothing about the volume changes it, so it is where the cost line '
        'starts rather than how steeply it rises. It is also why the '
        'high-fixed option only wins once there is enough work to spread it '
        'over.',
    source: 'econ-ctb-q2',
  ),
  BucketRound(
    subject: 'land that could have been sold',
    cost:
        'The satellite plant would go on a parcel the county already owns and '
        'could otherwise sell for 400,000 dollars.',
    answer: 3,
    why:
        'Owning it already does not make it free. Building there gives up the '
        'sale, and the value given up belongs in the comparison even though no '
        'invoice will ever be issued for it.',
    source: 'econ-ctb-q1',
  ),
  BucketRound(
    subject: 'one more yard than planned',
    cost:
        'The contractor wants to know what it costs to haul the six hundred '
        'and first cubic yard, having already planned for six hundred.',
    answer: 4,
    why:
        'The next one, not the average of all of them. It is usually the '
        'variable cost per unit, and it stops being that the moment one more '
        'unit needs another truck.',
    source: 'econ-ctb-q2',
  ),
  BucketRound(
    subject: 'a study nobody can undo',
    cost:
        'Two million dollars was spent on a feasibility study for a bridge. '
        'The council is now deciding whether to build it.',
    answer: 2,
    why:
        'The commonest trap on this topic, and it is a trap because it feels '
        'like waste. Two million already gone is not a reason to spend more, '
        'and it is not a reason to stop either.',
    source: 'econ-ctb-q1',
  ),
];

class _WhichBucketGameState extends State<WhichBucketGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-bucket',
    chapterId: 'economics',
    total: bucketRounds.length,
    sourceProblemIdOf: (round) => bucketRounds[round].source,
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

  BucketRound get _round => bucketRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Bucket',
        closing:
            'Fixed is where the line starts and variable is how steeply it '
            'rises. Sunk is already gone and stays out. Opportunity cost never '
            'appears on an invoice and belongs in anyway, and marginal is the '
            'next unit rather than the average of them all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: costTypesBrief,
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
            'WHAT KIND OF COST IS THIS',
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
              r.cost,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < buckets.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            LiabilityRow(
              key: ValueKey('bucket-$i'),
              title: buckets[i].$1,
              note: buckets[i].$2,
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
              title: _session.correct! ? 'THAT BUCKET' : 'A DIFFERENT BUCKET',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
