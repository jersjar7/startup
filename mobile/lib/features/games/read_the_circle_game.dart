import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'mohr_figures.dart';

/// Read the Circle — the first item for `combined-stresses-mohrs-circle`.
///
/// The lesson says you rarely need to draw the circle, and that is true of the
/// arithmetic. It is not true of the understanding: every quantity in this
/// lesson is a PLACE on that circle, and a student who knows where each one
/// sits never mixes up the radius with a principal stress, which is the trap
/// in two of the lesson's three problems.
///
/// So the circle is drawn with its places marked and the answer is which place
/// the question is asking for. Nothing is computed.
class ReadTheCircleGame extends StatefulWidget {
  const ReadTheCircleGame({super.key});

  @override
  State<ReadTheCircleGame> createState() => _ReadTheCircleGameState();
}

@immutable
class MohrRound {
  const MohrRound({
    required this.subject,
    required this.asked,
    required this.stress,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What is wanted, described by what it MEANS rather than by its name.
  final String asked;

  final Stress stress;
  final Spot answer;
  final String why;
  final String source;

  static const spots = [
    Spot.s2,
    Spot.center,
    Spot.s1,
    Spot.topShear,
    Spot.xFace,
  ];
}

const mohrRounds = <MohrRound>[
  MohrRound(
    subject: 'a point under tension and shear',
    asked:
        'Tap the largest stress pulling this point apart on any plane through '
        'it.',
    stress: Stress(x: 60, y: 0, xy: 40),
    answer: Spot.s1,
    why:
        'The rightmost point of the circle, which is the center plus the '
        'radius. That is what a principal stress IS: the normal stress on the '
        'plane where there is no shear at all, and on this circle you can see '
        'there is exactly one such plane at each end. Note how far right of '
        'the sixty it started at: the shear pushed it there.',
    source: 'mm-csm-q2',
  ),
  MohrRound(
    subject: 'the same point',
    asked: 'Tap the worst shear stress any plane through this point feels.',
    stress: Stress(x: 60, y: 0, xy: 40),
    answer: Spot.topShear,
    why:
        'The top of the circle, and its height above the axis is the RADIUS. '
        'This is the one the lesson warns about twice: the radius is a shear '
        'stress, not a normal one, and reporting it as a principal stress is '
        'the named wrong answer in this very problem. The bottom of the circle '
        'is the same size the other way round.',
    source: 'mm-csm-q2',
  ),
  MohrRound(
    subject: 'a point in a beam web',
    asked:
        'Tap the average of the two normal stresses you were given.',
    stress: Stress(x: 40, y: -10, xy: 25),
    answer: Spot.center,
    why:
        'The center, which sits on the axis at the average of the two normal '
        'stresses. It never moves when the element is rotated, which is worth '
        'holding on to: turning the block changes what each face feels, and '
        'the average of the two always comes out the same.',
    source: 'mm-csm-q1',
  ),
  MohrRound(
    subject: 'a pier under wind and weight',
    asked:
        'Tap the most compressive stress any plane through this point feels.',
    stress: Stress(x: 20, y: -60, xy: 30),
    answer: Spot.s2,
    why:
        'The leftmost point, the center MINUS the radius. Sigma two is the '
        'algebraically smallest, which on a circle that crosses the axis means '
        'the most compressive. Algebraically smallest and smallest in size are '
        'not the same thing, and that distinction is the whole of the next '
        'round.',
    source: 'mm-csm-q1',
  ),
  MohrRound(
    subject: 'a point that is compressed both ways',
    asked:
        'Tap the largest principal stress here, the algebraically largest.',
    stress: Stress(x: -30, y: -110, xy: 20),
    answer: Spot.s1,
    why:
        'The RIGHTMOST point, even though everything here is compression and '
        'that point is the SMALLEST squeeze in the picture. Sigma one means '
        'furthest to the right on the circle, always. A reader who hunts for '
        'the biggest number by size picks the left hand end and has the two '
        'principal stresses swapped.',
    source: 'mm-csm-q1',
  ),
  MohrRound(
    subject: 'where the numbers came from',
    asked:
        'Tap the point that stands for the face the stresses were measured '
        'on.',
    stress: Stress(x: 120, y: 40, xy: 30),
    answer: Spot.xFace,
    why:
        'The point at the normal stress you were given, raised by the shear '
        'you were given. Every plane through the point is somewhere on this '
        'circle, and the face you happened to start from is nothing special: '
        'go a quarter of the way round the circle and you are on the plane '
        'square to it, go to the ends and the shear has gone.',
    source: 'mm-csm-q3',
  ),
];

class _ReadTheCircleGameState extends State<ReadTheCircleGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'read-the-circle',
    chapterId: 'mechanics-materials',
    total: mohrRounds.length,
    sourceProblemIdOf: (round) => mohrRounds[round].source,
  )..addListener(_onSession);

  Spot? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  MohrRound get _round => mohrRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Read the Circle',
        closing:
            'The center is the average of the two normal stresses. The radius '
            'is the worst in-plane shear. The two ends are the principal '
            'stresses, and sigma one is the right hand end whatever the signs '
            'are. Every plane through the point is somewhere on that circle.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final window = Window.over([r.stress]);

    return BoardShell(
      session: _session,
      brief: circleBrief,
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
            'TAP THE PLACE ON THE CIRCLE',
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
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 130,
              child: CustomPaint(
                painter: ElementPainter(
                  stress: r.stress,
                  label: 'the point, and what it feels',
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 210);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = MohrPainter.nearest(
                          r.stress,
                          size,
                          window,
                          MohrRound.spots,
                          details.localPosition,
                        );
                        if (hit != null) setState(() => _picked = hit);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: MohrPainter(
                        stress: r.stress,
                        span: window,
                        spots: MohrRound.spots,
                        picked: _picked,
                        truth: answered ? r.answer : null,
                        locked: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_picked != null && !answered) ...[
            const SizedBox(height: 6),
            Text(
              _picked!.plain,
              style: AppTheme.mono(size: 12, color: AppColors.ember),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 12),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE PLACE' : 'A DIFFERENT PLACE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
