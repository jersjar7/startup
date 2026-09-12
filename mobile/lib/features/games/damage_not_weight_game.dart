import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pavement_figures.dart';

/// Damage, Not Weight — the third item for `pavement-design`.
///
/// Traffic is counted for pavement design in equivalent standard axle
/// loads, because the damage an axle does climbs far faster than its
/// weight. A car is worth almost nothing and a loaded truck axle is worth
/// several standard loads.
class DamageNotWeightGame extends StatefulWidget {
  const DamageNotWeightGame({super.key});

  @override
  State<DamageNotWeightGame> createState() => _DamageNotWeightGameState();
}

@immutable
class LoadRound {
  const LoadRound({
    required this.subject,
    required this.asked,
    required this.axles,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final List<Axle> axles;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own axle: 24 kip on one axle, worth 3.03 standard loads,
/// a thousand times a year.
const _lessonAxles = [
  Axle(name: 'a car axle', kips: 2, factor: 0.0002),
  Axle(name: 'the standard', kips: 18, factor: 1.0),
  Axle(name: 'the truck here', kips: 24, factor: 3.03, passes: 1000),
];

/// A lighter truck axle against the standard one.
const _lighter = [
  Axle(name: 'a car axle', kips: 2, factor: 0.0002),
  Axle(name: 'a light truck', kips: 12, factor: 0.19),
  Axle(name: 'the standard', kips: 18, factor: 1.0),
];

const loadRounds = <LoadRound>[
  LoadRound(
    subject: 'why traffic is not just counted',
    asked:
        'Why is pavement traffic measured in equivalent standard axle loads '
        'rather than in vehicles?',
    axles: _lessonAxles,
    options: [
      'Because vehicles are hard to count',
      'Because the damage an axle does climbs far faster than its weight, so '
          'a vehicle count says nothing about wear',
      'Because axles are easier to see than vehicles',
      'Because the standard was chosen at random',
    ],
    answer: 1,
    why:
        'Because a count treats everything alike and nothing about pavement '
        'damage is alike. The damage rises roughly with the fourth power of '
        'the axle load, so a few heavy axles do more harm than all the cars '
        'on the road put together.',
    source: 'trans-pd-q3',
  ),
  LoadRound(
    subject: 'what the factor means',
    asked:
        'A 24 kip single axle has a load equivalency factor of 3.03. What '
        'does that say?',
    axles: _lessonAxles,
    options: [
      'It weighs 3.03 times the standard axle',
      'One pass of it does the damage of about three passes of the standard '
          'eighteen kip axle',
      'It is allowed three passes a day',
      'It carries 3.03 kips',
    ],
    answer: 1,
    why:
        'Three standard passes of damage from one pass. Note that it weighs '
        'only a third more than the standard axle and does three times the '
        'harm: that gap between weight and damage is the entire reason for '
        'the factor.',
    source: 'trans-pd-q3',
  ),
  LoadRound(
    subject: 'a thousand passes',
    asked:
        'A thousand of those axles come past in a year. How many standard '
        'loads is that?',
    axles: _lessonAxles,
    options: [
      'A thousand: one each',
      'About 330',
      'About 3,030: each pass counts three times over',
      'It cannot be worked out without the pavement thickness',
    ],
    answer: 2,
    why:
        'Three thousand and thirty. Multiply the passes by the factor, which '
        'is all the conversion amounts to once the factor is in hand. The '
        'answer is bigger than the count, which is the direction to expect '
        'for anything heavier than the standard axle.',
    source: 'trans-pd-q3',
  ),
  LoadRound(
    subject: 'the cars',
    asked:
        'A car axle has a factor of around two ten thousandths. What follows?',
    axles: _lessonAxles,
    options: [
      'Cars barely matter to the pavement: thousands of them equal one truck '
          'axle',
      'Cars do about a fifth of the damage of a truck',
      'Cars must be counted carefully',
      'Cars do more damage in total, since there are more of them',
    ],
    answer: 0,
    why:
        'Cars are nearly irrelevant to pavement wear. It takes something like '
        'fifteen thousand car axles to equal one loaded truck axle, so a '
        'pavement on a road with no trucks lasts almost indefinitely, and a '
        'bus route destroys a residential street.',
    source: 'trans-pd-q3',
  ),
  LoadRound(
    subject: 'a lighter axle',
    asked:
        'A twelve kip axle, two thirds the standard weight, has a factor of '
        'about 0.19. What does that show?',
    axles: _lighter,
    options: [
      'That the factor falls in proportion to the weight',
      'That the relationship is steep both ways: two thirds the load does '
          'less than a fifth of the damage',
      'That light axles do no damage',
      'That the factor is always under one',
    ],
    answer: 1,
    why:
        'The curve is steep in both directions. Two thirds of the weight does '
        'under a fifth of the damage, which is why a load limit works: taking '
        'a little weight off an axle takes a great deal of damage off the '
        'road.',
    source: 'trans-pd-q3',
  ),
  LoadRound(
    subject: 'what the number is used for',
    asked:
        'Once the standard loads for the design life are totalled, what are '
        'they used for?',
    axles: _lessonAxles,
    options: [
      'To set the speed limit',
      'To set the structural number the section has to reach',
      'To choose the drainage coefficients',
      'To decide the number of lanes',
    ],
    answer: 1,
    why:
        'They set the target. Traffic and subgrade support together give the '
        'structural number the section must reach, and that is the number the '
        'courses are then chosen to meet. The whole chain runs from truck '
        'axles to inches of asphalt.',
    source: 'trans-pd-q3',
  ),
];

class _DamageNotWeightGameState extends State<DamageNotWeightGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'damage-not-weight',
    chapterId: 'transportation',
    total: loadRounds.length,
    sourceProblemIdOf: (round) => loadRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  LoadRound get _round => loadRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Damage, Not Weight',
        closing:
            'Damage climbs far faster than weight, so traffic is counted in '
            'standard eighteen kip axle loads. A car is worth a couple of ten '
            'thousandths of one and a loaded truck axle is worth three. '
            'Multiply the passes by the factor, add them up over the design '
            'life, and that is what sets the structural number.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: esalBrief,
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
            'WHAT WEARS A ROAD OUT',
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
                  painter: EsalPainter(
                    axles: r.axles,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
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
