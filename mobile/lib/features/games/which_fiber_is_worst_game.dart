import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';
import 'stress_figures.dart';

/// Which Fiber Is Worst — the first item for `bending-shear-stresses`.
///
/// Both formulas in this lesson are about a PLACE in the cross section, and
/// the two places are opposites: bending is nothing at the neutral axis and
/// worst at the faces, shear is nothing at the faces and worst at the neutral
/// axis. Neither of those is arithmetic. What is arithmetic, the size of the
/// stress, stays on paper.
class WhichFiberIsWorstGame extends StatefulWidget {
  const WhichFiberIsWorstGame({super.key});

  @override
  State<WhichFiberIsWorstGame> createState() => _WhichFiberIsWorstGameState();
}

/// What a round is looking for.
enum Wanted { mostTension, mostCompression, noBending, mostShear }

extension WantedWords on Wanted {
  String get asked => switch (this) {
        Wanted.mostTension => 'Tap the layer being pulled hardest.',
        Wanted.mostCompression => 'Tap the layer being squashed hardest.',
        Wanted.noBending =>
          'Tap the layer that feels no bending stress at all.',
        Wanted.mostShear => 'Tap the layer carrying the most shear stress.',
      };

  Runs get shows =>
      this == Wanted.mostShear ? Runs.shear : Runs.bending;
}

@immutable
class FiberRound {
  const FiberRound({
    required this.subject,
    required this.section,
    required this.wanted,
    required this.sagging,
    required this.labels,
    required this.why,
    required this.source,
  });

  final String subject;
  final Profile section;
  final Wanted wanted;

  /// True for a beam bending the usual way, concave up, with the top squashed.
  /// False over a support, where it is the other way round.
  final bool sagging;

  /// What the marked layers are called, bottom first.
  final List<String> labels;

  final String why;
  final String source;

  /// Five layers through the depth, including the neutral axis, which is the
  /// centroid and not the middle of the depth.
  List<Layer> get layers {
    final base = section.baseline;
    final top = section.crown;
    final axis = section.centroid.dy;
    final ys = [base, (base + axis) / 2, axis, (axis + top) / 2, top];
    return [
      for (var i = 0; i < ys.length; i++) Layer(ys[i], labels[i]),
    ];
  }

  double get moment => sagging ? 20e6 : -20e6;
  static const shear = 60000.0;

  /// Read off the section rather than declared: whichever marked layer wins
  /// on whatever the round is asking about.
  int get answer {
    final marks = layers;
    var best = -1e30;
    var at = 0;
    for (var i = 0; i < marks.length; i++) {
      final y = marks[i].y;
      final score = switch (wanted) {
        Wanted.mostTension => section.bendingStressAt(y, moment),
        Wanted.mostCompression => -section.bendingStressAt(y, moment),
        Wanted.noBending => -section.bendingStressAt(y, moment).abs(),
        Wanted.mostShear => section.shearStressAt(y, shear),
      };
      if (score > best + 1e-9) {
        best = score;
        at = i;
      }
    }
    return at;
  }
}

const _labels = ['bottom face', 'lower quarter', 'neutral axis',
    'upper quarter', 'top face'];

final fiberRounds = <FiberRound>[
  FiberRound(
    subject: 'a timber beam across a room',
    section: boxSection(100, 200),
    wanted: Wanted.mostTension,
    sagging: true,
    labels: _labels,
    why:
        'The bottom face. A beam sagging between two supports is being '
        'stretched along its underside and squashed along its top, and the '
        'further from the neutral axis the harder, which is the c in M c over '
        'I. The extreme fiber is the one that fails first and the only one '
        'the formula is about.',
    source: 'mm-bss-q1',
  ),
  FiberRound(
    subject: 'the same beam, over a support',
    section: boxSection(100, 200),
    wanted: Wanted.mostTension,
    sagging: false,
    labels: _labels,
    why:
        'The TOP face this time. Over a support the beam hogs instead of '
        'sagging, and the stretched side swaps to the top. Nothing about the '
        'formula changed, only the sign of the moment, and that is why the '
        'reinforcement in a continuous concrete beam moves to the top over the '
        'columns.',
    source: 'mm-bss-q1',
  ),
  FiberRound(
    subject: 'a beam sagging under load',
    section: boxSection(150, 300),
    wanted: Wanted.noBending,
    sagging: true,
    labels: _labels,
    why:
        'The neutral axis, halfway up a rectangle. It is stretched by nothing '
        'and squashed by nothing however big the moment gets, which is why '
        'you can put a service hole through the middle of a beam\'s depth and '
        'not through its flanges.',
    source: 'mm-bss-q1',
  ),
  FiberRound(
    subject: 'the same beam, carrying shear',
    section: boxSection(150, 300),
    wanted: Wanted.mostShear,
    sagging: true,
    labels: _labels,
    why:
        'The neutral axis again, and this is the part that surprises people: '
        'the shear stress is WORST exactly where the bending stress is '
        'nothing, and nothing at the two faces where the bending is worst. It '
        'runs as a parabola through the depth, and its peak is half again the '
        'plain average of V over A.',
    source: 'mm-bss-q2',
  ),
  FiberRound(
    subject: 'a tee, sagging',
    section: teeSection(
      depth: 300,
      flangeWidth: 200,
      flangeThickness: 40,
      webThickness: 30,
    ),
    wanted: Wanted.noBending,
    sagging: true,
    labels: _labels,
    why:
        'The neutral axis, and on a tee that is NOT halfway up: it sits high, '
        'up where most of the material is. The marked line is the section\'s '
        'centroid, which is what the neutral axis always is. So the bottom of '
        'a tee is much further from the axis than the top, and it is the '
        'bottom that decides the beam.',
    source: 'mm-bss-q1',
  ),
  FiberRound(
    subject: 'a steel I-beam carrying shear',
    section: iSection(
      depth: 300,
      flangeWidth: 150,
      flangeThickness: 20,
      webThickness: 10,
    ),
    wanted: Wanted.mostShear,
    sagging: true,
    labels: _labels,
    why:
        'The neutral axis, in the middle of the web. On an I-beam the web '
        'carries nearly all the shear and the flanges carry nearly all the '
        'bending, which is the whole reason the shape exists. That is also why '
        'the stress jumps where the flange meets the web: the width the shear '
        'has to squeeze through drops from the flange to the web in one step.',
    source: 'mm-bss-q3',
  ),
];

class _WhichFiberIsWorstGameState extends State<WhichFiberIsWorstGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-fiber-is-worst',
    chapterId: 'mechanics-materials',
    total: fiberRounds.length,
    sourceProblemIdOf: (round) => fiberRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FiberRound get _round => fiberRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Fiber Is Worst',
        closing:
            'Bending is nothing at the neutral axis and worst at the faces. '
            'Shear is nothing at the faces and worst at the neutral axis. The '
            'neutral axis is the centroid, which is halfway up only when the '
            'section is symmetric. Sagging stretches the bottom; hogging '
            'stretches the top.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: fiberBrief,
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
            r.sagging ? 'THE BEAM IS SAGGING' : 'THE BEAM IS HOGGING',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.wanted.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 230);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = LayerPainter.nearest(
                          r.section,
                          size,
                          r.layers,
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
                      painter: LayerPainter(
                        profile: r.section,
                        layers: r.layers,
                        picked: _picked,
                        truth: answered ? r.answer : -1,
                        locked: answered,
                        show: answered ? r.wanted.shows : null,
                        moment: r.moment,
                        shear: FiberRound.shear,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_picked != null && !answered) ...[
            const SizedBox(height: 8),
            Text(
              r.layers[_picked!].label,
              style: AppTheme.mono(size: 12, color: AppColors.ember),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            Text(
              'the line beside it is how that stress runs through the depth',
              style: AppTheme.mono(size: 11, color: AppColors.ink3),
            ),
            const SizedBox(height: 12),
            BoardFeedback(
              correct: _session.correct!,
              title:
                  _session.correct! ? 'THAT IS THE LAYER' : 'A DIFFERENT LAYER',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
