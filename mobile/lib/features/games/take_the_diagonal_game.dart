import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Take the Diagonal — the first item for `dot-product-angle`.
///
/// The lesson names one structural mistake: pairing a component of A with the
/// wrong component of B, which is the cross product's pattern wearing the dot
/// product's name. Written as a formula that is easy to nod at. Laid out as
/// every possible pairing in a grid it becomes something you can see, because
/// the dot product is the DIAGONAL of that grid and nothing else. So the
/// answer is a set of cells, the products are already worked out so there is
/// no arithmetic in it, and picking an off-diagonal cell is the mistake
/// itself rather than a near miss.
class TakeTheDiagonalGame extends StatefulWidget {
  const TakeTheDiagonalGame({super.key});

  @override
  State<TakeTheDiagonalGame> createState() => _TakeTheDiagonalGameState();
}

@immutable
class DiagonalRound {
  const DiagonalRound({
    required this.a,
    required this.b,
    required this.axes,
    required this.why,
    required this.source,
  });

  /// Components of each vector, in axis order.
  final List<int> a;
  final List<int> b;

  /// The axis names, so a two dimensional round does not pretend to be three.
  final List<String> axes;
  final String why;
  final String source;

  int get n => axes.length;

  /// Cells are numbered across then down: row is A's axis, column is B's.
  Set<int> get answer => {for (var i = 0; i < n; i++) i * n + i};

  String cell(int row, int col) =>
      '(${a[row]})(${b[col]})';
}

const diagonalRounds = <DiagonalRound>[
  DiagonalRound(
    a: [3, 4],
    b: [-2, 5],
    axes: ['i', 'j'],
    why:
        'Across with across, up with up. The minus on B stays: three times '
        'minus two is minus six, and minus six plus twenty is fourteen. The '
        'off-diagonal cells are the cross product asking to be let in.',
    source: 'math-dpa-q1',
  ),
  DiagonalRound(
    a: [1, 0],
    b: [3, 5],
    axes: ['i', 'j'],
    why:
        'A zero component contributes nothing, but it still has to be paired '
        'with its own partner rather than skipped over. Everything here comes '
        'from the one cell that is not zero, and the answer is three.',
    source: 'math-dpa-q2',
  ),
  DiagonalRound(
    a: [2, -3],
    b: [-4, -1],
    axes: ['i', 'j'],
    why:
        'Two negatives multiply to a positive, so the second cell adds three '
        'rather than taking it away. Sign slips are the most common way this '
        'formula goes wrong.',
    source: 'math-dpa-q1',
  ),
  DiagonalRound(
    a: [3, 6, -3],
    b: [2, 3, 1],
    axes: ['i', 'j', 'k'],
    why:
        'Three dimensions, three cells, still the diagonal. This is the joint '
        'and the member from the worked problem with the hundreds taken off. '
        'Six plus eighteen minus three is twenty one, and the k pairing is '
        'the only one that takes anything away.',
    source: 'math-dpa-q3',
  ),
  DiagonalRound(
    a: [4, 2, 0],
    b: [1, -2, 5],
    axes: ['i', 'j', 'k'],
    why:
        'Four minus four is nothing, and the k pairing contributes nothing '
        'either, so the whole dot product is zero. That means these two are '
        'perpendicular, which is worth more than the number.',
    source: 'math-dpa-q1',
  ),
  DiagonalRound(
    a: [0, 5, 2],
    b: [3, 0, -1],
    axes: ['i', 'j', 'k'],
    why:
        'Two of the three cells are zero and the answer comes from one '
        'pairing. Which is fine. What is not fine is pairing the five with '
        'the three because they are the only interesting numbers on screen.',
    source: 'math-dpa-q3',
  ),
];

class _TakeTheDiagonalGameState extends State<TakeTheDiagonalGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'take-the-diagonal',
    chapterId: 'mathematics',
    total: diagonalRounds.length,
    sourceProblemIdOf: (round) => diagonalRounds[round].source,
  )..addListener(_onSession);

  final Set<int> _picked = {};

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DiagonalRound get _round => diagonalRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Take the Diagonal',
        closing:
            'Matching components only, signs kept, and the result is a '
            'number. If your answer has an i or a j in it you have done the '
            'cross product instead.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: dotProductBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_picked.clear);
              _session.next();
            }
          : (_picked.isEmpty
                ? null
                : () => _session.submit(
                    ok: _picked.length == r.answer.length &&
                        _picked.containsAll(r.answer),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHICH PRODUCTS GET ADDED',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Every possible pairing is here. Tap the ones that belong in the '
            'dot product.',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          _Given(r: r),
          const SizedBox(height: 14),
          _Table(
            round: r,
            picked: _picked,
            answered: answered,
            onTap: answered
                ? null
                : (cell) => setState(() {
                    _picked.contains(cell)
                        ? _picked.remove(cell)
                        : _picked.add(cell);
                  }),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THE DIAGONAL' : 'NOT THOSE CELLS',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Given extends StatelessWidget {
  const _Given({required this.r});

  final DiagonalRound r;

  @override
  Widget build(BuildContext context) {
    String write(String name, List<int> v) {
      final parts = <String>[];
      for (var i = 0; i < v.length; i++) {
        final sign = v[i] < 0 ? '-' : (i == 0 ? '' : '+');
        parts.add('$sign${v[i].abs()}\\hat{${r.axes[i]}}');
      }
      return '\\vec{$name} = ${parts.join(' ')}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          MathBlock(write('A', r.a), fontSize: 16),
          const SizedBox(height: 8),
          MathBlock(write('B', r.b), fontSize: 16),
        ],
      ),
    );
  }
}

/// Every pairing laid out as a table: A's components down the side, B's along
/// the top. The dot product is the diagonal, and seeing that is the item.
class _Table extends StatelessWidget {
  const _Table({
    required this.round,
    required this.picked,
    required this.answered,
    required this.onTap,
  });

  final DiagonalRound round;
  final Set<int> picked;
  final bool answered;
  final void Function(int cell)? onTap;

  @override
  Widget build(BuildContext context) {
    final n = round.n;
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 30),
            for (var col = 0; col < n; col++)
              Expanded(
                child: Text(
                  'B${round.axes[col]}',
                  textAlign: TextAlign.center,
                  style: AppTheme.overline(color: AppColors.ink2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var row = 0; row < n; row++) ...[
          if (row > 0) const SizedBox(height: 6),
          Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  'A${round.axes[row]}',
                  style: AppTheme.overline(color: AppColors.ink2),
                ),
              ),
              for (var col = 0; col < n; col++) ...[
                if (col > 0) const SizedBox(width: 6),
                Expanded(
                  child: _Cell(
                    key: ValueKey('cell-${row * n + col}'),
                    text: round.cell(row, col),
                    selected: picked.contains(row * n + col),
                    locked: answered,
                    isTruth: row == col,
                    onTap: onTap == null ? null : () => onTap!(row * n + col),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.text,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String text;
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
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            text,
            style: AppTheme.mono(size: 13, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
