import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart' show Prop;
import 'board.dart';
import 'lesson_brief.dart';
import 'truss_figures.dart';

/// Stretched or Squashed — the second item for `trusses-joints-sections`.
///
/// The lesson's sign convention warning is the whole of this one: a truss
/// member is assumed in tension, a negative answer means compression, and the
/// number is worthless if you cannot say which. The exam does not ask for 4.2
/// kilonewtons. It asks for 4.2 kilonewtons COMPRESSION, and half a mark is
/// gone if you leave that off.
///
/// One member is lit up on a drawn truss and the answer is which way it is
/// being worked. No arithmetic: the top chord of a simply supported truss is
/// squashed, the bottom chord is stretched, and a cantilever turns both of
/// those upside down. The same bottom chord member appears twice, in a
/// simply supported truss and in a cantilever, with opposite answers.
class StretchedOrSquashedGame extends StatefulWidget {
  const StretchedOrSquashedGame({super.key});

  @override
  State<StretchedOrSquashedGame> createState() =>
      _StretchedOrSquashedGameState();
}

/// What is happening to the member. Tension stretches it, compression squashes
/// it, and a zero-force member is doing neither.
enum Working { stretched, squashed, neither }

@immutable
class WorkRound {
  const WorkRound({
    required this.subject,
    required this.setting,
    required this.truss,
    required this.member,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Truss truss;

  /// The index of the one member being asked about.
  final int member;

  final Working answer;
  final String why;
  final String source;
}

/// Simply supported, nine meters, one load hung on the top chord at F.
const _deck = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('B', Offset(3, 0)),
    Joint('C', Offset(6, 0)),
    Joint('D', Offset(9, 0)),
    Joint('E', Offset(3, 4)),
    Joint('F', Offset(6, 4)),
  ],
  members: [
    (0, 1), // 0 AB
    (1, 2), // 1 BC
    (2, 3), // 2 CD
    (0, 4), // 3 AE
    (4, 5), // 4 EF
    (5, 3), // 5 FD
    (1, 4), // 6 BE
    (2, 4), // 7 CE
    (2, 5), // 8 CF
  ],
  supports: {0: Prop.pin, 3: Prop.roller},
  loads: {5: '24 kN'},
);

/// A cantilever off a wall on the right, carrying its load at the free end.
const _cantilever = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('B', Offset(3, 0)),
    Joint('C', Offset(6, 0)),
    Joint('D', Offset(3, 2.5)),
    Joint('E', Offset(6, 2.5)),
  ],
  members: [
    (0, 1), // 0 AB
    (1, 2), // 1 BC
    (0, 3), // 2 AD
    (1, 3), // 3 BD
    (3, 4), // 4 DE
    (1, 4), // 5 BE
  ],
  supports: {2: Prop.pin, 4: Prop.pin},
  loads: {0: '10 kN'},
  wall: 6,
);

/// A load hung at the apex, which leaves two members with nothing to do.
const _apex = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('B', Offset(2, 0)),
    Joint('C', Offset(4, 0)),
    Joint('D', Offset(6, 0)),
    Joint('E', Offset(3, 2.5)),
  ],
  members: [
    (0, 1), // 0 AB
    (1, 2), // 1 BC
    (2, 3), // 2 CD
    (0, 4), // 3 AE
    (4, 3), // 4 ED
    (1, 4), // 5 BE
    (2, 4), // 6 CE
  ],
  supports: {0: Prop.pin, 3: Prop.roller},
  loads: {4: '16 kN'},
);

const workRounds = <WorkRound>[
  WorkRound(
    subject: 'the bottom chord of a simply supported truss',
    setting:
        'A road truss held at both ends, carrying its load on the top chord. '
        'The member picked out is at the bottom, near the left support.',
    truss: _deck,
    member: 0,
    answer: Working.stretched,
    why:
        'Stretched. The whole truss sags between its two supports, so the '
        'bottom of it has further to go than the top and everything along the '
        'bottom chord is being pulled apart. Every bottom chord member in a '
        'simply supported truss under downward load does this.',
    source: 'stat-tjs-q2',
  ),
  WorkRound(
    subject: 'the top chord of the same truss',
    setting:
        'Same truss, same load. This time the member picked out runs along the '
        'top, between the two apex joints.',
    truss: _deck,
    member: 4,
    answer: Working.squashed,
    why:
        'Squashed. The top of a sagging truss has to travel a shorter '
        'distance than it started with, so the top chord is being pushed '
        'together. That is why top chords are the fat members: a squashed '
        'member can buckle, and a stretched one cannot.',
    source: 'stat-tjs-q2',
  ),
  WorkRound(
    subject: 'the vertical hanging the load',
    setting:
        'The same truss again. The member picked out is the vertical running '
        'from the loaded joint F straight down to C.',
    truss: _deck,
    member: 8,
    answer: Working.squashed,
    why:
        'Squashed. The load is sitting on top of F and this member is directly '
        'under it, so it is being stood on. Reading it as stretched because it '
        'looks like something hanging is the trap: it would be stretched if '
        'the load hung from C underneath, and here it does not.',
    source: 'stat-tjs-q2',
  ),
  WorkRound(
    subject: 'the top chord of a cantilever',
    setting:
        'A bracket built off a wall on the right, carrying its load at the '
        'free end on the left. The member picked out is the top one.',
    truss: _cantilever,
    member: 4,
    answer: Working.stretched,
    why:
        'Stretched. A cantilever does not sag between supports, it droops off '
        'the end, so the top of it is what opens up and the top chord is '
        'pulled. Everything you learned from the last three rounds turns over '
        'the moment the support arrangement changes.',
    source: 'stat-tjs-q1',
  ),
  WorkRound(
    subject: 'the bottom chord of the same cantilever',
    setting:
        'Same bracket, same load at the free end. The member picked out is the '
        'bottom one, running out to the tip.',
    truss: _cantilever,
    member: 0,
    answer: Working.squashed,
    why:
        'Squashed. This is the same place in the truss as the first round and '
        'the opposite answer, because that one was held at both ends and this '
        'one is held at one. Top and bottom is not the question. Which way the '
        'thing bends is.',
    source: 'stat-tjs-q1',
  ),
  WorkRound(
    subject: 'a member that is not being worked at all',
    setting:
        'The load hangs at the apex E. The member picked out runs from B up to '
        'that apex.',
    truss: _apex,
    member: 5,
    answer: Working.neither,
    why:
        'Neither. Nothing is applied at B and the bottom chord runs straight '
        'through it, so this member carries nothing and is neither stretched '
        'nor squashed. A zero-force member is the one case where the sign does '
        'not matter, because there is no number to put it on.',
    source: 'stat-tjs-q1',
  ),
];

class _StretchedOrSquashedGameState extends State<StretchedOrSquashedGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stretched-or-squashed',
    chapterId: 'statics',
    total: workRounds.length,
    sourceProblemIdOf: (round) => workRounds[round].source,
  )..addListener(_onSession);

  Working? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WorkRound get _round => workRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stretched or Squashed',
        closing:
            'Assume tension, always, and let the sign tell you the truth: '
            'negative means compression. A number on its own is not an answer '
            'on this exam. Say which way the member is being worked or you '
            'have not finished it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: senseOfForceBrief,
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
            'WHICH WAY IS IT BEING WORKED',
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
              height: 220,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: TrussPainter(
                    truss: r.truss,
                    mode: TrussMode.oneMember,
                    spotlight: r.member,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'member ${r.truss.memberName(r.member)}',
            style: AppTheme.mono(size: 11.5, color: AppColors.ember),
          ),
          const SizedBox(height: 12),
          for (final option in Working.values) ...[
            _WorkButton(
              key: ValueKey('working-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Working.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SENSE' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkButton extends StatelessWidget {
  const _WorkButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Working option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Working.stretched: 'Stretched',
    Working.squashed: 'Squashed',
    Working.neither: 'Neither',
  };

  static const _notes = {
    Working.stretched: 'tension, a positive answer',
    Working.squashed: 'compression, a negative answer',
    Working.neither: 'a zero-force member',
  };

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
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 46,
                height: 30,
                child: CustomPaint(
                  painter: _WorkingGlyph(option),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _titles[option]!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _notes[option]!,
                      style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A short bar with arrows saying what is being done to it: pulled out of both
/// ends, pushed into both ends, or left alone.
class _WorkingGlyph extends CustomPainter {
  const _WorkingGlyph(this.option);

  final Working option;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final ink = Paint()
      ..color = AppColors.charcoal
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // The bar itself sits in the middle, leaving room for an arrow at each end.
    const arrow = 11.0;
    final left = arrow + 3;
    final right = size.width - arrow - 3;
    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      Paint()
        ..color = AppColors.ink2
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    if (option == Working.neither) {
      // Nothing is being done to it, so nothing is drawn on it.
      return;
    }

    final out = option == Working.stretched;
    for (final end in [true, false]) {
      final anchor = end ? left : right;
      final away = end ? -1.0 : 1.0;
      // Pulling points away from the bar, pushing points into it.
      final tip = Offset(anchor + away * (out ? arrow : 0), y);
      final tail = Offset(anchor + away * (out ? 0 : arrow), y);
      canvas.drawLine(tail, tip, ink);
      final back = out ? -away : away;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + back * 6, tip.dy - 4)
          ..lineTo(tip.dx + back * 6, tip.dy + 4)
          ..close(),
        Paint()..color = AppColors.charcoal,
      );
    }
  }

  @override
  bool shouldRepaint(_WorkingGlyph old) => old.option != option;
}
