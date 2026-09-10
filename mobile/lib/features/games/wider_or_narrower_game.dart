import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'interval_figures.dart';
import 'lesson_brief.dart';

/// Wider or Narrower — the second item for `confidence-intervals-estimation`.
///
/// The lesson opens by saying the width depends on three things and then
/// spends the rest of itself on formulas. The exam asks about the three
/// things. Its medium problem is a t against z question, and the answer is not
/// a number: t is wider than z at the same confidence, because a sample
/// standard deviation is itself a guess and the interval has to pay for that.
///
/// So nothing is computed here. One thing about the study changes, and the
/// question is which way the interval moves. The one round where nothing
/// happens is the one worth meeting: the width does not depend on the sample
/// mean at all.
class WiderOrNarrowerGame extends StatefulWidget {
  const WiderOrNarrowerGame({super.key});

  @override
  State<WiderOrNarrowerGame> createState() => _WiderOrNarrowerGameState();
}

enum Move { narrower, same, wider }

@immutable
class MoveRound {
  const MoveRound({
    required this.before,
    required this.change,
    required this.answer,
    required this.after,
    required this.why,
    required this.source,
  });

  /// The study as it stands.
  final String before;

  /// What changes about it.
  final String change;
  final Move answer;

  /// The half-width afterwards, as a multiple of what it was, so the reveal
  /// can draw the two intervals against each other.
  final double after;
  final String why;
  final String source;
}

const moveRounds = <MoveRound>[
  MoveRound(
    before: '25 samples, sigma known, reported at 95%',
    change: 'You go back and collect 100 samples instead of 25.',
    answer: Move.narrower,
    after: 0.5,
    why:
        'Four times the samples halve the margin, because the root of four is '
        'two. That is the whole economics of sampling: the interval improves '
        'with the root of the effort, never with the effort.',
    source: 'stat-ci-q1',
  ),
  MoveRound(
    before: '25 samples, sigma known, reported at 95%',
    change: 'The report is reissued at 99% confidence instead of 95%.',
    answer: Move.wider,
    after: 1.314,
    why:
        'Being surer costs width. The multiplier goes from 1.960 to 2.576 and '
        'the interval grows by about a third, which is the price of the extra '
        'four percent of confidence.',
    source: 'stat-ci-q1',
  ),
  MoveRound(
    before: '10 cylinders, 95% confidence',
    change:
        'Sigma was never actually known. You have s from the sample, so you '
        'switch to t with nine degrees of freedom.',
    answer: Move.wider,
    after: 1.154,
    why:
        'The t interval is always the wider one at the same confidence, because '
        'the spread is now a guess too and the interval has to pay for that. '
        'With ten samples the multiplier goes from 1.960 to 2.262.',
    source: 'stat-ci-q2',
  ),
  MoveRound(
    before: '10 cylinders, s known, 95% confidence',
    change:
        'The cylinders come back stronger than expected, so the sample mean is '
        'higher. Everything else is unchanged.',
    answer: Move.same,
    after: 1,
    why:
        'The interval slides up the axis and keeps its width. Nothing in the '
        'margin formula mentions the mean, and noticing that is worth more than '
        'memorising the formula.',
    source: 'stat-ci-q2',
  ),
  MoveRound(
    before: '25 samples, sigma assumed to be 5, reported at 95%',
    change: 'The material turns out to be more consistent: sigma is really 2.5.',
    answer: Move.narrower,
    after: 0.5,
    why:
        'Half the spread, half the margin, and this one is a straight halving '
        'rather than a root. Consistency is the cheapest way to a tight '
        'interval, which is why specifications chase it.',
    source: 'stat-ci-q1',
  ),
  MoveRound(
    before: '100 samples already counted, reported at 95%',
    change: 'The budget stretches to 121 samples rather than 100.',
    answer: Move.narrower,
    after: 0.909,
    why:
        'It helps, and barely. Twenty one more days of counting buys nine '
        'percent off the margin, which is the flat end of the curve and the '
        'reason sample size is planned before the counting starts.',
    source: 'stat-ci-q3',
  ),
];

class _WiderOrNarrowerGameState extends State<WiderOrNarrowerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'wider-or-narrower',
    chapterId: 'statistics',
    total: moveRounds.length,
    sourceProblemIdOf: (round) => moveRounds[round].source,
  )..addListener(_onSession);

  Move? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  MoveRound get _round => moveRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Wider or Narrower',
        closing:
            'Three things set the width: how sure you want to be, how spread '
            'out the material is, and how many samples you took. The sample '
            'mean is not one of them, and t is always wider than z.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: zOrTBrief,
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
            'WHICH WAY DOES THE INTERVAL MOVE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.before,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 130,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: IntervalPainter(
                    center: 0,
                    widest: 1.5,
                    unit: 'the true mean',
                    bands: [
                      const Band(
                        margin: 1,
                        label: 'as it stands',
                        tone: BandTone.before,
                      ),
                      // Held back until it is answered: the picture IS the
                      // answer, so showing it early asks nothing of anybody.
                      if (answered)
                        Band(
                          margin: r.after,
                          label: 'after the change',
                          tone: _session.correct!
                              ? BandTone.truth
                              : BandTone.wrong,
                        ),
                    ],
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (i, move) in Move.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _MoveButton(
                    key: ValueKey('move-${move.name}'),
                    label: switch (move) {
                      Move.narrower => 'Narrower',
                      Move.same => 'No change',
                      Move.wider => 'Wider',
                    },
                    selected: _picked == move,
                    locked: answered,
                    isTruth: move == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = move),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE WAY' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({
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
          height: 54,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
