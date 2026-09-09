import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which Line Do You Read — the second item for `central-tendency-dispersion`.
///
/// The lesson spends a whole callout on the calculator, and with good reason:
/// on the exam nobody computes a standard deviation by hand, they read one off
/// a screen that offers six numbers at once. Every trap in the lesson is a
/// wrong line on that screen. The sum instead of the mean. The population
/// figure instead of the sample one, which is the missing n minus one wearing
/// a different hat. And the variance, which is not on the screen at all, so
/// the honest answer is that you have to square something first.
class WhichReadoutGame extends StatefulWidget {
  const WhichReadoutGame({super.key});

  @override
  State<WhichReadoutGame> createState() => _WhichReadoutGameState();
}

/// The six lines a 1-Var Stats screen shows, in the order it shows them.
const readoutLines = <(String, String)>[
  ('n', 'how many readings'),
  ('x̄', 'the arithmetic mean'),
  ('Sx', 'standard deviation over n minus 1'),
  ('σx', 'standard deviation over n'),
  ('Σx', 'the readings added up'),
  ('Σx²', 'the squares added up'),
];

@immutable
class ReadoutRound {
  const ReadoutRound({
    required this.ask,
    required this.values,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String ask;

  /// What the screen is showing, one per line above.
  final List<String> values;

  /// Which line to hand in, or -1 when the number wanted is not on the screen.
  final int answer;
  final String why;
  final String source;
}

const readoutRounds = <ReadoutRound>[
  ReadoutRound(
    ask: 'Five moisture readings are in. The report wants the average '
        'moisture content.',
    values: ['5', '12.9', '0.89', '0.79', '64.5', '839.03'],
    answer: 1,
    why:
        'The mean is its own line. The 64.5 beside it is the readings added '
        'up, which is the number people hand in when they stop one step '
        'early.',
    source: 'stat-ctd-q1',
  ),
  ReadoutRound(
    ask: 'Six cylinders from one pour. The spec asks for the SAMPLE standard '
        'deviation.',
    values: ['6', '4183.3', '85.2', '77.8', '25100', '105000000'],
    answer: 2,
    why:
        'Sx is the one over n minus one, and six cylinders out of a whole '
        'pour are a sample. σx below it divides by n and gives 77.8, which is '
        'the single most common wrong answer on this topic.',
    source: 'stat-ctd-q2',
  ),
  ReadoutRound(
    ask: 'Every cylinder ever cast from this batch is on the screen. The '
        'question asks for the standard deviation of the batch.',
    values: ['6', '4183.3', '85.2', '77.8', '25100', '105000000'],
    answer: 3,
    why:
        'Not a sample this time. When the readings ARE the whole population '
        'there is nothing to correct for, so the divisor is n and σx is the '
        'line. Same screen, different question, different line.',
    source: 'stat-ctd-q2',
  ),
  ReadoutRound(
    ask: 'The same six cylinders. The report asks for the sample VARIANCE.',
    values: ['6', '4183.3', '85.2', '77.8', '25100', '105000000'],
    answer: -1,
    why:
        'Variance is not on this screen. It is the standard deviation '
        'squared, so 85.2 squared gives about 7,267. Reaching for Σx² because '
        'it has a square in it is the trap that line exists to set.',
    source: 'stat-ctd-q2',
  ),
  ReadoutRound(
    ask: 'How many readings went into this?',
    values: ['8', '203.4', '19.6', '18.3', '1627', '333000'],
    answer: 0,
    why:
        'The count has its own line, and it is worth reading before anything '
        'else: it tells you whether the sample line or the population line is '
        'the one you want.',
    source: 'stat-ctd-q1',
  ),
  ReadoutRound(
    ask: 'The coefficient of variation, so two sites with different units can '
        'be compared.',
    values: ['8', '203.4', '19.6', '18.3', '1627', '333000'],
    answer: -1,
    why:
        'Also not on the screen. It is the sample standard deviation over the '
        'mean, so it comes from two lines rather than one, and it comes out '
        'dimensionless on purpose.',
    source: 'stat-ctd-q2',
  ),
];

class _WhichReadoutGameState extends State<WhichReadoutGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-readout',
    chapterId: 'statistics',
    total: readoutRounds.length,
    sourceProblemIdOf: (round) => readoutRounds[round].source,
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

  ReadoutRound get _round => readoutRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Line Do You Read',
        closing:
            'Sx divides by n minus one and σx divides by n, and which you want '
            'is decided by whether the readings are a sample or everything '
            'there is. Variance and the coefficient of variation are not on '
            'the screen at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: spreadBrief,
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
            'ONE SCREEN, SIX NUMBERS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  color: Colors.white.withValues(alpha: 0.08),
                  child: Center(
                    child: Text(
                      '1-VAR STATS',
                      style: AppTheme.overline(color: AppColors.cream),
                    ),
                  ),
                ),
                for (var i = 0; i < readoutLines.length; i++)
                  _Line(
                    key: ValueKey('line-$i'),
                    name: readoutLines[i].$1,
                    meaning: readoutLines[i].$2,
                    value: r.values[i],
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = i),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _NotThereButton(
            selected: _picked == -1,
            locked: answered,
            isTruth: r.answer == -1,
            onTap: answered ? null : () => setState(() => _picked = -1),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? (r.answer == -1 ? 'NOT ON THE SCREEN' : 'THAT LINE')
                  : 'NOT THAT LINE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    super.key,
    required this.name,
    required this.meaning,
    required this.value,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String name;
  final String meaning;
  final String value;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color fill;
    if (locked && isTruth) {
      fill = AppColors.forest.withValues(alpha: 0.45);
    } else if (locked && selected) {
      fill = AppColors.error.withValues(alpha: 0.4);
    } else if (selected) {
      fill = AppColors.ember.withValues(alpha: 0.4);
    } else {
      fill = Colors.transparent;
    }

    return Material(
      color: fill,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Text(
                  name,
                  style: AppTheme.code(size: 15, color: AppColors.cream),
                ),
              ),
              Expanded(
                child: Text(
                  meaning,
                  style: AppTheme.mono(
                    size: 10,
                    color: AppColors.cream.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Text(
                value,
                style: AppTheme.code(size: 15, color: AppColors.cream),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotThereButton extends StatelessWidget {
  const _NotThereButton({
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
      key: const ValueKey('line-none'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            'It is not on this screen',
            style: AppTheme.heading(size: 14.5),
          ),
        ),
      ),
    );
  }
}
