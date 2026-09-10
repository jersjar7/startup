import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart';
import 'board.dart';
import 'diagram_figures.dart';
import 'lesson_brief.dart';

/// Jump, Bend or Neither — the third item for `shear-moment-diagrams`.
///
/// The lesson's first heading is sign conventions and its own warning is that
/// people mix up the sign of a reaction with the sign of the shear. Underneath
/// that is a smaller and more useful question: at THIS point on the beam, what
/// does the diagram actually do? A force makes the shear jump. A couple makes
/// the moment jump. Where a spread load starts, nothing jumps at all, the line
/// just bends. Getting those three apart is most of drawing a diagram
/// correctly, and none of it is arithmetic.
class JumpBendOrNeitherGame extends StatefulWidget {
  const JumpBendOrNeitherGame({super.key});

  @override
  State<JumpBendOrNeitherGame> createState() =>
      _JumpBendOrNeitherGameState();
}

/// What a diagram does at one point.
enum Does { jumpsUp, jumpsDown, bends, carriesOn }

extension DoesWords on Does {
  String get plain => switch (this) {
        Does.jumpsUp => 'It jumps UP',
        Does.jumpsDown => 'It jumps DOWN',
        Does.bends => 'It bends, without jumping',
        Does.carriesOn => 'It carries straight on',
      };
}

@immutable
class SpotRound {
  const SpotRound({
    required this.subject,
    required this.beam,
    required this.at,
    required this.asked,
    required this.why,
    required this.source,
    this.loadLabels = const <String>[],
  });

  final String subject;
  final Loading beam;

  /// The point being asked about.
  final double at;

  final Diagram asked;
  final List<String> loadLabels;
  final String why;
  final String source;

  /// Read off the diagram itself: is there a step, and if not, does the line
  /// leave at a different angle from the one it arrived at?
  Does get answer {
    final before = beam.valueOf(asked, at, after: false);
    final after = beam.valueOf(asked, at);
    final step = after - before;
    final scale = beam.peakMoment.abs() + beam.totalDown.abs();
    if (step.abs() > scale * 1e-6) {
      return step > 0 ? Does.jumpsUp : Does.jumpsDown;
    }
    const h = 1e-4;
    final inSlope = (before - beam.valueOf(asked, at - h, after: false)) / h;
    final outSlope = (beam.valueOf(asked, at + h) - after) / h;
    return (outSlope - inSlope).abs() > scale * 1e-4
        ? Does.bends
        : Does.carriesOn;
  }
}

const _six = Loading(span: 6, points: [(3, 18)]);
const _part = Loading(
  span: 8,
  spreads: [Spread(4, 8, 6, 6, label: '6 kN/m')],
);

const markRounds = <SpotRound>[
  SpotRound(
    subject: 'right at the left support',
    beam: _six,
    at: 0,
    asked: Diagram.shear,
    loadLabels: ['18 kN'],
    why:
        'Up, by the size of the reaction. Walking in from the left there is '
        'nothing on the beam yet, so the shear is zero; the moment you step '
        'past the support you are carrying its nine kilonewtons upward. This '
        'is the one the lesson warns about: the reaction points up and so does '
        'the step.',
    source: 'mm-smd-q1',
  ),
  SpotRound(
    subject: 'under the load',
    beam: _six,
    at: 3,
    asked: Diagram.shear,
    loadLabels: ['18 kN'],
    why:
        'Down, by the whole eighteen, from plus nine to minus nine in one '
        'step. A force always steps the shear by its own size, upward forces '
        'up and downward forces down. Nothing gradual happens at a point load, '
        'which is why the shear diagram is made of flat pieces here.',
    source: 'mm-smd-q1',
  ),
  SpotRound(
    subject: 'under that same load, the other diagram',
    beam: _six,
    at: 3,
    asked: Diagram.moment,
    loadLabels: ['18 kN'],
    why:
        'It bends. The moment is the running total of the shear, and a total '
        'cannot jump when the thing being totalled merely steps. What changes '
        'is the RATE: it was climbing at nine, now it falls at nine, so the '
        'line arrives going up and leaves going down. Only a couple can jump '
        'a moment diagram.',
    source: 'mm-smd-q1',
  ),
  SpotRound(
    subject: 'where the spread load begins',
    beam: _part,
    at: 4,
    asked: Diagram.shear,
    why:
        'It bends. Up to here the beam carries nothing along its length, so '
        'the shear is flat; from here the load starts eating into it at six '
        'kilonewtons per meter. No force acts AT this point, so there is '
        'nothing to jump by. A spread load changes the slope, never the value.',
    source: 'mm-smd-q2',
  ),
  SpotRound(
    subject: 'halfway along a uniform load',
    beam: Loading(span: 8, spreads: [Spread(0, 8, 5, 5, label: '5 kN/m')]),
    at: 4,
    asked: Diagram.shear,
    why:
        'It carries straight on. There is nothing special about the middle of '
        'a uniform load as far as the shear is concerned: the same load per '
        'meter before and after means the same slope before and after. The '
        'middle matters for the MOMENT, because that is where the shear '
        'happens to pass through zero.',
    source: 'mm-smd-q2',
  ),
  SpotRound(
    subject: 'where a couple is applied',
    beam: Loading(span: 8, couples: [(4, 24)]),
    at: 4,
    asked: Diagram.moment,
    why:
        'It jumps, by the size of the couple. This is the one thing that can '
        'step a moment diagram, and it does nothing whatever to the shear: no '
        'vertical force has been added, so nothing about the shear changes. A '
        'couple is how a bracket or an eccentric connection gets into a beam.',
    source: 'mm-smd-q3',
  ),
];

class _JumpBendOrNeitherGameState extends State<JumpBendOrNeitherGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'jump-bend-or-neither',
    chapterId: 'mechanics-materials',
    total: markRounds.length,
    sourceProblemIdOf: (round) => markRounds[round].source,
  )..addListener(_onSession);

  Does? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SpotRound get _round => markRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Jump, Bend or Neither',
        closing:
            'A vertical force steps the shear by its own size and bends the '
            'moment. A couple steps the moment and leaves the shear alone. '
            'The start or end of a spread load steps nothing and bends the '
            'shear. Everywhere else both lines carry straight on.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: jumpBrief,
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
            r.asked == Diagram.shear
                ? 'WHAT THE SHEAR DIAGRAM DOES HERE'
                : 'WHAT THE MOMENT DIAGRAM DOES HERE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'Walking from left to right, what happens to the '
            '${r.asked == Diagram.shear ? 'shear' : 'moment'} at the marked '
            'point?',
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
              height: 175,
              child: CustomPaint(
                painter: BeamPainter(
                  span: r.beam.span,
                  supports: supportsOf(r.beam),
                  spreads: r.beam.spreads,
                  loads: [
                    for (final (i, p) in r.beam.points.indexed)
                      (
                        p.$1,
                        i < r.loadLabels.length ? r.loadLabels[i] : kn(p.$2)
                      ),
                  ],
                  couples: [
                    for (final (pos, m) in r.beam.couples)
                      (pos, m < 0, '${m.abs().round()} kN·m'),
                  ],
                  stations: [Station(r.at, 'here')],
                  selected: 0,
                  locked: false,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final d in Does.values) ...[
            _Choice(
              label: d.plain,
              selected: _picked == d,
              locked: answered,
              isTruth: d == r.answer,
              onTap: answered ? null : () => setState(() => _picked = d),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT DOES' : 'NOT QUITE',
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
