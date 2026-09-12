import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'influence_figures.dart';

/// Where Do You Park It — the third item for `influence-lines`.
///
/// Once the line is drawn, the question the exam actually asks is where to
/// stand the moving load to make the answer as large as it will go, and the
/// rule is the same every time: on the tallest part of the line, and the
/// heaviest load on the tallest part of all. The arithmetic that follows
/// belongs on paper. Choosing the spot does not.
class WhereDoYouParkItGame extends StatefulWidget {
  const WhereDoYouParkItGame({super.key});

  @override
  State<WhereDoYouParkItGame> createState() => _WhereDoYouParkItGameState();
}

@immutable
class ParkRound {
  const ParkRound({
    required this.subject,
    required this.asked,
    required this.line,
    required this.parked,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Influence line;

  /// Where the loads end up once the right answer is out, which is drawn on
  /// the line rather than described.
  final List<(double, String)> parked;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const parkRounds = <ParkRound>[
  ParkRound(
    subject: 'one load, the moment at midspan',
    asked:
        'A single load can stand anywhere on this 24 foot span. Where does it '
        'go to make the moment at midspan as large as possible?',
    line: Influence(span: 24, response: Response.momentAt, at: 12),
    parked: [(12, 'P')],
    options: [
      'Right at midspan, on the peak of the line',
      'Over one of the supports',
      'A quarter of the way along',
      'Anywhere: a single load gives the same moment wherever it stands',
    ],
    answer: 0,
    why:
        'On the peak, which for a midspan moment line is midspan itself. The '
        'rule never changes: the load goes where the line is tallest, because '
        'the answer is the load times the height under it. Everything else in '
        'this item is that one sentence applied to a line of a different '
        'shape.',
    source: 'str-il-q2',
  ),
  ParkRound(
    subject: 'one load, the shear at a section',
    asked:
        'The same kind of question for the SHEAR at a section 6 feet from the '
        'left support of a 24 foot span. Where does the load go for the '
        'largest positive shear there?',
    line: Influence(span: 24, response: Response.shearAt, at: 6),
    parked: [(6, 'P')],
    options: [
      'Just to the right of the section',
      'Just to the left of the section',
      'At midspan',
      'Over the right support',
    ],
    answer: 0,
    why:
        'Just to the right of the section, where the line is at its tallest '
        'above the axis. Step across to the left of the section and the '
        'ordinate is not merely smaller, it is NEGATIVE: the same load now '
        'makes the shear go the other way. On a shear line, which side of the '
        'section the load stands on is the whole question.',
    source: 'str-il-q1',
  ),
  ParkRound(
    subject: 'one load, the reaction',
    asked:
        'And for the largest reaction at the left support?',
    line: Influence(span: 24, response: Response.leftReaction),
    parked: [(0, 'P')],
    options: [
      'Right over the left support',
      'At midspan',
      'Over the right support',
      'A third of the way along',
    ],
    answer: 0,
    why:
        'Over the support itself, where the line is worth one and the support '
        'carries the whole load. The same rule again, and this is the easiest '
        'of the three lines to sanity-check: no support can ever be asked to '
        'carry more than the whole of a load standing on top of it.',
    source: 'str-il-q1',
  ),
  ParkRound(
    subject: 'a section that is not the middle',
    asked:
        'A 30 foot span, and the question asks for the largest moment at a '
        'section 10 feet from the left support. Where does the single load '
        'go?',
    line: Influence(span: 30, response: Response.momentAt, at: 10),
    parked: [(10, 'P')],
    options: [
      'At the section, 10 feet along',
      'At midspan, where the beam is weakest',
      'Over the nearer support',
      'Fifteen feet along, halfway between the section and the far end',
    ],
    answer: 0,
    why:
        'At the section. The peak of a moment influence line sits over the '
        'section it was drawn for, wherever that is, so a question about a '
        'quarter point is answered at the quarter point. Sliding the load to '
        'midspan out of habit is the commonest wrong answer here, and it '
        'gives a smaller moment at the place that was actually asked about.',
    source: 'str-il-q2',
  ),
  ParkRound(
    subject: 'two loads that travel together',
    asked:
        'Two loads 8 feet apart cross a 40 foot span together: 20 kips and 10 '
        'kips. Where do they go for the largest moment at midspan?',
    line: Influence(span: 40, response: Response.momentAt, at: 20),
    parked: [(20, '20 k'), (28, '10 k')],
    options: [
      'The heavier one at midspan, with the lighter one 8 feet along from it',
      'The lighter one at midspan, with the heavier one 8 feet along',
      'Straddling midspan, one load 4 feet each side',
      'Both as far to the right as they will fit',
    ],
    answer: 0,
    why:
        'The heavier load on the peak. The pair cannot both stand at midspan, '
        'so the tallest ordinate goes to the load that will make the most of '
        'it. Straddling looks fair and is worth less: it gives both loads the '
        'same middling height, and the 20 kips loses more than the 10 kips '
        'gains. This is the lesson\'s own hard problem, and it is decided '
        'before any multiplying starts.',
    source: 'str-il-q3',
  ),
  ParkRound(
    subject: 'a load that is spread out',
    asked:
        'Now a uniform load long enough to cover part of the span, and the '
        'question is again the largest POSITIVE shear at the section. Which '
        'part of the beam do you cover?',
    line: Influence(span: 24, response: Response.shearAt, at: 6),
    parked: [],
    options: [
      'Only the part where the line is above the axis, to the right of the '
          'section',
      'The whole span, so that every bit of it is working',
      'Only the part to the left of the section',
      'The middle third, where the line is closest to its average',
    ],
    answer: 0,
    why:
        'Only the positive part. A spread load contributes the AREA under the '
        'line beneath it, so covering ground where the line is below the axis '
        'subtracts from the answer. Covering the whole span is the wrong '
        'answer that feels safe: it quietly cancels part of what you are '
        'trying to maximize.',
    source: 'str-il-q1',
  ),
];

class _WhereDoYouParkItGameState extends State<WhereDoYouParkItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-do-you-park-it',
    chapterId: 'structural',
    total: parkRounds.length,
    sourceProblemIdOf: (round) => parkRounds[round].source,
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

  ParkRound get _round => parkRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where Do You Park It',
        closing:
            'The load goes where the line is tallest, and when several travel '
            'together the heaviest one gets the tallest spot. For shear that '
            'means just to the right of the section, for a moment it means on '
            'the section itself, and for a reaction it means over the '
            'support. A spread load covers only the ground where the line is '
            'on the side you want, because the rest of it would cancel.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: placeBrief,
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
            'WHERE DOES THE LOAD GO',
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
                  // The loads are only drawn once the round is over: where
                  // they stand is the question.
                  painter: InfluencePainter(
                    line: r.line,
                    loads: answered ? r.parked : const [],
                    showOrdinates: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\text{the load goes where the line is tallest}$',
              style: const TextStyle(fontSize: 13, color: AppColors.ink3),
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
              title: _session.correct! ? 'THAT IS THE SPOT' : 'NOT THERE',
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
