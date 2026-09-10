import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'irr_figures.dart';
import 'lesson_brief.dart';

/// Which Earns More — the third item for `rate-of-return`.
///
/// The definition problem's first wrong answer is undiscounted profit, and it
/// is the one people actually pick, because a bigger total feels like a better
/// project. Nothing in a sentence dislodges that. Two pictures do.
///
/// Every round is a pair of cash flow diagrams drawn to one scale, and the
/// question is which of them earns the higher rate. The totals are on the
/// arrows where they can be added up by eye, and in half the rounds the one
/// that hands back more money is the one earning less. One round is the same
/// deal at two sizes, where the honest answer is that the rate is identical.
class WhichEarnsMoreGame extends StatefulWidget {
  const WhichEarnsMoreGame({super.key});

  @override
  State<WhichEarnsMoreGame> createState() => _WhichEarnsMoreGameState();
}

enum Earns { first, second, same }

@immutable
class EarnsRound {
  const EarnsRound({
    required this.subject,
    required this.situation,
    required this.first,
    required this.second,
    required this.why,
    required this.source,
  });

  final String subject;
  final String situation;
  final Project first;
  final Project second;
  final String why;
  final String source;

  /// Worked out rather than declared, from the two sets of cash flows.
  Earns get answer {
    final a = first.irr;
    final b = second.irr;
    if ((a - b).abs() < 0.0005) return Earns.same;
    return a > b ? Earns.first : Earns.second;
  }

  /// One scale for both diagrams, or the pictures lie about size.
  double get scale =>
      first.biggest > second.biggest ? first.biggest : second.biggest;

  /// And one time span, or they lie about waiting.
  int get periods =>
      first.lastPeriod > second.lastPeriod ? first.lastPeriod : second.lastPeriod;
}

const earnsRounds = <EarnsRound>[
  EarnsRound(
    subject: 'the same money, one year apart',
    situation:
        'A thousand goes out today either way and twelve hundred comes back '
        'either way. The only difference is when.',
    first: Project('the first', [(0, -1000), (2, 1200)]),
    second: Project('the second', [(0, -1000), (1, 1200)]),
    why:
        'The second. Identical money in and identical money out, and the one '
        'that gets there in a year earns twenty percent while the one that '
        'takes two earns under ten. A rate is money per year, so the same gain '
        'over a longer wait is a smaller rate.',
    source: 'econ-ror-q3',
  ),
  EarnsRound(
    subject: 'the same deal at two sizes',
    situation:
        'The second is the first with every number doubled. Twice as much '
        'money out, twice as much back, on the same day.',
    first: Project('the first', [(0, -1000), (1, 1150)]),
    second: Project('the second', [(0, -2000), (1, 2300)]),
    why:
        'Neither. Both earn fifteen percent, because a rate of return is a '
        'ratio and doubling the top and the bottom of a ratio changes nothing. '
        'The second returns 150 more dollars and earns not one point more. '
        'That is the whole difference between a rate and a profit.',
    source: 'econ-ror-q1',
  ),
  EarnsRound(
    subject: 'all at the end, or half of it early',
    situation:
        'A thousand out today in both. The first pays six hundred at the end '
        'of each of two years, the second pays the whole twelve hundred at the '
        'end of the second.',
    first: Project('the first', [(0, -1000), (1, 600), (2, 600)]),
    second: Project('the second', [(0, -1000), (2, 1200)]),
    why:
        'The first, at about thirteen percent against under ten. The totals '
        'are the same twelve hundred, so nothing separates these two except '
        'that half of the first one\'s money comes back a year early and can '
        'go to work again.',
    source: 'econ-ror-q3',
  ),
  EarnsRound(
    subject: 'the same, and then a little more',
    situation:
        'The second is the first with one extra payment tacked on at the end '
        'of year two. Everything before that is identical.',
    first: Project('the first', [(0, -1000), (1, 1200)]),
    second: Project('the second', [(0, -1000), (1, 1200), (2, 100)]),
    why:
        'The second, and this is the one round where more money really does '
        'mean a better rate. Nothing was given up for it: the same thousand '
        'buys everything the first one bought and a hundred more afterwards, '
        'so the return can only go up.',
    source: 'econ-ror-q1',
  ),
  EarnsRound(
    subject: 'a smaller job beside a bigger one',
    situation:
        'The first costs eight hundred and returns a thousand in a year. The '
        'second costs twelve hundred and returns fourteen forty, in the same '
        'year.',
    first: Project('the first', [(0, -800), (1, 1000)]),
    second: Project('the second', [(0, -1200), (1, 1440)]),
    why:
        'The first, at twenty-five percent against twenty. The second hands '
        'back 240 dollars against the first one\'s 200 and earns less doing '
        'it, because it needed half again as much money at risk to get there. '
        'The bigger project is not the better one.',
    source: 'econ-ror-q3',
  ),
  EarnsRound(
    subject: 'a lot more money, a long way off',
    situation:
        'The first returns fourteen hundred, which is far more than the second '
        'ever pays. It arrives at the end of year four.',
    first: Project('the first', [(0, -1000), (4, 1400)]),
    second: Project('the second', [(0, -1000), (1, 1150)]),
    why:
        'The second, at fifteen percent against under nine. Forty percent of '
        'gain looks like the better deal until you notice it took four years '
        'to earn, which is about a tenth a year before compounding. Total '
        'profit is not a rate and this is the round where it costs you most.',
    source: 'econ-ror-q1',
  ),
];

class _WhichEarnsMoreGameState extends State<WhichEarnsMoreGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-earns-more',
    chapterId: 'economics',
    total: earnsRounds.length,
    sourceProblemIdOf: (round) => earnsRounds[round].source,
  )..addListener(_onSession);

  Earns? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  EarnsRound get _round => earnsRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Earns More',
        closing:
            'A rate is not a total. Money that comes back sooner earns more '
            'than the same money later, a smaller stake can earn more than a '
            'larger one, and doubling every figure in a project leaves its '
            'return exactly where it was.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: timingBrief,
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
            'WHICH RATE IS HIGHER',
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
          const SizedBox(height: 12),
          for (final (i, project) in [r.first, r.second].indexed) ...[
            if (i > 0) const SizedBox(height: 8),
            Text(
              i == 0 ? 'THE FIRST' : 'THE SECOND',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 126,
                width: double.infinity,
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: CustomPaint(
                    painter: DealPainter(
                      project: project,
                      periods: r.periods,
                      scale: r.scale,
                      colour: AppColors.charcoal,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (i, choice) in Earns.values.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _EarnsButton(
                    key: ValueKey('earns-${choice.name}'),
                    label: switch (choice) {
                      Earns.first => 'The first',
                      Earns.second => 'The second',
                      Earns.same => 'The same',
                    },
                    selected: _picked == choice,
                    locked: answered,
                    isTruth: choice == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = choice),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'WHAT THEY EARN',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            Text(
              'the first    ${_pct(r.first.irr)}\n'
              'the second   ${_pct(r.second.irr)}',
              style: AppTheme.code(size: 12),
            ),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT ONE' : 'THE OTHER READING',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }

  static String _pct(double i) => '${(i * 100).toStringAsFixed(1)}%';
}

class _EarnsButton extends StatelessWidget {
  const _EarnsButton({
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
