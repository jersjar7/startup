import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'curve_figures.dart';
import 'lesson_brief.dart';

/// Stiff Is Not Strong — the elastic modulus, taught in this lesson too.
///
/// Chapter seven asks which property a curve shows. This lesson has its own
/// problem behind the modulus, so a student who starts here meets it here:
/// stress over strain is a SLOPE, and a slope is not a height.
class StiffIsNotStrongGame extends StatefulWidget {
  const StiffIsNotStrongGame({super.key});

  @override
  State<StiffIsNotStrongGame> createState() => _StiffIsNotStrongGameState();
}

@immutable
class StiffRound {
  const StiffRound({
    required this.subject,
    required this.asked,
    required this.stiffer,
    required this.stronger,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  /// The two specimens on the axes: the stiffer one and the stronger one.
  final Specimen stiffer;
  final Specimen stronger;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The pair is deliberately crossed, because the whole point of the item
/// is that stiffness and strength are different properties. Cast iron is
/// the STIFFER of the two, and its curve is the steeper one, yet it ends
/// far lower: it is much the weaker in tension, and it breaks early. The
/// aluminum alloy is springier and holds more than twice the stress.
const _castIron = Specimen(
  label: 'cast iron',
  e: 170000,
  yieldStress: 170,
  ultimate: 200,
  fractureStrain: 0.02,
  necksTo: 1,
);

const _aluminumAlloy = Specimen(
  label: 'aluminum alloy',
  e: 70000,
  yieldStress: 400,
  ultimate: 480,
  fractureStrain: 0.12,
  necksTo: 0.92,
);

const stiffRounds = <StiffRound>[
  StiffRound(
    subject: 'the strain from the numbers',
    asked:
        'A 50 mm gauge length stretches 0.125 mm. What is the strain?',
    stiffer: _castIron,
    stronger: _aluminumAlloy,
    options: [
      '0.125, the stretch itself',
      '0.0025, the stretch divided by the original length',
      '400, the length divided by the stretch',
      '0.0025 mm',
    ],
    answer: 1,
    why:
        'Stretch over original length, which is 0.0025. Strain has no units '
        'at all: it is a length over a length, so quoting it in millimeters '
        'is a category mistake even when the number is right.',
    source: 'mat-ssm-q2',
  ),
  StiffRound(
    subject: 'stress over strain',
    asked:
        'That strain came from 175 MPa of stress, still in the elastic range. '
        'What does 175 over 0.0025 give?',
    stiffer: _castIron,
    stronger: _aluminumAlloy,
    options: [
      'The strength, 70,000 MPa',
      'The stiffness: 70,000 MPa, or 70 GPa, which is the elastic modulus',
      'The yield stress',
      'The strain energy',
    ],
    answer: 1,
    why:
        'The elastic modulus, 70 GPa, which happens to be aluminum. It is '
        'the SLOPE of the straight part of the curve, and the number says how '
        'hard you have to pull to stretch the thing, not how hard you have '
        'to pull to break it.',
    source: 'mat-ssm-q2',
  ),
  StiffRound(
    subject: 'the difference that matters',
    asked:
        'Two materials are on these axes, and the steeper line is the one '
        'that ends LOWER. Which feature shows which is stiffer?',
    stiffer: _castIron,
    stronger: _aluminumAlloy,
    options: [
      'How high its curve goes',
      'How steep its straight part is',
      'How far along it breaks',
      'Which curve is longer',
    ],
    answer: 1,
    why:
        'The steepness. Stiffness is the slope of the elastic line, so the '
        'steeper material stretches less under the same stress. How HIGH the '
        'curve goes is strength, and how far along it goes is ductility: '
        'three different questions, three different features of one drawing.',
    source: 'mat-ssm-q2',
  ),
  StiffRound(
    subject: 'stiff is not strong',
    asked:
        'A material has a high elastic modulus. Does that mean it takes more '
        'load before it breaks?',
    stiffer: _castIron,
    stronger: _aluminumAlloy,
    options: [
      'Yes: stiffness and strength are the same property',
      'No: stiffness says how much it stretches, strength says when it gives '
          'way, and a material can be one without the other',
      'Yes, but only in tension',
      'Only if it is ductile',
    ],
    answer: 1,
    why:
        'No, and the two curves here are the proof: the steeper one is cast '
        'iron, which is stiffer than the aluminum alloy beside it and breaks '
        'at well under half the stress. Glass is the other standard case, '
        'stiff and brittle. The properties come from different parts of the '
        'same curve and are not tied together.',
    source: 'mat-ssm-q2',
  ),
  StiffRound(
    subject: 'which one for a bouncy floor',
    asked:
        'A floor is strong enough but bounces when people walk across it. '
        'Which property has to change?',
    stiffer: _castIron,
    stronger: _aluminumAlloy,
    options: [
      'Strength: use a stronger material',
      'Stiffness: the deflection is a serviceability problem, not a strength '
          'one',
      'Ductility',
      'Hardness',
    ],
    answer: 1,
    why:
        'Stiffness. The floor is not close to failing, it is moving too much, '
        'and movement is governed by the modulus and the shape of the '
        'section. Specifying a stronger steel changes almost nothing here, '
        'because the modulus of every structural steel is about the same.',
    source: 'mat-ssm-q2',
  ),
  StiffRound(
    subject: 'the number the exam expects',
    asked:
        'Which quantity does the elastic modulus of ordinary structural '
        'steel sit near?',
    stiffer: _castIron,
    stronger: _aluminumAlloy,
    options: [
      '200 GPa, about three times aluminum',
      '70 GPa, the same as aluminum',
      '400 MPa',
      '0.0025',
    ],
    answer: 0,
    why:
        'About 200 GPa, near enough, with aluminum at about 70. It is worth '
        'carrying those two numbers: they let you check an answer in seconds, '
        'and they are why an aluminum member of the same shape deflects '
        'roughly three times as much as a steel one.',
    source: 'mat-ssm-q2',
  ),
];

class _StiffIsNotStrongGameState extends State<StiffIsNotStrongGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stiff-is-not-strong',
    chapterId: 'materials',
    total: stiffRounds.length,
    sourceProblemIdOf: (round) => stiffRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  StiffRound get _round => stiffRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stiff Is Not Strong',
        closing:
            'Stress over strain is the slope of the straight part, which '
            'is stiffness: how much the thing stretches. Strength is how '
            'HIGH the curve goes and ductility is how far along it goes. A '
            'material can be stiff and weak, and a floor that bounces needs '
            'stiffness rather than strength.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: stiffnessBrief,
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
            'SLOPE, NOT HEIGHT',
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
            height: 226,
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
                  painter: PairPainter(
                    left: r.stiffer,
                    right: r.stronger,
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
