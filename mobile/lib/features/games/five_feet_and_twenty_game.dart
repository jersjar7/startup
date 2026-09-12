import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'safety_figures.dart';
import 'lesson_brief.dart';

/// Five Feet and Twenty — the first item for `construction-safety`.
///
/// Two depths change what an excavation needs: five feet, where a
/// protective system becomes required at all, and twenty, where the system
/// has to be designed by a professional engineer.
class FiveFeetAndTwentyGame extends StatefulWidget {
  const FiveFeetAndTwentyGame({super.key});

  @override
  State<FiveFeetAndTwentyGame> createState() => _FiveFeetAndTwentyGameState();
}

@immutable
class TrenchRound {
  const TrenchRound({
    required this.subject,
    required this.asked,
    required this.trench,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Trench trench;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own trench: seven feet deep with nothing in it.
const _sevenFoot = Trench(depth: 7);

/// A shallow one, under the threshold.
const _fourFoot = Trench(depth: 4);

/// The same seven feet, properly shored.
const _shored = Trench(depth: 7, protected: true);

/// And a deep one, past where an engineer has to design the system.
const _twentyTwo = Trench(depth: 22);

const trenchRounds = <TrenchRound>[
  TrenchRound(
    subject: 'seven feet, and nothing in it',
    asked:
        'A crew is working in a seven foot trench with no protective system. '
        'Is that a violation?',
    trench: _sevenFoot,
    options: [
      'No: violations start at ten feet',
      'Yes: anything over five feet needs sloping, shoring or a box',
      'No, if the soil looks firm',
      'Only if somebody is inside it',
    ],
    answer: 1,
    why:
        'A violation. Five feet is the line, and past it the trench needs a '
        'protective system of some kind. Soil that looks firm is exactly the '
        'soil people are buried in: a cubic yard of it weighs about as much '
        'as a car, and a trench gives no warning before it comes in.',
    source: 'const-cs-q1',
  ),
  TrenchRound(
    subject: 'under the line',
    asked: 'This one is four feet deep. What does the rule require?',
    trench: _fourFoot,
    options: [
      'A protective system all the same',
      'Nothing by the depth rule, though good practice may still ask for '
          'something',
      'An engineer\'s design',
      'A permit',
    ],
    answer: 1,
    why:
        'Nothing, by the depth rule. Below five feet the requirement does not '
        'bite, which does not mean the hole is safe: a competent person still '
        'has to look at it, and a four foot trench in bad ground can still be '
        'protected by choice.',
    source: 'const-cs-q1',
  ),
  TrenchRound(
    subject: 'the three ways to do it',
    asked:
        'This seven foot trench has been made safe. Which methods were '
        'available?',
    trench: _shored,
    options: [
      'Shoring only',
      'A trench box only',
      'Sloping or benching the sides, shoring, or a trench box',
      'Nothing works at this depth',
    ],
    answer: 2,
    why:
        'Any of the three. Sloping lays the sides back to a safe angle, '
        'shoring holds them in place, and a box protects the people rather '
        'than the hole. Which one gets used comes down to the soil, the room '
        'available and the cost, not to the rule.',
    source: 'const-cs-q1',
  ),
  TrenchRound(
    subject: 'the second line',
    asked:
        'This excavation is twenty two feet deep. What changes at that '
        'depth?',
    trench: _twentyTwo,
    options: [
      'Nothing: the five foot rule already covers it',
      'The protective system has to be designed by a registered '
          'professional engineer',
      'The work has to stop',
      'Only a trench box may be used',
    ],
    answer: 1,
    why:
        'An engineer has to design it. Past twenty feet the manufactured '
        'tabulated data most systems rely on runs out, so the design becomes '
        'a professional engineering job with a seal on it. That is the second '
        'number worth remembering after the five.',
    source: 'const-cs-q3',
  ),
  TrenchRound(
    subject: 'the soil types',
    asked:
        'The flattest slope is required in which soil?',
    trench: _sevenFoot,
    options: [
      'The strongest',
      'The weakest, type C, which needs one and a half horizontal to one '
          'vertical',
      'It is the same slope in every soil',
      'It depends on the depth only',
    ],
    answer: 1,
    why:
        'The weakest. Type C soil will not stand steeply, so the sides have '
        'to be laid back further, which takes more room and more excavation. '
        'That is often what pushes a job toward shoring or a box instead: '
        'sloping is cheap only when there is space for it.',
    source: 'const-cs-q1',
  ),
  TrenchRound(
    subject: 'who the rule protects',
    asked:
        'A trench box protects the workers but does not hold the trench '
        'walls up. Is that acceptable?',
    trench: _shored,
    options: [
      'No: the walls must be held',
      'Yes: the rule is about keeping people from being buried, and a box '
          'does that',
      'Only in type A soil',
      'Only under ten feet',
    ],
    answer: 1,
    why:
        'Yes. The three methods work in different ways and the rule accepts '
        'all of them, because the point is not a tidy trench: it is that '
        'nobody is under the soil when it moves. A box lets the walls fail '
        'around the people inside it.',
    source: 'const-cs-q1',
  ),
];

class _FiveFeetAndTwentyGameState extends State<FiveFeetAndTwentyGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'five-feet-and-twenty',
    chapterId: 'construction',
    total: trenchRounds.length,
    sourceProblemIdOf: (round) => trenchRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  TrenchRound get _round => trenchRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Five Feet and Twenty',
        closing:
            'Over five feet a trench needs a protective system: sloping, '
            'shoring or a box, whichever suits the soil and the room. Over '
            'twenty feet that system has to be designed by a professional '
            'engineer. Below five the rule does not bite, which is not the '
            'same as the hole being safe.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: excavationBrief,
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
            'THE HOLE IN THE GROUND',
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
                  painter: TrenchPainter(
                    trench: r.trench,
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
