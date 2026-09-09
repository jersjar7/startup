import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which One Do You Build — the second item for
/// `benefit-cost-decision-trees`.
///
/// The lesson says it outright: with mutually exclusive alternatives you
/// cannot pick the highest individual benefit-cost ratio. Rank them by cost
/// and ask, of each step up, whether the extra benefit covers the extra cost.
/// Keep stepping while it does and stop when it stops.
///
/// So every option's own ratio is on the board, and the highest one is the
/// wrong answer more often than not. The individual ratios still matter for
/// one thing: an option that cannot clear one on its own is not in the race
/// at all.
class WhichOneDoYouBuildGame extends StatefulWidget {
  const WhichOneDoYouBuildGame({super.key});

  @override
  State<WhichOneDoYouBuildGame> createState() =>
      _WhichOneDoYouBuildGameState();
}

/// One alternative, priced in whatever units the round is working in.
@immutable
class Alternative {
  const Alternative(this.name, this.cost, this.benefit);

  final String name;
  final double cost;
  final double benefit;

  double get ratio => benefit / cost;
}

@immutable
class BuildRound {
  const BuildRound({
    required this.subject,
    required this.units,
    required this.options,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What the numbers are in, said once rather than on every row.
  final String units;

  /// Cheapest first, which is the order the analysis needs them in.
  final List<Alternative> options;
  final String why;
  final String source;

  /// Worked out rather than declared: start from the cheapest option that
  /// clears one on its own, then step up while each extra buys its keep.
  int get answer {
    var best = -1;
    for (var i = 0; i < options.length; i++) {
      if (options[i].ratio < 1) continue;
      if (best < 0) {
        best = i;
        continue;
      }
      final dB = options[i].benefit - options[best].benefit;
      final dC = options[i].cost - options[best].cost;
      if (dC > 0 && dB / dC >= 1) best = i;
    }
    return best;
  }

  /// The comparisons the analysis actually makes, in order, for the reveal.
  ///
  /// Not consecutive pairs. Once a step fails, the next option is compared
  /// against the last one that SURVIVED, and printing consecutive pairs would
  /// show a comparison nobody made.
  List<String> get steps {
    final out = <String>[];
    var best = -1;
    for (var i = 0; i < options.length; i++) {
      final o = options[i];
      if (o.ratio < 1) {
        out.add('${o.name} on its own   ${o.ratio.toStringAsFixed(2)}   out');
        continue;
      }
      if (best < 0) {
        best = i;
        out.add('${o.name} on its own   ${o.ratio.toStringAsFixed(2)}   in');
        continue;
      }
      final dB = o.benefit - options[best].benefit;
      final dC = o.cost - options[best].cost;
      final ratio = dC > 0 ? dB / dC : 0.0;
      final keep = dC > 0 && ratio >= 1;
      out.add(
        '${options[best].name} to ${o.name}   '
        '${ratio.toStringAsFixed(2)}   ${keep ? 'keep going' : 'stop here'}',
      );
      if (keep) best = i;
    }
    return out;
  }
}

const buildRounds = <BuildRound>[
  BuildRound(
    subject: 'three drainage schemes',
    units: 'present worth, thousands of dollars',
    options: [
      Alternative('A', 800, 1040),
      Alternative('B', 1200, 1440),
      Alternative('C', 1600, 1920),
    ],
    why:
        'A has the best individual ratio and is not the answer. Stepping A to '
        'B buys 400 of benefit for 400 of cost, which pays for itself exactly, '
        'and B to C buys 480 for 400, which pays rather better. Each step '
        'earns its money, so build the largest.',
    source: 'econ-bcd-q2',
  ),
  BuildRound(
    subject: 'two levee heights',
    units: 'present worth, millions of dollars',
    options: [
      Alternative('Low', 6, 9),
      Alternative('High', 12, 13),
    ],
    why:
        'Both clear one on their own, and the step up does not. Six million '
        'more buys four million more of protection, which is a ratio of two '
        'thirds, so the extra height is not worth building even though the '
        'high levee is a justified project in isolation.',
    source: 'econ-bcd-q2',
  ),
  BuildRound(
    subject: 'a corridor, three widths',
    units: 'annual worth, thousands of dollars',
    options: [
      Alternative('Two lane', 400, 520),
      Alternative('Four lane', 700, 910),
      Alternative('Six lane', 1100, 1200),
    ],
    why:
        'Two steps and only the first one pays. Four lanes buys 390 of benefit '
        'for 300 of cost; going to six buys 290 for 400 and stops being worth '
        'it. Stop at the last step that paid, not at the largest option that '
        'clears one.',
    source: 'econ-bcd-q2',
  ),
  BuildRound(
    subject: 'a scheme that never justified itself',
    units: 'present worth, thousands of dollars',
    options: [
      Alternative('Small', 500, 450),
      Alternative('Medium', 900, 1080),
      Alternative('Large', 1400, 1650),
    ],
    why:
        'The cheapest option is out before the comparison starts, because it '
        'does not return what it costs. Medium to Large buys 570 for 500 and '
        'pays, so the largest wins, and the option nobody should build was '
        'never in the race.',
    source: 'econ-bcd-q2',
  ),
  BuildRound(
    subject: 'two culvert sizes',
    units: 'present worth, thousands of dollars',
    options: [
      Alternative('600 mm', 240, 360),
      Alternative('900 mm', 300, 430),
    ],
    why:
        'The small pipe has the better ratio of the two and still loses. Sixty '
        'thousand more buys seventy thousand more, so the step pays for itself '
        'and the bigger pipe wins on the increment rather than on how it '
        'looks in the column.',
    source: 'econ-bcd-q1',
  ),
  BuildRound(
    subject: 'three treatment upgrades',
    units: 'annual worth, thousands of dollars',
    options: [
      Alternative('Phase 1', 200, 260),
      Alternative('Phase 2', 340, 380),
      Alternative('Phase 3', 480, 560),
    ],
    why:
        'The first step buys 120 for 140 and fails, so Phase 2 is out. But '
        'Phase 3 against Phase 1 buys 300 for 280 and pays, which is why the '
        'comparison is always against the last option that SURVIVED rather '
        'than against the one immediately below.',
    source: 'econ-bcd-q2',
  ),
];

class _WhichOneDoYouBuildGameState extends State<WhichOneDoYouBuildGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-do-you-build',
    chapterId: 'economics',
    total: buildRounds.length,
    sourceProblemIdOf: (round) => buildRounds[round].source,
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

  BuildRound get _round => buildRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Do You Build',
        closing:
            'Rank them by cost and ask of each step whether the extra benefit '
            'covers the extra cost. The highest individual ratio belongs to '
            'the cheapest option almost every time and is almost never the '
            'answer. An option that cannot clear one on its own is out before '
            'the comparison begins.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: incrementalBrief,
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
            'MUTUALLY EXCLUSIVE. BUILD ONE.',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 2),
          Text(
            r.units,
            style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          _Table(options: r.options),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < r.options.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _OptionButton(
                    key: ValueKey('build-$i'),
                    label: r.options[i].name,
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
              'WHAT THE ANALYSIS ASKED',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            for (final step in r.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(step, style: AppTheme.code(size: 12)),
              ),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'BUILD THAT ONE' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The alternatives as a board would see them: cost, benefit, and the ratio
/// that tempts everybody.
class _Table extends StatelessWidget {
  const _Table({required this.options});

  final List<Alternative> options;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 74),
              for (final label in ['cost', 'benefit', 'B/C'])
                Expanded(
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      label,
                      style: AppTheme.overline(color: AppColors.ink3),
                    ),
                  ),
                ),
            ],
          ),
          for (final o in options) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Divider(height: 1, color: AppColors.line),
            ),
            Row(
              children: [
                SizedBox(
                  width: 74,
                  child: Text(o.name, style: AppTheme.code(size: 12.5)),
                ),
                for (final v in [
                  o.cost.toStringAsFixed(0),
                  o.benefit.toStringAsFixed(0),
                  o.ratio.toStringAsFixed(2),
                ])
                  Expanded(
                    child: Center(
                      widthFactor: 1,
                      child: Text(v, style: AppTheme.code(size: 12.5)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
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
          height: 54,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
