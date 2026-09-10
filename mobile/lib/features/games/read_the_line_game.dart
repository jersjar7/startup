import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'dot_plot_figures.dart';
import 'lesson_brief.dart';

/// Read It Off the Line — the first item for `central-tendency-dispersion`.
///
/// Every formula in this lesson has a sum in it, and adding six numbers on a
/// phone teaches nothing. What the lesson is actually about is telling six
/// summaries apart, and three of them are places rather than sums: the median
/// is the middle POSITION, the mode is the tallest stack, and the range is the
/// distance between the ends. Put the readings on a line and all three can be
/// pointed at. The one that cannot be pointed at is the mean, which is exactly
/// why the rounds keep contrasting it with the median.
class ReadTheLineGame extends StatefulWidget {
  const ReadTheLineGame({super.key});

  @override
  State<ReadTheLineGame> createState() => _ReadTheLineGameState();
}

@immutable
class LineRound {
  const LineRound({
    required this.ask,
    required this.subject,
    required this.values,
    required this.from,
    required this.to,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String ask;

  /// What the readings are of, in the lesson's own words.
  final String subject;
  final List<int> values;
  final int from;
  final int to;

  /// The ticks that answer it. More than one where the question has more than
  /// one, which is the honest shape for an even-sized median or a range.
  final Set<int> answer;
  final String why;
  final String source;
}

const lineRounds = <LineRound>[
  LineRound(
    ask: 'Tap the median.',
    subject: 'five moisture readings, in percent',
    values: [11, 12, 13, 14, 16],
    from: 10,
    to: 18,
    answer: {13},
    why:
        'Five readings sorted, so the median is the third one along. It is a '
        'position, not a sum, which is why you can point at it without adding '
        'anything up.',
    source: 'stat-ctd-q1',
  ),
  LineRound(
    ask: 'Tap the value that appears most often.',
    subject: 'seven blow counts',
    values: [12, 14, 15, 15, 15, 17, 18],
    from: 11,
    to: 19,
    answer: {15},
    why:
        'The mode is the tallest stack and nothing else. A set can have no '
        'mode at all, or several, which is why it is the least useful of the '
        'three centers and the easiest to read.',
    source: 'stat-ctd-q1',
  ),
  LineRound(
    ask: 'Six readings. Tap the two the median sits between.',
    subject: 'six cylinder strengths, in hundreds of psi',
    values: [40, 41, 42, 43, 44, 46],
    from: 39,
    to: 47,
    answer: {42, 43},
    why:
        'With an even count there is no middle reading, so the median is the '
        'average of the middle two. That average is 42.5, which is not a '
        'reading anybody took.',
    source: 'stat-ctd-q2',
  ),
  LineRound(
    ask: 'Tap the two readings the range is measured between.',
    subject: 'six cylinder strengths, in hundreds of psi',
    values: [40, 41, 42, 43, 44, 46],
    from: 39,
    to: 47,
    answer: {40, 46},
    why:
        'Range is the largest take the smallest, so it only ever looks at the '
        'two ends. Everything in between could move anywhere and the range '
        'would not change, which is why it is a poor measure of spread.',
    source: 'stat-ctd-q2',
  ),
  LineRound(
    ask: 'One reading is a long way out. Tap the median anyway.',
    subject: 'seven traffic counts, in hundreds',
    values: [10, 11, 12, 13, 14, 15, 24],
    from: 9,
    to: 25,
    answer: {13},
    why:
        'The median does not care how far out the stray reading is, only that '
        'it is on that side. The MEAN would be dragged up to about 14.1, well '
        'past the middle of the pack, and that gap is the whole reason both '
        'summaries exist.',
    source: 'stat-ctd-q1',
  ),
  LineRound(
    ask: 'Tap every mode.',
    subject: 'eight lift thicknesses, in inches',
    values: [6, 7, 7, 8, 9, 9, 10, 11],
    from: 5,
    to: 12,
    answer: {7, 9},
    why:
        'Two values tie for the most common, so the set has two modes and '
        'neither one is more the mode than the other. A summary that can '
        'answer twice is not a summary you build a design on.',
    source: 'stat-ctd-q1',
  ),
];

class _ReadTheLineGameState extends State<ReadTheLineGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'read-the-line',
    chapterId: 'statistics',
    total: lineRounds.length,
    sourceProblemIdOf: (round) => lineRounds[round].source,
  )..addListener(_onSession);

  final Set<int> _picked = {};

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LineRound get _round => lineRounds[_session.round];

  void _tap(Offset local, Size box, LineRound r) {
    if (_session.answered) return;
    final hit = DotPlotPainter(
      values: r.values,
      from: r.from,
      to: r.to,
    ).nearest(box, local);
    if (hit == null) return;
    setState(() {
      _picked.contains(hit) ? _picked.remove(hit) : _picked.add(hit);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Read It Off the Line',
        closing:
            'Median, mode and range are places on the line and can be read '
            'without adding anything up. The mean cannot, which is the '
            'difference that matters when one reading is a long way out.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: centerBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_picked.clear);
              _session.next();
            }
          : (_picked.isEmpty
                ? null
                : () => _session.submit(
                    ok: _picked.length == r.answer.length &&
                        _picked.containsAll(r.answer),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOTHING HERE NEEDS ADDING UP',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: DotPlotPainter.heightFor(r.values),
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final size = Size(box.maxWidth, box.maxHeight);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _tap(d.localPosition, size, r),
                      child: CustomPaint(
                        painter: DotPlotPainter(
                          values: r.values,
                          from: r.from,
                          to: r.to,
                          picked: _picked,
                          truth: answered ? r.answer : const {},
                          revealed: answered,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SPOT' : 'NOT THERE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
