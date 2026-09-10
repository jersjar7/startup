import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'axial_figures.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// What Comes Out — the second item for `axial-stress-strain-deformation`.
///
/// The lesson names mixing meters and millimeters as the single commonest
/// source of wrong answers in the whole topic, and the reason it is so hard to
/// catch is that it is dimensionally PERFECT. The units cancel exactly the way
/// they should. The answer is simply out by a thousand and looks entirely
/// reasonable.
///
/// So here is a substitution with the unit written on every quantity, and the
/// question is what falls out of it: a stress, a distance, a bare ratio, or
/// nothing trustworthy at all because two different lengths went in.
class WhatComesOutGame extends StatefulWidget {
  const WhatComesOutGame({super.key});

  @override
  State<WhatComesOutGame> createState() => _WhatComesOutGameState();
}

@immutable
class SumRound {
  const SumRound({
    required this.subject,
    required this.setting,
    required this.sum,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Sum sum;
  final String why;
  final String source;

  /// Worked out from the units written on the terms, never declared.
  Gives get answer => sum.gives;
}

const sumRounds = <SumRound>[
  SumRound(
    subject: 'a load over an area',
    setting:
        'The load has been put in newtons and the area in square '
        'millimeters.',
    sum: Sum(
      over: [Term('P', Written.newton)],
      under: [Term('A', Written.mmSq)],
    ),
    why:
        'A stress. Newtons over square millimeters is newtons per square '
        'millimeter, which is a megapascal, and that is the unit steel design '
        'is done in. Working in newtons and millimeters throughout is the one '
        'habit that makes this lesson painless.',
    source: 'mm-asd-q1',
  ),
  SumRound(
    subject: 'the deformation formula, all in millimeters',
    setting:
        'Load in newtons, length in millimeters, area in square millimeters, '
        'modulus in newtons per square millimeter.',
    sum: Sum(
      over: [Term('P', Written.newton), Term('L', Written.mm)],
      under: [Term('A', Written.mmSq), Term('E', Written.mpa)],
    ),
    why:
        'A distance, in millimeters. Every length in the sum is a millimeter, '
        'so the answer comes out in millimeters too and needs no converting. '
        'Track the units through once like this and you never have to wonder '
        'what the answer is measured in.',
    source: 'mm-asd-q2',
  ),
  SumRound(
    subject: 'the same formula with the length left in meters',
    setting:
        'Identical to the last one except the length has been left in meters, '
        'the way it was given in the question.',
    sum: Sum(
      over: [Term('P', Written.newton), Term('L', Written.meter)],
      under: [Term('A', Written.mmSq), Term('E', Written.mpa)],
    ),
    why:
        'Nothing you can trust. Here is the cruelty of it: the units cancel '
        'perfectly and something that looks like a length falls out. It is out '
        'by a factor of a thousand. Dimensional checking will not catch this '
        'one, and the lesson calls it the commonest wrong answer in the topic '
        'for that reason. Convert first, every time.',
    source: 'mm-asd-q2',
  ),
  SumRound(
    subject: 'a stretch over a length',
    setting: 'Both of them measured in millimeters.',
    sum: Sum(
      over: [Term(r'\delta', Written.mm)],
      under: [Term('L', Written.mm)],
    ),
    why:
        'A bare number with nothing on it. That is what a strain is: how much '
        'longer as a fraction of how long, so the units cancel away entirely. '
        'A strain quoted with a unit on it is a strain someone has '
        'misunderstood.',
    source: 'mm-asd-q2',
  ),
  SumRound(
    subject: 'a modulus times an expansion times a rise',
    setting:
        'Modulus in newtons per square millimeter, the expansion coefficient '
        'per degree, and the temperature rise in degrees.',
    sum: Sum(
      over: [
        Term('E', Written.mpa),
        Term(r'\alpha', Written.perCelsius),
        Term(r'\Delta T', Written.celsius),
      ],
    ),
    why:
        'A stress. The degrees cancel against the per-degree and what is left '
        'is the modulus, which was already a stress. No length appears '
        'anywhere in it, which is the point the lesson makes about a '
        'restrained bar: how long it is and how thick it is both drop out.',
    source: 'mm-asd-q3',
  ),
  SumRound(
    subject: 'a stretch over a length again',
    setting:
        'The same ratio, but the stretch was measured in millimeters and the '
        'length was written down in meters.',
    sum: Sum(
      over: [Term(r'\delta', Written.mm)],
      under: [Term('L', Written.meter)],
    ),
    why:
        'Nothing you can trust, and this is the plainest version of the '
        'mistake there is. Both are lengths, so they cancel and a bare number '
        'comes out looking exactly like a strain. It is a thousand times too '
        'small. Two lengths in one sum have to be the same length.',
    source: 'mm-asd-q2',
  ),
];

class _WhatComesOutGameState extends State<WhatComesOutGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-comes-out',
    chapterId: 'mechanics-materials',
    total: sumRounds.length,
    sourceProblemIdOf: (round) => sumRounds[round].source,
  )..addListener(_onSession);

  Gives? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SumRound get _round => sumRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Comes Out',
        closing:
            'Put newtons, millimeters and megapascals in and the answer comes '
            'out in millimeters or megapascals with nothing to convert. Put a '
            'meter in beside a millimeter and the units still cancel and the '
            'answer is still wrong by a thousand. Checking the dimensions will '
            'not save you from that one. Converting before you start will.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: unitsBrief,
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
            'WHAT FALLS OUT OF THIS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.setting,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Center(
              child: MathText(
                '\$${r.sum.latex}\$',
                style: const TextStyle(fontSize: 19, color: AppColors.charcoal),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Gives.values) ...[
            _GivesButton(
              key: ValueKey('gives-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Gives.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT COMES OUT' : 'SOMETHING ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _GivesButton extends StatelessWidget {
  const _GivesButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Gives option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Gives.stress: 'A stress',
    Gives.length: 'A distance',
    Gives.pureNumber: 'A bare number',
    Gives.mixedUnits: 'Nothing you can trust',
  };

  static const _notes = {
    Gives.stress: 'newtons over an area',
    Gives.length: 'something you could measure with a rule',
    Gives.pureNumber: 'the units cancel away, which is a strain',
    Gives.mixedUnits: 'two different lengths went into one sum',
  };

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 58,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _titles[option]!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _notes[option]!,
                style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
