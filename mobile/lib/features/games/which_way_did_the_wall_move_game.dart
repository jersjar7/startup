import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'earth_pressure_figures.dart';

/// Which Way Did the Wall Move — the first item for `lateral-earth-pressure`.
///
/// Three coefficients describe the same soil against the same wall, and
/// which one applies depends entirely on what the wall has done. Lean away
/// from the soil and it relaxes into its active state, the smallest pressure
/// there is. Hold it still and the soil stays at rest. Push into the soil
/// and it resists with the passive pressure, which is several times larger.
class WhichWayDidTheWallMoveGame extends StatefulWidget {
  const WhichWayDidTheWallMoveGame({super.key});

  @override
  State<WhichWayDidTheWallMoveGame> createState() =>
      _WhichWayDidTheWallMoveGameState();
}

@immutable
class WallMoveRound {
  const WallMoveRound({
    required this.subject,
    required this.asked,
    required this.backfill,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Backfill backfill;
  final WallState answer;
  final String why;
  final String source;

  static String label(WallState which) => switch (which) {
        WallState.active => 'Active, the wall leaned away from the soil',
        WallState.atRest => 'At rest, the wall did not move at all',
        WallState.passive => 'Passive, the wall was pushed into the soil',
      };
}

const _thirtyDegrees = Backfill(height: 15, unitWeight: 120, friction: 30);
const _looseFill = Backfill(height: 12, unitWeight: 115, friction: 26);

const wallMoveRounds = <WallMoveRound>[
  WallMoveRound(
    subject: 'a wall that leans away',
    asked:
        'A retaining wall tips outward by a fraction of an inch as the fill '
        'goes in behind it. Which coefficient applies?',
    backfill: _thirtyDegrees,
    answer: WallState.active,
    why:
        'The active one. Letting the wall move away by even a very little '
        'lets the soil stretch sideways and take up some of the load itself, '
        'and the pressure on the wall falls to the smallest of the three. '
        'Almost every ordinary retaining wall is designed for this, because '
        'almost every ordinary wall moves that much.',
    source: 'geo-le-q1',
  ),
  WallMoveRound(
    subject: 'a wall that cannot move',
    asked:
        'A basement wall is held at the top by the floor slab and at the '
        'bottom by the footing, so it does not move at all. Which '
        'coefficient?',
    backfill: _thirtyDegrees,
    answer: WallState.atRest,
    why:
        'At rest, which sits between the other two and for this soil is half '
        'again as large as the active value. A basement wall designed for '
        'active pressure is under-designed, and the reason is not subtle: it '
        'never gets to move, so the soil never gets to relax.',
    source: 'geo-le-q1',
  ),
  WallMoveRound(
    subject: 'a wall pushed into the soil',
    asked:
        'The toe of a wall is shoved into the soil in front of it as the wall '
        'slides. What does that soil offer?',
    backfill: _thirtyDegrees,
    answer: WallState.passive,
    why:
        'Passive resistance, which for this soil is nine times the active '
        'value: the same soil, and a coefficient of 3 instead of a third. It '
        'takes a lot of movement to develop it, far more than the active '
        'case needs, which is why engineers are careful about how much of it '
        'they count on.',
    source: 'geo-le-q1',
  ),
  WallMoveRound(
    subject: 'the order of the three',
    asked:
        'One of the three states always gives the smallest coefficient, '
        'whatever the soil. Which state?',
    backfill: _looseFill,
    answer: WallState.active,
    why:
        'The active one, always, and the passive one is always the largest, '
        'with at rest between them. That order never changes. The lesson says '
        'to use it as a check: if an active coefficient comes out above one, '
        'or a passive one below one, the two angle formulas have been '
        'swapped.',
    source: 'geo-le-q1',
  ),
  WallMoveRound(
    subject: 'the check that catches a swap',
    asked:
        'One side of a wall works out at a coefficient of one third and the '
        'other at three. Which state is the three?',
    backfill: _thirtyDegrees,
    answer: WallState.passive,
    why:
        'Three, because the two are reciprocals: their product is one, every '
        'time. That is the fastest sanity check in the lesson. A third and '
        'three, a quarter and four, and if the pair you have do not multiply '
        'to one, one of them is wrong.',
    source: 'geo-le-q1',
  ),
  WallMoveRound(
    subject: 'a wall propped after the fact',
    asked:
        'A wall was designed for a leaning wall\'s pressure, and is then '
        'propped at the top so it cannot move at all. Which coefficient '
        'should have been used?',
    backfill: _looseFill,
    answer: WallState.atRest,
    why:
        'At rest, and the wall as built is under-designed. The soil only '
        'relaxes into its active state if the wall lets it, and a prop takes '
        'that away. Propping a wall feels like making it safer and it raises '
        'the load it has to carry, which is a good thing to have straight '
        'before somebody adds a slab to the top of one.',
    source: 'geo-le-q1',
  ),
];

class _WhichWayDidTheWallMoveGameState
    extends State<WhichWayDidTheWallMoveGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-way-did-the-wall-move',
    chapterId: 'geotechnical',
    total: wallMoveRounds.length,
    sourceProblemIdOf: (round) => wallMoveRounds[round].source,
  )..addListener(_onSession);

  WallState? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WallMoveRound get _round => wallMoveRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Way Did the Wall Move',
        closing:
            'Active when the wall leans away, which nearly every retaining '
            'wall does, and it is the smallest pressure of the three. At rest '
            'when it cannot move at all, which is what a basement wall does. '
            'Passive when it is pushed INTO the soil, which is much the '
            'largest and takes real movement to develop. The order never '
            'changes, the active and passive coefficients multiply to one, '
            'and a looser fill leans harder.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: rankineBrief,
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
            'WHICH COEFFICIENT',
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
            height: 158,
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
                  painter: CoefficientPainter(
                    backfill: r.backfill,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 10),
            Center(
              child: MathText(
                r'$K_a < K_0 < K_p, \quad K_a K_p = 1$',
                style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (final option in WallState.values) ...[
            _Choice(
              label: WallMoveRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != WallState.values.last) const SizedBox(height: 8),
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
