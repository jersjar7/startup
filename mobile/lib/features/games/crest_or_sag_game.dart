import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'vertical_curve_figures.dart';

/// Crest or Sag — the first item for `vertical-curves`.
///
/// Two formulas that look alike and are set by quite different things. A
/// crest is limited by what the driver can SEE over the hill. A sag is
/// limited at night by how far the HEADLIGHTS reach. The lesson's warning
/// is that the denominators are not interchangeable.
class CrestOrSagGame extends StatefulWidget {
  const CrestOrSagGame({super.key});

  @override
  State<CrestOrSagGame> createState() => _CrestOrSagGameState();
}

@immutable
class CriterionRound {
  const CriterionRound({
    required this.subject,
    required this.asked,
    required this.criterion,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Criterion criterion;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's crest: eight per cent of break and 500 ft to see, which
/// wants 927 ft of curve.
const _theCrest = Criterion(breakSize: 8, sight: 500, sag: false);

/// And its sag: the same break, 300 ft to see, which wants 497 ft.
const _theSag = Criterion(breakSize: 8, sight: 300, sag: true);

/// A gentle crest where the sight distance runs past the curve.
const _shortCrest = Criterion(breakSize: 2, sight: 600, sag: false);

const criterionRounds = <CriterionRound>[
  CriterionRound(
    subject: 'what limits a crest',
    asked:
        'A crest curve has to be long enough for what? The driver is at the '
        'left of this drawing.',
    criterion: _theCrest,
    options: [
      'For the headlights to reach',
      'For the driver to see over the hill to something low on the road ahead',
      'For the car not to leave the ground',
      'For drainage to run off it',
    ],
    answer: 1,
    why:
        'For the sight line to clear the hill. The hump itself is what blocks '
        'the view, so the flatter the curve the further ahead the driver can '
        'see. It is a daylight problem: headlights have nothing to do with '
        'it.',
    source: 'trans-vc-q1',
  ),
  CriterionRound(
    subject: 'what limits a sag',
    asked: 'And a sag curve, at night. What sets its length?',
    criterion: _theSag,
    options: [
      'The sight line over the hill, as before',
      'The comfort of the passengers only',
      'How far the headlight beam reaches along the road',
      'Nothing: a sag curve has no sight problem',
    ],
    answer: 2,
    why:
        'The headlights. In a dip the driver can see plenty of sky and road '
        'ahead by day, but at night the beam tips only about a degree up from '
        'the car, and in a sag the road curves away from it. The beam is what '
        'runs out, so that is what the length is set by.',
    source: 'trans-vc-q3',
  ),
  CriterionRound(
    subject: 'the two denominators',
    asked:
        'The crest formula divides by 2,158. What does the sag formula divide '
        'by?',
    criterion: _theSag,
    options: [
      '2,158 as well',
      '400 plus three and a half times the sight distance',
      'The grade difference',
      'The design speed',
    ],
    answer: 1,
    why:
        'By 400 plus 3.5 S, which moves when the sight distance moves, while '
        'the crest denominator is a constant. That is the practical '
        'difference to remember: if the denominator does not contain S, you '
        'are working a crest.',
    source: 'trans-vc-q3',
  ),
  CriterionRound(
    subject: 'the wrong rule on the right curve',
    asked:
        'For this sag the answer is 497 ft. A student reports 334 ft. What '
        'did they do?',
    criterion: _theSag,
    options: [
      'Used the crest denominator on a sag curve',
      'Forgot to square the sight distance',
      'Used the wrong grade difference',
      'Halved the answer',
    ],
    answer: 0,
    why:
        'Used 2,158 on a sag. It gives 334 ft, a third short of what the '
        'headlights actually need, which at night is the difference between '
        'seeing something and arriving at it. The two formulas are printed '
        'next to each other in the handbook, which is exactly why this '
        'happens.',
    source: 'trans-vc-q3',
  ),
  CriterionRound(
    subject: 'the assumption you start with',
    asked:
        'Both criteria come in two versions, for the sight distance fitting '
        'inside the curve or running past it. How does a problem start?',
    criterion: _theCrest,
    options: [
      'By measuring the curve first',
      'By assuming the sight distance fits inside the curve, working out the '
          'length, then checking that it does',
      'By assuming it runs past the curve',
      'By averaging the two answers',
    ],
    answer: 1,
    why:
        'Assume it fits inside, work the length, then check the answer '
        'against the sight distance. Here 927 ft of curve against 500 ft of '
        'sight distance, so the assumption held. If the length had come out '
        'below the sight distance, the other version of the formula would be '
        'the one to use.',
    source: 'trans-vc-q1',
  ),
  CriterionRound(
    subject: 'when the check fails',
    asked:
        'On this gentle crest the first formula gives a length well under the '
        'sight distance. What does that mean?',
    criterion: _shortCrest,
    options: [
      'The curve is impossible',
      'The answer stands anyway',
      'The assumption was wrong, so the other version of the formula is the '
          'one that applies',
      'The sight distance must be recalculated',
    ],
    answer: 2,
    why:
        'The assumption failed, so switch formulas. It happens when the break '
        'in grade is small: a gentle curve is short, and the driver can see '
        'right past the end of it. Nothing is wrong with the road, only with '
        'the version of the formula first reached for.',
    source: 'trans-vc-q1',
  ),
];

class _CrestOrSagGameState extends State<CrestOrSagGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'crest-or-sag',
    chapterId: 'transportation',
    total: criterionRounds.length,
    sourceProblemIdOf: (round) => criterionRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  CriterionRound get _round => criterionRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Crest or Sag',
        closing:
            'A crest is set by what the driver can see over the hill and '
            'divides by 2,158, a constant. A sag is set at night by how far '
            'the headlights reach and divides by 400 plus three and a half '
            'times the sight distance, which moves with it. Assume the sight '
            'distance fits inside the curve, work the length, then check it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: crestSagBrief,
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
            'WHICH RULE APPLIES',
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
            height: 210,
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
                  painter: CriterionPainter(
                    criterion: r.criterion,
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
