import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'friction_figures.dart';
import 'lesson_brief.dart';

/// Will It Hold Itself — the fourth item for `friction`.
///
/// The lesson's third topic is the screw jack and the other three items never
/// touch it. Its formula carries a plus or a minus depending on whether you
/// are raising the load or lowering it, and underneath that sign sits the
/// thing that actually matters on site: whether the screw is SELF-LOCKING. A
/// jack whose thread is shallower than its friction angle stays where you left
/// it. One whose thread is steeper runs back down the moment you let go, which
/// is the difference between a car on a jack and a car on the floor.
///
/// So no arithmetic. Unwrap one turn of the thread and it is a ramp; the
/// friction angle is the steepest ramp that surface could hold on. Both are
/// drawn on one baseline and the steeper one decides.
class WillItHoldItselfGame extends StatefulWidget {
  const WillItHoldItselfGame({super.key});

  @override
  State<WillItHoldItselfGame> createState() => _WillItHoldItselfGameState();
}

@immutable
class ScrewRound {
  const ScrewRound({
    required this.subject,
    required this.setting,
    required this.screw,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Screw screw;
  final String why;
  final String source;

  /// Worked out by comparing the thread angle with the friction angle, never
  /// declared beside the round.
  Effort get answer => screw.effort;
}

const screwRounds = <ScrewRound>[
  ScrewRound(
    subject: 'raising a car on a jack',
    setting:
        'A scissor jack with a fine thread under a car. You are winding the '
        'handle to lift it.',
    screw: Screw(pitchDeg: 3, mu: 0.15, raising: true),
    why:
        'You drive it up, and raising always takes work whatever the thread is '
        'like. This is the round where the sign in the formula is a plus: the '
        'friction angle is ADDED to the thread angle, because friction and '
        'gravity are both against you on the way up.',
    source: 'stat-fri-q1',
  ),
  ScrewRound(
    subject: 'letting the same car down',
    setting:
        'The same jack under the same car. Now you want it back on the ground, '
        'so you wind the handle the other way.',
    screw: Screw(pitchDeg: 3, mu: 0.15, raising: false),
    why:
        'You drive it down too. The thread is far shallower than the friction '
        'angle, so the screw is self-locking and the car is not coming down '
        'until you make it. That is not a nuisance, it is the entire reason it '
        'is safe to be under the car at all.',
    source: 'stat-fri-q1',
  ),
  ScrewRound(
    subject: 'a coarse screw with a load on it',
    setting:
        'A steep, quick-acting thread built for speed rather than grip, on a '
        'clean dry surface. The load is being lowered.',
    screw: Screw(pitchDeg: 15, mu: 0.10, raising: false),
    why:
        'Hold it back. The thread is steeper than the friction angle, so the '
        'load drives the screw down all by itself and your job on the handle is '
        'to stop it running away. A coarse thread moves a load quickly and '
        'will not hold it, which is a fair trade as long as you knew about it.',
    source: 'stat-fri-q1',
  ),
  ScrewRound(
    subject: 'raising with that same coarse screw',
    setting: 'The same quick thread, the same surface, going up this time.',
    screw: Screw(pitchDeg: 15, mu: 0.10, raising: true),
    why:
        'Drive it up. Going up is always work, and this thread being steep '
        'makes it harder work per turn than a fine one, though it gets there '
        'in fewer turns. Which way the sign goes depends only on the '
        'direction of travel. What happens when you let go depends on the two '
        'angles.',
    source: 'stat-fri-q1',
  ),
  ScrewRound(
    subject: 'a fine thread, freshly greased',
    setting:
        'A fine thread much like the jack in the first round, but this one has '
        'been greased and the friction is now very low. Lowering.',
    screw: Screw(pitchDeg: 4, mu: 0.05, raising: false),
    why:
        'Hold it back, and this is the round worth remembering. The thread is '
        'shallow and it still is not self-locking, because greasing it dropped '
        'the friction angle below the thread angle. Self-locking is not a '
        'property of the thread on its own. Grease a jack and you can make it '
        'unsafe without changing a single dimension.',
    source: 'stat-fri-q1',
  ),
  ScrewRound(
    subject: 'releasing a bench vice',
    setting:
        'The screw of a workshop vice, cut fine and running dry on cast iron. '
        'You are backing it off to release the work.',
    screw: Screw(pitchDeg: 2.5, mu: 0.20, raising: false),
    why:
        'You drive it down. The friction angle is several times the thread '
        'angle here, so the vice holds whatever you set it to and will not '
        'shake loose. Every screw fastener in the world is built the same way, '
        'and it is why a bolt stays done up.',
    source: 'stat-fri-q1',
  ),
];

class _WillItHoldItselfGameState extends State<WillItHoldItselfGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'will-it-hold-itself',
    chapterId: 'statics',
    total: screwRounds.length,
    sourceProblemIdOf: (round) => screwRounds[round].source,
  )..addListener(_onSession);

  Effort? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ScrewRound get _round => screwRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Will It Hold Itself',
        closing:
            'Raising a load is always work and the friction angle is added on. '
            'Lowering is the interesting one: if the thread is shallower than '
            'the friction angle the screw is self-locking and you have to '
            'drive it down, and if it is steeper the load runs away and you '
            'have to hold it. Compare the two angles before anything else.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: screwBrief,
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
            'WHAT DOES THE HANDLE HAVE TO DO',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 240,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: ScrewPainter(screw: r.screw, showWinner: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Effort.values) ...[
            _EffortButton(
              key: ValueKey('effort-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Effort.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE JOB' : 'SOMETHING ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _EffortButton extends StatelessWidget {
  const _EffortButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Effort option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Effort.driveItUp: 'Drive it up',
    Effort.driveItDown: 'Drive it down',
    Effort.holdItBack: 'Hold it back',
  };

  static const _notes = {
    Effort.driveItUp: 'raising is always work',
    Effort.driveItDown: 'self-locking, so it will not come down on its own',
    Effort.holdItBack: 'the load is driving the screw down by itself',
  };

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
          width: double.infinity,
          height: 58,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _titles[option]!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _notes[option]!,
                style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
