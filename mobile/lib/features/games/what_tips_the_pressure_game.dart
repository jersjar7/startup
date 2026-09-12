import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'wall_stability_figures.dart';

/// What Tips the Pressure — the third item for `retaining-walls`.
///
/// The pressure under a footing is uniform only when the load lands dead
/// center. Off center, it becomes a trapezoid with the most at the toe, and
/// the 6e/B term is the whole of that tilt. Reaching for the average alone
/// is the wrong answer the lesson prints.
class WhatTipsThePressureGame extends StatefulWidget {
  const WhatTipsThePressureGame({super.key});

  @override
  State<WhatTipsThePressureGame> createState() =>
      _WhatTipsThePressureGameState();
}

@immutable
class TipRound {
  const TipRound({
    required this.subject,
    required this.asked,
    required this.wall,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Gravity wall;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's eight foot base, with the resultant a foot off center: an
/// average of 1,000 psf becomes 1,750 at the toe and 250 at the heel.
const _offCenter = Gravity(
  baseWidth: 8,
  vertical: 8000,
  resisting: 30000,
  overturning: 6000,
);

/// The same base with the resultant dead center: 1,000 psf everywhere.
const _centered = Gravity(
  baseWidth: 8,
  vertical: 8000,
  resisting: 38000,
  overturning: 6000,
);

const tipRounds = <TipRound>[
  TipRound(
    subject: 'a load that lands dead center',
    asked:
        'The resultant lands exactly in the middle of the base. What does the '
        'pressure under it look like?',
    wall: _centered,
    options: [
      'A triangle, most at the toe',
      'The same all the way across: the load divided by the base',
      'Most in the middle, tailing off at both ends',
      'Nothing at the edges',
    ],
    answer: 1,
    why:
        'Uniform, the load spread over the base and nothing more. That is the '
        'only case where the load over the area is the whole answer, and it '
        'is why that number is such a tempting wrong answer in every other '
        'case.',
    source: 'geo-rw-q3',
  ),
  TipRound(
    subject: 'and one that does not',
    asked:
        'Now the same load lands a foot toward the toe. What does the '
        'pressure do?',
    wall: _offCenter,
    options: [
      'It stays uniform: the total has not changed',
      'It becomes a trapezoid, largest at the toe',
      'It becomes a trapezoid, largest at the heel',
      'It doubles everywhere',
    ],
    answer: 1,
    why:
        'It tilts into a trapezoid with the most under the toe, the end the '
        'load moved toward. The total under the base has not changed, since '
        'the vertical force has not: the same amount of pressure is simply '
        'shared out unevenly.',
    source: 'geo-rw-q3',
  ),
  TipRound(
    subject: 'the term that does the tilting',
    asked:
        'In the toe pressure formula, what is the 6e/B part doing?',
    wall: _offCenter,
    options: [
      'Converting the force into a pressure',
      'Applying a factor of safety',
      'Correcting for the wall being sloped',
      'Tilting the diagram: it is zero when the load is centered',
    ],
    answer: 3,
    why:
        'It is the tilt, and only the tilt. With the load centered the '
        'eccentricity is zero, the bracket becomes one, and the formula falls '
        'back to the load over the base. Everything the eccentricity does to '
        'the pressure happens inside that one term.',
    source: 'geo-rw-q3',
  ),
  TipRound(
    subject: 'what the far end gets',
    asked:
        'The average pressure under this base is 1,000 psf and the toe takes '
        '1,750. Without working it out, what can be said about the heel?',
    wall: _offCenter,
    options: [
      'It takes 1,750 as well',
      'It takes more than 1,000, since the total went up',
      'It takes less than 1,000, since the average sits between the two ends',
      'It takes nothing at all',
    ],
    answer: 2,
    why:
        'Less than the average, necessarily. A trapezoid averages its two '
        'ends, so if one end is above the average the other is below it by '
        'the same amount. That symmetry is a free check on any answer to this '
        'kind of problem.',
    source: 'geo-rw-q3',
  ),
  TipRound(
    subject: 'why the toe and not the heel',
    asked: 'Why is it the toe that takes the most, rather than the heel?',
    wall: _offCenter,
    options: [
      'Because the toe is the shorter side of the footing',
      'Because the earth pushes the wall toward the toe, so the load leans '
          'that way',
      'Because the heel is buried deeper',
      'Because the toe is where the concrete is thickest',
    ],
    answer: 1,
    why:
        'Because everything is leaning that way. The earth pressure pushes '
        'the wall toward its toe and the wall tries to turn about that '
        'corner, so the resultant of the vertical forces moves toward it too, '
        'and the soil under that end feels it.',
    source: 'geo-rw-q3',
  ),
  TipRound(
    subject: 'when the average is the answer',
    asked:
        'A student answers a base pressure question with the load divided by '
        'the base width and nothing else. When is that right?',
    wall: _offCenter,
    options: [
      'Always: it is the definition of pressure',
      'Whenever the wall passes the overturning check',
      'Only when the load lands dead center',
      'Never',
    ],
    answer: 2,
    why:
        'Only with the load dead center, which a retaining wall almost never '
        'is: the whole point of a retaining wall is that something is pushing '
        'it sideways. The lesson offers that number as a wrong answer for '
        'exactly this reason.',
    source: 'geo-rw-q3',
  ),
];

class _WhatTipsThePressureGameState extends State<WhatTipsThePressureGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-tips-the-pressure',
    chapterId: 'geotechnical',
    total: tipRounds.length,
    sourceProblemIdOf: (round) => tipRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  TipRound get _round => tipRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Tips the Pressure',
        closing:
            'Load dead center, and the pressure under the base is the load '
            'over the base, everywhere alike. Off center, and it tilts into a '
            'trapezoid with the most under the toe. The 6e/B term is that '
            'tilt, it vanishes when the load is centered, and it stops being '
            'true once the load leaves the middle third.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: basePressureBrief,
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
            'UNDER THE BASE',
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
            height: 226,
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
                  painter: BasePainter(
                    wall: r.wall,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
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
