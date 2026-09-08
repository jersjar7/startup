import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Run the Loop — the first item for `lhopitals-rule`.
///
/// This rule is not a formula, it is a procedure with a test in the middle of
/// it: substitute, look at what you got, and only then decide whether to
/// differentiate. Every warning in the lesson is about someone skipping that
/// test or leaving the loop too early. So the student drives the procedure one
/// move at a time and the board answers back. Nothing else in the app is
/// answered by a sequence of moves, and nothing else here would show that the
/// checking IS the rule.
class RunTheLoopGame extends StatefulWidget {
  const RunTheLoopGame({super.key});

  @override
  State<RunTheLoopGame> createState() => _RunTheLoopGameState();
}

enum LoopMove {
  substitute('Put the value in'),
  differentiate('Differentiate top and bottom'),
  readOff('That is the answer'),
  notApplicable('The rule does not apply');

  const LoopMove(this.label);
  final String label;
}

@immutable
class LoopStep {
  const LoopStep(this.shown, this.move);

  /// What is on the board right now. Nothing is said about it: reading the
  /// form is the skill, so a caption would be the answer.
  final String shown;

  /// The one right move from here.
  final LoopMove move;
}

@immutable
class LoopRound {
  const LoopRound({
    required this.steps,
    required this.result,
    required this.why,
    required this.source,
  });

  final List<LoopStep> steps;

  /// What the limit turns out to be, shown once the loop is finished.
  final String result;
  final String why;
  final String source;

  String get opening => steps.first.shown;
}

const loopRounds = <LoopRound>[
  LoopRound(
    steps: [
      LoopStep(r'\lim_{x \to 0}\frac{\sin x}{x}', LoopMove.substitute),
      LoopStep(r'\frac{0}{0}', LoopMove.differentiate),
      LoopStep(r'\lim_{x \to 0}\frac{\cos x}{1}', LoopMove.substitute),
      LoopStep(r'\frac{1}{1}', LoopMove.readOff),
    ],
    result: '1',
    why:
        'Substituting first is what tells you the rule is allowed. One round '
        'of differentiating clears it, and the second substitution gives a '
        'number rather than a form.',
    source: 'math-lh-q1',
  ),
  LoopRound(
    steps: [
      LoopStep(r'\lim_{x \to 0}\frac{e^x - x - 1}{x^2}', LoopMove.substitute),
      LoopStep(r'\frac{0}{0}', LoopMove.differentiate),
      LoopStep(r'\lim_{x \to 0}\frac{e^x - 1}{2x}', LoopMove.substitute),
      LoopStep(r'\frac{0}{0}', LoopMove.differentiate),
      LoopStep(r'\lim_{x \to 0}\frac{e^x}{2}', LoopMove.substitute),
      LoopStep(r'\frac{1}{2}', LoopMove.readOff),
    ],
    result: r'\frac{1}{2}',
    why:
        'Still indeterminate after the first round, so the loop goes around '
        'again. Leaving after one pass is the mistake this problem is built '
        'to catch. Two passes is as far as this exam usually goes.',
    source: 'math-lh-q2',
  ),
  LoopRound(
    steps: [
      LoopStep(r'\lim_{x \to 0}\frac{e^x}{x}', LoopMove.substitute),
      LoopStep(r'\frac{1}{0}', LoopMove.notApplicable),
    ],
    result: r'\text{the limit does not exist}',
    why:
        'A number over zero is not indeterminate, it is a blow up, and the '
        'rule has nothing to say about it. Applying it anyway gives 1, which '
        'is wrong. The real answer is that the two sides disagree, so the '
        'limit does not exist.',
    source: 'math-lh-q3',
  ),
  LoopRound(
    steps: [
      LoopStep(r'\lim_{x \to 2}\frac{x^2 - 4}{x - 2}', LoopMove.substitute),
      LoopStep(r'\frac{0}{0}', LoopMove.differentiate),
      LoopStep(r'\lim_{x \to 2}\frac{2x}{1}', LoopMove.substitute),
      LoopStep(r'\frac{4}{1}', LoopMove.readOff),
    ],
    result: '4',
    why:
        'This one also factors, and on paper you might cancel instead. The '
        'rule gets there in one pass either way, which is why it is worth '
        'reaching for when the clock is running.',
    source: 'math-lh-q1',
  ),
  LoopRound(
    steps: [
      LoopStep(r'\lim_{x \to 0}\frac{\cos x}{x + 1}', LoopMove.substitute),
      LoopStep(r'\frac{1}{1}', LoopMove.readOff),
    ],
    result: '1',
    why:
        'Substituting gave a number straight away, so there was never a '
        'question to answer. Differentiating a determinate form changes the '
        'value and hands in the wrong one.',
    source: 'math-lh-q3',
  ),
  LoopRound(
    steps: [
      LoopStep(
        r'\lim_{x \to \infty}\frac{3x^2 + 2x}{x^2 - 5}',
        LoopMove.substitute,
      ),
      LoopStep(r'\frac{\infty}{\infty}', LoopMove.differentiate),
      LoopStep(r'\lim_{x \to \infty}\frac{6x + 2}{2x}', LoopMove.substitute),
      LoopStep(r'\frac{\infty}{\infty}', LoopMove.differentiate),
      LoopStep(r'\lim_{x \to \infty}\frac{6}{2}', LoopMove.substitute),
      LoopStep(r'\frac{6}{2}', LoopMove.readOff),
    ],
    result: '3',
    why:
        'Infinity over infinity is the other form the rule accepts, and it '
        'takes two passes here. Once the x has gone the fraction is just a '
        'number, and that number is the limit.',
    source: 'math-lh-q2',
  ),
];

class _RunTheLoopGameState extends State<RunTheLoopGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'run-the-loop',
    chapterId: 'mathematics',
    total: loopRounds.length,
    sourceProblemIdOf: (round) => loopRounds[round].source,
  )..addListener(_onSession);

  /// How far into the round's moves the student has got.
  int _at = 0;
  LoopMove? _slip;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LoopRound get _round => loopRounds[_session.round];

  void _play(LoopMove move) {
    final r = _round;
    final want = r.steps[_at].move;
    if (move != want) {
      setState(() => _slip = move);
      _session.submit(ok: false, context: context);
      return;
    }
    if (_at == r.steps.length - 1) {
      _session.submit(ok: true, context: context);
      return;
    }
    setState(() => _at++);
  }

  /// Why the move they made was the wrong one, said in terms of this rule
  /// rather than in terms of being wrong.
  String _slipWhy(LoopMove want, LoopMove got) {
    if (want == LoopMove.notApplicable) {
      return 'Putting the value in gave a number over zero. That is not one '
          'of the two forms the rule accepts, so there is nothing here to '
          'differentiate.';
    }
    switch (got) {
      case LoopMove.differentiate when want == LoopMove.substitute:
        return 'Check the form first. Differentiating before you know what '
            'you are looking at is exactly how this rule gets used where it '
            'does not apply.';
      case LoopMove.differentiate when want == LoopMove.readOff:
        return 'There is nothing indeterminate left. Applying the rule to a '
            'form that already has a value changes the value, and the answer '
            'comes out wrong.';
      case LoopMove.substitute when want == LoopMove.differentiate:
        return 'The value is already in, and what came out was indeterminate. '
            'That is the signal to differentiate the top and the bottom.';
      case LoopMove.readOff:
        return 'Not yet. What is on the board is a form, not a value.';
      case LoopMove.notApplicable:
        return 'The rule does apply here: what came out of the substitution '
            'is one of the two indeterminate forms.';
      case _:
        return 'Not the move this step calls for.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Run the Loop',
        closing:
            'Substitute, look, and only then decide. The rule is a loop with '
            'a test in it, and both of the ways it goes wrong are ways of '
            'skipping the test.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final step = r.steps[_at];
    final correct = _session.correct == true;

    return BoardShell(
      session: _session,
      brief: formCheckBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Pick a move',
      onButton: answered
          ? () {
              setState(() {
                _at = 0;
                _slip = null;
              });
              _session.next();
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ONE MOVE AT A TIME',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_at + 1}. What happens next?',
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                if (_at > 0) ...[
                  Opacity(
                    opacity: 0.45,
                    child: MathBlock(r.opening, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                ],
                MathBlock(step.shown, fontSize: 22),
                if (answered && correct) ...[
                  const SizedBox(height: 14),
                  Text(
                    'THE LIMIT IS',
                    style: AppTheme.overline(color: AppColors.forest),
                  ),
                  const SizedBox(height: 6),
                  MathBlock(r.result, fontSize: 20),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final move in LoopMove.values) ...[
            if (move != LoopMove.values.first) const SizedBox(height: 8),
            _MoveButton(
              key: ValueKey('move-${move.name}'),
              move: move,
              locked: answered,
              isTruth: move == step.move,
              slipped: _slip == move,
              onTap: answered ? null : () => _play(move),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: correct,
              title: correct ? 'LOOP FINISHED' : 'NOT THAT MOVE',
              body: correct ? r.why : _slipWhy(step.move, _slip!),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({
    super.key,
    required this.move,
    required this.locked,
    required this.isTruth,
    required this.slipped,
    required this.onTap,
  });

  final LoopMove move;
  final bool locked;
  final bool isTruth;
  final bool slipped;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && slipped) {
      border = AppColors.error;
      fill = AppColors.errorBg;
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
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(move.label, style: AppTheme.heading(size: 15)),
        ),
      ),
    );
  }
}
