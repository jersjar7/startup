import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'clarifier_figures.dart';

/// What Moves the Ratio — the third item for `water-treatment`.
///
/// The food to microorganism ratio is exactly what its name says: the
/// organic load arriving each day over the mass of bugs available to eat it.
/// Everything about how an activated sludge plant is run comes back to
/// holding that ratio in a band, and the only way to see which lever does
/// what is to notice which of the four quantities sits on top and which
/// underneath.
class WhatMovesTheRatioGame extends StatefulWidget {
  const WhatMovesTheRatioGame({super.key});

  @override
  State<WhatMovesTheRatioGame> createState() =>
      _WhatMovesTheRatioGameState();
}

/// Where the ratio goes.
enum Ratio3 { up, down, same }

extension Ratio3Words on Ratio3 {
  String get plain => switch (this) {
        Ratio3.up => 'The ratio goes up: more food per bug',
        Ratio3.down => 'The ratio comes down: more bugs per unit of food',
        Ratio3.same => 'No change at all',
      };
}

@immutable
class RatioRound {
  const RatioRound({
    required this.subject,
    required this.change,
    required this.flow,
    required this.strength,
    required this.volume,
    required this.solids,
    required this.why,
    required this.source,
  });

  final String subject;
  final String change;

  /// The four quantities, before and after, as (before, after) pairs.
  final (double, double) flow;
  final (double, double) strength;
  final (double, double) volume;
  final (double, double) solids;
  final String why;
  final String source;

  double get before =>
      flow.$1 * strength.$1 / (volume.$1 * solids.$1);

  double get after => flow.$2 * strength.$2 / (volume.$2 * solids.$2);

  /// Worked out of the four numbers, never declared.
  Ratio3 get answer {
    if ((after - before).abs() / before < 0.001) return Ratio3.same;
    return after > before ? Ratio3.up : Ratio3.down;
  }
}

const fmRounds = <RatioRound>[
  RatioRound(
    subject: 'a stronger wastewater',
    change:
        'The influent BOD climbs from 200 to 300 mg/L. The flow, the basin '
        'and the mixed liquor are unchanged.',
    flow: (4000, 4000),
    strength: (200, 300),
    volume: (2000, 2000),
    solids: (3000, 3000),
    why:
        'Up, by half. The influent BOD is the FOOD, on the top of the ratio, '
        'so more of it arriving means more food per bug. The plant\'s answer '
        'is to grow more bugs, which takes time, and in the meantime the '
        'ratio sits above where it should be and the effluent suffers. This '
        'is what a strong industrial discharge does to a works overnight.',
    source: 'wr-wt-q2',
  ),
  RatioRound(
    subject: 'carrying more mixed liquor',
    change:
        'The operator raises the MLSS from 3,000 to 4,500 mg/L by wasting '
        'less sludge. Everything else is unchanged.',
    flow: (4000, 4000),
    strength: (200, 200),
    volume: (2000, 2000),
    solids: (3000, 4500),
    why:
        'Down, by a third. The mixed liquor solids are the MICROORGANISMS, '
        'underneath, so carrying more of them spreads the same food over more '
        'mouths. This is the operator\'s main lever: wasting less builds the '
        'population and pulls the ratio down, and it is why the waste rate is '
        'adjusted a little at a time rather than all at once.',
    source: 'wr-wt-q2',
  ),
  RatioRound(
    subject: 'a bigger basin',
    change:
        'A second aeration basin is brought online, doubling the volume from '
        '2,000 to 4,000 cubic meters at the same mixed liquor concentration.',
    flow: (4000, 4000),
    strength: (200, 200),
    volume: (2000, 4000),
    solids: (3000, 3000),
    why:
        'Down, by half. Volume sits underneath alongside the MLSS, and for '
        'good reason: what actually matters is the MASS of bugs in the plant, '
        'which is the concentration times the volume. Twice the tank at the '
        'same concentration is twice the biomass, and the same food spread '
        'over twice as many of them.',
    source: 'wr-wt-q2',
  ),
  RatioRound(
    subject: 'a busy morning',
    change:
        'The flow rises from 4,000 to 6,000 cubic meters a day at the same '
        'influent strength.',
    flow: (4000, 6000),
    strength: (200, 200),
    volume: (2000, 2000),
    solids: (3000, 3000),
    why:
        'Up, by half. Flow is on the top with the strength, because the two '
        'of them together are the LOAD: kilograms of BOD arriving each day. '
        'More water at the same strength is more kilograms, and the bugs have '
        'more to get through.',
    source: 'wr-wt-q2',
  ),
  RatioRound(
    subject: 'a rainy day',
    change:
        'Storm water doubles the flow to 8,000 cubic meters a day and halves '
        'the influent BOD to 100 mg/L. Nothing else changes.',
    flow: (4000, 8000),
    strength: (200, 100),
    volume: (2000, 2000),
    solids: (3000, 3000),
    why:
        'No change. Twice the flow at half the strength is the same load: '
        'the same kilograms of BOD a day arriving, only more dilute. The '
        'ratio has Q times S on top and cares about the product, not about '
        'either one on its own. What the storm HAS done is halve the '
        'hydraulic time, which is a different problem and a real one.',
    source: 'wr-wt-q2',
  ),
  RatioRound(
    subject: 'wasting harder',
    change:
        'The waste pump is turned up and the mixed liquor falls from 3,000 '
        'to 2,000 mg/L. The load and the basin are unchanged.',
    flow: (4000, 4000),
    strength: (200, 200),
    volume: (2000, 2000),
    solids: (3000, 2000),
    why:
        'Up, by half. Fewer bugs for the same food. Wasting harder shortens '
        'the solids residence time and lifts the ratio at the same stroke, '
        'and both of those move the plant toward a younger, faster-growing '
        'sludge. Push it far enough and the sludge stops settling properly, '
        'which is how a clarifier ends up passing solids.',
    source: 'wr-wt-q2',
  ),
];

class _WhatMovesTheRatioGameState extends State<WhatMovesTheRatioGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-moves-the-ratio',
    chapterId: 'water-resources',
    total: fmRounds.length,
    sourceProblemIdOf: (round) => fmRounds[round].source,
  )..addListener(_onSession);

  Ratio3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RatioRound get _round => fmRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Moves the Ratio',
        closing:
            'Food over microorganisms, and the four quantities sort '
            'themselves by which side of the line they sit on. The flow and '
            'the influent strength are the food, and only their PRODUCT '
            'matters, so a storm that doubles one and halves the other '
            'changes nothing. The basin volume and the mixed liquor solids '
            'are the bugs, and their product is the biomass the plant is '
            'carrying.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: foodRatioBrief,
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
            'WHERE DOES THE RATIO GO',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 214,
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
                  painter: PlantPainter(
                    note: answered
                        ? 'F:M was ${r.before.toStringAsFixed(3)}, now '
                            '${r.after.toStringAsFixed(3)} per day'
                        : 'F:M ${r.before.toStringAsFixed(3)} per day before '
                            'the change',
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$F{:}M = \dfrac{Q S_0}{V X_A}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Ratio3.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Ratio3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHERE IT GOES' : 'THE OTHER WAY',
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
