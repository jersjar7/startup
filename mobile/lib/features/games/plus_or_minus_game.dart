import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'survey_figures.dart';
import 'traverse_figures.dart';

/// Plus or Minus — the first item for `traverse-computations`.
///
/// The two formulas are short enough to memorize in a minute and the sines
/// and cosines are desk work. What is not desk work is the pair of signs,
/// because a sign error does not look wrong: it produces a perfectly
/// believable pair of numbers that puts the next station in the wrong
/// quarter of the county. The signs follow from the quadrant and nothing
/// else, and the drawing shows the quadrant.
class PlusOrMinusGame extends StatefulWidget {
  const PlusOrMinusGame({super.key});

  @override
  State<PlusOrMinusGame> createState() => _PlusOrMinusGameState();
}

extension QuadSigns on Quad {
  String get signs => switch (this) {
        Quad.ne => 'Latitude plus, departure plus',
        Quad.se => 'Latitude minus, departure plus',
        Quad.sw => 'Latitude minus, departure minus',
        Quad.nw => 'Latitude plus, departure minus',
      };
}

@immutable
class SignRound2 {
  const SignRound2({
    required this.subject,
    required this.course,
    required this.why,
    required this.source,
  });

  final String subject;
  final Course course;
  final String why;
  final String source;

  /// Read off the quadrant the azimuth lands in, never declared.
  Quad get answer => course.quad;
}

const signPairRounds = <SignRound2>[
  SignRound2(
    subject: 'the lesson\'s own course',
    course: Course(azimuth: 60, length: 200),
    why:
        'Both plus. An azimuth of 60 is in the north-east quarter, so the '
        'course goes north and it goes east, and going north and east is all '
        'that a positive latitude and a positive departure mean. The lesson '
        'works this one out as 100.0 north and 173.2 east, and notice which '
        'is bigger: at 60 degrees the course has swung most of the way '
        'toward east, so the departure beats the latitude.',
    source: 'surv-tc-q1',
  ),
  SignRound2(
    subject: 'past due east',
    course: Course(azimuth: 135, length: 160),
    why:
        'Latitude minus, departure plus. Anything past 90 degrees is heading '
        'south, and the cosine turns negative there on its own if you let '
        'it. This is the quarter where people write a positive latitude out '
        'of habit and then cannot find why the traverse will not close.',
    source: 'surv-tc-q1',
  ),
  SignRound2(
    subject: 'into the third quarter',
    course: Course(azimuth: 200, length: 240),
    why:
        'Both minus. Past 180 the course is going south and west at once, so '
        'both components are negative. A closed traverse must have courses '
        'in more than one quarter, because latitudes that are all positive '
        'can never sum to nothing.',
    source: 'surv-tc-q1',
  ),
  SignRound2(
    subject: 'coming back north',
    course: Course(azimuth: 310, length: 180),
    why:
        'Latitude plus, departure minus. The last quarter is the one that '
        'brings a traverse home: heading north again while still running '
        'west. The cosine of 310 is positive and its sine is negative, which '
        'is exactly what north and west means.',
    source: 'surv-tc-q1',
  ),
  SignRound2(
    subject: 'five degrees past east',
    course: Course(azimuth: 95, length: 300),
    why:
        'Latitude minus, departure plus, and the latitude is tiny. Five '
        'degrees past due east is barely south of dead east, so the course '
        'drops only about 26 meters while running nearly 300 east. Small '
        'does not mean zero: leave the sign off and the traverse carries the '
        'error all the way round.',
    source: 'surv-tc-q1',
  ),
  SignRound2(
    subject: 'a hair west of north',
    course: Course(azimuth: 355, length: 150),
    why:
        'Latitude plus, departure minus. Almost due north, so the latitude '
        'is nearly the whole 150 and the departure is about 13 meters of '
        'west. The quarter decides the signs however close to a cardinal '
        'direction the course runs, and the numbers themselves say how much '
        'of each.',
    source: 'surv-tc-q1',
  ),
];

class _PlusOrMinusGameState extends State<PlusOrMinusGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'plus-or-minus',
    chapterId: 'surveying',
    total: signPairRounds.length,
    sourceProblemIdOf: (round) => signPairRounds[round].source,
  )..addListener(_onSession);

  Quad? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SignRound2 get _round => signPairRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Plus or Minus',
        closing:
            'Latitude is how far north, departure is how far east, and both '
            'go negative when the course goes the other way. The quadrant '
            'settles both signs before a single trigonometric function is '
            'touched: north-east both plus, south-east latitude minus, '
            'south-west both minus, north-west departure minus. A closed '
            'traverse has to visit more than one quarter or it can never '
            'come back.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: latDepBrief,
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
            'WHAT SIGNS DO ITS TWO PARTS TAKE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Container(
            height: 230,
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
                  painter: LegPainter(course: r.course, showSigns: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{Lat} = L\cos\theta \qquad \text{Dep} = L\sin\theta$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Quad.values) ...[
            _Choice(
              label: option.signs,
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
              title: _session.correct! ? 'THAT IS THE PAIR' : 'ANOTHER PAIR',
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
