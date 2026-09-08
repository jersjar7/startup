import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What Was Asked — the third item for `applications-derivatives`.
///
/// Both worked problems in this lesson carry the same warning, and it is not
/// about calculus: the student finds the right critical point and then hands
/// in the wrong quantity. So the calculus here is already done and correct.
/// Every number on the screen is true. The only question is which of them the
/// sentence at the top was asking for, which is a reading skill the exam
/// charges full price for.
class WhatWasAskedGame extends StatefulWidget {
  const WhatWasAskedGame({super.key});

  @override
  State<WhatWasAskedGame> createState() => _WhatWasAskedGameState();
}

@immutable
class AskedRound {
  const AskedRound({
    required this.question,
    required this.working,
    required this.quantities,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// The sentence the exam actually wrote.
  final String question;

  /// One line saying what was done, so nothing on screen is a mystery.
  final String working;

  /// Everything the working produced, all of it true.
  final List<String> quantities;
  final int answer;
  final String why;
  final String source;
}

const askedRounds = <AskedRound>[
  AskedRound(
    question: 'What wall height minimizes the cost per meter?',
    working: r"C(h) = 3h^2 - 36h + 150,\quad C'(h) = 6h - 36 = 0",
    quantities: [
      r'h = 6\ \text{m}',
      r'C(6) = 42\ \text{dollars/m}',
      r'C(0) = 150\ \text{dollars/m}',
      r"C''(h) = 6",
    ],
    answer: 0,
    why:
        'A height is asked for, so a height is handed in. The cost at that '
        'height is the next question, not this one.',
    source: 'math-ad-q2',
  ),
  AskedRound(
    question: 'What is the minimum cost per meter?',
    working: r"C(h) = 3h^2 - 36h + 150,\quad C'(h) = 6h - 36 = 0",
    quantities: [
      r'h = 6\ \text{m}',
      r'C(6) = 42\ \text{dollars/m}',
      r'C(0) = 150\ \text{dollars/m}',
      r"C''(h) = 6",
    ],
    answer: 1,
    why:
        'Same working, different question. Finding h = 6 is only half of it: '
        'the cost comes from putting 6 back into C. Handing in the 150, the '
        'constant sitting in the formula, is the trap this problem is built '
        'around.',
    source: 'math-ad-q2',
  ),
  AskedRound(
    question: 'At what value of x does f reach its maximum?',
    working: r"f(x) = -2x^2 + 16x - 5,\quad f'(x) = -4x + 16 = 0",
    quantities: [
      r"f'(x) = -4x + 16",
      r'x = 4',
      r'f(4) = 27',
      r"f''(x) = -4",
    ],
    answer: 1,
    why:
        'The location, not the height. The 27 is how high the hilltop is; the '
        '4 is where it stands.',
    source: 'math-ad-q1',
  ),
  AskedRound(
    question: 'What is the maximum value of f?',
    working: r"f(x) = -2x^2 + 16x - 5,\quad f'(x) = -4x + 16 = 0",
    quantities: [
      r"f'(x) = -4x + 16",
      r'x = 4',
      r'f(4) = 27',
      r"f''(x) = -4",
    ],
    answer: 2,
    why:
        'Now it is the height. Read the sentence twice: "at what x" and "what '
        'is the value" point at two different lines of the same working.',
    source: 'math-ad-q1',
  ),
  AskedRound(
    question: 'Where does the beam change which way it bends?',
    working: r"y(x) = x^3 - 12x^2 + 36x,\quad y''(x) = 6x - 24",
    quantities: [
      r'x = 2\ \text{m}',
      r'x = 4\ \text{m}',
      r'x = 6\ \text{m}',
      r'y(2) = 32\ \text{mm}',
    ],
    answer: 1,
    why:
        'Changing bend is the second derivative, so x = 4. The 2 and the 6 '
        'are where the slope is zero, which is a different question and the '
        'most common wrong answer on this problem.',
    source: 'math-ad-q3',
  ),
  AskedRound(
    question: 'Where does the deflection curve reach a local maximum?',
    working: r"y'(x) = 3x^2 - 24x + 36 = 0,\quad y''(x) = 6x - 24",
    quantities: [
      r'x = 2\ \text{m}',
      r'x = 4\ \text{m}',
      r'x = 6\ \text{m}',
      r'y(6) = 0\ \text{mm}',
    ],
    answer: 0,
    why:
        'Both 2 and 6 make the slope zero. Put them into the second '
        'derivative: at x = 2 it is -12, negative, a frown, so that is the '
        'maximum. x = 4 is where the bend flips, which is neither.',
    source: 'math-ad-q3',
  ),
];

class _WhatWasAskedGameState extends State<WhatWasAskedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-was-asked',
    chapterId: 'mathematics',
    total: askedRounds.length,
    sourceProblemIdOf: (round) => askedRounds[round].source,
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

  AskedRound get _round => askedRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Was Asked',
        closing:
            'The calculus is the easy half. Where it happens and how much it '
            'is are two different answers out of the same working, and the '
            'exam is happy to offer you both.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: askedForBrief,
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
            'ALL OF IT IS TRUE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.question,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MathBlock(r.working, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'The working is already done and correct.',
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.quantities.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _QuantityRow(
              key: ValueKey('quantity-$i'),
              latex: r.quantities[i],
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'TRUE, BUT NOT ASKED',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    super.key,
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: MathBlock(latex, fontSize: 16, align: Alignment.centerLeft),
        ),
      ),
    );
  }
}
