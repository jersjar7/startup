import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'fluid_figures.dart';
import 'lesson_brief.dart';

/// Float or Sink — the second item for `hydrostatic-forces-buoyancy`.
///
/// Archimedes is two numbers held against each other: the weight of the thing
/// and the weight of the water it shoves aside. The lesson's problem asks for
/// the net force and offers the right size pointing the wrong way, the push
/// on its own, and the weight on its own. So the rounds ask only which way
/// the body goes, and the arrows are drawn after the answer rather than
/// before it.
class FloatOrSinkGame extends StatefulWidget {
  const FloatOrSinkGame({super.key});

  @override
  State<FloatOrSinkGame> createState() => _FloatOrSinkGameState();
}

/// Which way the body is pushed.
enum Goes2 { up, down, still }

extension GoesWords2 on Goes2 {
  String get plain => switch (this) {
        Goes2.up => 'Up: it rises and floats',
        Goes2.down => 'Down: it sinks',
        Goes2.still => 'Neither: it hangs where it is',
      };
}

@immutable
class FloatRound {
  const FloatRound({
    required this.subject,
    required this.setting,
    required this.lump,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Lump lump;
  final String why;
  final String source;

  /// Worked out from the two forces, never declared.
  Goes2 get answer {
    if (lump.floats) return Goes2.up;
    if (lump.sinks) return Goes2.down;
    return Goes2.still;
  }
}

const floatRounds = <FloatRound>[
  FloatRound(
    subject: 'the lesson\'s hollow tank',
    setting:
        'A hollow steel tank of two cubic meters, weighing 15 kilonewtons, '
        'held under water and let go.',
    lump: Lump(volume: 2, weight: 15),
    why:
        'Up. Two cubic meters of water weigh about 19.6 kilonewtons and the '
        'tank weighs 15, so the water wins by 4.6 and the tank rises. Notice '
        'what did NOT matter: the specific weight of the steel. Buoyancy '
        'counts the volume the body shoves aside, hollow or solid.',
    source: 'fm-hfb-q3',
  ),
  FloatRound(
    subject: 'the same tank, filled with water',
    setting:
        'The same tank, still two cubic meters on the outside, but flooded '
        'through a split seam. It now weighs 34 kilonewtons.',
    lump: Lump(volume: 2, weight: 34),
    why:
        'Down. The push has not changed, because the tank still shoves aside '
        'the same two cubic meters, but it is now far heavier than the water '
        'it displaces. This is exactly how a ship sinks: nothing about the '
        'hull changed, only what is inside it.',
    source: 'fm-hfb-q3',
  ),
  FloatRound(
    subject: 'an empty tank in saturated ground',
    setting:
        'A buried tank of four cubic meters weighing 22 kilonewtons, with the '
        'water table risen above it.',
    lump: Lump(volume: 4, weight: 22, name: 'the buried tank'),
    why:
        'Up, by about 17 kilonewtons, and this is a real failure that happens '
        'on real sites: an empty tank floats out of wet ground and lifts the '
        'slab with it. It is why empty tanks get held down with straps or '
        'ballast, and why nobody empties one during a wet winter without '
        'checking first.',
    source: 'fm-hfb-q3',
  ),
  FloatRound(
    subject: 'weighing exactly what it displaces',
    setting:
        'A sealed instrument float of half a cubic meter, trimmed with lead '
        'until it weighs 4.905 kilonewtons.',
    lump: Lump(volume: 0.5, weight: 4.905, name: 'the float'),
    why:
        'Neither: it hangs wherever you leave it. Half a cubic meter of water '
        'weighs 4.905 kilonewtons, so the two forces are exactly equal and '
        'nothing is left over. A submarine trims to this on purpose, and it '
        'is what neutral buoyancy means.',
    source: 'fm-hfb-q3',
  ),
  FloatRound(
    subject: 'a solid block of steel',
    setting:
        'A solid steel block of a tenth of a cubic meter, weighing 7.7 '
        'kilonewtons.',
    lump: Lump(volume: 0.1, weight: 7.7, name: 'the block'),
    why:
        'Down, and hard. A tenth of a cubic meter of water weighs about one '
        'kilonewton against the block\'s 7.7, so the water barely slows it. '
        'Steel is roughly eight times the weight of water for the same '
        'volume, which is why a steel BOX can float and a steel BLOCK cannot: '
        'the box shoves aside far more water for the same steel.',
    source: 'fm-hfb-q3',
  ),
  FloatRound(
    subject: 'a barge under load',
    setting:
        'A loaded barge hull weighing 117.72 kilonewtons, which shoves aside '
        'twelve cubic meters when it is pushed right under. Held down there '
        'and let go.',
    lump: Lump(volume: 12, weight: 117.72, name: 'the barge'),
    why:
        'Neither, and that is what floating IS. Held under, this hull '
        'displaces exactly its own weight, so nothing is left over to move it '
        'either way. A boat on the surface has arranged the same balance for '
        'itself: it settles until the water it has shoved aside weighs what '
        'it does, and then stops. Load it more and it settles deeper until '
        'the two match again.',
    source: 'fm-hfb-q3',
  ),
];

class _FloatOrSinkGameState extends State<FloatOrSinkGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'float-or-sink',
    chapterId: 'fluid-mechanics',
    total: floatRounds.length,
    sourceProblemIdOf: (round) => floatRounds[round].source,
  )..addListener(_onSession);

  Goes2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FloatRound get _round => floatRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Float or Sink',
        closing:
            'Two numbers: what the body weighs, and what the water it shoves '
            'aside weighs. Bigger push and it rises, bigger weight and it '
            'sinks, equal and it hangs. Only the DISPLACED volume counts, so '
            'a hollow box and a solid block of the same steel behave nothing '
            'alike, and an empty buried tank will lift itself out of wet '
            'ground.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: buoyancyBrief,
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
            'WHICH WAY DOES IT GO',
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
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: CustomPaint(
                painter: LumpPainter(lump: r.lump, showForces: answered),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answered
                ? 'the two arrows are drawn to one scale'
                : 'the arrows go on once you answer: their lengths are the '
                    'answer',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$F_B = \gamma V_{displaced}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Goes2.values) ...[
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
