import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'compaction_figures.dart';
import 'lesson_brief.dart';

/// Lime or Cement — the third item for `compaction-stabilization`.
///
/// When rolling is not enough, the soil gets help, and which help depends on
/// what the soil is. Lime for plastic clays, cement for granular soils, a
/// geosynthetic where the job is separation or reinforcement, and drainage
/// first whenever water is the real complaint.
class LimeOrCementGame extends StatefulWidget {
  const LimeOrCementGame({super.key});

  @override
  State<LimeOrCementGame> createState() => _LimeOrCementGameState();
}

@immutable
class SoilFixRound {
  const SoilFixRound({
    required this.subject,
    required this.asked,
    required this.ground,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Ground ground;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _fatClay =
    Ground(name: 'a swelling clay subgrade', plasticityIndex: 34);
const _siltySand = Ground(name: 'a silty sand subbase', plasticityIndex: 4);
const _wetClay =
    Ground(name: 'a soft clay haul road', plasticityIndex: 26, wet: true);
const _softSubgrade =
    Ground(name: 'soft ground under stone', plasticityIndex: 18);

const soilFixRounds = <SoilFixRound>[
  SoilFixRound(
    subject: 'the swelling clay',
    asked:
        'A high-plasticity clay subgrade is too soft and swells when it gets '
        'wet. Which chemical stabilizer suits it?',
    ground: _fatClay,
    options: [
      'Portland cement on its own',
      'More water, to swell it evenly',
      'Lime',
      'Fly ash used only as a filler',
    ],
    answer: 2,
    why:
        'Lime. It is the classic treatment for a fat clay: it reacts with the '
        'clay minerals, drops the plasticity index, cuts the swelling and '
        'makes the material workable. Cement in a plastic clay struggles to '
        'get mixed through it in the first place.',
    source: 'geo-cmp-q3',
  ),
  SoilFixRound(
    subject: 'what lime actually does',
    asked: 'What does the lime change about the clay?',
    ground: _fatClay,
    options: [
      'It makes the clay heavier',
      'It lowers the plasticity index, so the clay behaves less like a clay',
      'It waterproofs the surface',
      'It replaces the clay with silt',
    ],
    answer: 1,
    why:
        'It changes the clay chemically so that it is less plastic: the '
        'plasticity index comes down, the material stops shrinking and '
        'swelling so much, and it can be worked and compacted. That is a '
        'different kind of help from cement, which glues grains together.',
    source: 'geo-cmp-q3',
  ),
  SoilFixRound(
    subject: 'the other end of the scale',
    asked:
        'A silty sand subbase needs more strength. Which additive is the '
        'usual choice here?',
    ground: _siltySand,
    options: [
      'Cement',
      'Lime',
      'Neither: granular soils cannot be stabilized',
      'Water alone',
    ],
    answer: 0,
    why:
        'Cement, which suits granular and low-plasticity soils. It binds the '
        'grains into something much stiffer. Lime needs clay minerals to '
        'react with, so in a clean or nearly clean sand there is nothing for '
        'it to work on.',
    source: 'geo-cmp-q3',
  ),
  SoilFixRound(
    subject: 'the tempting wrong answer',
    asked:
        'Someone suggests wetting the swelling clay down before compaction. '
        'What would that do?',
    ground: _fatClay,
    options: [
      'Improve it: wet clay compacts more easily',
      'Nothing measurable',
      'Make it worse: water is what the clay swells on',
      'Turn it into a granular soil',
    ],
    answer: 2,
    why:
        'Make it worse. Water is the thing a swelling clay reacts to, and a '
        'soft clay that is already wet gets softer, not stronger. There is a '
        'right amount of water for compaction, from the Proctor curve, and a '
        'plastic clay on a wet site is usually already past it.',
    source: 'geo-cmp-q3',
  ),
  SoilFixRound(
    subject: 'when no additive is the answer',
    asked:
        'Stone base keeps sinking into a soft subgrade and mixing with it. '
        'What is the usual fix?',
    ground: _softSubgrade,
    options: [
      'A geosynthetic between the two, to separate and reinforce',
      'Lime in the stone',
      'Cement in the subgrade only',
      'A thicker stone layer and nothing else',
    ],
    answer: 0,
    why:
        'A geosynthetic. The complaint is not chemistry, it is two materials '
        'mixing: a fabric between them keeps the stone out of the mud and '
        'spreads the load at the same time. Geosynthetics are used for '
        'exactly three things, separation, reinforcement and drainage, and '
        'this is the first of them.',
    source: 'geo-cmp-q3',
  ),
  SoilFixRound(
    subject: 'what to do before anything else',
    asked:
        'A haul road over soft clay softens again after every rain, however '
        'it is treated. What comes first?',
    ground: _wetClay,
    options: [
      'A stronger additive',
      'Heavier compaction equipment',
      'Get the water away from it',
      'Wait for it to dry on its own',
    ],
    answer: 2,
    why:
        'Drainage. Water that keeps coming back will undo any treatment you '
        'pay for, so the ditches and the crossfall come before the chemistry. '
        'It is the least glamorous line in the lesson and the one that saves '
        'the most money.',
    source: 'geo-cmp-q3',
  ),
];

class _LimeOrCementGameState extends State<LimeOrCementGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'lime-or-cement',
    chapterId: 'geotechnical',
    total: soilFixRounds.length,
    sourceProblemIdOf: (round) => soilFixRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  SoilFixRound get _round => soilFixRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Lime or Cement',
        closing:
            'Match the help to the soil. Lime for plastic clays, where it '
            'lowers the plasticity index and stops the swelling. Cement for '
            'granular and low-plasticity soils, where it binds the grains. A '
            'geosynthetic where the job is to separate, reinforce or drain. '
            'And drainage first, whenever water is what keeps coming back.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: stabilizerBrief,
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
            'WHAT THE SOIL NEEDS',
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
            height: 196,
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
                  painter: StabilizerPainter(
                    ground: r.ground,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
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
