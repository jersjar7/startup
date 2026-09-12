import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'load_figures.dart';

/// How Much Comes Off — the third item for `load-combinations`.
///
/// The reduction formula is arithmetic and belongs on paper. What the phone
/// can settle is everything around it: which member is allowed the bigger
/// reduction and why, that a bigger area means a bigger reduction, that the
/// answer is floored at half the unreduced load for a single floor, that the
/// rule never turns into an increase, and that it applies to live load only.
/// Every one of those is a place a worked answer goes wrong after the
/// arithmetic was right.
class HowMuchComesOffGame extends StatefulWidget {
  const HowMuchComesOffGame({super.key});

  @override
  State<HowMuchComesOffGame> createState() => _HowMuchComesOffGameState();
}

@immutable
class ReduceRound {
  const ReduceRound({
    required this.subject,
    required this.asked,
    required this.left,
    this.right,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Tributary left;
  final Tributary? right;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const reduceRounds = <ReduceRound>[
  ReduceRound(
    subject: 'a column and a beam, same floor area',
    asked:
        'These two members each carry the same 600 square feet of floor. '
        'Which one is allowed the bigger reduction?',
    left: Tributary(area: 600, column: true),
    right: Tributary(area: 600, column: false),
    options: [
      'The column',
      'The beam',
      'Neither: the same area means the same reduction',
      'The beam, because it carries a strip rather than a patch',
    ],
    answer: 0,
    why:
        'The column, because the rule multiplies the area by K first and a '
        'column gets 4 against a beam\'s 2. That doubles what goes under the '
        'square root and shrinks the fifteen-over-root term, which is the '
        'part that keeps the load up. Same floor area, different member, '
        'different answer: reading K off the member type is the first thing '
        'to do, not the last.',
    source: 'str-lc-q3',
  ),
  ReduceRound(
    subject: 'two columns, different areas',
    asked:
        'Two interior columns, one carrying a small bay and one carrying a '
        'large one. Which gets the bigger reduction?',
    left: Tributary(area: 200, column: true),
    right: Tributary(area: 1200, column: true),
    options: [
      'The one carrying the large area',
      'The one carrying the small area',
      'Neither: area does not enter into it',
      'The large one, but only up to 600 square feet',
    ],
    answer: 0,
    why:
        'The large one. The reduction exists because the chance of every '
        'square foot being loaded to the full at the same moment falls as the '
        'floor gets bigger, so the more floor a member carries the less of '
        'the nominal load it will ever see at once. A member holding up a '
        'small bay might genuinely see the lot.',
    source: 'str-lc-q3',
  ),
  ReduceRound(
    subject: 'a small bay',
    asked:
        'A beam carries a small area, and the bracket in the formula works '
        'out to more than one. What live load do you design it for?',
    left: Tributary(area: 120, column: false),
    options: [
      'The unreduced load: the rule never turns into an increase',
      'The increased load the formula gives',
      'Half the unreduced load, as the floor allows',
      'The unreduced load times 0.25',
    ],
    answer: 0,
    why:
        'The unreduced load. The bracket passes through exactly one when K '
        'times the area reaches 400 square feet, and below that it would give '
        'more than the load the code already asked for, which is not what a '
        'reduction rule is for. Small tributary areas simply get no '
        'reduction.',
    source: 'str-lc-q3',
  ),
  ReduceRound(
    subject: 'a very large bay',
    asked:
        'A column carries one floor over a very large area, and the formula '
        'comes out at 0.42 of the unreduced live load. What do you use?',
    left: Tributary(area: 4000, column: true),
    options: [
      'Half the unreduced load: a single floor may go no lower',
      'The 0.42 the formula gives',
      'Four tenths of the unreduced load',
      'The unreduced load, since the formula has failed',
    ],
    answer: 0,
    why:
        'Half. The rule has floors under it: a member carrying ONE floor may '
        'not be reduced below 0.50 of the unreduced load, and one carrying '
        'two or more floors may not go below 0.40. Working the bracket out '
        'and then forgetting to check it against the floor is the commonest '
        'way to get this question wrong after doing the hard part right.',
    source: 'str-lc-q3',
  ),
  ReduceRound(
    subject: 'the other loads',
    asked:
        'May the dead load on the same column be reduced the same way?',
    left: Tributary(area: 800, column: true),
    options: [
      'No: the reduction is for live load only',
      'Yes, by the same bracket',
      'Yes, but only for areas over 400 square feet',
      'No, but the snow load may be',
    ],
    answer: 0,
    why:
        'Live load only. The reduction is a statement about how unlikely it '
        'is that every part of a big floor is crowded at once, and the dead '
        'load has no such luck about it: the slab weighs what it weighs, '
        'everywhere, all the time. Snow has its own rules elsewhere and is '
        'not touched by this bracket either.',
    source: 'str-lc-q3',
  ),
  ReduceRound(
    subject: 'why a column gets more',
    asked:
        'Why does the rule hand a column a K of 4 where a beam gets 2?',
    left: Tributary(area: 600, column: true),
    right: Tributary(area: 600, column: false),
    options: [
      'Because the floor that influences a column is about four times the '
          'area it directly carries',
      'Because columns are more important than beams',
      'Because columns usually carry more floors',
      'Because a column is stiffer than a beam',
    ],
    answer: 0,
    why:
        'Because K is the ratio of the INFLUENCE area to the tributary area. '
        'Bending a bay of floor anywhere in the four panels around an '
        'interior column puts some load into it, so its influence area is '
        'about four times what it directly carries; a beam is influenced by '
        'the strip on either side of it, which is about twice. The rule is '
        'about how much floor can reach the member, not about how important '
        'the member is.',
    source: 'str-lc-q3',
  ),
];

class _HowMuchComesOffGameState extends State<HowMuchComesOffGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-much-comes-off',
    chapterId: 'structural',
    total: reduceRounds.length,
    sourceProblemIdOf: (round) => reduceRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ReduceRound get _round => reduceRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Much Comes Off',
        closing:
            'The reduction is a bet that a big floor is never full '
            'everywhere at once, so the more floor a member carries the less '
            'of the load it has to be designed for. A column counts its area '
            'four times over and a beam twice. The bracket never becomes an '
            'increase, it stops at half the unreduced load for a single floor '
            'and four tenths for more than one, and it touches nothing but '
            'live load.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: reductionBrief,
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
            'WHAT COMES OFF THE LIVE LOAD',
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
            height: 190,
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
                  painter: TributaryPainter(
                    left: r.left,
                    right: r.right,
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
              r'$L = L_o\left(0.25 + \frac{15}{\sqrt{K_{LL} A_T}}\right)$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
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
              title: _session.correct! ? 'THAT IS RIGHT' : 'NOT THAT ONE',
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
