import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';

/// Which Distance Goes In — the third item for `centroids-composite-shapes`.
///
/// The lesson's warning is that the most common mistake in the whole topic is
/// measuring a piece's centroid distance from the wrong place. Pick one
/// reference axis, it says, and stick to it for every piece. Switch halfway
/// and the weighted average is wrong, and it is wrong quietly: the number
/// still comes out looking like a length.
///
/// So the section is drawn split into its pieces with the bottom edge as the
/// reference, one piece is picked out, and three candidate distances are drawn
/// down the side. The answer is the one that belongs in the sum. The
/// distractors are the mistakes people actually make: the bottom of the piece
/// instead of its middle, the piece's own local distance, and a measurement
/// taken from the top of the section instead of the bottom.
class WhichDistanceGoesInGame extends StatefulWidget {
  const WhichDistanceGoesInGame({super.key});

  @override
  State<WhichDistanceGoesInGame> createState() =>
      _WhichDistanceGoesInGameState();
}

@immutable
class DropRound {
  const DropRound({
    required this.subject,
    required this.setting,
    required this.profile,
    required this.piece,
    required this.drops,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Profile profile;

  /// The piece the round is asking about.
  final int piece;

  final List<Drop> drops;
  final String why;
  final String source;

  /// The one that runs from the reference axis at the bottom to this piece's
  /// own centroid. Worked out from the drawing, never declared.
  int get answer {
    final want = profile.pieces[piece].centroid.dy;
    final base = profile.baseline;
    for (var i = 0; i < drops.length; i++) {
      if ((drops[i].from - base).abs() < 0.01 &&
          (drops[i].to - want).abs() < 0.01) {
        return i;
      }
    }
    return -1;
  }
}

/// The lesson's T: a narrow web with a wide flange on top.
const _tee = Profile([
  Piece(Slab.box, Offset(50, 0), Size(20, 80)),
  Piece(Slab.box, Offset(0, 80), Size(120, 20)),
]);

/// The lesson's built-up section.
const _builtUp = Profile([
  Piece(Slab.box, Offset(0, 0), Size(200, 30)),
  Piece(Slab.box, Offset(85, 30), Size(30, 140)),
  Piece(Slab.box, Offset(25, 170), Size(150, 30)),
]);

/// An angle, two rectangles meeting at the bottom left.
const _angle = Profile([
  Piece(Slab.box, Offset(0, 0), Size(140, 30)),
  Piece(Slab.box, Offset(0, 30), Size(30, 90)),
]);

/// The lesson's plate with a hole in it.
const _plate = Profile([
  Piece(Slab.box, Offset(0, 0), Size(300, 200)),
  Piece(Slab.disc, Offset(120, 120), Size(60, 60), hole: true),
]);

const dropRounds = <DropRound>[
  DropRound(
    subject: 'the flange of a T',
    setting:
        'The section is split into a web and a flange, and the reference is '
        'the bottom edge. Which distance goes into the sum for the FLANGE?',
    profile: _tee,
    piece: 1,
    drops: [
      Drop(0, 80, 'to the underside of the flange'),
      Drop(0, 90, 'to the middle of the flange'),
      Drop(0, 100, 'to the top of the section'),
    ],
    why:
        'Distance 2, from the reference up to the flange\'s OWN centroid, '
        'which is its own middle. Every term in the sum is the area of a piece '
        'times how far that piece\'s centroid is from the one axis you chose. '
        'Not where the piece starts and not where it stops.',
    source: 'stat-ccs-q1',
  ),
  DropRound(
    subject: 'the web of the same T',
    setting: 'Same section, same reference. Now the WEB is picked out.',
    profile: _tee,
    piece: 0,
    drops: [
      Drop(0, 40, 'to the middle of the web'),
      Drop(0, 80, 'to the top of the web'),
      Drop(40, 100, 'from the web up to the top'),
    ],
    why:
        'Distance 1. Two pieces, two distances, both measured from the same '
        'bottom edge, and neither of them cares where the other piece is. '
        'Distance 3 is measured from the web up rather than from the axis up, '
        'and mixing those two habits in one problem is what the lesson warns '
        'about.',
    source: 'stat-ccs-q1',
  ),
  DropRound(
    subject: 'the top flange of a built-up section',
    setting:
        'Three rectangles. The reference is still the bottom edge, and the top '
        'flange is picked out.',
    profile: _builtUp,
    piece: 2,
    drops: [
      Drop(170, 185, 'within the flange itself'),
      Drop(0, 200, 'to the top of the section'),
      Drop(0, 185, 'to the middle of the flange'),
    ],
    why:
        'Distance 3. Distance 1 is the flange\'s centroid measured from the '
        'flange, which is fifteen and is useless: it says nothing about where '
        'the flange sits in the section. Every piece has to be measured from '
        'the SAME place or they cannot be averaged together.',
    source: 'stat-ccs-q3',
  ),
  DropRound(
    subject: 'the web in the middle of three',
    setting:
        'The same built-up section with the web picked out. It sits between '
        'the two flanges.',
    profile: _builtUp,
    piece: 1,
    drops: [
      Drop(30, 100, 'from the top of the bottom flange'),
      Drop(0, 100, 'to the middle of the web'),
      Drop(0, 170, 'to the top of the web'),
    ],
    why:
        'Distance 2. Distance 1 measures from the top of the bottom flange, '
        'which is a perfectly sensible axis and is simply not the one already '
        'in use. Change reference partway through and the sum adds up numbers '
        'that are not comparable. Pick an axis at the start and never move it.',
    source: 'stat-ccs-q3',
  ),
  DropRound(
    subject: 'the upright leg of an angle',
    setting:
        'An angle split into a flat leg along the bottom and an upright one on '
        'the left. The upright leg is picked out.',
    profile: _angle,
    piece: 1,
    drops: [
      Drop(0, 30, 'to the foot of the upright'),
      Drop(0, 120, 'to the top of the upright'),
      Drop(0, 75, 'to the middle of the upright'),
    ],
    why:
        'Distance 3. The upright runs from thirty up to a hundred and twenty, '
        'so its own middle is at seventy five, and that is the number the sum '
        'wants. Reaching for thirty because that is where the piece begins is '
        'the commonest slip of the lot.',
    source: 'stat-ccs-q3',
  ),
  DropRound(
    subject: 'the hole in a plate',
    setting:
        'A plate with a round hole drilled in it. The hole is a piece too, and '
        'it is picked out.',
    profile: _plate,
    piece: 1,
    drops: [
      Drop(0, 150, 'to the center of the hole'),
      Drop(0, 120, 'to the bottom of the hole'),
      Drop(0, 180, 'to the top of the hole'),
    ],
    why:
        'Distance 1, to the center of the hole, measured from the same bottom '
        'edge as everything else. A hole is an ordinary piece in every way but '
        'one: its distance is found exactly like any other, and only its AREA '
        'goes in negative.',
    source: 'stat-ccs-q2',
  ),
];

class _WhichDistanceGoesInGameState extends State<WhichDistanceGoesInGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-distance-goes-in',
    chapterId: 'statics',
    total: dropRounds.length,
    sourceProblemIdOf: (round) => dropRounds[round].source,
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

  DropRound get _round => dropRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Distance Goes In',
        closing:
            'Choose one axis before you start and measure every piece from it, '
            'to that piece\'s own centroid and nowhere else. The whole of the '
            'weighted average is areas times those distances. Switch reference '
            'partway through and the arithmetic still works and the answer is '
            'still wrong.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: referenceBrief,
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
            'WHICH ONE GOES IN THE SUM',
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
          _Split(
            round: r,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 10),
            for (var i = 0; i < r.drops.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '${i + 1}  ${r.drops[i].label}',
                  style: AppTheme.mono(
                    size: 11,
                    color: i == r.answer ? AppColors.forest : AppColors.ink3,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT ONE',
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
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final DropRound round;
  final int? picked;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 260.0;

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
                        drops: round.drops,
                        spotlight: round.piece,
                        picked: picked,
                        truth: round.answer,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < round.drops.length; i++)
                    _target(i, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// A dimension is a tall thin thing, so its tap target is one too: the full
  /// height of the lane it lives in, and wide enough for a thumb.
  Widget _target(int i, Size size) {
    final lane = ProfilePainter.laneFor(round.profile, size, round.drops, i);
    final a = ProfilePainter.toScreen(round.profile,
        Offset(round.profile.bounds.left, round.drops[i].from), size,
        drops: round.drops);
    final b = ProfilePainter.toScreen(round.profile,
        Offset(round.profile.bounds.left, round.drops[i].to), size,
        drops: round.drops);
    final top = a.dy < b.dy ? a.dy : b.dy;
    final tall = (a.dy - b.dy).abs();
    const wide = 44.0;
    return Positioned(
      key: ValueKey('drop-$i'),
      left: lane - wide / 2,
      top: top - 8,
      width: wide,
      height: tall < 44 ? 44 : tall + 16,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(i),
        child: const SizedBox.expand(),
      ),
    );
  }
}
