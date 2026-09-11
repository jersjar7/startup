import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'bod_figures.dart';

/// How Much Is Used Up — the first item for `water-quality`.
///
/// The five day BOD test is not the ultimate BOD, and the often quoted 68
/// percent is not a law: it is what you get at one particular decay rate.
/// Slow water catches far less in five days and fast water catches nearly
/// all of it. What is always true is the bookkeeping: what has been exerted
/// and what is still to come add up to the ultimate, and the lesson's own
/// problem offers the remainder as a wrong answer to a question about the
/// exerted.
class HowMuchIsUsedUpGame extends StatefulWidget {
  const HowMuchIsUsedUpGame({super.key});

  @override
  State<HowMuchIsUsedUpGame> createState() => _HowMuchIsUsedUpGameState();
}

/// How far the decay has got by the day the test is read.
enum Used { most, half, little }

extension UsedWords on Used {
  String get plain => switch (this) {
        Used.most => 'Most of it: well over half has been used',
        Used.half => 'About half used and half still to come',
        Used.little => 'Only a part: most of it is still to come',
      };
}

@immutable
class UsedRound {
  const UsedRound({
    required this.subject,
    required this.setting,
    required this.demand,
    required this.day,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Demand demand;
  final double day;
  final String why;
  final String source;

  /// Worked out of the curve, never declared.
  Used get answer {
    final share = demand.fractionAt(day);
    if ((share - 0.5).abs() < 0.08) return Used.half;
    return share > 0.5 ? Used.most : Used.little;
  }
}

const usedRounds = <UsedRound>[
  UsedRound(
    subject: 'the lesson\'s own sample',
    setting:
        'Ultimate BOD 300 mg/L at the standard rate, k = 0.23 a day. The '
        'test is read at five days.',
    demand: Demand(ultimate: 300, rate: 0.23),
    day: 5,
    why:
        'Most of it: 205 of the 300, which is 68 percent, leaving 95 still '
        'to come. That 68 percent is where the rule of thumb comes from, and '
        'it holds only at this decay rate. The 95 is the BOD REMAINING, and '
        'the lesson offers it as a wrong answer to a question about the BOD '
        'exerted: the two add to the ultimate and it is worth naming which '
        'one a question wants before starting.',
    source: 'wr-wq-q1',
  ),
  UsedRound(
    subject: 'slow, cold water',
    setting:
        'The same 300 mg/L of ultimate BOD, but a sluggish k of 0.10 a day. '
        'Read at five days again.',
    demand: Demand(ultimate: 300, rate: 0.10),
    day: 5,
    why:
        'Only a part: 39 percent, so nearly two thirds of the demand is '
        'still waiting. The 68 percent figure is not a property of the five '
        'day test, it is a property of the test AND the rate together. Slow '
        'water is exactly where the five day test misleads: the sample looks '
        'cleaner than it is, and the river downstream finds out later.',
    source: 'wr-wq-q2',
  ),
  UsedRound(
    subject: 'a fast, warm sample',
    setting:
        'Ultimate BOD 250 mg/L and a brisk k of 0.40 a day, read at five '
        'days.',
    demand: Demand(ultimate: 250, rate: 0.40),
    day: 5,
    why:
        'Most of it, and nearly all: 86 percent. At this rate the five day '
        'test is very nearly the ultimate, and the difference between the two '
        'numbers stops mattering much. This is what a warm, readily '
        'degradable wastewater looks like, and it is why the same plant can '
        'report quite different BOD figures in summer and winter.',
    source: 'wr-wq-q1',
  ),
  UsedRound(
    subject: 'reading the test early',
    setting:
        'The standard sample again, k = 0.23, but somebody reads the bottle '
        'at three days instead of five.',
    demand: Demand(ultimate: 300, rate: 0.23),
    day: 3,
    why:
        'About half: 50 percent used and 50 percent still to come, almost '
        'exactly. Three days is not a standard reading and the number it '
        'gives cannot be compared with anybody else\'s BOD, which is the '
        'whole reason the five day test is defined the way it is: a fixed '
        'time at a fixed temperature so that two laboratories mean the same '
        'thing.',
    source: 'wr-wq-q1',
  ),
  UsedRound(
    subject: 'leaving the bottle a long while',
    setting: 'The standard sample, k = 0.23, left for twenty days.',
    demand: Demand(ultimate: 300, rate: 0.23),
    day: 20,
    why:
        'Most of it, and effectively all: 99 percent. The curve approaches '
        'the ultimate and never quite touches it, so there is no day on which '
        'the decay is finished. Twenty days is close enough that the '
        'measurement is taken as the ultimate, and that is one way of finding '
        'the ultimate directly rather than back-calculating from the five day '
        'figure.',
    source: 'wr-wq-q2',
  ),
  UsedRound(
    subject: 'the lesson\'s second sample',
    setting:
        'A sample with k = 0.20 a day, read at five days. The laboratory '
        'reports 180 mg/L.',
    demand: Demand(ultimate: 285, rate: 0.20),
    day: 5,
    why:
        'Most of it: 63 percent. Note what the laboratory actually handed '
        'over: the 180 is the EXERTED figure, 63 percent of an ultimate of '
        '285. The lesson\'s problem asks you to work backward to that 285, '
        'and the way in is to divide by the fraction rather than to multiply '
        'by it.',
    source: 'wr-wq-q2',
  ),
];

class _HowMuchIsUsedUpGameState extends State<HowMuchIsUsedUpGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-much-is-used-up',
    chapterId: 'water-resources',
    total: usedRounds.length,
    sourceProblemIdOf: (round) => usedRounds[round].source,
  )..addListener(_onSession);

  Used? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  UsedRound get _round => usedRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Much Is Used Up',
        closing:
            'The five day BOD is never the ultimate BOD, and how much of it '
            'the test catches depends on the decay rate: 68 percent at the '
            'standard 0.23 a day, under 40 percent in slow cold water, and '
            'nearly all of it in a fast warm sample. What is always true is '
            'that the exerted and the remaining add up to the ultimate, so '
            'naming which one a question wants is the first move.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: bodBrief,
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
            'BY THAT DAY, HOW FAR HAS IT GOT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 226,
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
                  painter: BodPainter(
                    demand: r.demand,
                    day: r.day,
                    showSplit: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$BOD_t = L_0\left(1 - e^{-kt}\right)$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Used.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Used.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS HOW FAR' : 'NOT THAT FAR',
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
