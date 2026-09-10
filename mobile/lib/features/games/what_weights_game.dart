import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What Gets Weighted — the third item for `central-tendency-dispersion`.
///
/// The hard problem in this lesson is a weighted average and its difficulty is
/// not the arithmetic, it is working out which column is the value and which
/// is the weight. Get that pairing wrong and the formula runs perfectly to the
/// wrong answer, which is what both of its named traps are. So the table
/// arrives with its columns and the student names the two roles. Nothing is
/// added up. One round has weights that are all equal, because a weighted
/// average with equal weights is just an average, and knowing when the extra
/// machinery buys you nothing is worth as much as knowing how to run it.
class WhatWeightsGame extends StatefulWidget {
  const WhatWeightsGame({super.key});

  @override
  State<WhatWeightsGame> createState() => _WhatWeightsGameState();
}

@immutable
class WeightRound {
  const WeightRound({
    required this.ask,
    required this.columns,
    required this.rows,
    required this.value,
    required this.weight,
    required this.why,
    required this.source,
  });

  final String ask;

  /// Column headings, left to right. The first is always a label rather than
  /// a number, so it is never a candidate.
  final List<String> columns;
  final List<List<String>> rows;

  /// Which column supplies the values, and which supplies the weights.
  final int value;
  final int weight;
  final String why;
  final String source;
}

const weightRounds = <WeightRound>[
  WeightRound(
    ask: 'What is the weighted average hourly traffic volume?',
    columns: ['Period', 'Vehicles', 'Hours', 'Veh/hr'],
    rows: [
      ['Morning', '520', '2', '260'],
      ['Midday', '870', '5', '174'],
      ['Evening', '610', '3', '203'],
    ],
    value: 3,
    weight: 2,
    why:
        'The question asks for an hourly volume, so the values are the hourly '
        'rates and the weights are how long each count ran. Averaging the raw '
        'vehicle counts instead answers a different question, and averaging '
        'the rates without weighting treats two hours as if they were five.',
    source: 'stat-ctd-q3',
  ),
  WeightRound(
    ask: 'What is the average compressive strength across the whole pour?',
    columns: ['Batch', 'Cylinders', 'Strength psi'],
    rows: [
      ['A', '3', '4180'],
      ['B', '6', '4310'],
      ['C', '2', '3990'],
    ],
    value: 2,
    weight: 1,
    why:
        'Strength is what is being averaged and the cylinder count is how much '
        'each batch gets to say. Batch B was tested three times as often as C, '
        'so it pulls the average three times as hard.',
    source: 'stat-ctd-q3',
  ),
  WeightRound(
    ask: 'What is the average unit weight of the soil profile?',
    columns: ['Layer', 'Thickness ft', 'Unit wt pcf'],
    rows: [
      ['Fill', '4', '118'],
      ['Sand', '12', '125'],
      ['Clay', '9', '131'],
    ],
    value: 2,
    weight: 1,
    why:
        'Thicker layers count for more, so thickness is the weight. This is '
        'the same shape as the traffic problem with the words changed, which '
        'is the point: the formula never changes, only which column plays '
        'which part.',
    source: 'stat-ctd-q3',
  ),
  WeightRound(
    ask: 'What is the average daily flow over the week?',
    columns: ['Segment', 'Days', 'Flow MGD'],
    rows: [
      ['Weekdays', '5', '2.4'],
      ['Saturday', '1', '3.1'],
      ['Sunday', '1', '2.9'],
    ],
    value: 2,
    weight: 1,
    why:
        'Five weekdays against one Saturday, so the weekday figure carries '
        'five times the weight. Averaging the three numbers evenly would give '
        'the weekend two sevenths of the week and call it three.',
    source: 'stat-ctd-q3',
  ),
  WeightRound(
    ask: 'Every borehole was sampled the same number of times. What is the '
        'average blow count?',
    columns: ['Hole', 'Samples', 'Blows'],
    rows: [
      ['B-1', '4', '18'],
      ['B-2', '4', '25'],
      ['B-3', '4', '21'],
    ],
    value: 2,
    weight: 1,
    why:
        'The roles are the same as ever, and here the weights happen to be '
        'equal, so the weighted average comes out identical to the plain one. '
        'Equal weights are the case where the extra machinery buys you '
        'nothing, and spotting that saves time.',
    source: 'stat-ctd-q3',
  ),
  WeightRound(
    ask: 'What is the average cost per cubic yard across the whole job?',
    columns: ['Supplier', 'Cost \$/cy', 'Cubic yards'],
    rows: [
      ['North', '142', '80'],
      ['South', '129', '350'],
      ['East', '151', '60'],
    ],
    value: 1,
    weight: 2,
    why:
        'The columns are the other way round this time. Cost is what is being '
        'averaged and volume is how much of the job each price applied to, so '
        'reading position rather than meaning gets this one backwards.',
    source: 'stat-ctd-q3',
  ),
];

class _WhatWeightsGameState extends State<WhatWeightsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-weights',
    chapterId: 'statistics',
    total: weightRounds.length,
    sourceProblemIdOf: (round) => weightRounds[round].source,
  )..addListener(_onSession);

  int? _value;
  int? _weight;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WeightRound get _round => weightRounds[_session.round];

  /// Tapping a column fills whichever role is still empty, and tapping a
  /// column that already has a role hands it back.
  void _tapColumn(int i) {
    setState(() {
      if (_value == i) {
        _value = null;
      } else if (_weight == i) {
        _weight = null;
      } else {
        _value ??= i;
        if (_value != i) _weight ??= i;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Gets Weighted',
        closing:
            'The formula never changes. What changes is which column is the '
            'thing being averaged and which is how much each row counts for, '
            'and getting that backwards runs the arithmetic perfectly to the '
            'wrong answer.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final ready = _value != null && _weight != null;

    return BoardShell(
      session: _session,
      brief: weightedBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _value = null;
                _weight = null;
              });
              _session.next();
            }
          : (!ready
                ? null
                : () => _session.submit(
                    ok: _value == r.value && _weight == r.weight,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NAME THE TWO COLUMNS',
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
          const SizedBox(height: 6),
          Text(
            'Tap the column being averaged, then the one that weights it.',
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          _Table(
            round: r,
            value: _value,
            weight: _weight,
            answered: answered,
            onTap: answered ? null : _tapColumn,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Role(
                  label: 'BEING AVERAGED',
                  column: _value == null ? null : r.columns[_value!],
                  color: AppColors.ember,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Role(
                  label: 'THE WEIGHT',
                  column: _weight == null ? null : r.columns[_weight!],
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'BOTH ROLES' : 'NOT THOSE TWO',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({
    required this.round,
    required this.value,
    required this.weight,
    required this.answered,
    required this.onTap,
  });

  final WeightRound round;
  final int? value;
  final int? weight;
  final bool answered;
  final void Function(int)? onTap;

  Color _tint(int i) {
    if (answered) {
      if (i == round.value || i == round.weight) {
        return AppColors.forestBg;
      }
      if (i == value || i == weight) return AppColors.errorBg;
      return Colors.transparent;
    }
    if (i == value) return AppColors.emberBg;
    if (i == weight) return AppColors.infoBg;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < round.columns.length; i++)
                Expanded(
                  flex: i == 0 ? 4 : 3,
                  child: GestureDetector(
                    key: ValueKey('column-$i'),
                    onTap: i == 0 || onTap == null ? null : () => onTap!(i),
                    child: Container(
                      height: 42,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      color: i == 0 ? AppColors.creamDark : _tint(i),
                      child: Text(
                        round.columns[i],
                        textAlign: TextAlign.center,
                        style: AppTheme.overline(
                          color: i == 0 ? AppColors.ink3 : AppColors.charcoal,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (final row in round.rows)
            Row(
              children: [
                for (var i = 0; i < row.length; i++)
                  Expanded(
                    flex: i == 0 ? 4 : 3,
                    child: Container(
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == 0 ? AppColors.creamDark : _tint(i),
                        border: const Border(
                          top: BorderSide(color: AppColors.line),
                        ),
                      ),
                      child: Text(
                        row[i],
                        style: AppTheme.mono(
                          size: 12.5,
                          color: i == 0 ? AppColors.ink2 : AppColors.charcoal,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Role extends StatelessWidget {
  const _Role({
    required this.label,
    required this.column,
    required this.color,
  });

  final String label;
  final String? column;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: column == null ? AppColors.line : color,
          width: column == null ? 1 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.overline(color: AppColors.ink3)),
          const SizedBox(height: 4),
          Text(
            column ?? '?',
            style: AppTheme.mono(size: 13, color: AppColors.charcoal),
          ),
        ],
      ),
    );
  }
}
