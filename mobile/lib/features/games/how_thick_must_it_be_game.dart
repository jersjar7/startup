import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pavement_figures.dart';

/// How Thick Must It Be — the second item for `pavement-design`.
///
/// The same sum read backwards. With a target structural number and every
/// course but one fixed, what is left over decides the missing thickness,
/// and the drainage coefficient on that course decides how far the leftover
/// goes.
class HowThickMustItBeGame extends StatefulWidget {
  const HowThickMustItBeGame({super.key});

  @override
  State<HowThickMustItBeGame> createState() => _HowThickMustItBeGameState();
}

@immutable
class ThicknessRound {
  const ThicknessRound({
    required this.subject,
    required this.asked,
    required this.pavement,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Pavement pavement;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own problem: four inches of asphalt and twelve of a subbase
/// that drains at 0.80, against a target of 4.0. The base has to make up
/// 1.18, which at 0.14 an inch is about eight and a half inches.
const _needsABase = Pavement(
  required_: 4.0,
  courses: [
    Course(name: 'asphalt', coefficient: 0.44, thickness: 4),
    Course(name: 'subbase', coefficient: 0.11, thickness: 12, drainage: 0.80),
  ],
);

/// The same, but with the subbase draining properly.
const _wellDrained = Pavement(
  required_: 4.0,
  courses: [
    Course(name: 'asphalt', coefficient: 0.44, thickness: 4),
    Course(name: 'subbase', coefficient: 0.11, thickness: 12),
  ],
);

/// A section that already reaches the target.
const _alreadyThere = Pavement(
  required_: 2.5,
  courses: [
    Course(name: 'asphalt', coefficient: 0.44, thickness: 4),
    Course(name: 'subbase', coefficient: 0.11, thickness: 12, drainage: 0.80),
  ],
);

const thicknessRounds = <ThicknessRound>[
  ThicknessRound(
    subject: 'reading the sum backwards',
    asked:
        'The target is 4.0. The asphalt and the subbase are fixed. How is the '
        'base thickness found?',
    pavement: _needsABase,
    options: [
      'Divide the target by the number of courses',
      'Take what the other courses give away from the target, then divide by '
          'what an inch of base is worth',
      'Make the base as thick as the subbase',
      'Multiply the target by the base coefficient',
    ],
    answer: 1,
    why:
        'Subtract, then divide. The other courses give 1.76 and 1.06, so 1.18 '
        'is still needed, and an inch of base is worth 0.14, so about eight '
        'and a half inches of it are wanted. Same equation as before, read '
        'the other way.',
    source: 'trans-pd-q2',
  ),
  ThicknessRound(
    subject: 'the drainage on the subbase',
    asked:
        'The subbase here has a drainage coefficient of 0.80. What does that '
        'do to the base thickness needed?',
    pavement: _needsABase,
    options: [
      'Nothing: drainage belongs to the subbase alone',
      'It makes the base thinner',
      'It makes the base thicker, since the subbase now contributes less',
      'It cancels out of the equation',
    ],
    answer: 2,
    why:
        'Thicker. The subbase gives 1.06 instead of 1.32, so the base has to '
        'find a quarter of a structural number more, which is nearly two '
        'extra inches. Treating the poorly drained subbase as though it '
        'drained well would leave the pavement short.',
    source: 'trans-pd-q2',
  ),
  ThicknessRound(
    subject: 'the same section, drained',
    asked:
        'Suppose the subbase drained properly, at a coefficient of 1.0. What '
        'happens to the base thickness required?',
    pavement: _wellDrained,
    options: [
      'It falls, to about six and a half inches',
      'It rises',
      'It is unchanged',
      'The base can be left out',
    ],
    answer: 0,
    why:
        'It falls by about two inches, because the subbase is now worth 1.32 '
        'rather than 1.06. Drainage is cheap compared with pavement: a ditch '
        'and a daylighted subbase can save more thickness than they cost, '
        'which is why the coefficient is in the equation at all.',
    source: 'trans-pd-q2',
  ),
  ThicknessRound(
    subject: 'when nothing more is needed',
    asked:
        'This same section is checked against a target of only 2.5. What does '
        'the sum give for the base?',
    pavement: _alreadyThere,
    options: [
      'About eight inches',
      'A negative thickness, which means the two courses already meet the '
          'target',
      'Exactly zero',
      'The target cannot be met',
    ],
    answer: 1,
    why:
        'The arithmetic comes out negative, which is the equation telling you '
        'the section is already there. A negative required thickness is not a '
        'mistake, it is a signal, and in practice it means a minimum '
        'construction thickness governs rather than the structural number.',
    source: 'trans-pd-q2',
  ),
  ThicknessRound(
    subject: 'trading between courses',
    asked:
        'An inch of asphalt is added instead. How much base could come out '
        'while keeping the same structural number?',
    pavement: _needsABase,
    options: [
      'One inch',
      'About three inches, since 0.44 buys about three times what 0.14 does',
      'About half an inch',
      'None: the courses cannot be traded',
    ],
    answer: 1,
    why:
        'Three inches or so. The trade always runs through the coefficients, '
        'and this is the calculation a contractor makes when asphalt or '
        'aggregate prices move. Whether it is worth doing is an economics '
        'question, not a structural one.',
    source: 'trans-pd-q2',
  ),
  ThicknessRound(
    subject: 'what the target came from',
    asked:
        'Where does the required structural number itself come from?',
    pavement: _needsABase,
    options: [
      'The thickness of the asphalt',
      'The traffic the road must carry and the support the subgrade gives',
      'The drainage coefficients',
      'The cost of the materials',
    ],
    answer: 1,
    why:
        'Traffic and subgrade. Heavier traffic and a softer subgrade both '
        'push the required number up. That is the step before this one, and '
        'it is why two roads with the same section can be fine in one place '
        'and fail in another.',
    source: 'trans-pd-q2',
  ),
];

class _HowThickMustItBeGameState extends State<HowThickMustItBeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-thick-must-it-be',
    chapterId: 'transportation',
    total: thicknessRounds.length,
    sourceProblemIdOf: (round) => thicknessRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  ThicknessRound get _round => thicknessRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Thick Must It Be',
        closing:
            'Take what the fixed courses give away from the target, then '
            'divide by what an inch of the missing course is worth. A poorly '
            'drained subbase gives less, so the base has to give more. And a '
            'negative answer is not an error: it means the section already '
            'meets the number.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: layerThicknessBrief,
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
            'SOLVING FOR A COURSE',
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
            height: 216,
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
                  painter: PavementPainter(
                    pavement: r.pavement,
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
