import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'fluid_figures.dart';
import 'lesson_brief.dart';

/// Same Depth, Same Pressure — the first item for `hydrostatic-pressure`.
///
/// The pressure formula has two things in it, the liquid and the depth, and
/// what is NOT in it is the whole point: not the shape of the vessel, not how
/// much water there is, not how wide the surface is. People find that hard to
/// believe until they see two very different vessels marked at the same
/// depth, which is exactly what this item draws.
class SameDepthGame extends StatefulWidget {
  const SameDepthGame({super.key});

  @override
  State<SameDepthGame> createState() => _SameDepthGameState();
}

/// Which marked point is under the most pressure, or neither.
enum Harder { left, right, alike }

extension HarderWords on Harder {
  String get plain => switch (this) {
        Harder.left => 'The left one',
        Harder.right => 'The right one',
        Harder.alike => 'Neither: the same pressure',
      };
}

@immutable
class DepthRound {
  const DepthRound({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Pot left;
  final Pot right;
  final String why;
  final String source;

  /// Worked out from the two vessels, never declared.
  Harder get answer {
    final gap = (left.pressure - right.pressure).abs() /
        (left.pressure > right.pressure ? left.pressure : right.pressure);
    if (gap < 0.01) return Harder.alike;
    return left.pressure > right.pressure ? Harder.left : Harder.right;
  }

  double get ratio => left.pressure > right.pressure
      ? left.pressure / right.pressure
      : right.pressure / left.pressure;

  double get deepest =>
      left.depth > right.depth ? left.depth : right.depth;

  List<Pot> get both => [left, right];
}

const depthRounds = <DepthRound>[
  DepthRound(
    subject: 'a jug and a barrel',
    setting:
        'Two open vessels of water, both filled to the same depth. One holds '
        'a great deal more than the other.',
    left: Pot(shape: Shape4.tapered, depth: 3),
    right: Pot(shape: Shape4.flared, depth: 3),
    why:
        'Neither: the same pressure, and this is the fact worth arguing with '
        'until it sticks. Only the depth and the liquid are in the formula. '
        'How much water is above and to the side of the point does not come '
        'into it, because the walls carry that, and the water directly over '
        'the point is the same column in both.',
    source: 'fm-hp-q1',
  ),
  DepthRound(
    subject: 'one filled deeper',
    setting:
        'The same two vessels, now filled to different depths. Same water in '
        'both.',
    left: Pot(shape: Shape4.straight, depth: 2),
    right: Pot(shape: Shape4.straight, depth: 5),
    why:
        'The deeper one, and in direct proportion: five meters is two and a '
        'half times the pressure of two. Depth is the only thing that has '
        'changed and it is the only thing that matters. Five meters of water '
        'is about 49 kilopascals, which is the lesson\'s own first problem.',
    source: 'fm-hp-q1',
  ),
  DepthRound(
    subject: 'water against oil',
    setting:
        'Both vessels are filled to four meters. The right hand one holds an '
        'oil that is lighter than water.',
    left: Pot(shape: Shape4.straight, depth: 4),
    right: Pot(
      shape: Shape4.straight,
      depth: 4,
      gamma: 8338,
      liquid: 'oil',
    ),
    why:
        'The water, by about a fifth. The other thing in the formula is the '
        'liquid\'s specific weight, and oil at a specific gravity of 0.85 '
        'weighs less per cubic meter, so four meters of it presses less hard. '
        'Depth and liquid: that is the whole formula.',
    source: 'fm-hp-q2',
  ),
  DepthRound(
    subject: 'the same tank, two points',
    setting:
        'Two points in identical tanks of water. The left point is halfway '
        'down and the right one is at the bottom.',
    left: Pot(shape: Shape4.straight, depth: 6, pointDepth: 3),
    right: Pot(shape: Shape4.straight, depth: 6),
    why:
        'The bottom one, at twice the pressure. What counts is the depth of '
        'the POINT below the free surface, not how deep the tank is. This is '
        'why pressure on a dam is drawn as a triangle: nothing at the top, '
        'most at the bottom, and straight in between.',
    source: 'fm-hp-q1',
  ),
  DepthRound(
    subject: 'a narrow neck on a wide base',
    setting:
        'A vessel with a narrow neck and a wide base, against a plain '
        'cylinder. Both are filled to the same depth with water.',
    left: Pot(shape: Shape4.stepped, depth: 4),
    right: Pot(shape: Shape4.straight, depth: 4),
    why:
        'Neither, and this one is the hydrostatic paradox proper. The vessel '
        'on the left holds far more water, yet the pressure on its base is '
        'the same, and the force on the base is the same for equal areas. A '
        'thin tube of water four meters tall would do it too, which is why a '
        'header tank on a roof can pressurize a whole building.',
    source: 'fm-hp-q1',
  ),
  DepthRound(
    subject: 'shallow oil against deep water',
    setting:
        'Three meters of water on the left, against four meters of the same '
        'lighter oil on the right.',
    left: Pot(shape: Shape4.straight, depth: 3),
    right: Pot(
      shape: Shape4.flared,
      depth: 4,
      gamma: 8338,
      liquid: 'oil',
    ),
    why:
        'The oil, just: four meters of it comes to about 33 kilopascals '
        'against the water\'s 29. Being lighter per meter is not enough when '
        'there is a third more of it. Both numbers move here, and as always '
        'the question is only which moved further.',
    source: 'fm-hp-q2',
  ),
];

class _SameDepthGameState extends State<SameDepthGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'same-depth',
    chapterId: 'fluid-mechanics',
    total: depthRounds.length,
    sourceProblemIdOf: (round) => depthRounds[round].source,
  )..addListener(_onSession);

  Harder? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DepthRound get _round => depthRounds[_session.round];

  int? _index(Harder? which) => switch (which) {
        Harder.left => 0,
        Harder.right => 1,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Same Depth, Same Pressure',
        closing:
            'Two things decide it: how deep the point is below the free '
            'surface, and what the liquid weighs. Nothing else. Not the shape '
            'of the vessel, not how much liquid there is, not how wide the '
            'surface is. A narrow pipe of water and a lake of it, at the same '
            'depth, press equally hard.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: depthBrief,
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
            'TAP THE POINT UNDER MORE PRESSURE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
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
                        final hit =
                            PotPainter.at(size, r.both, details.localPosition);
                        if (hit == null) return;
                        setState(() =>
                            _picked = hit == 0 ? Harder.left : Harder.right);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: PotPainter(
                        pots: r.both,
                        deepest: r.deepest,
                        picked: _index(_picked),
                        answer: answered ? _index(r.answer) : null,
                        locked: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$p = \gamma h$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Harder.alike.plain,
            selected: _picked == Harder.alike,
            locked: answered,
            isTruth: r.answer == Harder.alike,
            onTap:
                answered ? null : () => setState(() => _picked = Harder.alike),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS RIGHT' : 'NOT QUITE',
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
