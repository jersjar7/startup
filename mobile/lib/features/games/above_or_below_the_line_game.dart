import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'soil_class_figures.dart';

/// Above or Below the Line — the second item for `soil-classification`.
///
/// A fine-grained soil is classified by where its point lands on the
/// plasticity chart, and the chart is only two lines: the A-line, with clays
/// above it and silts below, and the liquid limit of 50, with high
/// plasticity to the right of it. Four quarters, four symbols. The
/// arithmetic of the A-line belongs on paper; reading the quarter does not.
class AboveOrBelowTheLineGame extends StatefulWidget {
  const AboveOrBelowTheLineGame({super.key});

  @override
  State<AboveOrBelowTheLineGame> createState() =>
      _AboveOrBelowTheLineGameState();
}

/// The four symbols the chart hands out.
enum Quarter { cl, ch, ml, mh }

@immutable
class ChartRound {
  const ChartRound({
    required this.subject,
    required this.asked,
    required this.fines,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Fines fines;
  final String why;
  final String source;

  /// The chart decides, so a round cannot claim a symbol its own point does
  /// not land on.
  Quarter get answer => switch (fines.symbol) {
        'CL' => Quarter.cl,
        'CH' => Quarter.ch,
        'ML' => Quarter.ml,
        _ => Quarter.mh,
      };

  static String label(Quarter which) => switch (which) {
        Quarter.cl => 'CL, a lean clay',
        Quarter.ch => 'CH, a fat clay',
        Quarter.ml => 'ML, a low plasticity silt',
        Quarter.mh => 'MH, a high plasticity silt',
      };
}

const chartRounds = <ChartRound>[
  ChartRound(
    subject: 'the lesson\'s own sample',
    asked:
        'Eighty per cent passes the No. 200, the liquid limit is 45 and the '
        'plasticity index is 22. What is it?',
    fines: Fines(liquidLimit: 45, plasticityIndex: 22),
    why:
        'CL, a lean clay. The point sits left of the liquid limit of 50, so '
        'it is low plasticity, and above the A-line, so it is a clay rather '
        'than a silt. Both halves of the symbol come straight off the chart, '
        'and neither needs anything worked out beyond finding the point.',
    source: 'geo-sc-q1',
  ),
  ChartRound(
    subject: 'the lesson\'s hard one',
    asked:
        'Sixty per cent passes the No. 200, the liquid limit is 55 and the '
        'plasticity index is 28. What is it?',
    fines: Fines(liquidLimit: 55, plasticityIndex: 28),
    why:
        'CH, a fat clay. Past a liquid limit of 50 the second letter becomes '
        'H, and the point is still above the A-line so the first letter stays '
        'C. The lesson offers CL as a distractor, which is the same soil with '
        'the liquid limit misread, and MH, which is the same point put on the '
        'wrong side of the A-line.',
    source: 'geo-sc-q3',
  ),
  ChartRound(
    subject: 'just under the line',
    asked:
        'A fine soil with a liquid limit of 40 and a plasticity index of 10. '
        'What is it?',
    fines: Fines(liquidLimit: 40, plasticityIndex: 10),
    why:
        'ML, a silt of low plasticity. Same side of the LL 50 boundary as the '
        'first round but BELOW the A-line this time, and that one difference '
        'changes what the soil is: a silt drains and settles quickly where a '
        'clay holds water and keeps moving for years. The chart is not '
        'labeling, it is behavior.',
    source: 'geo-sc-q1',
  ),
  ChartRound(
    subject: 'wet and not very plastic',
    asked:
        'A fine soil with a liquid limit of 62 and a plasticity index of 22. '
        'What is it?',
    fines: Fines(liquidLimit: 62, plasticityIndex: 22),
    why:
        'MH, an elastic silt. It holds a great deal of water before it '
        'behaves as a liquid, which is what a high liquid limit means, and '
        'yet the range between its two limits is narrow, which puts it under '
        'the A-line. High liquid limit does NOT mean clay: that is the '
        'quarter people forget exists.',
    source: 'geo-sc-q3',
  ),
  ChartRound(
    subject: 'close to the A-line',
    asked:
        'A liquid limit of 45 again, but this time a plasticity index of 15. '
        'What is it?',
    fines: Fines(liquidLimit: 45, plasticityIndex: 15),
    why:
        'ML. The A-line at a liquid limit of 45 sits at a plasticity index of '
        'about 18, so 15 is under it and the soil is a silt. Compare it with '
        'the first round: the same liquid limit, seven points of plasticity '
        'index between them, and a different material. Near the line, the '
        'index is worth reading carefully.',
    source: 'geo-sc-q1',
  ),
  ChartRound(
    subject: 'a long way up',
    asked:
        'A liquid limit of 70 and a plasticity index of 45. What is it?',
    fines: Fines(liquidLimit: 70, plasticityIndex: 45),
    why:
        'CH, and emphatically: high on the chart and well right of the LL 50 '
        'line. Soils up here are the ones that swell when they get wet and '
        'shrink when they dry, and they are the reason a classification is '
        'worth doing before anything is designed to sit on them.',
    source: 'geo-sc-q3',
  ),
];

class _AboveOrBelowTheLineGameState extends State<AboveOrBelowTheLineGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'above-or-below-the-line',
    chapterId: 'geotechnical',
    total: chartRounds.length,
    sourceProblemIdOf: (round) => chartRounds[round].source,
  )..addListener(_onSession);

  Quarter? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ChartRound get _round => chartRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Above or Below the Line',
        closing:
            'Two lines and four quarters. Above the A-line is a clay and '
            'below it is a silt, which is a statement about behavior rather '
            'than a name: silts drain and settle quickly, clays hold water '
            'and keep moving. Right of a liquid limit of 50 is high '
            'plasticity. A high liquid limit on its own does not make a clay, '
            'which is the quarter people forget is there.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: chartBrief,
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
            'WHERE DOES THE POINT LAND',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 222,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter:
                      PlasticityPainter(fines: r.fines, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{A-line: } PI = 0.73(LL - 20)$',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Quarter.values) ...[
            _Choice(
              label: ChartRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Quarter.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
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
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
