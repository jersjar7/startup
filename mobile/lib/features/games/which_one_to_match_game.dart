import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'model_figures.dart';

/// Which One to Match — the first item for `dimensional-analysis-similitude`.
///
/// The lesson's two similitude problems differ only in which number is being
/// held equal, and the choice is not a matter of taste: it follows from what
/// is shaping the flow. A free water surface means gravity is doing the
/// shaping, and gravity is what the Froude number carries. No free surface
/// means gravity has nothing to pull against and viscosity is what is left,
/// which is the Reynolds number. Reading a rig for its water surface settles
/// it in a second, and the lesson names picking the wrong one as a trap on
/// both problems.
class WhichOneToMatchGame extends StatefulWidget {
  const WhichOneToMatchGame({super.key});

  @override
  State<WhichOneToMatchGame> createState() => _WhichOneToMatchGameState();
}

@immutable
class BenchRound {
  const BenchRound({
    required this.subject,
    required this.setting,
    required this.bench,
    required this.caption,
    required this.scale,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Bench bench;
  final String caption;

  /// How many times the real thing the model is. One means it is not a
  /// model at all, and then the question answers itself.
  final double scale;

  final String why;
  final String source;

  /// Worked out from the rig rather than declared beside it: a free surface
  /// means gravity governs, and a full size test asks the same speed of
  /// either number.
  Law get answer {
    if (scale == 1) return Law.either;
    return bench.hasSurface ? Law.froude : Law.reynolds;
  }
}

const benchRounds = <BenchRound>[
  BenchRound(
    subject: 'a spillway at one in twenty five',
    setting:
        'A dam spillway built at 1:25 in a hydraulics lab, with the water '
        'running over the crest and down the face in the open.',
    bench: Bench.openChannel,
    caption: 'a spillway crest and its chute',
    scale: 25,
    why:
        'Froude. The shape of this flow is set by water falling: the depth '
        'over the crest, where it springs clear, where it lands. All of that '
        'is gravity against momentum, and that ratio is the Froude number. '
        'Viscosity is along for the ride. This is the lesson\'s own problem, '
        'and its answer of 2 meters a second for a 10 meter a second '
        'prototype comes straight out of holding Froude equal.',
    source: 'fm-das-q2',
  ),
  BenchRound(
    subject: 'a valve on a test bench',
    setting:
        'A butterfly valve for a pumping main, tested at quarter size in a '
        'closed loop that runs full of water at all times.',
    bench: Bench.closedPipe,
    caption: 'a valve in a closed loop',
    scale: 4,
    why:
        'Reynolds. There is no water surface anywhere in a closed loop, so '
        'gravity has nothing to shape: raise the whole rig a story and '
        'nothing about the flow through the valve changes. What is left '
        'deciding the pattern is viscosity against momentum, which is the '
        'Reynolds number, and it is the one that has to match.',
    source: 'fm-das-q3',
  ),
  BenchRound(
    subject: 'a pipeline on the sea bed',
    setting:
        'A submerged pipeline at 1:10, sitting well below the surface with a '
        'current running past it.',
    bench: Bench.submerged,
    caption: 'a pipeline under a current',
    scale: 10,
    why:
        'Reynolds, and this is the lesson\'s own second problem. There is a '
        'water surface in the picture, but the pipeline is nowhere near it '
        'and is making no waves, so gravity is not shaping anything. Drag on '
        'a submerged body is a viscous question. The awkward part is what '
        'Reynolds then asks of the model, which is the next item.',
    source: 'fm-das-q3',
  ),
  BenchRound(
    subject: 'a river reach with bridge piers',
    setting:
        'A stretch of river built at 1:60 on a laboratory floor, with piers '
        'in it and the water surface open to the room.',
    bench: Bench.openChannel,
    caption: 'a river reach and its piers',
    scale: 60,
    why:
        'Froude. Everything anyone builds a river model to see is a surface '
        'effect: the backwater upstream of the piers, the drawdown between '
        'them, where the scour starts. Those are gravity waves on an open '
        'surface, so Froude is what has to match, and the model runs slower '
        'than the river does.',
    source: 'fm-das-q2',
  ),
  BenchRound(
    subject: 'the pump itself, not a model of it',
    setting:
        'A pump is put on a closed test loop at full size, 1:1, in the same '
        'water it will handle in service.',
    bench: Bench.closedPipe,
    caption: 'full size, in the same water',
    scale: 1,
    why:
        'Either, because at full size in the same fluid both numbers ask for '
        'exactly the same thing: run it at the speed it will run at in '
        'service. The whole business of choosing a law is about what you '
        'give up when the model is a different size. At 1:1 you give up '
        'nothing and there is nothing to choose.',
    source: 'fm-das-q3',
  ),
  BenchRound(
    subject: 'a bridge deck in a wind tunnel',
    setting:
        'A 1:50 section of a bridge deck in a wind tunnel, with air blown '
        'past it.',
    bench: Bench.tunnel,
    caption: 'a deck section in moving air',
    scale: 50,
    why:
        'Reynolds. Air has no free surface in a tunnel, so there is no '
        'gravity wave to get right, and the thing being looked for is where '
        'the air separates off the deck edges. That is viscous, and Reynolds '
        'governs it. It is the same reasoning as the closed loop: look for '
        'the surface first, and when there is not one, stop looking for '
        'Froude.',
    source: 'fm-das-q3',
  ),
];

class _WhichOneToMatchGameState extends State<WhichOneToMatchGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-to-match',
    chapterId: 'fluid-mechanics',
    total: benchRounds.length,
    sourceProblemIdOf: (round) => benchRounds[round].source,
  )..addListener(_onSession);

  Law? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  BenchRound get _round => benchRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One to Match',
        closing:
            'Look for the free surface. If the water has one and the thing '
            'you care about happens at it, gravity is shaping the flow and '
            'Froude has to match: spillways, weirs, rivers, hulls. If there '
            'is no surface in it, viscosity is what is left and Reynolds has '
            'to match: pipe fittings, valves, submerged bodies, wind '
            'tunnels. At full size the question does not arise.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: similitudeBrief,
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
            'WHICH NUMBER HAS TO MATCH',
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
            height: 150,
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
                  painter: BenchPainter(bench: r.bench, caption: r.caption),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MathText(
                r'$Re = \frac{\rho v l}{\mu}$',
                style: const TextStyle(fontSize: 15, color: AppColors.ink2),
              ),
              MathText(
                r'$Fr = \frac{v}{\sqrt{gl}}$',
                style: const TextStyle(fontSize: 15, color: AppColors.ink2),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final option in Law.values) ...[
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
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER ONE',
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
