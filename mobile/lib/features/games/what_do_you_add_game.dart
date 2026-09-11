import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'cogo_figures.dart';

/// What Do You Add — the third item for `coordinate-geometry`.
///
/// The inverse computation ends with an arctangent, and an arctangent of one
/// number cannot tell you the quadrant: it returns something between minus a
/// right angle and a right angle, which is half the compass. The other half
/// has to come from the signs of the two coordinate differences, and that is
/// the whole of the lesson's third problem. The rule is short. Running
/// south, whichever way it also runs, add 180. Running north and west, add
/// 360. Running north and east, the calculator was right the first time.
class WhatDoYouAddGame extends StatefulWidget {
  const WhatDoYouAddGame({super.key});

  @override
  State<WhatDoYouAddGame> createState() => _WhatDoYouAddGameState();
}

/// What has to be done to the calculator's answer.
enum AddOn { asIs, plusHalf, plusWhole }

extension AddOnWords on AddOn {
  String get plain => switch (this) {
        AddOn.asIs => 'Nothing: that is the azimuth',
        AddOn.plusHalf => 'Add 180 degrees',
        AddOn.plusWhole => 'Add 360 degrees',
      };

  double get value => switch (this) {
        AddOn.asIs => 0,
        AddOn.plusHalf => 180,
        AddOn.plusWhole => 360,
      };
}

@immutable
class AddOnRound {
  const AddOnRound({
    required this.subject,
    required this.setting,
    required this.task,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Task task;
  final String why;
  final String source;

  /// Worked out from the two signs, never declared beside them.
  AddOn get answer =>
      AddOn.values.firstWhere((f) => f.value == task.toAdd);
}

const addOnRounds = <AddOnRound>[
  AddOnRound(
    subject: 'north and east',
    setting:
        'The line runs from A up and to the right. The calculator returns 37 '
        'degrees.',
    task: Task(known: [Peg2('A', 1000, 1000), Peg2('B', 1300, 1400)]),
    why:
        'Nothing: 37 degrees is already the azimuth. Clockwise from north, '
        'the first quarter of the turn is the one quarter where the '
        'arctangent lands on the right answer by itself, because both '
        'differences are positive and the angle it returns is positive too. '
        'Every other quarter needs help, which is why checking the two signs '
        'has to be a habit rather than something done when the answer looks '
        'odd.',
    source: 'surv-cg-q3',
  ),
  AddOnRound(
    subject: 'south and east',
    setting:
        'The line runs down and to the right. The calculator returns minus '
        '37 degrees.',
    task: Task(known: [Peg2('A', 1000, 1400), Peg2('B', 1300, 1000)]),
    why:
        'Add 180, giving 143. The northing difference is negative, so the '
        'line is running south, and every southbound line has an azimuth '
        'between 90 and 270. A negative number off the calculator is not an '
        'azimuth at all: azimuths run from 0 to 360.',
    source: 'surv-cg-q3',
  ),
  AddOnRound(
    subject: 'south and west',
    setting:
        'The line runs down and to the left. The calculator returns 37 '
        'degrees, a positive number.',
    task: Task(known: [Peg2('A', 1300, 1400), Peg2('B', 1000, 1000)]),
    why:
        'Add 180, giving 217, and notice that the calculator handed back a '
        'positive 37 that looks perfectly usable. Both differences are '
        'negative here, so the two minus signs cancel inside the division '
        'and the arctangent cannot tell this line from the first round\'s. '
        'The signs are the only thing that can.',
    source: 'surv-cg-q3',
  ),
  AddOnRound(
    subject: 'north and west',
    setting:
        'The line runs up and to the left. The calculator returns minus 37 '
        'degrees.',
    task: Task(known: [Peg2('A', 1300, 1000), Peg2('B', 1000, 1400)]),
    why:
        'Add 360, giving 323. This is the only quarter that takes the 360, '
        'and it is the last one you reach going clockwise from north. Adding '
        '180 instead would put the line down and to the right, which is the '
        'exact opposite direction: the same line walked backwards.',
    source: 'surv-cg-q3',
  ),
  AddOnRound(
    subject: 'due east',
    setting:
        'The line runs straight across to the right, with no change in '
        'northing at all.',
    task: Task(known: [Peg2('A', 1000, 1200), Peg2('B', 1500, 1200)]),
    why:
        'Nothing: it is 90 and the calculator gets there on its own, if it '
        'survives the division by a northing difference of zero. Due east is '
        'the boundary between the first quarter and the second, and both '
        'rules agree on it, which is a useful thing to know when a line '
        'comes out very close to a cardinal direction.',
    source: 'surv-cg-q3',
  ),
  AddOnRound(
    subject: 'due west',
    setting:
        'The line runs straight across to the left. The calculator returns '
        'minus 90 degrees.',
    task: Task(known: [Peg2('A', 1500, 1200), Peg2('B', 1000, 1200)]),
    why:
        'Add 360, giving 270. Due west is the other cardinal case, and it '
        'follows the north and west rule: the northing difference is not '
        'negative, so the 180 does not apply, and minus 90 has to be brought '
        'back into the 0 to 360 range by adding a full turn.',
    source: 'surv-cg-q3',
  ),
];

class _WhatDoYouAddGameState extends State<WhatDoYouAddGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-do-you-add',
    chapterId: 'surveying',
    total: addOnRounds.length,
    sourceProblemIdOf: (round) => addOnRounds[round].source,
  )..addListener(_onSession);

  AddOn? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  AddOnRound get _round => addOnRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Do You Add',
        closing:
            'The arctangent of one number covers half the compass, so the '
            'signs of the two differences have to supply the rest. A '
            'negative northing difference means the line runs south and the '
            'azimuth is 180 plus whatever came back. North and west takes '
            '360. North and east is the only quarter the calculator gets '
            'right on its own, and a negative answer is never an azimuth.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: arctanBrief,
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
            'WHAT DOES THE CALCULATOR ANSWER NEED',
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
            height: 215,
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
                  painter: CogoPainter(task: r.task, showDeltas: true),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$Az = \tan^{-1}\left(\dfrac{\Delta E}{\Delta N}\right)$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in AddOn.values) ...[
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
              title: _session.correct! ? 'THAT IS THE FIX' : 'ANOTHER FIX',
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
