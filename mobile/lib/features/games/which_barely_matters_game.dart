import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';

/// Which One Barely Matters — the third item for `area-moments-of-inertia`.
///
/// The lesson's third problem is a composite, and the whole of it is that each
/// piece brings its own centroidal value AND a transfer term, and the transfer
/// term is usually the bigger half. Follow that through and something useful
/// falls out: a piece sitting on the axis contributes almost nothing however
/// big it is, because its distance is squared and near the axis that distance
/// is nearly zero.
///
/// So the answer here is which piece you could very nearly ignore. Half the
/// rounds have the biggest piece by area as the answer, which is the point.
class WhichBarelyMattersGame extends StatefulWidget {
  const WhichBarelyMattersGame({super.key});

  @override
  State<WhichBarelyMattersGame> createState() =>
      _WhichBarelyMattersGameState();
}

@immutable
class ShareRound {
  const ShareRound({
    required this.subject,
    required this.setting,
    required this.profile,
    required this.names,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Profile profile;

  /// What each piece is called, for the feedback.
  final List<String> names;

  final String why;
  final String source;

  /// The piece contributing least to the section's stiffness about its own
  /// centroidal axis. Worked out piece by piece, never declared.
  int get answer {
    var least = 0;
    for (var i = 1; i < profile.pieces.length; i++) {
      if (profile.shareOf(i) < profile.shareOf(least)) least = i;
    }
    return least;
  }
}

/// The lesson's T: a deep narrow web under a wide thin flange.
const _tee = Profile([
  Piece(Slab.box, Offset(50, 0), Size(20, 80)),
  Piece(Slab.box, Offset(0, 80), Size(120, 20)),
]);

/// A symmetric I, the shape the answer explains.
const _iBeam = Profile([
  Piece(Slab.box, Offset(0, 0), Size(140, 20)),
  Piece(Slab.box, Offset(60, 20), Size(20, 120)),
  Piece(Slab.box, Offset(0, 140), Size(140, 20)),
]);

/// A heavy plate straddling the axis with two small bars held out from it.
const _spread = Profile([
  Piece(Slab.box, Offset(0, 80), Size(200, 40)),
  Piece(Slab.box, Offset(80, 170), Size(40, 40)),
  Piece(Slab.box, Offset(75, 0), Size(50, 40)),
]);

/// A stem with a thin brim across the top of it.
const _topHat = Profile([
  Piece(Slab.box, Offset(60, 0), Size(80, 100)),
  Piece(Slab.box, Offset(0, 100), Size(200, 16)),
]);

/// A very deep web with the flange right out at the top.
const _deepTee = Profile([
  Piece(Slab.box, Offset(50, 0), Size(20, 180)),
  Piece(Slab.box, Offset(0, 180), Size(120, 20)),
]);

/// A plate with a service hole bored through the middle of its depth.
const _bored = Profile([
  Piece(Slab.box, Offset(0, 0), Size(200, 120)),
  Piece(Slab.disc, Offset(70, 30), Size(60, 60), hole: true),
]);

const shareRounds = <ShareRound>[
  ShareRound(
    subject: 'the T from the last lesson',
    setting:
        'A narrow web with a wide flange over it, bending about the chain '
        'line. Which of the two pieces could you very nearly leave out of the '
        'sum?',
    profile: _tee,
    names: ['the web', 'the flange'],
    why:
        'The flange, and it has half again as much metal in it as the web. '
        'The flange sits only twenty from the axis, so its transfer term is '
        'small, while the web is deep and reaches a long way either side. Area '
        'is not what the sum is weighing. Distance squared is.',
    source: 'stat-ami-q3',
  ),
  ShareRound(
    subject: 'a symmetric I-beam',
    setting:
        'Two equal flanges and the web between them. One of these three pieces '
        'is carrying far less than the others.',
    profile: _iBeam,
    names: ['the bottom flange', 'the web', 'the top flange'],
    why:
        'The web, by about five to one against either flange. Every bit of it '
        'is near the axis, where distance squared is almost nothing, so almost '
        'none of the stiffness comes from it. That is the entire reason an '
        'I-beam is shaped like an I and the web is as thin as shear will '
        'allow.',
    source: 'stat-ami-q3',
  ),
  ShareRound(
    subject: 'a heavy plate with two small bars',
    setting:
        'One thick plate sitting across the axis and two small bars held well '
        'away from it.',
    profile: _spread,
    names: ['the plate', 'the top bar', 'the bottom bar'],
    why:
        'The plate, which is four times the metal of either bar and does about '
        'a twelfth of the work. Sitting on the axis is the worst place a piece '
        'can be. Move that same plate out to where the bars are and it would '
        'dwarf both of them.',
    source: 'stat-ami-q3',
  ),
  ShareRound(
    subject: 'a stem with a brim',
    setting:
        'A tall stem with a wide thin brim laid across the top of it. The brim '
        'is a long way out, which usually counts for a great deal.',
    profile: _topHat,
    names: ['the stem', 'the brim'],
    why:
        'Still the brim, though not by much, and this is the round where the '
        'usual reasoning nearly fails. Being far out helps it, but there is so '
        'little of it and the stem is so deep that the stem still wins. Both '
        'terms matter and neither one settles it on its own.',
    source: 'stat-ami-q3',
  ),
  ShareRound(
    subject: 'a very deep web',
    setting:
        'The same T shape as the first round, but the web is now more than '
        'twice as deep and the flange has not changed.',
    profile: _deepTee,
    names: ['the web', 'the flange'],
    why:
        'The flange again, and by a wider margin than before. Deepening the '
        'web raised its own centroidal value on the cube of its depth, which '
        'is the fastest-growing term anywhere in this lesson. The flange did '
        'move further from the axis and it still could not keep up.',
    source: 'stat-ami-q3',
  ),
  ShareRound(
    subject: 'a plate with a hole bored in it',
    setting:
        'A service hole drilled through the middle of a plate\'s depth. The '
        'hole is a piece as well, with a negative area.',
    profile: _bored,
    names: ['the plate', 'the hole'],
    why:
        'The hole, by a factor of about forty five, and that is a fact worth '
        'carrying: a hole bored near the neutral axis costs almost no '
        'stiffness at all. Ducts and services go through the middle of a beam '
        'depth for exactly this reason, and never near the flanges.',
    source: 'stat-ami-q3',
  ),
];

class _WhichBarelyMattersGameState extends State<WhichBarelyMattersGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-barely-matters',
    chapterId: 'statics',
    total: shareRounds.length,
    sourceProblemIdOf: (round) => shareRounds[round].source,
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

  ShareRound get _round => shareRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Barely Matters',
        closing:
            'Every piece brings its own value and a transfer term, and the '
            'transfer term carries the distance SQUARED. A piece on the axis '
            'therefore contributes almost nothing however much metal is in it, '
            'and a small piece a long way out can carry most of the section. '
            'Look at where a piece sits before you look at how big it is.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: compositeIBrief,
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
            'TAP THE PIECE THAT BARELY COUNTS',
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
          _Pieces(
            round: r,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'BARELY WORTH ADDING' : 'THAT ONE EARNS ITS PLACE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Pieces extends StatelessWidget {
  const _Pieces({
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final ShareRound round;
  final int? picked;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 270.0;

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
                        axes: [Datum(round.profile.centroid.dy, 'axis')],
                        spotlight: picked ?? -1,
                        truth: round.answer,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < round.profile.pieces.length; i++)
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
    final box = ProfilePainter.pieceRect(round.profile, size, i,
        axes: [Datum(round.profile.centroid.dy, 'axis')]);
    // A thin flange is only a few pixels deep, so its target is grown to
    // something a thumb can find without swallowing its neighbours.
    final grown = Rect.fromCenter(
      center: box.center,
      width: math.max(box.width, 40),
      height: math.max(box.height, 34),
    );
    return Positioned(
      key: ValueKey('piece-$i'),
      left: grown.left,
      top: grown.top,
      width: grown.width,
      height: grown.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(i),
        child: const SizedBox.expand(),
      ),
    );
  }
}
