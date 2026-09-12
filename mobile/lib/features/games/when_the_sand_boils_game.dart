import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'seepage_figures.dart';

/// When the Sand Boils — the second item for `permeability-seepage`.
///
/// Water seeping upward drags the grains with it, and when the drag matches
/// the buoyant weight of the sand the grains stop pressing on each other
/// altogether. That gradient is close to one for almost every sand, which is
/// what makes a quick condition such a real risk: it does not take anything
/// exotic, only a head difference of about the depth of the ground it has to
/// climb through.
class WhenTheSandBoilsGame extends StatefulWidget {
  const WhenTheSandBoilsGame({super.key});

  @override
  State<WhenTheSandBoilsGame> createState() => _WhenTheSandBoilsGameState();
}

@immutable
class BoilRound {
  const BoilRound({
    required this.subject,
    required this.asked,
    required this.quick,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Quick quick;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _lessonSand = Quick(gs: 2.70, voidRatio: 0.85, exitGradient: 0.45);
const _onTheEdge = Quick(gs: 2.70, voidRatio: 0.85, exitGradient: 0.92);
const _looseSand = Quick(gs: 2.65, voidRatio: 1.20, exitGradient: 0.50);

const boilRounds = <BoilRound>[
  BoilRound(
    subject: 'what a quick condition is',
    asked:
        'Water seeps upward through a sand until it boils. What has happened '
        'to the sand?',
    quick: _onTheEdge,
    options: [
      'The upward drag carries the grains, so they press on each other not '
          'at all',
      'The sand has dissolved into the water',
      'The water has washed the fine grains out',
      'The sand has reached its liquid limit',
    ],
    answer: 0,
    why:
        'The effective stress has gone to zero. Water climbing through the '
        'sand drags on every grain, and when that drag matches what the '
        'grains weigh under water there is nothing left pressing them '
        'together. A sand with no effective stress has no strength either, '
        'since its whole strength came from friction, so it behaves like a '
        'heavy liquid.',
    source: 'geo-seep-q2',
  ),
  BoilRound(
    subject: 'the lesson\'s own sand',
    asked:
        'A sand with a specific gravity of 2.70 and a void ratio of 0.85. '
        'What is its critical gradient?',
    quick: _lessonSand,
    options: [
      'About 0.92: the specific gravity less one, over one plus the void '
          'ratio',
      'Exactly 1.00, as it is for every sand',
      '1.85, which is one plus the void ratio',
      '0.54, the void ratio over the specific gravity',
    ],
    answer: 0,
    why:
        'About 0.92. It is close to one, as it nearly always is, but it is '
        'not one: this sand boils at a gradient a little under unity. The '
        'lesson offers exactly 1.00 as a choice because the habit of '
        'assuming it is a fair approximation for a rule of thumb and a wrong '
        'answer for a question.',
    source: 'geo-seep-q2',
  ),
  BoilRound(
    subject: 'why it is always near one',
    asked:
        'Why does the critical gradient come out near one for almost every '
        'sand?',
    quick: _lessonSand,
    options: [
      'Because the buoyant weight of soil is close to the weight of water',
      'Because water is incompressible',
      'Because sands all have the same void ratio',
      'Because the gradient cannot be larger than one',
    ],
    answer: 0,
    why:
        'Because the critical gradient IS the buoyant unit weight over the '
        'unit weight of water, and for ordinary soils those two are close: '
        'grains about 2.7 times the density of water with about as much void '
        'as solid. So the number lands near one whatever the sand, and that '
        'is exactly why quick conditions are a practical danger rather than '
        'a curiosity.',
    source: 'geo-seep-q2',
  ),
  BoilRound(
    subject: 'a looser sand',
    asked:
        'A looser sand, void ratio 1.20 instead of 0.85. What happens to the '
        'gradient it boils at?',
    quick: _looseSand,
    options: [
      'It falls: a looser sand boils more easily',
      'It rises: more void means more resistance',
      'Nothing: only the specific gravity matters',
      'It doubles, along with the void ratio',
    ],
    answer: 0,
    why:
        'It falls, to about 0.75. A loose sand has less solid in a given '
        'volume, so its buoyant weight is smaller and it takes less upward '
        'drag to carry it. Loose saturated sands are the ones that boil, '
        'liquefy and run, and their looseness is exactly the reason.',
    source: 'geo-seep-q2',
  ),
  BoilRound(
    subject: 'how safe is safe',
    asked:
        'The exit gradient at the downstream side is 0.45 and the critical '
        'gradient is 0.92. What is the factor of safety against piping?',
    quick: _lessonSand,
    options: [
      'About two: the critical gradient over the exit gradient',
      'About half: the exit gradient over the critical one',
      '0.47, the difference between them',
      'There is none, since the exit gradient is below one',
    ],
    answer: 0,
    why:
        'About two, the critical over the actual. It is the same shape as '
        'every other factor of safety: what it would take to fail, over what '
        'it is being asked to do. Two is a fair number for this; anything '
        'approaching one means the downstream side is close to boiling and '
        'needs a filter, a longer path, or a weight on top.',
    source: 'geo-seep-q2',
  ),
  BoilRound(
    subject: 'what to do about it',
    asked:
        'A design comes out with an exit gradient uncomfortably close to the '
        'critical one. What helps?',
    quick: _onTheEdge,
    options: [
      'Make the water travel further, by driving the sheet pile deeper',
      'Use a more permeable sand',
      'Raise the water on the upstream side',
      'Nothing: the gradient is fixed by the soil',
    ],
    answer: 0,
    why:
        'Lengthen the path. The exit gradient is the head divided by the '
        'distance the water has to travel to get out, so driving the pile '
        'deeper spends the same head over a longer way and the gradient '
        'falls. Raising the upstream water does the opposite. A filter blanket '
        'on the downstream side is the other classic answer: it adds weight '
        'where the water comes out without blocking it.',
    source: 'geo-seep-q2',
  ),
];

class _WhenTheSandBoilsGameState extends State<WhenTheSandBoilsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'when-the-sand-boils',
    chapterId: 'geotechnical',
    total: boilRounds.length,
    sourceProblemIdOf: (round) => boilRounds[round].source,
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

  BoilRound get _round => boilRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'When the Sand Boils',
        closing:
            'Upward seepage drags on every grain, and when the drag matches '
            'what the grains weigh under water the effective stress reaches '
            'zero and the sand has no strength left. That gradient is the '
            'buoyant weight over the weight of water, which lands near one '
            'for almost any sand and lower for a loose one. The safety factor '
            'is critical over actual, and the fix is a longer path for the '
            'water or weight where it comes out.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: quickBrief,
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
            'WHEN THE GRAINS LET GO',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 202,
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
                  painter: BoilPainter(quick: r.quick, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r"$i_c = \frac{\gamma'}{\gamma_w} = \frac{G_s - 1}{1 + e}$",
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Choice(
              label: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != r.options.length - 1) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
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
