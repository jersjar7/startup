import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Does the Mass Matter — the second item for `work-energy-power`.
///
/// Two of the three problems in this lesson have the mass cancel out, and the
/// lesson says so both times. It is worth more than a footnote: whether the
/// answer depends on the mass tells you something real about the situation,
/// and knowing it in advance catches a wrong answer before it is written.
///
/// So two versions of the same thing are described, one heavier than the
/// other, and the answer is which of them wins, or whether they tie.
class DoesTheMassMatterGame extends StatefulWidget {
  const DoesTheMassMatterGame({super.key});

  @override
  State<DoesTheMassMatterGame> createState() => _DoesTheMassMatterGameState();
}

/// Which of the two comes out on top.
enum Heavier { heavy, light, tie }

extension HeavierWords on Heavier {
  String get plain => switch (this) {
        Heavier.heavy => 'The heavy one',
        Heavier.light => 'The light one',
        Heavier.tie => 'Neither: they come out the same',
      };
}

@immutable
class MassRound {
  const MassRound({
    required this.subject,
    required this.setting,
    required this.asked,
    required this.answer,
    required this.formula,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final String asked;
  final Heavier answer;

  /// The expression the answer comes from, shown once the round is over so
  /// the cancelling is visible rather than asserted.
  final String formula;

  final String why;
  final String source;
}

const massRounds = <MassRound>[
  MassRound(
    subject: 'two blocks down the same smooth ramp',
    setting:
        'A five kilogram block and a fifty kilogram block are let go together '
        'at the top of the same frictionless ramp.',
    asked: 'Which reaches the bottom moving faster?',
    answer: Heavier.tie,
    formula: r'v = \sqrt{2gh}',
    why:
        'Neither: exactly the same speed. The heavy one starts with ten times '
        'the energy and needs ten times as much to reach any given speed, so '
        'the mass cancels clean out of the whole thing. This is the lesson\'s '
        'own first problem, and it is the same reason two objects dropped '
        'together land together.',
    source: 'dyn-wep-q1',
  ),
  MassRound(
    subject: 'the same two blocks, a different question',
    setting: 'The same two blocks arriving at the bottom of that ramp.',
    asked: 'Which one arrives with more ENERGY?',
    answer: Heavier.heavy,
    formula: r'T = \tfrac{1}{2}mv^2',
    why:
        'The heavy one, by ten times, even though they are moving at exactly '
        'the same speed. Speed and energy are different questions, and only '
        'one of them has the mass cancel. This is why a heavy vehicle needs '
        'so much more guardrail than a light one at the same speed.',
    source: 'dyn-wep-q1',
  ),
  MassRound(
    subject: 'two blocks sliding to a stop',
    setting:
        'Two blocks of different mass are sliding at the same speed on the '
        'same floor, with the same coefficient of friction.',
    asked: 'Which slides further before stopping?',
    answer: Heavier.tie,
    formula: r'd = \frac{v^2}{2\mu g}',
    why:
        'Neither. The heavy block carries more energy, and friction takes it '
        'away faster in exactly the same proportion, because the friction '
        'force is the coefficient times the WEIGHT. The two effects cancel and '
        'the distance is the same. That is the lesson\'s hardest problem, and '
        'it is why stopping distance is quoted for a road rather than for a '
        'car.',
    source: 'dyn-wep-q3',
  ),
  MassRound(
    subject: 'two pumps lifting water',
    setting:
        'Two identical pumps lift water the same height at the same rate, but '
        'one is pumping water and the other something twice as dense.',
    asked: 'Which needs more power?',
    answer: Heavier.heavy,
    formula: r'P = \dot{m}gh',
    why:
        'The heavier liquid, by exactly two. Nothing cancels here: the power '
        'is the mass lifted per second times g times the height, so doubling '
        'the mass doubles the power. Mass cancels when it sits on BOTH sides '
        'of an energy balance, and here it only sits on one.',
    source: 'dyn-wep-q2',
  ),
  MassRound(
    subject: 'two balls thrown up at the same speed',
    setting:
        'A light ball and a heavy ball are thrown straight up, both leaving '
        'the hand at fifteen meters a second. Ignore the air.',
    asked: 'Which goes higher?',
    answer: Heavier.tie,
    formula: r'h = \frac{v^2}{2g}',
    why:
        'Neither. The same cancelling as the ramp, upside down: the heavy ball '
        'has more energy to spend and needs more of it for every meter it '
        'climbs. Notice how often this happens once friction and air are out '
        'of the picture, and how it stops being true the moment they are '
        'not.',
    source: 'dyn-wep-q1',
  ),
  MassRound(
    subject: 'two blocks against the same spring',
    setting:
        'A light block and a heavy one are pushed against the same spring, '
        'compressed by the same amount, and released on a smooth floor.',
    asked: 'Which leaves the spring faster?',
    answer: Heavier.light,
    formula: r'v = \sqrt{\frac{ks^2}{m}}',
    why:
        'The LIGHT one, and this is the round that breaks the habit. The '
        'spring gives both blocks the same energy, because it was squeezed the '
        'same amount, and that fixed amount buys more speed in a lighter '
        'block. Nothing cancels: the mass is on one side only. Three rounds '
        'tied, one favored the heavy one and one the light one, and the '
        'formula told you which every time.',
    source: 'dyn-wep-q1',
  ),
];

class _DoesTheMassMatterGameState extends State<DoesTheMassMatterGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-the-mass-matter',
    chapterId: 'dynamics',
    total: massRounds.length,
    sourceProblemIdOf: (round) => massRounds[round].source,
  )..addListener(_onSession);

  Heavier? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  MassRound get _round => massRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does the Mass Matter',
        closing:
            'Mass cancels when it sits on both sides of an energy balance: the '
            'speed at the bottom of a ramp, the height of a throw, the '
            'stopping distance under friction. It does not cancel when it sits '
            'on one side only: the energy carried, the power to lift, the '
            'speed a fixed spring can give. Look for it before you compute.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: cancelBrief,
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
            'HEAVY, LIGHT, OR NO DIFFERENCE',
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
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          for (final h in Heavier.values) ...[
            _Choice(
              label: h.plain,
              selected: _picked == h,
              locked: answered,
              isTruth: h == r.answer,
              onTap: answered ? null : () => setState(() => _picked = h),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHAT IT COMES FROM',
                    style: AppTheme.overline(color: AppColors.forest),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: MathText(
                      '\$${r.formula}\$',
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS RIGHT' : 'LOOK AT THE FORMULA',
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
