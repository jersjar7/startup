import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'channel_figures.dart';

/// Which One Runs Faster — the second item for `open-channel-flow`.
///
/// Manning's equation has three things in it that a channel can differ by,
/// and the lesson's third problem asks about only one of them. Each round
/// here changes exactly ONE: the lining, the slope, the shape, or the depth.
/// That is the only way to see what each term does, and it is how the
/// equation is actually used on a job, where the section is fixed by the
/// site and the engineer is choosing a lining or a grade.
class WhichOneRunsFasterGame extends StatefulWidget {
  const WhichOneRunsFasterGame({super.key});

  @override
  State<WhichOneRunsFasterGame> createState() =>
      _WhichOneRunsFasterGameState();
}

/// Which of the two drawings carries the quicker water.
enum Swifter { top, bottom, same }

extension SwifterWords on Swifter {
  String get plain => switch (this) {
        Swifter.top => 'Channel A, the top one',
        Swifter.bottom => 'Channel B, the bottom one',
        Swifter.same => 'Neither: the same velocity',
      };
}

@immutable
class SwiftRound {
  const SwiftRound({
    required this.subject,
    required this.changed,
    required this.top,
    required this.bottom,
    required this.roughTop,
    required this.roughBottom,
    required this.slopeTop,
    required this.slopeBottom,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The one thing that differs between the two. Naming it keeps the item
  /// honest: a round that changed two things would teach nothing.
  final String changed;

  final Channel top;
  final Channel bottom;
  final double roughTop;
  final double roughBottom;
  final double slopeTop;
  final double slopeBottom;
  final String why;
  final String source;

  static double _speed(Channel c, double n, double slope) =>
      c.constant / n * math.pow(c.hydraulicRadius, 2 / 3) * math.sqrt(slope);

  double get speedTop => _speed(top, roughTop, slopeTop);

  double get speedBottom => _speed(bottom, roughBottom, slopeBottom);

  /// How many times quicker the winner is, for the feedback to quote.
  double get ratio => speedTop > speedBottom
      ? speedTop / speedBottom
      : speedBottom / speedTop;

  /// Worked out of Manning's equation on the two drawings, never declared.
  Swifter get answer {
    if (ratio < 1.01) return Swifter.same;
    return speedTop > speedBottom ? Swifter.top : Swifter.bottom;
  }

  /// Whether the two drawings are the same cut. A slope cannot be shown on
  /// a cross-section at all, and a lining does not change the shape, so on
  /// those rounds the two panels are deliberately identical and the drawing
  /// says so rather than looking like a duplication.
  bool get sameSection => top == bottom;

  String caption(bool isTop) =>
      'n ${(isTop ? roughTop : roughBottom).toStringAsFixed(3)}'
      '   S ${(isTop ? slopeTop : slopeBottom).toStringAsFixed(3)}';
}

const swiftRounds = <SwiftRound>[
  SwiftRound(
    subject: 'concrete against bare earth',
    changed: 'the lining, and nothing else',
    top: Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 0.6),
    bottom: Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 0.6),
    roughTop: 0.013,
    roughBottom: 0.025,
    slopeTop: 0.001,
    slopeBottom: 0.001,
    why:
        'The concrete one, by about 1.9 times. Everything in Manning\'s '
        'equation is identical except n, and n is underneath, so the velocity '
        'ratio is just the roughnesses swapped over: 0.025 over 0.013 is '
        '1.9. That is the whole of the lesson\'s third problem, and the trap '
        'in it is doing the division the other way up and handing the speed '
        'to the rougher channel.',
    source: 'wr-ocf-q3',
  ),
  SwiftRound(
    subject: 'the same ditch on two grades',
    changed: 'the slope, and nothing else',
    top: Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 0.6),
    bottom: Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 0.6),
    roughTop: 0.013,
    roughBottom: 0.013,
    slopeTop: 0.001,
    slopeBottom: 0.004,
    why:
        'The steeper one, but only by twice, not by four times. The slope '
        'goes into Manning\'s under a SQUARE ROOT, so four times the grade '
        'buys two times the speed. This is why making a storm sewer steeper '
        'is an expensive way to buy capacity: the digging goes up much faster '
        'than the flow does.',
    source: 'wr-ocf-q1',
  ),
  SwiftRound(
    subject: 'the same water in two shapes',
    changed: 'the shape, at the same flow area',
    top: Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 0.6),
    bottom: Channel(shape: Shaped.rectangle, width: 10, depth: 0.8, rim: 0.4),
    roughTop: 0.013,
    roughBottom: 0.013,
    slopeTop: 0.002,
    slopeBottom: 0.002,
    why:
        'The deep one. Both sections hold exactly 8 square feet of water, so '
        'the only difference is how much boundary that water is spread '
        'against: 8 feet of perimeter in the compact one against 11.6 in the '
        'wide one. More rubbing for the same water means a smaller hydraulic '
        'radius and slower flow. It is the same reason a narrow deep channel '
        'is the efficient shape.',
    source: 'wr-ocf-q1',
  ),
  SwiftRound(
    subject: 'a pipe full and the same pipe half full',
    changed: 'how much water is in it',
    top: Channel(shape: Shaped.circle, width: 3, depth: 3),
    bottom: Channel(shape: Shaped.circle, width: 3, depth: 1.5),
    roughTop: 0.015,
    roughBottom: 0.015,
    slopeTop: 0.002,
    slopeBottom: 0.002,
    why:
        'Neither: they run at the SAME velocity, which surprises everybody. '
        'Halving the depth halves the area, and it halves the wetted '
        'perimeter with it, so the hydraulic radius is unchanged at a quarter '
        'of the diameter in both. Half the pipe carries half the flow at the '
        'same speed. The full pipe does not win, and between the two the pipe '
        'actually runs fastest somewhere around 80 percent full.',
    source: 'wr-ocf-q2',
  ),
  SwiftRound(
    subject: 'the same channel at two depths',
    changed: 'the depth of water',
    top: Channel(shape: Shaped.rectangle, width: 4, depth: 1, rim: 1.6),
    bottom: Channel(shape: Shaped.rectangle, width: 4, depth: 2, rim: 0.6),
    roughTop: 0.013,
    roughBottom: 0.013,
    slopeTop: 0.001,
    slopeBottom: 0.001,
    why:
        'The deeper one. Deeper water in the same channel gains area faster '
        'than it gains perimeter, because the bed is already counted and only '
        'the two walls grow, so the hydraulic radius climbs from 0.67 feet to '
        '1.0. This is also the answer to why a channel runs faster in a big '
        'storm than a small one: the water is not just deeper, it is quicker.',
    source: 'wr-ocf-q1',
  ),
  SwiftRound(
    subject: 'two natural streams',
    changed: 'the lining again, but by much less',
    top: Channel(
        shape: Shaped.trapezoid, width: 6, depth: 2, sideRun: 1.5, rim: 0.8),
    bottom: Channel(
        shape: Shaped.trapezoid, width: 6, depth: 2, sideRun: 1.5, rim: 0.8),
    roughTop: 0.030,
    roughBottom: 0.035,
    slopeTop: 0.0015,
    slopeBottom: 0.0015,
    why:
        'The clean one, but only by about 1.17 times. Roughness values for '
        'natural channels sit close together, so choosing between them moves '
        'the answer far less than the difference between concrete and earth '
        'does. It is worth knowing which way the small differences go, and '
        'worth not agonizing over the second decimal place of n.',
    source: 'wr-ocf-q3',
  ),
];

class _WhichOneRunsFasterGameState extends State<WhichOneRunsFasterGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-runs-faster',
    chapterId: 'water-resources',
    total: swiftRounds.length,
    sourceProblemIdOf: (round) => swiftRounds[round].source,
  )..addListener(_onSession);

  Swifter? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SwiftRound get _round => swiftRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Runs Faster',
        closing:
            'Three things set the speed and they do not pull equally. '
            'Roughness is underneath, so halving n doubles the velocity. '
            'Slope is under a square root, so four times the grade is only '
            'twice the speed. The hydraulic radius is to the two thirds '
            'power, and it rewards shapes that hold a lot of water against '
            'not much boundary. A pipe half full runs at exactly the speed it '
            'does when full.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: manningBrief,
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
            'WHICH CARRIES THE QUICKER WATER',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'One thing differs between these two: ${r.changed}. '
            '${r.sameSection ? 'The cut is identical, so the difference is '
                'in the numbers written on each one.' : 'Both are drawn to '
                'the same scale.'}',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          _Pair(
            channel: r.top,
            other: r.bottom,
            name: 'A',
            caption: r.caption(true),
            outcome: !answered
                ? null
                : (r.answer == Swifter.same
                    ? AppColors.forest
                    : (r.answer == Swifter.top
                        ? AppColors.forest
                        : AppColors.line)),
          ),
          const SizedBox(height: 8),
          _Pair(
            channel: r.bottom,
            other: r.top,
            name: 'B',
            sameAsOther: r.sameSection,
            caption: r.caption(false),
            outcome: !answered
                ? null
                : (r.answer == Swifter.same
                    ? AppColors.forest
                    : (r.answer == Swifter.bottom
                        ? AppColors.forest
                        : AppColors.line)),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$v = \dfrac{K}{n} R_H^{2/3} S^{1/2}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Swifter.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Swifter.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE QUICKER ONE' : 'THE OTHER ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Pair extends StatelessWidget {
  const _Pair({
    required this.channel,
    required this.other,
    required this.name,
    required this.caption,
    required this.outcome,
    this.sameAsOther = false,
  });

  final Channel channel;

  /// The section this one is being compared with, so both are to one scale.
  final Channel other;
  final String name;
  final String caption;
  final Color? outcome;

  /// Says on the drawing that this is the same cut as the one above it.
  final bool sameAsOther;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: outcome ?? AppColors.line,
          width: outcome == AppColors.forest ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: CustomPaint(
            painter: SectionPainter(
              channel: channel,
              alongside: other,
              caption: '$name    $caption',
              note: sameAsOther
                  ? 'channel $name, the same cut as A'
                  : 'channel $name',
            ),
            child: const SizedBox.expand(),
          ),
        ),
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
