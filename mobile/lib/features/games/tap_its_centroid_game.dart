import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';

/// Tap Its Centroid — the second item for `centroids-composite-shapes`.
///
/// The lesson's exam callout is blunt about it: the handbook gives you the
/// centroid of a triangle, a rectangle, a circle, a semicircle and a parabolic
/// segment, and you are not expected to integrate anything. What you ARE
/// expected to do is know which one you are looking at and where the table
/// puts its centroid, because that number goes straight into the weighted
/// average and a wrong one poisons the whole sum.
///
/// So each round draws one shape with candidate points on it and the answer is
/// tapped. The distractor on almost every round is the middle of the box the
/// shape fits in, which is right for a rectangle and for nothing else.
class TapItsCentroidGame extends StatefulWidget {
  const TapItsCentroidGame({super.key});

  @override
  State<TapItsCentroidGame> createState() => _TapItsCentroidGameState();
}

@immutable
class SpotRound {
  const SpotRound({
    required this.subject,
    required this.setting,
    required this.profile,
    required this.spots,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Profile profile;

  /// The candidate places, in world units.
  final List<Offset> spots;

  final String why;
  final String source;

  /// The candidate nearest the centroid the shape actually has. Worked out
  /// from the shape, never declared beside the round.
  int get answer {
    var best = 0;
    for (var i = 1; i < spots.length; i++) {
      if ((spots[i] - profile.centroid).distance <
          (spots[best] - profile.centroid).distance) {
        best = i;
      }
    }
    return best;
  }
}

const spotRounds = <SpotRound>[
  SpotRound(
    subject: 'a right triangle',
    setting:
        'The upright leg is on the left. One of these three points is where '
        'the handbook puts its centroid.',
    profile: Profile([Piece(Slab.rightTri, Offset.zero, Size(6, 4))]),
    spots: [Offset(3, 2), Offset(2, 1.3333), Offset(4, 1.3333)],
    why:
        'Point 2, a third of the way along each leg from the right angle. A '
        'triangle has more of its area down at the wide end, so the centroid '
        'sits low and toward the upright. Point 1 is the middle of the box the '
        'triangle fits in, which is the centroid of the BOX and not of '
        'anything inside it.',
    source: 'stat-ccs-q1',
  ),
  SpotRound(
    subject: 'the same triangle, mirrored',
    setting:
        'The identical triangle with the upright leg on the right instead. '
        'Same three candidate points.',
    profile: Profile([
      Piece(Slab.rightTri, Offset.zero, Size(6, 4), flip: true),
    ]),
    spots: [Offset(3, 2), Offset(2, 1.3333), Offset(4, 1.3333)],
    why:
        'Point 3 now. The rule is a third from the right angle, not a third '
        'from the left edge, and mirroring the shape moves the answer with it. '
        'This is worth doing once deliberately, because a remembered picture '
        'of a triangle is exactly the sort of thing that turns up backwards.',
    source: 'stat-ccs-q1',
  ),
  SpotRound(
    subject: 'a semicircle on its flat side',
    setting:
        'Half a disc, flat side down. The candidates run up the line of '
        'symmetry.',
    profile: Profile([Piece(Slab.halfDisc, Offset.zero, Size(6, 3))]),
    spots: [Offset(3, 0), Offset(3, 1.2732), Offset(3, 2.2)],
    why:
        'Point 2, which the table gives as four r over three pi up from the '
        'flat side, a shade over four tenths of the radius. Point 1 is the '
        'center of the circle it was cut from, and that is where the centroid '
        'of the WHOLE disc would be. Half a disc is not half as far up as you '
        'might guess.',
    source: 'stat-ccs-q2',
  ),
  SpotRound(
    subject: 'a quarter of a disc',
    setting:
        'A quarter circle with its corner at the bottom left. The candidates '
        'run out along the diagonal.',
    profile: Profile([Piece(Slab.quarterDisc, Offset.zero, Size(5, 5))]),
    spots: [Offset(0, 0), Offset(2.1221, 2.1221), Offset(3.5, 3.5)],
    why:
        'Point 2, the same four r over three pi out along each axis from the '
        'corner. Point 1 is the center of the circle, which is a corner of '
        'this shape and could not possibly be its centroid. Point 3 sits out '
        'where the shape is widest, which is where it looks heavy and is not.',
    source: 'stat-ccs-q2',
  ),
  SpotRound(
    subject: 'a triangle standing on its base',
    setting: 'An isoceles triangle, symmetric about a vertical line.',
    profile: Profile([Piece(Slab.isoTri, Offset.zero, Size(6, 6))]),
    spots: [Offset(3, 2), Offset(3, 3), Offset(3, 4)],
    why:
        'Point 1, a third of the height up from the base. Symmetry settles the '
        'sideways half of the answer for nothing, and the table settles the '
        'other half. Point 3 is a third down from the APEX, which is the same '
        'rule remembered from the wrong end, and point 2 is the middle of the '
        'height.',
    source: 'stat-ccs-q1',
  ),
  SpotRound(
    subject: 'an angle made of two rectangles',
    setting:
        'A leg lying along the bottom and a taller one standing up the left '
        'side. Now it is a weighted average rather than a table lookup.',
    profile: Profile([
      Piece(Slab.box, Offset.zero, Size(7, 2)),
      Piece(Slab.box, Offset(0, 2), Size(2, 5)),
    ]),
    spots: [Offset(1, 1), Offset(2.4583, 2.4583), Offset(3.5, 3.5)],
    why:
        'Point 2. Two pieces, each with its own area and its own centroid, '
        'combined by the weighted average, and the answer lands outside the '
        'metal entirely, in the notch. That is allowed and it is common: a '
        'centroid is a property of the area, not a place you could put a pin.',
    source: 'stat-ccs-q3',
  ),
];

class _TapItsCentroidGameState extends State<TapItsCentroidGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'tap-its-centroid',
    chapterId: 'statics',
    total: spotRounds.length,
    sourceProblemIdOf: (round) => spotRounds[round].source,
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

  SpotRound get _round => spotRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Tap Its Centroid',
        closing:
            'A third of the way from the wide end of a triangle. Four r over '
            'three pi from the flat side of a half disc. The middle of a '
            'rectangle. The handbook has them all and you are not asked to '
            'derive any of them, only to know which shape you are holding and '
            'to measure from the right corner of it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: tableBrief,
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
            'TAP THE CENTROID',
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
          _Shape(
            round: r,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE POINT' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Shape extends StatelessWidget {
  const _Shape({
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final SpotRound round;
  final int? picked;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 340.0;

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
                      painter: ProfilePainter(
                        profile: round.profile,
                        spots: round.spots,
                        picked: picked,
                        truth: round.answer,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < round.spots.length; i++)
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
    final at =
        ProfilePainter.toScreen(round.profile, round.spots[i], size);
    const box = 46.0;
    return Positioned(
      key: ValueKey('spot-$i'),
      left: at.dx - box / 2,
      top: at.dy - box / 2,
      width: box,
      height: box,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(i),
        child: const SizedBox.expand(),
      ),
    );
  }
}
