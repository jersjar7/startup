import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'earth_pressure_figures.dart';

/// Double the Wall — the third item for `lateral-earth-pressure`.
///
/// The active force has a half in front of it and a height SQUARED inside
/// it, and both of those are worth feeling rather than memorizing. The half
/// is the area of a triangle, and dropping it doubles the answer, which is
/// the wrong choice the lesson prints. The square means a wall twice as tall
/// carries four times the force, and its overturning moment grows faster
/// still.
class DoubleTheWallGame extends StatefulWidget {
  const DoubleTheWallGame({super.key});

  @override
  State<DoubleTheWallGame> createState() => _DoubleTheWallGameState();
}

@immutable
class WallHeightRound {
  const WallHeightRound({
    required this.subject,
    required this.asked,
    required this.backfill,
    this.against,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Backfill backfill;

  /// The wall to set beside it, when the round is a comparison.
  final Backfill? against;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _fifteen = Backfill(height: 15, unitWeight: 120, friction: 30);
const _thirty = Backfill(height: 30, unitWeight: 120, friction: 30);

const wallHeightRounds = <WallHeightRound>[
  WallHeightRound(
    subject: 'where the half comes from',
    asked:
        'The active force has a half in front of it. What is the half doing '
        'there?',
    backfill: _fifteen,
    options: [
      'It is a factor of safety',
      'It is the area of the triangle: the average pressure is half the '
          'pressure at the base',
      'It halves the soil weight for buoyancy',
      'It accounts for the wall being smooth',
    ],
    answer: 1,
    why:
        'It is the area of a triangle, nothing more. The pressure runs from '
        'nothing at the top to its largest at the base, so the average over '
        'the wall is half the largest, and the force is that average times '
        'the height. Dropping it gives 9,000 instead of 4,500 on the '
        'lesson\'s own wall, which is exactly one of its wrong answers.',
    source: 'geo-le-q2',
  ),
  WallHeightRound(
    subject: 'the lesson\'s own wall',
    asked:
        'A fifteen foot wall on 120 pound fill, coefficient a third, carries '
        '4,500 pounds per foot. A student gets 9,000. What did they leave '
        'out?',
    backfill: _fifteen,
    options: [
      'They used the passive coefficient',
      'They used the wrong unit weight',
      'They left out the half',
      'They squared the height twice',
    ],
    answer: 2,
    why:
        'The half. Exactly twice the right answer, every time, is the '
        'signature of taking the pressure at the base as though it acted all '
        'the way up instead of averaging it. The lesson offers 9,000 as a '
        'choice for that reason, and 13,500 for leaving out the coefficient '
        'as well.',
    source: 'geo-le-q2',
  ),
  WallHeightRound(
    subject: 'a wall twice as tall',
    asked:
        'The same soil, but a wall thirty feet high instead of fifteen. What '
        'happens to the force?',
    backfill: _thirty,
    against: _fifteen,
    options: [
      'It doubles, along with the height',
      'It rises by half',
      'It grows eight times',
      'It quadruples, because the height is squared',
    ],
    answer: 3,
    why:
        'Four times, because of the square. Twice the height means twice as '
        'much soil AND twice the pressure at the base, and the two multiply. '
        'It is why tall retaining walls get expensive out of all proportion '
        'to their height, and why a bank is often terraced into two short '
        'walls instead of one tall one.',
    source: 'geo-le-q2',
  ),
  WallHeightRound(
    subject: 'and the overturning',
    asked:
        'That same doubling: what happens to the moment trying to tip the '
        'wall about its toe?',
    backfill: _thirty,
    against: _fifteen,
    options: [
      'It quadruples, like the force',
      'It grows eight times: four times the force, acting twice as high',
      'It doubles',
      'It stays the same, since the shape has not changed',
    ],
    answer: 1,
    why:
        'Eight times. The force is four times larger and its arm, a third of '
        'the height, is twice as long. That cube is the real reason tall '
        'walls are hard: the thing trying to tip them over grows faster than '
        'anything you can easily do about it.',
    source: 'geo-le-q2',
  ),
  WallHeightRound(
    subject: 'a lighter backfill',
    asked:
        'The fill is replaced with a lighter soil, 100 pounds a cubic foot '
        'instead of 120, at the same friction angle. What happens to the '
        'force?',
    backfill: _fifteen,
    options: [
      'It falls by a sixth squared',
      'Nothing: the coefficient has not changed',
      'It falls in proportion, by about a sixth',
      'It rises, since lighter soil is looser',
    ],
    answer: 2,
    why:
        'In proportion, because the unit weight sits in the formula on its '
        'own with no power on it. Weight and coefficient both scale the '
        'answer straight, and only the height is squared. Worth knowing which '
        'of the three does what before reaching for a lighter fill.',
    source: 'geo-le-q2',
  ),
  WallHeightRound(
    subject: 'what to check besides the force',
    asked:
        'The force on the wall has been worked out. What else does the wall '
        'have to be checked for?',
    backfill: _fifteen,
    options: [
      'Nothing else: the force is the design',
      'Only the strength of the concrete',
      'Sliding along its base, overturning about its toe, and bearing under '
          'it',
      'Only the settlement of the backfill',
    ],
    answer: 2,
    why:
        'Three separate checks, and the earth pressure is the input to all of '
        'them. The wall can slide, it can tip about its toe, and the soil '
        'underneath can fail in bearing. They are different sums with '
        'different factors of safety, and a wall can pass any two and fail '
        'the third.',
    source: 'geo-le-q3',
  ),
];

class _DoubleTheWallGameState extends State<DoubleTheWallGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'double-the-wall',
    chapterId: 'geotechnical',
    total: wallHeightRounds.length,
    sourceProblemIdOf: (round) => wallHeightRounds[round].source,
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

  WallHeightRound get _round => wallHeightRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Double the Wall',
        closing:
            'The half is the area of a triangle and dropping it doubles the '
            'answer. The height is squared, so twice the wall is four times '
            'the force, and the overturning moment grows eight times because '
            'the arm doubles as well. The unit weight and the coefficient '
            'scale it straight. And the force is only the input: sliding, '
            'overturning and bearing are three separate checks after it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: wallForceBrief,
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
            'THE HALF AND THE SQUARE',
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
            height: 222,
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
                  painter: WallPainter(
                    backfill: r.backfill,
                    against: r.against,
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
                r'$P_a = \tfrac{1}{2} K_a \gamma H^2$',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.charcoal),
              ),
            ),
          ],
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
