import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'traffic_flow_figures.dart';
import 'lesson_brief.dart';

/// Half of Each — the first item for `traffic-flow`.
///
/// Flow is speed times density, and under Greenshields the speed falls in a
/// straight line as the density rises. The product of a falling line and a
/// rising one peaks in the middle: half the free flow speed, half the jam
/// density, and a quarter of their product.
class HalfOfEachGame extends StatefulWidget {
  const HalfOfEachGame({super.key});

  @override
  State<HalfOfEachGame> createState() => _HalfOfEachGameState();
}

@immutable
class PeakFlowRound {
  const PeakFlowRound({
    required this.subject,
    required this.asked,
    required this.stream,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Stream stream;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own freeway: 70 mph free flow, 180 vehicles a mile at a
/// standstill, so 3,150 an hour at the peak.
const _freeway = Stream(freeFlow: 70, jamDensity: 180);

/// The lesson's other road, quieter and slower.
const _arterial = Stream(freeFlow: 60, jamDensity: 120);

const peakFlowRounds = <PeakFlowRound>[
  PeakFlowRound(
    subject: 'why the flow curve turns over',
    asked:
        'Flow is speed times density. Why does it rise, peak, and then fall '
        'again?',
    stream: _freeway,
    options: [
      'Because the speed limit changes',
      'Because more vehicles each go more slowly, and past a point the '
          'slowing beats the extra vehicles',
      'Because the road gets shorter',
      'It does not: more vehicles always means more flow',
    ],
    answer: 1,
    why:
        'Because the two terms fight. Adding vehicles adds to the density but '
        'takes away from the speed, and their product rises only while the '
        'first effect is winning. An empty road carries nothing because there '
        'is nobody on it, and a jam carries nothing because nobody is moving.',
    source: 'trans-tf-q1',
  ),
  PeakFlowRound(
    subject: 'where the peak sits',
    asked:
        'At the peak of the flow curve, what are the speed and the density?',
    stream: _freeway,
    options: [
      'The free flow speed and the jam density',
      'Half the free flow speed and half the jam density',
      'A quarter of each',
      'The free flow speed and half the jam density',
    ],
    answer: 1,
    why:
        'Half of each, exactly. It follows from the straight line: a product '
        'of two terms, one falling as the other rises, peaks in the middle. '
        'On this freeway that means 35 mph with 90 vehicles to the mile, '
        'which is a good deal slower than most drivers think capacity feels '
        'like.',
    source: 'trans-tf-q1',
  ),
  PeakFlowRound(
    subject: 'and so what the peak is',
    asked:
        'Half the free flow speed times half the jam density. What does that '
        'come to?',
    stream: _freeway,
    options: [
      'The free flow speed times the jam density',
      'Half their product',
      'A quarter of their product',
      'An eighth of their product',
    ],
    answer: 2,
    why:
        'A quarter, because each half contributes one. On this freeway 70 '
        'times 180 is 12,600, and the peak flow is a quarter of that: 3,150 '
        'vehicles an hour in the lane. The lesson prints 12,600, 6,300 and '
        '1,575 as the versions with no four, a two, and an eight.',
    source: 'trans-tf-q1',
  ),
  PeakFlowRound(
    subject: 'capacity is not comfort',
    asked:
        'A lane carrying its maximum flow is moving at half the free flow '
        'speed. What does that feel like to drive?',
    stream: _freeway,
    options: [
      'Wide open, since the flow is at its best',
      'Dense and slow, right on the edge of breaking down',
      'Stopped',
      'Exactly as it does on an empty road',
    ],
    answer: 1,
    why:
        'Crowded and slow. Maximum FLOW is not maximum comfort: it is the '
        'most vehicles an hour, reached at a density where the traffic is '
        'about to break down. Push a little past it and both the speed and '
        'the flow fall together, which is how a freeway collapses in minutes '
        'and takes an hour to recover.',
    source: 'trans-tf-q1',
  ),
  PeakFlowRound(
    subject: 'a different road',
    asked:
        'This road has a lower free flow speed and a lower jam density than '
        'the freeway. What happens to its peak flow?',
    stream: _arterial,
    options: [
      'It is lower, since both numbers that make the peak are lower',
      'It is higher',
      'It is the same: the quarter cancels',
      'It cannot be compared',
    ],
    answer: 0,
    why:
        'Lower, and by the product of both reductions. 60 times 120 over four '
        'is 1,800 an hour against the freeway\'s 3,150. That is the honest '
        'reason a city street cannot be made to carry freeway volumes by '
        'timing alone.',
    source: 'trans-tf-q2',
  ),
  PeakFlowRound(
    subject: 'two densities, one flow',
    asked:
        'A lane is carrying 2,000 vehicles an hour. How many densities could '
        'produce that?',
    stream: _freeway,
    options: [
      'One',
      'Two: one below the peak and one above it',
      'None',
      'Any number',
    ],
    answer: 1,
    why:
        'Two, one on each side of the peak, because the curve is a parabola. '
        'The same flow can mean a fast light lane or a slow crowded one, so '
        'flow alone does not tell you how the road is working. That is '
        'exactly why level of service is judged on DENSITY rather than on '
        'volume.',
    source: 'trans-tf-q1',
  ),
];

class _HalfOfEachGameState extends State<HalfOfEachGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'half-of-each',
    chapterId: 'transportation',
    total: peakFlowRounds.length,
    sourceProblemIdOf: (round) => peakFlowRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  PeakFlowRound get _round => peakFlowRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Half of Each',
        closing:
            'Speed falls in a straight line as the lane fills, so flow, which '
            'is their product, is a parabola. It peaks at half the free flow '
            'speed and half the jam density, which makes the peak a QUARTER '
            'of their product. And two quite different densities give the '
            'same flow, which is why density, not volume, tells you how a '
            'road is really working.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: greenshieldsBrief,
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
            'SPEED, DENSITY, FLOW',
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
            height: 234,
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
                  painter: GreenshieldsPainter(
                    stream: r.stream,
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
