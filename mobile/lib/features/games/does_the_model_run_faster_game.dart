import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'model_figures.dart';

/// Does the Model Run Faster — the second item for
/// `dimensional-analysis-similitude`.
///
/// Once the law is settled, it says what speed the model runs at, and the
/// two laws pull in opposite directions. Froude has the speed on the square
/// root of the length, so a small model runs SLOWER. Reynolds has the speed
/// multiplying the length, so a small model must run FASTER, and by the full
/// ratio: a tenth the size is ten times the speed. The lesson names both
/// mix-ups as traps, and the second one is why Reynolds models of small
/// things are so often impossible to build.
class DoesTheModelRunFasterGame extends StatefulWidget {
  const DoesTheModelRunFasterGame({super.key});

  @override
  State<DoesTheModelRunFasterGame> createState() =>
      _DoesTheModelRunFasterGameState();
}

/// Where the model's speed sits against the real thing's.
enum Runs2 { faster, slower, same }

extension Runs2Words on Runs2 {
  String get plain => switch (this) {
        Runs2.faster => 'Faster than the real thing',
        Runs2.slower => 'Slower than the real thing',
        Runs2.same => 'The same speed',
      };
}

@immutable
class TwinRound {
  const TwinRound({
    required this.subject,
    required this.setting,
    required this.twins,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Twins twins;
  final String why;
  final String source;

  /// Worked out from the law and the two sizes, never declared.
  Runs2 get answer {
    final r = twins.ratio;
    if ((r - 1).abs() < 0.001) return Runs2.same;
    return r > 1 ? Runs2.faster : Runs2.slower;
  }
}

const twinRounds = <TwinRound>[
  TwinRound(
    subject: 'the spillway, on Froude',
    setting:
        'The 1:25 spillway model, run to match the Froude number. The '
        'prototype carries 10 meters a second.',
    twins: Twins(law: Law.froude, model: 1, proto: 25),
    why:
        'Slower, at 2 meters a second. Froude puts the speed over the square '
        'root of the length, so the speed scales as the square root of the '
        'size: a twenty fifth the size is a fifth the speed. That is the '
        'lesson\'s own answer, and its named trap is dividing by 25 instead '
        'of by 5, which gives 0.4.',
    source: 'fm-das-q2',
  ),
  TwinRound(
    subject: 'the pipeline, on Reynolds',
    setting:
        'The 1:10 submerged pipeline, run to match the Reynolds number in '
        'the same water. The current past the real one is 3 meters a second.',
    twins: Twins(law: Law.reynolds, model: 1, proto: 10),
    why:
        'Faster, at 30 meters a second, and that is the lesson\'s own answer. '
        'Reynolds has the speed multiplying the length, so shrinking the '
        'length by ten means multiplying the speed by ten to hold the product '
        'still. Thirty meters a second through a test tank is a serious '
        'proposition, which is exactly why Reynolds models at small scale so '
        'often cannot be built.',
    source: 'fm-das-q3',
  ),
  TwinRound(
    subject: 'a river reach at one in a hundred',
    setting:
        'A 1:100 river model on a laboratory floor, matched on Froude '
        'because the surface is what matters.',
    twins: Twins(law: Law.froude, model: 1, proto: 100),
    why:
        'Slower, a tenth of the river\'s speed, because the square root of a '
        'hundredth is a tenth. A river running at two meters a second is a '
        'model creeping along at twenty centimeters a second, which is a '
        'large part of why these models are filmed and sped up to be watched '
        'at all.',
    source: 'fm-das-q2',
  ),
  TwinRound(
    subject: 'the pump at full size',
    setting:
        'The pump on its closed loop at 1:1 in the same water, matched on '
        'Reynolds.',
    twins: Twins(law: Law.reynolds, model: 1, proto: 1),
    why:
        'The same speed. With the length ratio at one, the inverse of it is '
        'one as well, and Reynolds asks for the service speed and nothing '
        'else. Froude would ask for the same. Both laws agree the moment the '
        'model stops being smaller than the thing.',
    source: 'fm-das-q3',
  ),
  TwinRound(
    subject: 'a fitting blown up to twice size',
    setting:
        'A small fitting is awkward to instrument, so it is built at twice '
        'full size and run on Reynolds in the same fluid.',
    twins: Twins(law: Law.reynolds, model: 2, proto: 1),
    why:
        'Slower, at half the speed. The rule is not "Reynolds means faster", '
        'it is that the speed goes as the inverse of the size: make the model '
        'BIGGER and the speed has to come down. Building a Reynolds model '
        'oversized is the standard dodge for exactly this reason, because a '
        'slow test is a cheap and measurable one.',
    source: 'fm-das-q3',
  ),
  TwinRound(
    subject: 'a weir crest built four times size',
    setting:
        'A small weir crest is built at four times full size in a flume, and '
        'matched on Froude because the nappe is what is being watched.',
    twins: Twins(law: Law.froude, model: 4, proto: 1),
    why:
        'Faster, at twice the speed, since the square root of four is two. '
        'Froude is not "always slower" either. Both rules are about the '
        'direction the size went, and both traps in the lesson come from '
        'remembering a direction instead of the formula the direction came '
        'out of.',
    source: 'fm-das-q2',
  ),
];

class _DoesTheModelRunFasterGameState extends State<DoesTheModelRunFasterGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-the-model-run-faster',
    chapterId: 'fluid-mechanics',
    total: twinRounds.length,
    sourceProblemIdOf: (round) => twinRounds[round].source,
  )..addListener(_onSession);

  Runs2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TwinRound get _round => twinRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does the Model Run Faster',
        closing:
            'Froude carries the speed over the root of the length, so the '
            'speed follows the size by its square root. Reynolds carries the '
            'speed times the length, so the speed goes the other way, by the '
            'full ratio. Neither law means faster or slower on its own: it '
            'depends which way the size went, and a small Reynolds model '
            'asking for ten times the speed is often the end of the idea.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: scalingBrief,
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
            'WHERE DOES THE MODEL SPEED SIT',
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
            height: 130,
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
                  painter: TwinsPainter(twins: r.twins),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: MathText(
              r.twins.law == Law.froude
                  ? r'$\frac{v_m}{\sqrt{g l_m}} = \frac{v_p}{\sqrt{g l_p}}$'
                  : r'$\frac{v_m l_m}{\nu} = \frac{v_p l_p}{\nu}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Runs2.values) ...[
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
              title: _session.correct! ? 'THAT IS WHERE IT SITS' : 'THE OTHER WAY',
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
