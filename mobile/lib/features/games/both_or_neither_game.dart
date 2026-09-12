import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'soil_class_figures.dart';

/// Both or Neither — the third item for `soil-classification`.
///
/// A coarse soil is well graded only if BOTH coefficients pass, and the
/// lesson says so twice because one of them passing is the commonest reason
/// a soil gets the wrong second letter. The uniformity asks whether the
/// sample spans a wide range of sizes; the concavity asks whether the middle
/// of that range is actually represented rather than missing.
class BothOrNeitherGame extends StatefulWidget {
  const BothOrNeitherGame({super.key});

  @override
  State<BothOrNeitherGame> createState() => _BothOrNeitherGameState();
}

/// What the pair of coefficients says about the sample.
enum Graded2 { well, poorUniformity, poorShape, poorBoth }

@immutable
class GradeRound {
  const GradeRound({
    required this.subject,
    required this.asked,
    required this.soil,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Graded soil;
  final String why;
  final String source;

  /// The sieve numbers decide it.
  Graded2 get answer {
    if (soil.uniformEnough && soil.shapedRight) return Graded2.well;
    if (!soil.uniformEnough && !soil.shapedRight) return Graded2.poorBoth;
    return soil.uniformEnough ? Graded2.poorShape : Graded2.poorUniformity;
  }

  static String label(Graded2 which) => switch (which) {
        Graded2.well => 'Well graded: both coefficients pass',
        Graded2.poorUniformity =>
          'Poorly graded: the range of sizes is too narrow',
        Graded2.poorShape =>
          'Poorly graded: the middle sizes are missing',
        Graded2.poorBoth => 'Poorly graded: neither coefficient passes',
      };
}

const wellGradedRounds = <GradeRound>[
  GradeRound(
    subject: 'the lesson\'s own sand',
    asked:
        'A clean sand with D10 of 0.15, D30 of 0.50 and D60 of 2.0 '
        'millimeters. What is it?',
    soil: Graded(passing200: 4, passing4: 92, d10: 0.15, d30: 0.50, d60: 2.0),
    why:
        'Poorly graded, and only just: the uniformity comes to 13, well past '
        'the 6 a sand needs, but the concavity lands at 0.83 and the range it '
        'has to fall in is 1 to 3. One failure is enough. This is the '
        'lesson\'s own problem and the reason it says BOTH twice: the big '
        'uniformity is exactly what tempts people into calling it SW.',
    source: 'geo-sc-q2',
  ),
  GradeRound(
    subject: 'a properly graded sand',
    asked:
        'Another sand, D10 of 0.10, D30 of 0.45 and D60 of 1.2 millimeters. '
        'What is it?',
    soil: Graded(passing200: 3, passing4: 95, d10: 0.10, d30: 0.45, d60: 1.2),
    why:
        'Well graded. The uniformity is 12, clear of the 6 it needs, and the '
        'concavity comes to 1.7, inside the 1 to 3 band. A soil like this has '
        'grains of every size in it, so the small ones fill the gaps between '
        'the big ones and it compacts to something dense and strong. That is '
        'what the two coefficients are really asking about.',
    source: 'geo-sc-q2',
  ),
  GradeRound(
    subject: 'all one size',
    asked:
        'A beach sand: D10 of 0.30, D30 of 0.38 and D60 of 0.50 millimeters. '
        'What is it?',
    soil: Graded(passing200: 2, passing4: 99, d10: 0.30, d30: 0.38, d60: 0.50),
    why:
        'Poorly graded, because the sizes are all so nearly the same: the '
        'uniformity is only 1.7 against the 6 a sand needs. Uniform sand '
        'looks clean and handles nicely and compacts badly, since there is '
        'nothing small to fill the space between the grains. Its curve is '
        'nearly vertical, which is the shape to watch for.',
    source: 'geo-sc-q2',
  ),
  GradeRound(
    subject: 'a gravel on the same numbers',
    asked:
        'A gravel with a uniformity of 5 and a concavity of 2. A sand with '
        'those numbers would fail. What about this one?',
    soil: Graded(passing200: 1, passing4: 15, d10: 2.0, d30: 6.3, d60: 10.0),
    why:
        'Well graded, because a gravel only needs a uniformity of 4 where a '
        'sand needs 6. Same two numbers, different verdict, decided by a fork '
        'taken earlier at the No. 4 sieve. It is a small asymmetry and it is '
        'worth carrying, because a question can turn on nothing else.',
    source: 'geo-sc-q2',
  ),
  GradeRound(
    subject: 'a gap in the middle',
    asked:
        'A sample with plenty of coarse and plenty of fine but almost nothing '
        'in between: D10 of 0.2, D30 of 0.25 and D60 of 8.0 millimeters.',
    soil: Graded(passing200: 3, passing4: 45, d10: 0.2, d30: 0.25, d60: 8.0),
    why:
        'Poorly graded, and this is what the concavity is for. The uniformity '
        'is enormous, 40, because the sample really does span a wide range of '
        'sizes. But the D30 sits almost on top of the D10, which says the '
        'middle sizes are missing, and the concavity comes out at about 0.04. '
        'A gap graded soil looks varied and packs like neither of its halves.',
    source: 'geo-sc-q2',
  ),
  GradeRound(
    subject: 'neither one',
    asked:
        'A narrow sand whose middle is also off center: D10 of 0.40, D30 of '
        '0.45 and D60 of 0.90 millimeters.',
    soil: Graded(passing200: 2, passing4: 98, d10: 0.40, d30: 0.45, d60: 0.90),
    why:
        'Both fail: the uniformity is 2.3 against the 6 it needs, and the '
        'concavity is 0.56, under the band. Nothing subtle here, and it is '
        'the ordinary case for a natural sand deposit, which is why so much '
        'fill has to be blended before it is any use.',
    source: 'geo-sc-q2',
  ),
];

class _BothOrNeitherGameState extends State<BothOrNeitherGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'both-or-neither',
    chapterId: 'geotechnical',
    total: wellGradedRounds.length,
    sourceProblemIdOf: (round) => wellGradedRounds[round].source,
  )..addListener(_onSession);

  Graded2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  GradeRound get _round => wellGradedRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Both or Neither',
        closing:
            'Two coefficients, and a soil is well graded only if both pass. '
            'The uniformity asks whether the sample spans a wide range of '
            'sizes, and a gravel needs only 4 where a sand needs 6. The '
            'concavity asks whether the middle of that range is actually '
            'there, and it has to land between 1 and 3. A huge uniformity '
            'with a failing concavity is a gap graded soil, and it is poorly '
            'graded however wide its range looks.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: gradationBrief,
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
            'WELL GRADED OR NOT',
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
                  painter: SizeCurvePainter(soil: r.soil, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$C_u = \frac{D_{60}}{D_{10}}, \quad '
              r'C_c = \frac{D_{30}^2}{D_{10}D_{60}}$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Graded2.values) ...[
            _Choice(
              label: GradeRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Graded2.values.last) const SizedBox(height: 8),
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
