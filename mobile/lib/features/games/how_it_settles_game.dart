import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'vibration_figures.dart';

/// How It Settles — the third item for `vibrations-natural-frequency`.
///
/// The damping ratio is three words and one picture each: under one it swings
/// and dies away, at one it comes back fastest without swinging at all, and
/// over one it comes back without swinging and takes longer about it. The
/// lesson gives the three names in a line; what it does not give is the
/// picture, and the picture is what makes them stick.
class HowItSettlesGame extends StatefulWidget {
  const HowItSettlesGame({super.key});

  @override
  State<HowItSettlesGame> createState() => _HowItSettlesGameState();
}

@immutable
class SettleRound {
  const SettleRound({
    required this.subject,
    required this.setting,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What the system is described as doing, in words.
  final String setting;

  /// The three curves on offer, in the order they are drawn.
  final List<Damped> options;

  final Damped answer;
  final String why;
  final String source;
}

const settleRounds = <SettleRound>[
  SettleRound(
    subject: 'a car with worn shock absorbers',
    setting:
        'You push down on the wing and let go. The car bobs up and down a few '
        'times before settling.',
    options: [Damped.critical, Damped.under, Damped.over],
    answer: Damped.under,
    why:
        'Underdamped, the one that swings inside a shrinking envelope. Every '
        'bounce is smaller than the last and the whole thing dies away, but it '
        'crosses the line several times on the way. Worn dampers are exactly '
        'this, and it is why the bounce test tells you they need replacing.',
    source: 'dyn-vib-q1',
  ),
  SettleRound(
    subject: 'a door closer that works properly',
    setting:
        'The door swings shut and stops at the frame without bouncing back, as '
        'quickly as it can manage without overshooting.',
    options: [Damped.over, Damped.critical, Damped.under],
    answer: Damped.critical,
    why:
        'Critically damped, and the definition is in the description: back to '
        'where it belongs in the shortest time that involves no overshoot at '
        'all. It is the borderline case, the damping ratio exactly one, and it '
        'is what a door closer, a gun recoil and a good instrument needle are '
        'all tuned to.',
    source: 'dyn-vib-q1',
  ),
  SettleRound(
    subject: 'a door closer screwed down too tight',
    setting:
        'The door creeps shut slowly and never bounces at all. It takes '
        'noticeably longer than it needs to.',
    options: [Damped.under, Damped.over, Damped.critical],
    answer: Damped.over,
    why:
        'Overdamped. No swing, like the critical case, but sluggish about it: '
        'more damping past the critical point does NOT get you back faster, it '
        'gets you back slower. That is the piece people expect to go the other '
        'way, and the two curves side by side show it plainly.',
    source: 'dyn-vib-q1',
  ),
  SettleRound(
    subject: 'a tall building after a gust',
    setting:
        'The top of the building sways back and forth for a couple of minutes '
        'after a gust, each swing a little smaller than the one before.',
    options: [Damped.under, Damped.none, Damped.critical],
    answer: Damped.under,
    why:
        'Underdamped, and almost every structure is: real buildings have '
        'damping ratios of a few percent, so they ring for a long time. That '
        'is precisely why a tuned mass damper gets added to a tall tower, to '
        'push that ratio up and shorten the ringing. The swings getting '
        'smaller is what rules out the curve beside it that never shrinks.',
    source: 'dyn-vib-q1',
  ),
  SettleRound(
    subject: 'the fastest way back',
    setting:
        'Of these three systems, all pulled the same distance aside and let '
        'go, one returns and stays put sooner than the others.',
    options: [Damped.over, Damped.critical, Damped.under],
    answer: Damped.critical,
    why:
        'The critically damped one, which is what makes the word critical '
        'worth having. More damping is slower and less damping overshoots and '
        'has to come back again, so the shortest honest settling time sits '
        'exactly on the boundary between the two behaviors.',
    source: 'dyn-vib-q1',
  ),
  SettleRound(
    subject: 'a system with no damping at all',
    setting:
        'An ideal spring and mass with nothing to rub or resist, pulled aside '
        'and released. It swings forever without shrinking.',
    options: [Damped.critical, Damped.none, Damped.under],
    answer: Damped.none,
    why:
        'The curve that keeps the same height forever. Damping ratio zero sits '
        'at the far end of the underdamped family rather than being a fourth '
        'kind of behavior, and the tell is the envelope: an underdamped swing '
        'shrinks and this one does not. Every free vibration formula on this '
        'page, the natural frequency included, is written for exactly this '
        'undamped ideal, which is why the exam asks for it and real life '
        'never quite delivers it.',
    source: 'dyn-vib-q1',
  ),
];

class _HowItSettlesGameState extends State<HowItSettlesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-it-settles',
    chapterId: 'dynamics',
    total: settleRounds.length,
    sourceProblemIdOf: (round) => settleRounds[round].source,
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

  SettleRound get _round => settleRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How It Settles',
        closing:
            'Under one it swings and dies away, which is nearly every real '
            'structure. At one it comes back fastest without swinging, which '
            'is what a door closer is tuned to. Over one it still does not '
            'swing and it takes LONGER, which is the part that surprises '
            'people: more damping past critical is slower, not quicker.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: dampingBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: r.options[_picked!] == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP THE CURVE THAT MATCHES',
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
          for (var i = 0; i < r.options.length; i++) ...[
            _Panel(
              damped: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.options[i] == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          if (_picked != null && !answered) ...[
            Text(
              r.options[_picked!].plain,
              style: AppTheme.mono(size: 12, color: AppColors.ember),
            ),
            const SizedBox(height: 8),
          ],
          Center(
            child: MathText(
              r'$\zeta = \dfrac{c}{2\sqrt{km}}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT CURVE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.damped,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Damped damped;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color tone;
    if (locked && isTruth) {
      border = AppColors.forest;
      tone = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      tone = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      tone = AppColors.ember;
    } else {
      border = AppColors.line;
      tone = AppColors.info;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: SettlePainter(damped: damped, tone: tone),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
