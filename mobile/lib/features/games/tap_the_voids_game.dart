import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'asphalt_figures.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Tap the Voids — the first item for `asphalt-mix-design`.
///
/// Every formula in this lesson is a share of a compacted specimen, and the
/// only hard part is which share: air against the whole mix, binder against
/// the space between the stones, the stone volume against the whole. Written
/// as letters they all look alike, which is why the problems get lost. Drawn
/// as one column they are three bands and a bracket, and the question stops
/// being algebra.
class TapTheVoidsGame extends StatefulWidget {
  const TapTheVoidsGame({super.key});

  @override
  State<TapTheVoidsGame> createState() => _TapTheVoidsGameState();
}

@immutable
class VoidRound {
  const VoidRound({
    required this.subject,
    required this.asked,
    required this.puck,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Puck puck;
  final Piece2 answer;
  final String why;
  final String source;
}

/// A mix at the design target: four percent air, eleven percent binder by
/// volume, so fifteen percent voids in the mineral aggregate.
const _design = Puck(air: 4, binder: 11);

/// A lean, tight mix: too little air and not much room for binder.
const _tight = Puck(air: 2.5, binder: 9.5);

/// An open one that was never compacted enough.
const _open = Puck(air: 7, binder: 10);

const voidRounds = <VoidRound>[
  VoidRound(
    subject: 'a mix at the design point',
    asked:
        'Tap the part that the air void percentage measures.',
    puck: _design,
    answer: Piece2.air,
    why:
        'The air, as a share of the WHOLE specimen. That is what the formula '
        'with the two gravities gives you: how far the compacted mix is from '
        'the same mix with no air in it at all. Four percent is where '
        'Superpave aims, which is this specimen exactly.',
    source: 'mat-asp-q1',
  ),
  VoidRound(
    subject: 'the space between the stones',
    asked:
        'Tap what the voids in the mineral aggregate measure.',
    puck: _design,
    answer: Piece2.vma,
    why:
        'The bracket: air and binder together, which is all the space between '
        'the stones however it is filled. That is why the hierarchy in the '
        'lesson reads VMA equals air plus the binder voids, and why VMA is '
        'always the bigger of the two numbers.',
    source: 'mat-asp-q3',
  ),
  VoidRound(
    subject: 'what VFA is a share of',
    asked:
        'Voids filled with asphalt is the binder as a share of something. Tap '
        'the something.',
    puck: _design,
    answer: Piece2.vma,
    why:
        'The VMA, not the whole specimen. VFA asks how much of the space '
        'between the stones the binder has taken: eleven parts out of fifteen '
        'here, so about 73 percent. Dividing the binder by the whole mix '
        'instead gives 11, which is why the lesson names that as a wrong '
        'answer.',
    source: 'mat-asp-q2',
  ),
  VoidRound(
    subject: 'the theoretical maximum',
    asked:
        'Tap the part that the theoretical maximum specific gravity assumes '
        'is not there.',
    puck: _open,
    answer: Piece2.air,
    why:
        'The air. That gravity is the same aggregate and the same binder with '
        'the air squeezed out, which is why it is always the LARGER of the '
        'two: more mass in less volume. If your air voids come out negative, '
        'you have the two the wrong way round.',
    source: 'mat-asp-q1',
  ),
  VoidRound(
    subject: 'a thin film around every stone',
    asked:
        'This mix looks dry and the film around each stone is too thin. Tap '
        'the part there is too little of.',
    puck: _tight,
    answer: Piece2.binder,
    why:
        'The binder, which is the part VFA counts. With the stones packed '
        'this tightly the VMA is only twelve percent, and once the air has '
        'taken its share there is very little room left for asphalt. That is '
        'why VMA is specified as a minimum: not for its own sake, but because '
        'a mix with nowhere to put binder gets a film too thin to last, and '
        'it oxidizes and cracks whatever the air voids say.',
    source: 'mat-asp-q2',
  ),
  VoidRound(
    subject: 'what the long term looks like',
    asked:
        'The VMA formula subtracts one term from a hundred. Tap the part that '
        'term measures.',
    puck: _design,
    answer: Piece2.aggregate,
    why:
        'The stone itself. The bulk gravity times the aggregate share over '
        'the aggregate gravity is the volume the aggregate occupies, and '
        'whatever is not stone is VMA. Reporting that subtracted term as the '
        'answer gives 86 percent, which is the other wrong answer the lesson '
        'names, and it should look obviously wrong: a compacted mix is not 86 '
        'percent void.',
    source: 'mat-asp-q3',
  ),
];

class _TapTheVoidsGameState extends State<TapTheVoidsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'tap-the-voids',
    chapterId: 'materials',
    total: voidRounds.length,
    sourceProblemIdOf: (round) => voidRounds[round].source,
  )..addListener(_onSession);

  Piece2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  VoidRound get _round => voidRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Tap the Voids',
        closing:
            'Three bands and a bracket. Air voids are the air over the WHOLE '
            'specimen. VMA is the air and the binder together, the whole '
            'space between the stones. VFA is the binder as a share of that '
            'bracket, never of the whole mix. And the term the VMA formula '
            'subtracts is the stone, which is why it comes out near eighty '
            'six and the VMA near fourteen.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: voidsBrief,
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
            'TAP THE PART',
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
              final size = Size(box.maxWidth, 250);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = PuckPainter.at(
                            size, r.puck, details.localPosition);
                        if (hit != null) setState(() => _picked = hit);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: PuckPainter(
                        puck: r.puck,
                        picked: _picked,
                        answer: r.answer,
                        locked: answered,
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
            'one specimen by volume. the voids are drawn far bigger than '
            'they are, or nothing could be pointed at',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE PART' : 'NOT THAT PART',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
