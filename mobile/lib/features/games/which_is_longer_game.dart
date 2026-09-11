import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'alignment_figures.dart';

/// Which Is Longer — the third item for `horizontal-curves`.
///
/// The lesson names the same confusion twice: the curve length and the
/// tangent distance are different measurements of the same curve, and one
/// gets used where the other belongs. They are different in a way worth
/// feeling rather than memorizing. On a gentle bend the arc is roughly twice
/// the tangent. As the turn sharpens the tangent catches up, passes the arc
/// at around 134 degrees, and then runs away to nothing short of infinity as
/// the turn approaches a full reversal, because the two tangents become
/// nearly parallel and their meeting point goes off the county.
class WhichIsLongerGame extends StatefulWidget {
  const WhichIsLongerGame({super.key});

  @override
  State<WhichIsLongerGame> createState() => _WhichIsLongerGameState();
}

/// Which of the two is the longer measurement.
enum Longer { arc, tangent, same }

extension LongerWords on Longer {
  String get plain => switch (this) {
        Longer.arc => 'The curve length L, round the arc',
        Longer.tangent => 'The tangent distance T, out to the PI',
        Longer.same => 'Neither: they are the same here',
      };
}

@immutable
class LongerRound {
  const LongerRound({
    required this.subject,
    required this.setting,
    required this.bend,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Bend2 bend;
  final String why;
  final String source;

  /// Worked out from the two lengths, never declared.
  Longer get answer {
    final gap = bend.arc - bend.tangent;
    if (gap.abs() < bend.radius * 0.01) return Longer.same;
    return gap > 0 ? Longer.arc : Longer.tangent;
  }
}

const longerRounds = <LongerRound>[
  LongerRound(
    subject: 'a gentle bend',
    setting: 'A 1,000 foot radius turning through 20 degrees.',
    bend: Bend2(radius: 1000, turn: 20),
    why:
        'The arc, at 349 feet against 176. On a shallow curve the arc is '
        'very close to twice the tangent, because the two tangents together '
        'are nearly the whole way round the outside of a very flat triangle. '
        'That two to one is a useful sense check on any gentle curve.',
    source: 'surv-hc-q3',
  ),
  LongerRound(
    subject: 'the lesson\'s own curve',
    setting: 'A 1,000 foot radius turning through 40 degrees.',
    bend: Bend2(radius: 1000, turn: 40),
    why:
        'The arc, 698 feet against 364, and these are the two numbers the '
        'lesson puts in front of you: 364 is the answer to its tangent '
        'question and 698 is offered beside it as a wrong one. Still very '
        'nearly two to one at 40 degrees.',
    source: 'surv-hc-q2',
  ),
  LongerRound(
    subject: 'a right angle turn',
    setting: 'An 800 foot radius turning through a full 90 degrees.',
    bend: Bend2(radius: 800, turn: 90),
    why:
        'The arc, 1,257 feet against 800, and the ratio has dropped from two '
        'to about one and a half. At a right angle the tangent is exactly '
        'the radius, because the half angle is 45 degrees and its tangent is '
        'one. That is a checkpoint worth remembering: at 90 degrees, T '
        'equals R.',
    source: 'surv-hc-q2',
  ),
  LongerRound(
    subject: 'the crossing point',
    setting:
        'A 600 foot radius turning through about 134 degrees, which is a '
        'sharper turn than most roads ever ask for.',
    bend: Bend2(radius: 600, turn: 133.6),
    why:
        'Neither: they are level here, both a little over 1,400 feet. '
        'Somewhere around 134 degrees the tangent catches the arc and passes '
        'it. Below that the arc is longer, above it the tangent is, and '
        'nothing in either formula announces the crossing.',
    source: 'surv-hc-q3',
  ),
  LongerRound(
    subject: 'a hairpin',
    setting: 'A 400 foot radius turning through 150 degrees.',
    bend: Bend2(radius: 400, turn: 150),
    why:
        'The tangent, 1,493 feet against 1,047. Past the crossing the '
        'tangent wins and keeps winning. The PI has run a long way out from '
        'the road, which is why a hairpin needs so much more right of way at '
        'the corner than the pavement itself ever occupies.',
    source: 'surv-hc-q2',
  ),
  LongerRound(
    subject: 'nearly doubling back',
    setting: 'A 300 foot radius turning through 165 degrees.',
    bend: Bend2(radius: 300, turn: 165),
    why:
        'The tangent, and by a long way: 2,214 feet against 864. As the turn '
        'approaches a full reversal the two tangents become nearly parallel, '
        'so the point where they would meet runs away toward infinity. The '
        'arc meanwhile can never exceed half the circumference. This is why '
        'switchbacks are laid out from the curve rather than from the PI.',
    source: 'surv-hc-q2',
  ),
];

class _WhichIsLongerGameState extends State<WhichIsLongerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-is-longer',
    chapterId: 'surveying',
    total: longerRounds.length,
    sourceProblemIdOf: (round) => longerRounds[round].source,
  )..addListener(_onSession);

  Longer? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LongerRound get _round => longerRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Is Longer',
        closing:
            'On a gentle bend the arc is about twice the tangent. At a right '
            'angle the tangent equals the radius and the arc is still half as '
            'long again. Somewhere near 134 degrees the two are equal, and '
            'past that the tangent runs away while the arc cannot exceed half '
            'a circle. Which is why the two get confused, and why the '
            'confusion matters most on exactly the curves that are hardest '
            'to build.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: roadCurveBrief,
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
            'WHICH MEASUREMENT IS THE LONGER ONE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 260,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: AlignPainter(
                    bend: r.bend,
                    // Neither is picked out until it is answered: the two
                    // candidates have to look alike while it is a question.
                    answer: answered
                        ? (r.answer == Longer.tangent
                            ? Bit.tangent
                            : r.answer == Longer.arc
                                ? Bit.arc
                                : null)
                        : null,
                    locked: answered,
                    label: 'R ${r.bend.radius.round()} ft, I ${r.bend.turn}°',
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$T = R\tan\frac{I}{2} \qquad L = \frac{\pi R I}{180}$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Longer.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE LONGER ONE' : 'THE OTHER ONE',
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
