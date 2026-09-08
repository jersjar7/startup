import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Point at the Inside — the third item for `derivatives-rules`.
///
/// Answered by tapping a piece of the function where it stands, the same way
/// the conics item is, because the question is the same shape: which part of
/// what is written in front of you is the thing being asked about. Here it is
/// the inner function, and finding it is the whole of the chain rule. A
/// student who cannot point at the inside cannot produce its derivative.
class PointAtTheInsideGame extends StatefulWidget {
  const PointAtTheInsideGame({super.key});

  @override
  State<PointAtTheInsideGame> createState() => _PointAtTheInsideGameState();
}

@immutable
class InsideRound {
  const InsideRound({
    required this.ask,
    required this.tokens,
    required this.inert,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String ask;
  final List<String> tokens;

  /// Indices that are glue, not candidates: brackets, an arrow, the word
  /// "or", and the reference copy of the whole function. They are drawn plain
  /// and cannot be tapped, so every tappable piece is a real answer.
  final Set<int> inert;
  final int answer;
  final String why;
  final String source;

  /// The pieces a student can actually choose between, for the auditor.
  List<String> get choices => [
    for (var i = 0; i < tokens.length; i++)
      if (!inert.contains(i)) tokens[i],
  ];

  int get choiceAnswer =>
      answer - inert.where((i) => i < answer).length;
}

const insideRounds = <InsideRound>[
  InsideRound(
    ask: 'Tap the inner function.',
    tokens: [r'\sin', r'\big(', r'3x^2', r'\big)'],
    inert: {1, 3},
    answer: 2,
    why:
        'The inside is 3x squared. Its derivative, 6x, multiplies the whole '
        'thing from outside and never moves into the argument.',
    source: 'math-dr-q1',
  ),
  InsideRound(
    ask: 'Tap the inner function.',
    tokens: [r'\big(', r'3x+5', r'\big)^4'],
    inert: {0},
    answer: 1,
    why:
        'The inside is 3x plus 5, so the extra factor is 3. Missing it is the '
        'most common wrong answer on this whole topic.',
    source: 'math-dr-q1',
  ),
  InsideRound(
    ask: 'Tap the part whose derivative gets multiplied in.',
    // Split as the whole exponential and then its two halves: chopping the
    // LaTeX itself would put a bare brace on the screen.
    tokens: [r'e^{3x}', r'\;\Rightarrow\;', 'e', 'or', '3x'],
    inert: {0, 1, 3},
    answer: 4,
    why:
        'The exponent. The derivative of e to the 3x is 3e to the 3x, and the '
        '3 comes from here.',
    source: 'math-dr-q2',
  ),
  InsideRound(
    ask: 'Tap the piece that needs NO chain rule.',
    tokens: [r'x^2', r'\;\cdot\;', 'e^{3x}'],
    inert: {1},
    answer: 0,
    why:
        'x squared is a plain power of x, straight off the table. The '
        'exponential is the half carrying an argument.',
    source: 'math-dr-q2',
  ),
  InsideRound(
    ask: 'Tap the function that goes FIRST in the quotient rule numerator.',
    tokens: [
      r'\frac{\sin x}{x^2+1}',
      r'\;\Rightarrow\;',
      r'\sin x',
      'or',
      r'x^2+1',
    ],
    inert: {0, 1, 3},
    answer: 4,
    why:
        'The bottom function leads: lo d-hi minus hi d-lo. It multiplies the '
        'derivative of the top.',
    source: 'math-dr-q3',
  ),
  InsideRound(
    ask: 'Tap the inner function.',
    tokens: [r'\ln', r'\big(', r'5x-2', r'\big)'],
    inert: {1, 3},
    answer: 2,
    why:
        'The derivative of ln u is one over u times du. The inside is 5x '
        'minus 2, so the extra factor is 5.',
    source: 'math-dr-q1',
  ),
];

class _PointAtTheInsideGameState extends State<PointAtTheInsideGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'point-at-the-inside',
    chapterId: 'mathematics',
    total: insideRounds.length,
    sourceProblemIdOf: (round) => insideRounds[round].source,
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

  InsideRound get _round => insideRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Point at the Inside',
        closing:
            'Find the inside first and the chain rule writes itself: '
            'derivative of the outside, times derivative of the inside. '
            'Multiplying it out is desk work.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: chainRuleBrief,
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                  if (r.inert.contains(i))
                    _Glue(key: ValueKey('glue-$i'), latex: r.tokens[i])
                  else
                    _Piece(
                      key: ValueKey('piece-$i'),
                      latex: r.tokens[i],
                      picked: _picked == i,
                      truth: answered && i == r.answer,
                      wrong: answered && _picked == i && i != r.answer,
                      onTap: answered
                          ? null
                          : () => setState(() => _picked = i),
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

class _Piece extends StatelessWidget {
  const _Piece({
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
        : AppColors.line;
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
          minWidth: 46,
          maxWidth: 170,
          minHeight: 54,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: border,
            width: border == AppColors.line ? 1 : 2,
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

/// A piece of the line that is not a candidate: a bracket, an arrow, the word
/// "or", or the whole function shown for reference. Drawn without a box so it
/// reads as part of the expression rather than as something to tap.
class _Glue extends StatelessWidget {
  const _Glue({super.key, required this.latex});

  final String latex;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        widthFactor: 1,
        child: MathBlock(latex, fontSize: 18, fit: false),
      ),
    );
  }
}
