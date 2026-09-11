import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart';
import 'board.dart';
import 'deflection_figures.dart';
import 'diagram_figures.dart';
import 'lesson_brief.dart';

/// Add It Up — the third item for `beam-deflections`.
///
/// The hard problem in this lesson is superposition, and the arithmetic in it
/// is adding two numbers, which is not worth a phone. What IS worth it is the
/// step before: taking a beam that is in no table and seeing the two table
/// beams that add up to it. Get that wrong and the two numbers you add are the
/// wrong two.
///
/// So the beam is drawn, three ways of splitting it are drawn under it, and
/// the answer is which pair really adds back up to the beam above.
class AddItUpGame extends StatefulWidget {
  const AddItUpGame({super.key});

  @override
  State<AddItUpGame> createState() => _AddItUpGameState();
}

@immutable
class SplitRound {
  const SplitRound({
    required this.subject,
    required this.whole,
    required this.pairs,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;

  /// The beam as it really is.
  final Loading whole;

  /// The ways of splitting it on offer, each a pair of table beams.
  final List<(Loading, Loading)> pairs;

  /// Which pair adds back up to the whole beam, or minus one when the beam is
  /// a table entry already and needs no splitting at all.
  final int answer;

  final String why;
  final String source;
}

const _l = 6000.0;

final splitRounds = <SplitRound>[
  SplitRound(
    subject: 'a load in the middle and a load spread along',
    whole: Loading(
      span: _l,
      points: [(_l / 2, 24000)],
      spreads: [Spread(0, _l, 4, 4)],
    ),
    pairs: [
      (Entry.ssPoint.beamOf(span: _l), Entry.cantUdl.beamOf(span: _l)),
      (Entry.ssPoint.beamOf(span: _l), Entry.ssUdl.beamOf(span: _l)),
      (Entry.ssOffset.beamOf(span: _l, at: 1500),
          Entry.ssUdl.beamOf(span: _l)),
    ],
    answer: 1,
    why:
        'The middle pair: the same beam with only the point load, plus the '
        'same beam with only the spread load. The first pair changes the '
        'supports halfway through, which is not the same beam at all. The '
        'third moves the point load off center. Superposition only works if '
        'every piece is the SAME beam carrying part of the load.',
    source: 'mm-bdf-q3',
  ),
  SplitRound(
    subject: 'a cantilever carrying both kinds at once',
    whole: Loading(
      span: 4000,
      held: Held.cantilever,
      points: [(4000, 12000)],
      spreads: [Spread(0, 4000, 6, 6)],
    ),
    pairs: [
      (Entry.cantPoint.beamOf(span: 4000), Entry.cantUdl.beamOf(span: 4000)),
      (Entry.cantPoint.beamOf(span: 4000), Entry.ssUdl.beamOf(span: 4000)),
      (Entry.ssPoint.beamOf(span: 4000), Entry.cantUdl.beamOf(span: 4000)),
    ],
    answer: 0,
    why:
        'The first pair, both of them cantilevers. The other two swap the '
        'supports for one of the halves, and the lesson has already put a '
        'number on what that costs: the same load held at both ends instead of '
        'one is out by sixteen times. Split the LOAD, never the supports.',
    source: 'mm-bdf-q3',
  ),
  SplitRound(
    subject: 'two loads, neither in the middle',
    whole: Loading(
      span: _l,
      points: [(2000, 15000), (4000, 15000)],
    ),
    pairs: [
      (Entry.ssPoint.beamOf(span: _l), Entry.ssPoint.beamOf(span: _l)),
      (Entry.ssOffset.beamOf(span: _l, at: 2000),
          Entry.ssOffset.beamOf(span: _l, at: 4000)),
      (Entry.ssOffset.beamOf(span: _l, at: 2000),
          Entry.ssUdl.beamOf(span: _l)),
    ],
    answer: 1,
    why:
        'The middle pair, one off center line for each load, at two meters and '
        'at four. The first pair puts both loads at midspan, which is a '
        'different beam and would overstate the sag. Two loads means two '
        'lookups, and there is nothing wrong with using the same line twice '
        'with different numbers in it.',
    source: 'mm-bdf-q3',
  ),
  SplitRound(
    subject: 'an off center load with a spread load over it',
    whole: Loading(
      span: _l,
      points: [(1500, 20000)],
      spreads: [Spread(0, _l, 5, 5)],
    ),
    pairs: [
      (Entry.ssUdl.beamOf(span: _l),
          Entry.ssOffset.beamOf(span: _l, at: 1500)),
      (Entry.ssUdl.beamOf(span: _l), Entry.ssPoint.beamOf(span: _l)),
      (Entry.cantUdl.beamOf(span: _l),
          Entry.ssOffset.beamOf(span: _l, at: 1500)),
    ],
    answer: 0,
    why:
        'The first pair. Order does not matter when you are adding, but which '
        'line you take for each piece does: the point load is at a quarter '
        'span, so it needs the off center line and not the midspan one. Note '
        'that the two pieces do not even peak in the same place, and you can '
        'still add them at the point you care about.',
    source: 'mm-bdf-q3',
  ),
  SplitRound(
    subject: 'two loads, one of them central',
    whole: Loading(
      span: _l,
      points: [(_l / 2, 18000), (4500, 9000)],
    ),
    pairs: [
      (Entry.ssOffset.beamOf(span: _l, at: 4500),
          Entry.ssOffset.beamOf(span: _l, at: 4500)),
      (Entry.ssPoint.beamOf(span: _l), Entry.ssUdl.beamOf(span: _l)),
      (Entry.ssPoint.beamOf(span: _l),
          Entry.ssOffset.beamOf(span: _l, at: 4500)),
    ],
    answer: 2,
    why:
        'The last pair: the midspan line for the load in the middle and the '
        'off center line for the other one. The first pair uses the off center '
        'line twice at the same place, which is one of these loads counted '
        'twice and the other ignored. The second turns a point load into a '
        'spread one, which it is not.',
    source: 'mm-bdf-q3',
  ),
  SplitRound(
    subject: 'one load and nothing else',
    whole: Loading(span: _l, points: [(_l / 2, 30000)]),
    pairs: [
      (Entry.ssPoint.beamOf(span: _l), Entry.ssUdl.beamOf(span: _l)),
      (Entry.ssPoint.beamOf(span: _l), Entry.ssPoint.beamOf(span: _l)),
      (Entry.ssOffset.beamOf(span: _l, at: 2000),
          Entry.ssOffset.beamOf(span: _l, at: 4000)),
    ],
    answer: -1,
    why:
        'None of them: this beam is already a line in the table, so splitting '
        'it adds load that is not there. The second pair is the same beam '
        'twice, which is double the load. Superposition is for beams the table '
        'does not have, and reaching for it when one lookup would do is its '
        'own kind of mistake.',
    source: 'mm-bdf-q1',
  ),
];

class _AddItUpGameState extends State<AddItUpGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'add-it-up',
    chapterId: 'mechanics-materials',
    total: splitRounds.length,
    sourceProblemIdOf: (round) => splitRounds[round].source,
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

  SplitRound get _round => splitRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Add It Up',
        closing:
            'Split the LOAD and never the supports. Every piece has to be the '
            'same beam, held the same way, carrying part of what the real one '
            'carries. Then look each piece up and add the answers. And a beam '
            'that is already in the table needs no splitting at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: addBrief,
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
            'TAP THE SPLIT THAT ADDS BACK UP',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          const Text(
            'This is the beam. Which pair of table beams adds up to it?',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 10),
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 120,
              child: CustomPaint(
                painter: BeamPainter(
                  span: r.whole.span,
                  supports: supportsOf(r.whole),
                  spreads: r.whole.spreads,
                  loads: [for (final p in r.whole.points) (p.$1, '')],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.pairs.length; i++) ...[
            _Split(
              pair: r.pairs[i],
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          _Refuse(
            selected: _picked == -1,
            locked: answered,
            isTruth: r.answer == -1,
            onTap: answered ? null : () => setState(() => _picked = -1),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SPLIT' : 'THAT IS A DIFFERENT BEAM',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Split extends StatelessWidget {
  const _Split({
    required this.pair,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final (Loading, Loading) pair;
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: CustomPaint(
            painter: PairPainter2(left: pair.$1, right: pair.$2),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _Refuse extends StatelessWidget {
  const _Refuse({
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

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
          child: const Text(
            'No split needed: it is a table entry already',
            style: TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
