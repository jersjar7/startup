import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'traffic_flow_figures.dart';
import 'lesson_brief.dart';

/// Per Million What — the third item for `traffic-flow`.
///
/// A crash count on its own says nothing: a busy intersection will have
/// more crashes than a quiet one simply by having more vehicles. The rate
/// divides by the traffic that was exposed, and the whole difficulty is
/// building that denominator: a daily count has to be annualized, and a
/// segment rate has to carry the length as well.
class PerMillionWhatGame extends StatefulWidget {
  const PerMillionWhatGame({super.key});

  @override
  State<PerMillionWhatGame> createState() => _PerMillionWhatGameState();
}

@immutable
class ExposureRound {
  const ExposureRound({
    required this.subject,
    required this.asked,
    required this.rate,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final CrashRate rate;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own intersection: 12 crashes in a year on 8,000 vehicles a
/// day, which is 4.11 per million entering.
const _theIntersection = CrashRate(crashes: 12, dailyTraffic: 8000);

/// A busier one with more crashes but a better rate.
const _busier = CrashRate(crashes: 20, dailyTraffic: 30000);

/// And a segment, where the length joins the denominator.
const _segment = CrashRate(crashes: 15, dailyTraffic: 10000, miles: 3);

const exposureRounds = <ExposureRound>[
  ExposureRound(
    subject: 'why a count is not enough',
    asked:
        'One intersection has 12 crashes a year and another has 20. Which is '
        'more dangerous?',
    rate: _theIntersection,
    options: [
      'The one with 20, obviously',
      'The one with 12, since fewer crashes means a worse road',
      'It cannot be said until each count is set against the traffic that '
          'went through',
      'Neither: crash counts are not comparable at all',
    ],
    answer: 2,
    why:
        'You cannot tell yet. A crossroads carrying thirty thousand vehicles '
        'a day has far more chances to produce a crash than one carrying '
        'eight thousand. Dividing by the traffic is what makes two places '
        'comparable, and that division is the whole of this calculation.',
    source: 'trans-tf-q3',
  ),
  ExposureRound(
    subject: 'building the denominator',
    asked:
        'The count here is 8,000 vehicles a DAY and the crashes are counted '
        'over a YEAR. What goes underneath?',
    rate: _theIntersection,
    options: [
      '8,000, the daily count',
      '8,000 times 365, the vehicles that entered in the year',
      '8,000 divided by 365',
      '365 on its own',
    ],
    answer: 1,
    why:
        'The whole year of traffic, 2.92 million vehicles. The periods have '
        'to match: a year of crashes over a year of traffic. Dividing by the '
        'daily count instead gives 1,500 per million, which is the lesson\'s '
        'wrong answer and is absurd on its face, since it would mean more '
        'crashes than vehicles.',
    source: 'trans-tf-q3',
  ),
  ExposureRound(
    subject: 'why a million',
    asked:
        'The formula multiplies by a million. What would happen without it?',
    rate: _theIntersection,
    options: [
      'The answer would be four millionths of a crash per vehicle, a number '
          'nobody can hold in their head',
      'Nothing: it cancels',
      'The units would change to crashes a day',
      'The answer would be a hundred times too big',
    ],
    answer: 0,
    why:
        'You would be quoting crashes per vehicle, which for any real '
        'intersection is a few millionths. Scaling to a million entering '
        'vehicles puts the answer in the range of ones and tens, where '
        'engineers can compare places at a glance.',
    source: 'trans-tf-q3',
  ),
  ExposureRound(
    subject: 'more crashes, better road',
    asked:
        'This intersection has 20 crashes a year on 30,000 vehicles a day. '
        'How does its rate compare with the 12 crashes on 8,000 a day?',
    rate: _busier,
    options: [
      'Worse: more crashes',
      'Better: nearly four times the traffic for under twice the crashes',
      'The same',
      'It cannot be compared at all',
    ],
    answer: 1,
    why:
        'Better, and it is not close: about 1.8 per million entering against '
        '4.1. This is exactly why rates exist. A programme that ranked sites '
        'by raw counts would spend its money at the busiest places rather '
        'than the most dangerous ones.',
    source: 'trans-tf-q3',
  ),
  ExposureRound(
    subject: 'a length of road instead',
    asked:
        'Now the crashes are on three miles of highway rather than at one '
        'intersection. What changes in the denominator?',
    rate: _segment,
    options: [
      'Nothing changes',
      'The days come out of it',
      'The length joins it: the exposure is vehicle MILES, not vehicles',
      'The crashes are divided by three',
    ],
    answer: 2,
    why:
        'The length joins in, because a vehicle on a three mile stretch is '
        'exposed three times as long as one crossing a single intersection. '
        'So a segment rate is per million vehicle miles and an intersection '
        'rate is per million entering vehicles, and the two are not '
        'interchangeable.',
    source: 'trans-tf-q3',
  ),
  ExposureRound(
    subject: 'which rate belongs where',
    asked:
        'A city wants to rank its worst signalized junctions. Which rate '
        'should it use?',
    rate: _theIntersection,
    options: [
      'Per million vehicle miles, since that is the more precise measure',
      'Per million entering vehicles, because a junction is a place rather '
          'than a length',
      'Either: they give the same ranking',
      'Neither: use the raw count',
    ],
    answer: 1,
    why:
        'Entering vehicles, because a junction has no meaningful length. '
        'Mixing the two measures makes a list that cannot be read: the '
        'numbers are in different units and a low figure in one is not '
        'comparable with a low figure in the other.',
    source: 'trans-tf-q3',
  ),
];

class _PerMillionWhatGameState extends State<PerMillionWhatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'per-million-what',
    chapterId: 'transportation',
    total: exposureRounds.length,
    sourceProblemIdOf: (round) => exposureRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  ExposureRound get _round => exposureRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Per Million What',
        closing:
            'A crash count means nothing until it is set against the traffic '
            'that was exposed. Annualize the daily count so the periods '
            'match, scale to a million so the answer is readable, and carry '
            'the length as well when it is a stretch of road rather than a '
            'junction. A busier place with more crashes can be the safer one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: crashRateBrief,
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
            'CRASHES AGAINST TRAFFIC',
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
            height: 196,
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
                  painter: ExposurePainter(
                    rate: r.rate,
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
