import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'flow_figures.dart';

/// What Moves the Critical Depth — the second item for
/// `energy-critical-flow`.
///
/// The lesson's own tip says it plainly: for a rectangular channel the
/// critical depth depends on the discharge and the width and on nothing
/// else. Not the slope, not the lining, not the length, and not how deep
/// the water happens to be running today. Almost every other quantity in
/// open-channel work does depend on the slope and the roughness, which is
/// why this one gets dragged along with them.
class WhatMovesTheCriticalDepthGame extends StatefulWidget {
  const WhatMovesTheCriticalDepthGame({super.key});

  @override
  State<WhatMovesTheCriticalDepthGame> createState() =>
      _WhatMovesTheCriticalDepthGameState();
}

/// Where the critical depth goes when something about the channel changes.
enum Shifted { up, down, nowhere }

extension ShiftedWords on Shifted {
  String get plain => switch (this) {
        Shifted.up => 'The critical depth goes up',
        Shifted.down => 'The critical depth comes down',
        Shifted.nowhere => 'It does not move at all',
      };
}

@immutable
class ShiftRound {
  const ShiftRound({
    required this.subject,
    required this.change,
    required this.before,
    required this.after,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What was done to the channel, in plain words.
  final String change;
  final Flume before;

  /// The channel after the change. Where nothing about the unit flow
  /// changed, this is the same flume, and the curve does not move.
  final Flume after;
  final String why;
  final String source;

  bool get moved =>
      (after.criticalDepth - before.criticalDepth).abs() > 0.005;

  /// Worked out of the two curves rather than declared.
  Shifted get answer {
    if (!moved) return Shifted.nowhere;
    return after.criticalDepth > before.criticalDepth
        ? Shifted.up
        : Shifted.down;
  }
}

const shiftRounds = <ShiftRound>[
  ShiftRound(
    subject: 'a steeper grade',
    change:
        'The same channel carrying the same flow is re-laid on a much '
        'steeper grade.',
    before: Flume(unitFlow: 9, depth: 3),
    after: Flume(unitFlow: 9, depth: 3),
    why:
        'Nowhere. Critical depth comes out of the discharge and the width, '
        'and the slope appears nowhere in it. What the steeper grade does '
        'change is the depth the water actually runs at, the normal depth, '
        'which will drop and may well fall below the critical depth and turn '
        'the flow supercritical. The flow regime changed; the critical depth '
        'did not.',
    source: 'wr-ecf-q1',
  ),
  ShiftRound(
    subject: 'twice the water',
    change: 'Twice as much water comes down the same channel.',
    before: Flume(unitFlow: 9, depth: 3),
    after: Flume(unitFlow: 18, depth: 3),
    why:
        'Up, but not doubled. The critical depth goes as the unit flow to '
        'the two thirds power, so twice the water raises it by about 1.6 '
        'times, from 2.02 meters to 3.21. This is the one thing on the list '
        'that genuinely moves it, along with the width, and it is why a storm '
        'can put a channel through critical when an ordinary day does not.',
    source: 'wr-ecf-q1',
  ),
  ShiftRound(
    subject: 'a smoother lining',
    change:
        'The earth channel is lined with concrete, taking the roughness '
        'from 0.025 down to 0.013.',
    before: Flume(unitFlow: 9, depth: 3),
    after: Flume(unitFlow: 9, depth: 3),
    why:
        'Nowhere. Roughness is not in the critical depth formula either. The '
        'lining is the first thing most people reach for because it is in '
        'almost every other open-channel calculation, and Manning\'s equation '
        'is right next to this one on the page. The critical depth is a '
        'property of the flow and the shape, not of the surface.',
    source: 'wr-ecf-q1',
  ),
  ShiftRound(
    subject: 'a wider channel',
    change:
        'The same total discharge is carried in a channel twice as wide.',
    before: Flume(unitFlow: 9, depth: 3),
    after: Flume(unitFlow: 4.5, depth: 3),
    why:
        'Down. Width comes in through the unit flow, the discharge divided '
        'by the width, so doubling the width halves q and the critical depth '
        'falls by about a third, from 2.02 meters to 1.27. Width matters '
        'here only because of what it does to q: the formula never sees the '
        'width on its own.',
    source: 'wr-ecf-q1',
  ),
  ShiftRound(
    subject: 'a gate held down the channel',
    change:
        'A gate downstream is lowered, backing the water up so it runs a '
        'meter deeper past this point.',
    before: Flume(unitFlow: 9, depth: 3),
    after: Flume(unitFlow: 9, depth: 4),
    why:
        'Nowhere. The critical depth is not the depth the water is at, it is '
        'the depth at which this flow would carry the least energy, and that '
        'is fixed by the flow alone. Backing the water up moves the flow '
        'further onto the deep arm of the curve and makes it more firmly '
        'subcritical, but the nose of the curve stays exactly where it was.',
    source: 'wr-ecf-q2',
  ),
  ShiftRound(
    subject: 'a drought',
    change: 'The flow falls away to a third of what it was.',
    before: Flume(unitFlow: 9, depth: 3),
    after: Flume(unitFlow: 3, depth: 3),
    why:
        'Down, to 0.97 meters. A third of the flow is about half the critical '
        'depth, again because of the two thirds power. Watch the whole curve '
        'move, not just the nose: less water means less energy needed at '
        'every depth, so the entire curve slides toward the left.',
    source: 'wr-ecf-q1',
  ),
];

class _WhatMovesTheCriticalDepthGameState
    extends State<WhatMovesTheCriticalDepthGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-moves-the-critical-depth',
    chapterId: 'water-resources',
    total: shiftRounds.length,
    sourceProblemIdOf: (round) => shiftRounds[round].source,
  )..addListener(_onSession);

  Shifted? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ShiftRound get _round => shiftRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Moves the Critical Depth',
        closing:
            'Two things move the critical depth of a rectangular channel: '
            'how much water is coming down it and how wide it is, and both '
            'of them only through the flow per unit width. The slope, the '
            'lining, the length and the depth the water happens to be '
            'running at do not appear in the formula and do not move it. They '
            'move where the flow SITS on the curve, which is a different '
            'question and usually the one worth asking next.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: criticalBrief,
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
            'WHERE DOES THE NOSE OF THE CURVE GO',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 250,
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
                  painter: EnergyCurvePainter(
                    flume: r.before,
                    after: answered && r.moved ? r.after : null,
                    label: !answered
                        ? 'q ${r.before.unitFlow.toStringAsFixed(1)} m2/s'
                        : (r.moved
                            ? 'green: after the change'
                            : 'the curve did not move'),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$y_c = \left(\dfrac{q^2}{g}\right)^{1/3}, \; q = \dfrac{Q}{B}$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Shifted.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Shifted.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHERE IT GOES' : 'NOT THAT WAY',
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
