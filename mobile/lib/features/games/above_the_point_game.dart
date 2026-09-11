import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'wood_figures.dart';

/// Above the Point — the first item for `wood-masonry`.
///
/// The moisture problem in this lesson is one subtraction over one weight,
/// and the number it produces only means something against the fiber
/// saturation point. That threshold is the whole of wood behavior on this
/// exam: above it the cell walls are already full and drying changes nothing,
/// below it the walls give up water and the timber shrinks and stiffens. So
/// the scale is drawn, the round moves the timber along it, and what the move
/// does is read off which side of the line it happens on.
class AboveThePointGame extends StatefulWidget {
  const AboveThePointGame({super.key});

  @override
  State<AboveThePointGame> createState() => _AboveThePointGameState();
}

/// What a change in moisture does to the timber.
enum Wets { shrinks, swells, nothing }

extension DoesWords on Wets {
  String get plain => switch (this) {
        Wets.shrinks => 'It shrinks, and gets stronger and stiffer',
        Wets.swells => 'It swells, and gets weaker and softer',
        Wets.nothing => 'Neither: no shrinking and no change in strength',
      };
}

@immutable
class MoveRound2 {
  const MoveRound2({
    required this.subject,
    required this.setting,
    required this.move,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Drying move;
  final String why;
  final String source;

  /// Worked out from where the move happens, never declared. Only the part of
  /// a move that is below the saturation point does anything at all.
  Wets get answer {
    if (!move.touchesWood) return Wets.nothing;
    return move.drying ? Wets.shrinks : Wets.swells;
  }
}

const moistureRounds = <MoveRound2>[
  MoveRound2(
    subject: 'green timber on the stack',
    setting:
        'Sawn green and left in the yard, a beam goes from 95 percent '
        'moisture down to 45 percent. Half the water in it has gone.',
    move: Drying(from: 95, to: 45),
    why:
        'Nothing worth measuring. Everything it lost was free water sitting '
        'in the cell cavities, and that water was not holding the walls apart '
        'or carrying anything. The beam is a great deal lighter and it is the '
        'same beam. Drying only starts to matter once the cavities are empty, '
        'at the saturation point.',
    source: 'mat-wm-q1',
  ),
  MoveRound2(
    subject: 'into a heated building',
    setting:
        'The same beam, now at 25 percent, is installed indoors and settles '
        'at 10 percent over a winter.',
    move: Drying(from: 25, to: 10),
    why:
        'It shrinks, and it gets stronger and stiffer as it does. This whole '
        'move is below the saturation point, so the water is coming out of '
        'the cell walls themselves and they close up behind it. This is why a '
        'timber frame is nailed up tight in the autumn and has gaps by '
        'spring, and why design values are quoted for a service moisture '
        'content.',
    source: 'mat-wm-q1',
  ),
  MoveRound2(
    subject: 'a damp crawl space',
    setting:
        'A dry joist at 8 percent is put in over a damp crawl space and comes '
        'up to 22 percent.',
    move: Drying(from: 8, to: 22),
    why:
        'It swells, and it gives up some strength and stiffness. Wetting '
        'below the saturation point is the drying round run backwards: the '
        'water goes back into the cell walls and pushes them apart. This is '
        'exactly what the wet service factor is for, and it is a factor below '
        'one because the timber really is weaker.',
    source: 'mat-wm-q1',
  ),
  MoveRound2(
    subject: 'the lesson\'s sample',
    setting:
        'The sample in the problem, at 28 percent, is left in a shed and '
        'settles at 18 percent.',
    move: Drying(from: 28, to: 18),
    why:
        'It shrinks and stiffens the whole way. Twenty eight percent is a '
        'hair under the saturation point, which is worth noticing about that '
        'problem: its answer sits right at the top of the range where drying '
        'starts to do something. One point higher and this move would have '
        'begun with nothing happening at all.',
    source: 'mat-wm-q1',
  ),
  MoveRound2(
    subject: 'rained on before the roof went up',
    setting:
        'Framing at 40 percent takes a week of rain and comes up to 80 '
        'percent.',
    move: Drying(from: 40, to: 80),
    why:
        'Nothing, in the sense that matters. The cell walls were already full '
        'at 40 percent and all that extra water went into the cavities, so '
        'the timber is heavier and no weaker. It will dry back out. The '
        'damage from a wet frame comes later, from what happens on the way '
        'DOWN through thirty, and from mold rather than from strength.',
    source: 'mat-wm-q1',
  ),
  MoveRound2(
    subject: 'all the way from green to dry',
    setting:
        'A green post at 70 percent is kiln dried down to 12 percent.',
    move: Drying(from: 70, to: 12),
    why:
        'It shrinks and stiffens, but only for the last eighteen points of '
        'it. From 70 down to 30 nothing happens except weight loss, and '
        'everything a kiln is trying to control happens between 30 and 12. '
        'That is why kiln schedules slow down at the end: all the shrinking, '
        'and all the checking and warping that goes with it, is in that last '
        'stretch.',
    source: 'mat-wm-q1',
  ),
];

class _AboveThePointGameState extends State<AboveThePointGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'above-the-point',
    chapterId: 'materials',
    total: moistureRounds.length,
    sourceProblemIdOf: (round) => moistureRounds[round].source,
  )..addListener(_onSession);

  Wets? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  MoveRound2 get _round => moistureRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Above the Point',
        closing:
            'One threshold decides everything: about thirty percent, the '
            'fiber saturation point. Above it the cell walls are already full '
            'and water comes and goes without changing the timber. Below it '
            'the walls give the water up and the wood shrinks and stiffens, '
            'or takes it back and swells and softens. And the moisture '
            'content is always against the DRY weight, so green timber can '
            'sit well over a hundred percent.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: moistureBrief,
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
            'WHAT DOES THE TIMBER DO',
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
                painter: DryingPainter(move: r.move),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Wets.values) ...[
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
              title: _session.correct! ? 'THAT IS WHAT IT DOES' : 'NOT QUITE',
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
