import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Order the Moves — the second item for `logarithms`.
///
/// The student puts the steps of a real problem in the order they would
/// actually do them, and never carries any of them out. This is the closest a
/// phone gets to problem solving without faking the desk: procedural knowledge
/// without execution. Every step is lifted from the lesson's own worked
/// solutions, arithmetic stripped out.
class OrderTheMovesGame extends StatefulWidget {
  const OrderTheMovesGame({super.key});

  @override
  State<OrderTheMovesGame> createState() => _OrderTheMovesGameState();
}

@immutable
class MoveSet {
  const MoveSet({
    required this.problem,
    required this.shown,
    required this.accepted,
    required this.why,
    required this.source,
  });

  /// The problem as the exam would state it.
  final String problem;

  /// The steps as presented, deliberately out of order.
  final List<String> shown;

  /// Indices into [shown], in the order they should be done. The FIRST entry
  /// is the one shown as the truth; any listed order is accepted, because
  /// some steps genuinely commute and marking one of them wrong teaches a
  /// distinction the lesson does not draw.
  final List<List<int>> accepted;

  List<int> get answer => accepted.first;

  final String why;
  final String source;
}

const moveSets = <MoveSet>[
  MoveSet(
    problem:
        r'A contaminant decays as $C = C_0 e^{-0.03t}$. How long until it '
        r'reaches 25 percent of where it started?',
    shown: [
      'Take the natural log of both sides',
      'Divide both sides by the starting concentration',
      'Divide by the rate to isolate the time',
      'Bring the exponent down, since ln undoes e',
    ],
    accepted: [
      [1, 0, 3, 2],
    ],
    why:
        'Clear whatever multiplies the exponential first, then take the log. '
        'Taking the log while the initial concentration is still there is the '
        'trap the lesson names.',
    source: 'math-log-q2',
  ),
  MoveSet(
    problem: r'Solve $\log_{10}(10^{x}) = 3.5$.',
    shown: [
      r'Use $\log_{10} 10 = 1$',
      'Pull the exponent down with the power rule',
      'Read off the answer',
    ],
    accepted: [
      [1, 0, 2],
    ],
    why:
        'The power rule brings the x down, then the log of its own base is '
        'one and the whole left side collapses. Nothing is computed.',
    source: 'math-log-q1',
  ),
  MoveSet(
    problem: r'Simplify $\log_2(32) - \log_2(4) + \log_2(8)$.',
    shown: [
      'Ask what power of the base gives that number',
      'Turn the subtraction into a division inside',
      'Simplify the single number inside the log',
      'Turn the addition into a multiplication inside',
    ],
    accepted: [
      [1, 3, 2, 0],
      [3, 1, 2, 0],
    ],
    why:
        'Collapse the terms into one log before evaluating anything. '
        'Evaluating each log first is where people multiply the values '
        'together by mistake.',
    source: 'math-log-q3',
  ),
  MoveSet(
    problem: r'Solve for the unknown in the exponent: $2^{x} = 40$.',
    shown: [
      'Divide by the log of the base',
      'Take the log of both sides',
      'Bring the exponent down in front',
    ],
    accepted: [
      [1, 2, 0],
    ],
    why:
        'Log both sides, power rule to bring x down, then it is a division. '
        'This is the shape of nearly every FE log problem.',
    source: 'math-log-q1',
  ),
];

class _OrderTheMovesGameState extends State<OrderTheMovesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'order-the-moves',
    chapterId: 'mathematics',
    total: moveSets.length,
    sourceProblemIdOf: (round) => moveSets[round].source,
  )..addListener(_onSession);

  final List<int> _order = [];

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  MoveSet get _set => moveSets[_session.round];

  void _tap(int i) {
    setState(() {
      if (_order.contains(i)) {
        _order.removeRange(_order.indexOf(i), _order.length);
      } else {
        _order.add(i);
      }
    });
  }

  static bool _same(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Order the Moves',
        closing:
            'Knowing the order is most of the work on a log problem: clear '
            'the coefficient, log both sides, bring the exponent down, then '
            'divide. Carrying it out is desk work.',
      );
    }

    final answered = _session.answered;
    final complete = _order.length == _set.shown.length;

    return BoardShell(
      session: _session,
      brief: undoExponentBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock the order',
      onButton: answered
          ? () {
              setState(_order.clear);
              _session.next();
            }
          : (!complete
                ? null
                : () => _session.submit(
                    ok: _set.accepted.any((a) => _same(_order, a)),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT WOULD YOU DO FIRST',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: MathText(
              _set.problem,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap the steps in the order you would actually do them. Tap one '
            'again to clear back to it.',
            style: TextStyle(fontSize: 13, color: AppColors.ink2),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _set.shown.length; i++) ...[
            _MoveCard(
              text: _set.shown[i],
              rank: _order.contains(i) ? _order.indexOf(i) + 1 : null,
              truth: answered ? _set.answer.indexOf(i) + 1 : null,
              wrong: answered && !_session.correct!,
              onTap: answered ? null : () => _tap(i),
            ),
            const SizedBox(height: 10),
          ],
          if (answered) ...[
            const SizedBox(height: 4),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THAT ORDER',
              body: _set.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _MoveCard extends StatelessWidget {
  const _MoveCard({
    required this.text,
    required this.rank,
    required this.truth,
    required this.wrong,
    required this.onTap,
  });

  final String text;
  final int? rank;
  final int? truth;
  final bool wrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final show = truth ?? rank;
    final Color border;
    if (truth != null) {
      border = wrong ? AppColors.error : AppColors.forest;
    } else if (rank != null) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: show == null
                      ? Colors.transparent
                      : (truth != null
                            ? (wrong ? AppColors.error : AppColors.forest)
                            : AppColors.ember),
                  border: Border.all(
                    color: show == null ? AppColors.line : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: show == null
                    ? null
                    : Text(
                        '$show',
                        style: AppTheme.mono(
                          size: 14,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: MathText(
                  text,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
