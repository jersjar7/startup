import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'clarifier_figures.dart';

/// Hours or Days — the second item for `water-treatment`.
///
/// An activated sludge plant has two clocks running in it and they are not
/// the same clock. The water goes through once and leaves: a few hours. The
/// solids are caught in the clarifier and returned to the basin, going round
/// and round until they are deliberately wasted: days to weeks. Confusing
/// them is the trap the lesson names, and the flow diagram makes the
/// difference obvious because the two paths are drawn apart.
class HoursOrDaysGame extends StatefulWidget {
  const HoursOrDaysGame({super.key});

  @override
  State<HoursOrDaysGame> createState() => _HoursOrDaysGameState();
}

/// Which of the two residence times the round is describing.
enum Stay { water, solids, neither }

extension StayWords on Stay {
  String get plain => switch (this) {
        Stay.water => 'The hydraulic time: the water, in hours',
        Stay.solids => 'The solids time: the sludge, in days',
        Stay.neither => 'Neither of those',
      };
}

@immutable
class ClockRound {
  const ClockRound({
    required this.subject,
    required this.asked,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Stay answer;
  final String why;
  final String source;

  Loop2? get highlight => switch (answer) {
        Stay.water => Loop2.water,
        Stay.solids => Loop2.solids,
        Stay.neither => null,
      };
}

const twoClockRounds = <ClockRound>[
  ClockRound(
    subject: 'volume over flow',
    asked:
        'A basin of 1,500 cubic meters takes 5,000 cubic meters a day. The '
        'answer, 0.3 days, is which of the two?',
    answer: Stay.water,
    why:
        'The hydraulic time, seven hours. Volume over flow is how long the '
        'WATER is in the tank, and nothing about it knows that solids are '
        'being recycled. The lesson offers exactly this 0.3 days as a wrong '
        'answer to a question about the solids time, and the giveaway is the '
        'magnitude: anything in hours is the water.',
    source: 'wr-wt-q3',
  ),
  ClockRound(
    subject: 'solids in, over solids out',
    asked:
        'The mass of solids held in the basin, divided by the mass leaving '
        'each day in the waste sludge and the effluent. Which is it?',
    answer: Stay.solids,
    why:
        'The solids time, and this is its definition: what is being held, '
        'over what is being lost each day. It comes out in days because the '
        'plant deliberately holds its bacteria far longer than its water. '
        'Both terms in the denominator count, and dropping the effluent '
        'solids gives 10.5 days instead of 8.8.',
    source: 'wr-wt-q3',
  ),
  ClockRound(
    subject: 'following one molecule',
    asked:
        'How long a particular molecule of water spends between the inlet '
        'and the outfall. Which time is that?',
    answer: Stay.water,
    why:
        'The hydraulic time. The water is drawn through the plant once and '
        'leaves, which is the top path on the diagram: in, through the basin, '
        'through the clarifier, out. Nothing sends it round again, so its '
        'time in the plant is just the volume it has to cross divided by the '
        'rate it is being pushed.',
    source: 'wr-wt-q3',
  ),
  ClockRound(
    subject: 'following one bacterium',
    asked:
        'How long an average bacterium stays in the plant before it leaves '
        'in the waste sludge. Which time is that?',
    answer: Stay.solids,
    why:
        'The solids time, which is what it is FOR. A bacterium settles in '
        'the clarifier and is pumped back to the basin, over and over, until '
        'it happens to leave in the waste stream. That is the lower loop on '
        'the diagram, and it is the reason the two times differ by a factor '
        'of thirty or more.',
    source: 'wr-wt-q3',
  ),
  ClockRound(
    subject: 'turning up the waste pump',
    asked:
        'The operator wastes more sludge each day, at the same flow and the '
        'same basin volume. Which of the two times changes?',
    answer: Stay.solids,
    why:
        'The solids time, and it goes DOWN: more solids leaving each day '
        'against the same mass held means each bacterium stays a shorter '
        'while. The hydraulic time does not move at all, because neither the '
        'volume nor the flow changed. This is the operator\'s main control '
        'lever, and it works on one clock only.',
    source: 'wr-wt-q3',
  ),
  ClockRound(
    subject: 'a number in the wrong units',
    asked:
        'A report quotes a residence time of 9 days for a conventional '
        'plant. Which of the two can it be?',
    answer: Stay.solids,
    why:
        'The solids time: 4 to 15 days is the usual range for a conventional '
        'plant, while the water is through in a few hours. The units are the '
        'quickest check there is. If a figure is in hours it is hydraulic, if '
        'it is in days it is solids, and a plant with a hydraulic time of 9 '
        'days would be a lagoon rather than an activated sludge works.',
    source: 'wr-wt-q3',
  ),
];

class _HoursOrDaysGameState extends State<HoursOrDaysGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'hours-or-days',
    chapterId: 'water-resources',
    total: twoClockRounds.length,
    sourceProblemIdOf: (round) => twoClockRounds[round].source,
  )..addListener(_onSession);

  Stay? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ClockRound get _round => twoClockRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Hours or Days',
        closing:
            'Two clocks, two paths. The water goes through once and is out '
            'in hours: volume over flow. The solids settle, are returned, and '
            'go round until they are wasted, which takes days: the mass held '
            'over the mass leaving each day. The units tell them apart, and '
            'so does the diagram, and the operator changes one of them with '
            'the waste pump without touching the other.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: residenceBrief,
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
            'WHICH OF THE TWO CLOCKS',
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
            height: 224,
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
                  painter: PlantPainter(
                    highlight: answered ? r.highlight : null,
                    note: answered
                        ? 'the path in ember is the one the round names'
                        : 'water across the top, solids round the bottom',
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\theta = \dfrac{V}{Q} \quad\quad \theta_c = \dfrac{V X_A}{Q_w X_w + Q_e X_e}$',
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Stay.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Stay.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER CLOCK',
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
