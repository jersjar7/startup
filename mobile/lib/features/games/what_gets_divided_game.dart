import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'bearing_figures.dart';

/// What Gets Divided — the third item for `bearing-capacity`.
///
/// The equation gives the pressure at which the soil fails, and nobody
/// builds to that. The factor of safety divides the ULTIMATE capacity to
/// give an allowable pressure, and it is the allowable one that the real
/// foundation pressure is compared with. Dividing the load instead, or
/// forgetting to divide at all, are the two wrong answers the lesson prints
/// side by side.
class WhatGetsDividedGame extends StatefulWidget {
  const WhatGetsDividedGame({super.key});

  @override
  State<WhatGetsDividedGame> createState() => _WhatGetsDividedGameState();
}

@immutable
class SafetyRound {
  const SafetyRound({
    required this.subject,
    required this.asked,
    required this.footing,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Footing footing;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _mixed = Footing(
    width: 5, depth: 3, cohesion: 500, unitWeight: 115,
    nc: 14.83, nq: 6.40, nGamma: 3.54);
const _sand = Footing(
    width: 4, depth: 3, cohesion: 0, unitWeight: 120,
    nc: 30.14, nq: 18.40, nGamma: 15.07);

const safetyRounds = <SafetyRound>[
  SafetyRound(
    subject: 'what the equation gives',
    asked:
        'The bearing capacity equation has been worked out and comes to '
        '10,640 pounds a square foot. What is that number?',
    footing: _mixed,
    options: [
      'The pressure at which the soil fails: nobody builds to it',
      'The pressure the footing may be designed for',
      'The load the column may carry',
      'The settlement the footing will suffer',
    ],
    answer: 0,
    why:
        'It is the ULTIMATE capacity, the pressure at which the soil gives '
        'way. It is a failure load and no more a design value than the '
        'breaking strength of a rope is a working load. The lesson offers it '
        'as a choice on the very problem that asks for the allowable '
        'pressure.',
    source: 'geo-bc-q3',
  ),
  SafetyRound(
    subject: 'what the factor divides',
    asked:
        'A factor of safety of three is applied. What does the three divide?',
    footing: _mixed,
    options: [
      'The ultimate capacity, giving an allowable pressure of about 3,550',
      'The load coming down the column',
      'The cohesion term only',
      'The width of the footing',
    ],
    answer: 0,
    why:
        'The ultimate capacity. Divide 10,640 by three and the allowable '
        'pressure is about 3,550, and it is THAT which the real foundation '
        'pressure is compared with. The lesson says so in as many words '
        'because dividing the load instead is a natural mistake and gives a '
        'different, wrong answer.',
    source: 'geo-bc-q3',
  ),
  SafetyRound(
    subject: 'why three',
    asked:
        'Bearing capacity is usually checked with a factor of three, where '
        'steel members get something nearer 1.5. Why so much more?',
    footing: _mixed,
    options: [
      'The soil is not manufactured, is barely sampled, and fails without '
          'warning',
      'Because foundations carry more load than members do',
      'Because concrete is weaker than steel',
      'It is arbitrary, and any number would do',
    ],
    answer: 0,
    why:
        'Because of what is being trusted. A steel section arrives with a '
        'mill certificate; the soil under a building is known from a handful '
        'of boreholes and varies between them, and a bearing failure arrives '
        'suddenly and cannot be repaired from above. Three is the price of '
        'that ignorance.',
    source: 'geo-bc-q3',
  ),
  SafetyRound(
    subject: 'which weight in the terms',
    asked:
        'The footing sits below the water table. Which unit weight goes into '
        'the depth and width terms?',
    footing: _sand,
    options: [
      'The effective one, which is roughly half the total',
      'The total unit weight, as measured',
      'The dry unit weight',
      'The unit weight of water',
    ],
    answer: 0,
    why:
        'The effective, buoyant one. Those two terms are the weight of soil '
        'that has to be shifted for the footing to fail, and soil under water '
        'weighs about half what it weighs above it. Using the total weight '
        'below the water table roughly doubles both terms and hands back a '
        'capacity the site does not have.',
    source: 'geo-bc-q3',
  ),
  SafetyRound(
    subject: 'comparing it with the building',
    asked:
        'The allowable pressure is 3,550 and the column brings 300 kips down '
        'onto the footing. What do you compare?',
    footing: _mixed,
    options: [
      'The load spread over the footing area, as a pressure, against the '
          'allowable pressure',
      'The load itself against the allowable pressure',
      'The load against the ultimate capacity',
      'The allowable pressure against the cohesion',
    ],
    answer: 0,
    why:
        'Pressure against pressure. The column load has to be turned into a '
        'pressure by dividing it over the area of the footing before it can '
        'meet the allowable value, and that is the step where the size of the '
        'footing is actually chosen. Comparing a load with a pressure is '
        'comparing two different things.',
    source: 'geo-bc-q3',
  ),
  SafetyRound(
    subject: 'what this check does not cover',
    asked:
        'The footing passes its bearing check comfortably. What might still '
        'be wrong with it?',
    footing: _mixed,
    options: [
      'It may settle too much: bearing capacity and settlement are separate '
          'checks',
      'Nothing: passing the bearing check is the whole of foundation design',
      'The soil may be too strong',
      'The factor of safety may be too large',
    ],
    answer: 0,
    why:
        'It may settle far too much. Bearing capacity asks whether the soil '
        'will fail; settlement asks how far the building will go down before '
        'it does not, and on a soft clay the settlement check is usually the '
        'one that decides the footing. Passing one says nothing about the '
        'other.',
    source: 'geo-bc-q3',
  ),
];

class _WhatGetsDividedGameState extends State<WhatGetsDividedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-gets-divided',
    chapterId: 'geotechnical',
    total: safetyRounds.length,
    sourceProblemIdOf: (round) => safetyRounds[round].source,
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

  SafetyRound get _round => safetyRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Gets Divided',
        closing:
            'The equation gives a failure pressure. The factor of safety '
            'divides THAT, never the load, and the result is what the real '
            'foundation pressure is compared with, pressure against pressure. '
            'Three is the usual figure because the soil is barely sampled and '
            'fails without warning. Below the water table the weight terms '
            'use the buoyant unit weight. And passing this check says nothing '
            'about how far the building will settle.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: allowableBrief,
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
            'ULTIMATE OR ALLOWABLE',
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
            height: 216,
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
                      FootingPainter(footing: r.footing, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$q_{allow} = \frac{q_{ult}}{FS}$',
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
