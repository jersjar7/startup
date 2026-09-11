import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'thermal_figures.dart';

/// Which Arm — the third item for `thermal-processing-phase-diagrams`.
///
/// The lever rule is one subtraction over another, and the only thing anybody
/// gets wrong is WHICH subtraction: the fraction of a phase uses the arm on
/// the far side from it. The lesson's own problem names that swap as its
/// first trap, and the swap is not an arithmetic slip, it is a picture that
/// was never looked at properly. So the picture is what the round asks about,
/// and no round asks for a number.
class WhichArmGame extends StatefulWidget {
  const WhichArmGame({super.key});

  @override
  State<WhichArmGame> createState() => _WhichArmGameState();
}

@immutable
class ArmRound {
  const ArmRound({
    required this.subject,
    required this.asked,
    required this.tie,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Tie tie;
  final Arm answer;
  final String why;
  final String source;
}

const tieRounds = <ArmRound>[
  ArmRound(
    subject: 'the lesson\'s alloy',
    asked:
        'You want the fraction that is LIQUID. Tap the piece that goes on '
        'top.',
    tie: Tie(solid: 10, overall: 30, liquid: 40),
    answer: Arm.toSolid,
    why:
        'The arm running back to the SOLID boundary, which is the far side '
        'from the liquid. That is the whole rule and it feels backwards until '
        'you check it at the ends: slide the alloy right up against the '
        'liquid boundary and that arm becomes the whole tie line, giving a '
        'fraction of one. All liquid, which is exactly right.',
    source: 'mat-tpd-q3',
  ),
  ArmRound(
    subject: 'the same alloy at the same temperature',
    asked: 'Now you want the fraction that is SOLID. Tap the piece on top.',
    tie: Tie(solid: 10, overall: 30, liquid: 40),
    answer: Arm.toLiquid,
    why:
        'The other arm, out to the LIQUID boundary. Same tie line, same '
        'alloy, other question, other arm. Notice the two fractions have to '
        'add to one, which is the cheapest check there is: if your two '
        'answers do not add up, you used the same arm twice.',
    source: 'mat-tpd-q3',
  ),
  ArmRound(
    subject: 'what goes underneath',
    asked:
        'Whichever fraction you are after, tap the piece that goes on the '
        'bottom of it.',
    tie: Tie(solid: 10, overall: 30, liquid: 40),
    answer: Arm.whole,
    why:
        'The whole tie line, boundary to boundary. It is the same denominator '
        'for both phases, and it is measured between the two BOUNDARIES, '
        'never from zero. Dividing by the liquid composition instead of by '
        'the tie line is this problem\'s other named wrong answer.',
    source: 'mat-tpd-q3',
  ),
  ArmRound(
    subject: 'an alloy sitting close to the solid boundary',
    asked: 'Tap the piece that goes on top of the LIQUID fraction.',
    tie: Tie(solid: 15, overall: 22, liquid: 45),
    answer: Arm.toSolid,
    why:
        'The short arm, back to the solid boundary. Short arm on top means a '
        'small fraction: this alloy is under a quarter liquid, and the '
        'picture says so before any arithmetic does. Sitting near a boundary '
        'means being mostly THAT phase, which is the sense check to run '
        'before you trust a lever rule answer.',
    source: 'mat-tpd-q3',
  ),
  ArmRound(
    subject: 'an alloy sitting close to the liquid boundary',
    asked: 'Tap the piece that goes on top of the SOLID fraction.',
    tie: Tie(solid: 5, overall: 35, liquid: 45),
    answer: Arm.toLiquid,
    why:
        'The short arm, out to the liquid boundary. This alloy is nearly all '
        'liquid, so the solid fraction must come out small, and the short arm '
        'is the only piece that can give a small answer. Reading the picture '
        'this way catches a swapped lever rule instantly.',
    source: 'mat-tpd-q3',
  ),
  ArmRound(
    subject: 'an alloy exactly halfway across',
    asked:
        'The alloy sits at the middle of the tie line. Tap the piece that '
        'goes underneath either fraction.',
    tie: Tie(solid: 20, overall: 35, liquid: 50),
    answer: Arm.whole,
    why:
        'The whole tie line, as always. Here the two arms are the same '
        'length, so both fractions come out at a half: half liquid and half '
        'solid. The denominator never changes with the question. Only the arm '
        'on top does.',
    source: 'mat-tpd-q3',
  ),
];

class _WhichArmGameState extends State<WhichArmGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-arm',
    chapterId: 'materials',
    total: tieRounds.length,
    sourceProblemIdOf: (round) => tieRounds[round].source,
  )..addListener(_onSession);

  Arm? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ArmRound get _round => tieRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Arm',
        closing:
            'The fraction of a phase is the arm on the FAR side from it, over '
            'the whole tie line. Liquid fraction takes the arm back to the '
            'solid boundary; solid fraction takes the arm out to the liquid '
            'one. The two must add to one, and an alloy sitting near a '
            'boundary is mostly that phase, which catches the swap before the '
            'arithmetic does.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: tieLineBrief,
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
            'TAP THE PIECE OF THE TIE LINE',
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
              final size = Size(box.maxWidth, 255);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = TiePainter.nearest(
                            size, r.tie, details.localPosition);
                        if (hit != null) setState(() => _picked = hit);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: TiePainter(
                        tie: r.tie,
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
            'the two bars above the line are the arms, the one below is all of it',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          // The rule with the part being asked about left out of it. The
          // whole formula printed here would answer the round.
          Center(
            child: MathText(
              r'$f = \dfrac{\text{one arm}}{\text{the whole tie line}}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE PIECE' : 'THE OTHER ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
