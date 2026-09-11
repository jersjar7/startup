import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'level_figures.dart';

/// Higher or Lower — the first item for `leveling`.
///
/// Everything in differential leveling hangs on one picture: the line of
/// sight is dead level, so it is one flat plane over the whole setup, and a
/// rod reading is simply how far the ground at that rod sits below it. The
/// consequence runs against the grain for most people the first time: the
/// BIGGER reading is the LOWER point. Get that the wrong way round and the
/// signs in the arithmetic will never come out, which is the lesson's own
/// first trap.
class HigherOrLowerGame extends StatefulWidget {
  const HigherOrLowerGame({super.key});

  @override
  State<HigherOrLowerGame> createState() => _HigherOrLowerGameState();
}

/// Where the far point sits against the one the run started from.
enum Perch { higher, lower, same }

extension PerchWords on Perch {
  String get plain => switch (this) {
        Perch.higher => 'The far point is higher',
        Perch.lower => 'The far point is lower',
        Perch.same => 'They are at the same elevation',
      };
}

@immutable
class SightRound {
  const SightRound({
    required this.subject,
    required this.setting,
    required this.level,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Level level;
  final String why;
  final String source;

  /// Worked out from the two elevations, never declared, and never drawn
  /// until the round is answered.
  Perch get answer {
    final gap = level.marks.last.elevation - level.marks.first.elevation;
    if (gap.abs() < 0.005) return Perch.same;
    return gap > 0 ? Perch.higher : Perch.lower;
  }
}

const sightRounds = <SightRound>[
  SightRound(
    subject: 'the lesson\'s own readings',
    setting:
        'One setup. The rod on the benchmark reads 1.52 and the rod on A '
        'reads 2.35.',
    level: Level(
      marks: [Stake(name: 'BM', elevation: 100), Stake(name: 'A', elevation: 99.17)],
      clearances: [1.52],
    ),
    why:
        'A is lower, by 0.83 meters. The line of sight is one level plane '
        'across both rods, so a rod that reads more is standing on ground '
        'that is further below it. That is why the lesson adds the backsight '
        'and subtracts the foresight: 100.00 plus 1.52 puts you up at the '
        'instrument, and 2.35 back down lands at 99.17.',
    source: 'surv-lev-q1',
  ),
  SightRound(
    subject: 'the smaller reading',
    setting:
        'The rod on the benchmark reads 2.10 and the rod on B reads 0.90.',
    level: Level(
      marks: [Stake(name: 'BM', elevation: 100), Stake(name: 'B', elevation: 101.2)],
      clearances: [0.9],
    ),
    why:
        'B is higher, by 1.20 meters. Less rod showing under the line of '
        'sight means the ground has come up to meet it. The instrument does '
        'not have to be above everything it reads, and here the ground at B '
        'is nearly up at the telescope.',
    source: 'surv-lev-q1',
  ),
  SightRound(
    subject: 'two readings that match',
    setting: 'Both rods read 1.40.',
    level: Level(
      marks: [Stake(name: 'BM', elevation: 100), Stake(name: 'C', elevation: 100)],
      clearances: [1.4],
    ),
    why:
        'Neither: they are at the same elevation. Two equal readings off one '
        'level line of sight can only mean two rod feet on the same plane. '
        'This is the whole of how a level checks a floor slab or a row of '
        'column bases, and it needs no arithmetic at all.',
    source: 'surv-lev-q1',
  ),
  SightRound(
    subject: 'a long way down',
    setting:
        'The rod on the benchmark reads 0.65 and the rod on D reads 3.80.',
    level: Level(
      marks: [Stake(name: 'BM', elevation: 100), Stake(name: 'D', elevation: 96.85)],
      clearances: [0.65],
    ),
    why:
        'D is lower, by 3.15 meters, which is most of a full rod. A reading '
        'near the top of the staff means the ground has dropped away, and a '
        'reading near the bottom means it is up near the instrument. Reading '
        'the two numbers that way round is the sense check that catches a '
        'swapped backsight before the arithmetic starts.',
    source: 'surv-lev-q1',
  ),
  SightRound(
    subject: 'three centimeters in it',
    setting:
        'The rod on the benchmark reads 1.48 and the rod on E reads 1.51.',
    level: Level(
      marks: [Stake(name: 'BM', elevation: 100), Stake(name: 'E', elevation: 99.97)],
      clearances: [1.48],
    ),
    why:
        'E is lower, by three centimeters. Nothing about the ground looks '
        'different at this scale and the instrument does not care: the '
        'readings differ, so the elevations differ. Three centimeters is the '
        'sort of number a drainage fall is made of, which is why leveling is '
        'read to the millimeter.',
    source: 'surv-lev-q1',
  ),
  SightRound(
    subject: 'both rods barely showing',
    setting:
        'The rod on the benchmark reads 0.42 and the rod on F reads 0.18.',
    level: Level(
      marks: [Stake(name: 'BM', elevation: 100), Stake(name: 'F', elevation: 100.24)],
      clearances: [0.18],
    ),
    why:
        'F is higher, by 0.24 meters. Both points are close under the line '
        'of sight, so both readings are small, and the comparison works '
        'exactly the same way. The size of the readings says where the '
        'instrument is. The DIFFERENCE between them says what the ground '
        'does.',
    source: 'surv-lev-q1',
  ),
];

class _HigherOrLowerGameState extends State<HigherOrLowerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'higher-or-lower',
    chapterId: 'surveying',
    total: sightRounds.length,
    sourceProblemIdOf: (round) => sightRounds[round].source,
  )..addListener(_onSession);

  Perch? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SightRound get _round => sightRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Higher or Lower',
        closing:
            'The line of sight is one level plane, so the rod reading is how '
            'far the ground is below it. The bigger reading is the lower '
            'point, every time. Equal readings mean equal elevations. Read '
            'the two numbers that way before any arithmetic and a swapped '
            'backsight has nowhere to hide.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: sightBrief,
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
            'WHICH POINT IS HIGHER',
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
            height: 210,
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
                  painter: LevelPainter(
                    level: r.level,
                    showGround: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$HI = \text{Elev} + BS \qquad \text{Elev} = HI - FS$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Perch.values) ...[
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
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER WAY',
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
