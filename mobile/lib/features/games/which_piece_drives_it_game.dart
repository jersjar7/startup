import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'kinetics_figures.dart';
import 'lesson_brief.dart';

/// Which Piece Drives It — the second item for `force-and-acceleration`.
///
/// The lesson's tip is to draw the free body diagram before anything else,
/// and its middle problem is lost by people who draw it and then use the
/// wrong piece of the weight. On a slope the weight splits into one piece
/// running down the surface, which is the only thing accelerating the block,
/// and one pressing into it, which the surface answers exactly and which
/// moves nothing.
///
/// So the arrows are drawn and the answer is which one the question is about.
class WhichPieceDrivesItGame extends StatefulWidget {
  const WhichPieceDrivesItGame({super.key});

  @override
  State<WhichPieceDrivesItGame> createState() =>
      _WhichPieceDrivesItGameState();
}

@immutable
class SlopeRound {
  const SlopeRound({
    required this.subject,
    required this.asked,
    required this.slope,
    required this.answer,
    required this.why,
    required this.source,
    this.arrows = const [Arrow.weight, Arrow.along, Arrow.square, Arrow.normal],
  });

  final String subject;
  final String asked;
  final Slope2 slope;
  final Arrow answer;
  final List<Arrow> arrows;
  final String why;
  final String source;
}

const _thirty = Slope2(degrees: 30, weight: 500);
const _steep = Slope2(degrees: 55, weight: 400);
const _shallow = Slope2(degrees: 15, weight: 600);

/// A middling slope for the round that shows all four arrows. On a gentle one
/// the whole weight and the piece pressing into the surface point almost the
/// same way, and their two heads land close enough together to be one tap
/// target.
const _middling = Slope2(degrees: 40, weight: 450);

const slopeRounds = <SlopeRound>[
  SlopeRound(
    subject: 'the lesson\'s own block',
    asked:
        'Tap the arrow that accelerates this block down the slope.',
    slope: _thirty,
    answer: Arrow.along,
    why:
        'The piece running down the surface, which is the weight times the '
        'SINE of the slope. Two hundred and fifty newtons of the five hundred, '
        'at thirty degrees. The whole weight points straight down and the '
        'block cannot go straight down: the surface is in the way, and what '
        'gets through is the part along it.',
    source: 'dyn-fa-q2',
  ),
  SlopeRound(
    subject: 'the same block',
    asked: 'Tap the arrow the surface pushes straight back against.',
    slope: _thirty,
    answer: Arrow.square,
    why:
        'The piece pressing into the slope, the weight times the COSINE. The '
        'surface answers it exactly, which is why the block does not sink into '
        'the ramp and why this piece accelerates nothing. Using it in place of '
        'the other one is the named trap in this problem and it gives eight '
        'and a half rather than four point nine.',
    source: 'dyn-fa-q2',
  ),
  SlopeRound(
    subject: 'a steeper slope',
    asked:
        'On this steeper slope, tap the LARGER of the two pieces of the '
        'weight.',
    slope: _steep,
    answer: Arrow.along,
    arrows: [Arrow.along, Arrow.square],
    why:
        'The one down the slope. Past forty five degrees the sine overtakes '
        'the cosine, so most of the weight is now driving the block rather '
        'than pressing on the surface. That is why a steep ramp accelerates '
        'things so hard and why the normal force, and with it the friction it '
        'could offer, falls away just when you need it.',
    source: 'dyn-fa-q2',
  ),
  SlopeRound(
    subject: 'a gentle slope',
    asked: 'On this gentle one, tap the LARGER of the two pieces.',
    slope: _shallow,
    answer: Arrow.square,
    arrows: [Arrow.along, Arrow.square],
    why:
        'The one pressing into the slope. At fifteen degrees almost all of the '
        'weight is being carried by the surface and only a quarter of it is '
        'driving the block. Between this round and the last, nothing changed '
        'but the angle, and which piece is bigger swapped over.',
    source: 'dyn-fa-q2',
  ),
  SlopeRound(
    subject: 'what the surface does',
    asked:
        'Tap the force that is NOT part of the weight at all.',
    slope: _thirty,
    answer: Arrow.normal,
    why:
        'The push back from the surface. The other three arrows are the weight '
        'and the two pieces it splits into, all of them gravity. This one is '
        'the ramp shoving back, equal and opposite to the piece pressing into '
        'it, and it is the force people leave off the free body diagram.',
    source: 'dyn-fa-q2',
  ),
  SlopeRound(
    subject: 'the whole of it',
    asked:
        'Tap the arrow you would use if you wanted the force the ramp carries.',
    slope: _middling,
    answer: Arrow.square,
    why:
        'The piece pressing into it, the weight times the cosine, which the '
        'ramp has to carry and answer. Worth holding on to: gravity pulls '
        'straight down and never along a slope, and everything else on this '
        'drawing is bookkeeping to work out how much of that one pull each '
        'direction gets.',
    source: 'dyn-fa-q2',
  ),
];

class _WhichPieceDrivesItGameState extends State<WhichPieceDrivesItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-piece-drives-it',
    chapterId: 'dynamics',
    total: slopeRounds.length,
    sourceProblemIdOf: (round) => slopeRounds[round].source,
  )..addListener(_onSession);

  Arrow? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SlopeRound get _round => slopeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Piece Drives It',
        closing:
            'Gravity pulls straight down. On a slope that splits into a piece '
            'running down the surface, weight times the sine, which is the '
            'only thing accelerating the block, and a piece pressing into it, '
            'weight times the cosine, which the surface answers exactly. Past '
            'forty five degrees the driving piece is the bigger one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: slopeBrief,
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
            'TAP AN ARROW ON THE BLOCK',
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
              final size = Size(box.maxWidth, 230);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = SlopePainter2.nearest(
                          r.slope,
                          size,
                          r.arrows,
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
                      painter: SlopePainter2(
                        slope: r.slope,
                        arrows: r.arrows,
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
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT ARROW',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
