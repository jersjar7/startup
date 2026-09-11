import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'bod_figures.dart';

/// Multiply or Divide — the second item for `water-quality`.
///
/// One equation connects the ultimate BOD and the five day figure, and a
/// problem can hand you either one and ask for the other. Going forward you
/// multiply the ultimate by the fraction; going backward you divide the
/// measurement by it. Which way round is the whole question, and the giveaway
/// is that the ultimate is ALWAYS the larger of the two: if your answer came
/// out smaller than the laboratory measurement, the division went the wrong
/// way.
class MultiplyOrDivideGame extends StatefulWidget {
  const MultiplyOrDivideGame({super.key});

  @override
  State<MultiplyOrDivideGame> createState() => _MultiplyOrDivideGameState();
}

/// What to do with the fraction the equation gives.
enum Step3 { multiply, divide, subtract }

extension Step3Words on Step3 {
  String get plain => switch (this) {
        Step3.multiply => 'Multiply by the fraction: the answer comes out smaller',
        Step3.divide => 'Divide by the fraction: the answer comes out larger',
        Step3.subtract => 'Neither: take it off the ultimate',
      };
}

@immutable
class StepRound {
  const StepRound({
    required this.subject,
    required this.asked,
    required this.demand,
    required this.day,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Demand demand;
  final double day;
  final Step3 answer;
  final String why;
  final String source;
}

const bodStepRounds = <StepRound>[
  StepRound(
    subject: 'the lesson\'s first problem',
    asked:
        'The ultimate BOD is 300 mg/L and k is 0.23 a day. What is the five '
        'day BOD?',
    demand: Demand(ultimate: 300, rate: 0.23),
    day: 5,
    answer: Step3.multiply,
    why:
        'Multiply. You have the whole of the demand and you want the part of '
        'it that five days catches, so the fraction goes on as a multiplier: '
        '300 times 0.683 is 205. The answer must be smaller than 300, and if '
        'it is not, the arithmetic went the wrong way.',
    source: 'wr-wq-q1',
  ),
  StepRound(
    subject: 'the lesson\'s second problem',
    asked:
        'The laboratory reports a five day BOD of 180 mg/L and k is 0.20 a '
        'day. What is the ultimate BOD?',
    demand: Demand(ultimate: 285, rate: 0.20),
    day: 5,
    answer: Step3.divide,
    why:
        'Divide. The 180 is a part and you want the whole, so the fraction '
        'comes off the bottom: 180 over 0.632 is 285. The lesson offers 180 '
        'itself as a wrong answer, which is what you get by assuming the five '
        'day test caught everything, and the check is that the ultimate has '
        'to be the larger number.',
    source: 'wr-wq-q2',
  ),
  StepRound(
    subject: 'what is left in the bottle',
    asked:
        'The ultimate is 300 mg/L and 205 has been exerted by day five. What '
        'is the BOD REMAINING?',
    demand: Demand(ultimate: 300, rate: 0.23),
    day: 5,
    answer: Step3.subtract,
    why:
        'Neither: it is the ultimate less what has been exerted, 300 minus '
        '205, which is 95. You can also get it directly as the ultimate times '
        'e to the minus kt, which is the same thing said another way. What '
        'matters is that exerted and remaining are two halves of one number '
        'and a question will ask for one of them by name.',
    source: 'wr-wq-q1',
  ),
  StepRound(
    subject: 'a discharge permit',
    asked:
        'A permit is written on ultimate BOD. The plant\'s five day figure '
        'is 40 mg/L with k of 0.18. What number does the permit want?',
    demand: Demand(ultimate: 67, rate: 0.18),
    day: 5,
    answer: Step3.divide,
    why:
        'Divide, and it matters: 40 over 0.593 is 67 mg/L, so a plant '
        'comfortably under a 50 mg/L five day limit is well over a 50 mg/L '
        'ultimate one. Permits are written both ways and the two numbers are '
        'not interchangeable. Read which one is being asked for before '
        'deciding whether you comply.',
    source: 'wr-wq-q2',
  ),
  StepRound(
    subject: 'a design figure',
    asked:
        'A textbook gives the ultimate BOD of a strong wastewater as 600 '
        'mg/L with k of 0.25. What would the laboratory report at five days?',
    demand: Demand(ultimate: 600, rate: 0.25),
    day: 5,
    answer: Step3.multiply,
    why:
        'Multiply: 600 times 0.713, which is 428 mg/L. Going from the '
        'ultimate to the measurement is always a multiplication by something '
        'less than one, so the reported figure is always the smaller. The '
        'direction of the arithmetic and the direction of the inequality are '
        'the same check twice over.',
    source: 'wr-wq-q1',
  ),
  StepRound(
    subject: 'a three day reading',
    asked:
        'A bottle read at three days shows 95 mg/L, with k of 0.23. What is '
        'the ultimate?',
    demand: Demand(ultimate: 190, rate: 0.23),
    day: 3,
    answer: Step3.divide,
    why:
        'Divide, by the three day fraction rather than the five day one: '
        '0.50 here, so the ultimate is about 190. The fraction is whatever '
        'the equation gives for the time the bottle was actually read at, and '
        'reaching for 0.68 out of habit is the mistake. Five days is a '
        'convention, not a term in the formula.',
    source: 'wr-wq-q2',
  ),
];

class _MultiplyOrDivideGameState extends State<MultiplyOrDivideGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'multiply-or-divide',
    chapterId: 'water-resources',
    total: bodStepRounds.length,
    sourceProblemIdOf: (round) => bodStepRounds[round].source,
  )..addListener(_onSession);

  Step3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  StepRound get _round => bodStepRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Multiply or Divide',
        closing:
            'The fraction the equation gives is always less than one. Going '
            'from the ultimate to the measurement you multiply by it and the '
            'answer gets smaller; going the other way you divide and it gets '
            'larger. The ultimate is always the bigger number, which is the '
            'check that catches a division done upside down. And the fraction '
            'belongs to the day the bottle was actually read at.',
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
            'WHICH WAY DOES THE FRACTION GO',
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
            height: 214,
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
                    note: answered
                        ? 'the fraction at day ${_num(r.day)} is '
                            '${r.demand.fractionAt(r.day).toStringAsFixed(3)}'
                        : 'k ${r.demand.rate} per day',
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
          for (final option in Step3.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Step3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE WAY' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

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
