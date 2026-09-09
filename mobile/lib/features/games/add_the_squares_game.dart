import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'expectation_figures.dart';
import 'lesson_brief.dart';

/// Add the Squares — the third item for `expected-value-weighted-averages`.
///
/// The lesson's hard problem is one sentence long and it catches almost
/// everybody: standard deviations do not add. Three and eight give eight point
/// five, not eleven, and the reason is drawn rather than derived. Two
/// independent spreads combine the way two perpendicular legs do, so the total
/// is the hypotenuse and a hypotenuse is always shorter than going round.
///
/// The triangle is on screen to scale and the answers are numbers. Eleven is
/// longer than a side of that triangle can be, and seventy three is longer
/// than the page; the eye rules both out before any arithmetic starts.
class AddTheSquaresGame extends StatefulWidget {
  const AddTheSquaresGame({super.key});

  @override
  State<AddTheSquaresGame> createState() => _AddTheSquaresGameState();
}

@immutable
class SquaresRound {
  const SquaresRound({
    required this.subject,
    required this.ask,
    required this.combination,
    required this.legA,
    required this.legB,
    required this.aLabel,
    required this.bLabel,
    required this.options,
    required this.answer,
    required this.wantsVariance,
    required this.why,
    required this.source,
  });

  final String subject;
  final String ask;

  /// How the total is built out of the two variables.
  final String combination;

  /// The legs as drawn, which already carry any coefficient.
  final double legA;
  final double legB;
  final String aLabel;
  final String bLabel;
  final List<String> options;
  final int answer;

  /// True on the round that asks for the variance rather than the standard
  /// deviation, where the named trap is forgetting the square root.
  final bool wantsVariance;
  final String why;
  final String source;
}

const squaresRounds = <SquaresRound>[
  SquaresRound(
    subject: 'dead load and live load on a bridge beam',
    ask: 'What is the standard deviation of the total load?',
    combination: r'T = D + L',
    legA: 3,
    legB: 8,
    aLabel: '3 kN',
    bLabel: '8 kN',
    options: ['11.0 kN', '8.54 kN', '73.0 kN'],
    answer: 1,
    wantsVariance: false,
    why:
        'Eleven is the two legs laid end to end, and the triangle says plainly '
        'that the direct route is shorter. Seventy three is the variance, '
        'which is the number you get one step before the square root.',
    source: 'stat-ev-q3',
  ),
  SquaresRound(
    subject: 'two independent survey measurements',
    ask: 'What is the standard deviation of the combined error?',
    combination: r'E = E_1 + E_2',
    legA: 6,
    legB: 8,
    aLabel: '6 mm',
    bLabel: '8 mm',
    options: ['10.0 mm', '14.0 mm', '100 mm'],
    answer: 0,
    wantsVariance: false,
    why:
        'Six and eight give ten, which is a triangle everyone has met. Adding '
        'them gives fourteen, and fourteen millimetres would be a longer '
        'straight line than the two legs can reach.',
    source: 'stat-ev-q3',
  ),
  SquaresRound(
    subject: 'travel time on two independent segments',
    ask: 'What is the standard deviation of the total travel time?',
    combination: r'T = T_1 + T_2',
    legA: 5,
    legB: 12,
    aLabel: '5 min',
    bLabel: '12 min',
    options: ['17.0 min', '169 min', '13.0 min'],
    answer: 2,
    wantsVariance: false,
    why:
        'Five and twelve give thirteen. Seventeen is the sum, and it is the '
        'answer that would be right only if the two segments always ran long '
        'together, which is what independent means they do not.',
    source: 'stat-ev-q3',
  ),
  SquaresRound(
    subject: 'the same dead and live loads',
    ask: 'What is the VARIANCE of the total load?',
    combination: r'T = D + L',
    legA: 3,
    legB: 8,
    aLabel: '3 kN',
    bLabel: '8 kN',
    options: ['8.54', '73.0', '121'],
    answer: 1,
    wantsVariance: true,
    why:
        'Variances add, so this one is a plain sum: nine and sixty four. The '
        'square root is what turns it back into a standard deviation, and this '
        'question did not ask for one.',
    source: 'stat-ev-q3',
  ),
  SquaresRound(
    subject: 'a precise gauge alongside a rough one',
    ask: 'What is the standard deviation of the total?',
    combination: r'T = X + Y',
    legA: 2,
    legB: 9,
    aLabel: '2 units',
    bLabel: '9 units',
    options: ['11.0', '85.0', '9.22'],
    answer: 2,
    wantsVariance: false,
    why:
        'The small spread barely moves the answer: nine becomes nine point '
        'two. Squaring makes the big one dominate, which is why tightening the '
        'already-tight measurement buys you almost nothing.',
    source: 'stat-ev-q3',
  ),
  SquaresRound(
    subject: 'a load counted twice, plus an independent one',
    ask: 'What is the standard deviation of the total?',
    combination: r'T = 2D + L',
    legA: 6,
    legB: 8,
    aLabel: '2(3) kN',
    bLabel: '8 kN',
    options: ['10.0 kN', '11.0 kN', '14.0 kN'],
    answer: 0,
    wantsVariance: false,
    why:
        'The coefficient gets squared along with the standard deviation, which '
        'is the same as saying it doubles the leg before the triangle is drawn. '
        'Eleven is what you get by forgetting the two entirely.',
    source: 'stat-ev-q3',
  ),
];

class _AddTheSquaresGameState extends State<AddTheSquaresGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'add-the-squares',
    chapterId: 'statistics',
    total: squaresRounds.length,
    sourceProblemIdOf: (round) => squaresRounds[round].source,
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

  SquaresRound get _round => squaresRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Add the Squares',
        closing:
            'Variances add, standard deviations do not. Square them, add them, '
            'and take the root at the end, and any coefficient gets squared on '
            'the way through.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: combiningBrief,
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
            'TWO INDEPENDENT SPREADS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MathBlock(r.combination, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 240,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: SigmaTrianglePainter(
                    a: r.legA,
                    b: r.legB,
                    aLabel: r.aLabel,
                    bLabel: r.bLabel,
                    showHypotenuse: true,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < r.options.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _LengthButton(
                    key: ValueKey('total-$i'),
                    label: r.options[i],
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _LengthButton extends StatelessWidget {
  const _LengthButton({
    super.key,
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
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.code(size: 13),
          ),
        ),
      ),
    );
  }
}
