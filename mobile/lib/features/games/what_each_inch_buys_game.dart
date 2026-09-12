import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pavement_figures.dart';

/// What Each Inch Buys — the first item for `pavement-design`.
///
/// The structural number is a sum of contributions, one per course, each of
/// them a coefficient times a thickness times a drainage factor. An inch of
/// asphalt is worth about three inches of crushed stone, which is the whole
/// economics of a pavement section.
class WhatEachInchBuysGame extends StatefulWidget {
  const WhatEachInchBuysGame({super.key});

  @override
  State<WhatEachInchBuysGame> createState() => _WhatEachInchBuysGameState();
}

@immutable
class PavementSectionRound {
  const PavementSectionRound({
    required this.subject,
    required this.asked,
    required this.pavement,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Pavement pavement;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own section: three inches of asphalt, eight of base, ten of
/// subbase, which comes to 3.54.
const _lessonSection = Pavement(courses: [
  Course(name: 'asphalt', coefficient: 0.44, thickness: 3),
  Course(name: 'base', coefficient: 0.14, thickness: 8),
  Course(name: 'subbase', coefficient: 0.11, thickness: 10),
]);

/// The same section with a subbase that drains badly.
const _wetSubbase = Pavement(courses: [
  Course(name: 'asphalt', coefficient: 0.44, thickness: 3),
  Course(name: 'base', coefficient: 0.14, thickness: 8),
  Course(name: 'subbase', coefficient: 0.11, thickness: 10, drainage: 0.80),
]);

/// A thicker asphalt course on a thinner base.
const _thickSurface = Pavement(courses: [
  Course(name: 'asphalt', coefficient: 0.44, thickness: 6),
  Course(name: 'base', coefficient: 0.14, thickness: 8),
  Course(name: 'subbase', coefficient: 0.11, thickness: 10),
]);

const pavementSectionRounds = <PavementSectionRound>[
  PavementSectionRound(
    subject: 'what the number is',
    asked:
        'The structural number of a flexible pavement is what, exactly?',
    pavement: _lessonSection,
    options: [
      'The thickness of the asphalt',
      'The total thickness of all the courses',
      'One number standing for the strength of the whole section, added up '
          'course by course',
      'The strength of the subgrade underneath',
    ],
    answer: 2,
    why:
        'A single index for the whole section. Each course contributes its '
        'coefficient times its thickness times its drainage factor, and the '
        'sum is what the design has to reach. It says nothing about the '
        'subgrade, which is what set the target in the first place.',
    source: 'trans-pd-q1',
  ),
  PavementSectionRound(
    subject: 'the value of an inch',
    asked:
        'An inch of asphalt is worth 0.44 and an inch of crushed stone base '
        '0.14. What does that mean in practice?',
    pavement: _lessonSection,
    options: [
      'Asphalt is three times heavier',
      'An inch of asphalt does the structural work of about three inches of '
          'base',
      'Base material is three times stronger',
      'The two are interchangeable inch for inch',
    ],
    answer: 1,
    why:
        'One inch of asphalt for three of stone, near enough. That ratio is '
        'the whole economics of a section: asphalt is far more expensive per '
        'inch, so a designer trades it against base thickness until the cost '
        'comes out lowest for the same structural number.',
    source: 'trans-pd-q1',
  ),
  PavementSectionRound(
    subject: 'which course contributes most here',
    asked:
        'Three inches of asphalt, eight of base, ten of subbase. Which course '
        'contributes the most?',
    pavement: _lessonSection,
    options: [
      'The subbase, since it is the thickest',
      'The base',
      'The asphalt, narrowly, at 1.32 against 1.12 and 1.10',
      'They are equal by design',
    ],
    answer: 2,
    why:
        'The asphalt, just, even though it is the thinnest course by a long '
        'way. Three inches at 0.44 beats ten inches at 0.11. The three '
        'contributions here are close enough that no course can be called '
        'the important one, which is typical of a balanced section.',
    source: 'trans-pd-q1',
  ),
  PavementSectionRound(
    subject: 'a subbase that holds water',
    asked:
        'The same section, but the subbase drains badly and gets a drainage '
        'coefficient of 0.80. What happens?',
    pavement: _wetSubbase,
    options: [
      'Nothing: drainage is not in the equation',
      'Its contribution falls by a fifth, and the whole section is worth less',
      'Only the base is affected',
      'The asphalt has to be thinner',
    ],
    answer: 1,
    why:
        'Its contribution drops from 1.10 to 0.88, and the section falls from '
        '3.54 to 3.32. Wet granular material simply does not carry as well. '
        'Assuming a drainage coefficient of one when the problem gives a '
        'lower value is the mistake the lesson warns about, and it undersizes '
        'the pavement.',
    source: 'trans-pd-q1',
  ),
  PavementSectionRound(
    subject: 'where drainage does not apply',
    asked:
        'Which course does NOT get a drainage coefficient?',
    pavement: _wetSubbase,
    options: [
      'The surface course, which is taken as one by convention',
      'The base',
      'The subbase',
      'All of them get one',
    ],
    answer: 0,
    why:
        'The asphalt surface, which is taken as one. It is not granular and '
        'is not meant to hold water in the first place, so there is nothing '
        'for a drainage factor to describe. The factors belong to the base '
        'and subbase, which are exactly the courses that can sit wet.',
    source: 'trans-pd-q1',
  ),
  PavementSectionRound(
    subject: 'doubling the surface',
    asked:
        'The asphalt goes from three inches to six, everything else the same. '
        'What happens to the structural number?',
    pavement: _thickSurface,
    options: [
      'It doubles',
      'It rises by 1.32, from 3.54 to 4.86, since each extra inch is worth '
          '0.44',
      'It is unchanged',
      'It rises by 0.44',
    ],
    answer: 1,
    why:
        'Three more inches at 0.44 each is 1.32 more structure. The sum is '
        'linear in every thickness, which is what makes the design tractable: '
        'a designer can price each course per inch and choose the cheapest '
        'combination that reaches the number.',
    source: 'trans-pd-q1',
  ),
];

class _WhatEachInchBuysGameState extends State<WhatEachInchBuysGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-each-inch-buys',
    chapterId: 'transportation',
    total: pavementSectionRounds.length,
    sourceProblemIdOf: (round) => pavementSectionRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  PavementSectionRound get _round => pavementSectionRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Each Inch Buys',
        closing:
            'Coefficient times thickness times drainage, course by course, '
            'added up. An inch of asphalt does the work of about three '
            'inches of base, which is why sections are traded rather than '
            'simply thickened. The surface course takes a drainage factor of '
            'one, and the granular courses take whatever the problem says.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: structuralNumberBrief,
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
            'ADDING UP THE SECTION',
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
                  painter: PavementPainter(
                    pavement: r.pavement,
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
