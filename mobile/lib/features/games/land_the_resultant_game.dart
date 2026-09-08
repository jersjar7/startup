import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'grid_figures.dart';
import 'lesson_brief.dart';
import 'vector_figures.dart';

/// Land the Resultant — the first item for `vector-basics-unit-vectors`.
///
/// Answered by putting a finger where the resultant ends. The lesson's loudest
/// trap is adding magnitudes instead of components, and it survives being told
/// not to, because the two only differ when the arrows point different ways.
/// Pointing at the place they actually land makes the difference visible: an
/// arrow that came back on itself is shorter, and one round here cancels to
/// nothing at all. The numbers are small so that this is a picture, not a
/// calculation.
class LandTheResultantGame extends StatefulWidget {
  const LandTheResultantGame({super.key});

  @override
  State<LandTheResultantGame> createState() => _LandTheResultantGameState();
}

@immutable
class ResultantRound {
  const ResultantRound({
    required this.ask,
    required this.parts,
    required this.labels,
    required this.why,
    required this.source,
  });

  final String ask;
  final List<Vec> parts;
  final List<String> labels;
  final String why;
  final String source;

  /// Where the chain ends. Added up here rather than declared, so a round
  /// cannot disagree with its own arrows.
  (int, int) get answer {
    var sum = const Vec(0, 0);
    for (final p in parts) {
      sum = sum + p;
    }
    return (sum.x.round(), sum.y.round());
  }

  /// The same arrows laid head to tail, for the reveal.
  List<Arrow> get chain {
    final out = <Arrow>[];
    var at = const Vec(0, 0);
    for (final p in parts) {
      out.add(Arrow(at + p, from: at, color: AppColors.ink3, faint: true));
      at = at + p;
    }
    return out;
  }
}

const resultantRounds = <ResultantRound>[
  ResultantRound(
    ask: 'Two pulls on a pin. Where does the resultant end?',
    parts: [Vec(3, 0), Vec(0, 4)],
    labels: ['A', 'B'],
    why:
        'Three across and four up lands at three across and four up. Adding '
        'the lengths would have given seven, and seven is the distance you '
        'would walk, not the distance you end up from the start.',
    source: 'math-vbu-q1',
  ),
  ResultantRound(
    ask: 'Three forces on a gusset plate. Where does the resultant end?',
    parts: [Vec(5, 0), Vec(-2, 3), Vec(0, -4)],
    labels: ['F1', 'F2', 'F3'],
    why:
        'Add the across parts, then the up parts, signs and all: five minus '
        'two is three, and three minus four is minus one. The minus signs are '
        'doing real work here, and dropping them is the whole mistake.',
    source: 'math-vbu-q3',
  ),
  ResultantRound(
    ask: 'Where does the resultant end?',
    parts: [Vec(2, 3), Vec(3, -1)],
    labels: ['A', 'B'],
    why:
        'The second arrow comes back down while it goes across, so the '
        'resultant sits lower than either arrow reached on its own.',
    source: 'math-vbu-q3',
  ),
  ResultantRound(
    ask: 'Both arrows head into the third quadrant. Where do they land?',
    parts: [Vec(-3, 2), Vec(-1, -5)],
    labels: ['A', 'B'],
    why:
        'Minus three and minus one is minus four; two and minus five is minus '
        'three. Every component keeps its sign through the addition, whatever '
        'quadrant the answer ends up in.',
    source: 'math-vbu-q3',
  ),
  ResultantRound(
    ask: 'Where does the resultant end?',
    parts: [Vec(4, 4), Vec(-4, -4)],
    labels: ['A', 'B'],
    why:
        'Straight back where it started. Two arrows of the same length can '
        'add to nothing at all, which is exactly what adding their lengths '
        'could never tell you.',
    source: 'math-vbu-q3',
  ),
  ResultantRound(
    ask: 'Three arrows. Where does the resultant end?',
    parts: [Vec(1, -2), Vec(2, 4), Vec(-4, 1)],
    labels: ['A', 'B', 'C'],
    why:
        'One plus two minus four is minus one; minus two plus four plus one '
        'is three. The order you add them in does not matter, which is worth '
        'knowing when a free body diagram has six arrows on it.',
    source: 'math-vbu-q3',
  ),
];

class _LandTheResultantGameState extends State<LandTheResultantGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'land-the-resultant',
    chapterId: 'mathematics',
    total: resultantRounds.length,
    sourceProblemIdOf: (round) => resultantRounds[round].source,
  )..addListener(_onSession);

  (int, int)? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ResultantRound get _round => resultantRounds[_session.round];

  static const _span = 6;

  void _tap(Offset local, Size box) {
    if (_session.answered) return;
    final hit = GridGeometry(box, span: _span).nearest(local, tolerance: 0.6);
    if (hit != null) setState(() => _picked = hit);
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Land the Resultant',
        closing:
            'Vectors add component by component, never length by length. '
            'Once the resultant is placed, its size is the square root of the '
            'squares, and that part belongs at a desk.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final colors = [AppColors.ember, AppColors.forest, AppColors.info];

    return BoardShell(
      session: _session,
      brief: vectorAddBrief,
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
            'PUT IT WHERE IT LANDS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the point where the arrows add up to.',
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final size = Size(box.maxWidth, box.maxHeight);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _tap(d.localPosition, size),
                      child: CustomPaint(
                        painter: VectorPainter(
                          span: _span,
                          lattice: true,
                          picked: _picked,
                          truth: answered ? r.answer : null,
                          revealed: answered,
                          arrows: [
                            if (answered) ...r.chain,
                            for (var i = 0; i < r.parts.length; i++)
                              Arrow(
                                r.parts[i],
                                color: colors[i % colors.length],
                                label: r.labels[i],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              for (var i = 0; i < r.parts.length; i++)
                _PartChip(
                  label: r.labels[i],
                  vec: r.parts[i],
                  color: colors[i % colors.length],
                ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHERE' : 'NOT THERE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _PartChip extends StatelessWidget {
  const _PartChip({
    required this.label,
    required this.vec,
    required this.color,
  });

  final String label;
  final Vec vec;
  final Color color;

  @override
  Widget build(BuildContext context) {
    String part(double v, String hat) {
      final sign = v < 0 ? '-' : '';
      return '$sign${v.abs().toStringAsFixed(0)}$hat';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        '$label = ${part(vec.x, 'i')} ${vec.y < 0 ? '-' : '+'} '
        '${vec.y.abs().toStringAsFixed(0)}j',
        style: AppTheme.mono(size: 12.5, color: AppColors.charcoal),
      ),
    );
  }
}
