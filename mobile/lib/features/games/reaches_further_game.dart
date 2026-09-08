import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'vector_figures.dart';

/// Which Reaches Further — the third item for `vector-basics-unit-vectors`.
///
/// The lesson's warning is that a magnitude is not a component and the two do
/// not move together. Saying that does not dislodge the instinct; seeing it
/// does. Every round here is built so that adding the components up gives the
/// wrong answer, and two of them are ties where the component sums are miles
/// apart. Nothing is computed: both arrows are on the same grid and the whole
/// question is which one gets further from the origin.
class ReachesFurtherGame extends StatefulWidget {
  const ReachesFurtherGame({super.key});

  @override
  State<ReachesFurtherGame> createState() => _ReachesFurtherGameState();
}

/// Which of the two, or neither.
enum Reach { first, second, same }

@immutable
class ReachRound {
  const ReachRound({
    required this.a,
    required this.b,
    required this.why,
    required this.source,
  });

  final Vec a;
  final Vec b;
  final String why;
  final String source;

  /// Worked out from the arrows, never declared beside them.
  Reach get answer {
    final diff = a.length - b.length;
    if (diff.abs() < 1e-9) return Reach.same;
    return diff > 0 ? Reach.first : Reach.second;
  }

  /// What somebody adding the components would have said. Used by the tests
  /// to insist that every round actually punishes that habit.
  Reach get bySum {
    final diff = (a.x.abs() + a.y.abs()) - (b.x.abs() + b.y.abs());
    if (diff.abs() < 1e-9) return Reach.same;
    return diff > 0 ? Reach.first : Reach.second;
  }
}

const reachRounds = <ReachRound>[
  ReachRound(
    a: Vec(6, 0),
    b: Vec(4, 4),
    why:
        'Six beats four and four. Their parts add to eight against six, which '
        'is why counting the parts up is no use: the second arrow spends its '
        'length going two ways at once.',
    source: 'math-vbu-q1',
  ),
  ReachRound(
    a: Vec(3, 4),
    b: Vec(5, 0),
    why:
        'The same length exactly, and this is the three four five triangle '
        'doing it. One has parts adding to seven and the other to five, and '
        'they still reach the same distance.',
    source: 'math-vbu-q1',
  ),
  ReachRound(
    a: Vec(-4, 4),
    b: Vec(0, -6),
    why:
        'Six straight down beats four and four, and the minus signs change '
        'nothing about that. A negative component points an arrow the other '
        'way, it never makes it shorter, because everything gets squared '
        'before it is added.',
    source: 'math-vbu-q3',
  ),
  ReachRound(
    a: Vec(2, 2),
    b: Vec(3, 0),
    why:
        'Three beats two and two, even though two and two add to more. Going '
        'diagonally costs you: the parts have to be squared, and squaring '
        'punishes splitting your length between two directions.',
    source: 'math-vbu-q1',
  ),
  ReachRound(
    a: Vec(0, 5),
    b: Vec(3, 3),
    why:
        'Five, straight up, beats three and three. Their parts add to five '
        'against six, so the count of parts and the actual distance disagree '
        'about which one wins.',
    source: 'math-vbu-q1',
  ),
  ReachRound(
    a: Vec(-3, 4),
    b: Vec(0, -5),
    why:
        'The same again, both of them five, and neither of them anywhere near '
        'the first quadrant. Three four five is worth recognizing on sight in '
        'any direction, because this exam uses it constantly.',
    source: 'math-vbu-q3',
  ),
];

class _ReachesFurtherGameState extends State<ReachesFurtherGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'reaches-further',
    chapterId: 'mathematics',
    total: reachRounds.length,
    sourceProblemIdOf: (round) => reachRounds[round].source,
  )..addListener(_onSession);

  Reach? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ReachRound get _round => reachRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Reaches Further',
        closing:
            'Length is the square root of the squares, so it is never the '
            'components added up. Two arrows with nothing in common can be '
            'exactly the same length.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: magnitudeBrief,
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
            'FURTHER FROM THE ORIGIN',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Which arrow is longer? They can also be the same.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 290,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: VectorPainter(
                    span: 7,
                    arrows: [
                      Arrow(r.a, color: AppColors.ember, label: 'A'),
                      Arrow(r.b, color: AppColors.forest, label: 'B'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ReachButton(
                  key: const ValueKey('reach-first'),
                  label: 'A',
                  color: AppColors.ember,
                  selected: _picked == Reach.first,
                  locked: answered,
                  isTruth: r.answer == Reach.first,
                  onTap: answered
                      ? null
                      : () => setState(() => _picked = Reach.first),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReachButton(
                  key: const ValueKey('reach-same'),
                  label: 'Same',
                  color: AppColors.ink2,
                  selected: _picked == Reach.same,
                  locked: answered,
                  isTruth: r.answer == Reach.same,
                  onTap: answered
                      ? null
                      : () => setState(() => _picked = Reach.same),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ReachButton(
                  key: const ValueKey('reach-second'),
                  label: 'B',
                  color: AppColors.forest,
                  selected: _picked == Reach.second,
                  locked: answered,
                  isTruth: r.answer == Reach.second,
                  onTap: answered
                      ? null
                      : () => setState(() => _picked = Reach.second),
                ),
              ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'READ RIGHT' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReachButton extends StatelessWidget {
  const _ReachButton({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.heading(
              size: 18,
              // The letter wears the arrow's own color, so nobody has to
              // remember which one was which.
            ).copyWith(color: locked ? AppColors.charcoal : color),
          ),
        ),
      ),
    );
  }
}
