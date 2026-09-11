import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Gauge or Absolute — the third item for `hydrostatic-pressure`.
///
/// Two of this lesson's problems hang on one sentence: gauge pressure is
/// measured from atmospheric, absolute from a vacuum, and the difference
/// between them is 101.3 kilopascals of nothing but air. The named wrong
/// answers are the right arithmetic reported in the wrong one of the two. So
/// the round never asks for a pressure. It asks what still has to be done to
/// the number in hand.
class GaugeOrAbsoluteGame extends StatefulWidget {
  const GaugeOrAbsoluteGame({super.key});

  @override
  State<GaugeOrAbsoluteGame> createState() => _GaugeOrAbsoluteGameState();
}

/// What is left to do to the number you are holding.
enum Fix { add, subtract, nothing }

extension FixWords on Fix {
  String get plain => switch (this) {
        Fix.add => 'Add 101.3 kPa',
        Fix.subtract => 'Subtract 101.3 kPa',
        Fix.nothing => 'Nothing: it is already what was asked for',
      };
}

@immutable
class GaugeRound {
  const GaugeRound({
    required this.subject,
    required this.have,
    required this.wanted,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The number in hand and where it came from, then what the question wants.
  final String have;
  final String wanted;
  final Fix answer;
  final String why;
  final String source;
}

const gaugeRounds = <GaugeRound>[
  GaugeRound(
    subject: 'an open tank',
    have:
        'You worked out 49.05 kPa from the depth and the water, in a tank '
        'open to the air.',
    wanted: 'The question asks for the GAUGE pressure there.',
    answer: Fix.nothing,
    why:
        'Nothing to do. A tank open to the air has zero gauge pressure at its '
        'surface, so what the depth formula gives you IS the gauge pressure. '
        'This is why most of civil engineering quotes gauge without saying '
        'so: the atmosphere is pressing on both sides of nearly everything we '
        'build, so it cancels.',
    source: 'fm-hp-q1',
  ),
  GaugeRound(
    subject: 'the same tank, other question',
    have: 'The same 49.05 kPa at five meters down in the open tank.',
    wanted: 'The question asks for the ABSOLUTE pressure there.',
    answer: Fix.add,
    why:
        'Add the atmosphere: about 150.4 kPa. Absolute pressure is measured '
        'from a vacuum, so it counts the air sitting on the surface as well '
        'as the water below it. The lesson\'s own first problem offers 150.4 '
        'as a wrong answer for exactly this reason: it is the right number '
        'for a question that was not asked.',
    source: 'fm-hp-q1',
  ),
  GaugeRound(
    subject: 'a closed tank of oil',
    have:
        'A closed tank reads 20 kPa on its gauge at the oil surface, and you '
        'have added the 25 kPa from three meters of oil to get 45 kPa.',
    wanted: 'The question asks for the ABSOLUTE pressure at that depth.',
    answer: Fix.add,
    why:
        'Add the atmosphere, giving 146.3 kPa. Note what the tank\'s own '
        'gauge reading already is: a gauge, so it is 20 above atmospheric, '
        'not 20 above nothing. Reporting the 45 as the answer is that '
        'problem\'s named trap, and it is the right work stopped one line '
        'early.',
    source: 'fm-hp-q2',
  ),
  GaugeRound(
    subject: 'a number quoted the other way',
    have: 'A specification gives the pressure at a valve as 146.3 kPa '
        'absolute.',
    wanted: 'You need the gauge pressure, which is what the valve is rated '
        'in.',
    answer: Fix.subtract,
    why:
        'Take the atmosphere back off: 45 kPa gauge. The two readings differ '
        'by a constant, so moving between them is one addition or one '
        'subtraction in whichever direction you need. What matters is '
        'noticing which one you were handed.',
    source: 'fm-hp-q2',
  ),
  GaugeRound(
    subject: 'what a manometer reads',
    have:
        'A U-tube manometer with one end open to the air reads a height '
        'difference, which works out to 33.35 kPa.',
    wanted: 'The question asks for the GAUGE pressure in the line.',
    answer: Fix.nothing,
    why:
        'Nothing to do: an open manometer reads gauge pressure by its nature. '
        'The atmosphere is pressing on the open leg and on nothing else, so '
        'what the height difference measures is the amount by which the line '
        'beats the atmosphere, which is exactly what gauge pressure means.',
    source: 'fm-hp-q3',
  ),
  GaugeRound(
    subject: 'the surface of a lake',
    have:
        'A table lists the pressure at the surface of an open reservoir as '
        '101.3 kPa absolute.',
    wanted: 'You want the gauge pressure at that surface.',
    answer: Fix.subtract,
    why:
        'Subtract, and it comes to zero, which is the whole idea. Gauge '
        'pressure counts from atmospheric, so anything sitting open to the '
        'air reads zero however deep the atmosphere above it is. A gauge '
        'pressure can also be negative, which is a vacuum, and the absolute '
        'one never can.',
    source: 'fm-hp-q1',
  ),
];

class _GaugeOrAbsoluteGameState extends State<GaugeOrAbsoluteGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'gauge-or-absolute',
    chapterId: 'fluid-mechanics',
    total: gaugeRounds.length,
    sourceProblemIdOf: (round) => gaugeRounds[round].source,
  )..addListener(_onSession);

  Fix? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  GaugeRound get _round => gaugeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Gauge or Absolute',
        closing:
            'Gauge counts from the atmosphere and absolute counts from a '
            'vacuum, and they differ by 101.3 kilopascals of air. Anything '
            'open to the sky reads zero gauge at its surface, which is why '
            'the depth formula gives gauge pressure directly and why an open '
            'manometer does too. Absolute is only wanted when the problem '
            'says the word.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: gaugeBrief,
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
            'WHAT IS LEFT TO DO',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOU HAVE', style: AppTheme.overline(color: AppColors.ink3)),
                const SizedBox(height: 4),
                Text(
                  r.have,
                  style: const TextStyle(
                      fontSize: 14.5, height: 1.45, color: AppColors.charcoal),
                ),
                const SizedBox(height: 10),
                Text('THE QUESTION WANTS',
                    style: AppTheme.overline(color: AppColors.ember)),
                const SizedBox(height: 4),
                Text(
                  r.wanted,
                  style: const TextStyle(
                      fontSize: 14.5, height: 1.45, color: AppColors.charcoal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: MathText(
              r'$P_{abs} = P_{atm} + P_{gauge}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Fix.values) ...[
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
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT',
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
