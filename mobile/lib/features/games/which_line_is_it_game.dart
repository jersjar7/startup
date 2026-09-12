import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'influence_figures.dart';

/// Which Line Is It — the second item for `influence-lines`.
///
/// The three shapes the lesson draws are unmistakable once they have been
/// looked at side by side: a straight run from one to nothing is a reaction,
/// a triangle peaking over the section is a moment, and the one with a step
/// of exactly one in it is a shear. Naming the shape is free marks on the
/// exam and it is also the check that catches a line drawn for the wrong
/// thing before any load is placed on it.
class WhichLineIsItGame extends StatefulWidget {
  const WhichLineIsItGame({super.key});

  @override
  State<WhichLineIsItGame> createState() => _WhichLineIsItGameState();
}

@immutable
class LineShapeRound {
  const LineShapeRound({
    required this.subject,
    required this.asked,
    required this.line,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Influence line;
  final String why;
  final String source;

  /// The line knows what it is for, so no round can mislabel its own figure.
  Response get answer => line.response;

  static String label(Response which) => switch (which) {
        Response.leftReaction => 'The reaction at the left support',
        Response.rightReaction => 'The reaction at the right support',
        Response.shearAt => 'The shear at the marked section',
        Response.momentAt => 'The moment at the marked section',
      };
}

const ilShapeRounds = <LineShapeRound>[
  LineShapeRound(
    subject: 'a straight run down',
    asked: 'What is this line drawn for?',
    line: Influence(span: 24, response: Response.leftReaction),
    why:
        'The reaction at the LEFT support. It is worth one when the load is '
        'sitting on that support, because then the support carries all of it, '
        'and nothing when the load has reached the far end. A straight line '
        'from one down to nothing can only be a reaction, and which end it '
        'starts at says which reaction.',
    source: 'str-il-q1',
  ),
  LineShapeRound(
    subject: 'a straight run up',
    asked: 'And this one?',
    line: Influence(span: 24, response: Response.rightReaction),
    why:
        'The reaction at the RIGHT support, which is the mirror image of the '
        'last one and for the mirror reason. Nothing while the load stands '
        'over the left support, all of it once the load reaches the right. '
        'The two reaction lines always add to one at every position, which is '
        'a quick way to check a pair of them.',
    source: 'str-il-q1',
  ),
  LineShapeRound(
    subject: 'a step of one',
    asked: 'What is this one for?',
    line: Influence(span: 30, response: Response.shearAt, at: 10),
    why:
        'The SHEAR at the section, and the step gives it away. Nothing else '
        'in the lesson jumps: the load crossing the section moves from one '
        'side of the cut to the other and the shear changes by the whole unit '
        'load at once. Measure the step on any shear line and it is exactly '
        'one, every time.',
    source: 'str-il-q1',
  ),
  LineShapeRound(
    subject: 'a triangle off to one side',
    asked: 'And this?',
    line: Influence(span: 30, response: Response.momentAt, at: 10),
    why:
        'The MOMENT at the section. The peak sits over the section, not at '
        'midspan, because a load standing on the section does the most for '
        'the moment there. Both a moment line and a shear line are drawn for '
        'a section, so the peak tells you where the section is in both cases; '
        'it is the step that tells you which is which.',
    source: 'str-il-q2',
  ),
  LineShapeRound(
    subject: 'the one everybody memorizes',
    asked: 'What is this line for?',
    line: Influence(span: 24, response: Response.momentAt, at: 12),
    why:
        'The moment at midspan, whose peak is a quarter of the span and which '
        'is the single most quoted influence line on the exam. It is '
        'symmetric only because the section happens to be in the middle: move '
        'the section and the triangle leans. Do not let the symmetric version '
        'become the only one you can draw.',
    source: 'str-il-q2',
  ),
  LineShapeRound(
    subject: 'a section near the end',
    asked: 'And this last one?',
    line: Influence(span: 30, response: Response.shearAt, at: 24),
    why:
        'Shear again, at a section near the far end this time. The step is '
        'still exactly one, but it is now mostly BELOW the axis, because with '
        'the section so far along, most positions of the load put it on the '
        'other side of the cut. The shape of a shear line follows the section '
        'about; only the size of its step stays put.',
    source: 'str-il-q1',
  ),
];

class _WhichLineIsItGameState extends State<WhichLineIsItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-line-is-it',
    chapterId: 'structural',
    total: ilShapeRounds.length,
    sourceProblemIdOf: (round) => ilShapeRounds[round].source,
  )..addListener(_onSession);

  Response? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LineShapeRound get _round => ilShapeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Line Is It',
        closing:
            'Three shapes and no others. A straight run between one and '
            'nothing is a reaction, and the end it starts at names which. A '
            'triangle peaking over the section is the moment there. A line '
            'with a step of exactly one in it is the shear, and the step is '
            'the only sure way to tell a shear line from a moment line, since '
            'both of them are drawn about a section.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: shapesBrief,
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
            'WHAT IS THE LINE FOR',
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
                  // The plot is not labeled with what it is for here: that is
                  // the question.
                  painter: InfluencePainter(line: r.line, named: false),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{one answer, at one place, as the load moves}$',
              style: const TextStyle(fontSize: 13, color: AppColors.ink3),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Response.values) ...[
            _Choice(
              label: LineShapeRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Response.values.last) const SizedBox(height: 8),
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
