import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';

/// Rank Them by Stiffness — the first item for `area-moments-of-inertia`.
///
/// The lesson opens with the one sentence the whole topic hangs on: the
/// farther the material sits from the axis, the larger the moment of inertia.
/// Everything else, the cubed height, the transfer term, why an I-beam looks
/// the way it does, is that sentence with arithmetic on it.
///
/// So the arithmetic is gone and the sentence is the whole item. Three
/// sections are drawn to ONE scale with the axis they bend about marked on
/// each, and they are tapped in order, stiffest first. Most rounds hold the
/// area fixed so nothing is being asked except where the material went.
class RankByStiffnessGame extends StatefulWidget {
  const RankByStiffnessGame({super.key});

  @override
  State<RankByStiffnessGame> createState() => _RankByStiffnessGameState();
}

@immutable
class RankRound {
  const RankRound({
    required this.subject,
    required this.setting,
    required this.shapes,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final List<Profile> shapes;
  final String why;
  final String source;

  /// Stiffest first, worked out from the sections themselves.
  List<int> get answer {
    final order = [for (var i = 0; i < shapes.length; i++) i];
    order.sort((a, b) => shapes[b].ownIx.compareTo(shapes[a].ownIx));
    return order;
  }
}

/// A plank, three ways, all the same area.
const _onEdge = Profile([Piece(Slab.box, Offset.zero, Size(30, 120))]);
const _square = Profile([Piece(Slab.box, Offset.zero, Size(60, 60))]);
const _flat = Profile([Piece(Slab.box, Offset.zero, Size(120, 30))]);

/// A tube, a solid bar and a plate, all the same area.
const _tube = Profile([
  Piece(Slab.disc, Offset.zero, Size(120, 120)),
  Piece(Slab.disc, Offset(10.6, 10.6), Size(98.8, 98.8), hole: true),
]);
const _bar = Profile([Piece(Slab.disc, Offset.zero, Size(68, 68))]);
const _plate = Profile([Piece(Slab.box, Offset.zero, Size(121, 30))]);

/// Same area and same depth, spread three ways.
const _iBeam = Profile([
  Piece(Slab.box, Offset(0, 0), Size(100, 15)),
  Piece(Slab.box, Offset(42.5, 15), Size(15, 120)),
  Piece(Slab.box, Offset(0, 135), Size(100, 15)),
]);
const _tallSolid = Profile([Piece(Slab.box, Offset.zero, Size(32, 150))]);
const _fatSquare = Profile([Piece(Slab.box, Offset.zero, Size(69.3, 69.3))]);

/// Same width, three depths.
const _deep = Profile([Piece(Slab.box, Offset.zero, Size(40, 120))]);
const _middling = Profile([Piece(Slab.box, Offset.zero, Size(40, 90))]);
const _shallow = Profile([Piece(Slab.box, Offset.zero, Size(40, 60))]);

/// Same area, same overall depth, material put in three different places.
const _atTheEdges = Profile([
  Piece(Slab.box, Offset(0, 0), Size(90, 20)),
  Piece(Slab.box, Offset(0, 100), Size(90, 20)),
]);
const _spreadEvenly = Profile([Piece(Slab.box, Offset.zero, Size(30, 120))]);
const _bunchedMiddle = Profile([Piece(Slab.box, Offset(0, 50), Size(180, 20))]);

/// Same outer size, hollowed out or not.
const _solidPost = Profile([Piece(Slab.box, Offset.zero, Size(100, 100))]);
const _hollowPost = Profile([
  Piece(Slab.box, Offset.zero, Size(100, 100)),
  Piece(Slab.box, Offset(10, 10), Size(80, 80), hole: true),
]);
const _littlePost = Profile([Piece(Slab.box, Offset.zero, Size(60, 60))]);

const rankRounds = <RankRound>[
  RankRound(
    subject: 'one plank, three ways up',
    setting:
        'The same plank on edge, a square of the same area, and the plank laid '
        'flat. Every one of them is the same amount of timber. Tap them '
        'stiffest first.',
    shapes: [_flat, _onEdge, _square],
    why:
        'On edge, then the square, then flat. Nothing here changed but the '
        'depth, and depth is CUBED in the formula while width is not, so '
        'turning the plank on edge multiplies its stiffness sixteen times over '
        'for exactly the same wood. It is why joists stand on edge.',
    source: 'stat-ami-q1',
  ),
  RankRound(
    subject: 'a tube, a bar and a plate',
    setting:
        'A hollow tube, a solid round bar, and a flat plate. All three have '
        'the same area of metal in them.',
    shapes: [_bar, _tube, _plate],
    why:
        'The tube, then the bar, then the plate. The tube wins because every '
        'bit of its metal is a long way from the axis, and the plate loses '
        'because all of its metal is close to the axis. Hollow sections are '
        'not a trick: they are where the material does the most good.',
    source: 'stat-ami-q1',
  ),
  RankRound(
    subject: 'why a beam is shaped like an I',
    setting:
        'An I-beam, a solid rectangle of the SAME depth and the same area, and '
        'a square of that area again.',
    shapes: [_tallSolid, _fatSquare, _iBeam],
    why:
        'The I-beam, then the tall rectangle, then the square. The I-beam and '
        'the rectangle are the same amount of steel at the same depth, and the '
        'I-beam still wins because it moved that steel out to the flanges '
        'where it counts. The web is barely doing anything, which is exactly '
        'why it is thin.',
    source: 'stat-ami-q1',
  ),
  RankRound(
    subject: 'three depths of the same joist',
    setting:
        'The same width of timber cut to three different depths. This time '
        'they are NOT the same area, and the deepest has twice the material of '
        'the shallowest.',
    shapes: [_middling, _shallow, _deep],
    why:
        'Deepest, middling, shallowest. Twice the material buys eight times '
        'the stiffness here, not twice: the depth is cubed and the area only '
        'grows with it. Doubling the depth of a beam is the cheapest stiffness '
        'there is.',
    source: 'stat-ami-q1',
  ),
  RankRound(
    subject: 'the same steel put in three places',
    setting:
        'Three sections with the same area of steel in them. One puts it out '
        'at the top and bottom, one spreads it evenly, and one rolls it out '
        'flat and keeps it all near the middle.',
    shapes: [_bunchedMiddle, _atTheEdges, _spreadEvenly],
    why:
        'At the edges, then spread evenly, then bunched in the middle. Same '
        'steel, same depth, and a factor of seventy between the best and the '
        'worst of them. Material near the axis contributes almost nothing, '
        'because the distance is squared and near the axis that distance is '
        'nearly zero.',
    source: 'stat-ami-q1',
  ),
  RankRound(
    subject: 'a post, hollowed out',
    setting:
        'A solid post, the same post with the middle bored out, and a small '
        'solid post with the same amount of metal as the hollow one.',
    shapes: [_hollowPost, _littlePost, _solidPost],
    why:
        'Solid, hollow, then the little one. The solid post wins, but look at '
        'the price: it uses nearly three times the metal of the hollow one to '
        'buy less than double the stiffness. The hollow post gets most of the '
        'way there on a third of the material, and the little post shows what '
        'that same metal is worth if you keep it near the axis.',
    source: 'stat-ami-q1',
  ),
];

class _RankByStiffnessGameState extends State<RankByStiffnessGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'rank-by-stiffness',
    chapterId: 'statics',
    total: rankRounds.length,
    sourceProblemIdOf: (round) => rankRounds[round].source,
  )..addListener(_onSession);

  final _order = <int>[];

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RankRound get _round => rankRounds[_session.round];

  void _tap(int i) {
    setState(() {
      if (_order.contains(i)) {
        _order.removeRange(_order.indexOf(i), _order.length);
      } else {
        _order.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Rank Them by Stiffness',
        closing:
            'The farther the material from the axis, the stiffer the section, '
            'and the distance is squared, so metal near the axis is nearly '
            'wasted. Depth is cubed in the formula and width is not. Before '
            'you look anything up, look at where the material is.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final done = _order.length == r.shapes.length;

    return BoardShell(
      session: _session,
      brief: farFromAxisBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_order.clear);
              _session.next();
            }
          : (!done
                ? null
                : () {
                    var ok = true;
                    for (var i = 0; i < _order.length; i++) {
                      if (_order[i] != r.answer[i]) ok = false;
                    }
                    _session.submit(ok: ok, context: context);
                  }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP THEM STIFFEST FIRST',
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
          const SizedBox(height: 10),
          _LineUp(
            round: r,
            order: _order,
            locked: answered,
            onTap: answered ? null : _tap,
          ),
          const SizedBox(height: 8),
          Text(
            answered
                ? 'the green numbers are the order it should have been in'
                : 'tap again to take one back',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ORDER' : 'A DIFFERENT ORDER',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _LineUp extends StatelessWidget {
  const _LineUp({
    required this.round,
    required this.order,
    required this.locked,
    required this.onTap,
  });

  final RankRound round;
  final List<int> order;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 215.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, _height);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LineUpPainter(
                        shapes: round.shapes,
                        order: order,
                        truth: round.answer,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < round.shapes.length; i++)
                    _target(i, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _target(int i, Size size) {
    final cell = LineUpPainter.cellFor(round.shapes, size, i);
    return Positioned(
      key: ValueKey('shape-$i'),
      left: cell.left,
      top: cell.top,
      width: cell.width,
      height: cell.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(i),
        child: const SizedBox.expand(),
      ),
    );
  }
}
