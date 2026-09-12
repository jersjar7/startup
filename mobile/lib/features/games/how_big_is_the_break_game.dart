import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'vertical_curve_figures.dart';

/// How Big Is the Break — the second item for `vertical-curves`.
///
/// Everything about a vertical curve is driven by A, the algebraic
/// difference between the two grades. Plus three to minus five is a break of
/// EIGHT, not two, and getting that subtraction wrong halves or doubles
/// every answer that follows it.
class HowBigIsTheBreakGame extends StatefulWidget {
  const HowBigIsTheBreakGame({super.key});

  @override
  State<HowBigIsTheBreakGame> createState() => _HowBigIsTheBreakGameState();
}

@immutable
class BreakRound {
  const BreakRound({
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

/// The lesson's own curve: plus three into minus five over 800 ft, a crest
/// with a break of eight.
const _plusThreeToMinusFive =
    Vertical(gradeIn: 3, gradeOut: -5, length: 800);

/// A sag: minus four into plus four, the same break of eight.
const _sag = Vertical(gradeIn: -4, gradeOut: 4, length: 800);

/// Two grades the same way up: a small break between them.
const _bothDownhill = Vertical(gradeIn: -2, gradeOut: -5, length: 600);

const breakRounds = <BreakRound>[
  BreakRound(
    subject: 'plus three into minus five',
    asked:
        'This curve takes a plus three per cent grade into a minus five. How '
        'big is the break between them?',
    curve: _plusThreeToMinusFive,
    options: [
      'Two per cent',
      'Eight per cent',
      'Fifteen per cent',
      'Minus two per cent',
    ],
    answer: 1,
    why:
        'Eight. The two grades run opposite ways, so the difference between '
        'them is the sum of their sizes. Treating a plus and a minus as '
        'though they subtract to two is the mistake this problem is built '
        'around, and it makes every length that follows far too short.',
    source: 'trans-vc-q2',
  ),
  BreakRound(
    subject: 'what makes a curve a crest',
    asked:
        'Which of these tells you, from the grades alone, that a curve is a '
        'crest?',
    curve: _plusThreeToMinusFive,
    options: [
      'The second grade is negative',
      'Both grades are negative',
      'The second grade is LESS than the first, whatever their signs',
      'The second grade is steeper than the first',
    ],
    answer: 2,
    why:
        'The second grade being less than the first. Going from plus three to '
        'minus five is a crest, and so is going from minus two to minus five, '
        'even though nothing is climbing in that one. The sign of either '
        'grade on its own tells you nothing.',
    source: 'trans-vc-q2',
  ),
  BreakRound(
    subject: 'a sag with the same break',
    asked:
        'This one runs minus four into plus four. How does its break compare '
        'with the crest above?',
    curve: _sag,
    options: [
      'Smaller: the grades are gentler',
      'Zero: they cancel',
      'The same eight per cent, but the curve is a sag',
      'Sixteen per cent',
    ],
    answer: 2,
    why:
        'The same eight, and the curve tips the other way. The break is the '
        'size of the difference and carries no sign of its own, which is why '
        'a crest and a sag can share a break and still need quite different '
        'lengths.',
    source: 'trans-vc-q3',
  ),
  BreakRound(
    subject: 'two grades the same way',
    asked:
        'This road goes from minus two to minus five, both downhill. What is '
        'the break?',
    curve: _bothDownhill,
    options: [
      'Seven per cent: the two add',
      'Three per cent: the two are on the same side, so the difference is '
          'small',
      'Zero: they are both negative',
      'Five per cent',
    ],
    answer: 1,
    why:
        'Three. Both are heading downhill, so only the extra steepness is '
        'new. This is still a crest, since minus five is less than minus two, '
        'and it is a gentle one. Grades on the same side subtract, grades on '
        'opposite sides add.',
    source: 'trans-vc-q2',
  ),
  BreakRound(
    subject: 'what the break buys',
    asked:
        'Two curves are the same length but one has twice the break. What is '
        'different about it?',
    curve: _plusThreeToMinusFive,
    options: [
      'Nothing measurable',
      'It is gentler',
      'It is a sharper curve: twice the grade change in the same distance',
      'It must be a sag',
    ],
    answer: 2,
    why:
        'Sharper, and every consequence follows from that. Twice the break in '
        'the same length means twice the offset from the tangents, half the '
        'rate of vertical curvature, and, on a crest, a good deal less sight '
        'distance than the gentler one.',
    source: 'trans-vc-q2',
  ),
  BreakRound(
    subject: 'the rate of curvature',
    asked:
        'Designers quote K, the length divided by the break. What does it '
        'measure?',
    curve: _plusThreeToMinusFive,
    options: [
      'How many feet of curve there are for each per cent of grade change',
      'The design speed',
      'The height of the curve above the tangents',
      'The percentage of the road that is curved',
    ],
    answer: 0,
    why:
        'Feet of curve per per cent of grade change, which is a tidy way to '
        'compare designs: a bigger K is a flatter, more forgiving curve. '
        'Design tables are written in K for exactly that reason, so a '
        'designer can look up one number for a speed and multiply by the '
        'break in hand.',
    source: 'trans-vc-q2',
  ),
];

class _HowBigIsTheBreakGameState extends State<HowBigIsTheBreakGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-big-is-the-break',
    chapterId: 'transportation',
    total: breakRounds.length,
    sourceProblemIdOf: (round) => breakRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  BreakRound get _round => breakRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Big Is the Break',
        closing:
            'The break is the size of the difference between the two grades. '
            'Opposite signs add, the same sign subtracts, and plus three into '
            'minus five is eight. A crest is where the second grade is LESS '
            'than the first, whatever their signs. K is the length over the '
            'break: feet of curve per per cent, and bigger is flatter.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: gradeBreakBrief,
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
            'THE DIFFERENCE IN GRADE',
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
