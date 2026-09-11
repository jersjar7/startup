import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'alignment_figures.dart';

/// Which Piece Is That — the first item for `horizontal-curves`.
///
/// A curve has six lengths on it and five of them are easy to confuse with
/// each other, which is why the lesson's own tangent problem offers the
/// curve length as a wrong answer and its station problem names the same
/// confusion as a trap. None of them is hard once the drawing is in your
/// head: the tangent runs out to the PI, the arc is the road itself, the
/// chord cuts across, and the two short ones measure how far the road bulges
/// away from each of those.
class WhichPieceIsThatGame extends StatefulWidget {
  const WhichPieceIsThatGame({super.key});

  @override
  State<WhichPieceIsThatGame> createState() => _WhichPieceIsThatGameState();
}

@immutable
class PieceRound {
  const PieceRound({
    required this.subject,
    required this.asked,
    required this.bend,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The piece the round names.
  final Bit asked;
  final Bend2 bend;
  final String why;
  final String source;

  Bit get answer => asked;
}

const pieceRounds = <PieceRound>[
  PieceRound(
    subject: 'the lesson\'s own curve',
    asked: Bit.tangent,
    bend: Bend2(radius: 1000, turn: 40),
    why:
        'The tangent distance runs from the PC straight out to the PI, along '
        'the line the road was on before it started turning. It is R times '
        'the tangent of HALF the intersection angle, which on this curve is '
        '364 feet. The other tangent, from the PI on to the PT, is the same '
        'length: the curve is symmetric about the PI.',
    source: 'surv-hc-q2',
  ),
  PieceRound(
    subject: 'the road itself',
    asked: Bit.arc,
    bend: Bend2(radius: 800, turn: 50),
    why:
        'The curve length is the arc from PC to PT, which is the piece of '
        'road a car actually drives and the piece the stationing runs along. '
        'On this curve it is 698 feet. Every station between the PC and the '
        'PT is measured round this arc, never out through the PI.',
    source: 'surv-hc-q3',
  ),
  PieceRound(
    subject: 'the straight line across',
    asked: Bit.chord,
    bend: Bend2(radius: 1000, turn: 75),
    why:
        'The long chord joins the PC to the PT directly, cutting across '
        'everything the road does in between. It is always shorter than the '
        'arc, and on a flat curve the two are nearly equal, which is why '
        'chords are what get taped when a curve is set out on the ground.',
    source: 'surv-hc-q2',
  ),
  PieceRound(
    subject: 'from the corner to the road',
    asked: Bit.external,
    bend: Bend2(radius: 700, turn: 100),
    why:
        'The external distance is the gap from the PI in to the middle of '
        'the arc: how far the road misses the corner by. It is the number '
        'that says whether the curve clears a building on the inside of the '
        'bend, and it grows very fast as the turn gets sharper.',
    source: 'surv-hc-q2',
  ),
  PieceRound(
    subject: 'the bulge off the chord',
    asked: Bit.middle,
    bend: Bend2(radius: 900, turn: 110),
    why:
        'The middle ordinate is measured from the middle of the long chord '
        'out to the middle of the arc. It is the sag between the straight '
        'line and the road, and it is what a sight distance check across the '
        'inside of a curve comes down to: whether there is room between the '
        'chord and the ditch.',
    source: 'surv-hc-q2',
  ),
  PieceRound(
    subject: 'out to the center',
    asked: Bit.radius,
    bend: Bend2(radius: 955, turn: 80),
    why:
        'The radius runs from the center of the curve out to the PC, and it '
        'meets the tangent there at a right angle, which is what makes the '
        'whole geometry work. Everything else on this drawing is worked out '
        'of the radius and the turn. This one is 955 feet, which is the '
        'radius of the lesson\'s own six degree curve.',
    source: 'surv-hc-q1',
  ),
];

class _WhichPieceIsThatGameState extends State<WhichPieceIsThatGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-piece-is-that',
    chapterId: 'surveying',
    total: pieceRounds.length,
    sourceProblemIdOf: (round) => pieceRounds[round].source,
  )..addListener(_onSession);

  Bit? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PieceRound get _round => pieceRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Piece Is That',
        closing:
            'The tangent runs out to the PI, the arc is the road, the chord '
            'cuts across from PC to PT. The external measures from the PI in '
            'to the road, the middle ordinate from the chord out to it, and '
            'the radius from the center to the PC, square to the tangent '
            'there. Six lengths, one drawing, and the drawing is worth more '
            'than the six formulas.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: roadCurveBrief,
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
            'TAP IT ON THE CURVE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              r.asked.plain,
              style: AppTheme.mono(size: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Curve(
            bend: r.bend,
            picked: _picked,
            answer: r.answer,
            locked: answered,
            onPick: answered ? null : (p) => setState(() => _picked = p),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'ANOTHER PIECE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Curve extends StatelessWidget {
  const _Curve({
    required this.bend,
    required this.picked,
    required this.answer,
    required this.locked,
    required this.onPick,
  });

  final Bend2 bend;
  final Bit? picked;
  final Bit answer;
  final bool locked;
  final void Function(Bit)? onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 280);
        return GestureDetector(
          onTapUp: onPick == null
              ? null
              : (details) {
                  final hit =
                      AlignPainter.at(size, bend, details.localPosition);
                  if (hit != null) onPick!(hit);
                },
          child: Container(
            height: size.height,
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
                  painter: AlignPainter(
                    bend: bend,
                    picked: picked,
                    answer: locked ? answer : null,
                    locked: locked,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
