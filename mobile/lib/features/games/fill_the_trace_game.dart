import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Fill the Trace — the first item for `structured-programming`.
///
/// The lesson does not ask anyone to be clever about loops, it asks them to
/// write the variables in a column and update them pass by pass. So that
/// column is the item. The passes are laid out with the loop variable already
/// filled in, and the student drops the running value into each row from a
/// strip of candidates. Doing it a row at a time is the point: the off-by-one
/// the lesson warns about is a row that should be there and is not, and it is
/// obvious in a table and invisible in a single answer.
class FillTheTraceGame extends StatefulWidget {
  const FillTheTraceGame({super.key});

  @override
  State<FillTheTraceGame> createState() => _FillTheTraceGameState();
}

@immutable
class TraceRound {
  const TraceRound({
    required this.code,
    required this.variable,
    required this.counters,
    required this.answer,
    required this.choices,
    required this.why,
    required this.source,
  });

  /// The pseudocode, one line per element.
  final List<String> code;

  /// The name of the running variable being traced.
  final String variable;

  /// What the loop variable is on each pass.
  final List<int> counters;

  /// What the running variable holds after each pass.
  final List<String> answer;

  /// The strip of values on offer, which holds every right one and some
  /// wrong ones that are real mistakes rather than noise.
  final List<String> choices;
  final String why;
  final String source;
}

const traceRounds = <TraceRound>[
  TraceRound(
    code: ['total = 0', 'FOR i = 1 TO 4', '    total = total + i'],
    variable: 'total',
    counters: [1, 2, 3, 4],
    answer: ['1', '3', '6', '10'],
    choices: ['0', '1', '3', '4', '5', '6', '10', '15'],
    why:
        'Four passes, because the endpoints are both included. Stopping at '
        'three leaves you with six, which is the off-by-one the lesson warns '
        'about, and fifteen is a pass too many.',
    source: 'math-prg-q1',
  ),
  TraceRound(
    code: ['total = 0', 'FOR i = 1 TO 4', '    total = total + 2*i'],
    variable: 'total',
    counters: [1, 2, 3, 4],
    answer: ['2', '6', '12', '20'],
    choices: ['1', '2', '3', '6', '10', '12', '20', '30'],
    why:
        'The same four passes with twice as much added each time, so every '
        'row is double the first round. The shape of the trace never changes, '
        'only what goes into it.',
    source: 'math-prg-q1',
  ),
  TraceRound(
    code: ['p = 1', 'FOR i = 1 TO 4', '    p = p * i'],
    variable: 'p',
    counters: [1, 2, 3, 4],
    answer: ['1', '2', '6', '24'],
    choices: ['0', '1', '2', '3', '6', '10', '12', '24'],
    why:
        'A product accumulator, and it has to start at one. Starting a '
        'product at zero would leave it at zero forever, which is worth '
        'noticing before you write your own.',
    source: 'math-prg-q1',
  ),
  TraceRound(
    code: ['total = 10', 'FOR i = 1 TO 3', '    total = total - i'],
    variable: 'total',
    counters: [1, 2, 3],
    answer: ['9', '7', '4'],
    choices: ['3', '4', '6', '7', '8', '9', '10'],
    why:
        'Three passes, going down instead of up. The starting value is not '
        'always zero and the loop does not care which way the numbers move.',
    source: 'math-prg-q1',
  ),
  TraceRound(
    code: ['count = 0', 'FOR i = 2 TO 5', '    count = count + 1'],
    variable: 'count',
    counters: [2, 3, 4, 5],
    answer: ['1', '2', '3', '4'],
    choices: ['0', '1', '2', '3', '4', '5', '6', '14'],
    why:
        'This one counts passes rather than adding them up, and it lands on '
        'four. Four is how many times the loop ran; fourteen is what the '
        'values would have added to. Those are different questions.',
    source: 'math-prg-q1',
  ),
  TraceRound(
    code: ['total = 0', 'FOR i = 0 TO 3', '    total = total + i'],
    variable: 'total',
    counters: [0, 1, 2, 3],
    answer: ['0', '1', '3', '6'],
    choices: ['0', '1', '2', '3', '4', '5', '6', '10'],
    why:
        'Starting at zero still gives four passes, because both ends are '
        'included. The first pass adds nothing at all, which makes the row '
        'easy to skip and the count easy to get wrong.',
    source: 'math-prg-q1',
  ),
];

class _FillTheTraceGameState extends State<FillTheTraceGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'fill-the-trace',
    chapterId: 'mathematics',
    total: traceRounds.length,
    sourceProblemIdOf: (round) => traceRounds[round].source,
  )..addListener(_onSession);

  /// Row index to the value dropped in it.
  final Map<int, String> _filled = {};

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TraceRound get _round => traceRounds[_session.round];

  /// The first row still waiting for a value.
  int? _nextEmpty(TraceRound r) {
    for (var i = 0; i < r.counters.length; i++) {
      if (!_filled.containsKey(i)) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Fill the Trace',
        closing:
            'A loop from one to four runs four times, both ends included, and '
            'the way to be sure is to write the rows out. The answer is the '
            'last row, not the number of rows.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final complete = _filled.length == r.counters.length;
    final next = _nextEmpty(r);

    return BoardShell(
      session: _session,
      brief: tracingBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_filled.clear);
              _session.next();
            }
          : (!complete
                ? null
                : () => _session.submit(
                    ok: [
                      for (var i = 0; i < r.answer.length; i++)
                        _filled[i] == r.answer[i],
                    ].every((ok) => ok),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ONE ROW PER PASS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill in what ${r.variable} holds after each pass.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          _CodeBlock(lines: r.code),
          const SizedBox(height: 14),
          _TraceTable(
            round: r,
            filled: _filled,
            answered: answered,
            active: next,
            onClear: answered
                ? null
                : (row) => setState(() => _filled.remove(row)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final choice in r.choices)
                _ChoiceChip(
                  key: ValueKey('choice-$choice'),
                  label: choice,
                  onTap: answered || next == null
                      ? null
                      : () => setState(() => _filled[next] = choice),
                ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THE WHOLE TRACE' : 'A ROW IS WRONG',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                line,
                style: AppTheme.code(size: 13.5, color: AppColors.cream),
              ),
            ),
        ],
      ),
    );
  }
}

class _TraceTable extends StatelessWidget {
  const _TraceTable({
    required this.round,
    required this.filled,
    required this.answered,
    required this.active,
    required this.onClear,
  });

  final TraceRound round;
  final Map<int, String> filled;
  final bool answered;

  /// The row the next tapped value will land in.
  final int? active;
  final void Function(int row)? onClear;

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
              Expanded(child: _Head(text: 'pass')),
              Expanded(child: _Head(text: 'i')),
              Expanded(flex: 2, child: _Head(text: round.variable)),
            ],
          ),
          for (var row = 0; row < round.counters.length; row++)
            Row(
              children: [
                Expanded(child: _Body(text: '${row + 1}')),
                Expanded(child: _Body(text: '${round.counters[row]}')),
                Expanded(
                  flex: 2,
                  child: _Slot(
                    key: ValueKey('slot-$row'),
                    value: filled[row],
                    active: !answered && active == row,
                    truth: answered ? round.answer[row] : null,
                    onTap: onClear == null || !filled.containsKey(row)
                        ? null
                        : () => onClear!(row),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      alignment: Alignment.center,
      color: AppColors.creamDark,
      child: Text(text, style: AppTheme.overline(color: AppColors.ink2)),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Text(
        text,
        style: AppTheme.mono(size: 14, color: AppColors.ink2),
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    super.key,
    required this.value,
    required this.active,
    required this.truth,
    required this.onTap,
  });

  final String? value;

  /// The row a tapped value will drop into next.
  final bool active;

  /// What belongs here, once the round is over.
  final String? truth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = truth != null;
    final right = locked && value == truth;
    final Color fill;
    final Color border;
    if (locked && right) {
      fill = AppColors.forestBg;
      border = AppColors.forest;
    } else if (locked) {
      fill = AppColors.errorBg;
      border = AppColors.error;
    } else if (active) {
      fill = AppColors.emberBg;
      border = AppColors.ember;
    } else if (value != null) {
      fill = AppColors.creamDark;
      border = AppColors.line;
    } else {
      fill = AppColors.white;
      border = AppColors.line;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          border: Border(
            top: BorderSide(color: AppColors.line),
            left: BorderSide(color: AppColors.line),
          ),
        ),
        child: Container(
          width: 62,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            locked && !right ? '${value ?? '—'} / $truth' : (value ?? ''),
            style: AppTheme.mono(size: 13, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 62,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.line),
          ),
          child: Text(
            label,
            style: AppTheme.mono(size: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
