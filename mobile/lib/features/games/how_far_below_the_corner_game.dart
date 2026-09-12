import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'vertical_curve_figures.dart';
import 'lesson_brief.dart';

/// How Far Below the Corner — the tangent offset, taught here as well.
///
/// The surveying chapter teaches this as two elevations at one station. A
/// student who comes to Transportation first would otherwise never meet it,
/// so it is here too, asked the way a highway designer meets it: how far
/// the finished road sits from the corner the grades make.
class HowFarBelowTheCornerGame extends StatefulWidget {
  const HowFarBelowTheCornerGame({super.key});

  @override
  State<HowFarBelowTheCornerGame> createState() => _HowFarBelowTheCornerGameState();
}

@immutable
class PviOffsetRound {
  const PviOffsetRound({
    required this.subject,
    required this.asked,
    required this.curve,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Vertical curve;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own curve: plus three into minus five over 800 ft, which
/// passes 8.0 ft below the corner where the grades cross.
const _lessonCurve = Vertical(gradeIn: 3, gradeOut: -5, length: 800);

/// The same grades stretched over twice the length.
const _longer = Vertical(gradeIn: 3, gradeOut: -5, length: 1600);

/// A sag, which misses its corner the other way.
const _sag = Vertical(gradeIn: -4, gradeOut: 4, length: 800);

const pviOffsetRounds = <PviOffsetRound>[
  PviOffsetRound(
    subject: 'how far off the corner',
    asked:
        'Plus three into minus five over 800 ft. How far does the road pass '
        'from the corner where the two grades cross?',
    curve: _lessonCurve,
    options: [
      'Sixteen feet',
      'Eight feet: the break as a decimal, times the length, over eight',
      'Four feet',
      'Thirty two feet',
    ],
    answer: 1,
    why:
        'Eight feet. The break is 0.08 as a decimal, times 800 is 64, over '
        'eight is 8. The lesson prints 16, 4 and 32, which are the same sum '
        'with a four, a sixteen and a two on the bottom, so the number on '
        'the bottom is the whole question here.',
    source: 'trans-vc-q2',
  ),
  PviOffsetRound(
    subject: 'where the eight comes from',
    asked: 'Why is the divisor eight, rather than four?',
    curve: _lessonCurve,
    options: [
      'It is arbitrary, and worth memorizing',
      'Because the offset grows with the SQUARE of the distance, so half way '
          'along is a quarter of the way to the full offset',
      'Because there are eight stations in a curve',
      'Because the grades are in per cent',
    ],
    answer: 1,
    why:
        'From the parabola. Halving the distance quarters the offset, and the '
        'halving and the quartering together make the eight. Using a four '
        'doubles the answer, which is the wrong answer the lesson prints '
        'first on its list.',
    source: 'trans-vc-q2',
  ),
  PviOffsetRound(
    subject: 'a longer curve',
    asked:
        'The same two grades are joined over 1,600 ft instead of 800. What '
        'happens to the offset?',
    curve: _longer,
    options: [
      'It doubles, to sixteen feet',
      'It halves',
      'It is unchanged',
      'It quadruples',
    ],
    answer: 0,
    why:
        'It doubles, because the length sits in the formula with no power on '
        'it. A longer curve is a gentler ride and it drops the road further '
        'below the hilltop, which costs excavation. Every vertical curve is '
        'that trade.',
    source: 'trans-vc-q2',
  ),
  PviOffsetRound(
    subject: 'which side of the corner',
    asked: 'In a sag, which way does the road miss the corner?',
    curve: _sag,
    options: [
      'Below it, as on a crest',
      'Above it, by the same sort of amount',
      'It passes exactly through it',
      'It depends on the design speed',
    ],
    answer: 1,
    why:
        'Above it. The corner in a sag is a dip no vehicle could take, and '
        'the road rides over it. The arithmetic is identical and only the '
        'direction changes, which is why the formula is usually quoted as a '
        'size with the direction left to the drawing.',
    source: 'trans-vc-q3',
  ),
  PviOffsetRound(
    subject: 'what the offset is for',
    asked:
        'Why does a designer want this offset rather than just the curve '
        'length?',
    curve: _lessonCurve,
    options: [
      'It sets the design speed',
      'It is a real elevation difference: the corner is known from the '
          'grades, so the offset is what the earthwork has to provide',
      'It gives the sight distance directly',
      'It is only used for drainage',
    ],
    answer: 1,
    why:
        'Because it is a height on the ground. The corner elevation follows '
        'from the two grades, and the offset is how far the finished road '
        'sits from it, so it is what every station elevation and every yard '
        'of cut is worked from. A length alone does not tell the machine '
        'where to go.',
    source: 'trans-vc-q2',
  ),
  PviOffsetRound(
    subject: 'the decimal',
    asked:
        'A student puts the break in as 8 rather than 0.08 and gets 800 ft. '
        'What went wrong?',
    curve: _lessonCurve,
    options: [
      'The length was wrong',
      'The break goes in as a decimal, not as a number of per cent',
      'They used the wrong divisor',
      'Nothing: 800 ft is right',
    ],
    answer: 1,
    why:
        'Per cent went in where a decimal belonged, and the answer came out a '
        'hundred times too big. Eight hundred feet of offset on an eight '
        'hundred foot curve is its own giveaway: the road would be below the '
        'corner by the length of the curve.',
    source: 'trans-vc-q2',
  ),
];

class _HowFarBelowTheCornerGameState extends State<HowFarBelowTheCornerGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-far-below-the-corner',
    chapterId: 'transportation',
    total: pviOffsetRounds.length,
    sourceProblemIdOf: (round) => pviOffsetRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  PviOffsetRound get _round => pviOffsetRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Far Below the Corner',
        closing:
            'The road misses the corner where the grades cross by the '
            'break as a DECIMAL times the length, over eight. Below it on a '
            'crest, above it in a sag. The eight comes from the parabola, '
            'the length scales the answer straight, and per cent in place of '
            'a decimal makes it a hundred times too big.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: cornerOffsetBrief,
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
            'MISSING THE CORNER',
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
            height: 206,
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
                  painter: VerticalCurvePainter(
                    curve: r.curve,
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
