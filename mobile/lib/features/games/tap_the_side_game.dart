import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'trig_figures.dart';

/// Tap the Side — the second item for `right-triangle-trig`.
///
/// The first item in the whole app where the answer is a place on a drawing
/// rather than a choice in a list. Reading an engineering drawing is over half
/// of what the FE actually shows you, and naming a side is where every trig
/// mistake in this lesson starts.
///
/// The triangle is drawn in four orientations and the marked angle moves
/// between corners, so the names can never be answered by position.
class TapTheSideGame extends StatefulWidget {
  const TapTheSideGame({super.key});

  @override
  State<TapTheSideGame> createState() => _TapTheSideGameState();
}

@immutable
class SideRound {
  const SideRound({
    required this.ask,
    required this.angleAtTop,
    required this.mirror,
    required this.source,
  });

  final TriSide ask;
  final bool angleAtTop;
  final bool mirror;
  final String source;
}

const sideRounds = <SideRound>[
  SideRound(
    ask: TriSide.hypotenuse,
    angleAtTop: false,
    mirror: false,
    source: 'math-rtt-q1',
  ),
  SideRound(
    ask: TriSide.opposite,
    angleAtTop: false,
    mirror: false,
    source: 'math-rtt-q1',
  ),
  SideRound(
    ask: TriSide.adjacent,
    angleAtTop: false,
    mirror: true,
    source: 'math-rtt-q1',
  ),
  SideRound(
    ask: TriSide.opposite,
    angleAtTop: true,
    mirror: false,
    source: 'math-rtt-q2',
  ),
  SideRound(
    ask: TriSide.adjacent,
    angleAtTop: true,
    mirror: true,
    source: 'math-rtt-q2',
  ),
  SideRound(
    ask: TriSide.hypotenuse,
    angleAtTop: true,
    mirror: false,
    source: 'math-rtt-q3',
  ),
  SideRound(
    ask: TriSide.opposite,
    angleAtTop: false,
    mirror: true,
    source: 'math-rtt-q3',
  ),
  SideRound(
    ask: TriSide.adjacent,
    angleAtTop: false,
    mirror: false,
    source: 'math-rtt-q1',
  ),
];

class _TapTheSideGameState extends State<TapTheSideGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'tap-the-side',
    chapterId: 'mathematics',
    total: sideRounds.length,
    sourceProblemIdOf: (round) => sideRounds[round].source,
  )..addListener(_onSession);

  TriSide? _tapped;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SideRound get _round => sideRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Tap the Side',
        closing:
            'The hypotenuse is always across from the right angle. '
            'Opposite and adjacent belong to the angle you marked, not to the '
            'page, and they swap the moment you mark the other corner.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: sideNamesBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _tapped = null);
              _session.next();
            }
          : (_tapped == null
                ? null
                : () =>
                      _session.submit(ok: _tapped == r.ask, context: context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP THE SIDE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            switch (r.ask) {
              TriSide.hypotenuse => 'Tap the hypotenuse.',
              TriSide.opposite => 'Tap the side opposite the marked angle.',
              TriSide.adjacent => 'Tap the side adjacent to the marked angle.',
            },
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Anywhere along it will do.',
            style: TextStyle(fontSize: 13, color: AppColors.ink2),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 260);
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: answered
                        ? null
                        : (details) {
                            final hit = TriangleGeometry(
                              size,
                              angleAtTop: r.angleAtTop,
                              mirror: r.mirror,
                            ).hitTest(details.localPosition);
                            if (hit != null) setState(() => _tapped = hit);
                          },
                    child: EngineeringGrid(
                      minor: 18,
                      major: 90,
                      child: CustomPaint(
                        painter: TrianglePainter(
                          angleAtTop: r.angleAtTop,
                          mirror: r.mirror,
                          highlight: answered ? r.ask : _tapped,
                          highlightColor: !answered
                              ? AppColors.ember
                              : (_session.correct!
                                    ? AppColors.forest
                                    : AppColors.error),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            _tapped == null
                ? 'Nothing picked yet'
                : 'You picked: ${_tapped!.label.toLowerCase()}',
            style: AppTheme.mono(size: 13, color: AppColors.ink2),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THAT SIDE',
              body: switch (r.ask) {
                TriSide.hypotenuse =>
                  'The hypotenuse is the side across from the right angle. It '
                      'is the only name that never moves.',
                TriSide.opposite =>
                  'Opposite means it does not touch the marked angle. Move the '
                      'angle to the other corner and this name moves with it.',
                TriSide.adjacent =>
                  'Adjacent is the side touching the marked angle that is not '
                      'the hypotenuse. Cos is cozy with this one.',
              },
            ),
          ],
        ],
      ),
    );
  }
}
