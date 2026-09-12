import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'shear_strength_figures.dart';

/// Reading the Circle — the third item for `shear-strength`.
///
/// A triaxial test hands over two numbers and the Mohr circle turns them
/// into the two that matter: the middle of the circle and its radius. From
/// there the undrained strength is the radius, and for a soil with no
/// cohesion the SINE of the friction angle is the radius over the middle.
/// Reaching for the tangent there is the wrong answer the lesson prints.
class ReadingTheCircleGame extends StatefulWidget {
  const ReadingTheCircleGame({super.key});

  @override
  State<ReadingTheCircleGame> createState() => _ReadingTheCircleGameState();
}

@immutable
class CircleRound {
  const CircleRound({
    required this.subject,
    required this.asked,
    required this.failure,
    required this.test,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Failure failure;
  final Triaxial test;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _sandTest = Triaxial(cell: 2000, deviator: 4000);
const _clayTest = Triaxial(cell: 1500, deviator: 2400);

const triaxialRounds = <CircleRound>[
  CircleRound(
    subject: 'the two numbers a circle gives',
    asked:
        'The cell pressure and the pressure at failure fix the circle. What '
        'are its middle and its radius made of?',
    failure: Failure(cohesion: 0, friction: 30),
    test: _sandTest,
    options: [
      'The middle is the average of the two, and the radius is half their '
          'difference',
      'The middle is the smaller one, and the radius is the larger',
      'The middle is their difference, and the radius is their average',
      'The middle is the cell pressure and the radius is the pressure at '
          'failure',
    ],
    answer: 0,
    why:
        'The average and the half difference. That is all a Mohr circle is '
        'for a triaxial test: the two principal stresses sit at the ends of a '
        'horizontal diameter, so the center is halfway between them and the '
        'radius is half the gap. Everything else in the lesson is read off '
        'that circle.',
    source: 'geo-ss-q2',
  ),
  CircleRound(
    subject: 'the lesson\'s own clay',
    asked:
        'A saturated clay is loaded fast and fails with 2,400 pounds a square '
        'foot of extra squeeze. What is its undrained strength?',
    failure: Failure(cohesion: 1200, friction: 0),
    test: _clayTest,
    options: [
      'Half of it: 1,200, the radius of the circle',
      'All of it: 2,400',
      'The cell pressure, 1,500',
      'The two added: 3,900',
    ],
    answer: 0,
    why:
        'Half, because the envelope for an undrained clay is a flat line and '
        'a flat line touches a circle at its TOP, which is one radius above '
        'the axis. So the strength is half the deviator, 1,200. Reporting the '
        'whole 2,400 is the wrong answer the lesson lists, and it overstates '
        'the clay by a factor of two.',
    source: 'geo-ss-q3',
  ),
  CircleRound(
    subject: 'sine, not tangent',
    asked:
        'A clean sand with no cohesion fails at 6,000 with a cell pressure of '
        '2,000. How is the friction angle found?',
    failure: Failure(cohesion: 0, friction: 30),
    test: _sandTest,
    options: [
      'Its SINE is the radius over the middle, which is 0.5 here',
      'Its TANGENT is the radius over the middle',
      'Its tangent is the larger stress over the smaller',
      'Its sine is the difference over the larger stress',
    ],
    answer: 0,
    why:
        'The sine. With no cohesion the envelope starts at the origin, so the '
        'line from the origin to the touching point makes a right triangle '
        'whose hypotenuse is the distance to the center and whose opposite '
        'side is the radius. Sine is opposite over hypotenuse, which gives 30 '
        'degrees. Taking the arctangent instead gives 26.6, which the lesson '
        'offers as a choice for exactly that reason.',
    source: 'geo-ss-q2',
  ),
  CircleRound(
    subject: 'where the circle touches',
    asked:
        'At failure the circle touches the envelope. What does the touching '
        'point mean?',
    failure: Failure(cohesion: 100, friction: 28),
    test: _sandTest,
    options: [
      'The plane inside the sample that gave way, and the stresses on it',
      'The horizontal plane through the sample',
      'The plane the cell pressure acts on',
      'Nothing physical: it is where the arithmetic lands',
    ],
    answer: 0,
    why:
        'It is the failure plane itself. Every point on the circle is the '
        'normal stress and shear on some plane through the sample, and the '
        'one that touches the envelope is the plane whose shear has just '
        'reached what the soil can carry. Everything inside the circle is a '
        'plane with strength to spare.',
    source: 'geo-ss-q1',
  ),
  CircleRound(
    subject: 'a circle that does not reach',
    asked:
        'A sample is loaded so that its circle sits entirely below the '
        'envelope. What does that say?',
    failure: Failure(cohesion: 100, friction: 28),
    test: Triaxial(cell: 2000, deviator: 1200),
    options: [
      'No plane in it has failed: the soil is holding, with strength to spare',
      'The sample has already failed',
      'The test was run at the wrong cell pressure',
      'The soil has no cohesion',
    ],
    answer: 0,
    why:
        'It is holding. A circle clear of the envelope means every plane in '
        'the sample has more strength than shear, which is a stable state. '
        'Failure is the moment the circle grows out to touch the line, and a '
        'circle that crossed it would describe something impossible: the soil '
        'would have given way before it got there.',
    source: 'geo-ss-q1',
  ),
  CircleRound(
    subject: 'raising the cell pressure',
    asked:
        'A sand is tested again at a higher cell pressure. What happens to '
        'the squeeze it takes to fail it?',
    failure: Failure(cohesion: 0, friction: 30),
    test: Triaxial(cell: 4000, deviator: 8000),
    options: [
      'It rises in proportion: the circle has to grow to keep touching the '
          'rising line',
      'It stays the same, since the soil is the same',
      'It falls, because the sample is already stressed',
      'It cannot be predicted without another test',
    ],
    answer: 0,
    why:
        'It rises in proportion, which is what a straight envelope through '
        'the origin means: doubling the cell pressure doubles the deviator at '
        'failure. That is why one triaxial test on a clean sand is enough to '
        'describe it at every depth, and why the same sand is worth so much '
        'more at the bottom of a deep excavation than at the top.',
    source: 'geo-ss-q2',
  ),
];

class _ReadingTheCircleGameState extends State<ReadingTheCircleGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'reading-the-circle',
    chapterId: 'geotechnical',
    total: triaxialRounds.length,
    sourceProblemIdOf: (round) => triaxialRounds[round].source,
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

  CircleRound get _round => triaxialRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Reading the Circle',
        closing:
            'The two stresses at failure sit at the ends of a diameter, so '
            'the middle is their average and the radius is half their '
            'difference. A flat undrained envelope touches the circle at its '
            'top, which makes the undrained strength the RADIUS, half the '
            'deviator. For a soil with no cohesion the envelope runs through '
            'the origin and the SINE of the friction angle is the radius over '
            'the middle. The touching point is the plane that gave way.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: mohrCircleBrief,
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
            'READING THE TEST',
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
            height: 212,
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
                  painter: EnvelopePainter(
                    failure: r.failure,
                    test: r.test,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$s = \frac{\sigma_1 + \sigma_3}{2}, \quad '
              r't = \frac{\sigma_1 - \sigma_3}{2}$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
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
