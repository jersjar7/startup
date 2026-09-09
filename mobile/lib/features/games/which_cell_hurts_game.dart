import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'test_figures.dart';

/// Which Cell Hurts Most — the third item for
/// `hypothesis-testing-goodness-of-fit`.
///
/// The lesson's hard problem names its trap as forgetting to divide by the
/// expected count, and that division is the only interesting thing in the
/// formula. It is what makes a chi-square a comparison rather than a total: a
/// gap of ten where a hundred was expected is a small surprise, and a gap of
/// eight where twenty was expected is a large one.
///
/// So the total is not asked for. The question is which category did the
/// damage, and the rounds are built so that the biggest raw gap is repeatedly
/// not the answer.
class WhichCellHurtsGame extends StatefulWidget {
  const WhichCellHurtsGame({super.key});

  @override
  State<WhichCellHurtsGame> createState() => _WhichCellHurtsGameState();
}

@immutable
class HurtRound {
  const HurtRound({
    required this.subject,
    required this.model,
    required this.cells,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What the expected counts came from, said plainly.
  final String model;
  final List<Cell> cells;
  final int answer;
  final String why;
  final String source;
}

const hurtRounds = <HurtRound>[
  HurtRound(
    subject: 'vehicle arrivals across four time periods',
    model: '200 arrivals spread evenly, so 50 expected in each',
    cells: [
      Cell('P1', 62, 50),
      Cell('P2', 45, 50),
      Cell('P3', 53, 50),
      Cell('P4', 40, 50),
    ],
    answer: 0,
    why:
        'Every category expected the same fifty, so with a level model the '
        'biggest gap wins outright. Twelve over beats ten under once both are '
        'squared.',
    source: 'stat-ht-q3',
  ),
  HurtRound(
    subject: 'failures by component type',
    model: 'a maintenance model predicting 100, 60, 20 and 20',
    cells: [
      Cell('Beam', 118, 100),
      Cell('Deck', 44, 60),
      Cell('Pier', 26, 20),
      Cell('Rail', 12, 20),
    ],
    answer: 1,
    why:
        'Beam is eighteen out and Deck only sixteen, and Deck still hurts more '
        'because less was expected of it. The division by E is what makes '
        'chi-square a comparison rather than a tally of gaps.',
    source: 'stat-ht-q3',
  ),
  HurtRound(
    subject: 'inspections logged by day of the week',
    model: '200 inspections across five days, so 40 expected each',
    cells: [
      Cell('Mon', 35, 40),
      Cell('Tue', 40, 40),
      Cell('Wed', 40, 40),
      Cell('Thu', 15, 40),
      Cell('Fri', 70, 40),
    ],
    answer: 4,
    why:
        'Friday is thirty over and Thursday twenty five under, and the squaring '
        'pulls them apart further than the raw gaps suggest. A category sitting '
        'exactly on its expectation adds nothing at all.',
    source: 'stat-ht-q3',
  ),
  HurtRound(
    subject: 'defects by severity grade',
    model: 'a quality model predicting 20, 80, 80 and 20',
    cells: [
      Cell('A', 12, 20),
      Cell('B', 90, 80),
      Cell('C', 74, 80),
      Cell('D', 24, 20),
    ],
    answer: 0,
    why:
        'Grade B is ten out and grade A only eight, and A still wins. Twenty '
        'expected against eighty is the whole difference, and it is the reason '
        'small categories drive chi-square.',
    source: 'stat-ht-q3',
  ),
  HurtRound(
    subject: 'soil samples by classification',
    model: 'a site model predicting 120, 40 and 40',
    cells: [
      Cell('Clay', 138, 120),
      Cell('Silt', 34, 40),
      Cell('Sand', 28, 40),
    ],
    answer: 2,
    why:
        'Clay is eighteen out and Sand only twelve, and Sand is the bigger '
        'problem. Reading the biggest gap off the chart and stopping there is '
        'the mistake this round exists for.',
    source: 'stat-ht-q3',
  ),
  HurtRound(
    subject: 'complaints by quarter',
    model: '200 complaints spread evenly, so 50 expected in each',
    cells: [
      Cell('Q1', 50, 50),
      Cell('Q2', 62, 50),
      Cell('Q3', 44, 50),
      Cell('Q4', 44, 50),
    ],
    answer: 1,
    why:
        'Q1 lands exactly on the model and contributes nothing, which is what '
        'a perfect cell looks like. Q2 carries most of the statistic on its '
        'own, and two equal cells behind it share the rest.',
    source: 'stat-ht-q3',
  ),
];

class _WhichCellHurtsGameState extends State<WhichCellHurtsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-cell-hurts',
    chapterId: 'statistics',
    total: hurtRounds.length,
    sourceProblemIdOf: (round) => hurtRounds[round].source,
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

  HurtRound get _round => hurtRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Cell Hurts Most',
        closing:
            'Each cell contributes the gap SQUARED and then divided by what was '
            'expected. That division is why a small category with a small gap '
            'can outweigh a large one with a large gap, and why the biggest bar '
            'on the chart is often not the culprit.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: goodnessOfFitBrief,
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
            'WHICH CELL ADDS THE MOST',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Which category contributes most to the chi-square total?',
            style: TextStyle(
              fontSize: 15.5,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.model,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: CellsPainter(
                    cells: r.cells,
                    picked: _picked,
                    truth: answered ? r.answer : null,
                    revealed: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'the bar is what was counted, the line is what was expected',
            style: AppTheme.mono(size: 10, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < r.cells.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _CellButton(
                    key: ValueKey('cell-$i'),
                    label: r.cells[i].name,
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
            Text(
              'WHAT EACH CELL ADDS',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 6),
            for (final cell in r.cells)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '${cell.name.padRight(6)}'
                  '(${cell.observed} - ${cell.expected})^2 / ${cell.expected}'
                  '  =  ${cell.contribution.toStringAsFixed(2)}',
                  style: AppTheme.code(size: 12),
                ),
              ),
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'LOOK AT THE E',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _CellButton extends StatelessWidget {
  const _CellButton({
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
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.code(size: 13),
          ),
        ),
      ),
    );
  }
}
