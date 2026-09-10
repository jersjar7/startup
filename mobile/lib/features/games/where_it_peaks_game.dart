import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart';
import 'board.dart';
import 'diagram_figures.dart';
import 'lesson_brief.dart';

/// Where It Peaks — the second item for `shear-moment-diagrams`.
///
/// Every problem in this lesson asks for the maximum moment, and every one of
/// them is two steps: find WHERE it happens, then work out how big it is
/// there. The second step is arithmetic and belongs on paper. The first is a
/// judgment, it is where the marks are lost, and the lesson's hard problem is
/// built on it: an off center load does not peak at midspan.
///
/// So the beam is drawn with places marked on it and the answer is which one
/// carries the worst bending, sagging or hogging.
class WhereItPeaksGame extends StatefulWidget {
  const WhereItPeaksGame({super.key});

  @override
  State<WhereItPeaksGame> createState() => _WhereItPeaksGameState();
}

@immutable
class PeakRound {
  const PeakRound({
    required this.subject,
    required this.beam,
    required this.spots,
    required this.why,
    required this.source,
    this.loadLabels = const <String>[],
  });

  final String subject;
  final Loading beam;

  /// The places offered, in beam units.
  final List<double> spots;

  final List<String> loadLabels;
  final String why;
  final String source;

  /// Which of the marked places carries the biggest bending moment. Worked
  /// out from the beam, never declared beside the round.
  int get answer {
    var best = -1.0;
    var at = 0;
    for (var i = 0; i < spots.length; i++) {
      final m = beam.momentAt(spots[i]).abs();
      final other = beam.momentAt(spots[i], after: false).abs();
      final worst = m > other ? m : other;
      if (worst > best + 1e-9) {
        best = worst;
        at = i;
      }
    }
    return at;
  }
}

const peakRounds = <PeakRound>[
  PeakRound(
    subject: 'a load in the middle',
    beam: Loading(span: 6, points: [(3, 18)]),
    spots: [0, 1.5, 3, 4.5, 6],
    loadLabels: ['18 kN'],
    why:
        'Under the load, in the middle, where the shear passes through zero. '
        'The two ends are pinned and a pin cannot hold a moment, so the '
        'diagram starts and finishes at nothing whatever the beam is carrying.',
    source: 'mm-smd-q1',
  ),
  PeakRound(
    subject: 'the same load, moved along',
    beam: Loading(span: 10, points: [(4, 30)]),
    spots: [0, 4, 6, 8, 10],
    loadLabels: ['30 kN'],
    why:
        'Under the load at four meters, not at midspan. This is the lesson\'s '
        'hard problem and its whole trap: the moment at midspan, one meter '
        'further along, is a real number, sixty, and it answers a question '
        'nobody asked. The peak '
        'follows the load, because the peak is where the shear changes sign '
        'and the shear changes sign where the load is.',
    source: 'mm-smd-q3',
  ),
  PeakRound(
    subject: 'a uniform load',
    beam: Loading(span: 8, spreads: [Spread(0, 8, 5, 5, label: '5 kN/m')]),
    spots: [0, 2, 4, 6, 8],
    loadLabels: [],
    why:
        'The middle, because the load is symmetric and the shear runs to zero '
        'there. Note how flat the peak is on a uniform load: the quarter '
        'point already carries thirty of the forty, so being a little off '
        'center hardly changes what the beam has to hold.',
    source: 'mm-smd-q2',
  ),
  PeakRound(
    subject: 'two loads, not the same size',
    beam: Loading(span: 10, points: [(3, 30), (7, 10)]),
    spots: [0, 3, 5, 7, 10],
    loadLabels: ['30 kN', '10 kN'],
    why:
        'Under the heavier load at three meters. Walk the shear along: it '
        'starts at plus twenty four, drops through zero under the first load, '
        'and stays negative from there on. It only crosses zero once, and that '
        'crossing is the peak. Midspan is offered here and it is worth '
        'sixty against the seventy two under the load: a real number, and the '
        'wrong one. Nothing later can beat the crossing, because from there '
        'the moment only comes back down.',
    source: 'mm-smd-q3',
  ),
  PeakRound(
    subject: 'built in at the wall',
    beam: Loading(
      span: 4,
      held: Held.cantilever,
      spreads: [Spread(0, 4, 6, 6, label: '6 kN/m')],
    ),
    spots: [0, 1, 2, 3, 4],
    loadLabels: [],
    why:
        'At the wall. A cantilever is the other way round from everything '
        'else in this lesson: nothing at the free end, worst where it is held. '
        'The whole load is hanging off that one connection and every meter of '
        'lever arm counts against it.',
    source: 'mm-smd-q2',
  ),
  PeakRound(
    subject: 'a beam that hangs over its support',
    beam: Loading(span: 10, b: 8, points: [(10, 12)]),
    spots: [0, 3, 6, 8, 10],
    loadLabels: ['12 kN'],
    why:
        'Over the right hand support, eight meters along, and the beam is '
        'hogging there rather than sagging. The overhang is a cantilever '
        'sticking out past the support, so the support is its wall. The worst '
        'moment on a beam is not always between the supports, and it is not '
        'always sagging.',
    source: 'mm-smd-q3',
  ),
];

class _WhereItPeaksGameState extends State<WhereItPeaksGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-it-peaks',
    chapterId: 'mechanics-materials',
    total: peakRounds.length,
    sourceProblemIdOf: (round) => peakRounds[round].source,
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

  PeakRound get _round => peakRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where It Peaks',
        closing:
            'The moment peaks where the shear passes through zero. Under the '
            'load when there is one load, at the middle when the load is '
            'spread evenly, at the wall on a cantilever, and over the support '
            'when something hangs past it. Find the place first. The size of '
            'it is arithmetic, and arithmetic belongs on paper.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: peakBrief,
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
            'TAP WHERE THE BENDING IS WORST',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          const Text(
            'Sagging or hogging, whichever is bigger.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 190);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        var best = 34.0;
                        int? hit;
                        for (var i = 0; i < r.spots.length; i++) {
                          final at = BeamPainter.stationAt(
                              size, r.beam.span, r.spots[i]);
                          final gap = (at - details.localPosition).distance;
                          if (gap < best) {
                            best = gap;
                            hit = i;
                          }
                        }
                        if (hit != null) setState(() => _picked = hit);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: BeamPainter(
                        span: r.beam.span,
                        supports: supportsOf(r.beam),
                        spreads: r.beam.spreads,
                        loads: [
                          for (final (i, p) in r.beam.points.indexed)
                            (
                              p.$1,
                              i < r.loadLabels.length
                                  ? r.loadLabels[i]
                                  : kn(p.$2)
                            ),
                        ],
                        stations: [
                          for (final x in r.spots)
                            Station(x, '${_meters(x)} m'),
                        ],
                        selected: _picked,
                        locked: answered,
                        truth: answered ? r.answer : -1,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE PLACE' : 'SOMEWHERE ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

String _meters(double x) =>
    x == x.roundToDouble() ? x.round().toString() : x.toString();
