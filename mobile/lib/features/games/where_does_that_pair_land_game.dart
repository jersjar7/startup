import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'cogo_figures.dart';

/// Where Does That Pair Land — the second item for `coordinate-geometry`.
///
/// A coordinate pair is two numbers and an agreement about which is which,
/// and the agreement is the part that gets dropped. Surveyors write easting
/// first and northing second, the same order as x then y, and plenty of
/// field books and older records write them the other way round. Reading a
/// pair backwards puts a point on the far side of the diagonal, which is
/// nowhere near where it belongs and produces perfectly believable numbers
/// all the way through. The lesson names it as a trap and the only cure is
/// to plot the thing.
class WhereDoesThatPairLandGame extends StatefulWidget {
  const WhereDoesThatPairLandGame({super.key});

  @override
  State<WhereDoesThatPairLandGame> createState() =>
      _WhereDoesThatPairLandGameState();
}

@immutable
class LandRound {
  const LandRound({
    required this.subject,
    required this.east,
    required this.north,
    required this.task,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The pair as the field book writes it: easting first.
  final double east;
  final double north;

  /// The candidates, all of them plotted.
  final Task task;
  final String why;
  final String source;

  /// Worked out by finding the plotted point that matches the pair, never
  /// declared beside it.
  int get answer => task.known
      .indexWhere((p) => p.east == east && p.north == north);
}

const landRounds = <LandRound>[
  LandRound(
    subject: 'the pair read straight',
    east: 1300,
    north: 1400,
    task: Task(known: [
      Peg2('P', 1300, 1400),
      Peg2('Q', 1400, 1300),
      Peg2('R', 1300, 1300),
      Peg2('S', 1400, 1400),
    ]),
    why:
        'P. Easting first, so 1,300 is measured across and 1,400 up. Q is '
        'the same two numbers swapped, which is the mistake worth watching '
        'for: it lands on the other side of the diagonal, a hundred feet '
        'from where the point belongs and in a different direction from '
        'everything else on the job.',
    source: 'surv-cg-q1',
  ),
  LandRound(
    subject: 'a wide gap between the two numbers',
    east: 2000,
    north: 5000,
    task: Task(known: [
      Peg2('P', 5000, 2000),
      Peg2('Q', 2000, 5000),
      Peg2('R', 2000, 2000),
      Peg2('S', 5000, 5000),
    ]),
    why:
        'Q, well up the sheet and not far across it. When the two numbers '
        'are far apart, reading them backwards moves the point three '
        'thousand feet, which is the sort of error that gets caught. It is '
        'the pairs that are close together that get through unnoticed.',
    source: 'surv-cg-q1',
  ),
  LandRound(
    subject: 'the lesson\'s own start point',
    east: 5000,
    north: 5000,
    task: Task(known: [
      Peg2('P', 5000, 5000),
      Peg2('Q', 5200, 5000),
      Peg2('R', 5000, 5200),
      Peg2('S', 5200, 5200),
    ]),
    why:
        'P. This is the point the lesson runs its course from, and it is the '
        'one pair that cannot be read backwards: the two numbers are the '
        'same. Control points are often set on round equal coordinates for '
        'exactly that reason, among others.',
    source: 'surv-cg-q2',
  ),
  LandRound(
    subject: 'a hundred feet in it',
    east: 4100,
    north: 4000,
    task: Task(known: [
      Peg2('P', 4000, 4100),
      Peg2('Q', 4100, 4000),
      Peg2('R', 4000, 4000),
      Peg2('S', 4100, 4100),
    ]),
    why:
        'Q, across to the right and level with the corner. P is the swap, '
        'and it sits a hundred feet away in a completely different '
        'direction. A hundred feet is small enough to look plausible on a '
        'plan and large enough to put a building on the neighbor\'s land.',
    source: 'surv-cg-q1',
  ),
  LandRound(
    subject: 'the far corner of the lesson\'s line',
    east: 1000,
    north: 1300,
    task: Task(known: [
      Peg2('P', 1300, 1000),
      Peg2('Q', 1000, 1000),
      Peg2('R', 1000, 1300),
      Peg2('S', 1300, 1300),
    ]),
    why:
        'R, straight up from the origin corner. Easting 1,000 means it has '
        'not moved east at all from that corner, and northing 1,300 puts it '
        'three hundred feet up. Read it backwards and the line would run '
        'east instead of north, which is a right angle of error.',
    source: 'surv-cg-q1',
  ),
  LandRound(
    subject: 'both numbers over three thousand',
    east: 3400,
    north: 3200,
    task: Task(known: [
      Peg2('P', 3200, 3400),
      Peg2('Q', 3400, 3200),
      Peg2('R', 3200, 3200),
      Peg2('S', 3400, 3400),
    ]),
    why:
        'Q. Two hundred feet separates the pair from its swap here, and '
        'nothing about either number looks wrong. This is why coordinates '
        'get labeled E and N on every drawing rather than left as a pair of '
        'numbers in brackets, and why a plotted check is worth the minute it '
        'takes.',
    source: 'surv-cg-q1',
  ),
];

class _WhereDoesThatPairLandGameState extends State<WhereDoesThatPairLandGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-does-that-pair-land',
    chapterId: 'surveying',
    total: landRounds.length,
    sourceProblemIdOf: (round) => landRounds[round].source,
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

  LandRound get _round => landRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where Does That Pair Land',
        closing:
            'Easting first, northing second: across, then up. A pair read '
            'backwards lands on the far side of the diagonal, and every '
            'number that follows it looks entirely reasonable. When the two '
            'numbers are close together the error is small enough to survive '
            'a glance and big enough to matter, which is why coordinates get '
            'labeled E and N and why the point gets plotted.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: pairBrief,
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
            'TAP THE POINT THAT PAIR NAMES',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '(E, N) = (${_num(r.east)}, ${_num(r.north)})',
              style: AppTheme.mono(size: 19, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Grid(
            task: r.task,
            picked: _picked,
            answer: r.answer,
            locked: answered,
            onPick: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE POINT' : 'ANOTHER POINT',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

class _Grid extends StatelessWidget {
  const _Grid({
    required this.task,
    required this.picked,
    required this.answer,
    required this.locked,
    required this.onPick,
  });

  final Task task;
  final int? picked;
  final int answer;
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
                  final hit = CogoPainter.at(size, task, details.localPosition);
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
                  painter: CogoPainter(
                    task: task,
                    showLine: false,
                    showCoordinates: false,
                    picked: picked,
                    answer: locked ? answer : null,
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
