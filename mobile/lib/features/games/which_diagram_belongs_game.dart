import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart';
import 'board.dart';
import 'diagram_figures.dart';
import 'lesson_brief.dart';

/// Which Diagram Belongs — the first item for `shear-moment-diagrams`.
///
/// The lesson's middle two headings are one idea in two sentences: the slope
/// of the shear diagram is minus the load, and the slope of the moment diagram
/// is the shear. Everything about the SHAPE of both diagrams follows from
/// that, and none of it is arithmetic. So the beam is drawn, three diagrams
/// are offered, and the wrong two are the two mistakes the rules exist to
/// prevent.
class WhichDiagramBelongsGame extends StatefulWidget {
  const WhichDiagramBelongsGame({super.key});

  @override
  State<WhichDiagramBelongsGame> createState() =>
      _WhichDiagramBelongsGameState();
}

/// What is wrong with a wrong diagram. Each one is a mistake with a name.
enum Twist {
  /// Nothing. This is the diagram of the beam above it.
  none,

  /// The other diagram of the same beam, offered when this one was asked for.
  other,

  /// The right shape upside down, which is a sign convention gone the wrong
  /// way.
  flipped,

  /// Straight where it should curve, or flat where it should slope, which is
  /// forgetting that a spread load is doing anything between the ends.
  blunt,

  /// The diagram this beam would have if the load sat at midspan, which is
  /// the assumption an off center load punishes.
  evened,
}

/// The line a twisted diagram draws.
List<Offset> variant(Loading beam, Diagram asked, Twist twist) {
  switch (twist) {
    case Twist.none:
      return beam.curve(asked);
    case Twist.other:
      return beam.curve(
          asked == Diagram.shear ? Diagram.moment : Diagram.shear);
    case Twist.flipped:
      return [for (final p in beam.curve(asked)) Offset(p.dx, -p.dy)];
    case Twist.blunt:
      final knots = <double>{...beam.breaks, ...beam.zeroShear}.toList()
        ..sort();
      if (asked == Diagram.moment) {
        // Straight lines from knot to knot: no curvature anywhere.
        return [
          for (final x in knots) Offset(x, beam.momentAt(x)),
        ];
      }
      // Shear held at whatever it was at the start of each stretch.
      final out = <Offset>[];
      for (var i = 0; i < knots.length - 1; i++) {
        final v = beam.shearAt(knots[i]);
        out
          ..add(Offset(knots[i], v))
          ..add(Offset(knots[i + 1], v));
      }
      return out;
    case Twist.evened:
      final even = Loading(
        span: beam.span,
        points: [(beam.span / 2, beam.totalDown)],
      );
      return even.curve(asked);
  }
}

@immutable
class ShapeRound {
  const ShapeRound({
    required this.subject,
    required this.beam,
    required this.asked,
    required this.options,
    required this.why,
    required this.source,
    this.loadLabels = const <String>[],
  });

  final String subject;
  final Loading beam;
  final Diagram asked;

  /// The three on offer, in the order they are drawn.
  final List<Twist> options;

  /// What to write beside each point load.
  final List<String> loadLabels;

  final String why;
  final String source;

  int get answer => options.indexOf(Twist.none);
}

const _six = Loading(span: 6, points: [(3, 18)]);
const _ten = Loading(span: 10, points: [(4, 30)]);
const _udl = Loading(span: 8, spreads: [Spread(0, 8, 5, 5, label: '5 kN/m')]);
const _tip = Loading(span: 4, held: Held.cantilever, points: [(4, 10)]);

const shapeRounds = <ShapeRound>[
  ShapeRound(
    subject: 'a load in the middle',
    beam: _six,
    asked: Diagram.shear,
    options: [Twist.none, Twist.flipped, Twist.other],
    loadLabels: ['18 kN'],
    why:
        'The first. Nothing is spread along this beam, so the shear cannot '
        'slope: it holds at plus nine from the left support, drops by the '
        'whole eighteen under the load, and holds at minus nine to the other '
        'support. The second is the same steps upside down, which is what a '
        'sign convention gone backwards looks like. The third is the moment '
        'diagram, which peaks where this one crosses zero.',
    source: 'mm-smd-q1',
  ),
  ShapeRound(
    subject: 'the same beam, the other diagram',
    beam: _six,
    asked: Diagram.moment,
    options: [Twist.other, Twist.none, Twist.flipped],
    loadLabels: ['18 kN'],
    why:
        'The second, a triangle with its peak under the load. It rises in a '
        'straight line because the shear is constant on the way, and the '
        'slope of the moment is the shear. The first is the shear diagram '
        'itself. The third hogs where this beam sags: a simply supported beam '
        'with a load on top bends concave upward, and the diagram goes with '
        'the bending.',
    source: 'mm-smd-q1',
  ),
  ShapeRound(
    subject: 'a uniform load, all the way',
    beam: _udl,
    asked: Diagram.shear,
    options: [Twist.blunt, Twist.other, Twist.none],
    why:
        'The third. A spread load takes the shear down steadily as you walk '
        'along, from plus twenty at one support through zero at the middle to '
        'minus twenty at the other. The first holds it flat, which is what '
        'you would draw if you forgot the load was there at all between the '
        'ends. The second curves, and a curve in the SHEAR would need a load '
        'that changes as it goes.',
    source: 'mm-smd-q2',
  ),
  ShapeRound(
    subject: 'the same uniform load, the moment',
    beam: _udl,
    asked: Diagram.moment,
    options: [Twist.none, Twist.blunt, Twist.flipped],
    why:
        'The first, a parabola. The shear is sloping, so the moment cannot '
        'climb at a steady rate: it climbs fast where the shear is big, '
        'flattens out where the shear runs to nothing, and turns over at the '
        'middle. The second is the same peak reached in straight lines, which '
        'is the commonest wrong drawing in the whole topic.',
    source: 'mm-smd-q2',
  ),
  ShapeRound(
    subject: 'a load nearer one end',
    beam: _ten,
    asked: Diagram.moment,
    options: [Twist.evened, Twist.none, Twist.flipped],
    loadLabels: ['30 kN'],
    why:
        'The second. The peak sits UNDER THE LOAD, four meters along, not in '
        'the middle of the beam. The first is what this beam would do if the '
        'load were at midspan, and it is the shape most people draw from '
        'memory. The peak follows the load because the peak follows the point '
        'where the shear changes sign, and that is where the load is.',
    source: 'mm-smd-q3',
  ),
  ShapeRound(
    subject: 'built in at one end',
    beam: _tip,
    asked: Diagram.moment,
    options: [Twist.flipped, Twist.other, Twist.none],
    loadLabels: ['10 kN'],
    why:
        'The third. A cantilever hogs, so its moment diagram sits BELOW the '
        'line: zero at the free end, worst at the wall, a straight line '
        'between. The first is that shape sagging, which is the same drawing '
        'a simply supported beam would give. The second is the shear, which '
        'on this beam is the same value the whole way along.',
    source: 'mm-smd-q1',
  ),
];

class _WhichDiagramBelongsGameState extends State<WhichDiagramBelongsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-diagram-belongs',
    chapterId: 'mechanics-materials',
    total: shapeRounds.length,
    sourceProblemIdOf: (round) => shapeRounds[round].source,
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

  ShapeRound get _round => shapeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Diagram Belongs',
        closing:
            'The slope of the shear is minus the load. The slope of the '
            'moment is the shear. Nothing spread on the beam means flat '
            'shear and straight moment; a uniform load means sloping shear '
            'and a curved moment. Read the beam and the shapes are decided '
            'before you compute anything.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: slopeRulesBrief,
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
                ? 'TAP THE SHEAR DIAGRAM FOR THIS BEAM'
                : 'TAP THE MOMENT DIAGRAM FOR THIS BEAM',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 140,
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
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Panel(
              beam: r.beam,
              curve: variant(r.beam, r.asked, r.options[i]),
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'shape only. each one is drawn to its own height',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT BEAM',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.beam,
    required this.curve,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Loading beam;
  final List<Offset> curve;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color tone;
    if (locked && isTruth) {
      border = AppColors.forest;
      tone = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      tone = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      tone = AppColors.ember;
    } else {
      border = AppColors.line;
      tone = AppColors.info;
    }

    // Each panel is drawn to its own tallest value: the question is which
    // SHAPE belongs to the beam, and how tall it is drawn says nothing.
    var peak = 0.0;
    for (final p in curve) {
      if (p.dy.abs() > peak) peak = p.dy.abs();
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: CustomPaint(
            painter: DiagramPainter(
              curve: curve,
              span: beam.span,
              peak: peak,
              tone: tone,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
