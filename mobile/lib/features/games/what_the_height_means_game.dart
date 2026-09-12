import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'influence_figures.dart';

/// What the Height Means — the first item for `influence-lines`.
///
/// An influence line looks exactly like a diagram of the beam and is nothing
/// of the kind, and every wrong answer in the lesson starts there. The
/// across-axis is where the moving LOAD is standing, not where you are
/// looking at the beam, and the height is one fixed answer at one fixed
/// place. Until that is straight, the ordinates are just numbers to multiply
/// the wrong things by.
class WhatTheHeightMeansGame extends StatefulWidget {
  const WhatTheHeightMeansGame({super.key});

  @override
  State<WhatTheHeightMeansGame> createState() => _WhatTheHeightMeansGameState();
}

@immutable
class HeightRound {
  const HeightRound({
    required this.subject,
    required this.asked,
    required this.line,
    required this.loads,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Influence line;
  final List<(double, String)> loads;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const heightRounds = <HeightRound>[
  HeightRound(
    subject: 'what the across-axis is',
    asked:
        'This is the influence line for the moment at the marked section. '
        'What does a position along the bottom of the plot mean?',
    line: Influence(span: 24, response: Response.momentAt, at: 8),
    loads: [],
    options: [
      'Where the moving load is standing at that moment',
      'Where along the beam you are working the moment out',
      'How far the beam has deflected there',
      'Where the supports are',
    ],
    answer: 0,
    why:
        'Where the LOAD is standing. This is the whole difference between an '
        'influence line and a bending moment diagram, which is drawn for one '
        'fixed set of loads and reads across the beam. An influence line is '
        'drawn for one fixed PLACE and reads across all the positions the '
        'load might take. Same shape of picture, opposite question.',
    source: 'str-il-q2',
  ),
  HeightRound(
    subject: 'what the height is',
    asked:
        'The same line, and the unit load is standing where the marker shows. '
        'What does the height of the line under it tell you?',
    line: Influence(span: 24, response: Response.momentAt, at: 8),
    loads: [(14, 'the unit load')],
    options: [
      'The moment at the section while the load stands there',
      'The moment under the load itself',
      'The largest moment anywhere in the beam',
      'How far the beam sags under the load',
    ],
    answer: 0,
    why:
        'The moment AT THE SECTION, the place the line was drawn for, while '
        'the load stands where it is. The section does not move and the load '
        'does. Reading the height as the moment under the load is the same '
        'mistake as before wearing a different hat, and it gives the right '
        'answer only in the one round where the load happens to be standing '
        'on the section.',
    source: 'str-il-q2',
  ),
  HeightRound(
    subject: 'the one that looks like a diagram',
    asked:
        'A student says this triangle is the bending moment diagram of the '
        'beam. Is it?',
    line: Influence(span: 24, response: Response.momentAt, at: 12),
    loads: [],
    options: [
      'No: it is one moment, at midspan, for every position the load can take',
      'Yes: the moment diagram of a central point load is this triangle',
      'Yes, as long as the load really is at midspan',
      'No: a moment diagram would be curved',
    ],
    answer: 0,
    why:
        'No, and the resemblance is a trap worth naming. The moment diagram '
        'for a single central load IS a triangle of the same shape, so the '
        'two pictures agree by coincidence in this one case and nowhere else. '
        'Change the section and the influence line changes shape while the '
        'moment diagram of a given load does not.',
    source: 'str-il-q2',
  ),
  HeightRound(
    subject: 'the line for a reaction',
    asked:
        'This is the influence line for the reaction at the left support. Why '
        'does it start at one and finish at nothing?',
    line: Influence(span: 24, response: Response.leftReaction),
    loads: [],
    options: [
      'A load over the left support goes straight into it; the same load over '
          'the right support goes entirely into the other one',
      'Because the reaction is largest when the load is at midspan',
      'Because the beam is stiffer at the left end',
      'Because the left support is a pin and the right one is a roller',
    ],
    answer: 0,
    why:
        'Because a load sitting right on top of a support is carried entirely '
        'by that support, and a load at the far end is carried entirely by '
        'the other one. Everything between is shared in proportion, which is '
        'why the line is straight. Reaction influence lines are the easiest '
        'of the three to reconstruct from scratch under exam pressure.',
    source: 'str-il-q1',
  ),
  HeightRound(
    subject: 'the step in the middle',
    asked:
        'This is the influence line for the SHEAR at the marked section. Why '
        'does it jump straight down where the section is?',
    line: Influence(span: 24, response: Response.shearAt, at: 6),
    loads: [],
    options: [
      'Because the load crossing the section moves from one side of the cut '
          'to the other, and the shear changes by the whole unit load',
      'Because the beam is weakest at the section',
      'Because the shear diagram always has a jump there',
      'Because the section is closer to the left support',
    ],
    answer: 0,
    why:
        'Because of which side of the cut the load is on. Walk the unit load '
        'past the section and the piece you are holding loses it or gains it '
        'all at once, so the shear at the section changes by exactly one. '
        'That step of one is the signature of a shear influence line and the '
        'quickest way to tell it from any other line in the lesson.',
    source: 'str-il-q1',
  ),
  HeightRound(
    subject: 'two loads at once',
    asked:
        'Two loads stand on the beam at the marked places. How do you get the '
        'moment at the section for that arrangement?',
    line: Influence(span: 24, response: Response.momentAt, at: 12),
    loads: [(12, 'P1'), (18, 'P2')],
    options: [
      'Multiply each load by the height under it and add the two together',
      'Multiply the larger load by the peak height',
      'Add the loads together and multiply by the peak height',
      'Multiply each load by its distance from the section and add',
    ],
    answer: 0,
    why:
        'Each load times the height under it, added up. The influence line is '
        'built from a UNIT load, so a load of any size scales its own '
        'ordinate, and separate loads simply add. That is the whole of what '
        'an influence line is for, and it is also why the heights are worth '
        'getting right before any load is placed on them.',
    source: 'str-il-q3',
  ),
];

class _WhatTheHeightMeansGameState extends State<WhatTheHeightMeansGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-the-height-means',
    chapterId: 'structural',
    total: heightRounds.length,
    sourceProblemIdOf: (round) => heightRounds[round].source,
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

  HeightRound get _round => heightRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What the Height Means',
        closing:
            'An influence line is one answer at one place, plotted against '
            'every position the moving load can take. Across is where the '
            'load is standing; up is the reaction, shear or moment at the '
            'fixed place the line was drawn for. It is not a picture of the '
            'beam and not a moment diagram, however alike they look. Once '
            'that is straight, using it is only multiplying and adding.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: influenceBrief,
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
            'READING THE LINE',
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
            height: 212,
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
                  painter: InfluencePainter(
                    line: r.line,
                    loads: r.loads,
                    showOrdinates: answered && r.loads.isNotEmpty,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$R = \sum P_i \, \eta_i$',
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
