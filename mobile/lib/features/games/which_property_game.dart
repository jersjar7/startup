import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which Property Is That — the first item for `fluid-properties`.
///
/// Three properties, linked by two multiplications, and the lesson's own
/// problem is lost entirely in telling them apart: its wrong answers are the
/// right number with the wrong units, and water's own specific weight. None
/// of that is arithmetic. It is knowing that a specific gravity is a bare
/// number, a density is mass in a cubic meter, and a specific weight is what
/// that weighs, which is the whole chapter's foundation.
class WhichPropertyGame extends StatefulWidget {
  const WhichPropertyGame({super.key});

  @override
  State<WhichPropertyGame> createState() => _WhichPropertyGameState();
}

/// The three properties this page links together.
enum Property { density, weight, gravity }

extension PropertyWords on Property {
  String get plain => switch (this) {
        Property.density => 'Density, in kilograms per cubic meter',
        Property.weight => 'Specific weight, in newtons per cubic meter',
        Property.gravity => 'Specific gravity, a bare number',
      };

  String get tex => switch (this) {
        Property.density => r'$\rho$',
        Property.weight => r'$\gamma$',
        Property.gravity => r'$SG$',
      };
}

@immutable
class PropertyRound {
  const PropertyRound({
    required this.subject,
    required this.asked,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What is in front of you: a reading, or a job it has to do.
  final String asked;
  final Property answer;
  final String why;
  final String source;
}

const propertyRounds = <PropertyRound>[
  PropertyRound(
    subject: 'a number off a data sheet',
    asked: 'A fluid is listed at 8,338 newtons per cubic meter. Which '
        'property is that?',
    answer: Property.weight,
    why:
        'Specific weight. Newtons are a force, so newtons per cubic meter is '
        'what a cubic meter of the stuff WEIGHS. This is the lesson '
        'problem\'s own answer, and its most tempting wrong choice is the '
        'same number written in kilograms per cubic meter, which would be a '
        'density and is not what that number is.',
    source: 'fm-fp-q1',
  ),
  PropertyRound(
    subject: 'a number with nothing after it',
    asked: 'An oil is described as 0.85, with no units of any kind. Which '
        'property is that?',
    answer: Property.gravity,
    why:
        'Specific gravity, and the giveaway is that it has no units. It is a '
        'ratio: this fluid against water, so it cancels down to a bare '
        'number. That is also why a specific gravity is the same 0.85 whether '
        'you work in newtons or in pounds, which is exactly what makes it '
        'useful.',
    source: 'fm-fp-q1',
  ),
  PropertyRound(
    subject: 'what a cubic meter holds',
    asked: 'The MASS packed into one cubic meter of the fluid. Which property '
        'is that?',
    answer: Property.density,
    why:
        'Density, in kilograms per cubic meter. Mass, not weight: it is the '
        'amount of stuff, and it does not care what gravity is doing. Water '
        'is a thousand of them, which is the number worth having by heart '
        'since almost everything on this page is quoted against it.',
    source: 'fm-fp-q1',
  ),
  PropertyRound(
    subject: 'multiplying by 9,810',
    asked: 'You multiply it by 9,810 newtons per cubic meter to get the '
        'fluid\'s specific weight. Which property is it?',
    answer: Property.gravity,
    why:
        'The specific gravity. Multiplying a bare ratio by water\'s specific '
        'weight gives the fluid\'s, which is the one line this problem needs: '
        '0.85 times 9,810 is 8,338. Multiplying by water\'s DENSITY instead '
        'gives 850, which is a density and the problem\'s other wrong answer.',
    source: 'fm-fp-q1',
  ),
  PropertyRound(
    subject: 'multiplying by g',
    asked: 'You multiply it by 9.81 meters per second squared to get the '
        'specific weight. Which property is it?',
    answer: Property.density,
    why:
        'The density, because weight is mass times g. That is the whole '
        'relationship between the two: a thousand kilograms in a cubic meter '
        'of water weighs 9,810 newtons. Two multiplications connect all three '
        'properties, and this is one of them.',
    source: 'fm-fp-q1',
  ),
  PropertyRound(
    subject: 'what the pressure formula wants',
    asked: 'Pressure under a depth of liquid is that depth times which '
        'property?',
    answer: Property.weight,
    why:
        'The specific weight. Pressure is a force over an area, so the thing '
        'it comes from has to carry a force in it: newtons per cubic meter '
        'times meters gives newtons per square meter. Putting a density in '
        'there leaves you a factor of g short, which is the mistake that '
        'follows people right through the rest of this chapter.',
    source: 'fm-fp-q1',
  ),
];

class _WhichPropertyGameState extends State<WhichPropertyGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-property',
    chapterId: 'fluid-mechanics',
    total: propertyRounds.length,
    sourceProblemIdOf: (round) => propertyRounds[round].source,
  )..addListener(_onSession);

  Property? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  PropertyRound get _round => propertyRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Property Is That',
        closing:
            'Density is mass in a cubic meter and has kilograms in it. '
            'Specific weight is what that cubic meter weighs and has newtons '
            'in it, which is why the pressure formula wants it. Specific '
            'gravity is the ratio to water and has nothing after it at all. '
            'Multiply a density by g to get a specific weight, and a specific '
            'gravity by water\'s 9,810 to get the same thing.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: threeNumbersBrief,
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
            'WHICH PROPERTY IS IT',
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
          // No formula strip here on purpose: two of these rounds ask which
          // property a multiplication belongs to, and printing the two
          // relationships on the same screen would answer them.
          const SizedBox(height: 18),
          for (final option in Property.values) ...[
            _Choice(
              tex: option.tex,
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
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
    required this.tex,
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String tex;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: MathText(
                  tex,
                  style:
                      const TextStyle(fontSize: 17, color: AppColors.charcoal),
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  style:
                      const TextStyle(fontSize: 14.5, color: AppColors.charcoal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
