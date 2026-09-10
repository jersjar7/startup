import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'depreciation_figures.dart';
import 'lesson_brief.dart';

/// Find the Factor — the first item for `depreciation-taxation-inflation`.
///
/// The lesson says it plainly: you do not have to memorize the MACRS
/// percentages, you have to be able to read the table. So the table is on the
/// screen, exactly as the handbook prints it, and the answer is a cell.
///
/// What that turns out to test is the half-year convention, which is the only
/// hard thing about the table. A five year property has SIX years of
/// depreciation and a three year property has four, so counting rows against
/// the name of the class puts you one line out. Two rounds ask for the last
/// year anything can be claimed, and one asks for a year that does not exist.
class FindTheFactorGame extends StatefulWidget {
  const FindTheFactorGame({super.key});

  @override
  State<FindTheFactorGame> createState() => _FindTheFactorGameState();
}

/// The columns on offer, in the order the handbook prints them.
const classes = [3, 5, 7];

/// How many rows the table shows. The longest column here is seven year
/// property, which runs to eight.
const tableYears = 8;

@immutable
class CellRound {
  const CellRound({
    required this.subject,
    required this.asset,
    required this.recovery,
    required this.ask,
    required this.year,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asset;

  /// Which column the asset belongs in.
  final int recovery;

  /// What is being asked for, in words rather than as a row number, so that
  /// the table has to be read rather than counted into.
  final String ask;

  /// The year the answer sits in. Past the end of the schedule means there is
  /// nothing left to claim.
  final int year;

  final String why;
  final String source;

  /// True when the asset is already fully written off and no cell answers it.
  bool get exhausted => year > macrsFactors[recovery]!.length;

  double get factor => macrsFactors[recovery]![year - 1];
}

/// The row under the table, for a year with nothing left in it.
const nothingLeft = 'Nothing. It is fully written off';

const cellRounds = <CellRound>[
  CellRound(
    subject: 'survey equipment',
    asset:
        'A firm buys survey equipment for 60,000 dollars and puts it on the '
        'books as five year property.',
    recovery: 5,
    ask: 'the deduction in year two',
    year: 2,
    why:
        'Thirty-two percent, and it is the biggest year of the asset\'s life '
        'because MACRS front-loads. Dividing the cost by five gives twenty '
        'percent, which is straight line and happens to be the year ONE '
        'figure, so the wrong method lands you one row up rather than nowhere.',
    source: 'econ-dti-q1',
  ),
  CellRound(
    subject: 'a concrete batch plant',
    asset:
        'A batch plant costs 500,000 dollars and is seven year property. The '
        'contractor expects to sell it for 40,000 at the end.',
    recovery: 7,
    ask: 'the deduction in the first year',
    year: 1,
    why:
        'Fourteen point two nine percent, of the full 500,000. The salvage '
        'figure is there to be ignored: MACRS depreciates the whole cost basis '
        'and takes the asset to zero, which is the difference between it and '
        'the straight line method sitting next to it in the handbook.',
    source: 'econ-dti-q2',
  ),
  CellRound(
    subject: 'a survey truck',
    asset:
        'A truck went on the books as five year property four years ago and '
        'the accountant is closing out its schedule.',
    recovery: 5,
    ask: 'the last year anything can be claimed',
    year: 6,
    why:
        'Year six, at five point seven six percent. Five year property is '
        'depreciated over SIX years, because the half-year convention takes '
        'half a year at the start and leaves half a year hanging off the end. '
        'Stopping at year five leaves money on the table.',
    source: 'econ-dti-q1',
  ),
  CellRound(
    subject: 'a set of laptops',
    asset:
        'Field laptops are three year property, bought for 18,000 dollars '
        'across the office.',
    recovery: 3,
    ask: 'the biggest deduction of the asset\'s life',
    year: 2,
    why:
        'Year two, at forty-four and a half percent, and it is the second year '
        'in every column of this table. The first year is only half a year, so '
        'the peak never lands on it, and nearly half the cost of a three year '
        'asset comes off in one go.',
    source: 'econ-dti-q1',
  ),
  CellRound(
    subject: 'the batch plant again',
    asset:
        'The same 500,000 dollar batch plant, seven year property, now in its '
        'third year.',
    recovery: 7,
    ask: 'the deduction in year three',
    year: 3,
    why:
        'Seventeen point four nine percent. The seven year column falls away '
        'more gently than the five year one, and the two columns have similar '
        'looking numbers in adjacent rows, which is the whole reason to find '
        'the column before counting the rows.',
    source: 'econ-dti-q2',
  ),
  CellRound(
    subject: 'equipment that has run out',
    asset:
        'The survey equipment from the first round is now in its seventh year '
        'and is still in daily use.',
    recovery: 5,
    ask: 'the deduction in year seven',
    year: 7,
    why:
        'There is none. Six years of MACRS took five year property to a book '
        'value of zero, and an asset still earning its keep can be worth '
        'plenty on the open market while being worth nothing on the books. '
        'They are different numbers and only one of them is depreciation.',
    source: 'econ-dti-q2',
  ),
];

class _FindTheFactorGameState extends State<FindTheFactorGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'find-the-factor',
    chapterId: 'economics',
    total: cellRounds.length,
    sourceProblemIdOf: (round) => cellRounds[round].source,
  )..addListener(_onSession);

  /// The cell under the thumb, as (recovery period, year).
  (int, int)? _picked;
  bool _none = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CellRound get _round => cellRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Find the Factor',
        closing:
            'Find the column before you count the rows, and remember that the '
            'class name is not the number of years: five year property is '
            'written off over six, three year over four. MACRS ignores salvage '
            'entirely and takes the book value to zero.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: macrsBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _picked = null;
                _none = false;
              });
              _session.next();
            }
          : (_picked == null && !_none
                ? null
                : () => _session.submit(
                    ok: r.exhausted
                        ? _none
                        : (!_none &&
                            _picked!.$1 == r.recovery &&
                            _picked!.$2 == r.year),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP THE PERCENTAGE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asset,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.emberBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'You want ${r.ask}.',
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.charcoal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Table(
            round: r,
            picked: _none ? null : _picked,
            locked: answered,
            onTap: answered
                ? null
                : (cell) => setState(() {
                      _none = false;
                      _picked = cell;
                    }),
          ),
          const SizedBox(height: 8),
          _NoneRow(
            selected: _none,
            locked: answered,
            isTruth: r.exhausted,
            onTap: answered
                ? null
                : () => setState(() {
                      _picked = null;
                      _none = !_none;
                    }),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT CELL' : 'A DIFFERENT CELL',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The MACRS table, printed the way the handbook prints it and tappable.
///
/// The point of putting the whole table on the screen rather than four
/// candidate percentages is that the wrong answers are the neighbours. A
/// column too far left and a row too far down are the two mistakes people
/// actually make, and neither is visible in a shortlist.
class _Table extends StatelessWidget {
  const _Table({
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final CellRound round;
  final (int, int)? picked;
  final bool locked;
  final void Function((int, int))? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  'YEAR',
                  style: AppTheme.overline(color: AppColors.ink3),
                ),
              ),
              for (final c in classes)
                Expanded(
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      '$c-YEAR',
                      style: AppTheme.overline(color: AppColors.ink3),
                    ),
                  ),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 5, bottom: 2),
            child: Divider(height: 1, color: AppColors.line),
          ),
          for (var year = 1; year <= tableYears; year++)
            Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Text(
                    '$year',
                    style: AppTheme.code(size: 12, color: AppColors.ink2),
                  ),
                ),
                for (final c in classes)
                  Expanded(
                    child: _Cell(
                      key: ValueKey('cell-$c-$year'),
                      value: year <= macrsFactors[c]!.length
                          ? macrsFactors[c]![year - 1]
                          : null,
                      selected: picked == (c, year),
                      locked: locked,
                      isTruth: !round.exhausted &&
                          c == round.recovery &&
                          year == round.year,
                      onTap: onTap == null || year > macrsFactors[c]!.length
                          ? null
                          : () => onTap!((c, year)),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.value,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final double? value;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return const SizedBox(
        height: 34,
        child: Center(
          child: Text(
            '-',
            style: TextStyle(fontSize: 12, color: AppColors.ink3),
          ),
        ),
      );
    }

    final Color border;
    final Color fill;
    final Color ink;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
      ink = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
      ink = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
      ink = AppColors.charcoal;
    } else {
      border = Colors.transparent;
      fill = Colors.transparent;
      ink = AppColors.charcoal;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Container(
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Text(
              value!.toStringAsFixed(2),
              style: AppTheme.code(size: 12.5, color: ink),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoneRow extends StatelessWidget {
  const _NoneRow({
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

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
      key: const ValueKey('nothing-left'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            nothingLeft,
            style: const TextStyle(fontSize: 14.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
