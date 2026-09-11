import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'fluid_figures.dart';
import 'lesson_brief.dart';

/// Walk the Manometer — the second item for `hydrostatic-pressure`.
///
/// A manometer is not a formula to memorize, it is a walk: start where you
/// know the pressure and step through the tube, adding as you go down a
/// column and subtracting as you come up one, with each fluid carrying its
/// own weight. The lesson says exactly that. So the item takes one step at a
/// time and asks which way the pressure went, which is the only thing that
/// ever goes wrong.
class WalkTheManometerGame extends StatefulWidget {
  const WalkTheManometerGame({super.key});

  @override
  State<WalkTheManometerGame> createState() => _WalkTheManometerGameState();
}

/// What one step does to the pressure.
enum Step2 { rises, falls, holds }

extension StepWords on Step2 {
  String get plain => switch (this) {
        Step2.rises => 'It goes UP',
        Step2.falls => 'It goes DOWN',
        Step2.holds => 'It does not change',
      };
}

@immutable
class WalkRound {
  const WalkRound({
    required this.subject,
    required this.tube,
    required this.from,
    required this.to,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final UTube tube;
  final Stop from;
  final Stop to;
  final Step2 answer;
  final String why;
  final String source;

  String get asked =>
      'Walking from ${from.plain} to ${to.plain}, what happens to the '
      'pressure?';
}

const _plain = UTube();
const _stacked = UTube(hasLight: true);

const walkRounds = <WalkRound>[
  WalkRound(
    subject: 'down the air side',
    tube: _plain,
    from: Stop.line,
    to: Stop.leftSurface,
    answer: Step2.holds,
    why:
        'Nothing worth counting. That leg is full of air, and a column of air '
        'a few centimeters tall weighs so little against a column of mercury '
        'that every manometer problem ignores it. The pressure at the mercury '
        'surface is the line pressure, which is what lets the walk start '
        'there.',
    source: 'fm-hp-q3',
  ),
  WalkRound(
    subject: 'down through the mercury',
    tube: _plain,
    from: Stop.leftSurface,
    to: Stop.leftBottom,
    answer: Step2.rises,
    why:
        'Up, by the mercury\'s specific weight times that drop. Going DOWN a '
        'column always adds, whatever the fluid is, and mercury adds fast: '
        'thirteen and a half times what the same drop in water would give.',
    source: 'fm-hp-q3',
  ),
  WalkRound(
    subject: 'across the bottom',
    tube: _plain,
    from: Stop.leftBottom,
    to: Stop.rightBottom,
    answer: Step2.holds,
    why:
        'It does not change. Moving sideways in the same connected fluid '
        'changes nothing, because pressure depends on depth alone. This is '
        'the step people expect to matter and it never does, and it is what '
        'lets you treat the bend as a single level.',
    source: 'fm-hp-q3',
  ),
  WalkRound(
    subject: 'up the open side',
    tube: _plain,
    from: Stop.rightBottom,
    to: Stop.rightSurface,
    answer: Step2.falls,
    why:
        'Down, by the mercury\'s weight times the climb. Coming UP a column '
        'always subtracts. Since the walk ends at an open surface, where the '
        'gauge pressure is zero, everything that was added coming down and '
        'taken off going up has to balance: that is the whole manometer '
        'equation in one sentence.',
    source: 'fm-hp-q3',
  ),
  WalkRound(
    subject: 'a lighter liquid on top',
    tube: _stacked,
    from: Stop.line,
    to: Stop.leftSurface,
    answer: Step2.rises,
    why:
        'Up, but only a little. With water standing on the mercury, this step '
        'goes down through a real column and adds its weight, at water\'s '
        'specific weight rather than mercury\'s: about a thirteenth as much '
        'per meter. Each fluid gets its own gamma, which is the part of the '
        'rule that a single-fluid manometer never tests.',
    source: 'fm-hp-q3',
  ),
  WalkRound(
    subject: 'back up to the open end',
    tube: _plain,
    from: Stop.rightSurface,
    to: Stop.open,
    answer: Step2.holds,
    why:
        'Nothing again: that stretch is air. The open end sits at atmospheric '
        'pressure, which is zero on the gauge, so the mercury surface below '
        'it is at zero too. Starting the walk from a known pressure and '
        'finishing at a known one is what makes the whole thing solvable.',
    source: 'fm-hp-q3',
  ),
];

class _WalkTheManometerGameState extends State<WalkTheManometerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'walk-the-manometer',
    chapterId: 'fluid-mechanics',
    total: walkRounds.length,
    sourceProblemIdOf: (round) => walkRounds[round].source,
  )..addListener(_onSession);

  Step2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WalkRound get _round => walkRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Walk the Manometer',
        closing:
            'Start where the pressure is known and walk. Down a column adds, '
            'up a column subtracts, sideways in the same fluid changes '
            'nothing, and a stretch of air changes nothing either. Each fluid '
            'carries its own weight, so a column of water adds about a '
            'thirteenth of what the same drop in mercury would.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: manometerBrief,
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
            'ONE STEP OF THE WALK',
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
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: CustomPaint(
                painter: UTubePainter(tube: r.tube, from: r.from, to: r.to),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Step2.values) ...[
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
