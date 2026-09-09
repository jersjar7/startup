import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which Happens First — the second item for `spreadsheet-computations`.
///
/// The lesson's second warning is that a spreadsheet does not read left to
/// right, and it gives the example that trips people up: A1 plus A2 over A3
/// divides before it adds. Asking for the answer to that would only test
/// arithmetic. Asking which PART goes first tests the thing the warning is
/// about, so the formula arrives broken into its pieces and the student puts
/// a finger on the piece the spreadsheet reaches for before anything else.
class HappensFirstGame extends StatefulWidget {
  const HappensFirstGame({super.key});

  @override
  State<HappensFirstGame> createState() => _HappensFirstGameState();
}

@immutable
class PrecedenceRound {
  const PrecedenceRound({
    required this.pieces,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// The formula broken into the smallest things worth pointing at. Operators
  /// stand on their own so that a piece is always a sub-expression.
  final List<String> pieces;

  /// Which piece the spreadsheet evaluates first.
  final int answer;
  final String why;
  final String source;

  String get formula => pieces.join(' ');
}

const precedenceRounds = <PrecedenceRound>[
  PrecedenceRound(
    pieces: ['=', 'A1', '+', 'A2*A3'],
    answer: 3,
    why:
        'Multiplication outranks addition, so three times four happens before '
        'anything is added to it. Reading left to right would give twenty; the '
        'sheet gives fourteen.',
    source: 'math-spr-q1',
  ),
  PrecedenceRound(
    pieces: ['=', 'A1', '+', 'A2/A3'],
    answer: 3,
    why:
        'Division outranks addition just as multiplication does. This is the '
        'exact formula the lesson warns about: it does not add A1 and A2 and '
        'then divide, it divides first.',
    source: 'math-spr-q1',
  ),
  PrecedenceRound(
    pieces: ['=', '(A1+A2)', '*', 'A3'],
    answer: 1,
    why:
        'Brackets beat everything. They are how you force the addition to '
        'happen first, and without them the same three cells give a different '
        'number.',
    source: 'math-spr-q1',
  ),
  PrecedenceRound(
    pieces: ['=', 'A1', '*', 'A2^A3'],
    answer: 3,
    why:
        'The power goes before the multiply. Order of operations runs '
        'brackets, then powers, then times and divide, then plus and minus.',
    source: 'math-spr-q1',
  ),
  PrecedenceRound(
    pieces: ['=', 'A1/A2', '*', 'A3'],
    answer: 1,
    why:
        'Divide and multiply are the same rank, so nothing outranks anything '
        'and it goes left to right. The division is simply written first.',
    source: 'math-spr-q1',
  ),
  PrecedenceRound(
    pieces: ['=', 'A1-A2', '+', 'A3'],
    answer: 1,
    why:
        'Plus and minus are also the same rank, so again it is left to right. '
        'Doing the addition first here would change the answer, which is why '
        'the rank AND the reading order both matter.',
    source: 'math-spr-q1',
  ),
];

class _HappensFirstGameState extends State<HappensFirstGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'happens-first',
    chapterId: 'mathematics',
    total: precedenceRounds.length,
    sourceProblemIdOf: (round) => precedenceRounds[round].source,
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

  PrecedenceRound get _round => precedenceRounds[_session.round];

  /// The equals sign and the bare operators are punctuation, not candidates.
  static bool _isGlue(String piece) =>
      piece == '=' || const ['+', '-', '*', '/', '^'].contains(piece);

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Happens First',
        closing:
            'Brackets, then powers, then times and divide, then plus and '
            'minus, and same rank goes left to right. A spreadsheet never '
            'reads a formula the way you read a sentence.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: precedenceBrief,
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
            'NOT LEFT TO RIGHT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the part of this formula the spreadsheet works out first.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'A1 = 2, A2 = 3, A3 = 4',
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 8,
              children: [
                for (var i = 0; i < r.pieces.length; i++)
                  if (_isGlue(r.pieces[i]))
                    _Glue(key: ValueKey('glue-$i'), text: r.pieces[i])
                  else
                    _Piece(
                      key: ValueKey('piece-$i'),
                      text: r.pieces[i],
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
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT ONE FIRST' : 'NOT FIRST',
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
    required this.text,
    required this.picked,
    required this.truth,
    required this.wrong,
    required this.onTap,
  });

  final String text;
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
        : AppColors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 54, minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          child: Text(
            text,
            style: AppTheme.mono(size: 16, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}

/// The equals sign and the operators between the pieces. They are part of the
/// formula, not parts of it that get evaluated, so there is nothing to tap.
class _Glue extends StatelessWidget {
  const _Glue({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        widthFactor: 1,
        child: Text(
          text,
          style: AppTheme.mono(size: 16, color: AppColors.ink2),
        ),
      ),
    );
  }
}
