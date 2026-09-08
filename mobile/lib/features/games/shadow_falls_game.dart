import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'grid_figures.dart';
import 'lesson_brief.dart';
import 'vector_figures.dart';

/// Where the Shadow Falls — the third item for `dot-product-angle`.
///
/// A scalar projection is the length of one arrow's shadow on another, and the
/// two mistakes the lesson names are both mistakes about that sentence: using
/// the raw dot product, which is the shadow times the member's length, and
/// dividing by the force instead of the member. Both stop being tempting once
/// the shadow is a place on a line rather than a term in a formula. So the
/// member is drawn with whole numbers marked along it and the student taps
/// where the shadow lands. A negative round puts the shadow behind the joint,
/// and a perpendicular round puts it at nothing at all.
class ShadowFallsGame extends StatefulWidget {
  const ShadowFallsGame({super.key});

  @override
  State<ShadowFallsGame> createState() => _ShadowFallsGameState();
}

@immutable
class ShadowRound {
  const ShadowRound({
    required this.force,
    required this.unit,
    required this.member,
    required this.memberPlain,
    required this.why,
    required this.source,
  });

  /// The arrow being projected.
  final Vec force;

  /// The member's direction, one long so a mark at i really is i away.
  final Vec unit;

  /// How the member is written on the card, before it was normalized.
  final String member;

  /// The same thing in plain words, for the line of running text under the
  /// question, which is not a place LaTeX can go.
  final String memberPlain;
  final String why;
  final String source;

  /// The dot product with the UNIT direction, which is the shadow itself.
  /// Worked out here rather than declared, so a round cannot disagree with
  /// its own drawing.
  int get answer => (force.x * unit.x + force.y * unit.y).round();
}

const shadowRounds = <ShadowRound>[
  ShadowRound(
    force: Vec(3, 4),
    unit: Vec(1, 0),
    member: r'\vec{d} = 1\hat{i} + 0\hat{j}',
    memberPlain: '1i + 0j',
    why:
        'Along a horizontal member only the across part of the force does any '
        'work, so the shadow is 3. The up part contributes nothing to this '
        'member no matter how big it is.',
    source: 'math-dpa-q3',
  ),
  ShadowRound(
    force: Vec(5, 0),
    unit: Vec(0.6, 0.8),
    member: r'\vec{d} = 3\hat{i} + 4\hat{j}',
    memberPlain: '3i + 4j',
    why:
        'The dot product with the raw member would be 15, and 15 is not a '
        'length anybody wants: it is the shadow times the member. Dividing by '
        'the member length of 5 leaves the shadow, which is 3.',
    source: 'math-dpa-q3',
  ),
  ShadowRound(
    force: Vec(0, 5),
    unit: Vec(0.6, 0.8),
    member: r'\vec{d} = 3\hat{i} + 4\hat{j}',
    memberPlain: '3i + 4j',
    why:
        'Same member, a force straight up instead of straight across, and the '
        'shadow is 4. The member leans more up than across, so it catches '
        'more of this one.',
    source: 'math-dpa-q3',
  ),
  ShadowRound(
    force: Vec(-5, 0),
    unit: Vec(0.6, 0.8),
    member: r'\vec{d} = 3\hat{i} + 4\hat{j}',
    memberPlain: '3i + 4j',
    why:
        'Behind the joint. A projection is signed: negative means the force '
        'pushes back along the member rather than out along it, and dropping '
        'the sign turns a compression into a tension.',
    source: 'math-dpa-q3',
  ),
  ShadowRound(
    force: Vec(3, 4),
    unit: Vec(0.8, -0.6),
    member: r'\vec{d} = 4\hat{i} - 3\hat{j}',
    memberPlain: '4i - 3j',
    why:
        'The force is square on to the member, so its shadow is nothing and '
        'the member carries none of it. This is the perpendicularity test '
        'arriving as a length rather than as a number.',
    source: 'math-dpa-q1',
  ),
  ShadowRound(
    force: Vec(2, 6),
    unit: Vec(0.6, 0.8),
    member: r'\vec{d} = 3\hat{i} + 4\hat{j}',
    memberPlain: '3i + 4j',
    why:
        'Six along the member, out of a force that is a little over six long '
        'in total. Almost all of it lands on the member, because the two very '
        'nearly line up.',
    source: 'math-dpa-q3',
  ),
];

class _ShadowFallsGameState extends State<ShadowFallsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'shadow-falls',
    chapterId: 'mathematics',
    total: shadowRounds.length,
    sourceProblemIdOf: (round) => shadowRounds[round].source,
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

  ShadowRound get _round => shadowRounds[_session.round];

  static const _span = 8;
  static const _from = -4;
  static const _to = 7;

  /// Which mark along the member the finger was nearest, if any.
  void _tap(Offset local, Size box, ShadowRound r) {
    if (_session.answered) return;
    final g = GridGeometry(box, span: _span);
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = _from; i <= _to; i++) {
      final at = g.at(r.unit.x * i, r.unit.y * i);
      final d = (at - local).distance;
      if (d < bestDistance) {
        bestDistance = d;
        best = i;
      }
    }
    // A mark is about 22 points apart on a phone, so anything within a mark
    // and a half resolves rather than doing nothing.
    if (bestDistance <= g.step * 1.5) setState(() => _picked = best);
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where the Shadow Falls',
        closing:
            'The component of a force along a member is the dot product '
            'divided by the MEMBER length, never the force length, and never '
            'left undivided. Working the number out belongs at a desk.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: projectionBrief,
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
            'HOW MUCH LANDS ON THE MEMBER',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Drop the force onto the member and tap the mark its shadow '
            'reaches.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The member runs along ${r.memberPlain}, marked off in whole '
            'units.',
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 320,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final size = Size(box.maxWidth, box.maxHeight);
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _tap(d.localPosition, size, r),
                      child: CustomPaint(
                        painter: VectorPainter(
                          span: _span,
                          ruler: RulerLine(
                            unit: r.unit,
                            from: _from,
                            to: _to,
                          ),
                          rulerPick: _picked,
                          rulerTruth: answered ? r.answer : null,
                          revealed: answered,
                          drop: answered ? r.force : null,
                          arrows: [
                            Arrow(r.force, color: AppColors.ember, label: 'F'),
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
          Row(
            children: [
              Text(
                'Shadow at',
                style: AppTheme.mono(size: 12, color: AppColors.ink2),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.emberBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _picked == null ? '—' : '$_picked',
                  style: AppTheme.mono(size: 14, color: AppColors.ember),
                ),
              ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SHADOW' : 'NOT THAT FAR',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
