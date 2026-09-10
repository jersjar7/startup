import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Grade Sense — the third item for `straight-lines-quadratics`.
///
/// Rank three stretches of road by grade, steepest first. No division is
/// asked for and none is needed: the numbers are chosen so the ordering is a
/// judgement about rise over run. The lesson's own trap is built into the
/// labels, because a run written as a station reads as three feet to anyone
/// who has not learned to read it.
class GradeSenseGame extends StatefulWidget {
  const GradeSenseGame({super.key});

  @override
  State<GradeSenseGame> createState() => _GradeSenseGameState();
}

@immutable
class Stretch {
  const Stretch({
    required this.name,
    required this.rise,
    required this.run,
    required this.runLabel,
  });

  final String name;
  final double rise;

  /// The true run in feet, which is what grade is measured against.
  final double run;

  /// How the run is written on the card: a station, or plain feet.
  final String runLabel;

  double get grade => rise / run;

  /// What the run looks like to somebody who reads "3+00" as three.
  double get naiveRun {
    final plus = runLabel.indexOf('+');
    if (plus < 0) return run;
    return double.parse(runLabel.substring(0, plus));
  }
}

@immutable
class GradeRound {
  const GradeRound({required this.prompt, required this.stretches});

  final String prompt;
  final List<Stretch> stretches;

  /// Indices ordered steepest first.
  List<int> get answer {
    final idx = [for (var i = 0; i < stretches.length; i++) i];
    idx.sort((a, b) => stretches[b].grade.compareTo(stretches[a].grade));
    return idx;
  }

  List<int> get byRiseAlone {
    final idx = [for (var i = 0; i < stretches.length; i++) i];
    idx.sort((a, b) => stretches[b].rise.compareTo(stretches[a].rise));
    return idx;
  }

  List<int> get byNaiveStation {
    final idx = [for (var i = 0; i < stretches.length; i++) i];
    idx.sort(
      (a, b) => (stretches[b].rise / stretches[b].naiveRun).compareTo(
        stretches[a].rise / stretches[a].naiveRun,
      ),
    );
    return idx;
  }
}

/// Exposed for tests: each round must have exactly one correct order.
/// Exposed for tests: each round must have exactly one correct order.
///
/// Every set mixes stations with a run written in plain feet. Written entirely
/// in stations, misreading them divides every run by the same 100 and the
/// ranking survives, so the trap the lesson names would never bite.
const gradeRounds = <GradeRound>[
  GradeRound(
    prompt:
        'Three stretches of the same centerline. Rank them by grade, '
        'steepest first.',
    stretches: [
      Stretch(name: 'A', rise: 6, run: 300, runLabel: '3+00'),
      Stretch(name: 'B', rise: 6, run: 100, runLabel: '100 ft'),
      Stretch(name: 'C', rise: 3, run: 300, runLabel: '3+00'),
    ],
  ),
  GradeRound(
    prompt: 'Same rise on all three. Only the run changes.',
    stretches: [
      Stretch(name: 'A', rise: 8, run: 400, runLabel: '4+00'),
      Stretch(name: 'B', rise: 8, run: 200, runLabel: '200 ft'),
      Stretch(name: 'C', rise: 8, run: 800, runLabel: '8+00'),
    ],
  ),
  GradeRound(
    prompt: 'Two are written as stations, one in feet. Rank by grade.',
    stretches: [
      Stretch(name: 'A', rise: 5, run: 250, runLabel: '2+50'),
      Stretch(name: 'B', rise: 5, run: 100, runLabel: '100 ft'),
      Stretch(name: 'C', rise: 10, run: 1000, runLabel: '10+00'),
    ],
  ),
  GradeRound(
    prompt: 'An access drive, a collector and a ramp.',
    stretches: [
      Stretch(name: 'Drive', rise: 12, run: 150, runLabel: '150 ft'),
      Stretch(name: 'Collector', rise: 9, run: 900, runLabel: '9+00'),
      Stretch(name: 'Ramp', rise: 20, run: 500, runLabel: '5+00'),
    ],
  ),
  GradeRound(
    prompt: 'The biggest rise is not the steepest road.',
    stretches: [
      Stretch(name: 'A', rise: 30, run: 3000, runLabel: '30+00'),
      Stretch(name: 'B', rise: 4, run: 100, runLabel: '100 ft'),
      Stretch(name: 'C', rise: 15, run: 750, runLabel: '7+50'),
    ],
  ),
  GradeRound(
    prompt: 'Last one. Read every run carefully.',
    stretches: [
      Stretch(name: 'A', rise: 7, run: 700, runLabel: '7+00'),
      Stretch(name: 'B', rise: 7, run: 350, runLabel: '350 ft'),
      Stretch(name: 'C', rise: 21, run: 700, runLabel: '7+00'),
    ],
  ),
];

class _GradeSenseGameState extends State<GradeSenseGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'grade-sense',
    chapterId: 'mathematics',
    total: gradeRounds.length,
    // Authored from the lesson's road-grade problem and its station trap.
    sourceProblemIdOf: (_) => 'math-slq-q1',
  )..addListener(_onSession);

  final List<int> _order = [];

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  GradeRound get _round => gradeRounds[_session.round];

  bool get _complete => _order.length == _round.stretches.length;

  void _tap(int i) {
    setState(() {
      if (_order.contains(i)) {
        _order.removeRange(_order.indexOf(i), _order.length);
      } else {
        _order.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Grade Sense',
        closing:
            'Grade is rise over run, and a station is hundreds of feet: '
            '3+00 is 300 feet, never 3. Getting the order right is not the '
            'same as computing a grade to two decimals, which is desk work.',
      );
    }

    final answered = _session.answered;

    return BoardShell(
      session: _session,
      brief: gradeBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock the order',
      onButton: answered
          ? () {
              setState(_order.clear);
              _session.next();
            }
          : (!_complete
                ? null
                : () => _session.submit(
                    ok: _listEquals(_order, _round.answer),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STEEPEST FIRST',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            _round.prompt,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap them in order. Tap one again to clear back to it.',
            style: const TextStyle(fontSize: 13, color: AppColors.ink2),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _round.stretches.length; i++) ...[
            _StretchCard(
              stretch: _round.stretches[i],
              rank: _order.contains(i) ? _order.indexOf(i) + 1 : null,
              truth: answered ? _round.answer.indexOf(i) + 1 : null,
              wrong: answered && !_session.correct!,
              onTap: answered ? null : () => _tap(i),
            ),
            const SizedBox(height: 10),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THE ORDER',
              body: _explain(),
            ),
          ],
        ],
      ),
    );
  }

  String _explain() {
    final r = _round;
    if (_session.correct!) {
      final steep = r.stretches[r.answer.first];
      return 'Steepest is ${steep.name}: ${_pct(steep)}. Grade is rise over '
          'run, so a short run with the same rise is always the steeper road.';
    }
    if (_listEquals(_order, r.byNaiveStation) &&
        !_listEquals(r.byNaiveStation, r.answer)) {
      return 'That is the order you get by reading a station as a plain '
          'number. 3+00 means 300 feet, not 3. Convert the stations first, '
          'then compare.';
    }
    if (_listEquals(_order, r.byRiseAlone) &&
        !_listEquals(r.byRiseAlone, r.answer)) {
      return 'That is the order by rise alone. The longest run flattens the '
          'biggest rise, so you have to weigh them against each other.';
    }
    final steep = r.stretches[r.answer.first];
    return 'The correct order is marked. ${steep.name} is steepest at '
        '${_pct(steep)}.';
  }

  String _pct(Stretch s) {
    final pct = s.grade * 100;
    final text = pct == pct.roundToDouble()
        ? pct.toStringAsFixed(0)
        : pct.toStringAsFixed(1);
    return '$text percent';
  }

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _StretchCard extends StatelessWidget {
  const _StretchCard({
    required this.stretch,
    required this.rank,
    required this.truth,
    required this.wrong,
    required this.onTap,
  });

  final Stretch stretch;

  /// Where the student has placed it, if anywhere.
  final int? rank;

  /// Where it actually belongs, shown once the round is answered.
  final int? truth;
  final bool wrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final show = truth ?? rank;
    final Color border;
    if (truth != null) {
      border = wrong ? AppColors.error : AppColors.forest;
    } else if (rank != null) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              _RankBadge(
                value: show,
                color: truth != null
                    ? (wrong ? AppColors.error : AppColors.forest)
                    : AppColors.ember,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stretch.name,
                      style: AppTheme.heading(size: 16, height: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'rise ${_trim(stretch.rise)} ft · run ${stretch.runLabel}',
                      style: AppTheme.mono(size: 12.5, color: AppColors.ink2),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.value, required this.color});

  final int? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: value == null ? Colors.transparent : color,
        border: Border.all(
          color: value == null ? AppColors.line : color,
          width: 1.5,
        ),
      ),
      child: value == null
          ? null
          : Text(
              '$value',
              style: AppTheme.mono(
                size: 15,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
    );
  }
}

/// A plain road-profile mark. Deliberately the same on every card: the ranking
/// has to come from the numbers, not from a picture that gives it away.
