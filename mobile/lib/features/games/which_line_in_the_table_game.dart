import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'beam_figures.dart';
import 'board.dart';
import 'deflection_figures.dart';
import 'diagram_figures.dart';
import 'lesson_brief.dart';

/// Which Line in the Table — the first item for `beam-deflections`.
///
/// The lesson says outright that nothing here is derived: you match the beam
/// in front of you to a line in the handbook's table. Both of its easier
/// problems name the same trap, which is matching it to the wrong line, and
/// its own warning puts a number on that: the cantilever entry on a simply
/// supported beam is out by sixteen times.
///
/// So the beam is drawn and the answer is which line it belongs to. No
/// arithmetic: the numbers are not even given.
class WhichLineInTheTableGame extends StatefulWidget {
  const WhichLineInTheTableGame({super.key});

  @override
  State<WhichLineInTheTableGame> createState() =>
      _WhichLineInTheTableGameState();
}

@immutable
class TableRound {
  const TableRound({
    required this.subject,
    required this.setting,
    required this.beam,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
    this.shows,
    this.at = 0,
  });

  final String subject;
  final String setting;

  /// The beam as drawn.
  final Loading beam;

  /// The lines on offer.
  final List<Entry> options;

  /// Which one it is, or minus one when the beam needs two lines added
  /// together and no single one will do.
  final int answer;

  /// The entry whose sag shape is worth showing once the answer is out.
  final Entry? shows;

  /// Where an off center load sits.
  final double at;

  final String why;
  final String source;
}

const _span = 6000.0;

final tableRounds = <TableRound>[
  TableRound(
    subject: 'a load in the middle',
    setting:
        'A simply supported beam with one load at midspan. Which line gives '
        'its worst sag?',
    beam: Entry.ssPoint.beamOf(span: _span),
    options: [Entry.cantPoint, Entry.ssPoint, Entry.ssUdl],
    answer: 1,
    shows: Entry.ssPoint,
    why:
        'P L cubed over forty eight E I. The first line is the same load on a '
        'cantilever, and the lesson puts a number on that mix up: sixteen '
        'times too much. The third has a w in it, and there is nothing spread '
        'along this beam. Read the supports first, then the load.',
    source: 'mm-bdf-q1',
  ),
  TableRound(
    subject: 'built in at one end, load spread along it',
    setting:
        'A cantilever carrying a load spread evenly over its whole length.',
    beam: Entry.cantUdl.beamOf(span: 4000),
    options: [Entry.ssUdl, Entry.cantUdl, Entry.cantPoint],
    answer: 1,
    shows: Entry.cantUdl,
    why:
        'w L to the fourth over eight E I. The first line is the same spread '
        'load on a beam held at both ends, which sags nearly ten times less. '
        'The third is a cantilever but with the load gathered at the tip. '
        'Both wrong lines are real table entries, which is exactly why the '
        'matching is the work.',
    source: 'mm-bdf-q2',
  ),
  TableRound(
    subject: 'held at both ends, load spread along it',
    setting: 'A simply supported beam under a load spread evenly all the way.',
    beam: Entry.ssUdl.beamOf(span: _span),
    options: [Entry.ssUdl, Entry.cantUdl, Entry.ssPoint],
    answer: 0,
    shows: Entry.ssUdl,
    why:
        'Five w L to the fourth over three hundred and eighty four E I, and '
        'the five on the top is the part people drop. Note the fourth power: a '
        'spread load always brings one more power of the span than a point '
        'load does, because there is more of it the longer the beam gets.',
    source: 'mm-bdf-q2',
  ),
  TableRound(
    subject: 'a load right at the tip',
    setting: 'A cantilever with a single load hanging at the free end.',
    beam: Entry.cantPoint.beamOf(span: 3000),
    options: [Entry.ssPoint, Entry.cantUdl, Entry.cantPoint],
    answer: 2,
    shows: Entry.cantPoint,
    why:
        'P L cubed over three E I, which is the one worth remembering because '
        'it is the softest arrangement in the table. Same beam, same load, '
        'held at both ends instead of one: sixteen times less sag. The '
        'supports matter more than anything else on this page.',
    source: 'mm-bdf-q1',
  ),
  TableRound(
    subject: 'a load nearer one end',
    setting:
        'A simply supported beam with one load, two meters along a six meter '
        'span rather than in the middle.',
    beam: Entry.ssOffset.beamOf(span: _span, at: 2000),
    options: [Entry.ssPoint, Entry.ssOffset, Entry.ssUdl],
    answer: 1,
    shows: Entry.ssOffset,
    at: 2000,
    why:
        'The off center line, P a squared b squared over three E I L. The '
        'midspan formula is the same beam with the load moved, and using it '
        'here overstates the sag. One more thing this line does not tell you: '
        'the worst sag is NOT under the load. It sits between the load and '
        'midspan, which is why the table gives the sag at the load as a '
        'separate quantity.',
    source: 'mm-bdf-q1',
  ),
  TableRound(
    subject: 'two loads at once',
    setting:
        'A simply supported beam carrying a load at midspan AND a load spread '
        'over the whole span.',
    beam: Loading(
      span: _span,
      points: [(_span / 2, 24000)],
      spreads: [Spread(0, _span, 4, 4, label: 'w')],
    ),
    options: [Entry.ssPoint, Entry.ssUdl, Entry.cantUdl],
    answer: -1,
    why:
        'None of them on its own. This beam is two table lines at once, and '
        'the way through is superposition: work out the sag from each load as '
        'though the other were not there, then add the two. That works because '
        'sag is proportional to load while the steel stays elastic. The first '
        'two lines are both right for half of this beam and wrong for the '
        'whole of it.',
    source: 'mm-bdf-q3',
  ),
];

class _WhichLineInTheTableGameState extends State<WhichLineInTheTableGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-line-in-the-table',
    chapterId: 'mechanics-materials',
    total: tableRounds.length,
    sourceProblemIdOf: (round) => tableRounds[round].source,
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

  TableRound get _round => tableRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Line in the Table',
        closing:
            'Read the supports, then the load. Held at both ends or built in '
            'at one. Gathered at a point or spread along. Those two questions '
            'pick the line, and picking the wrong one is out by ten or sixteen '
            'times rather than by a few percent. A beam with two loads needs '
            'two lines added together.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: tableBrief2,
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
            'TAP THE LINE THIS BEAM BELONGS TO',
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
          const SizedBox(height: 12),
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: answered && r.shows != null ? 110 : 140,
              child: CustomPaint(
                painter: BeamPainter(
                  span: r.beam.span,
                  supports: supportsOf(r.beam),
                  spreads: r.beam.spreads,
                  loads: [for (final p in r.beam.points) (p.$1, 'P')],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          if (answered && r.shows != null) ...[
            const SizedBox(height: 4),
            EngineeringGrid(
              minor: 18,
              major: 90,
              child: SizedBox(
                height: 110,
                child: CustomPaint(
                  painter: SagPainter(
                    entry: r.shows!,
                    span: r.beam.span,
                    at: r.at,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Line(
              tex: r.options[i].tex,
              note: r.options[i].plain,
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          _Line(
            tex: '',
            note: 'None on its own: this beam needs two lines added',
            selected: _picked == -1,
            locked: answered,
            isTruth: r.answer == -1,
            onTap: answered ? null : () => setState(() => _picked = -1),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE LINE' : 'A DIFFERENT LINE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.tex,
    required this.note,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String tex;
  final String note;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tex.isNotEmpty)
                MathText(
                  '\$$tex\$',
                  style:
                      const TextStyle(fontSize: 17, color: AppColors.charcoal),
                ),
              if (tex.isNotEmpty) const SizedBox(height: 4),
              Text(
                note,
                style: tex.isEmpty
                    ? const TextStyle(fontSize: 15, color: AppColors.charcoal)
                    : AppTheme.mono(size: 11, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
