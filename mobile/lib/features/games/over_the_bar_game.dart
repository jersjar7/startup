import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Over the Bar — the second item for `rate-of-return`.
///
/// The accept-or-reject rule is one comparison, and both traps the lesson
/// names are refusals to make it. One accepts anything with a positive return,
/// as though earning three percent were the same as earning enough. The other
/// invents a close-enough rule for a project that misses by a point.
///
/// A hurdle is a line, so it is drawn as one. Every project's return runs at it
/// as a bar and the question is who gets over, which makes a near miss look
/// like exactly what it is. Two of the six rounds turn on a project sitting
/// precisely ON the line, which clears: at that rate the project breaks even
/// and nothing is lost by doing it.
class OverTheBarGame extends StatefulWidget {
  const OverTheBarGame({super.key});

  @override
  State<OverTheBarGame> createState() => _OverTheBarGameState();
}

@immutable
class HurdleRound {
  const HurdleRound({
    required this.subject,
    required this.setting,
    required this.marr,
    required this.projects,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// The minimum the money has to earn, in whole percent.
  final int marr;

  /// Each candidate and the return it came back with.
  final List<(String, double)> projects;
  final String why;
  final String source;

  /// Worked out rather than declared: accept at or above the hurdle.
  List<int> get answer => [
        for (var i = 0; i < projects.length; i++)
          if (projects[i].$2 >= marr) i,
      ];

  /// Where the axis ends, with room past whichever is furthest right.
  double get span {
    var most = marr.toDouble();
    for (final (_, rate) in projects) {
      if (rate > most) most = rate;
    }
    return most + 7;
  }
}

/// The row that says nobody got over. Every round offers it, so a board where
/// the answer is "none of them" is possible without being announced.
const nobodyClears = 'None of them clears it';

const hurdleRounds = <HurdleRound>[
  HurdleRound(
    subject: 'four capital projects, one budget',
    setting:
        'The county sets its minimum at fifteen percent this year. Three '
        'proposals come back from the consultants.',
    marr: 15,
    projects: [
      ('Interchange', 18),
      ('Bridge', 12),
      ('Pumps', 15),
    ],
    why:
        'The interchange clears and so does the pump station, which lands '
        'exactly on fifteen. At the hurdle a project earns precisely what the '
        'money was required to earn, so it breaks even in time-value terms and '
        'the rule accepts it. The bridge deck at twelve does not.',
    source: 'econ-ror-q2',
  ),
  HurdleRound(
    subject: 'three ways to spend a facilities budget',
    setting:
        'The authority will not put money into anything earning less than ten '
        'percent.',
    marr: 10,
    projects: [
      ('Solar', 3),
      ('Roof', 14),
      ('Meters', 9),
    ],
    why:
        'Only the roof. The array earns three percent, which is a positive '
        'return and still a rejection: the money is required to earn ten, and '
        'earning something is not the test. The meter swap at nine fails for '
        'the same reason with a smaller margin.',
    source: 'econ-ror-q2',
  ),
  HurdleRound(
    subject: 'a near miss and a comfortable pass',
    setting:
        'Twelve percent is the hurdle. The levee comes back at eleven and the '
        'engineer wants to know whether that is close enough.',
    marr: 12,
    projects: [
      ('Levee', 11),
      ('Culvert', 12),
      ('Trail', 8),
    ],
    why:
        'The culvert lining, and nothing else. Eleven against a twelve percent '
        'hurdle is a rejection, not a rounding error: it says the money earns '
        'less here than it is required to earn, and the size of the shortfall '
        'does not change the answer. There is no close-enough rule.',
    source: 'econ-ror-q2',
  ),
  HurdleRound(
    subject: 'a year when nothing is worth doing',
    setting:
        'Borrowing costs have risen and the board has moved its minimum to '
        'twenty percent. The same three proposals are back.',
    marr: 20,
    projects: [
      ('Transit', 18),
      ('Garage', 12),
      ('Plaza', 6),
    ],
    why:
        'None of them. The transit center at eighteen was accepted at last '
        'year\'s hurdle and is rejected at this one, which is the point of '
        'having a hurdle: it is a property of the money, not of the project. '
        'Rejecting everything is a real answer.',
    source: 'econ-ror-q2',
  ),
  HurdleRound(
    subject: 'four items on a water system',
    setting:
        'Eight percent is the minimum. Four items were evaluated separately, '
        'and any of them can be done on its own.',
    marr: 8,
    projects: [
      ('Main', 8),
      ('Valves', 19),
      ('Hydrants', 7),
      ('Billing', 11),
    ],
    why:
        'Three of the four. The main sits on the hurdle and clears, the '
        'hydrant program at seven misses by a point and does not. These are '
        'independent rather than mutually exclusive, so every one that clears '
        'gets done and there is no choosing between them.',
    source: 'econ-ror-q2',
  ),
  HurdleRound(
    subject: 'one that earns nothing at all',
    setting:
        'Twelve percent again. The fountain returns exactly what it cost, with '
        'nothing over.',
    marr: 12,
    projects: [
      ('Fountain', 0),
      ('Repaving', 16),
      ('Drainage', 12),
    ],
    why:
        'Repaving and drainage. A project that hands back exactly what went in '
        'has a return of zero, not of nothing: it earned no interest at all, '
        'so it fails a hurdle of twelve as clearly as it would fail one of two.',
    source: 'econ-ror-q1',
  ),
];

class _OverTheBarGameState extends State<OverTheBarGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'over-the-bar',
    chapterId: 'economics',
    total: hurdleRounds.length,
    sourceProblemIdOf: (round) => hurdleRounds[round].source,
  )..addListener(_onSession);

  final _picked = <int>{};
  bool _nobody = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  HurdleRound get _round => hurdleRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Over the Bar',
        closing:
            'Accept at or above the hurdle, reject below it. On the line is '
            'an acceptance, because the project earns exactly what the money '
            'was required to earn. A positive return is not a pass, a near '
            'miss is not a pass, and a year can go by with nothing clearing.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final truth = r.answer.toSet();

    return BoardShell(
      session: _session,
      brief: marrBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _picked.clear();
                _nobody = false;
              });
              _session.next();
            }
          : (_picked.isEmpty && !_nobody
                ? null
                : () => _session.submit(
                    ok: _nobody
                        ? truth.isEmpty
                        : _picked.length == truth.length &&
                            _picked.containsAll(truth),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHO GETS OVER IT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'tap everyone to accept, which may be nobody',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          _Chart(
            round: r,
            picked: _picked,
            locked: answered,
            truth: truth,
            onTap: answered
                ? null
                : (i) => setState(() {
                      _nobody = false;
                      if (!_picked.add(i)) _picked.remove(i);
                    }),
          ),
          const SizedBox(height: 8),
          _NobodyRow(
            selected: _nobody,
            locked: answered,
            isTruth: truth.isEmpty,
            onTap: answered
                ? null
                : () => setState(() {
                      _picked.clear();
                      _nobody = !_nobody;
                    }),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE LIST' : 'NOT THAT LIST',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The projects as bars, with the hurdle drawn across all of them.
///
/// The bar and the line have to be one picture. Printed as a column of numbers
/// beside a stated minimum, a project missing by a point looks like a project
/// that nearly qualified, and it is not one.
class _Chart extends StatelessWidget {
  const _Chart({
    required this.round,
    required this.picked,
    required this.locked,
    required this.truth,
    required this.onTap,
  });

  final HurdleRound round;
  final Set<int> picked;
  final bool locked;
  final Set<int> truth;
  final void Function(int)? onTap;

  /// Everything left of the bars: the box, the name and the return. Fixed so
  /// that every bar in the round starts at the same place.
  static const _gutter = 152.0;

  /// Breathing room at the right-hand end, so a bar at the top of the axis
  /// does not run into the edge of the card.
  static const _tail = 10.0;

  static const _rowHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // ONE number for the length of a full bar. The chart drew the hurdle
        // from one scale and the rows drew their bars from another, which put
        // a project sitting exactly ON the hurdle visibly short of it.
        final barFull = box.maxWidth - _gutter - _tail;
        final marrX = _gutter + round.marr / round.span * barFull;

        return SizedBox(
          height: 18 + round.projects.length * _rowHeight,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 18,
                child: Column(
                  children: [
                    for (var i = 0; i < round.projects.length; i++)
                      _BarRow(
                        key: ValueKey('project-$i'),
                        name: round.projects[i].$1,
                        rate: round.projects[i].$2,
                        span: round.span,
                        gutter: _gutter,
                        barFull: barFull,
                        height: _rowHeight,
                        selected: picked.contains(i),
                        locked: locked,
                        isTruth: truth.contains(i),
                        onTap: onTap == null ? null : () => onTap!(i),
                      ),
                  ],
                ),
              ),
              // The hurdle. Drawn over the bars so that a bar ending short of
              // it cannot be mistaken for one reaching it.
              Positioned(
                left: marrX,
                top: 16,
                bottom: 0,
                child: Container(width: 1.8, color: AppColors.ember),
              ),
              Positioned(
                left: marrX - 40,
                top: 0,
                width: 80,
                child: Text(
                  'MARR ${round.marr}%',
                  textAlign: TextAlign.center,
                  style: AppTheme.overline(color: AppColors.ember),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({
    super.key,
    required this.name,
    required this.rate,
    required this.span,
    required this.gutter,
    required this.barFull,
    required this.height,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String name;
  final double rate;
  final double span;
  final double gutter;
  final double barFull;
  final double height;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color colour;
    if (locked && isTruth) {
      colour = AppColors.forest;
    } else if (locked && selected) {
      colour = AppColors.error;
    } else if (selected) {
      colour = AppColors.ember;
    } else {
      colour = AppColors.ink2;
    }
    final marked = selected || (locked && isTruth);

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: marked ? colour : null,
                  border: Border.all(
                    color: marked ? colour : AppColors.line,
                  ),
                ),
                child: marked
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: gutter - 28,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, color: colour),
                    ),
                  ),
                  // The return goes here rather than at the end of its own
                  // bar. At the end it landed under the hurdle line on
                  // exactly the rounds worth reading.
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${rate.toStringAsFixed(0)}%',
                      textAlign: TextAlign.right,
                      style: AppTheme.mono(size: 10.5, color: colour),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Container(
              height: 20,
              width: (rate / span * barFull).clamp(1.5, 1e4),
              decoration: BoxDecoration(
                color: colour.withValues(alpha: marked ? 0.35 : 0.18),
                border: Border.all(color: colour, width: marked ? 1.4 : 1),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(3),
                  right: Radius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NobodyRow extends StatelessWidget {
  const _NobodyRow({
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
      key: const ValueKey('nobody'),
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
            nobodyClears,
            style: const TextStyle(fontSize: 14.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
