import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'sheet_figures.dart';

/// What Does the Cell Show — the third item for `spreadsheet-computations`.
///
/// A cell holds a formula and displays a result, and the whole function
/// section of this lesson is about telling those two apart. The sheet is on
/// screen so nothing has to be imagined, and every wrong answer on offer is a
/// real misreading rather than a near miss: the other branch of an IF, the
/// count that included the text cell, the sum where an average was asked for.
/// The numbers are small on purpose. This is a reading question wearing an
/// arithmetic coat.
class WhatShowsGame extends StatefulWidget {
  const WhatShowsGame({super.key});

  @override
  State<WhatShowsGame> createState() => _WhatShowsGameState();
}

@immutable
class ShowsRound {
  const ShowsRound({
    required this.formula,
    required this.cell,
    required this.values,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String formula;

  /// Where the formula lives, so the sheet can point at it.
  final String cell;
  final Map<String, String> values;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _ifSheet = <String, String>{'A1': '12', 'A2': '7'};
const _sumSheet = <String, String>{'B1': '30', 'B2': '40', 'B3': '20'};
const _countSheet = <String, String>{
  'A1': '5',
  'A2': 'n/a',
  'A3': '8',
  'A4': '2',
};

const showsRounds = <ShowsRound>[
  ShowsRound(
    formula: '=IF(A1>=10, A1*2, A1+5)',
    cell: 'C1',
    values: _ifSheet,
    options: ['24', '17', '10', '1'],
    answer: 0,
    why:
        'Twelve is at least ten, so the test passes and the middle argument '
        'is what comes back: twelve doubled. Seventeen is the other branch, '
        'and the 1 is what you get by treating TRUE as a number.',
    source: 'math-spr-q3',
  ),
  ShowsRound(
    formula: '=IF(A2>=10, A2*2, A2+5)',
    cell: 'C2',
    values: _ifSheet,
    options: ['14', '12', '7', '0'],
    answer: 1,
    why:
        'Seven is not at least ten, so the test fails and the LAST argument '
        'comes back: seven plus five. Same formula as the round before, '
        'different cell, different branch.',
    source: 'math-spr-q3',
  ),
  ShowsRound(
    formula: '=SUM(B1:B3)',
    cell: 'C1',
    values: _sumSheet,
    options: ['90', '30', '3', '40'],
    answer: 0,
    why:
        'A colon means a range, and SUM adds everything in it. The 3 is what '
        'COUNT would give you and the 30 is the average.',
    source: 'math-spr-q1',
  ),
  ShowsRound(
    formula: '=AVERAGE(B1:B3)',
    cell: 'C2',
    values: _sumSheet,
    options: ['90', '30', '40', '3'],
    answer: 1,
    why:
        'The same range, the arithmetic mean instead of the total. Ninety is '
        'the sum sitting right beside it, which is why the two get handed in '
        'for each other.',
    source: 'math-spr-q1',
  ),
  ShowsRound(
    formula: '=COUNT(A1:A4)',
    cell: 'C1',
    values: _countSheet,
    options: ['4', '3', '15', '2'],
    answer: 1,
    why:
        'COUNT counts NUMBERS. The cell holding text is in the range and is '
        'not counted, so the answer is three and not four. Fifteen is what '
        'SUM would have given.',
    source: 'math-spr-q1',
  ),
  ShowsRound(
    formula: '=MAX(B1:B3)-MIN(B1:B3)',
    cell: 'C3',
    values: _sumSheet,
    options: ['60', '40', '20', '90'],
    answer: 2,
    why:
        'Largest take smallest, which is the spread of the column. Forty is '
        'just the largest, and sixty is the two of them added rather than '
        'subtracted.',
    source: 'math-spr-q1',
  ),
];

class _WhatShowsGameState extends State<WhatShowsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-shows',
    chapterId: 'mathematics',
    total: showsRounds.length,
    sourceProblemIdOf: (round) => showsRounds[round].source,
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

  ShowsRound get _round => showsRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Does the Cell Show',
        closing:
            'A cell holds a formula and shows a result. IF returns one '
            'branch or the other and never a 1, COUNT ignores anything that '
            'is not a number, and a colon always means every cell in between.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: functionsBrief,
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
            'THE FORMULA, AND WHAT IT DISPLAYS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            'Cell ${r.cell} holds this. What does it show?',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          FormulaBar(cell: r.cell, formula: r.formula),
          const SizedBox(height: 12),
          SheetGrid(
            columns: const ['A', 'B'],
            rows: 4,
            values: r.values,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < r.options.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _ValueButton(
                    key: ValueKey('shows-$i'),
                    label: r.options[i],
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE DISPLAY' : 'NOT THAT',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _ValueButton extends StatelessWidget {
  const _ValueButton({
    super.key,
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
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
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.mono(size: 16, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
