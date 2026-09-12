import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'shear_strength_figures.dart';

/// Drained or Not — the second item for `shear-strength`.
///
/// Soil strength comes in two matched sets and mixing them is the trap the
/// lesson names outright. Effective parameters go with effective stresses
/// and describe the soil once the water has had time to move. Undrained
/// parameters go with total stresses and describe a saturated clay loaded
/// faster than its water can escape. Which set a problem wants is a question
/// about TIME, not about the soil.
class DrainedOrNotGame extends StatefulWidget {
  const DrainedOrNotGame({super.key});

  @override
  State<DrainedOrNotGame> createState() => _DrainedOrNotGameState();
}

/// Which set of parameters the situation calls for.
enum Set2 { drained, undrained, either }

@immutable
class DrainRound {
  const DrainRound({
    required this.subject,
    required this.asked,
    required this.failure,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Failure failure;
  final Set2 answer;
  final String why;
  final String source;

  static String label(Set2 which) => switch (which) {
        Set2.drained =>
          'The effective set, with effective stresses',
        Set2.undrained =>
          'The undrained set, with total stresses and no friction angle',
        Set2.either => 'Either: they give the same answer here',
      };
}

const _effective = Failure(cohesion: 100, friction: 28);
const _undrained = Failure(cohesion: 1200, friction: 0);
const _sand = Failure(cohesion: 0, friction: 34);

const drainRounds = <DrainRound>[
  DrainRound(
    subject: 'a tank filled overnight',
    asked:
        'A steel tank on a soft saturated clay is filled in a day. Which set '
        'of parameters describes the clay while it is being filled?',
    failure: _undrained,
    answer: Set2.undrained,
    why:
        'The undrained set. A day is nothing to a clay: no water leaves, so '
        'the extra load goes straight into the pore water and the grains feel '
        'no more than they did. The strength available is the undrained one, '
        'a single number with no friction angle, and this is the case that '
        'governs the tank.',
    source: 'geo-ss-q3',
  ),
  DrainRound(
    subject: 'the same tank, years later',
    asked:
        'The same tank, twenty years on, with the clay long since drained. '
        'Which set describes it now?',
    failure: _effective,
    answer: Set2.drained,
    why:
        'The effective set. Given time the excess pore pressure squeezes out, '
        'the grains take up the load, and the clay ends up STRONGER than it '
        'was on the day the tank was filled. A soft clay is usually at its '
        'most dangerous right at the start, which is the opposite of how most '
        'materials behave.',
    source: 'geo-ss-q1',
  ),
  DrainRound(
    subject: 'a clean sand under a footing',
    asked:
        'A footing is built on a clean sand. Which set describes the sand '
        'during construction?',
    failure: _sand,
    answer: Set2.either,
    why:
        'Either, because a sand drains as fast as it is loaded: there is no '
        'undrained condition to speak of. Whatever water needs to move has '
        'already moved by the time the load is on, so the effective '
        'parameters apply from the start, and a separate undrained case would '
        'be describing a moment that never exists.',
    source: 'geo-ss-q2',
  ),
  DrainRound(
    subject: 'the mixing trap',
    asked:
        'Somebody uses the effective friction angle with TOTAL stresses. What '
        'is wrong with that?',
    failure: _effective,
    answer: Set2.drained,
    why:
        'The parameters and the stresses have to come from the same set. An '
        'effective friction angle multiplies an EFFECTIVE normal stress, so '
        'feeding it a total stress overstates the strength by the pore '
        'pressure times the tangent, which below the water table is a great '
        'deal. The lesson calls this the common exam trap, and it is common '
        'in practice too.',
    source: 'geo-ss-q1',
  ),
  DrainRound(
    subject: 'why the angle goes to zero',
    asked:
        'Why is the friction angle taken as zero for a saturated clay loaded '
        'quickly?',
    failure: _undrained,
    answer: Set2.undrained,
    why:
        'Because squeezing it harder does not press the grains together any '
        'harder. With no water able to leave, extra all-round pressure goes '
        'entirely into the pore water, the effective stress is unchanged, and '
        'so is the strength. Plot several such tests and their circles all '
        'have the same radius, so the envelope through their tops is flat.',
    source: 'geo-ss-q3',
  ),
  DrainRound(
    subject: 'a slope that has stood for years',
    asked:
        'A long-standing clay slope is being checked for stability against a '
        'slow rise in the water table. Which set?',
    failure: _effective,
    answer: Set2.drained,
    why:
        'The effective set, because the change is slow enough for the water '
        'to keep up. Long-term stability is always an effective stress '
        'question, and the rising water table lowers the effective stresses '
        'and therefore the strength, which is exactly how a slope that stood '
        'for decades comes to move in a wet winter.',
    source: 'geo-ss-q1',
  ),
];

class _DrainedOrNotGameState extends State<DrainedOrNotGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'drained-or-not',
    chapterId: 'geotechnical',
    total: drainRounds.length,
    sourceProblemIdOf: (round) => drainRounds[round].source,
  )..addListener(_onSession);

  Set2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DrainRound get _round => drainRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Drained or Not',
        closing:
            'Which set a problem wants is a question about time. Faster than '
            'the water can move, a saturated clay is described by its '
            'undrained strength with total stresses and no friction angle. '
            'Given time, by effective parameters with effective stresses, and '
            'it ends up stronger than it started. A sand drains as fast as it '
            'is loaded, so the effective set applies throughout. Never take '
            'one parameter from one set and one stress from the other.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: drainedBrief,
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
            'WHICH SET OF PARAMETERS',
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
            height: 200,
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
                    // The shape of the envelope IS the answer here, so it
                    // stays off the drawing until the round is over.
                    reveal: answered,
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
              r"$c', \phi' \text{ with } \sigma' \qquad c_u, \phi_u = 0 "
              r"\text{ with } \sigma$",
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Set2.values) ...[
            _Choice(
              label: DrainRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Set2.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SET' : 'NOT THAT ONE',
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
