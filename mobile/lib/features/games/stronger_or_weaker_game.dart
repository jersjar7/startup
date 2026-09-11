import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'concrete_figures.dart';
import 'lesson_brief.dart';

/// Stronger or Weaker — the first item for `concrete-mix-design`.
///
/// One ratio decides the strength of concrete, and the lesson says outright
/// that people get its direction backwards because more water feels like it
/// should help. So every round is a change somebody actually makes on a job:
/// water added at the truck, cement added at the plant, a water reducer
/// instead of the water, air entrained for the winter, aggregate added. Which
/// way the strength moves is judgment about one ratio, and it is the judgment
/// the mistakes come from.
class StrongerOrWeakerGame extends StatefulWidget {
  const StrongerOrWeakerGame({super.key});

  @override
  State<StrongerOrWeakerGame> createState() => _StrongerOrWeakerGameState();
}

/// Which way the twenty eight day strength goes.
enum Way { up, down, level }

extension WayWords on Way {
  String get plain => switch (this) {
        Way.up => 'Stronger',
        Way.down => 'Weaker',
        Way.level => 'No real change either way',
      };
}

@immutable
class ChangeRound {
  const ChangeRound({
    required this.subject,
    required this.before,
    required this.after,
    required this.change,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The mix as batched, and the mix after somebody changes something.
  final Mix before;
  final Mix after;

  /// What was done, in the words a site would use.
  final String change;
  final String why;
  final String source;

  /// Worked out from the two mixes, never declared.
  Way get answer {
    final gap = (after.strength - before.strength) / before.strength;
    if (gap.abs() < 0.02) return Way.level;
    return gap > 0 ? Way.up : Way.down;
  }
}

const batchRounds = <ChangeRound>[
  ChangeRound(
    subject: 'water added at the truck',
    before: Mix(wc: 0.45),
    after: Mix(wc: 0.60),
    change:
        'The mix is stiff and hard to place, so the crew runs more water into '
        'the drum until it flows.',
    why:
        'Weaker, and by a lot: this is the single most expensive habit on a '
        'concrete site. Going from a ratio of 0.45 to 0.60 takes something '
        'like 5,600 psi down to about 3,500. The concrete does get easier to '
        'place, which is exactly why it happens, and the cylinders find out '
        'four weeks later.',
    source: 'mat-cmd-q3',
  ),
  ChangeRound(
    subject: 'cement added at the plant',
    before: Mix(wc: 0.50),
    after: Mix(wc: 0.40),
    change:
        'The water stays at 200 kilograms and the cement goes up from 400 to '
        '500.',
    why:
        'Stronger. More cement under the same water is a SMALLER ratio, '
        'because the cement is underneath: 200 over 500 is 0.40 where 200 '
        'over 400 was 0.50. That is the lesson\'s own second problem, and it '
        'buys roughly a thousand psi.',
    source: 'mat-cmd-q2',
  ),
  ChangeRound(
    subject: 'a water reducer instead',
    before: Mix(wc: 0.45),
    after: Mix(wc: 0.45, plasticized: true),
    change:
        'The same stiff mix, but a superplasticizer goes in rather than the '
        'extra water. It pours well now.',
    why:
        'No real change in strength, which is the whole point of the '
        'admixture. Workability went up and the ratio did not move, so the '
        'strength stays where it was. This is the right answer to the problem '
        'the first round solved the wrong way: you can have a mix that places '
        'well AND makes its number.',
    source: 'mat-cmd-q3',
  ),
  ChangeRound(
    subject: 'air entrained for the winter',
    before: Mix(wc: 0.45),
    after: Mix(wc: 0.45, air: 5),
    change:
        'The same ratio, with five percent air deliberately entrained for '
        'freeze and thaw.',
    why:
        'Weaker, by something like a fifth, and worth every bit of it where '
        'the concrete freezes. This is the trade the exam likes: air '
        'entrainment buys DURABILITY and costs STRENGTH. The two are '
        'different properties, and a mix that needs both has to start from a '
        'lower ratio to leave room.',
    source: 'mat-cmd-q3',
  ),
  ChangeRound(
    subject: 'the water comes down',
    before: Mix(wc: 0.55),
    after: Mix(wc: 0.45),
    change:
        'The cement stays where it is and the batch water is cut back, with a '
        'water reducer keeping it placeable.',
    why:
        'Stronger, and it is the same move as adding cement seen from the '
        'other side: what matters is the RATIO, so you can get there by '
        'taking water out or by putting cement in. Taking water out is '
        'usually cheaper, which is why water reducers earn their keep.',
    source: 'mat-cmd-q2',
  ),
  ChangeRound(
    subject: 'more aggregate in the batch',
    before: Mix(wc: 0.50),
    after: Mix(wc: 0.50),
    change:
        'The water and the cement are left exactly as they were, and more '
        'coarse aggregate goes into the mix.',
    why:
        'No real change to the ratio, and so none to the strength that this '
        'curve predicts. Nothing but water and cement goes into W over C: not '
        'aggregate, not the total weight of the batch. Dividing by the whole '
        'batch instead of by the cement is the first problem\'s own named '
        'wrong answer.',
    source: 'mat-cmd-q1',
  ),
];

class _StrongerOrWeakerGameState extends State<StrongerOrWeakerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stronger-or-weaker',
    chapterId: 'materials',
    total: batchRounds.length,
    sourceProblemIdOf: (round) => batchRounds[round].source,
  )..addListener(_onSession);

  Way? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ChangeRound get _round => batchRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stronger or Weaker',
        closing:
            'Water over cement decides it, and the direction is the one that '
            'feels wrong: more water is WEAKER. More cement under the same '
            'water is a smaller ratio and a stronger concrete. A water '
            'reducer buys workability for nothing. Air entrainment costs '
            'strength and buys freeze and thaw durability. Aggregate is not '
            'in the ratio at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: mixBrief,
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
            'WHICH WAY DOES THE STRENGTH GO',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'As batched: ${r.before.plain}',
            style: AppTheme.mono(size: 12.5, color: AppColors.charcoal),
          ),
          const SizedBox(height: 8),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 240,
              width: double.infinity,
              child: CustomPaint(
                // The mix is put on the chart only once the answer is in.
                // Before that the chart is the reference it would be on the
                // wall, not a place to read the answer off.
                painter: MixPainter(
                  marks: answered ? [r.before, r.after] : const [],
                  picked: null,
                  answer: answered ? 1 : null,
                  locked: answered,
                  showMarks: answered,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answered
                ? 'one is the mix as batched, two is the mix after the change'
                : 'the handbook curve. your mix goes on it once you answer',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$W/C = \dfrac{\text{water}}{\text{cement}}$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final way in Way.values) ...[
            _Choice(
              label: way.plain,
              selected: _picked == way,
              locked: answered,
              isTruth: r.answer == way,
              onTap: answered ? null : () => setState(() => _picked = way),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
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

class _Choice extends StatelessWidget {
  const _Choice({
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
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
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
