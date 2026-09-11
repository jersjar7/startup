import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'aquifer_figures.dart';

/// Which Speed Is That — the first item for `groundwater-wells`.
///
/// Darcy's law hands you a number in meters a second that is not the speed
/// of anything: it is the flow divided by the WHOLE face of the soil, grains
/// included, and water cannot get through the grains. Dividing by the
/// porosity gives the speed a tracer would actually travel at, which is
/// always larger. Multiplying by the area instead gives a volume a second,
/// which is not a speed at all. The lesson's own problem offers all three
/// and asks for the middle one.
class WhichSpeedIsThatGame extends StatefulWidget {
  const WhichSpeedIsThatGame({super.key});

  @override
  State<WhichSpeedIsThatGame> createState() => _WhichSpeedIsThatGameState();
}

/// Which of the three quantities the round is describing.
enum Quantity3 { darcy, seepage, volume }

extension Quantity3Words on Quantity3 {
  String get plain => switch (this) {
        Quantity3.darcy => 'The Darcy velocity, K times the gradient',
        Quantity3.seepage => 'The seepage velocity, faster, through the pores',
        Quantity3.volume => 'A volume a second, not a speed at all',
      };
}

@immutable
class SeepRound {
  const SeepRound({
    required this.subject,
    required this.asked,
    required this.answer,
    required this.seep,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What the round asks for, in the words a problem would use.
  final String asked;
  final Quantity3 answer;
  final Seep seep;
  final String why;
  final String source;

  double get value => switch (answer) {
        Quantity3.darcy => seep.darcy,
        Quantity3.seepage => seep.seepage,
        Quantity3.volume => seep.flow,
      };
}

const seepRounds = <SeepRound>[
  SeepRound(
    subject: 'the lesson\'s own aquifer',
    asked:
        'How fast would a dye tracer released upstream actually travel '
        'through this sand?',
    answer: Quantity3.seepage,
    seep: Seep(
        conductivity: 5e-4, gradient: 0.02, porosity: 0.30, area: 200),
    why:
        'The seepage velocity, 3.33 times ten to the minus five meters a '
        'second. Darcy gives one times ten to the minus five, but that number '
        'assumes the water is using the whole face of the soil, grains '
        'included. Only three tenths of the face is void, so the water has to '
        'move three and a third times faster to get the same volume through. '
        'A tracer moves at the seepage velocity, always.',
    source: 'wr-gw-q1',
  ),
  SeepRound(
    subject: 'the number Darcy\'s law gives',
    asked: 'What is K times the hydraulic gradient, on its own?',
    answer: Quantity3.darcy,
    seep: Seep(
        conductivity: 5e-4, gradient: 0.02, porosity: 0.30, area: 200),
    why:
        'The Darcy velocity, also called the specific discharge. It has the '
        'units of a speed and it is not the speed of anything: it is the '
        'volume a second passing through a square meter of soil, grains and '
        'all. Useful for computing flow, misleading if you tell somebody how '
        'fast the contamination is moving.',
    source: 'wr-gw-q1',
  ),
  SeepRound(
    subject: 'the whole cross-section',
    asked:
        'The aquifer is 200 square meters in section. What is K times the '
        'gradient times that area?',
    answer: Quantity3.volume,
    seep: Seep(
        conductivity: 5e-4, gradient: 0.02, porosity: 0.30, area: 200),
    why:
        'A volume a second: two times ten to the minus three CUBIC meters a '
        'second. Multiplying a velocity by an area gives a discharge, and the '
        'lesson offers exactly this number as a wrong answer to a question '
        'about speed. Check the units before the arithmetic and it cannot '
        'catch you.',
    source: 'wr-gw-q1',
  ),
  SeepRound(
    subject: 'a tight silt',
    asked:
        'Porosity 0.45 and the gradient is steep. How fast does the water '
        'move between the grains?',
    answer: Quantity3.seepage,
    seep: Seep(
        conductivity: 1e-6, gradient: 0.05, porosity: 0.45, area: 50),
    why:
        'The seepage velocity again, and the ratio is smaller here: a '
        'porosity of 0.45 means nearly half the face is open, so the water '
        'only has to speed up by a factor of about two. The looser the soil, '
        'the closer the two velocities come, and they are only equal at a '
        'porosity of one, which is open water.',
    source: 'wr-gw-q1',
  ),
  SeepRound(
    subject: 'sizing a cutoff wall',
    asked:
        'How much water gets past the wall each second, through 80 square '
        'meters of gravel?',
    answer: Quantity3.volume,
    seep: Seep(
        conductivity: 2e-3, gradient: 0.01, porosity: 0.35, area: 80),
    why:
        'A volume, because the question asks how MUCH and not how fast. '
        'Darcy times the area, and the porosity does not enter it at all: '
        'the volume getting through does not care how the pore space is '
        'arranged, only the speed of an individual water particle does. That '
        'is the division of labor between the two.',
    source: 'wr-gw-q1',
  ),
  SeepRound(
    subject: 'reading a problem carefully',
    asked:
        'A question asks for the specific discharge through a clay liner. '
        'Which number does it want?',
    answer: Quantity3.darcy,
    seep: Seep(
        conductivity: 1e-9, gradient: 0.5, porosity: 0.50, area: 1000),
    why:
        'The Darcy velocity: specific discharge is another name for it, and '
        'the exam uses both. Three names are in play and two of them mean the '
        'same thing. Darcy velocity and specific discharge are K times the '
        'gradient; seepage velocity is that divided by the porosity, and it '
        'is the only one anything actually travels at.',
    source: 'wr-gw-q1',
  ),
];

class _WhichSpeedIsThatGameState extends State<WhichSpeedIsThatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-speed-is-that',
    chapterId: 'water-resources',
    total: seepRounds.length,
    sourceProblemIdOf: (round) => seepRounds[round].source,
  )..addListener(_onSession);

  Quantity3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SeepRound get _round => seepRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Speed Is That',
        closing:
            'Three quantities and they are easy to hand to the wrong '
            'question. The Darcy velocity, or specific discharge, is K times '
            'the gradient: the units of a speed, and the speed of nothing. '
            'The seepage velocity is that divided by the porosity, and it is '
            'what a tracer travels at, always the larger of the two. '
            'Multiply the Darcy velocity by the area and you have a volume a '
            'second, which is not a speed at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: seepageBrief,
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
            'WHICH OF THE THREE IS BEING ASKED FOR',
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
                  painter: SoilPainter(seep: r.seep, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$q = K i, \quad v = \dfrac{q}{n}, \quad Q = qA$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Quantity3.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Quantity3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT ONE',
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
