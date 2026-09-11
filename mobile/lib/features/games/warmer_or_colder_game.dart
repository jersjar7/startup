import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'bod_figures.dart';

/// Warmer or Colder — the third item for `water-quality`.
///
/// Temperature changes how FAST the bugs work and not how much oxygen the
/// organic matter will eventually need. The correction is one line, and its
/// trap is the exponent: T minus 20, so above twenty the rate goes up and
/// below it the rate goes down. Turning the exponent around gives a smaller
/// rate for a warmer river, which is backward, and the lesson names it.
class WarmerOrColderGame extends StatefulWidget {
  const WarmerOrColderGame({super.key});

  @override
  State<WarmerOrColderGame> createState() => _WarmerOrColderGameState();
}

/// What the temperature change does to the rate constant.
enum Rate3 { faster, slower, unchanged }

extension Rate3Words on Rate3 {
  String get plain => switch (this) {
        Rate3.faster => 'A bigger k: the decay runs faster',
        Rate3.slower => 'A smaller k: the decay runs slower',
        Rate3.unchanged => 'No change at all',
      };
}

@immutable
class HeatRound {
  const HeatRound({
    required this.subject,
    required this.setting,
    required this.base,
    required this.celsius,
    required this.asks,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Demand base;

  /// The temperature the sample is at.
  final double celsius;

  /// Whether the round is asking about the rate or about the ultimate.
  final bool asks;
  final String why;
  final String source;

  Demand get corrected => base.atTemperature(celsius);

  /// Worked out of the correction, never declared. A question about the
  /// ULTIMATE always answers unchanged: temperature moves the rate only.
  Rate3 get answer {
    if (!asks) return Rate3.unchanged;
    if ((celsius - 20).abs() < 0.01) return Rate3.unchanged;
    return celsius > 20 ? Rate3.faster : Rate3.slower;
  }
}

const warmRounds = <HeatRound>[
  HeatRound(
    subject: 'the lesson\'s own correction',
    setting:
        'A rate of 0.23 a day at 20 degrees. The river is running at 28 '
        'degrees. What happens to k?',
    base: Demand(ultimate: 300, rate: 0.23),
    celsius: 28,
    asks: true,
    why:
        'Bigger: 0.23 times 1.056 to the eighth, which is 0.36 a day. Warm '
        'water means busy bugs. The exponent is T minus 20, so eight degrees '
        'above the reference is a positive eight and the factor is above one. '
        'Turning it into 20 minus T gives 0.15, a rate LOWER than the cold '
        'one, and that is the lesson\'s named trap.',
    source: 'wr-wq-q3',
  ),
  HeatRound(
    subject: 'a cold river in February',
    setting:
        'The same 0.23 a day at 20 degrees, but the water is at 10 degrees. '
        'What happens to k?',
    base: Demand(ultimate: 300, rate: 0.23),
    celsius: 10,
    asks: true,
    why:
        'Smaller. Below the reference the exponent is negative and the '
        'factor drops under one, so the decay crawls. This is why a river '
        'carries its oxygen demand much further downstream in winter: the '
        'same load, worked through more slowly, so the sag in dissolved '
        'oxygen is shallower but a great deal longer.',
    source: 'wr-wq-q3',
  ),
  HeatRound(
    subject: 'the same water, asked about differently',
    setting:
        'That warm 28 degree river again. What happens to the ULTIMATE BOD '
        'of the sample?',
    base: Demand(ultimate: 300, rate: 0.23),
    celsius: 28,
    asks: false,
    why:
        'Nothing. Temperature is a rate correction and nothing else: the '
        'same organic matter still needs the same oxygen to break down, it '
        'just gets there sooner. On the drawing the warm curve climbs more '
        'steeply and then flattens against exactly the same ultimate. Mixing '
        'up what changes and what does not is the whole reason this round is '
        'here.',
    source: 'wr-wq-q3',
  ),
  HeatRound(
    subject: 'at the reference temperature',
    setting: 'The sample is measured at 20 degrees. What happens to k?',
    base: Demand(ultimate: 300, rate: 0.23),
    celsius: 20,
    asks: true,
    why:
        'Nothing: the exponent is zero and theta to the zero is one. Twenty '
        'degrees is the reference the standard test is run at, which is why '
        'rate constants are quoted there and why a correction is needed for '
        'any other temperature at all. A laboratory BOD is a five day test AT '
        'TWENTY DEGREES, both halves of that.',
    source: 'wr-wq-q3',
  ),
  HeatRound(
    subject: 'a warm treatment plant',
    setting:
        'An aeration basin runs at 30 degrees. The rate at 20 is 0.20 a day. '
        'What happens to k?',
    base: Demand(ultimate: 250, rate: 0.20),
    celsius: 30,
    asks: true,
    why:
        'Bigger, by about 1.7 times at theta of 1.056. Warm plants work '
        'faster, which is why a basin sized for a cold winter has capacity to '
        'spare in summer and why treatment in a cold climate is the harder '
        'design case. The theta to use depends on the process and the range: '
        '1.056 for BOD between 21 and 30 degrees, 1.024 for reaeration.',
    source: 'wr-wq-q3',
  ),
  HeatRound(
    subject: 'a mountain stream',
    setting:
        'Snowmelt at 5 degrees, against a rate of 0.23 quoted at 20. What '
        'happens to k?',
    base: Demand(ultimate: 300, rate: 0.23),
    celsius: 5,
    asks: true,
    why:
        'Smaller, and dramatically so: fifteen degrees below the reference. '
        'Cold water also holds more dissolved oxygen to begin with, so a cold '
        'stream is doubly forgiving of a load, and both effects run the same '
        'way. Note that below 20 degrees the theta for BOD is 1.135 rather '
        'than 1.056, which makes the fall steeper still.',
    source: 'wr-wq-q3',
  ),
];

class _WarmerOrColderGameState extends State<WarmerOrColderGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'warmer-or-colder',
    chapterId: 'water-resources',
    total: warmRounds.length,
    sourceProblemIdOf: (round) => warmRounds[round].source,
  )..addListener(_onSession);

  Rate3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  HeatRound get _round => warmRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Warmer or Colder',
        closing:
            'Temperature corrects the RATE and never the ultimate: the same '
            'organic matter needs the same oxygen, it just gets there sooner '
            'in warm water. The exponent is T minus 20, so above the '
            'reference k rises and below it k falls, and turning the exponent '
            'around gives a slower rate for a warmer river, which cannot '
            'happen. Which theta to use depends on the process and the range.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: temperatureBrief,
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
            'WHAT DOES THE TEMPERATURE CHANGE',
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
            height: 222,
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
                    demand: r.base,
                    day: 5,
                    warmer: answered ? r.corrected : null,
                    showSplit: false,
                    note: answered
                        ? 'red: the same sample at ${_num(r.celsius)} degrees'
                        : 'black: k ${r.base.rate} at 20 degrees',
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$k_T = k_{20}\,\theta^{(T-20)}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Rate3.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Rate3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT DOES' : 'NOT THAT',
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
