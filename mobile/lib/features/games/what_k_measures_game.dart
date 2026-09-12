import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'rigid_figures.dart';

/// What k Measures — the third item for `rigid-pavement`.
///
/// The modulus of subgrade reaction is a STIFFNESS, not a strength: the
/// pressure it takes to push the ground down one inch. A slab sits on it
/// the way a plank sits on a bed of springs.
class WhatKMeasuresGame extends StatefulWidget {
  const WhatKMeasuresGame({super.key});

  @override
  State<WhatKMeasuresGame> createState() => _WhatKMeasuresGameState();
}

@immutable
class SupportRound {
  const SupportRound({
    required this.subject,
    required this.asked,
    required this.stiffness,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;

  /// Pounds per cubic inch.
  final double stiffness;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const supportRounds = <SupportRound>[
  SupportRound(
    subject: 'what the number describes',
    asked:
        'The modulus of subgrade reaction, k, describes the subgrade how?',
    stiffness: 200,
    options: [
      'How strong it is before it fails',
      'How stiff it is: the pressure needed to push it down one inch',
      'How much water it holds',
      'How thick it is',
    ],
    answer: 1,
    why:
        'Stiffness, not strength. It is pressure over deflection, which is '
        'why its units are pounds per square inch per inch of movement, or '
        'pounds per cubic inch. It says how far the ground gives, and '
        'nothing at all about when it would fail.',
    source: 'trans-rp-q3',
  ),
  SupportRound(
    subject: 'a stiffer foundation',
    asked: 'A subgrade with a higher k does what?',
    stiffness: 400,
    options: [
      'Gives less under the same pressure',
      'Gives more',
      'Carries more load before failing',
      'Drains faster',
    ],
    answer: 0,
    why:
        'It moves less. Higher k is a stiffer bed of springs under the slab, '
        'so the same pressure pushes it down a shorter distance, and the '
        'slab bends less. That is what the slab cares about: not how much '
        'the ground could carry, but how far it sinks.',
    source: 'trans-rp-q3',
  ),
  SupportRound(
    subject: 'a soft one',
    asked:
        'This subgrade has a low k. What does the slab do over it?',
    stiffness: 90,
    options: [
      'It settles evenly and nothing else happens',
      'It bends more, and the bending stress in the concrete goes up',
      'It carries less traffic automatically',
      'It cracks immediately',
    ],
    answer: 1,
    why:
        'It bends more, and bending is what breaks a slab. A soft bed lets '
        'the slab deflect, which raises the tensile stress at the bottom of '
        'the concrete. The usual answer is a thicker slab, or a treated '
        'subbase to raise k.',
    source: 'trans-rp-q3',
  ),
  SupportRound(
    subject: 'the picture to hold',
    asked: 'Which picture fits what k describes?',
    stiffness: 200,
    options: [
      'A rope holding the slab up',
      'A bed of springs under the slab, each pushing back as it is pressed',
      'A hinge at each joint',
      'A layer of water under the slab',
    ],
    answer: 1,
    why:
        'A bed of springs. It is the standard idealization for a slab on '
        'ground, and k is the stiffness of one of those springs per unit of '
        'area. Everything about rigid pavement design rests on that picture, '
        'which is why the number is called a reaction rather than a '
        'capacity.',
    source: 'trans-rp-q3',
  ),
  SupportRound(
    subject: 'why it matters less than you would think',
    asked:
        'Doubling k on a rigid pavement helps less than doubling it would '
        'help a flexible one. Why?',
    stiffness: 400,
    options: [
      'Because the slab spreads the load so widely that the pressure on the '
          'subgrade is small either way',
      'Because k is not used in rigid design',
      'Because concrete is heavier',
      'Because rigid pavements are thinner',
    ],
    answer: 0,
    why:
        'Because the slab has already done most of the work. It spreads the '
        'wheel over so wide a patch that the pressure arriving is low, so '
        'improving the ground gains less than it would under asphalt. That '
        'is the same fact as the slab bridging a soft spot, seen from the '
        'other side.',
    source: 'trans-rp-q3',
  ),
  SupportRound(
    subject: 'what k is not',
    asked: 'Which of these is k NOT?',
    stiffness: 200,
    options: [
      'A stiffness',
      'A pressure divided by a deflection',
      'The bearing capacity of the subgrade',
      'A number that goes up on firmer ground',
    ],
    answer: 2,
    why:
        'It is not a bearing capacity. Bearing capacity asks when the ground '
        'fails; k asks how far it moves before it does anything of the kind. '
        'Two soils can have the same capacity and quite different '
        'stiffnesses, and it is the stiffness the slab responds to.',
    source: 'trans-rp-q3',
  ),
];

class _WhatKMeasuresGameState extends State<WhatKMeasuresGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-k-measures',
    chapterId: 'transportation',
    total: supportRounds.length,
    sourceProblemIdOf: (round) => supportRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  SupportRound get _round => supportRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What k Measures',
        closing:
            'A stiffness, not a strength: the pressure it takes to push the '
            'ground down one inch. Higher k means a bed of springs that '
            'gives less, so the slab bends less and the concrete is stressed '
            'less. And because the slab spreads the load so widely to begin '
            'with, improving the ground buys less here than it would under '
            'asphalt.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: subgradeReactionBrief,
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
            'THE GROUND UNDER THE SLAB',
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
            height: 206,
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
                  painter: SupportPainter(
                    stiffness: r.stiffness,
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
