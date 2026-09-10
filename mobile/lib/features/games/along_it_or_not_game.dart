import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart' show Prop;
import 'board.dart';
import 'frame_figures.dart';
import 'lesson_brief.dart';

/// Along It or Not — the first item for `frames-machines`.
///
/// The lesson's tip says to spot the two-force members first, and the reason
/// is worth more than the rule: the moment you know a member is two-force you
/// know the DIRECTION of its pin force for nothing, and that is usually the
/// unknown that unlocks the rest of the frame. The warning beside it is the
/// other half: a member loaded at three points is not two-force, however much
/// it looks like one.
///
/// So the answer here is a direction, tapped on the drawing. Three rounds have
/// a member whose force is along the line joining its ends and three have one
/// where nothing about the shape settles it. Two of the rounds put a bend in
/// the member, because along the LINE and along the MEMBER are then two
/// different arrows and only one of them is right.
class AlongItOrNotGame extends StatefulWidget {
  const AlongItOrNotGame({super.key});

  @override
  State<AlongItOrNotGame> createState() => _AlongItOrNotGameState();
}

@immutable
class PinRound {
  const PinRound({
    required this.subject,
    required this.setting,
    required this.rig,
    required this.limb,
    required this.atPin,
    required this.aims,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Assembly rig;

  /// The member being asked about, and the pin at the end of it.
  final int limb;
  final int atPin;

  final List<Aim> aims;
  final String why;
  final String source;

  /// Minus one means nothing about the shape settles it. Worked out from how
  /// many places touch the member, never declared beside the round.
  int get answer =>
      rig.limbs[limb].twoForce ? aims.indexOf(Aim.alongTheLine) : -1;
}

/// A bracket off a wall: an arm held out by a diagonal strut.
const _bracket = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('B', Offset(0, 2.6)),
    Pin('M', Offset(1.9, 2.6)),
    Pin('C', Offset(3.3, 2.6)),
  ],
  limbs: [
    Limb(from: 1, to: 3, via: [2]), // 0 the arm, touched in three places
    Limb(from: 0, to: 2), // 1 the strut
  ],
  supports: {0: Prop.pin, 1: Prop.pin},
  pinLoads: {3: '5 kN'},
);

/// A brace with a knee in it, propping a post.
const _knee = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('D', Offset(3.2, 0)),
    Pin('B', Offset(3.2, 1.8)),
  ],
  limbs: [
    Limb(from: 0, to: 2, bend: Offset(0.7, 2.2)), // 0 the bent brace
    Limb(from: 1, to: 2), // 1 the post
  ],
  supports: {0: Prop.pin, 1: Prop.pin},
  pinLoads: {2: '4 kN'},
);

/// The same knee, with something hung on the bend itself.
const _loadedKnee = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('D', Offset(3.2, 0)),
    Pin('B', Offset(3.2, 1.8)),
  ],
  limbs: [
    Limb(from: 0, to: 2, bend: Offset(0.7, 2.2), loads: [0.5]),
    Limb(from: 1, to: 2),
  ],
  supports: {0: Prop.pin, 1: Prop.pin},
  pinLoads: {2: '4 kN'},
);

/// A portal with the load out on the beam rather than over a column.
const _portal = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('B', Offset(0, 2.6)),
    Pin('C', Offset(3.6, 2.6)),
    Pin('D', Offset(3.6, 0)),
  ],
  limbs: [
    Limb(from: 0, to: 1),
    Limb(from: 1, to: 2, loads: [0.5]),
    Limb(from: 2, to: 3),
  ],
  supports: {0: Prop.pin, 3: Prop.pin},
);

/// A mast, a boom and a cable between them.
const _derrick = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('B', Offset(0, 3.0)),
    Pin('C', Offset(3.4, 1.3)),
  ],
  limbs: [
    Limb(from: 0, to: 1), // 0 the mast
    Limb(from: 0, to: 2), // 1 the boom
    Limb(from: 1, to: 2, cable: true), // 2 the cable
  ],
  supports: {0: Prop.pin},
  pinLoads: {2: '8 kN'},
);

const pinRounds = <PinRound>[
  PinRound(
    subject: 'a straight strut in a bracket',
    setting:
        'The arm is held out from the wall by the strut AM. Nothing is applied '
        'to that strut between its two ends. Tap the arrow showing which way '
        'its force acts at M.',
    rig: _bracket,
    limb: 1,
    atPin: 2,
    aims: [Aim.alongTheLine, Aim.square, Aim.oblique],
    why:
        'Arrow 1, along the line joining its two ends. Two points of contact '
        'and nothing else, so the two forces have to be equal, opposite and in '
        'line, and there is only one line they can be in. Which way along it, '
        'pushing or pulling, still takes the rest of the analysis. The '
        'direction does not.',
    source: 'stat-fm-q1',
  ),
  PinRound(
    subject: 'the arm of the same bracket',
    setting:
        'Same bracket, and now the question is about the arm BC, which is '
        'pinned at the wall, pinned to the strut at M, and carries the load at '
        'C. Which way does ITS force act at C?',
    rig: _bracket,
    limb: 0,
    atPin: 3,
    aims: [Aim.alongTheLine, Aim.square, Aim.oblique],
    why:
        'None of them, not from the shape. Three separate places act on this '
        'arm, so it is a multi-force member and its pin forces are under no '
        'obligation to line up with anything. It bends. Assuming the arm is '
        'axial because it is straight is the mistake the lesson warns about, '
        'and it is the same picture as the round before.',
    source: 'stat-fm-q1',
  ),
  PinRound(
    subject: 'a brace with a knee in it',
    setting:
        'This brace runs from A up over a bend and across to B. Nothing '
        'touches it in between. Tap the arrow showing its force at A.',
    rig: _knee,
    limb: 0,
    atPin: 0,
    aims: [Aim.alongTheLimb, Aim.alongTheLine, Aim.square],
    why:
        'Arrow 2, along the straight line from A to B. Arrow 1 follows the '
        'metal, and the metal is not what the rule is about: two forces at two '
        'points can only balance if they are collinear WITH EACH OTHER, which '
        'means along the line joining the points. Bend the member however you '
        'like and that line does not move.',
    source: 'stat-fm-q1',
  ),
  PinRound(
    subject: 'a beam carrying its load between the pins',
    setting:
        'A portal frame with the load sitting out on the beam rather than over '
        'a column. Which way does the beam force act at B?',
    rig: _portal,
    limb: 1,
    atPin: 1,
    aims: [Aim.square, Aim.oblique, Aim.alongTheLine],
    why:
        'None of them. The beam is pinned at both ends AND carries a load in '
        'the middle, which is three places, so it bends and its pin forces go '
        'wherever equilibrium sends them. The two columns beside it ARE '
        'two-force members, which is the part of this frame worth spotting.',
    source: 'stat-fm-q1',
  ),
  PinRound(
    subject: 'the cable on a derrick',
    setting:
        'A mast, a boom, and a cable strung between their tops. Which way does '
        'the cable force act where it meets the boom at C?',
    rig: _derrick,
    limb: 2,
    atPin: 2,
    aims: [Aim.square, Aim.alongTheLine, Aim.oblique],
    why:
        'Arrow 2, along the cable. A cable is the easiest two-force member '
        'there is: it is touched at two points, and it can only pull, so its '
        'force is along itself and pointing away from whatever it is attached '
        'to. The boom here is two-force as well, which is worth noticing '
        'before writing anything down.',
    source: 'stat-fm-q1',
  ),
  PinRound(
    subject: 'the same knee, with something hung on it',
    setting:
        'The bent brace from earlier, but this time a load hangs at the bend '
        'itself. Which way does its force act at A now?',
    rig: _loadedKnee,
    limb: 0,
    atPin: 0,
    aims: [Aim.alongTheLimb, Aim.alongTheLine, Aim.square],
    why:
        'None of them. One load at the knee is all it takes: three points of '
        'contact, so it is a multi-force member and the answer that was right '
        'a moment ago is wrong now. The picture barely changed. What it is '
        'called, and what you may assume about it, changed completely.',
    source: 'stat-fm-q1',
  ),
];

class _AlongItOrNotGameState extends State<AlongItOrNotGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'along-it-or-not',
    chapterId: 'statics',
    total: pinRounds.length,
    sourceProblemIdOf: (round) => pinRounds[round].source,
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

  PinRound get _round => pinRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Along It or Not',
        closing:
            'Count the places something touches a member. Exactly two, and its '
            'force is along the line joining them, whatever shape the member '
            'is. Three or more and you know nothing about the direction until '
            'you have solved for it. That count is the cheapest thing you will '
            'ever do to a frame and it hands you free unknowns.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: twoForceBrief,
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
            'WHICH WAY DOES THAT FORCE ACT',
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
          _Frame(
            round: r,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          const SizedBox(height: 8),
          _CannotTellRow(
            selected: _picked == -1,
            locked: answered,
            isTruth: r.answer == -1,
            onTap: answered ? null : () => setState(() => _picked = -1),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE DIRECTION' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final PinRound round;
  final int? picked;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 300.0;

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
                      painter: FramePainter(
                        rig: round.rig,
                        spotlight: round.limb,
                        atPin: round.atPin,
                        aims: round.aims,
                        picked: picked,
                        truth: round.answer,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < round.aims.length; i++)
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
    final at = FramePainter.aimTip(
        round.rig, size, round.limb, round.atPin, round.aims, i);
    const box = 48.0;
    return Positioned(
      key: ValueKey('aim-$i'),
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

class _CannotTellRow extends StatelessWidget {
  const _CannotTellRow({
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
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      key: const ValueKey('cannot-tell'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 58,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'None of them, not from the shape',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'this member is touched in more than two places',
                style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
