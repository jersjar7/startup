import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'level_figures.dart';

/// What Is That Point — the second item for `leveling`.
///
/// A level run is bookkeeping, and the book has exactly three kinds of
/// entry. The point you start from is read once, looking back at what you
/// already know, and its reading is added. The point you finish on is read
/// once, looking forward, and its reading is taken off. Everything in
/// between is read TWICE: once forward from the old setup and once back from
/// the new one, because the level was picked up and moved. That is the
/// lesson's own warning, and reading it off the drawing is easier than
/// remembering it: count the instruments that can see the rod.
class WhatIsThatPointGame extends StatefulWidget {
  const WhatIsThatPointGame({super.key});

  @override
  State<WhatIsThatPointGame> createState() => _WhatIsThatPointGameState();
}

@immutable
class RunRound {
  const RunRound({
    required this.subject,
    required this.asking,
    required this.level,
    required this.why,
    required this.source,
  });

  final String subject;

  /// Which point in the run the round is about.
  final int asking;
  final Level level;
  final String why;
  final String source;

  /// Read off the run rather than declared: first, last, or in between.
  Peg get answer => level.roleOf(asking);

  String get name => level.marks[asking].name;
}

const runRounds = <RunRound>[
  RunRound(
    subject: 'the point the run starts from',
    asking: 0,
    level: Level(
      marks: [Stake(name: 'BM', elevation: 100), Stake(name: 'A', elevation: 99.17)],
      clearances: [1.52],
    ),
    why:
        'A backsight, and its 1.52 is added. It is the only elevation on the '
        'drawing that is already known, so it is the only one that can tell '
        'the instrument how high it is standing. Looking BACK at what you '
        'know is where the name comes from, and it is always the first '
        'reading of a run.',
    source: 'surv-lev-q1',
  ),
  RunRound(
    subject: 'the point the run finishes on',
    asking: 1,
    level: Level(
      marks: [Stake(name: 'BM', elevation: 100), Stake(name: 'A', elevation: 99.17)],
      clearances: [1.52],
    ),
    why:
        'A foresight, and its 2.35 is taken off. Only one instrument ever '
        'sees this rod, and the run stops here, so the reading is used once '
        'and subtracted from the height of instrument. Adding it instead is '
        'the lesson\'s own wrong answer of 100.83.',
    source: 'surv-lev-q1',
  ),
  RunRound(
    subject: 'the point in the middle',
    asking: 1,
    level: Level(
      marks: [
        Stake(name: 'BM-1', elevation: 250),
        Stake(name: 'TP-1', elevation: 251.44),
        Stake(name: 'B', elevation: 254.7),
      ],
      clearances: [3.18, 1.95],
    ),
    why:
        'Both. Two instruments can see this rod, so it is read twice: as a '
        'foresight from the first setup, which fixes its elevation, and then '
        'as a backsight from the second, which fixes the new height of '
        'instrument. That is what a turning point is for, and it is why the '
        'height of instrument has to be worked out again after every move. '
        'Carrying the old one forward is the lesson\'s own trap.',
    source: 'surv-lev-q2',
  ),
  RunRound(
    subject: 'the far end of a longer run',
    asking: 3,
    level: Level(
      marks: [
        Stake(name: 'BM', elevation: 60),
        Stake(name: 'TP-1', elevation: 61.8),
        Stake(name: 'TP-2', elevation: 63.1),
        Stake(name: 'P', elevation: 62.4),
      ],
      clearances: [1.1],
    ),
    why:
        'A foresight. However many setups a run takes, only the last point '
        'is read once and never looked back from, because nothing is '
        'measured beyond it. Notice it is not the highest point on the run '
        'either: a run wanders up and down and the bookkeeping does not '
        'care.',
    source: 'surv-lev-q2',
  ),
  RunRound(
    subject: 'the second of two turning points',
    asking: 2,
    level: Level(
      marks: [
        Stake(name: 'BM', elevation: 60),
        Stake(name: 'TP-1', elevation: 61.8),
        Stake(name: 'TP-2', elevation: 63.1),
        Stake(name: 'P', elevation: 62.4),
      ],
      clearances: [1.1],
    ),
    why:
        'Both again. Every point with an instrument on each side of it is a '
        'turning point, and a run can have as many as the ground needs: '
        'round a corner, over a ridge, or simply because the rod went out of '
        'sight. The count of turning points is one less than the count of '
        'setups.',
    source: 'surv-lev-q2',
  ),
  RunRound(
    subject: 'the known point on a three point run',
    asking: 0,
    level: Level(
      marks: [
        Stake(name: 'BM-1', elevation: 250),
        Stake(name: 'TP-1', elevation: 251.44),
        Stake(name: 'B', elevation: 254.7),
      ],
      clearances: [3.18, 1.95],
    ),
    why:
        'A backsight. There is exactly one of these in a run, at the start, '
        'no matter how long the run gets. Everything else on the drawing is '
        'worked out FROM it, which is why an error in the benchmark '
        'elevation moves every point on the job and closes the loop '
        'perfectly while doing it.',
    source: 'surv-lev-q2',
  ),
];

class _WhatIsThatPointGameState extends State<WhatIsThatPointGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-is-that-point',
    chapterId: 'surveying',
    total: runRounds.length,
    sourceProblemIdOf: (round) => runRounds[round].source,
  )..addListener(_onSession);

  Peg? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RunRound get _round => runRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Is That Point',
        closing:
            'Count the instruments that can see the rod. One, at the start '
            'of the run, and it is a backsight to be added. One, at the end, '
            'and it is a foresight to be taken off. Two, and it is a turning '
            'point read both ways, which means a fresh height of instrument '
            'after the level moves.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: runBrief,
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
            'WHAT IS IT IN THE BOOK',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'What is the reading on ${r.name}?',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
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
                    picked: r.asking,
                    readings: false,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Peg.values) ...[
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
