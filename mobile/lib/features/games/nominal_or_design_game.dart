import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Nominal or Design — the third item for `rc-flexure-shear`.
///
/// Reinforced concrete carries two numbers for every capacity and the exam
/// hands out marks for telling them apart: the nominal strength the section
/// can actually reach, and the design strength that is all you are allowed
/// to count on. The lesson's own first problem puts the phi-reduced answer
/// in the choices for a question that asked for the nominal one, which is a
/// mark lost after the hard part was done right.
class NominalOrDesignGame extends StatefulWidget {
  const NominalOrDesignGame({super.key});

  @override
  State<NominalOrDesignGame> createState() => _NominalOrDesignGameState();
}

@immutable
class PhiRound {
  const PhiRound({
    required this.subject,
    required this.asked,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const phiRounds = <PhiRound>[
  PhiRound(
    subject: 'what the question asked for',
    asked:
        'A problem gives the steel, the width and the effective depth and '
        'asks for the NOMINAL moment capacity. You have worked out the block '
        'depth and the lever arm. What do you report?',
    options: [
      'The steel force times the lever arm, with no phi anywhere near it',
      'That number multiplied by 0.90',
      'That number divided by 0.90',
      'That number multiplied by 0.75',
    ],
    answer: 0,
    why:
        'The nominal capacity is what the section can actually reach, so no '
        'reduction goes on it. Multiplying by 0.90 turns it into the DESIGN '
        'capacity, which is a perfectly good number answering a question that '
        'was not asked. The lesson puts that reduced value in the choices on '
        'purpose, and it catches people who have done every hard step '
        'correctly.',
    source: 'str-rfs-q1',
  ),
  PhiRound(
    subject: 'which reduction goes where',
    asked:
        'The same beam is now being checked for both bending and shear. Which '
        'reduction factors apply?',
    options: [
      '0.90 on the moment capacity and 0.75 on the shear capacity',
      '0.90 on both',
      '0.75 on both',
      '0.75 on the moment capacity and 0.90 on the shear capacity',
    ],
    answer: 0,
    why:
        'Bending gets 0.90 and shear gets 0.75. The difference is not '
        'arbitrary: a properly proportioned beam fails in bending slowly, '
        'with the steel yielding and the thing sagging visibly first, while '
        'shear failure arrives without notice. The less warning a failure '
        'gives, the harder the code leans on it.',
    source: 'str-rfs-q2',
  ),
  PhiRound(
    subject: 'which side the factors sit on',
    asked:
        'In the check itself, which quantity gets factored UP and which gets '
        'cut down?',
    options: [
      'The loads are factored up and the capacity is cut down',
      'Both are factored up',
      'The loads are cut down and the capacity is factored up',
      'Only the capacity is touched',
    ],
    answer: 0,
    why:
        'The loads go up and the capacity comes down, and the design is safe '
        'when what is left of the capacity still clears what the loads have '
        'grown into. Margin is bought at both ends, which is the whole idea '
        'of strength design: the load factors cover being wrong about the '
        'demand and phi covers being wrong about the concrete.',
    source: 'str-rfs-q1',
  ),
  PhiRound(
    subject: 'the shear the stirrups have to take',
    asked:
        'The concrete is worth some shear on its own, and the factored shear '
        'is larger. How much do the stirrups have to carry?',
    options: [
      'The factored shear divided by phi, less what the concrete carries',
      'The factored shear less what the concrete carries',
      'The factored shear less phi times what the concrete carries',
      'Phi times the factored shear, less what the concrete carries',
    ],
    answer: 0,
    why:
        'Divide the demand by phi first, then take the concrete off. The two '
        'capacities, concrete and stirrups, are both NOMINAL numbers and the '
        'reduction applies to their sum, so the demand has to be brought onto '
        'the same footing before anything is subtracted. Taking the concrete '
        'off the raw demand understates what the stirrups need, and by enough '
        'to change the spacing.',
    source: 'str-rfs-q3',
  ),
  PhiRound(
    subject: 'why the beam is arranged to yield',
    asked:
        'The 0.90 on bending is allowed only for a tension-controlled '
        'section, which means one with enough room for the steel to yield '
        'before the concrete crushes. Why does the code care?',
    options: [
      'Because a beam whose steel yields first sags and cracks long before it '
          'collapses, so it gives warning',
      'Because steel is cheaper than concrete',
      'Because yielding steel carries more load than elastic steel',
      'Because the concrete is then never the weaker of the two',
    ],
    answer: 0,
    why:
        'Because of warning. Steel that yields stretches a long way at more '
        'or less constant force, so the beam droops and the cracks open where '
        'people can see them. Concrete crushing does none of that: it arrives '
        'suddenly and takes the beam with it. Reinforced concrete design is '
        'arranged, on purpose, so that the ductile material is the one that '
        'runs out first.',
    source: 'str-rfs-q1',
  ),
  PhiRound(
    subject: 'the root of a number',
    asked:
        'The concrete shear formula wants the square root of the concrete '
        'strength in POUNDS per square inch. A beam has 4 ksi concrete. What '
        'goes into the formula?',
    options: [
      'About 63, from the square root of 4,000',
      'Exactly 2, from the square root of 4',
      'Exactly 4, since the strength is already given',
      'About 63,000, from the square root of 4,000 in pounds',
    ],
    answer: 0,
    why:
        'About 63. The formula is written for pounds per square inch, so 4 '
        'ksi has to become 4,000 psi before the root is taken, and the root '
        'of 4,000 is about 63. Taking the root of 4 instead gives 2, and the '
        'shear capacity comes out roughly a thousand times too small: a '
        'number so wrong it is easy to catch, if you look at it.',
    source: 'str-rfs-q2',
  ),
];

class _NominalOrDesignGameState extends State<NominalOrDesignGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'nominal-or-design',
    chapterId: 'structural',
    total: phiRounds.length,
    sourceProblemIdOf: (round) => phiRounds[round].source,
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

  PhiRound get _round => phiRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Nominal or Design',
        closing:
            'Nominal is what the section can reach; design is what you are '
            'allowed to count on, which is nominal times phi. Bending gets '
            '0.90 and shear gets 0.75, because bending gives warning and '
            'shear does not. In the check, loads go up and capacity comes '
            'down. And when the stirrups are being sized, the demand is '
            'divided by phi BEFORE the concrete is taken off.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: phiBrief,
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
            'WHICH NUMBER IS WANTED',
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
          const SizedBox(height: 14),
          if (answered)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE TWO CHECKS',
                    style: AppTheme.overline(color: AppColors.ink3),
                  ),
                  const SizedBox(height: 8),
                  MathText(
                    r'$\phi M_n \ge M_u, \quad \phi = 0.90$',
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.charcoal),
                  ),
                  const SizedBox(height: 6),
                  MathText(
                    r'$\phi V_n \ge V_u, \quad \phi = 0.75$',
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.charcoal),
                  ),
                ],
              ),
            ),
          if (answered) const SizedBox(height: 14),
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
