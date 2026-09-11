import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'area_figures.dart';

/// What Weight Does It Get — the second item for `area-computations`.
///
/// Both offset rules are the same shape: multiply each offset by something,
/// add them up, multiply by the interval. All that separates them is the
/// list of somethings. The trapezoidal rule halves the two ends and takes
/// everything else whole, because the end strips are half strips. Simpson
/// takes the ends once and then alternates four and two, because it fits a
/// parabola across every pair of intervals and the shared offsets get
/// counted for both. Getting a weight wrong is the lesson's own trap, and
/// the weights are where the whole difference between the rules lives.
class WhatWeightDoesItGetGame extends StatefulWidget {
  const WhatWeightDoesItGetGame({super.key});

  @override
  State<WhatWeightDoesItGetGame> createState() =>
      _WhatWeightDoesItGetGameState();
}

/// What an offset gets multiplied by.
enum Weight { half, once, twice, fourTimes }

extension WeightWords on Weight {
  String get plain => switch (this) {
        Weight.half => 'Half of it',
        Weight.once => 'All of it, once',
        Weight.twice => 'Twice',
        Weight.fourTimes => 'Four times',
      };

  double get value => switch (this) {
        Weight.half => 0.5,
        Weight.once => 1,
        Weight.twice => 2,
        Weight.fourTimes => 4,
      };
}

@immutable
class WeightRound {
  const WeightRound({
    required this.subject,
    required this.strip,
    required this.rule,
    required this.at,
    required this.why,
    required this.source,
  });

  final String subject;
  final Strip strip;

  /// Which of the two rules is being applied.
  final Way3 rule;

  /// Which offset the round is asking about, counting from the start.
  final int at;
  final String why;
  final String source;

  /// Read off the rule and the position, never declared.
  Weight get answer {
    final w = rule == Way3.simpson
        ? strip.simpsonWeight(at)
        : strip.trapezoidWeight(at);
    return Weight.values.firstWhere((o) => o.value == w);
  }
}

const offsetWeightRounds = <WeightRound>[
  WeightRound(
    subject: 'the trapezoidal rule, at the first offset',
    strip: Strip(offsets: [0, 8, 12, 10, 0], step: 20),
    rule: Way3.trapezoid,
    at: 0,
    why:
        'Half of it. The trapezoidal rule halves the two end offsets, and '
        'the reason is worth seeing rather than memorizing: every offset in '
        'the middle is shared by the strip on its left and the strip on its '
        'right, so it gets counted whole. The two at the ends belong to one '
        'strip each. On the lesson\'s own problem both ends happen to be '
        'zero, so halving them changes nothing and the trap hides.',
    source: 'surv-ac-q3',
  ),
  WeightRound(
    subject: 'the trapezoidal rule, in the middle',
    strip: Strip(offsets: [0, 8, 12, 10, 0], step: 20),
    rule: Way3.trapezoid,
    at: 2,
    why:
        'All of it, once. Every offset between the ends is taken at full '
        'value: the 8, the 12 and the 10 add up to 30, and twenty meters '
        'times 30 is the 600 square meters the lesson computes. Averaging '
        'ALL of them instead is the trap it names, and that gives 480.',
    source: 'surv-ac-q3',
  ),
  WeightRound(
    subject: 'Simpson\'s rule, at the first offset',
    strip: Strip(offsets: [2, 7, 13, 15, 12, 6, 3], step: 10),
    rule: Way3.simpson,
    at: 0,
    why:
        'All of it, once. Simpson treats the ends differently from the '
        'trapezoidal rule: they are taken whole rather than halved, and the '
        'division by three at the end of the sum is what keeps the '
        'arithmetic honest. Ends once, then four and two alternating.',
    source: 'surv-ac-q3',
  ),
  WeightRound(
    subject: 'Simpson\'s rule, at the second offset',
    strip: Strip(offsets: [2, 7, 13, 15, 12, 6, 3], step: 10),
    rule: Way3.simpson,
    at: 1,
    why:
        'Four times. The offsets in the MIDDLE of each pair of intervals '
        'carry the most weight, because the parabola Simpson fits is pinned '
        'hardest by the point in the middle of it. Every other offset from '
        'the second one carries four.',
    source: 'surv-ac-q3',
  ),
  WeightRound(
    subject: 'Simpson\'s rule, at the third offset',
    strip: Strip(offsets: [2, 7, 13, 15, 12, 6, 3], step: 10),
    rule: Way3.simpson,
    at: 2,
    why:
        'Twice. This offset is where one parabola ends and the next begins, '
        'so it is shared between two of them and gets counted once for each. '
        'Four and two alternating along the strip is not a mnemonic: it is '
        'what shared endpoints look like written down.',
    source: 'surv-ac-q3',
  ),
  WeightRound(
    subject: 'Simpson\'s rule, at the last offset',
    strip: Strip(offsets: [2, 7, 13, 15, 12, 6, 3], step: 10),
    rule: Way3.simpson,
    at: 6,
    why:
        'All of it, once, the same as the first. The pattern down a Simpson '
        'strip is 1, 4, 2, 4, 2, 4, 1, and it has to end on a 1 with a 4 '
        'before it. If yours does not, either an offset has been miscounted '
        'or the count is even and Simpson does not apply at all.',
    source: 'surv-ac-q3',
  ),
];

class _WhatWeightDoesItGetGameState extends State<WhatWeightDoesItGetGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-weight-does-it-get',
    chapterId: 'surveying',
    total: offsetWeightRounds.length,
    sourceProblemIdOf: (round) => offsetWeightRounds[round].source,
  )..addListener(_onSession);

  Weight? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WeightRound get _round => offsetWeightRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Weight Does It Get',
        closing:
            'The trapezoidal rule halves the two ends and takes everything '
            'between them whole, because the middle offsets are shared by '
            'the strips either side. Simpson takes the ends once and '
            'alternates four and two, because the middle of each parabola '
            'carries it and the joins are shared. One, four, two, four, one. '
            'Then multiply by the interval, and for Simpson divide by three.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: weightsBrief,
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
            'WHAT DOES THE MARKED OFFSET GET MULTIPLIED BY',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
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
                  painter: OffsetsPainter(
                    strip: r.strip,
                    marked: r.at,
                    locked: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r.rule == Way3.simpson
                  ? r'$A = \frac{w}{3}(h_1 + 4h_2 + 2h_3 + \cdots + h_n)$'
                  : r'$A = w\left(\frac{h_1 + h_n}{2} + h_2 + \cdots\right)$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Weight.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE WEIGHT' : 'ANOTHER WEIGHT',
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
