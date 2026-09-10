import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart' show Prop;
import 'board.dart';
import 'frame_figures.dart';
import 'lesson_brief.dart';

/// Frame, Truss or Machine — the third item for `frames-machines`.
///
/// The lesson's third problem is a definition, and definitions are usually
/// dead weight on an exam. This one is not, because what the thing is called
/// decides what you are allowed to assume about every member in it. Call a
/// frame a truss and you have just assumed away the bending.
///
/// The two named traps are swapping the truss and frame definitions, and
/// confusing a frame with a machine. So the answer is a name, and the rounds
/// are drawings rather than sentences. The middle pair is the same truss with
/// one load moved off a joint and onto a member, which turns it into a frame
/// and changes nothing else on the page.
class FrameTrussOrMachineGame extends StatefulWidget {
  const FrameTrussOrMachineGame({super.key});

  @override
  State<FrameTrussOrMachineGame> createState() =>
      _FrameTrussOrMachineGameState();
}

@immutable
class KindRound {
  const KindRound({
    required this.subject,
    required this.setting,
    required this.rig,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Assembly rig;
  final String why;
  final String source;

  /// Worked out from the members and whether the thing moves, never declared
  /// beside the round.
  Kind get answer => rig.kind;
}

/// A king post roof truss, loaded where the members meet.
const _roof = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('B', Offset(2, 0)),
    Pin('C', Offset(4, 0)),
    Pin('D', Offset(2, 1.6)),
  ],
  limbs: [
    Limb(from: 0, to: 1),
    Limb(from: 1, to: 2),
    Limb(from: 0, to: 3),
    Limb(from: 2, to: 3),
    Limb(from: 1, to: 3),
  ],
  supports: {0: Prop.pin, 2: Prop.roller},
  pinLoads: {3: '10 kN'},
);

/// A portal with the load out on the beam.
const _portal = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('B', Offset(0, 2.4)),
    Pin('C', Offset(3.4, 2.4)),
    Pin('D', Offset(3.4, 0)),
  ],
  limbs: [
    Limb(from: 0, to: 1),
    Limb(from: 1, to: 2, loads: [0.55]),
    Limb(from: 2, to: 3),
  ],
  supports: {0: Prop.pin, 3: Prop.pin},
);

/// Two arms crossed on a pin.
const _pliers = Assembly(
  pins: [
    Pin('P', Offset(1.92, 1.2)),
    Pin('J', Offset(0, 2.0)),
    Pin('K', Offset(0, 0.4)),
    Pin('G', Offset(3.6, 1.9)),
    Pin('H', Offset(3.6, 0.5)),
  ],
  limbs: [
    Limb(from: 1, to: 4, via: [0]),
    Limb(from: 2, to: 3, via: [0]),
  ],
  moves: true,
);

/// A Pratt truss with everything hung where the members meet.
const _bridge = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('B', Offset(1.6, 0)),
    Pin('C', Offset(3.2, 0)),
    Pin('D', Offset(4.8, 0)),
    Pin('E', Offset(1.6, 1.5)),
    Pin('F', Offset(3.2, 1.5)),
  ],
  limbs: [
    Limb(from: 0, to: 1),
    Limb(from: 1, to: 2),
    Limb(from: 2, to: 3),
    Limb(from: 0, to: 4),
    Limb(from: 4, to: 5),
    Limb(from: 5, to: 3),
    Limb(from: 1, to: 4),
    Limb(from: 2, to: 5),
    Limb(from: 1, to: 5),
  ],
  supports: {0: Prop.pin, 3: Prop.roller},
  pinLoads: {1: '12 kN'},
);

/// The same bridge with that load slid off the joint and onto the chord.
const _slungBridge = Assembly(
  pins: [
    Pin('A', Offset(0, 0)),
    Pin('B', Offset(1.6, 0)),
    Pin('C', Offset(3.2, 0)),
    Pin('D', Offset(4.8, 0)),
    Pin('E', Offset(1.6, 1.5)),
    Pin('F', Offset(3.2, 1.5)),
  ],
  limbs: [
    Limb(from: 0, to: 1),
    Limb(from: 1, to: 2, loads: [0.5]),
    Limb(from: 2, to: 3),
    Limb(from: 0, to: 4),
    Limb(from: 4, to: 5),
    Limb(from: 5, to: 3),
    Limb(from: 1, to: 4),
    Limb(from: 2, to: 5),
    Limb(from: 1, to: 5),
  ],
  supports: {0: Prop.pin, 3: Prop.roller},
);

/// A scissor jack: every member is two-force, and it still is not a truss.
const _jack = Assembly(
  pins: [
    Pin('A', Offset(1.6, 0)),
    Pin('B', Offset(0, 1.1)),
    Pin('C', Offset(3.2, 1.1)),
    Pin('D', Offset(1.6, 2.2)),
  ],
  limbs: [
    Limb(from: 0, to: 1),
    Limb(from: 0, to: 2),
    Limb(from: 1, to: 3),
    Limb(from: 2, to: 3),
    Limb(from: 1, to: 2, cable: true),
  ],
  supports: {0: Prop.pin},
  pinLoads: {3: '6 kN'},
  moves: true,
);

const kindRounds = <KindRound>[
  KindRound(
    subject: 'a roof over a room',
    setting:
        'Every member runs pin to pin with nothing on it in between, and the '
        'load hangs where the members meet.',
    rig: _roof,
    why:
        'A truss. Every member is touched at exactly two points, so every one '
        'of them carries pure axial force and nothing else, and the whole '
        'thing can be solved joint by joint. That is what the word means, and '
        'it is the reason a truss is the easiest structure there is to '
        'analyze.',
    source: 'stat-fm-q3',
  ),
  KindRound(
    subject: 'two columns and a beam',
    setting:
        'It is bolted to the ground at both feet and it is not going anywhere. '
        'The load sits out on the beam, between the two corners.',
    rig: _portal,
    why:
        'A frame. It holds still, so it is not a machine, and the beam is '
        'touched in three places, so it bends and it is not a truss. One '
        'multi-force member is all it takes. The two columns beside it are '
        'still two-force, and spotting that is worth free unknowns.',
    source: 'stat-fm-q3',
  ),
  KindRound(
    subject: 'two arms crossed on a pin',
    setting:
        'Squeeze the handles and the jaws close. The two halves turn against '
        'each other about the pin.',
    rig: _pliers,
    why:
        'A machine. Parts of it move relative to each other, and that is the '
        'only line between a machine and a frame: a frame holds still and a '
        'machine works. Both are dismembered and solved the same way, so '
        'nothing about the analysis changes. What it is called does not '
        'change the method.',
    source: 'stat-fm-q3',
  ),
  KindRound(
    subject: 'a bridge with its load over a joint',
    setting:
        'The deck load comes down right where the members meet at B, which is '
        'how a truss is meant to be loaded.',
    rig: _bridge,
    why:
        'A truss. The load lands on a PIN, so it is shared out by the joint '
        'and every member is still touched only at its two ends. Loads at the '
        'joints are what keep a truss a truss, and it is why real bridge decks '
        'sit on cross beams that deliver their weight to the panel points.',
    source: 'stat-fm-q3',
  ),
  KindRound(
    subject: 'the same bridge, one load moved',
    setting:
        'The same structure exactly, but the load has been slid along and now '
        'hangs from the middle of the bottom chord instead of from the joint.',
    rig: _slungBridge,
    why:
        'A frame now. One member is touched in three places, so it bends, and '
        'the method of joints will not touch it. Nothing else on the page '
        'changed. This is why the deck load of a real bridge is delivered to '
        'the panel points and not hung wherever it happens to fall.',
    source: 'stat-fm-q3',
  ),
  KindRound(
    subject: 'a jack under a car',
    setting:
        'Four links pinned in a diamond with a screw across the middle. Turn '
        'the screw and the diamond squeezes and the top rises.',
    rig: _jack,
    why:
        'A machine, and every single member in it is two-force. That is the '
        'trap: being made of two-force members does not make something a '
        'truss, because a truss also has to hold still. Turn the screw and '
        'this one changes shape, which is the entire point of it.',
    source: 'stat-fm-q3',
  ),
];

class _FrameTrussOrMachineGameState extends State<FrameTrussOrMachineGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'frame-truss-or-machine',
    chapterId: 'statics',
    total: kindRounds.length,
    sourceProblemIdOf: (round) => kindRounds[round].source,
  )..addListener(_onSession);

  Kind? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  KindRound get _round => kindRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Frame, Truss or Machine',
        closing:
            'Does it move? Then it is a machine. If it holds still, count the '
            'places something touches each member: all of them touched twice '
            'and it is a truss, any one of them touched three times and it is '
            'a frame. The name is not trivia. It says whether you may assume '
            'every force runs along its member.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: whatItIsBrief,
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
            'WHAT IS THIS THING',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: FramePainter(rig: r.rig),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final option in Kind.values) ...[
                if (option != Kind.values.first) const SizedBox(width: 8),
                Expanded(
                  child: _KindButton(
                    key: ValueKey('kind-${option.name}'),
                    option: option,
                    selected: _picked == option,
                    locked: answered,
                    isTruth: option == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = option),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT IS' : 'SOMETHING ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _KindButton extends StatelessWidget {
  const _KindButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Kind option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Kind.truss: 'A truss',
    Kind.frame: 'A frame',
    Kind.machine: 'A machine',
  };

  static const _notes = {
    Kind.truss: 'every member touched twice',
    Kind.frame: 'holds still, something bends',
    Kind.machine: 'parts move against each other',
  };

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    final Color ink;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
      ink = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
      ink = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
      ink = AppColors.ember;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
      ink = AppColors.charcoal;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 112,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 32,
                child: CustomPaint(painter: _KindGlyph(option, ink)),
              ),
              const SizedBox(height: 6),
              Text(
                _titles[option]!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _notes[option]!,
                textAlign: TextAlign.center,
                style: AppTheme.mono(size: 9, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A lattice, a portal and a crossed pair, so the three names can be told
/// apart without reading them.
class _KindGlyph extends CustomPainter {
  const _KindGlyph(this.option, this.colour);

  final Kind option;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = colour
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final w = size.width;
    final h = size.height;

    switch (option) {
      case Kind.truss:
        canvas.drawPath(
          Path()
            ..moveTo(3, h - 4)
            ..lineTo(w - 3, h - 4)
            ..moveTo(3, h - 4)
            ..lineTo(w / 2, 4)
            ..lineTo(w - 3, h - 4)
            ..moveTo(w / 2, 4)
            ..lineTo(w / 2, h - 4),
          ink,
        );
      case Kind.frame:
        canvas.drawPath(
          Path()
            ..moveTo(6, h - 3)
            ..lineTo(6, 6)
            ..lineTo(w - 6, 6)
            ..lineTo(w - 6, h - 3),
          ink,
        );
        canvas.drawLine(Offset(w / 2, 6), Offset(w / 2, 14), ink);
      case Kind.machine:
        canvas.drawPath(
          Path()
            ..moveTo(4, 4)
            ..lineTo(w - 4, h - 5)
            ..moveTo(4, h - 5)
            ..lineTo(w - 4, 4),
          ink,
        );
        canvas.drawCircle(
            Offset(w / 2, (h - 1) / 2), 3.4, Paint()..color = colour);
    }
  }

  @override
  bool shouldRepaint(_KindGlyph old) =>
      old.option != option || old.colour != colour;
}
