import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'effective_stress_figures.dart';

/// The Short Way Down — the third item for `effective-stress`.
///
/// There are two routes to the effective stress at a depth and they agree
/// exactly: work out the total and take the water pressure off it, or walk
/// down layer by layer using the SUBMERGED weight below the water table and
/// the ordinary weight above it. The short way is quicker and it is also
/// where the mistakes live, because the buoyant weight belongs only below
/// the table and a surcharge is never buoyed at all.
class TheShortWayDownGame extends StatefulWidget {
  const TheShortWayDownGame({super.key});

  @override
  State<TheShortWayDownGame> createState() => _TheShortWayDownGameState();
}

@immutable
class RouteRound {
  const RouteRound({
    required this.subject,
    required this.asked,
    required this.deposit,
    required this.at,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Deposit deposit;
  final double at;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _sandOverClay = Deposit(
  layers: [
    Stratum(name: 'dry sand', thickness: 5, unitWeight: 110),
    Stratum(name: 'saturated clay', thickness: 8, unitWeight: 120,
        saturated: true),
  ],
  waterDepth: 5,
);

const _allSaturated = Deposit(
  layers: [
    Stratum(name: 'saturated clay', thickness: 10, unitWeight: 115,
        saturated: true),
  ],
  waterDepth: 0,
);

const _surcharged = Deposit(
  layers: [
    Stratum(name: 'sand', thickness: 6, unitWeight: 105),
    Stratum(name: 'saturated clay', thickness: 10, unitWeight: 118,
        saturated: true),
  ],
  waterDepth: 6,
  surcharge: 100,
);

const profileWalkRounds = <RouteRound>[
  RouteRound(
    subject: 'below the water table',
    asked:
        'Walking down the profile to build the effective stress directly, '
        'which weight do you use for the saturated clay?',
    deposit: _sandOverClay,
    at: 13,
    options: [
      'The submerged weight: the saturated weight less the weight of water',
      'The saturated weight, as measured',
      'The dry weight of the clay',
      'The saturated weight plus the weight of water',
    ],
    answer: 0,
    why:
        'The submerged weight, which for most soils is roughly half the '
        'saturated one. Below the water table each foot of soil adds its own '
        'weight to the total and a foot of water pressure underneath it, and '
        'the difference between those two is exactly the buoyant weight. That '
        'is the whole of the shortcut.',
    source: 'geo-es-q2',
  ),
  RouteRound(
    subject: 'above it',
    asked:
        'And for the dry sand above the water table, walking the same way '
        'down?',
    deposit: _sandOverClay,
    at: 13,
    options: [
      'Its own weight as it is, with nothing taken off',
      'Its weight less the weight of water',
      'Its saturated weight',
      'Half its weight, since it is only partly wet',
    ],
    answer: 0,
    why:
        'Its own weight, untouched. There is no water pressure above the '
        'table, so there is nothing to subtract, and taking the unit weight '
        'of water off a layer that sits above the water table is the mistake '
        'the lesson names outright. It makes the answer too small, and by a '
        'lot.',
    source: 'geo-es-q2',
  ),
  RouteRound(
    subject: 'the two routes',
    asked:
        'One person works out the total stress and subtracts the water '
        'pressure. Another walks down using buoyant weights. How do the '
        'answers compare?',
    deposit: _allSaturated,
    at: 10,
    options: [
      'Identical: the short way is the long way with the subtraction done '
          'early',
      'The short way is an approximation and comes out slightly low',
      'The short way only works when the water table is at the surface',
      'They differ by the weight of water times the depth',
    ],
    answer: 0,
    why:
        'Identical, and it is worth seeing why: subtracting the water '
        'pressure at the end is the same as subtracting a foot of water from '
        'every foot of submerged soil on the way down. Nothing is '
        'approximated. Use whichever is less trouble, and use the other one '
        'to check it.',
    source: 'geo-es-q1',
  ),
  RouteRound(
    subject: 'what the water pressure is measured from',
    asked:
        'The point is thirteen feet down and the water table is at five feet. '
        'What height of water sets the pressure there?',
    deposit: _sandOverClay,
    at: 13,
    options: [
      'Eight feet, from the water table down to the point',
      'Thirteen feet, from the ground surface down',
      'Five feet, the depth of the water table',
      'Twenty-one feet, the two added together',
    ],
    answer: 0,
    why:
        'Eight feet. The pressure comes from the column of water standing '
        'above the point, and that column starts at the water table. Using '
        'the depth below the ground surface instead is the commonest slip in '
        'the whole lesson, and it always overstates the water pressure and '
        'understates what the grains are carrying.',
    source: 'geo-es-q2',
  ),
  RouteRound(
    subject: 'a surcharge on top',
    asked:
        'A hundred pounds a square foot sits on the surface. How does it '
        'enter the effective stress at a point below the water table?',
    deposit: _surcharged,
    at: 16,
    options: [
      'In full: it adds to the total and nothing to the water',
      'Buoyed, like the soil below the water table',
      'Not at all, since it is above the water table',
      'Halved, because half of it is carried by the water',
    ],
    answer: 0,
    why:
        'In full. Buoyancy applies to things sitting IN the water, and a load '
        'spread on the surface is not one of them: it presses down on '
        'everything below it, the water pressure is set by the water table '
        'and does not notice, and the whole hundred pounds lands on the '
        'grains. The lesson offers the version that forgets the surcharge '
        'entirely as a wrong answer.',
    source: 'geo-es-q3',
  ),
  RouteRound(
    subject: 'the wrong weight in the wrong place',
    asked:
        'Somebody uses the buoyant weight for the sand ABOVE the water table '
        'as well. What happens to the answer?',
    deposit: _surcharged,
    at: 16,
    options: [
      'It comes out too small, by the weight of water times that thickness',
      'It comes out too large by the same amount',
      'Nothing: the two cancel further down',
      'It is right, since buoyancy applies everywhere below the surface',
    ],
    answer: 0,
    why:
        'Too small, by about 62 pounds a square foot for every foot of sand '
        'wrongly buoyed. Above the water table there is no water holding '
        'anything up, so nothing may be taken off. Being too small sounds '
        'safe and is not: an understated effective stress overstates how much '
        'the ground will settle and understates how strong it is.',
    source: 'geo-es-q3',
  ),
];

class _TheShortWayDownGameState extends State<TheShortWayDownGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'the-short-way-down',
    chapterId: 'geotechnical',
    total: profileWalkRounds.length,
    sourceProblemIdOf: (round) => profileWalkRounds[round].source,
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

  RouteRound get _round => profileWalkRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'The Short Way Down',
        closing:
            'Below the water table each foot of soil adds its buoyant weight '
            'to the effective stress, above it each foot adds its own weight '
            'untouched, and a surcharge adds in full. That walk gives exactly '
            'the same answer as taking the total and subtracting the water '
            'pressure, which is measured from the WATER TABLE down. The one '
            'thing never to do is buoy a layer that sits above the table.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: shortWayBrief,
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
            'WALKING DOWN THE PROFILE',
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
                  painter: DepositPainter(
                    deposit: r.deposit,
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
              r"$\sigma' = \gamma_1 H_1 + \gamma' H_2$",
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Choice(
              label: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != r.options.length - 1) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
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
