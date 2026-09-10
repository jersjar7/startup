import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'curve_figures.dart';
import 'lesson_brief.dart';

/// Where On the Curve — the first item for `stress-strain-diagrams`.
///
/// The lesson's first heading is a list of five named points and what each one
/// means. Nothing about that is arithmetic: it is reading a picture, which is
/// the one thing a phone does better than paper. So the curve is drawn and the
/// round asks for a point by what it DOES rather than by its name, because
/// knowing the name in the right order is not the same as knowing which
/// behavior it marks.
class WhereOnTheCurveGame extends StatefulWidget {
  const WhereOnTheCurveGame({super.key});

  @override
  State<WhereOnTheCurveGame> createState() => _WhereOnTheCurveGameState();
}

@immutable
class CurveRound {
  const CurveRound({
    required this.subject,
    required this.asked,
    required this.specimen,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What the point DOES, never what it is called.
  final String asked;

  final Specimen specimen;
  final Mark answer;
  final String why;
  final String source;
}

const curveRounds = <CurveRound>[
  CurveRound(
    subject: 'mild steel in tension',
    asked: 'Tap the last point at which stress and strain are still in step.',
    specimen: Specimen(
      label: 'mild steel',
      e: 200000,
      yieldStress: 250,
      ultimate: 400,
      fractureStrain: 0.25,
      plateau: 0.014,
      necksTo: 0.86,
    ),
    answer: Mark.proportional,
    why:
        'The proportional limit, where the straight run ends. Up to there, '
        'double the stress and you get double the strain, which is Hooke\'s '
        'law and the only stretch of curve E can be read from. The bar still '
        'springs back a little past this point, but the two stop being '
        'proportional here.',
    source: 'mm-ssd-q1',
  ),
  CurveRound(
    subject: 'the same steel',
    asked: 'Tap where it keeps stretching without carrying any more load.',
    specimen: Specimen(
      label: 'mild steel',
      e: 200000,
      yieldStress: 250,
      ultimate: 400,
      fractureStrain: 0.25,
      plateau: 0.014,
      necksTo: 0.86,
    ),
    answer: Mark.yieldPoint,
    why:
        'The yield point, and the flat run after it is exactly what the words '
        'describe: more strain, no more stress. This is the number that goes '
        'into design for steel. Not every material shows this flat run, which '
        'is why the next rounds look different.',
    source: 'mm-ssd-q2',
  ),
  CurveRound(
    subject: 'an aluminum alloy',
    asked: 'Tap the most stress this material will ever carry.',
    specimen: Specimen(
      label: 'aluminum alloy',
      e: 70000,
      yieldStress: 240,
      ultimate: 310,
      fractureStrain: 0.12,
      necksTo: 0.88,
    ),
    answer: Mark.ultimate,
    why:
        'The ultimate strength, which is the top of the curve and not the end '
        'of it. The end is lower, and tapping the end is the mistake this '
        'round is for. Note there is no flat run here: aluminum has no yield '
        'plateau, which is why its yield strength is quoted off an offset '
        'line instead.',
    source: 'mm-ssd-q2',
  ),
  CurveRound(
    subject: 'mild steel, pulled to destruction',
    asked: 'Tap where the bar comes apart.',
    specimen: Specimen(
      label: 'mild steel',
      e: 200000,
      yieldStress: 250,
      ultimate: 400,
      fractureStrain: 0.25,
      plateau: 0.014,
      necksTo: 0.86,
    ),
    answer: Mark.fracture,
    why:
        'The fracture point, and it sits BELOW the ultimate. That looks like '
        'the steel got weaker, and it did not. This is engineering stress, '
        'which divides by the ORIGINAL area, and by now the bar has necked '
        'down to something much thinner. The load really is dropping. The '
        'stress in the metal that is left is still climbing.',
    source: 'mm-ssd-q2',
  ),
  CurveRound(
    subject: 'annealed copper',
    asked: 'Tap where the bar starts to neck down.',
    specimen: Specimen(
      label: 'annealed copper',
      e: 117000,
      yieldStress: 70,
      ultimate: 220,
      fractureStrain: 0.45,
      necksTo: 0.78,
    ),
    answer: Mark.ultimate,
    why:
        'Necking begins at the ultimate strength. They are the same point: up '
        'to there the bar thins evenly all along, and after it the thinning '
        'runs away in one place. That is why the curve turns over. The turn '
        'and the start of necking are one event, not two.',
    source: 'mm-ssd-q2',
  ),
  CurveRound(
    subject: 'a high strength steel',
    asked: 'Tap the point past which it will not return to its old length.',
    specimen: Specimen(
      label: 'high strength steel',
      e: 200000,
      yieldStress: 450,
      ultimate: 560,
      fractureStrain: 0.14,
      plateau: 0.004,
      necksTo: 0.9,
    ),
    answer: Mark.yieldPoint,
    why:
        'Yield. Before it the bar springs back, after it some of the stretch '
        'is kept for good. Strictly the lesson names an elastic limit a hair '
        'past the proportional limit and just short of yield, and on a real '
        'curve the three are so close together that the yield point is what '
        'everybody works to. This steel has a much shorter flat run than mild '
        'steel, and it is still a yield point.',
    source: 'mm-ssd-q2',
  ),
];

class _WhereOnTheCurveGameState extends State<WhereOnTheCurveGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-on-the-curve',
    chapterId: 'mechanics-materials',
    total: curveRounds.length,
    sourceProblemIdOf: (round) => curveRounds[round].source,
  )..addListener(_onSession);

  Mark? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CurveRound get _round => curveRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where On the Curve',
        closing:
            'Straight run, then the knee, then yield, then the top, then the '
            'break. The top is the ultimate and the break is lower than it, '
            'because engineering stress keeps dividing by the area the bar '
            'started with. Every property in this lesson is one of these '
            'points or the slope between two of them.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final frame = Frame.over([r.specimen]);

    return BoardShell(
      session: _session,
      brief: curveBrief,
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
            'TAP THE POINT ON THE CURVE',
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
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 210);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = TensilePainter.nearest(
                          r.specimen,
                          frame,
                          size,
                          details.localPosition,
                          Mark.values,
                          within: 30,
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
                      painter: TensilePainter(
                        specimen: r.specimen,
                        frame: frame,
                        labelled: answered ? [r.answer] : const [],
                        dotted: answered
                            ? const []
                            : (_picked == null ? const [] : [_picked!]),
                        wrong: answered && _picked != r.answer ? _picked : null,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'a schematic. each part of the curve is drawn wide enough to see',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE POINT' : 'NOT THAT POINT',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
