import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'safety_figures.dart';
import 'lesson_brief.dart';

/// Six Feet Up — the second item for `construction-safety`.
///
/// Fall protection starts at six feet in general construction, with a
/// higher trigger for steel erection connectors. Five in the ground and six
/// in the air are the two numbers the exam swaps.
class SixFeetUpGame extends StatefulWidget {
  const SixFeetUpGame({super.key});

  @override
  State<SixFeetUpGame> createState() => _SixFeetUpGameState();
}

@immutable
class HeightRound2 {
  const HeightRound2({
    required this.subject,
    required this.asked,
    required this.work,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Working work;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own scaffold: eight feet up with nothing.
const _eightFoot = Working(height: 8);

/// Just under the trigger.
const _fiveFoot = Working(height: 5);

/// A steel connector, who has a higher trigger.
const _connector = Working(height: 12, steelConnector: true);

const heightRounds2 = <HeightRound2>[
  HeightRound2(
    subject: 'eight feet on a scaffold',
    asked:
        'A worker is on a platform eight feet up with no guardrail, no net '
        'and no harness. Is fall protection required?',
    work: _eightFoot,
    options: [
      'No: the trigger is ten feet',
      'Yes: in general construction it starts at six feet',
      'Only if the worker is leaning out',
      'Only on a scaffold over twenty feet',
    ],
    answer: 1,
    why:
        'Required. Six feet is the general construction trigger, and eight is '
        'past it. Six feet does not sound far until you remember that a fall '
        'from it puts a head into the ground at about twenty miles an hour.',
    source: 'const-cs-q2',
  ),
  HeightRound2(
    subject: 'the three ways to do it',
    asked: 'What counts as fall protection?',
    work: _eightFoot,
    options: [
      'A harness only',
      'Guardrails, safety nets, or a personal fall arrest system',
      'A warning sign',
      'A second worker watching',
    ],
    answer: 1,
    why:
        'Any of the three. Guardrails stop the fall happening, a net catches '
        'the person, and a harness and lanyard stop them short. Like the '
        'excavation rule, the requirement is an outcome and the methods are '
        'a choice.',
    source: 'const-cs-q2',
  ),
  HeightRound2(
    subject: 'under the line',
    asked: 'Five feet up, on the same job. What does the rule require?',
    work: _fiveFoot,
    options: [
      'The same protection',
      'Nothing by the height rule, though the hazard has not gone away',
      'A harness only',
      'A permit',
    ],
    answer: 1,
    why:
        'Nothing, by the rule. The trigger is a line drawn for enforcement '
        'and not a promise about physics: people are injured falling five '
        'feet, and a job that can provide protection cheaply usually should '
        'whatever the number says.',
    source: 'const-cs-q2',
  ),
  HeightRound2(
    subject: 'a different trade',
    asked:
        'A connector setting structural steel is twelve feet up. Is '
        'protection required?',
    work: _connector,
    options: [
      'Yes, as everywhere: six feet',
      'No: steel erection connectors have their own trigger, at fifteen '
          'feet',
      'No: connectors are exempt at any height',
      'Only with a crane working nearby',
    ],
    answer: 1,
    why:
        'Not yet, for that one trade. Steel erection connectors work to a '
        'fifteen foot trigger, on the argument that the equipment needed to '
        'protect them below that creates hazards of its own. It is the '
        'exception worth knowing, because it is the one the exam asks about.',
    source: 'const-cs-q2',
  ),
  HeightRound2(
    subject: 'the two numbers',
    asked:
        'Which pair of numbers are the two most quoted thresholds on a '
        'construction site?',
    work: _eightFoot,
    options: [
      'Five feet for excavation protection, six feet for fall protection',
      'Six feet for excavation, five for falls',
      'Ten and twenty feet',
      'Four and eight feet',
    ],
    answer: 0,
    why:
        'Five in the ground, six in the air. They are easy to swap and the '
        'exam swaps them, so it is worth one deliberate moment: you can '
        'stand in a five foot trench with your head near the surface, and '
        'six feet is a fall that kills people.',
    source: 'const-cs-q2',
  ),
  HeightRound2(
    subject: 'what the engineer has to do with it',
    asked:
        'Where does the engineer of record come into site safety?',
    work: _eightFoot,
    options: [
      'Nowhere: safety belongs to the contractor alone',
      'By designing for constructability, specifying measures such as '
          'shoring where they are needed, and observing the work',
      'By supervising the crew directly',
      'By writing the safety plan',
    ],
    answer: 1,
    why:
        'In the design and the administration, not in running the crew. The '
        'means and methods belong to the contractor, which is why an engineer '
        'who starts directing them takes on liability that was not theirs. '
        'Specifying shoring for a deep excavation, though, is squarely the '
        'engineer\'s job.',
    source: 'const-cs-q3',
  ),
];

class _SixFeetUpGameState extends State<SixFeetUpGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'six-feet-up',
    chapterId: 'construction',
    total: heightRounds2.length,
    sourceProblemIdOf: (round) => heightRounds2[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  HeightRound2 get _round => heightRounds2[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Six Feet Up',
        closing:
            'Six feet is the general construction trigger for fall '
            'protection, and guardrails, a net or a harness all satisfy it. '
            'Steel erection connectors work to fifteen. Five in the ground '
            'and six in the air are the two numbers to keep straight, and '
            'the engineer meets them in the design rather than on the '
            'crew.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: fallProtectionBrief,
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
            'WORKING AT A HEIGHT',
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
                  painter: HeightPainter(
                    work: r.work,
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
