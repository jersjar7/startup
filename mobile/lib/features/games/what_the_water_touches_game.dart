import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'channel_figures.dart';

/// What the Water Touches — the first item for `open-channel-flow`.
///
/// The lesson's own channel problem names using the width alone as the
/// wetted perimeter as its trap, and that is the whole of the difficulty in
/// Manning's equation: the area is easy and the slope is given, but the
/// perimeter has to be reasoned out edge by edge. Two rules settle every
/// case. The water surface is not a wall, so it never counts. Anything above
/// the water line is dry, so it never counts either. What is left is what
/// the water is rubbing against, and rubbing is what slows it down.
class WhatTheWaterTouchesGame extends StatefulWidget {
  const WhatTheWaterTouchesGame({super.key});

  @override
  State<WhatTheWaterTouchesGame> createState() =>
      _WhatTheWaterTouchesGameState();
}

@immutable
class TouchRound {
  const TouchRound({
    required this.subject,
    required this.channel,
    required this.traced,
    required this.fault,
    required this.why,
    required this.source,
  });

  final String subject;
  final Channel channel;

  /// The boundary somebody added up, drawn over the section.
  final List<Edge> traced;

  /// The one piece they got wrong.
  final Edge fault;
  final String why;
  final String source;

  /// The pieces the water is actually rubbing against. Never the surface,
  /// never anything dry.
  static const wetted = [Edge.bed, Edge.leftWet, Edge.rightWet];

  /// Counted when it should not have been, rather than left out.
  bool get isExtra => traced.contains(fault);

  /// The drawing and the answer come from the same place: whatever single
  /// piece the traced boundary disagrees with the water on.
  Edge get answer {
    final wrong = [
      for (final part in Edge.values)
        if (traced.contains(part) != wetted.contains(part)) part,
    ];
    assert(wrong.length == 1, 'a round must have exactly one fault');
    assert(wrong.single == fault, 'the fault named is not the fault drawn');
    return wrong.single;
  }
}

const touchRounds = <TouchRound>[
  TouchRound(
    subject: 'a concrete channel, four feet wide',
    channel: Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 0.6),
    traced: [Edge.bed, Edge.leftWet, Edge.rightWet, Edge.surface],
    fault: Edge.surface,
    why:
        'The water surface. Wetted perimeter means the boundary the water is '
        'rubbing against, and open-channel flow is open precisely because the '
        'top is air. Air does not hold the water back. Counting the surface '
        'here turns 8 feet of perimeter into 12, which drops the hydraulic '
        'radius by a third and the discharge with it.',
    source: 'wr-ocf-q1',
  ),
  TouchRound(
    subject: 'the same channel, counted short',
    channel: Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 0.6),
    traced: [Edge.bed, Edge.leftWet],
    fault: Edge.rightWet,
    why:
        'The right wall was left out. This is the lesson\'s own trap in its '
        'most common form: the bed width gets used as the perimeter and the '
        'walls are forgotten, which here gives 6 feet instead of 8. The rule '
        'for a rectangle is b plus TWICE the depth, because the water rubs '
        'against a wall on each side.',
    source: 'wr-ocf-q1',
  ),
  TouchRound(
    subject: 'a channel with freeboard',
    channel: Channel(shape: Shaped.rectangle, width: 6, depth: 2, rim: 1.5),
    traced: [Edge.bed, Edge.leftWet, Edge.rightWet, Edge.rightDry],
    fault: Edge.rightDry,
    why:
        'The dry part of the right wall. The wall is built taller than the '
        'water for a reason, so the channel can take a bigger storm without '
        'overtopping, but concrete with air against it is not rubbing '
        'anything. The perimeter is measured at the depth the water is '
        'flowing at today, not at the top of the wall.',
    source: 'wr-ocf-q1',
  ),
  TouchRound(
    subject: 'an earth channel with sloped sides',
    channel:
        Channel(shape: Shaped.trapezoid, width: 4, depth: 2, sideRun: 1.5),
    traced: [Edge.leftWet, Edge.rightWet],
    fault: Edge.bed,
    why:
        'The bed was left out. On a trapezoid the two sloped sides are the '
        'interesting part, each one longer than the depth because it leans, '
        'and it is easy to add those up and forget that the water is sitting '
        'on something. The perimeter is the bed plus both sides, and the '
        'sides are measured along the slope, not straight up.',
    source: 'wr-ocf-q1',
  ),
  TouchRound(
    subject: 'a ditch cut deeper than it runs',
    channel: Channel(
        shape: Shaped.trapezoid, width: 3, depth: 2, sideRun: 2, rim: 1),
    traced: [
      Edge.bed,
      Edge.leftWet,
      Edge.rightWet,
      Edge.leftDry,
    ],
    fault: Edge.leftDry,
    why:
        'The dry part of the left side. The same rule as the concrete '
        'channel, and worth seeing twice because on a sloped side the dry '
        'piece is long: the bank keeps going up and out well past the water '
        'line. Measure the side from the bed to the water surface, and stop '
        'there.',
    source: 'wr-ocf-q1',
  ),
  TouchRound(
    subject: 'a wide shallow swale',
    channel: Channel(shape: Shaped.rectangle, width: 12, depth: 1, rim: 0.5),
    traced: [Edge.bed, Edge.leftWet, Edge.rightWet, Edge.surface],
    fault: Edge.surface,
    why:
        'The surface again, and this is where it does the most damage. The '
        'water here is 12 feet across and a foot deep, so counting the '
        'surface almost doubles the perimeter, from 14 feet to 26. It also '
        'shows why a wide shallow channel has a hydraulic radius close to '
        'its depth: the two short walls barely add anything, so the area '
        'over the perimeter is near enough the depth.',
    source: 'wr-ocf-q1',
  ),
];

class _WhatTheWaterTouchesGameState extends State<WhatTheWaterTouchesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-the-water-touches',
    chapterId: 'water-resources',
    total: touchRounds.length,
    sourceProblemIdOf: (round) => touchRounds[round].source,
  )..addListener(_onSession);

  Edge? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TouchRound get _round => touchRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What the Water Touches',
        closing:
            'The wetted perimeter is the boundary the water is rubbing '
            'against, and two rules settle it every time. The free surface '
            'never counts, because air does not hold water back. Nothing '
            'above the water line counts, however tall the wall is built. '
            'Everything else the water is in contact with does, measured '
            'along the surface rather than straight up.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: wettedBrief,
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
            'TAP THE PIECE THEY GOT WRONG',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          const Text(
            'The orange line is the boundary somebody added up for the '
            'wetted perimeter. It is wrong by exactly one piece: either they '
            'counted something the water is not touching, or they left out '
            'something it is.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            channel: r.channel,
            traced: r.traced,
            picked: _picked,
            answer: r.answer,
            locked: answered,
            onPick: answered ? null : (p) => setState(() => _picked = p),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$R_H = \dfrac{A}{P}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? (r.isExtra ? 'THAT ONE IS NOT WET' : 'THAT ONE WAS MISSED')
                  : 'ANOTHER PIECE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.channel,
    required this.traced,
    required this.picked,
    required this.answer,
    required this.locked,
    required this.onPick,
  });

  final Channel channel;
  final List<Edge> traced;
  final Edge? picked;
  final Edge answer;
  final bool locked;
  final void Function(Edge)? onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 250);
        return GestureDetector(
          onTapUp: onPick == null
              ? null
              : (details) {
                  final hit =
                      SectionPainter.at(size, channel, details.localPosition);
                  if (hit != null) onPick!(hit);
                },
          child: Container(
            height: size.height,
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
                  painter: SectionPainter(
                    channel: channel,
                    traced: traced,
                    picked: picked,
                    answer: locked ? answer : null,
                    locked: locked,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
