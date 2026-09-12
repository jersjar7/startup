import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'shear_strength_figures.dart';

/// Two Terms — the first item for `shear-strength`.
///
/// Shear strength is a constant plus something that grows with how hard the
/// grains are pressed together, and which of those two a soil has decides
/// how it behaves. A clean sand has only the growing part, so it is worth
/// nothing at the surface and a great deal at depth. A saturated clay loaded
/// quickly has only the constant part, so it is worth the same everywhere.
class TwoTermsGame extends StatefulWidget {
  const TwoTermsGame({super.key});

  @override
  State<TwoTermsGame> createState() => _TwoTermsGameState();
}

/// Which part of the criterion a round is about.
enum Term2 { cohesion, friction, both, neither }

@immutable
class TermRound2 {
  const TermRound2({
    required this.subject,
    required this.asked,
    required this.failure,
    this.markAt,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Failure failure;
  final double? markAt;
  final Term2 answer;
  final String why;
  final String source;

  static String label(Term2 which) => switch (which) {
        Term2.cohesion => 'The cohesion, the part that is there anyway',
        Term2.friction => 'The friction, the part that grows with pressing',
        Term2.both => 'Both of them together',
        Term2.neither => 'Neither: it has no strength at all',
      };
}

const _cPhiSoil = Failure(cohesion: 200, friction: 30);
const _cleanSand = Failure(cohesion: 0, friction: 34);
const _fastClay = Failure(cohesion: 1200, friction: 0);

const twoTermRounds = <TermRound2>[
  TermRound2(
    subject: 'the lesson\'s own soil',
    asked:
        'This soil has 200 pounds a square foot of cohesion and a friction '
        'angle of 30 degrees. On a plane pressed by 1,000, what is carrying '
        'the shear?',
    failure: _cPhiSoil,
    markAt: 1000,
    answer: Term2.both,
    why:
        'Both, and they add: 200 from the cohesion whatever happens, plus '
        'another 577 from the pressing. The lesson offers each of them alone '
        'as a wrong answer, and both mistakes are easy to make in a hurry '
        'because each looks like a complete calculation on its own.',
    source: 'geo-ss-q1',
  ),
  TermRound2(
    subject: 'a clean sand at the surface',
    asked:
        'A clean dry sand, with nothing pressing on the plane at all. What '
        'shear can it carry?',
    failure: _cleanSand,
    markAt: 0,
    answer: Term2.neither,
    why:
        'Nothing whatever. A sand has no cohesion, so its envelope starts at '
        'the origin, and with no normal stress there is no friction to call '
        'on either. That is why dry sand cannot stand in a vertical face and '
        'why a sand pile has a slope rather than a wall.',
    source: 'geo-ss-q2',
  ),
  TermRound2(
    subject: 'the same sand, well buried',
    asked:
        'The same sand, but now on a plane thirty feet down with plenty of '
        'soil pressing on it. What is carrying the shear?',
    failure: _cleanSand,
    markAt: 3600,
    answer: Term2.friction,
    why:
        'The friction alone, and by now it is a large number: the strength of '
        'a sand grows in proportion to how hard it is squeezed. Same material '
        'as the last round, nothing added to it, and a completely different '
        'strength, decided entirely by depth.',
    source: 'geo-ss-q2',
  ),
  TermRound2(
    subject: 'a clay loaded quickly',
    asked:
        'A saturated clay is loaded too fast for any water to leave. Its '
        'friction angle is taken as zero. What is carrying the shear?',
    failure: _fastClay,
    markAt: 2000,
    answer: Term2.cohesion,
    why:
        'The cohesion alone, and the envelope is a flat line: the clay is '
        'worth the same on a plane near the surface as on one far below it. '
        'The friction has not gone away, but with no time for water to leave, '
        'squeezing the sample harder just raises the pore pressure and the '
        'grains feel nothing extra.',
    source: 'geo-ss-q3',
  ),
  TermRound2(
    subject: 'pressing a fast-loaded clay harder',
    asked:
        'That same clay, on a plane pressed twice as hard. What does the '
        'strength do?',
    failure: _fastClay,
    markAt: 4000,
    answer: Term2.cohesion,
    why:
        'Nothing: still the cohesion, still the same number. A flat envelope '
        'means the strength does not care how hard the plane is pressed, '
        'which is the whole meaning of the zero friction angle. It is why an '
        'undrained clay can be described by a single strength for a whole '
        'layer, and why that strength is the one a quick site investigation '
        'reports.',
    source: 'geo-ss-q3',
  ),
  TermRound2(
    subject: 'which soils have which',
    asked:
        'A clean sand and a saturated clay under fast loading. Which of the '
        'two terms does the SAND have?',
    failure: _cleanSand,
    markAt: 1800,
    answer: Term2.friction,
    why:
        'Friction only, which is the mirror of the clay. Sand grains have '
        'nothing sticking them together, so everything they can carry comes '
        'from being pressed; a fast-loaded clay has everything from what '
        'holds it together and nothing from pressing. Most real soils sit '
        'somewhere between, with a bit of both.',
    source: 'geo-ss-q2',
  ),
];

class _TwoTermsGameState extends State<TwoTermsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'two-terms',
    chapterId: 'geotechnical',
    total: twoTermRounds.length,
    sourceProblemIdOf: (round) => twoTermRounds[round].source,
  )..addListener(_onSession);

  Term2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TermRound2 get _round => twoTermRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Two Terms',
        closing:
            'Strength is a constant plus something that grows with pressing. '
            'A clean sand has only the growing part, so it is worth nothing '
            'at the surface and a great deal at depth, which is why sand '
            'cannot stand in a vertical face. A saturated clay loaded quickly '
            'has only the constant part, so its envelope is flat and one '
            'number describes the whole layer. Most soils have some of each, '
            'and both terms are added.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: mohrCoulombBrief,
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
            'WHAT IS CARRYING IT',
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
            height: 208,
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
                    markAt: r.markAt,
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
              r"$\tau_f = c' + \sigma_N' \tan\phi'$",
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Term2.values) ...[
            _Choice(
              label: TermRound2.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Term2.values.last) const SizedBox(height: 8),
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
