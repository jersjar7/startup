import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'wall_stability_figures.dart';

/// From the Toe or the Center — the second item for `retaining-walls`.
///
/// The lesson's own named trap: the working finds where the resultant
/// crosses the base, measured from the toe, and the formula that follows
/// wants how far that is from the MIDDLE. Reporting the first as the second
/// is the wrong answer the problem prints.
class FromTheToeOrTheCenterGame extends StatefulWidget {
  const FromTheToeOrTheCenterGame({super.key});

  @override
  State<FromTheToeOrTheCenterGame> createState() =>
      _FromTheToeOrTheCenterGameState();
}

@immutable
class LandingRound {
  const LandingRound({
    required this.subject,
    required this.asked,
    required this.wall,
    required this.showResultant,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Gravity wall;

  /// Where the resultant lands is the question in one round, so that round
  /// keeps it off the drawing.
  final bool showResultant;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's six foot base: the resultant lands 2.40 ft from the toe, so
/// 0.60 ft from the middle, comfortably inside the one foot allowed.
const _sixFoot = Gravity(
  baseWidth: 6,
  vertical: 5000,
  resisting: 18000,
  overturning: 6000,
);

/// And its eight foot base: 3.0 ft from the toe, so 1.0 ft out, against a
/// middle third of 1.33 ft. Inside, but not by much.
const _eightFoot = Gravity(
  baseWidth: 8,
  vertical: 8000,
  resisting: 30000,
  overturning: 6000,
);

const landingRounds = <LandingRound>[
  LandingRound(
    subject: 'two distances, one of them wanted',
    asked:
        'On this six foot base the resultant crosses 2.40 ft from the toe. '
        'The middle of the base is at 3.00 ft. Which distance is the '
        'eccentricity?',
    wall: _sixFoot,
    showResultant: true,
    options: [
      'The 2.40 ft from the toe',
      'The 3.00 ft to the middle',
      'The 0.60 ft between the resultant and the middle',
      'The 6.00 ft of the whole base',
    ],
    answer: 2,
    why:
        'The gap between the resultant and the MIDDLE, 0.60 ft. Eccentricity '
        'means off center, and the center is the reference. The 2.40 ft is a '
        'real number and a necessary one, but it is a step on the way, and '
        'the lesson offers it as a wrong answer because reporting it is the '
        'commonest slip in this calculation.',
    source: 'geo-rw-q2',
  ),
  LandingRound(
    subject: 'why the moments are subtracted first',
    asked:
        'Finding where the resultant lands starts by subtracting the '
        'overturning moment from the resisting one. Why subtract?',
    wall: _sixFoot,
    showResultant: false,
    options: [
      'Because the two moments turn the wall opposite ways, so what is left '
          'over is what positions the resultant',
      'Because the overturning moment is not real',
      'Because the difference is the factor of safety',
      'Because the moments have different units',
    ],
    answer: 0,
    why:
        'They act opposite ways about the toe, so the net of the two is what '
        'is left turning the wall, and dividing that by the vertical force is '
        'what places the resultant on the base. Forgetting to subtract puts '
        'the resultant too far from the toe, which is the lesson\'s other '
        'named trap here.',
    source: 'geo-rw-q2',
  ),
  LandingRound(
    subject: 'how far off center is allowed',
    asked:
        'The base is six feet wide. How far from the middle may the resultant '
        'land before it leaves the middle third?',
    wall: _sixFoot,
    showResultant: true,
    options: [
      'Two feet, a third of the base',
      'One foot, a sixth of the base',
      'Three feet, half the base',
      'Half a foot, a twelfth of the base',
    ],
    answer: 1,
    why:
        'A sixth of the base, so one foot here. The middle third is two feet '
        'wide and sits centered, so it reaches one foot either side of the '
        'middle. That is where the rule e no greater than B over 6 comes '
        'from: it is the same statement said two ways.',
    source: 'geo-rw-q2',
  ),
  LandingRound(
    subject: 'past the third',
    asked:
        'Suppose the resultant landed outside the middle third. What does '
        'that mean for the base?',
    wall: _sixFoot,
    showResultant: true,
    options: [
      'Nothing, as long as the factor of safety is met',
      'The whole base presses harder',
      'The heel would have to pull down on the soil, which it cannot',
      'The wall would tip immediately',
    ],
    answer: 2,
    why:
        'The arithmetic starts asking the soil for tension at the heel, and '
        'soil has none to give: that corner simply lifts off instead. It is '
        'not instant failure, but it is unwanted, and it means the tidy '
        'pressure formula no longer describes what is under the base.',
    source: 'geo-rw-q3',
  ),
  LandingRound(
    subject: 'the eight foot base',
    asked:
        'This base is eight feet wide and its resultant lands 3.00 ft from '
        'the toe, one foot off center. Is that inside the middle third?',
    wall: _eightFoot,
    showResultant: true,
    options: [
      'No: one foot is more than a sixth of eight feet',
      'Yes: the allowance is one and a third feet',
      'No: the resultant must be exactly central',
      'It cannot be told without the vertical force',
    ],
    answer: 1,
    why:
        'Yes, with a little room to spare. A sixth of eight feet is one and a '
        'third, and the resultant is one foot out. The wider the base, the '
        'more room the resultant has, which is one of the reasons widening a '
        'footing fixes so many wall problems at once.',
    source: 'geo-rw-q3',
  ),
  LandingRound(
    subject: 'what a student reported',
    asked:
        'On the six foot base a student reports an eccentricity of 2.40 ft. '
        'What have they actually reported?',
    wall: _sixFoot,
    showResultant: true,
    options: [
      'Half the base width',
      'The distance from the toe to the resultant',
      'The width of the middle third',
      'The net moment divided by the base',
    ],
    answer: 1,
    why:
        'The distance from the toe, which was the intermediate step. Since '
        '2.40 ft is well outside the one foot the middle third allows, a '
        'student who reports it and then checks the middle third will '
        'conclude that a perfectly sound wall has failed. The check catches '
        'the slip, if it is made.',
    source: 'geo-rw-q2',
  ),
];

class _FromTheToeOrTheCenterGameState extends State<FromTheToeOrTheCenterGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'from-the-toe-or-the-center',
    chapterId: 'geotechnical',
    total: landingRounds.length,
    sourceProblemIdOf: (round) => landingRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  LandingRound get _round => landingRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'From the Toe or the Center',
        closing:
            'Where the resultant crosses the base is measured from the toe. '
            'The eccentricity is measured from the MIDDLE, and it is the '
            'second of those the pressure formula wants. Keep it inside a '
            'sixth of the base either way and the whole base stays in '
            'contact with the soil.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: middleThirdBrief,
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
            'WHERE IT LANDS',
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
            height: 196,
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
                    showResultant: r.showResultant,
                    withPressure: false,
                    answered: false,
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
