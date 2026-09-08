import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Read the Equation — the second item for `circles-conics`.
///
/// The answer is a PART OF THE EQUATION, tapped where it stands. Conics on the
/// FE are mostly a reading exercise: which piece tells you the radius, which
/// one fixes the centre, which one decides which way a parabola opens. Asking
/// in words and answering in words lets a student agree with a sentence they
/// could not act on. Here they have to point at it.
class ReadTheEquationGame extends StatefulWidget {
  const ReadTheEquationGame({super.key});

  @override
  State<ReadTheEquationGame> createState() => _ReadTheEquationGameState();
}

@immutable
class ReadRound {
  const ReadRound({
    required this.ask,
    required this.tokens,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String ask;

  /// The equation, broken into the pieces a student can point at.
  final List<String> tokens;

  /// Index of the piece being asked for.
  final int answer;
  final String why;
  final String source;
}

const readRounds = <ReadRound>[
  ReadRound(
    ask: 'Tap the part that tells you the radius.',
    tokens: [r'(x-5)^2', '+', r'(y+3)^2', '=', '64'],
    answer: 4,
    why:
        'It is the radius SQUARED, so the radius is 8. Handing back 64 is one '
        'of the two traps the lesson names.',
    source: 'math-cc-q1',
  ),
  ReadRound(
    ask: 'Tap the part that fixes the y-coordinate of the centre.',
    tokens: [r'(x-5)^2', '+', r'(y+3)^2', '=', '64'],
    answer: 2,
    why:
        'And it fixes it at MINUS three, because y + 3 is y − (−3). The sign '
        'inside is always the opposite of the coordinate.',
    source: 'math-cc-q1',
  ),
  ReadRound(
    ask: 'Tap the part that decides which way this parabola opens.',
    tokens: ['y', '=', '-0.004x^2', '+', '2.4x', '-', '200'],
    answer: 2,
    why:
        'The sign of the squared term. It is negative, so the curve opens '
        'downward and its vertex is a maximum, which is what makes a crest '
        'curve a crest.',
    source: 'math-cc-q3',
  ),
  ReadRound(
    ask: 'Tap the part you complete the square with for x.',
    tokens: ['x^2', '-10x', '+', 'y^2', '+6y', '+', '18', '=', '0'],
    answer: 1,
    why:
        'Halve the ten and square it: 25 goes in, and the same 25 has to go '
        'on the other side of the equals.',
    source: 'math-cc-q2',
  ),
  ReadRound(
    ask: 'Tap the part that makes the major axis horizontal.',
    tokens: [r'\frac{x^2}{25}', '+', r'\frac{y^2}{9}', '=', '1'],
    answer: 0,
    why:
        'The larger denominator sits under x, so the ellipse is wider than it '
        'is tall. Larger denominator, major axis.',
    source: 'math-cc-q1',
  ),
  ReadRound(
    ask: 'Tap the part that shifts this parabola sideways.',
    tokens: ['y', '=', 'a', '(x-h)^2', '+', 'k'],
    answer: 3,
    why:
        'h moves it left or right, k moves it up or down, and a sets how '
        'sharp it is and which way it opens.',
    source: 'math-cc-q3',
  ),
  ReadRound(
    ask: 'Tap the part that would be zero if the centre sat on the y-axis.',
    tokens: [r'(x-h)^2', '+', r'(y-k)^2', '=', 'r^2'],
    answer: 0,
    why:
        'On the y-axis the across-coordinate is zero, so h is zero and that '
        'bracket becomes plain x squared.',
    source: 'math-cc-q1',
  ),
  ReadRound(
    ask: 'Tap the part that is NOT the maximum elevation.',
    tokens: ['y', '=', '-0.004x^2', '+', '2.4x', '-', '200'],
    answer: 6,
    why:
        'The constant is where the curve starts, not where it peaks. Reading '
        'it as the maximum is the trap; the peak comes from the vertex.',
    source: 'math-cc-q3',
  ),
];

class _ReadTheEquationGameState extends State<ReadTheEquationGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'read-the-equation',
    chapterId: 'mathematics',
    total: readRounds.length,
    sourceProblemIdOf: (round) => readRounds[round].source,
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

  ReadRound get _round => readRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Read the Equation',
        closing:
            'Most conic questions are read, not solved: which piece is '
            'the radius, which fixes the centre, which decides the direction. '
            'Putting numbers through them is desk work.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: readingConicsBrief,
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
            'POINT AT THE PART',
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
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 8,
              children: [
                for (var i = 0; i < r.tokens.length; i++)
                  _Token(
                    key: ValueKey('token-$i'),
                    latex: r.tokens[i],
                    picked: _picked == i,
                    truth: answered && i == r.answer,
                    wrong: answered && _picked == i && i != r.answer,
                    onTap: answered ? null : () => setState(() => _picked = i),
                  ),
              ],
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 18),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THAT PART',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Token extends StatelessWidget {
  const _Token({
    super.key,
    required this.latex,
    required this.picked,
    required this.truth,
    required this.wrong,
    required this.onTap,
  });

  final String latex;
  final bool picked;
  final bool truth;
  final bool wrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = truth
        ? AppColors.forest
        : wrong
        ? AppColors.error
        : picked
        ? AppColors.ember
        : Colors.transparent;
    final Color fill = truth
        ? AppColors.forestBg
        : wrong
        ? AppColors.errorBg
        : picked
        ? AppColors.emberBg
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 44,
          maxWidth: 170,
          minHeight: 52,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: border == Colors.transparent ? AppColors.line : border,
            width: border == Colors.transparent ? 1 : 2,
          ),
        ),
        child: Center(
          widthFactor: 1,
          child: MathBlock(latex, fontSize: 18, fit: false),
        ),
      ),
    );
  }
}
