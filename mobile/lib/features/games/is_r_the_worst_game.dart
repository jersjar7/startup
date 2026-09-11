import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'mohr_figures.dart';

/// Is R the Worst — the third item for `combined-stresses-mohrs-circle`.
///
/// The hard problem in this lesson is the one everybody gets wrong by stopping
/// one step early. The radius of the circle is the worst shear on the planes
/// you can see in the page. It is not always the worst shear at the point,
/// because there is a third principal stress out of the page and for a point
/// on a free surface it is ZERO. If the circle never reaches zero, the real
/// spread is from zero out to the far end, and the worst shear is half of
/// that.
///
/// It is answerable by looking: does the circle touch or cross the origin?
class IsRTheWorstGame extends StatefulWidget {
  const IsRTheWorstGame({super.key});

  @override
  State<IsRTheWorstGame> createState() => _IsRTheWorstGameState();
}

/// The three candidates for the worst shear at a point.
enum Worst { radius, halfTop, halfBottom }

extension WorstWords on Worst {
  String get plain => switch (this) {
        Worst.radius => 'The radius of the circle',
        Worst.halfTop => 'Half the way from zero up to the right hand end',
        Worst.halfBottom => 'Half the way from the left hand end up to zero',
      };
}

@immutable
class WorstRound {
  const WorstRound({
    required this.subject,
    required this.setting,
    required this.stress,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Stress stress;
  final String why;
  final String source;

  /// What each candidate comes to.
  double sizeOf(Worst worst) => switch (worst) {
        Worst.radius => stress.radius,
        Worst.halfTop => (stress.s1 - Stress.s3).abs() / 2,
        Worst.halfBottom => (Stress.s3 - stress.s2).abs() / 2,
      };

  /// The biggest of the three, which is the worst shear at the point. Worked
  /// out rather than declared, and the tests insist the winner is clear of
  /// the others by enough to be read off a drawing.
  Worst get answer {
    var best = Worst.radius;
    for (final w in Worst.values) {
      if (sizeOf(w) > sizeOf(best) + 1e-9) best = w;
    }
    return best;
  }
}

const worstRounds = <WorstRound>[
  WorstRound(
    subject: 'tension one way, compression the other',
    setting:
        'The circle for this point runs from well below zero to well above it.',
    stress: Stress(x: 80, y: -20, xy: 0),
    why:
        'The radius, because this circle already straddles zero. The third '
        'principal stress out of the page is zero, and zero is INSIDE the '
        'spread between the other two, so it adds nothing: the widest gap '
        'between any two of the three principal stresses is still the one '
        'across the circle. When the circle crosses the axis, the in-plane '
        'answer is the answer.',
    source: 'mm-csm-q1',
  ),
  WorstRound(
    subject: 'the lesson\'s hardest problem',
    setting:
        'A hundred and twenty one way, forty the other, thirty of shear. Look '
        'at where the circle sits against the zero mark.',
    stress: Stress(x: 120, y: 40, xy: 30),
    why:
        'Half the way from zero up to the right hand end: sixty five, against '
        'a radius of fifty. Both principal stresses are tension, so the circle '
        'never reaches zero, and the real spread of principal stresses is from '
        'zero to a hundred and thirty rather than from thirty to a hundred and '
        'thirty. Stopping at the radius is the named wrong answer, and it '
        'understates the shear by thirty percent.',
    source: 'mm-csm-q3',
  ),
  WorstRound(
    subject: 'a point squeezed both ways',
    setting:
        'Everything here is compression, so the whole circle sits to the left '
        'of zero.',
    stress: Stress(x: -40, y: -120, xy: 20),
    why:
        'Half the way from the left hand end up to zero. The same argument '
        'the other way round: with both principal stresses compressive, zero '
        'is outside them and the widest gap runs from the most compressive '
        'stress up to nothing. A buried pile or a deep concrete core is '
        'exactly this case.',
    source: 'mm-csm-q3',
  ),
  WorstRound(
    subject: 'a shaft in pure torsion',
    setting: 'No normal stress at all, forty of shear.',
    stress: Stress(x: 0, y: 0, xy: 40),
    why:
        'The radius. Pure shear gives principal stresses of plus forty and '
        'minus forty, so the circle sits centered on zero and could not '
        'straddle it more completely. This is the friendliest case: the shear '
        'you were given IS the worst shear at the point.',
    source: 'mm-csm-q2',
  ),
  WorstRound(
    subject: 'two tensions almost the same size',
    setting:
        'A hundred one way and ninety the other, with a little shear. The '
        'circle is small and sits a long way out.',
    stress: Stress(x: 100, y: 90, xy: 5),
    why:
        'Half the way from zero up to the right hand end, and it is not close: '
        'about fifty against a radius of about seven. This is the case that '
        'punishes a habit hardest. The two normal stresses being nearly equal '
        'makes the in-plane shear nearly nothing, and the point is still '
        'carrying a serious shear on a plane out of the page.',
    source: 'mm-csm-q3',
  ),
  WorstRound(
    subject: 'a beam web under bending and shear',
    setting:
        'Sixty along the beam, nothing across it, forty of shear. The circle '
        'reaches back past zero.',
    stress: Stress(x: 60, y: 0, xy: 40),
    why:
        'The radius, fifty. The shear is big enough here to pull the left hand '
        'end of the circle below zero, into compression, so zero is inside the '
        'spread again and adds nothing. The test is always the same and it '
        'takes one look: does the circle reach the zero mark?',
    source: 'mm-csm-q2',
  ),
];

class _IsRTheWorstGameState extends State<IsRTheWorstGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'is-r-the-worst',
    chapterId: 'mechanics-materials',
    total: worstRounds.length,
    sourceProblemIdOf: (round) => worstRounds[round].source,
  )..addListener(_onSession);

  Worst? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WorstRound get _round => worstRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Is R the Worst',
        closing:
            'The third principal stress is zero, and it counts. If the circle '
            'crosses the zero mark, the radius is the worst shear at the '
            'point. If the whole circle sits to one side of zero, the worst '
            'shear is half the gap from zero to the far end, and it is bigger '
            'than the radius. One look at the drawing settles it.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final window = Window.over([r.stress]);

    return BoardShell(
      session: _session,
      brief: worstBrief,
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
            'WHAT IS THE WORST SHEAR AT THIS POINT',
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
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 160,
              child: CustomPaint(
                painter: MohrPainter(
                  stress: r.stress,
                  span: window,
                  spots: const [Spot.s1, Spot.s2],
                  locked: false,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'the two marks are the principal stresses. zero is marked too',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\tau_{abs} = \dfrac{\sigma_{max} - \sigma_{min}}{2}, \quad \sigma_3 = 0$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final w in Worst.values) ...[
            _Choice(
              label: w.plain,
              selected: _picked == w,
              locked: answered,
              isTruth: w == r.answer,
              onTap: answered ? null : () => setState(() => _picked = w),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE WORST' : 'SOMETHING IS WORSE',
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
