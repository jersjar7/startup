import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'earth_pressure_figures.dart';

/// Triangle or Rectangle — the second item for `lateral-earth-pressure`.
///
/// Two things press on a retaining wall and they press differently. The soil
/// weighs more the deeper you go, so its pressure grows with depth and its
/// diagram is a TRIANGLE with its resultant a third of the way up. A
/// surcharge presses the same at every depth, so its diagram is a RECTANGLE
/// with its resultant at mid height. Adding them as though they were the
/// same shape is the lesson's own hard problem.
class TriangleOrRectangleGame extends StatefulWidget {
  const TriangleOrRectangleGame({super.key});

  @override
  State<TriangleOrRectangleGame> createState() =>
      _TriangleOrRectangleGameState();
}

@immutable
class ShapeRound2 {
  const ShapeRound2({
    required this.subject,
    required this.asked,
    required this.backfill,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Backfill backfill;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _plainWall = Backfill(height: 15, unitWeight: 120, friction: 30);
const _loadedWall =
    Backfill(height: 12, unitWeight: 120, friction: 30, surcharge: 200);

const shapeRounds2 = <ShapeRound2>[
  ShapeRound2(
    subject: 'the soil on its own',
    asked:
        'Nothing but soil behind the wall. What shape is the pressure '
        'diagram?',
    backfill: _plainWall,
    options: [
      'A rectangle: the same at every depth',
      'A triangle the other way up, most at the top',
      'A triangle: nothing at the top, most at the base',
      'A curve, since the soil compresses with depth',
    ],
    answer: 2,
    why:
        'A triangle, with nothing at the surface and the most at the base. '
        'The pressure at any depth is the coefficient times the weight of '
        'soil above it, and that weight grows steadily as you go down. That '
        'is why the total force has a half in it and a height SQUARED.',
    source: 'geo-le-q2',
  ),
  ShapeRound2(
    subject: 'where the soil pushes',
    asked:
        'Whereabouts on the wall does the resultant of that triangle act?',
    backfill: _plainWall,
    options: [
      'Half way up',
      'A third of the height up from the base',
      'A third of the way down from the top',
      'At the base',
    ],
    answer: 1,
    why:
        'A third of the way up, which is where the centroid of a triangle '
        'sits. It matters because the wall has to be checked for overturning '
        'about its toe, and that check is a moment: the same force applied '
        'higher up would tip the wall more easily.',
    source: 'geo-le-q2',
  ),
  ShapeRound2(
    subject: 'a surcharge on the surface',
    asked:
        'Two hundred pounds a square foot is spread over the ground behind '
        'the wall. What shape does that add?',
    backfill: _loadedWall,
    options: [
      'Another triangle, added to the first',
      'A triangle the other way up',
      'Nothing: a surface load does not reach the wall',
      'A rectangle: the same extra pressure at every depth',
    ],
    answer: 3,
    why:
        'A rectangle. The surcharge presses down on the soil everywhere '
        'alike, and the soil passes a share of it sideways at every depth, so '
        'the extra pressure is the same all the way down the wall. Nothing '
        'about it grows with depth because nothing about the surcharge does.',
    source: 'geo-le-q3',
  ),
  ShapeRound2(
    subject: 'where the surcharge pushes',
    asked: 'And where does the rectangle\'s resultant act?',
    backfill: _loadedWall,
    options: [
      'A third of the way up',
      'Two thirds of the way up',
      'Half way up the wall',
      'At the top',
    ],
    answer: 2,
    why:
        'At mid height, where the centroid of a rectangle is. So the two '
        'forces act at different heights and cannot simply be added into one '
        'and placed at a third: for the overturning check each has to be '
        'taken about its own arm.',
    source: 'geo-le-q3',
  ),
  ShapeRound2(
    subject: 'putting the two together',
    asked:
        'The soil gives 2,880 pounds per foot and the surcharge 800. What is '
        'the total force on the wall?',
    backfill: _loadedWall,
    options: [
      '2,880: the surcharge is already in the soil term',
      '3,680: the two simply add, each on its own diagram',
      '800: the surcharge governs',
      '4,800: the surcharge is triangular as well',
    ],
    answer: 1,
    why:
        'They add, 3,680. The two diagrams sit side by side against the same '
        'wall and the force is the whole area. The lesson offers the soil '
        'term alone as a choice, which is what you get by forgetting the '
        'surcharge, and it also offers the version that treats the surcharge '
        'as triangular.',
    source: 'geo-le-q3',
  ),
  ShapeRound2(
    subject: 'why the surcharge matters more than it looks',
    asked:
        'The surcharge adds 67 pounds a square foot of pressure, a seventh of '
        'the 480 the soil reaches at the base. So why is its force more than '
        'a quarter of the soil force?',
    backfill: _loadedWall,
    options: [
      'Because surcharges get a larger coefficient',
      'Because the surcharge acts higher up',
      'Because it presses over the whole height, while the soil pressure '
          'builds up from nothing',
      'It does not: the numbers must be wrong',
    ],
    answer: 2,
    why:
        'Because a rectangle over the full height holds far more area than '
        'its small pressure suggests, while the soil triangle spends its '
        'first few feet near zero. A modest surcharge on top of a wall is '
        'worth more than most people expect, which is why a road or a stack '
        'of material behind a wall has to be asked about.',
    source: 'geo-le-q3',
  ),
];

class _TriangleOrRectangleGameState extends State<TriangleOrRectangleGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'triangle-or-rectangle',
    chapterId: 'geotechnical',
    total: shapeRounds2.length,
    sourceProblemIdOf: (round) => shapeRounds2[round].source,
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

  ShapeRound2 get _round => shapeRounds2[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Triangle or Rectangle',
        closing:
            'The soil presses harder the deeper you go, so its diagram is a '
            'triangle and its resultant sits a third of the way up. A '
            'surcharge presses the same everywhere, so its diagram is a '
            'rectangle and its resultant sits at mid height. The forces add, '
            'but the heights do not: for overturning, each has to be taken '
            'about its own arm. And a modest surcharge is worth more than it '
            'looks, because it acts over the whole wall.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: diagramShapeBrief,
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
            'WHAT SHAPE IS IT',
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
            height: 226,
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
                  painter: WallPainter(
                    backfill: r.backfill,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 10),
            Center(
              child: MathText(
                r'$P_a = \tfrac{1}{2}K_a \gamma H^2 + K_a q H$',
                style: const TextStyle(
                    fontSize: 15, color: AppColors.charcoal),
              ),
            ),
          ],
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
