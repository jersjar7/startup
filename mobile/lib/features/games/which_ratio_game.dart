import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'trig_figures.dart';

/// Which Ratio — the first item for `right-triangle-trig`.
///
/// One side is given, another is wanted, and the student picks the ratio that
/// connects them. Nothing is evaluated. The marked angle moves between the two
/// corners round to round, so opposite and adjacent have to be read off the
/// drawing rather than remembered as up and along.
class WhichRatioGame extends StatefulWidget {
  const WhichRatioGame({super.key});

  @override
  State<WhichRatioGame> createState() => _WhichRatioGameState();
}

@immutable
class RatioRound {
  const RatioRound({
    required this.context,
    required this.known,
    required this.wanted,
    required this.angleAtTop,
    required this.mirror,
    required this.source,
  });

  final String context;
  final TriSide known;
  final TriSide wanted;
  final bool angleAtTop;
  final bool mirror;
  final String source;

  /// The ratio that connects the two sides in play.
  TriRatio get answer =>
      TriRatio.values.firstWhere((r) => r.sides.containsAll({known, wanted}));
}

const ratioRounds = <RatioRound>[
  RatioRound(
    context:
        'You are 50 m from a building on level ground and you measure the '
        'angle up to its roof. You want the height.',
    known: TriSide.adjacent,
    wanted: TriSide.opposite,
    angleAtTop: false,
    mirror: false,
    source: 'math-rtt-q1',
  ),
  RatioRound(
    context:
        'A cable of known length runs to an anchor. You want the height it '
        'reaches.',
    known: TriSide.hypotenuse,
    wanted: TriSide.opposite,
    angleAtTop: false,
    mirror: true,
    source: 'math-rtt-q2',
  ),
  RatioRound(
    context:
        'A guy wire of known length is anchored back from the pole. You '
        'want its distance from the base.',
    known: TriSide.hypotenuse,
    wanted: TriSide.adjacent,
    angleAtTop: false,
    mirror: false,
    source: 'math-rtt-q2',
  ),
  RatioRound(
    context:
        'The angle is marked at the TOP corner this time. You know the '
        'side along the ground and want the one it leans on.',
    known: TriSide.opposite,
    wanted: TriSide.adjacent,
    angleAtTop: true,
    mirror: false,
    source: 'math-rtt-q1',
  ),
  RatioRound(
    context:
        'Marked at the top corner again. You know the sloped side and want '
        'the one along the ground.',
    known: TriSide.hypotenuse,
    wanted: TriSide.opposite,
    angleAtTop: true,
    mirror: true,
    source: 'math-rtt-q1',
  ),
  RatioRound(
    context: 'A ramp rises a known height over an unknown run.',
    known: TriSide.opposite,
    wanted: TriSide.adjacent,
    angleAtTop: false,
    mirror: false,
    source: 'math-rtt-q1',
  ),
  RatioRound(
    context:
        'A tower guy line: you know how far back it is anchored and you '
        'want the length of the line itself.',
    known: TriSide.adjacent,
    wanted: TriSide.hypotenuse,
    angleAtTop: false,
    mirror: true,
    source: 'math-rtt-q2',
  ),
  RatioRound(
    context: 'You know the vertical leg and want the sloped side.',
    known: TriSide.opposite,
    wanted: TriSide.hypotenuse,
    angleAtTop: false,
    mirror: false,
    source: 'math-rtt-q1',
  ),
];

class _WhichRatioGameState extends State<WhichRatioGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-ratio',
    chapterId: 'mathematics',
    total: ratioRounds.length,
    sourceProblemIdOf: (round) => ratioRounds[round].source,
  )..addListener(_onSession);

  TriRatio? _choice;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RatioRound get _round => ratioRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Ratio',
        closing:
            'Pick the ratio that connects what you have to what you want, '
            'and read opposite and adjacent off the angle rather than off the '
            'page. Working the number is desk work.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: ratiosBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _choice = null);
              _session.next();
            }
          : (_choice == null
                ? null
                : () => _session.submit(
                    ok: _choice == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHICH RATIO CONNECTS THEM',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.context,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: TrianglePainter(
                    angleAtTop: r.angleAtTop,
                    mirror: r.mirror,
                    known: r.known,
                    wanted: r.wanted,
                    highlight: answered ? r.wanted : null,
                    highlightColor: _session.correct == true
                        ? AppColors.forest
                        : AppColors.error,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final ratio in TriRatio.values) ...[
                Expanded(
                  child: _RatioButton(
                    ratio: ratio,
                    selected: _choice == ratio,
                    locked: answered,
                    isTruth: ratio == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _choice = ratio),
                  ),
                ),
                if (ratio != TriRatio.values.last) const SizedBox(width: 10),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THAT ONE',
              body:
                  '${r.known.label.toLowerCase()} and '
                  '${r.wanted.label.toLowerCase()} are connected by '
                  '${r.answer.label}. Remember cos is cozy with the adjacent '
                  'side, the one touching the angle.',
            ),
            const SizedBox(height: 12),
            Center(child: MathBlock(r.answer.latex, fontSize: 19)),
          ],
        ],
      ),
    );
  }
}

class _RatioButton extends StatelessWidget {
  const _RatioButton({
    required this.ratio,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final TriRatio ratio;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 62,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(ratio.label, style: AppTheme.heading(size: 18)),
        ),
      ),
    );
  }
}
