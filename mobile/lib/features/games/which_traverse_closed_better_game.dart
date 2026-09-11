import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'traverse_figures.dart';

/// Which Traverse Closed Better — the third item for
/// `traverse-computations`.
///
/// Precision is a ratio, and the whole point of writing it as one over
/// something is that the size of the gap means nothing on its own. A tenth
/// of a meter is careless work on a short town lot and good work across a
/// mile of control. Comparing two traverses by their closure alone is the
/// mistake the ratio exists to prevent, and comparing them properly needs no
/// arithmetic: hold one of the two numbers still and look at the other.
class WhichTraverseClosedBetterGame extends StatefulWidget {
  const WhichTraverseClosedBetterGame({super.key});

  @override
  State<WhichTraverseClosedBetterGame> createState() =>
      _WhichTraverseClosedBetterGameState();
}

/// Which of the two closed better.
enum Better { left, right, same }

extension BetterWords on Better {
  String get plain => switch (this) {
        Better.left => 'The left one',
        Better.right => 'The right one',
        Better.same => 'Neither: the same precision',
      };
}

@immutable
class ClosedRound {
  const ClosedRound({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Trip left;
  final Trip right;
  final String why;
  final String source;

  /// Worked out from the two ratios, never declared. A bigger figure is a
  /// better traverse: 1 in 10,000 beats 1 in 5,000.
  Better get answer {
    final gap = left.precision - right.precision;
    if (gap.abs() < 1) return Better.same;
    return gap > 0 ? Better.left : Better.right;
  }
}

const closedRounds = <ClosedRound>[
  ClosedRound(
    subject: 'the same gap, two sizes of job',
    setting:
        'Both finished 0.10 meters out. The left runs 1,000 meters round and '
        'the right 400.',
    left: Trip(lengths: [250, 250, 250, 250], driftNorth: 0.08, driftEast: -0.06),
    right: Trip(lengths: [100, 100, 100, 100], driftNorth: 0.08, driftEast: -0.06),
    why:
        'The left one, at 1 in 10,000 against 1 in 4,000. The same gap is '
        'worse work on the smaller job, because there was less traverse to '
        'accumulate it over. The left one is the lesson\'s own, and 1 in '
        '10,000 is the figure it computes.',
    source: 'surv-tc-q2',
  ),
  ClosedRound(
    subject: 'the same size of job, two crews',
    setting:
        'Both run 800 meters round. The left finished 0.05 out, the right '
        '0.20.',
    left: Trip(lengths: [200, 200, 200, 200], driftNorth: 0.03, driftEast: 0.04),
    right: Trip(lengths: [200, 200, 200, 200], driftNorth: 0.12, driftEast: 0.16),
    why:
        'The left one, four times the precision for a quarter of the gap. '
        'Hold the perimeter still and the comparison is just the closures, '
        'which is the only case where the raw gap answers the question on '
        'its own.',
    source: 'surv-tc-q2',
  ),
  ClosedRound(
    subject: 'both doubled',
    setting:
        'The right is the left at twice the size: twice round and twice the '
        'gap.',
    left: Trip(lengths: [150, 150, 150, 150], driftNorth: 0.048, driftEast: 0.064),
    right: Trip(lengths: [300, 300, 300, 300], driftNorth: 0.096, driftEast: 0.128),
    why:
        'Neither: the same precision, 1 in 7,500 each. Double the gap over '
        'double the distance is the same ratio, and that is exactly why the '
        'ratio is the thing that gets specified. A contract asking for 1 in '
        '10,000 asks the same standard of a small site and a large one.',
    source: 'surv-tc-q2',
  ),
  ClosedRound(
    subject: 'a tiny gap on a tiny traverse',
    setting:
        'The left is a 60 meter lot that closed 0.01 out. The right is 3,000 '
        'meters of control that closed 0.30 out.',
    left: Trip(lengths: [15, 15, 15, 15], driftNorth: 0.006, driftEast: 0.008),
    right: Trip(lengths: [750, 750, 750, 750], driftNorth: 0.18, driftEast: 0.24),
    why:
        'The right one, 1 in 10,000 against 1 in 6,000, even though its gap '
        'is thirty times bigger. This is the whole reason precision is '
        'written as a ratio. A centimeter out around a small lot is ordinary '
        'work; thirty centimeters around three kilometers is better than '
        'ordinary.',
    source: 'surv-tc-q2',
  ),
  ClosedRound(
    subject: 'twice the gap, four times the traverse',
    setting:
        'The left runs 500 meters and closed 0.05. The right runs 2,000 and '
        'closed 0.10.',
    left: Trip(lengths: [125, 125, 125, 125], driftNorth: 0.03, driftEast: 0.04),
    right: Trip(lengths: [500, 500, 500, 500], driftNorth: 0.06, driftEast: 0.08),
    why:
        'The right one, 1 in 20,000 against 1 in 10,000. Four times the '
        'distance for only twice the gap is twice the precision. Work the '
        'two halves against each other rather than reading either one alone: '
        'that is all the ratio is doing.',
    source: 'surv-tc-q2',
  ),
  ClosedRound(
    subject: 'two jobs that match',
    setting:
        'One is two long courses and two short ones, the other is four '
        'equal. Same perimeter of 1,200 meters, and both finished 0.12 out.',
    left: Trip(lengths: [500, 100, 500, 100], driftNorth: 0.072, driftEast: 0.096),
    right: Trip(lengths: [300, 300, 300, 300], driftNorth: 0.072, driftEast: 0.096),
    why:
        'Neither: 1 in 10,000 each. How a traverse is cut into courses has '
        'nothing to do with its precision. Only the total length it ran and '
        'the gap it finished with go into the ratio, which is why a traverse '
        'of two big legs and one of four equal ones are held to the same '
        'standard. The sketch is drawn to shape, not to scale, so read the '
        'lengths.',
    source: 'surv-tc-q2',
  ),
];

class _WhichTraverseClosedBetterGameState
    extends State<WhichTraverseClosedBetterGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-traverse-closed-better',
    chapterId: 'surveying',
    total: closedRounds.length,
    sourceProblemIdOf: (round) => closedRounds[round].source,
  )..addListener(_onSession);

  Better? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ClosedRound get _round => closedRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Traverse Closed Better',
        closing:
            'Precision is the gap over the distance it accumulated across, '
            'written as one over something. The gap alone says nothing: a '
            'centimeter around a small lot can be worse work than thirty '
            'centimeters around three kilometers. Double both and nothing '
            'changes. The shape of the figure never comes into it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: precisionBrief,
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
            'WHICH ONE IS THE BETTER TRAVERSE',
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
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Panel(
                    trip: i == 0 ? r.left : r.right,
                    selected: _picked == (i == 0 ? Better.left : Better.right),
                    locked: answered,
                    isTruth: r.answer == (i == 0 ? Better.left : Better.right),
                    onTap: answered
                        ? null
                        : () => setState(() =>
                            _picked = i == 0 ? Better.left : Better.right),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{precision} = \dfrac{\text{closure}}{\text{perimeter}}$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Better.same.plain,
            selected: _picked == Better.same,
            locked: answered,
            isTruth: r.answer == Better.same,
            onTap:
                answered ? null : () => setState(() => _picked = Better.same),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.trip,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Trip trip;
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 190,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: TripPainter(trip: trip),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
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
