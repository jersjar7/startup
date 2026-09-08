import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'vector_figures.dart';

/// Open or Closed — the second item for `dot-product-angle`.
///
/// The angle formula says the dot product is the two lengths times the cosine
/// of the angle between them, and both lengths are positive, so the SIGN of a
/// dot product is nothing but the sign of that cosine. Under ninety degrees it
/// is positive, over ninety it is negative, and exactly ninety makes it zero,
/// which is the perpendicularity test the lesson calls the fastest check there
/// is. All of that is readable off a drawing without a single multiplication,
/// and reading it off a drawing is what makes it stick.
class OpenOrClosedGame extends StatefulWidget {
  const OpenOrClosedGame({super.key});

  @override
  State<OpenOrClosedGame> createState() => _OpenOrClosedGameState();
}

enum DotSign { positive, zero, negative }

@immutable
class SignRound {
  const SignRound({
    required this.a,
    required this.b,
    required this.why,
    required this.source,
  });

  final Vec a;
  final Vec b;
  final String why;
  final String source;

  double get dot => a.x * b.x + a.y * b.y;

  /// Worked out from the arrows, never declared beside them.
  DotSign get answer {
    if (dot.abs() < 1e-9) return DotSign.zero;
    return dot > 0 ? DotSign.positive : DotSign.negative;
  }
}

const signRounds = <SignRound>[
  SignRound(
    a: Vec(5, 0),
    b: Vec(4, 4),
    why:
        'They lean the same way, so the angle between them is under ninety '
        'and the cosine is positive. You never had to multiply anything to '
        'know the sign.',
    source: 'math-dpa-q2',
  ),
  SignRound(
    a: Vec(4, 2),
    b: Vec(-2, 4),
    why:
        'A right angle, so the dot product is exactly zero. This is the '
        'perpendicularity test, and it is the fastest check for it there is: '
        'no lengths, no inverse cosine, just zero or not.',
    source: 'math-dpa-q1',
  ),
  SignRound(
    a: Vec(5, 1),
    b: Vec(-4, 2),
    why:
        'More than ninety degrees apart, so the cosine is negative and so is '
        'the dot product. The arrows disagree about which way to go, and the '
        'sign says so.',
    source: 'math-dpa-q1',
  ),
  SignRound(
    a: Vec(-3, -4),
    b: Vec(-5, 0),
    why:
        'Both point into the left half, so they still lean the same way as '
        'each other and the answer is positive. Where the arrows sit on the '
        'page has nothing to do with it; the angle BETWEEN them is the whole '
        'story.',
    source: 'math-dpa-q2',
  ),
  SignRound(
    a: Vec(0, 6),
    b: Vec(3, 0),
    why:
        'Straight up against straight across is the easiest right angle to '
        'see, and zero is the answer. Notice the two arrows are nowhere near '
        'the same length, and it changed nothing.',
    source: 'math-dpa-q1',
  ),
  SignRound(
    a: Vec(2, 5),
    b: Vec(1, -3),
    why:
        'Just past ninety degrees, and past is enough. This is the one worth '
        'being careful with: it looks close, and the components decide it '
        'rather than the eye. Two minus fifteen is negative.',
    source: 'math-dpa-q1',
  ),
];

class _OpenOrClosedGameState extends State<OpenOrClosedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'open-or-closed',
    chapterId: 'mathematics',
    total: signRounds.length,
    sourceProblemIdOf: (round) => signRounds[round].source,
  )..addListener(_onSession);

  DotSign? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SignRound get _round => signRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Open or Closed',
        closing:
            'The sign of a dot product is the sign of the cosine, because the '
            'two lengths are always positive. Under ninety, positive. Over '
            'ninety, negative. Exactly ninety, zero, and that is the '
            'perpendicularity test.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: dotAngleBrief,
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
            'NO MULTIPLYING NEEDED',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Is the dot product of these two positive, zero, or negative?',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 290,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: VectorPainter(
                    span: 7,
                    between: (r.a, r.b),
                    arrows: [
                      Arrow(r.a, color: AppColors.ember, label: 'A'),
                      Arrow(r.b, color: AppColors.forest, label: 'B'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final option in DotSign.values) ...[
                if (option != DotSign.values.first) const SizedBox(width: 8),
                Expanded(
                  child: _SignButton(
                    key: ValueKey('sign-${option.name}'),
                    option: option,
                    selected: _picked == option,
                    locked: answered,
                    isTruth: r.answer == option,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = option),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? (r.answer == DotSign.zero
                        ? 'PERPENDICULAR'
                        : 'RIGHT SIGN')
                  : 'NOT THAT SIGN',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _SignButton extends StatelessWidget {
  const _SignButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final DotSign option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _labels = {
    DotSign.positive: ('Positive', 'under 90'),
    DotSign.zero: ('Zero', 'exactly 90'),
    DotSign.negative: ('Negative', 'over 90'),
  };

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

    final (label, detail) = _labels[option]!;
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 66,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppTheme.heading(size: 15)),
              const SizedBox(height: 2),
              Text(
                detail,
                style: AppTheme.mono(size: 10, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
