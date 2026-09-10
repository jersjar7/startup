import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Match the Dollars — the third item for
/// `depreciation-taxation-inflation`.
///
/// Two traps, and they sit on top of each other. One is discounting
/// inflated dollars at the real rate, or the reverse, which throws the whole
/// present worth out. The other is building the adjusted rate by adding the
/// two rates and stopping, when there is a third term.
///
/// Both are visible in one question: which of these four rates do you discount
/// at. The added figure and the compounded figure are always both on the
/// board, a tenth of a point apart at small rates and most of a point apart at
/// large ones, and half the rounds say what kind of dollars they are in while
/// the other half only describe them.
class MatchTheDollarsGame extends StatefulWidget {
  const MatchTheDollarsGame({super.key});

  @override
  State<MatchTheDollarsGame> createState() => _MatchTheDollarsGameState();
}

/// The four numbers anybody could reach for.
enum Adjust { inflationOnly, real, sum, combined }

@immutable
class DollarsRound {
  const DollarsRound({
    required this.subject,
    required this.situation,
    required this.actual,
    required this.real,
    required this.inflation,
    required this.order,
    required this.why,
    required this.source,
  });

  final String subject;
  final String situation;

  /// True when the cash flows are in actual dollars, the money that will
  /// really change hands. False when they are in constant dollars, stated in
  /// today's purchasing power.
  final bool actual;

  /// The real interest rate, in whole percent.
  final double real;

  /// General inflation, in whole percent.
  final double inflation;

  /// The order the four rates are offered in, so the answer is not always in
  /// the same place.
  final List<Adjust> order;

  final String why;
  final String source;

  double valueOf(Adjust a) => switch (a) {
        Adjust.inflationOnly => inflation,
        Adjust.real => real,
        Adjust.sum => real + inflation,
        Adjust.combined =>
          real + inflation + real * inflation / 100,
      };

  /// Worked out rather than declared: actual dollars carry inflation in them
  /// already, so they meet the compounded rate. Constant dollars have had it
  /// taken out, so they meet the real one.
  int get answer => order.indexOf(actual ? Adjust.combined : Adjust.real);
}

const dollarsRounds = <DollarsRound>[
  DollarsRound(
    subject: 'a ten year project',
    situation:
        'An engineer is discounting a ten year stream whose cash flows are '
        'stated in actual dollars. The real interest rate is four percent and '
        'general inflation is running at three.',
    actual: true,
    real: 4,
    inflation: 3,
    order: [Adjust.inflationOnly, Adjust.real, Adjust.sum, Adjust.combined],
    why:
        'Actual dollars already have inflation baked into them, so they have '
        'to be discounted at the rate that has inflation in it too. And that '
        'rate is not the two added: there is a third term, four times three '
        'over a hundred, which is why it comes to 7.12 and not 7.00.',
    source: 'econ-dti-q3',
  ),
  DollarsRound(
    subject: 'a planning estimate',
    situation:
        'The planner has worked the whole twenty year estimate in constant '
        'dollars, at today\'s purchasing power. The real rate is four percent '
        'and inflation is three.',
    actual: false,
    real: 4,
    inflation: 3,
    order: [Adjust.sum, Adjust.real, Adjust.combined, Adjust.inflationOnly],
    why:
        'Constant dollars have had inflation taken out of them already, so '
        'putting it back through the discount rate charges for it twice. Same '
        'two rates as the round before and a different answer, because what '
        'changed is the dollars rather than the economy.',
    source: 'econ-dti-q3',
  ),
  DollarsRound(
    subject: 'a supply contract that escalates',
    situation:
        'The contract escalates its prices with an index running at eight '
        'percent a year, and the figures in the schedule are the amounts that '
        'will actually be invoiced. Money is worth ten percent in real terms.',
    actual: true,
    real: 10,
    inflation: 8,
    order: [Adjust.combined, Adjust.sum, Adjust.real, Adjust.inflationOnly],
    why:
        'Amounts that will actually be invoiced are actual dollars, whatever '
        'the problem calls them. And this is where adding instead of '
        'compounding stops being a rounding difference: eight tenths of a '
        'point, on a stream that runs for years.',
    source: 'econ-dti-q3',
  ),
  DollarsRound(
    subject: 'a lease priced in the money of the day',
    situation:
        'A lease is quoted in the money that will actually change hands each '
        'year. The tenant\'s real cost of money is five percent and inflation '
        'is expected to run at twelve.',
    actual: true,
    real: 5,
    inflation: 12,
    order: [Adjust.real, Adjust.combined, Adjust.inflationOnly, Adjust.sum],
    why:
        'The money that changes hands is actual dollars. At rates this high '
        'the cross term is six tenths of a point on its own, and the real rate '
        'sitting at the top of the list is the answer to a different question '
        'entirely.',
    source: 'econ-dti-q3',
  ),
  DollarsRound(
    subject: 'a maintenance budget in today\'s money',
    situation:
        'Every maintenance figure in the study has been expressed in today\'s '
        'dollars so the years can be compared. The real rate is seven percent '
        'and inflation four.',
    actual: false,
    real: 7,
    inflation: 4,
    order: [Adjust.inflationOnly, Adjust.sum, Adjust.real, Adjust.combined],
    why:
        'Today\'s dollars are constant dollars, so the real rate is the one '
        'that matches them. Nothing about the four percent is wrong, it is '
        'just already accounted for by the way the figures were written down.',
    source: 'econ-dti-q3',
  ),
  DollarsRound(
    subject: 'a bond with fixed payments',
    situation:
        'The payments are fixed dollar amounts written into the bond and they '
        'do not move with anything. The real return wanted is three percent '
        'and inflation is running at five.',
    actual: true,
    real: 3,
    inflation: 5,
    order: [Adjust.sum, Adjust.combined, Adjust.inflationOnly, Adjust.real],
    why:
        'A fixed payment is the plainest actual dollar there is: it is the '
        'number on the check, and inflation eats it rather than moving it. '
        'Fixed does not mean constant, and those two words point in opposite '
        'directions here.',
    source: 'econ-dti-q3',
  ),
];

class _MatchTheDollarsGameState extends State<MatchTheDollarsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'match-the-dollars',
    chapterId: 'economics',
    total: dollarsRounds.length,
    sourceProblemIdOf: (round) => dollarsRounds[round].source,
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

  DollarsRound get _round => dollarsRounds[_session.round];

  static String _label(Adjust a) => switch (a) {
        Adjust.inflationOnly => 'the inflation rate',
        Adjust.real => 'the real rate',
        Adjust.sum => 'the two rates added',
        Adjust.combined => 'the two rates compounded',
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Match the Dollars',
        closing:
            'Match the rate to the dollars. Money that will really change '
            'hands has inflation in it and meets the compounded rate; figures '
            'written in today\'s purchasing power have had it removed and meet '
            'the real one. And the compounded rate has three terms, not two.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: inflationBrief,
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
            'DISCOUNT AT WHICH RATE',
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
          const SizedBox(height: 14),
          for (var i = 0; i < r.order.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _RateRow(
              key: ValueKey('adjust-${r.order[i].name}'),
              label: _label(r.order[i]),
              value: '${r.valueOf(r.order[i]).toStringAsFixed(2)}%',
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            Text(
              r.actual ? 'ACTUAL DOLLARS' : 'CONSTANT DOLLARS',
              style: AppTheme.overline(color: AppColors.ink3),
            ),
            const SizedBox(height: 4),
            Text(
              r.actual
                  ? 'd = ${_n(r.real)} + ${_n(r.inflation)} + '
                      '${_n(r.real)}(${_n(r.inflation)})/100 = '
                      '${r.valueOf(Adjust.combined).toStringAsFixed(2)}%'
                  : 'i = ${r.real.toStringAsFixed(2)}%, and inflation stays '
                      'out of it',
              style: AppTheme.code(size: 12),
            ),
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT RATE' : 'A DIFFERENT RATE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }

  static String _n(double v) => v.toStringAsFixed(0);
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    super.key,
    required this.label,
    required this.value,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final String value;
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
          width: double.infinity,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              Text(value, style: AppTheme.code(size: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
