import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'sheet_figures.dart';

/// Copy It Down — the first item for `spreadsheet-computations`.
///
/// The lesson says outright that this is the single most tested spreadsheet
/// idea, and that forgetting a dollar sign is the number one error people
/// make. Both of those are about WHERE a reference ends up pointing after a
/// copy, so the answer here is a place on a real grid rather than a sentence
/// about relative and absolute. The student reads the formula, works out where
/// each half lands, and puts a finger on the cells the copy will read. A lock
/// that does nothing looks exactly like a lock that does, until you move.
class CopyItDownGame extends StatefulWidget {
  const CopyItDownGame({super.key});

  @override
  State<CopyItDownGame> createState() => _CopyItDownGameState();
}

@immutable
class CopyRound {
  const CopyRound({
    required this.formula,
    required this.from,
    required this.to,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// The formula as it stands in the cell it was written in.
  final String formula;

  /// Where it lives, and where it is being copied to.
  final String from;
  final String to;

  /// The cells the COPY reads.
  final Set<String> answer;
  final String why;
  final String source;
}

/// One sheet stands behind every round, so the grid stops being a new puzzle
/// each time and the only thing changing is the formula.
const sheetValues = <String, String>{
  'A1': '5',
  'A2': '8',
  'A3': '6',
  'A4': '9',
  'B1': '10',
  'B2': '3',
  'B3': '7',
  'B4': '2',
};

const copyRounds = <CopyRound>[
  CopyRound(
    formula: r'=A1*$B$1',
    from: 'C1',
    to: 'C2',
    answer: {'A2', 'B1'},
    why:
        'Down one row. A1 is relative so it walks down to A2, and the dollar '
        'signs hold B1 exactly where it is. This is the unit price pattern: a '
        'column of quantities times one fixed rate.',
    source: 'math-spr-q2',
  ),
  CopyRound(
    formula: r'=A1*$B$1',
    from: 'C1',
    to: 'C3',
    answer: {'A3', 'B1'},
    why:
        'Down two rows this time, so the relative half walks two rows with it. '
        'The locked half does not care how far the copy went.',
    source: 'math-spr-q2',
  ),
  CopyRound(
    formula: '=A1*B1',
    from: 'C1',
    to: 'C2',
    answer: {'A2', 'B2'},
    why:
        'No dollar signs anywhere, so both halves move. This is the row that '
        'goes wrong when somebody forgets to lock the rate: every line below '
        'the first quietly multiplies by the wrong cell.',
    source: 'math-spr-q2',
  ),
  CopyRound(
    formula: r'=$A1*B$1',
    from: 'C2',
    to: 'D3',
    answer: {'A2', 'C1'},
    why:
        'One dollar sign each, and they lock different things. The A keeps its '
        'column and moves down a row; the B keeps its row and moves across a '
        'column. A dollar sign locks only what comes straight after it.',
    source: 'math-spr-q2',
  ),
  CopyRound(
    formula: r'=$A$1*B2',
    from: 'C2',
    to: 'D2',
    answer: {'A1', 'C2'},
    why:
        'Across one column, not down. Fully locked stays at A1, and B2 slides '
        'sideways to C2. Copying across moves the letters; copying down moves '
        'the numbers.',
    source: 'math-spr-q2',
  ),
  CopyRound(
    formula: r'=A$1+A2',
    from: 'C2',
    to: 'C3',
    answer: {'A1', 'A3'},
    why:
        'Two references into the same column, and only one of them moves. The '
        'row lock on the first one is doing all the work, which is what a '
        'running total against a fixed header looks like.',
    source: 'math-spr-q2',
  ),
];

class _CopyItDownGameState extends State<CopyItDownGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'copy-it-down',
    chapterId: 'mathematics',
    total: copyRounds.length,
    sourceProblemIdOf: (round) => copyRounds[round].source,
  )..addListener(_onSession);

  final Set<String> _picked = {};

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CopyRound get _round => copyRounds[_session.round];

  CellState _stateOf(CopyRound r, String cell) {
    final answered = _session.answered;
    if (answered && r.answer.contains(cell)) return CellState.right;
    if (answered && _picked.contains(cell)) return CellState.wrong;
    if (_picked.contains(cell)) return CellState.picked;
    if (cell == r.from) return CellState.source;
    if (cell == r.to) return CellState.target;
    return CellState.plain;
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Copy It Down',
        closing:
            'A plain reference moves with the copy and a dollar sign pins '
            'whatever comes straight after it. Nothing tells you which you '
            'need except knowing what has to stay put, and the rate is almost '
            'always the thing that stays put.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: referencesBrief,
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
            'WHERE DOES IT POINT AFTER THE COPY',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            'This formula is copied from ${r.from} to ${r.to}. Tap the cells '
            'the copy reads.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          FormulaBar(cell: r.from, formula: r.formula),
          const SizedBox(height: 12),
          SheetGrid(
            columns: const ['A', 'B', 'C', 'D'],
            rows: 4,
            values: sheetValues,
            stateOf: (cell) => _stateOf(r, cell),
            onTap: answered
                ? null
                : (cell) => setState(() {
                    _picked.contains(cell)
                        ? _picked.remove(cell)
                        : _picked.add(cell);
                  }),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Key(color: AppColors.sunbeam, label: 'holds the formula'),
              const SizedBox(width: 14),
              _Key(color: AppColors.ink3, label: 'copied into'),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'BOTH LANDED' : 'NOT THOSE CELLS',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTheme.mono(size: 10.5, color: AppColors.ink3)),
      ],
    );
  }
}
