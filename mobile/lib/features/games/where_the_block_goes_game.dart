import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'momentum_figures.dart';

/// Where the Block Goes — the third item for `momentum-equation`.
///
/// Knowing a bend needs holding is half of it. The other half is which way
/// the water shoves, and the sum in the lesson says it plainly once you read
/// it as vectors: both the pressure force and the momentum change run along
/// `in minus out`, so the push comes out on the OUTSIDE of the turn, along
/// the bisector. It is never along one leg, and it is never into the corner.
/// A block set on the wrong face does nothing at all.
class WhereTheBlockGoesGame extends StatefulWidget {
  const WhereTheBlockGoesGame({super.key});

  @override
  State<WhereTheBlockGoesGame> createState() => _WhereTheBlockGoesGameState();
}

@immutable
class ElbowRound {
  const ElbowRound({
    required this.subject,
    required this.setting,
    required this.elbow,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Elbow elbow;
  final String why;
  final String source;

  /// Worked out from the two headings, never declared beside them.
  int get answer => elbow.answer;
}

const blockRounds = <ElbowRound>[
  ElbowRound(
    subject: 'the square bend on the lesson\'s own problem',
    setting:
        'Water comes in from the west and leaves to the north through a '
        'square bend. Which block takes the push?',
    elbow: Elbow(comesFrom: 0, goesTo: 90),
    why:
        'A, on the outside of the turn. Both halves of the force point the '
        'same way here: the water arriving still wants to carry on east, and '
        'the pressure standing on the inlet face pushes east as well, while '
        'nothing is pushing back from the north leg because the water is '
        'leaving that way. Add them and the bend is shoved out into the '
        'corner of the angle, southeast, away from the elbow.',
    source: 'fm-me-q2',
  ),
  ElbowRound(
    subject: 'the same bend, turned the other way',
    setting:
        'Water comes in from the west again, and this time the bend sends it '
        'south.',
    elbow: Elbow(comesFrom: 0, goesTo: 270, order: [2, 0, 3, 1]),
    why:
        'B. The push always comes out on the outside of the turn, so turning '
        'the bend over turns the answer over with it: northeast rather than '
        'southeast. The block goes on the face the water is being pulled '
        'away from, never on the inside of the elbow where there is nothing '
        'to hold.',
    source: 'fm-me-q2',
  ),
  ElbowRound(
    subject: 'coming in from the south',
    setting: 'The main runs north up the street and then turns east.',
    elbow: Elbow(comesFrom: 90, goesTo: 0, order: [1, 2, 0, 3]),
    why:
        'C, up and to the west. Take it one leg at a time: the water arriving '
        'is still trying to go north, and after the bend nothing is going '
        'north any more, so that momentum went into the pipe. The same for '
        'the pressure on the two faces. The two add to a push out on the '
        'far side of the corner.',
    source: 'fm-me-q2',
  ),
  ElbowRound(
    subject: 'a gentle bend',
    setting:
        'A 45 degree bend: the water comes in heading east and leaves heading '
        'northeast.',
    elbow: Elbow(comesFrom: 0, goesTo: 45, order: [3, 1, 2, 0]),
    why:
        'D. The rule does not care how sharp the bend is, only where the '
        'two legs point: the push splits the angle the two legs make and '
        'heads away from the corner. A gentle bend is a smaller push, since '
        'less of the water\'s direction has changed, but it is still a push '
        'and it still comes out on the outside face.',
    source: 'fm-me-q2',
  ),
  ElbowRound(
    subject: 'past square',
    setting:
        'A 135 degree bend, which sends the water back on itself: in heading '
        'east, out heading northwest.',
    elbow: Elbow(comesFrom: 0, goesTo: 135, order: [1, 0, 3, 2]),
    why:
        'B, and this is the hardest block on the job. Turning the water more '
        'than square means it ends up traveling BACK along the line it came '
        'in on, so the change in momentum is bigger than at a square bend, '
        'and it is the same story as the cup that a jet is turned right '
        'around in. The push is still straight out on the outside of the '
        'turn.',
    source: 'fm-me-q2',
  ),
  ElbowRound(
    subject: 'coming the other way down the same street',
    setting:
        'The main runs west and turns north. The drawing is the first round '
        'mirrored.',
    elbow: Elbow(comesFrom: 180, goesTo: 90, order: [0, 3, 2, 1]),
    why:
        'A. Nothing about this turn is different from the first one except '
        'which way the paper is facing, and the push follows the pipe: out '
        'on the outside, southwest this time. If you find yourself reaching '
        'for compass directions you memorized, read the two arrows on the '
        'drawing again instead.',
    source: 'fm-me-q2',
  ),
];

class _WhereTheBlockGoesGameState extends State<WhereTheBlockGoesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-the-block-goes',
    chapterId: 'fluid-mechanics',
    total: blockRounds.length,
    sourceProblemIdOf: (round) => blockRounds[round].source,
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

  ElbowRound get _round => blockRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where the Block Goes',
        closing:
            'The push on a bend runs along the inlet direction minus the '
            'outlet direction, which lands it out on the outside of the turn '
            'every time, on the bisector. Sharper turns push harder. The '
            'inside of the elbow never needs holding, because nothing is '
            'trying to go there.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: blockBrief,
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
            'TAP THE BLOCK THAT TAKES THE PUSH',
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
          _Corner(
            elbow: r.elbow,
            picked: _picked,
            locked: answered,
            onPick: answered ? null : (i) => setState(() => _picked = i),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$F_{on\ bend} \propto \hat{u}_{in} - \hat{u}_{out}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER FACE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.elbow,
    required this.picked,
    required this.locked,
    required this.onPick,
  });

  final Elbow elbow;
  final int? picked;
  final bool locked;
  final void Function(int)? onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 250);
        return GestureDetector(
          onTapUp: onPick == null
              ? null
              : (details) {
                  final hit =
                      ElbowPainter.at(size, elbow, details.localPosition);
                  if (hit != null) onPick!(hit);
                },
          child: Container(
            height: size.height,
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
                  painter: ElbowPainter(
                    elbow: elbow,
                    picked: picked,
                    locked: locked,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
