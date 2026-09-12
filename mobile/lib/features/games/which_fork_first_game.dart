import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'soil_class_figures.dart';

/// Which Fork First — the first item for `soil-classification`.
///
/// Classification is a decision tree and the marks are lost at the top of
/// it, not the bottom. The first question is always the No. 200 sieve, since
/// coarse soils are judged on their gradation and fine ones on their
/// plasticity, and the two halves of the tree share nothing at all. Take the
/// wrong branch and the rest of the work, however careful, answers a
/// different question.
class WhichForkFirstGame extends StatefulWidget {
  const WhichForkFirstGame({super.key});

  @override
  State<WhichForkFirstGame> createState() => _WhichForkFirstGameState();
}

/// Where the soil goes next.
enum Fork { gravel, sand, plasticity, retest }

@immutable
class ForkRound {
  const ForkRound({
    required this.subject,
    required this.asked,
    required this.soil,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Graded soil;
  final Fork answer;
  final String why;
  final String source;

  static String label(Fork which) => switch (which) {
        Fork.gravel => 'Coarse, and a gravel: check the gradation',
        Fork.sand => 'Coarse, and a sand: check the gradation',
        Fork.plasticity => 'Fine: take it to the plasticity chart',
        Fork.retest => 'Not enough to say yet',
      };
}

const forkRounds = <ForkRound>[
  ForkRound(
    subject: 'the lesson\'s own clay',
    asked:
        'Eighty per cent of this sample passes the No. 200 sieve. Where does '
        'it go?',
    soil: Graded(
        passing200: 80, passing4: 98, d10: 0.001, d30: 0.004, d60: 0.02),
    answer: Fork.plasticity,
    why:
        'To the plasticity chart. More than half the sample passes the No. '
        '200, so it is FINE grained, and a fine soil is classified by how it '
        'behaves when wet rather than by the sizes of its grains. Gradation '
        'coefficients mean nothing here and the sieve curve is not the '
        'question.',
    source: 'geo-sc-q1',
  ),
  ForkRound(
    subject: 'the lesson\'s own sand',
    asked:
        'Less than five per cent of this one passes the No. 200, and most of '
        'the rest passes the No. 4. Where does it go?',
    soil: Graded(passing200: 4, passing4: 92, d10: 0.15, d30: 0.50, d60: 2.0),
    answer: Fork.sand,
    why:
        'Coarse, and a sand. The first fork is the No. 200 and it comes out '
        'coarse; the second is the No. 4, and since most of the coarse '
        'fraction passes it, the grains are sand sized rather than gravel. '
        'Now, and only now, do the two gradation coefficients matter.',
    source: 'geo-sc-q2',
  ),
  ForkRound(
    subject: 'held on the No. 4',
    asked:
        'Two per cent passes the No. 200, and most of the sample is held back '
        'by the No. 4. Where does this one go?',
    soil: Graded(passing200: 2, passing4: 20, d10: 2.0, d30: 8.0, d60: 25.0),
    answer: Fork.gravel,
    why:
        'A gravel, and worth knowing because the gravel gets an easier '
        'gradation test: it needs a uniformity of only 4 where a sand needs '
        '6. Same soil description, same two coefficients, different pass '
        'mark, which is why naming the branch matters before the checking '
        'starts.',
    source: 'geo-sc-q2',
  ),
  ForkRound(
    subject: 'right on the line',
    asked:
        'Exactly half of a sample passes the No. 200 and half is retained. '
        'Which way does it go?',
    soil: Graded(
        passing200: 50, passing4: 85, d10: 0.002, d30: 0.02, d60: 0.35),
    answer: Fork.plasticity,
    why:
        'Fine. The rule is that MORE than half retained makes it coarse, so a '
        'sample split exactly down the middle does not clear that bar and '
        'goes to the plasticity chart. Exam numbers rarely land here, but '
        'knowing which side of the boundary belongs to which branch is the '
        'sort of thing a question is built around.',
    source: 'geo-sc-q1',
  ),
  ForkRound(
    subject: 'the sixty per cent case',
    asked:
        'Sixty per cent of this sample passes the No. 200 and it has a liquid '
        'limit of 55. Where does it go?',
    soil: Graded(
        passing200: 60, passing4: 95, d10: 0.002, d30: 0.01, d60: 0.075),
    answer: Fork.plasticity,
    why:
        'Fine again, which is the lesson\'s hard problem. Sixty per cent '
        'passing is a majority, so the plasticity chart decides it, and the '
        'liquid limit of 55 is exactly the number the chart wants. Notice '
        'that the sample still has forty per cent of coarse grains in it and '
        'they play no part in the classification at all.',
    source: 'geo-sc-q3',
  ),
  ForkRound(
    subject: 'a clean gravel',
    asked:
        'Nothing at all passes the No. 200 and only a tenth passes the No. 4. '
        'Where does it go?',
    soil: Graded(passing200: 0, passing4: 10, d10: 4.0, d30: 12.0, d60: 30.0),
    answer: Fork.gravel,
    why:
        'A gravel, and a clean one: with no fines to speak of, the '
        'classification is decided entirely by the shape of its grain size '
        'curve. The plasticity chart never enters into it, because there is '
        'nothing plastic in the sample to put on it.',
    source: 'geo-sc-q2',
  ),
];

class _WhichForkFirstGameState extends State<WhichForkFirstGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-fork-first',
    chapterId: 'geotechnical',
    total: forkRounds.length,
    sourceProblemIdOf: (round) => forkRounds[round].source,
  )..addListener(_onSession);

  Fork? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ForkRound get _round => forkRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Fork First',
        closing:
            'The No. 200 sieve asks the first question every time: more than '
            'half retained and the soil is coarse, judged on the shape of its '
            'grain size curve. Otherwise it is fine, judged on the plasticity '
            'chart, and its coarse grains play no part at all. Coarse soils '
            'then split at the No. 4 into gravel and sand, which matters '
            'because the gravel gets the easier gradation test.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: forkBrief,
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
            'WHERE DOES THIS ONE GO',
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
              r'$\text{No. 200 first, then No. 4}$',
              style: const TextStyle(fontSize: 14, color: AppColors.ink3),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Fork.values) ...[
            _Choice(
              label: ForkRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Fork.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE BRANCH' : 'NOT THAT ONE',
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
