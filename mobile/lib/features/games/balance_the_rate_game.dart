import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'irr_figures.dart';
import 'lesson_brief.dart';

/// Balance the Rate — the first item for `rate-of-return`.
///
/// The lesson's definition problem asks what a rate of return IS, and the
/// three wrong answers are all quantities that have nothing to do with
/// discounting: undiscounted profit, a payback period, a salvage value. A
/// definition can be recited without any of that landing, so this item does
/// not ask for the sentence. It hands over the rate and lets it be tried.
///
/// Two bars, what the money is worth today coming in and going out, and a line
/// at the end of the second one. Raise the rate and the money arriving later
/// shrinks. The rate where the ends meet is the answer, which is the
/// definition in the only form that sticks. And the lowest stop on every round
/// is the plain undiscounted total, where the bars are furthest apart, which is
/// the named trap standing in plain view.
class BalanceTheRateGame extends StatefulWidget {
  const BalanceTheRateGame({super.key});

  @override
  State<BalanceTheRateGame> createState() => _BalanceTheRateGameState();
}

@immutable
class MeetRound {
  const MeetRound({
    required this.subject,
    required this.situation,
    required this.project,
    required this.stops,
    required this.why,
    required this.source,
  });

  final String subject;
  final String situation;
  final Project project;

  /// The rates on offer, in whole percent. Widely spaced on purpose: two
  /// stops a point apart would be two bars nobody could tell apart.
  final List<int> stops;
  final String why;
  final String source;

  /// Worked out rather than declared: whichever stop the project's own rate of
  /// return actually lands on.
  int get answer {
    final target = project.irr;
    var best = 0;
    for (var i = 1; i < stops.length; i++) {
      if ((stops[i] / 100 - target).abs() < (stops[best] / 100 - target).abs()) {
        best = i;
      }
    }
    return best;
  }

  /// What a full-width bar is worth. Taken at the lowest stop so that every
  /// other stop draws shorter, which is the whole behavior being taught.
  double get reference {
    final at = stops.first / 100;
    final a = project.pwIn(at);
    final b = project.pwOut(at);
    return (a > b ? a : b) * 1.02;
  }
}

const meetRounds = <MeetRound>[
  MeetRound(
    subject: 'a thousand out, a year to wait',
    situation:
        'You put in a thousand dollars today and a single payment of eleven '
        'fifty comes back one year from now. Nothing else happens.',
    project: Project('one year', [(0, -1000), (1, 1150)]),
    stops: [0, 5, 10, 15, 20, 25],
    why:
        'Fifteen percent, and at that rate the eleven fifty is worth exactly '
        'the thousand you put in. Over one period the return is just the gain '
        'over what you PUT IN, which is 150 on 1,000. Dividing the 150 by the '
        '1,150 you got back gives thirteen, and that is the wrong '
        'denominator.',
    source: 'econ-ror-q3',
  ),
  MeetRound(
    subject: 'more money back, longer to wait',
    situation:
        'The same thousand, but the payment is twelve ten and it does not '
        'arrive until the end of year two. A bigger gain over a longer wait.',
    project: Project('two years', [(0, -1000), (2, 1210)]),
    stops: [0, 5, 10, 15, 20, 25],
    why:
        'Ten percent. Twenty-one percent of gain sounds better than the '
        'fifteen from the round before, and as a rate it is worse, because it '
        'took two years to earn. Ten percent twice over is what turns a '
        'thousand into 1,210.',
    source: 'econ-ror-q3',
  ),
  MeetRound(
    subject: 'money back in two pieces',
    situation:
        'A thousand today buys a small plant. It returns six hundred at the '
        'end of the first year and seven hundred and twenty at the end of the '
        'second, and then it is scrapped for nothing.',
    project: Project('two payments', [(0, -1000), (1, 600), (2, 720)]),
    stops: [5, 10, 15, 20, 25, 30],
    why:
        'Twenty percent. There is no single division to do here, which is why '
        'the rate has to be tried rather than computed: the only rate that '
        'makes both payments together worth exactly a thousand today is the '
        'one where the ends meet.',
    source: 'econ-ror-q3',
  ),
  MeetRound(
    subject: 'a smaller job that pays better',
    situation:
        'Eight hundred today, five hundred back at the end of year one, six '
        'hundred and twenty-five at the end of year two.',
    project: Project('smaller job', [(0, -800), (1, 500), (2, 625)]),
    stops: [15, 20, 25, 30, 35],
    why:
        'Twenty-five percent. Less money in and less money out than the round '
        'before, and a better rate, because a rate of return says nothing '
        'about size. It is the only thing on this screen that a bigger project '
        'cannot buy.',
    source: 'econ-ror-q3',
  ),
  MeetRound(
    subject: 'a bill in the middle of it',
    situation:
        'A thousand today, then a hundred more at the end of year one to fix '
        'something nobody planned for, and thirteen twenty comes back at the '
        'end of year two.',
    project: Project('with a bill', [(0, -1000), (1, -100), (2, 1320)]),
    stops: [0, 10, 20, 30, 40],
    why:
        'Ten percent. The bill in year one belongs on the money-out bar, '
        'discounted like everything else, so BOTH bars move as the rate goes '
        'up. What has to balance is every dollar in against every dollar out, '
        'not the first cost against the last payment.',
    source: 'econ-ror-q1',
  ),
  MeetRound(
    subject: 'the same deal at twice the size',
    situation:
        'Two thousand today and twenty-three hundred back in a year. Every '
        'number in the first round of this board, doubled.',
    project: Project('doubled', [(0, -2000), (1, 2300)]),
    stops: [0, 5, 15, 25, 35],
    why:
        'Fifteen percent again, and the picture is identical to the first '
        'round. Doubling every cash flow doubles both bars and moves the '
        'balance point nowhere. A rate of return is a ratio, so it survives '
        'any change of scale.',
    source: 'econ-ror-q1',
  ),
];

class _BalanceTheRateGameState extends State<BalanceTheRateGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'balance-the-rate',
    chapterId: 'economics',
    total: meetRounds.length,
    sourceProblemIdOf: (round) => meetRounds[round].source,
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

  MeetRound get _round => meetRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Balance the Rate',
        closing:
            'A rate of return is the rate at which what comes in is worth '
            'exactly what goes out. At zero percent the bars are the plain '
            'totals, which is why the total is not the return. Raise the rate '
            'and later money shrinks. Where the ends meet, the net present '
            'worth is zero.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final shown = r.stops[_picked ?? 0];

    return BoardShell(
      session: _session,
      brief: irrBrief,
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
            'MAKE THE ENDS MEET',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: BalancePainter(
                    project: r.project,
                    rate: shown / 100,
                    reference: r.reference,
                    settled: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _picked == null
                ? 'shown at ${r.stops.first} percent. try a rate.'
                : 'trying $shown percent',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < r.stops.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _RateChip(
                    key: ValueKey('rate-${r.stops[i]}'),
                    label: '${r.stops[i]}%',
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered ? null : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              'WHERE IT BALANCES',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            Text(
              'at ${r.stops[r.answer]}%   in ${_money(r.project.pwIn(r.stops[r.answer] / 100))}'
              '   out ${_money(r.project.pwOut(r.stops[r.answer] / 100))}',
              style: AppTheme.code(size: 12),
            ),
            Text(
              'at ${r.stops.first}%   in ${_money(r.project.pwIn(r.stops.first / 100))}'
              '   out ${_money(r.project.pwOut(r.stops.first / 100))}',
              style: AppTheme.code(size: 12, color: AppColors.ink3),
            ),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THEY MEET' : 'NOT THERE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }

  static String _money(double v) {
    final s = v.round().toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({
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
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.code(size: 13),
          ),
        ),
      ),
    );
  }
}
