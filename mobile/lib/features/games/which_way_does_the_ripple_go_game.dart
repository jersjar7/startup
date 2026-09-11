import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'flow_figures.dart';

/// Which Way Does the Ripple Go — the first item for `energy-critical-flow`.
///
/// The Froude number is a ratio of two speeds: how fast the water is moving
/// against how fast a ripple can travel over it. Written that way the whole
/// of subcritical and supercritical stops being vocabulary. If the ripple is
/// quicker than the water, news can reach upstream and the flow is
/// subcritical. If the water is quicker, nothing gets back up and the flow
/// is supercritical. The lesson's own trap is getting the number right and
/// the label wrong, which is what happens when the label is memorized
/// instead of understood.
class WhichWayDoesTheRippleGoGame extends StatefulWidget {
  const WhichWayDoesTheRippleGoGame({super.key});

  @override
  State<WhichWayDoesTheRippleGoGame> createState() =>
      _WhichWayDoesTheRippleGoGameState();
}

/// What becomes of the ring the stone made.
enum Ring { upstream, downstream, standsStill }

extension RingWords on Ring {
  String get plain => switch (this) {
        Ring.upstream => 'It works its way upstream',
        Ring.downstream => 'It is swept downstream',
        Ring.standsStill => 'Its upstream edge stands still',
      };

  String get regime => switch (this) {
        Ring.upstream => 'subcritical',
        Ring.downstream => 'supercritical',
        Ring.standsStill => 'critical',
      };
}

@immutable
class RingRound {
  const RingRound({
    required this.subject,
    required this.flume,
    required this.why,
    required this.source,
  });

  final String subject;
  final Flume flume;
  final String why;
  final String source;

  /// Read off the two speeds on the drawing, never declared.
  Ring get answer {
    if (flume.isCritical) return Ring.standsStill;
    return flume.isFast ? Ring.downstream : Ring.upstream;
  }
}

const ringRounds = <RingRound>[
  RingRound(
    subject: 'the lesson\'s own flow',
    flume: Flume(unitFlow: 2, depth: 0.5),
    why:
        'Swept downstream. The water is moving at 4 meters a second and a '
        'ripple can only manage 2.2, so nothing the stone did ever gets back '
        'upstream. That ratio, 4 over 2.2, IS the Froude number of 1.81, and '
        'because it is bigger than one the flow is supercritical. This is the '
        'lesson\'s own problem, and its trap is computing 1.81 correctly and '
        'then calling it subcritical.',
    source: 'wr-ecf-q2',
  ),
  RingRound(
    subject: 'a deep canal',
    flume: Flume(unitFlow: 9, depth: 3),
    why:
        'Upstream. Three meters of water carries a ripple at 5.4 meters a '
        'second and the flow itself is only doing 3, so the ring spreads '
        'against the current and news travels up the channel. That is what '
        'subcritical means and it is why a gate or a weir downstream can be '
        'felt for a long way upstream: in tranquil flow, the channel knows '
        'what is coming.',
    source: 'wr-ecf-q1',
  ),
  RingRound(
    subject: 'the critical depth from the lesson',
    flume: Flume(unitFlow: 9, depth: 2.02),
    why:
        'Its upstream edge stands still. The water and the ripple are both '
        'moving at about 4.45 meters a second, so the upstream side of the '
        'ring is running exactly as fast as the current is carrying it back, '
        'and it hangs in one place. That is critical flow, Froude equal to '
        'one, and 2.02 meters is the critical depth this lesson computes for '
        'a unit flow of 9.',
    source: 'wr-ecf-q1',
  ),
  RingRound(
    subject: 'a shallow trickle',
    flume: Flume(unitFlow: 1, depth: 0.8),
    why:
        'Upstream, comfortably. Shallow does not mean supercritical: what '
        'matters is the depth against the SPEED, and at 1.25 meters a second '
        'over water that carries ripples at 2.8, this flow is well inside '
        'subcritical. Most natural streams are, and so is most of what a '
        'storm sewer does on an ordinary day.',
    source: 'wr-ecf-q2',
  ),
  RingRound(
    subject: 'the same canal flow, running thin',
    flume: Flume(unitFlow: 9, depth: 1.2),
    why:
        'Swept downstream. Same 9 square meters a second as the deep canal, '
        'but squeezed into 1.2 meters of depth it has to move at 7.5 meters a '
        'second, well past the 3.4 a ripple manages. This is the pair worth '
        'holding on to: one flow rate can be either regime, and the depth is '
        'what decides which.',
    source: 'wr-ecf-q1',
  ),
  RingRound(
    subject: 'a chute below a spillway',
    flume: Flume(unitFlow: 6, depth: 1),
    why:
        'Swept downstream, at nearly twice the ripple speed. Spillways and '
        'steep chutes are where supercritical flow actually lives, and it is '
        'why a jump has to be built at the bottom of one: the fast shallow '
        'sheet has to be turned back into ordinary tranquil flow before it '
        'reaches the river, and the only thing that does that is a jump.',
    source: 'wr-ecf-q2',
  ),
];

class _WhichWayDoesTheRippleGoGameState
    extends State<WhichWayDoesTheRippleGoGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-does-the-ripple-go',
    chapterId: 'water-resources',
    total: ringRounds.length,
    sourceProblemIdOf: (round) => ringRounds[round].source,
  )..addListener(_onSession);

  Ring? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RingRound get _round => ringRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way Does the Ripple Go',
        closing:
            'The Froude number is the water speed divided by the ripple '
            'speed, and the ripple speed is set by the depth alone. Below one '
            'the flow is subcritical and a disturbance can travel upstream, '
            'so what happens downstream is felt above it. Above one it is '
            'supercritical and nothing gets back up. At exactly one the '
            'upstream edge of a ring stands still, and that is critical '
            'depth.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: froudeBrief,
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
            'A STONE GOES IN. WHAT HAPPENS TO THE RING',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          const Text(
            'The two arrows are drawn to the same scale: how fast the water '
            'is moving, and how fast a ripple travels over water of this '
            'depth.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 230,
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
                  painter:
                      RipplePainter(flume: r.flume, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$Fr = \dfrac{v}{\sqrt{g y}}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Ring.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Ring.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? 'YES, THIS IS ${r.answer.regime.toUpperCase()} FLOW'
                  : 'IT IS ${r.answer.regime.toUpperCase()} FLOW',
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
