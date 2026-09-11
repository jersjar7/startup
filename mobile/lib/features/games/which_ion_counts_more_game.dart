import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'standards_figures.dart';

/// Which Ion Counts More — the second item for `water-quality-standards`.
///
/// Hardness is reported as calcium carbonate so that different ions can be
/// added together, and the conversion is 50 over the ion's own equivalent
/// weight. That makes magnesium count for more than calcium, milligram for
/// milligram, because magnesium is the lighter ion: 4.12 against 2.5. Adding
/// the raw concentrations without converting is the mistake the lesson
/// names, and it understates the hardness every time.
class WhichIonCountsMoreGame extends StatefulWidget {
  const WhichIonCountsMoreGame({super.key});

  @override
  State<WhichIonCountsMoreGame> createState() =>
      _WhichIonCountsMoreGameState();
}

/// Which ion contributes more hardness once both are converted.
enum Counts { first, second, level }

extension CountsWords on Counts {
  String plainFor(List<Ion> ions) => switch (this) {
        Counts.first => 'The ${ions.first.name.toLowerCase()}',
        Counts.second => 'The ${ions.last.name.toLowerCase()}',
        Counts.level => 'Neither: they contribute the same',
      };
}

@immutable
class IonRound {
  const IonRound({
    required this.subject,
    required this.ions,
    required this.why,
    required this.source,
  });

  final String subject;
  final List<Ion> ions;
  final String why;
  final String source;

  /// Worked out of the conversion, never declared.
  Counts get answer {
    final a = ions.first.asCaCO3;
    final b = ions.last.asCaCO3;
    if ((a - b).abs() / b < 0.02) return Counts.level;
    return a > b ? Counts.first : Counts.second;
  }
}

const ionRounds = <IonRound>[
  IonRound(
    subject: 'the lesson\'s own sample',
    ions: [
      Ion(name: 'Calcium', concentration: 40, equivalentWeight: 20),
      Ion(name: 'Magnesium', concentration: 24.3, equivalentWeight: 12.15),
    ],
    why:
        'Neither: both come to exactly 100 mg/L as calcium carbonate, for a '
        'total of 200 and a very hard water. Note how the raw numbers '
        'mislead: 40 of calcium against 24.3 of magnesium looks lopsided, and '
        'after conversion they are level, because magnesium is converted at '
        '4.12 and calcium at 2.5. Adding the raw figures gives 64.3, which is '
        'the wrong answer the lesson offers.',
    source: 'wr-wqs-q1',
  ),
  IonRound(
    subject: 'equal amounts of each',
    ions: [
      Ion(name: 'Calcium', concentration: 30, equivalentWeight: 20),
      Ion(name: 'Magnesium', concentration: 30, equivalentWeight: 12.15),
    ],
    why:
        'The magnesium, by two thirds again. Milligram for milligram '
        'magnesium always counts for more, because the conversion is 50 over '
        'the equivalent weight and magnesium\'s is the smaller: it is a '
        'lighter ion, so a given mass of it is more ions and more charge to '
        'be neutralized. That is the whole reason the two get different '
        'multipliers.',
    source: 'wr-wqs-q1',
  ),
  IonRound(
    subject: 'a limestone groundwater',
    ions: [
      Ion(name: 'Calcium', concentration: 88, equivalentWeight: 20),
      Ion(name: 'Magnesium', concentration: 12, equivalentWeight: 12.15),
    ],
    why:
        'The calcium, and by a long way: 220 against 49. Water out of '
        'limestone is calcium dominated, which is the commonest kind of hard '
        'water there is, and the total of 269 puts it well into the very hard '
        'band. Softening plants in limestone country are designed around '
        'calcium first.',
    source: 'wr-wqs-q1',
  ),
  IonRound(
    subject: 'a dolomite aquifer',
    ions: [
      Ion(name: 'Calcium', concentration: 20, equivalentWeight: 20),
      Ion(name: 'Magnesium', concentration: 30, equivalentWeight: 12.15),
    ],
    why:
        'The magnesium, 123 against 50. Dolomite is a calcium magnesium '
        'carbonate, so water from it carries a good deal of magnesium, and '
        'the conversion widens the gap that the raw numbers already showed. '
        'Magnesium hardness is the more troublesome half to remove, which is '
        'why the split is worth knowing and not just the total.',
    source: 'wr-wqs-q1',
  ),
  IonRound(
    subject: 'a soft surface water',
    ions: [
      Ion(name: 'Calcium', concentration: 12, equivalentWeight: 20),
      Ion(name: 'Magnesium', concentration: 7.3, equivalentWeight: 12.15),
    ],
    why:
        'Neither: 30 each, for a total of 60, right at the line between soft '
        'and moderately hard. Surface water off granite is typically like '
        'this, and it needs no softening at all. The bands are worth '
        'carrying: under 60 soft, 60 to 120 moderately hard, 120 to 180 hard, '
        'and over 180 very hard.',
    source: 'wr-wqs-q1',
  ),
  IonRound(
    subject: 'reading the raw numbers',
    ions: [
      Ion(name: 'Calcium', concentration: 50, equivalentWeight: 20),
      Ion(name: 'Magnesium', concentration: 32, equivalentWeight: 12.15),
    ],
    why:
        'The magnesium, 132 against 125, and this is the round to be caught '
        'by. Fifty of calcium against thirty-two of magnesium looks like a '
        'clear calcium water on the raw figures, and after conversion the '
        'magnesium is the larger contributor. The conversion can reverse the '
        'order, which is exactly why it has to be done before anything is '
        'compared or added.',
    source: 'wr-wqs-q1',
  ),
];

class _WhichIonCountsMoreGameState extends State<WhichIonCountsMoreGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-ion-counts-more',
    chapterId: 'water-resources',
    total: ionRounds.length,
    sourceProblemIdOf: (round) => ionRounds[round].source,
  )..addListener(_onSession);

  Counts? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  IonRound get _round => ionRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Ion Counts More',
        closing:
            'Hardness is reported as calcium carbonate so that different '
            'ions can be added on one basis, and the conversion is 50 over '
            'the ion\'s equivalent weight: 2.5 for calcium and 4.12 for '
            'magnesium. Magnesium therefore counts for more milligram for '
            'milligram, the conversion can reverse which ion dominates, and '
            'adding the raw concentrations understates the hardness every '
            'time.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: hardnessBrief,
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
            'WHICH CONTRIBUTES MORE HARDNESS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          const Text(
            'The bars are the raw concentrations as they come out of the '
            'laboratory. Hardness is reported on a calcium carbonate basis.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 196,
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
                      HardnessPainter(ions: r.ions, converted: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{as CaCO}_3 = C \times \dfrac{50}{EW}$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Counts.values) ...[
            _Choice(
              label: option.plainFor(r.ions),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Counts.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE BIGGER SHARE' : 'THE OTHER ONE',
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
