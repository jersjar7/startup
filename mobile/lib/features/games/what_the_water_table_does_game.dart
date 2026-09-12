import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'effective_stress_figures.dart';

/// What the Water Table Does — the second item for `effective-stress`.
///
/// The arithmetic of a stress profile belongs on paper. What belongs here is
/// the direction: pump the water table down and the grains take up the
/// slack, which is why dewatering settles a site; flood the surface and
/// nothing changes at all, because the water added weight and pressure in
/// equal measure. Each round moves one thing and asks which way the answer
/// goes.
class WhatTheWaterTableDoesGame extends StatefulWidget {
  const WhatTheWaterTableDoesGame({super.key});

  @override
  State<WhatTheWaterTableDoesGame> createState() =>
      _WhatTheWaterTableDoesGameState();
}

/// Which way the quantity in question moves.
enum Moves3 { up, down, same }

@immutable
class ChangeRound {
  const ChangeRound({
    required this.subject,
    required this.asked,
    required this.before,
    required this.after,
    required this.at,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;

  /// The profile as it stands and as it becomes, so the drawing can show
  /// the change rather than describe it.
  final Deposit before;
  final Deposit after;
  final double at;
  final Moves3 answer;
  final String why;
  final String source;

  static String label(Moves3 which) => switch (which) {
        Moves3.up => 'It goes up',
        Moves3.down => 'It goes down',
        Moves3.same => 'It does not change',
      };
}

const _high = Deposit(
  layers: [
    Stratum(name: 'sand', thickness: 6, unitWeight: 120, saturated: true),
    Stratum(name: 'clay', thickness: 10, unitWeight: 118, saturated: true),
  ],
  waterDepth: 0,
);

const _pumped = Deposit(
  layers: [
    Stratum(name: 'sand, drained', thickness: 6, unitWeight: 105),
    Stratum(name: 'clay', thickness: 10, unitWeight: 118, saturated: true),
  ],
  waterDepth: 6,
);

const _plain = Deposit(
  layers: [
    Stratum(name: 'sand', thickness: 6, unitWeight: 105),
    Stratum(name: 'clay', thickness: 10, unitWeight: 118, saturated: true),
  ],
  waterDepth: 6,
);

const _flooded = Deposit(
  layers: [
    Stratum(name: 'sand', thickness: 6, unitWeight: 120, saturated: true),
    Stratum(name: 'clay', thickness: 10, unitWeight: 118, saturated: true),
  ],
  waterDepth: 0,
  standing: 6,
);

const _loaded = Deposit(
  layers: [
    Stratum(name: 'sand', thickness: 6, unitWeight: 105),
    Stratum(name: 'clay', thickness: 10, unitWeight: 118, saturated: true),
  ],
  waterDepth: 6,
  surcharge: 400,
);

const tableMoveRounds = <ChangeRound>[
  ChangeRound(
    subject: 'pumping it down',
    asked:
        'The water table is pumped from the surface down to six feet. What '
        'happens to the WATER PRESSURE at the bottom of the clay?',
    before: _high,
    after: _pumped,
    at: 16,
    answer: Moves3.down,
    why:
        'Down. The pressure at a point is the height of water above it, and '
        'the top of that column has just been lowered six feet, so the '
        'pressure falls by six feet of water, around 375 pounds a square '
        'foot. Nothing about the soil has changed: only where the water '
        'starts.',
    source: 'geo-es-q2',
  ),
  ChangeRound(
    subject: 'and what the grains feel',
    asked:
        'The same pumping. What happens to the EFFECTIVE stress at that same '
        'point?',
    before: _high,
    after: _pumped,
    at: 16,
    answer: Moves3.up,
    why:
        'Up, and this is the most consequential sentence in the lesson. The '
        'total stress barely moves, since draining the sand makes it a little '
        'lighter at most, while the water pressure has dropped a long way, so '
        'what is left for the grains goes up. That is why dewatering a site '
        'settles it, and why pumping next door can crack a building that '
        'nobody has touched.',
    source: 'geo-es-q2',
  ),
  ChangeRound(
    subject: 'raising it instead',
    asked:
        'Now the other way: a wet season brings the water table back up to '
        'the surface. What happens to the effective stress down there?',
    before: _pumped,
    after: _high,
    at: 16,
    answer: Moves3.down,
    why:
        'Down. Buoyancy takes back the share it had lost, so the grains pass '
        'less to each other. It is the same mechanism as before, run '
        'backwards, and it is why a rising water table can be as awkward as a '
        'falling one: a slope that stood all summer can slide after a week of '
        'rain without anything being built on it.',
    source: 'geo-es-q2',
  ),
  ChangeRound(
    subject: 'a load on the surface',
    asked:
        'No pumping this time. Four hundred pounds a square foot of fill is '
        'spread over the whole site. What happens to the WATER PRESSURE deep '
        'in the clay, long after the fill has gone on?',
    before: _plain,
    after: _loaded,
    at: 16,
    answer: Moves3.same,
    why:
        'Unchanged. The water table has not moved, so the height of water '
        'above the point is what it was, and in the long run the pressure '
        'goes back to exactly that. Immediately after the fill goes on a clay '
        'does hold an excess pressure for a while, and squeezing that out '
        'over months is the whole of the consolidation lesson.',
    source: 'geo-es-q3',
  ),
  ChangeRound(
    subject: 'and what the fill does to the grains',
    asked: 'The same fill. What happens to the effective stress in the clay?',
    before: _plain,
    after: _loaded,
    at: 16,
    answer: Moves3.up,
    why:
        'Up, by the full weight of the fill. The surcharge adds to the total '
        'and nothing to the water, so all of it lands on the grains. This is '
        'why a surcharge is piled on a soft site on purpose: it drives the '
        'settlement that would otherwise happen under the building, and then '
        'it is taken away again.',
    source: 'geo-es-q3',
  ),
  ChangeRound(
    subject: 'a lake over the site',
    asked:
        'The site floods and stands under six feet of open water, with the '
        'ground already saturated. What happens to the effective stress in '
        'the clay?',
    before: _high,
    after: _flooded,
    at: 16,
    answer: Moves3.same,
    why:
        'Nothing at all, which surprises people every time. The standing '
        'water adds its weight to the total stress AND the same amount to the '
        'water pressure, and the two cancel exactly. That is why lakes do not '
        'consolidate their own beds, and it is the neatest demonstration '
        'going that only the difference between the two ever matters.',
    source: 'geo-es-q1',
  ),
];

class _WhatTheWaterTableDoesGameState
    extends State<WhatTheWaterTableDoesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-the-water-table-does',
    chapterId: 'geotechnical',
    total: tableMoveRounds.length,
    sourceProblemIdOf: (round) => tableMoveRounds[round].source,
  )..addListener(_onSession);

  Moves3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ChangeRound get _round => tableMoveRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What the Water Table Does',
        closing:
            'Lower the water table and the grains take up what buoyancy gives '
            'back, so the effective stress rises and the site settles: that '
            'is dewatering, and it is why pumping next door cracks buildings '
            'nobody has touched. Raise it and the reverse happens. A '
            'surcharge lands entirely on the grains. And standing water over '
            'a saturated site changes nothing at all, because it adds the '
            'same amount to both sides of the subtraction.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: waterTableBrief,
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
            'WHICH WAY DOES IT GO',
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
            height: 232,
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
                  // Before the answer the profile is the one being changed
                  // FROM; afterward it is the one it became, so the move is
                  // shown rather than described.
                  painter: DepositPainter(
                    deposit: answered ? r.after : r.before,
                    at: r.at,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r"$\sigma' = \sigma - u$",
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Moves3.values) ...[
            _Choice(
              label: ChangeRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Moves3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE WAY' : 'THE OTHER WAY',
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
