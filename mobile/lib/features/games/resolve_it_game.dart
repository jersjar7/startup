import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'trig_figures.dart';

/// Resolve It — the third item for `right-triangle-trig`.
///
/// The lesson calls mixing up sine and cosine when resolving a force the
/// biggest trap on the exam, and it is. Half the rounds quote the angle from
/// the vertical, which swaps the two, because that is where the mistake
/// actually happens rather than in the arithmetic.
class ResolveItGame extends StatefulWidget {
  const ResolveItGame({super.key});

  @override
  State<ResolveItGame> createState() => _ResolveItGameState();
}

@immutable
class Resolve {
  const Resolve({
    required this.context,
    required this.degrees,
    required this.fromVertical,
    required this.wantHorizontal,
    required this.source,
  });

  final String context;
  final double degrees;

  /// Whether the quoted angle is measured from the vertical axis.
  final bool fromVertical;

  /// Which component is being asked for.
  final bool wantHorizontal;
  final String source;

  /// Cosine goes with the axis the angle is measured from.
  bool get answerIsCos => wantHorizontal != fromVertical;

  String get answerLatex => answerIsCos ? r'F\cos\theta' : r'F\sin\theta';
}

const resolves = <Resolve>[
  Resolve(
    context:
        'A cable pulls on a bridge anchor at 40 degrees above the '
        'horizontal. You want the horizontal component.',
    degrees: 40,
    fromVertical: false,
    wantHorizontal: true,
    source: 'math-rtt-q2',
  ),
  Resolve(
    context:
        'Same cable, same angle from the horizontal. Now you want the '
        'vertical component.',
    degrees: 40,
    fromVertical: false,
    wantHorizontal: false,
    source: 'math-rtt-q2',
  ),
  Resolve(
    context:
        'A hanger is quoted at 25 degrees from the VERTICAL. You want the '
        'horizontal component.',
    degrees: 25,
    fromVertical: true,
    wantHorizontal: true,
    source: 'math-rtt-q2',
  ),
  Resolve(
    context:
        'The same hanger, 25 degrees from the vertical. You want the '
        'vertical component.',
    degrees: 25,
    fromVertical: true,
    wantHorizontal: false,
    source: 'math-rtt-q2',
  ),
  Resolve(
    context:
        'A guy wire at 55 degrees above the horizontal. You want the pull '
        'along the ground.',
    degrees: 55,
    fromVertical: false,
    wantHorizontal: true,
    source: 'math-rtt-q2',
  ),
  Resolve(
    context:
        'A strut leaning 30 degrees from the vertical carries a load along '
        'its length. You want the downward part.',
    degrees: 30,
    fromVertical: true,
    wantHorizontal: false,
    source: 'math-rtt-q2',
  ),
];

class _ResolveItGameState extends State<ResolveItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'resolve-it',
    chapterId: 'mathematics',
    total: resolves.length,
    sourceProblemIdOf: (round) => resolves[round].source,
  )..addListener(_onSession);

  bool? _choseCos;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Resolve get _round => resolves[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Resolve It',
        closing:
            'The component along the axis the angle is measured from takes '
            'the cosine, the other takes the sine. An angle quoted from the '
            'vertical swaps them, which is where the marks go missing.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: componentsBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _choseCos = null);
              _session.next();
            }
          : (_choseCos == null
                ? null
                : () => _session.submit(
                    ok: _choseCos == r.answerIsCos,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.wantHorizontal
                ? 'THE HORIZONTAL COMPONENT'
                : 'THE VERTICAL COMPONENT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.context,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: ForcePainter(
                    degrees: r.degrees,
                    fromVertical: r.fromVertical,
                    highlightHorizontal: r.wantHorizontal,
                    magnitude: 'F',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Pick(
                  latex: r'F\cos\theta',
                  selected: _choseCos == true,
                  locked: answered,
                  isTruth: r.answerIsCos,
                  onTap: answered
                      ? null
                      : () => setState(() => _choseCos = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Pick(
                  latex: r'F\sin\theta',
                  selected: _choseCos == false,
                  locked: answered,
                  isTruth: !r.answerIsCos,
                  onTap: answered
                      ? null
                      : () => setState(() => _choseCos = false),
                ),
              ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'THE OTHER ONE',
              body: r.fromVertical
                  ? 'The angle is measured from the VERTICAL, so the vertical '
                        'component is the adjacent one and takes the cosine. The '
                        'horizontal takes the sine, which is the reverse of the '
                        'usual case.'
                  : 'The angle is measured from the horizontal, so the '
                        'horizontal component is the adjacent one and takes the '
                        'cosine. Cos is cozy with the side touching the angle.',
            ),
          ],
        ],
      ),
    );
  }
}

class _Pick extends StatelessWidget {
  const _Pick({
    required this.latex,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String latex;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 74,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: MathBlock(latex, fontSize: 20),
        ),
      ),
    );
  }
}
