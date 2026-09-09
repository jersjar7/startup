import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'tree_figures.dart';

/// Roll It Back — the third item for `benefit-cost-decision-trees`.
///
/// A decision tree is solved backwards: work out what each chance node is
/// worth on average, then stand at the square and take the cheapest line. The
/// lesson calls that rolling the tree back, and both traps it names are
/// refusals to do it. One counts only the money spent today and pretends the
/// branch is not there. The other treats the worst ending as though it were
/// certain.
///
/// Neither needs arithmetic to catch, which is why the tree is drawn and the
/// branch itself is what gets tapped. An expected cost always lands between
/// the cheapest and dearest ending and leans toward the likelier one, and that
/// alone settles every round here: sometimes both endings sit under the
/// certain price and the odds never matter, sometimes the certain price sits
/// exactly halfway and the odds are the whole question.
class RollItBackGame extends StatefulWidget {
  const RollItBackGame({super.key});

  @override
  State<RollItBackGame> createState() => _RollItBackGameState();
}

@immutable
class TreeRound {
  const TreeRound({
    required this.subject,
    required this.units,
    required this.situation,
    required this.branches,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What the numbers on the tree are counted in, said once.
  final String units;
  final String situation;

  /// What can be chosen at the square. Order is the order they are drawn in.
  final List<TreeBranch> branches;
  final String why;
  final String source;

  /// Worked out rather than declared: the branch with the lowest expected
  /// cost, which is what standing at the square and rolling back gives you.
  int get answer {
    var best = 0;
    for (var i = 1; i < branches.length; i++) {
      if (branches[i].expected < branches[best].expected) best = i;
    }
    return best;
  }

  /// The rollback itself, for the reveal. Each branch, and where its number
  /// came from.
  List<String> get rollback => [
        for (final b in branches)
          if (b.isChance)
            '${b.name}   '
                '${[for (final e in b.ends) '${e.label} of ${_n(e.cost)}'].join(' + ')}'
                '   =   ${_n(b.expected)}'
          else
            '${b.name}   ${_n(b.certain!)}, certain',
      ];

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

const treeRounds = <TreeRound>[
  TreeRound(
    subject: 'a congested corridor',
    units: 'millions of dollars, present worth',
    situation:
        'The bypass is a known price. Widening costs less to start, but there '
        'is a real chance the traffic keeps growing and a second phase has to '
        'be built on top of it.',
    branches: [
      TreeBranch.certain('Bypass', 12),
      TreeBranch.uncertain('Widen', [Chance(0.4, 10), Chance(0.6, 5)]),
    ],
    why:
        'Widening, and you did not need the probabilities to say so. Even the '
        'bad ending costs ten against a certain twelve, so every path down '
        'that branch beats the bypass. The average works out at seven.',
    source: 'econ-bcd-q3',
  ),
  TreeRound(
    subject: 'a stretch of eroding coast',
    units: 'millions of dollars, present worth',
    situation:
        'The seawall is priced at exactly the middle of the two nourishment '
        'endings, so this one is decided by which way the odds lean and by '
        'nothing else.',
    branches: [
      TreeBranch.uncertain('Nourish', [Chance(0.25, 12), Chance(0.75, 6)]),
      TreeBranch.certain('Seawall', 9),
    ],
    why:
        'Nourishment. Its two endings, six and twelve, straddle the seawall, '
        'so the worst ending on its own says nothing. Three times out of four '
        'it comes in at six, which pulls the average down to seven and a half '
        'and under the wall.',
    source: 'econ-bcd-q3',
  ),
  TreeRound(
    subject: 'a failing culvert under a county road',
    units: 'thousands of dollars, present worth',
    situation:
        'Patching is a fraction of the price today. The inspector puts the '
        'chance of a washout before the road is next resurfaced at four in '
        'five, and a washout means replacing it anyway plus the closure.',
    branches: [
      TreeBranch.uncertain('Patch it', [Chance(0.8, 900), Chance(0.2, 300)]),
      TreeBranch.certain('Replace', 620),
    ],
    why:
        'Replace it. Three hundred is what patching costs on the ending that '
        'probably will not happen, and reading the tree as though that were '
        'the price is the mistake the lesson names. Four times in five it ends '
        'at nine hundred, so the average is 780.',
    source: 'econ-bcd-q3',
  ),
  TreeRound(
    subject: 'land for a future treatment plant',
    units: 'millions of dollars, present worth',
    situation:
        'Buying the parcel now settles it. Waiting has three endings and only '
        'two of them are labeled, so the third carries whatever probability '
        'is left over.',
    branches: [
      TreeBranch.certain('Buy now', 15),
      TreeBranch.uncertain('Wait', [
        Chance(0.3, 8),
        Chance(0.5, 10),
        Chance(0.2, 60, note: 'the rest'),
      ]),
    ],
    why:
        'Buy now. The unlabeled branch is the one in five nobody wrote down, '
        'and it costs four times the parcel. Skip it and waiting looks like a '
        'nine, count it and the average is 19.4. Probabilities at a circle '
        'have to add to one.',
    source: 'econ-bcd-q3',
  ),
  TreeRound(
    subject: 'a bridge deck at the end of its life',
    units: 'millions of dollars, present worth',
    situation:
        'Rehabilitation depends on what the chloride testing finds under the '
        'deck, and the lab puts it at even odds either way.',
    branches: [
      TreeBranch.certain('Replace', 20),
      TreeBranch.certain('Interim repairs', 14),
      TreeBranch.uncertain('Rehabilitate', [Chance(0.5, 10), Chance(0.5, 15)]),
    ],
    why:
        'Rehabilitate. Even odds put the average exactly midway between ten '
        'and fifteen, which is 12.5 and under the interim repairs. Its bad '
        'ending is worse than repairing, and that is not the same as the '
        'branch being worse.',
    source: 'econ-bcd-q3',
  ),
  TreeRound(
    subject: 'peak-hour capacity on an arterial',
    units: 'millions of dollars, present worth',
    situation:
        'The reversible lane is cheap to stripe, but the district thinks there '
        'are three chances in four that it forces a signal and geometry '
        'rebuild within two years.',
    branches: [
      TreeBranch.uncertain('Reversible lane', [Chance(0.75, 10), Chance(0.25, 2)]),
      TreeBranch.certain('Wider shoulders', 4),
      TreeBranch.certain('New signals', 9),
    ],
    why:
        'Wider shoulders. Two is the striping bill and it is the ending that '
        'probably will not stand: three times in four the lane ends up at ten, '
        'so the branch is worth eight on average and the cheapest certain '
        'option beats it.',
    source: 'econ-bcd-q3',
  ),
];

class _RollItBackGameState extends State<RollItBackGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'roll-it-back',
    chapterId: 'economics',
    total: treeRounds.length,
    sourceProblemIdOf: (round) => treeRounds[round].source,
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

  TreeRound get _round => treeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Roll It Back',
        closing:
            'Work backwards. A circle is worth its endings weighted by how '
            'likely they are, which always lands between the cheapest and the '
            'dearest and leans toward the likely one. Then stand at the square '
            'and take the cheapest line. The price today is not the branch, '
            'and neither is the worst thing that could happen.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: rollbackBrief,
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
            'TAKE THE CHEAPEST LINE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.situation,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            r.units,
            style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          _Tree(
            branches: r.branches,
            selected: _picked,
            locked: answered,
            truth: r.answer,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'ROLLED BACK',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            for (final line in r.rollback)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(line, style: AppTheme.code(size: 11.5)),
              ),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT BRANCH' : 'ANOTHER BRANCH',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The tree, with each branch its own tap target.
///
/// The branch you would take IS the answer here, so it is the thing under the
/// thumb. A list of names underneath would work and would quietly turn a
/// drawing back into a multiple choice.
class _Tree extends StatelessWidget {
  const _Tree({
    required this.branches,
    required this.selected,
    required this.locked,
    required this.truth,
    required this.onTap,
  });

  final List<TreeBranch> branches;
  final int? selected;
  final bool locked;
  final int truth;
  final void Function(int)? onTap;

  @override
  Widget build(BuildContext context) {
    final tops = <double>[];
    var y = 5.0;
    for (final b in branches) {
      tops.add(y);
      y += TreePainter.rowHeight(b);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: TreePainter.heightOf(branches),
        width: double.infinity,
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: TreePainter(
                    branches: branches,
                    selected: selected,
                    locked: locked,
                    truth: truth,
                  ),
                ),
              ),
              for (var i = 0; i < branches.length; i++)
                Positioned(
                  key: ValueKey('branch-$i'),
                  left: 0,
                  right: 0,
                  top: tops[i],
                  height: TreePainter.rowHeight(branches[i]),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap == null ? null : () => onTap!(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
