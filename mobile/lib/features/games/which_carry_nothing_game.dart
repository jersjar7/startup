import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart' show Prop;
import 'board.dart';
import 'lesson_brief.dart';
import 'truss_figures.dart';

/// Which Ones Carry Nothing — the first item for `trusses-joints-sections`.
///
/// The lesson's exam callout says to scan for zero-force members BEFORE doing
/// any calculation, and the two rules are the only ones in this chapter that
/// answer a question about forces without arithmetic. Two members at a joint
/// nobody is pulling on, and both are idle. Three at such a joint with two of
/// them in line, and the odd one out is idle.
///
/// So the truss is drawn and the members are tapped. What makes it more than
/// pattern-matching is the load: the last round has two joints with exactly the
/// same geometry and something applied at one of them, so the shape alone
/// answers half of it and gets the other half wrong.
class WhichCarryNothingGame extends StatefulWidget {
  const WhichCarryNothingGame({super.key});

  @override
  State<WhichCarryNothingGame> createState() => _WhichCarryNothingGameState();
}

@immutable
class IdleRound {
  const IdleRound({
    required this.subject,
    required this.setting,
    required this.truss,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Truss truss;
  final String why;
  final String source;

  /// Worked out from the truss by the two rules, never declared beside it.
  Set<int> get answer => truss.idle;
}

/// The row under the truss, for a truss where everything is working.
const everythingWorks = 'Nothing. Every member carries something';

const idleRounds = <IdleRound>[
  IdleRound(
    subject: 'three members at an unloaded joint',
    setting:
        'Two of the members at C run straight through it in the same line. The '
        'third goes up to the apex, and nothing is applied at C.',
    truss: Truss(
      joints: [
        Joint('A', Offset(0, 0)),
        Joint('C', Offset(3, 0)),
        Joint('E', Offset(6, 0)),
        Joint('D', Offset(3, 2)),
      ],
      members: [(0, 1), (1, 2), (1, 3), (0, 3), (3, 2)],
      supports: {0: Prop.pin, 2: Prop.roller},
      loads: {3: '12 kN'},
    ),
    why:
        'CD, and by inspection. AC and CE are in line, so whatever one of them '
        'pulls the other pulls straight back, and there is nothing left over '
        'for CD to balance. It is holding the joint in place and carrying '
        'nothing while it does.',
    source: 'stat-tjs-q1',
  ),
  IdleRound(
    subject: 'a corner with two members and nothing on it',
    setting:
        'The joint at C has exactly two members meeting at it, at an angle, '
        'and nothing is applied there.',
    truss: Truss(
      joints: [
        Joint('A', Offset(0, 0)),
        Joint('B', Offset(4, 0)),
        Joint('C', Offset(0, 3)),
        Joint('D', Offset(4, 3)),
      ],
      members: [(0, 1), (0, 2), (1, 3), (2, 3), (0, 3)],
      supports: {0: Prop.pin, 1: Prop.roller},
      loads: {3: '9 kN'},
    ),
    why:
        'Both of them, AC and CD. Two members at an unloaded joint pull in two '
        'different directions and there is nothing else there to balance '
        'either one, so both have to be zero. Neither is useless: take them '
        'out and the corner has nothing holding its shape.',
    source: 'stat-tjs-q1',
  ),
  IdleRound(
    subject: 'a truss with nothing spare in it',
    setting:
        'A single triangle, held at both feet and loaded at the top.',
    truss: Truss(
      joints: [
        Joint('A', Offset(0, 0)),
        Joint('B', Offset(6, 0)),
        Joint('C', Offset(3, 4)),
      ],
      members: [(0, 1), (0, 2), (1, 2)],
      supports: {0: Prop.pin, 1: Prop.roller},
      loads: {2: '10 kN'},
    ),
    why:
        'None of them. Every joint here has something applied to it, a load at '
        'C and a reaction at each foot, so neither rule gets a look in. The '
        'scan is still worth doing: it takes a second and it tells you there '
        'is no shortcut waiting.',
    source: 'stat-tjs-q2',
  ),
  IdleRound(
    subject: 'a three panel truss under one load',
    setting:
        'The load sits at F, on the top chord. Look along the bottom chord for '
        'a joint with nothing applied to it.',
    truss: Truss(
      joints: [
        Joint('A', Offset(0, 0)),
        Joint('B', Offset(3, 0)),
        Joint('C', Offset(6, 0)),
        Joint('D', Offset(9, 0)),
        Joint('E', Offset(3, 4)),
        Joint('F', Offset(6, 4)),
      ],
      members: [
        (0, 1),
        (1, 2),
        (2, 3),
        (0, 4),
        (4, 5),
        (5, 3),
        (1, 4),
        (2, 4),
        (2, 5),
      ],
      supports: {0: Prop.pin, 3: Prop.roller},
      loads: {5: '24 kN'},
    ),
    why:
        'BE. At B the two bottom chord members are in line and nothing is '
        'applied, so the vertical has nothing to do. C looks similar and is '
        'not: four members meet there, and neither rule covers four.',
    source: 'stat-tjs-q3',
  ),
  IdleRound(
    subject: 'two verticals off the bottom chord',
    setting:
        'The load hangs at the apex. Both B and C have three members and '
        'nothing applied.',
    truss: Truss(
      joints: [
        Joint('A', Offset(0, 0)),
        Joint('B', Offset(2, 0)),
        Joint('C', Offset(4, 0)),
        Joint('D', Offset(6, 0)),
        Joint('E', Offset(3, 2.5)),
      ],
      members: [(0, 1), (1, 2), (2, 3), (0, 4), (4, 3), (1, 4), (2, 4)],
      supports: {0: Prop.pin, 3: Prop.roller},
      loads: {4: '16 kN'},
    ),
    why:
        'BE and CE, both by the same rule and for the same reason. The bottom '
        'chord runs straight through each of them, and with nothing applied at '
        'either joint the member coming up to the apex has nothing to balance.',
    source: 'stat-tjs-q1',
  ),
  IdleRound(
    subject: 'the same truss, loaded somewhere else',
    setting:
        'The same shape, but this time the load hangs at C on the bottom chord '
        'rather than at the apex.',
    truss: Truss(
      joints: [
        Joint('A', Offset(0, 0)),
        Joint('B', Offset(2, 0)),
        Joint('C', Offset(4, 0)),
        Joint('D', Offset(6, 0)),
        Joint('E', Offset(3, 2.5)),
      ],
      members: [(0, 1), (1, 2), (2, 3), (0, 4), (4, 3), (1, 4), (2, 4)],
      supports: {0: Prop.pin, 3: Prop.roller},
      loads: {2: '16 kN'},
    ),
    why:
        'BE only. C has exactly the geometry it had a moment ago and the load '
        'is sitting on it, so CE is now carrying that load up to the apex. The '
        'rules are about what is applied at the joint as much as about what '
        'meets there, and the picture alone will not tell you.',
    source: 'stat-tjs-q1',
  ),
];

class _WhichCarryNothingGameState extends State<WhichCarryNothingGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-carry-nothing',
    chapterId: 'statics',
    total: idleRounds.length,
    sourceProblemIdOf: (round) => idleRounds[round].source,
  )..addListener(_onSession);

  final _picked = <int>{};
  bool _none = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  IdleRound get _round => idleRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Ones Carry Nothing',
        closing:
            'Two members at a joint nobody is pulling on, and both are idle. '
            'Three with two of them in line, and the odd one out is idle. Both '
            'rules need the joint to be UNLOADED, and both stop at three '
            'members. Scan for them before writing an equation, because each '
            'one is an unknown you never have to find.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final truth = r.answer;

    return BoardShell(
      session: _session,
      brief: zeroForceBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _picked.clear();
                _none = false;
              });
              _session.next();
            }
          : (_picked.isEmpty && !_none
                ? null
                : () => _session.submit(
                    ok: _none
                        ? truth.isEmpty
                        : _picked.length == truth.length &&
                            _picked.containsAll(truth),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP EVERY MEMBER CARRYING NOTHING',
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
          _TrussBoard(
            truss: r.truss,
            picked: _none ? const <int>{} : _picked,
            truths: truth,
            locked: answered,
            onTap: answered
                ? null
                : (m) => setState(() {
                      _none = false;
                      if (!_picked.add(m)) _picked.remove(m);
                    }),
          ),
          const SizedBox(height: 8),
          _NoneRow(
            selected: _none,
            locked: answered,
            isTruth: truth.isEmpty,
            onTap: answered
                ? null
                : () => setState(() {
                      _picked.clear();
                      _none = !_none;
                    }),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SET' : 'NOT THAT SET',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The truss, with a tap target over the middle of every member.
class _TrussBoard extends StatelessWidget {
  const _TrussBoard({
    required this.truss,
    required this.picked,
    required this.truths,
    required this.locked,
    required this.onTap,
  });

  final Truss truss;
  final Set<int> picked;
  final Set<int> truths;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 250.0;

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
                      painter: TrussPainter(
                        truss: truss,
                        mode: TrussMode.members,
                        chosen: picked,
                        truths: truths,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var m = 0; m < truss.members.length; m++)
                    _target(m, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _target(int m, Size size) {
    final (a, b) = truss.members[m];
    final mid = (truss.joints[a].at + truss.joints[b].at) / 2;
    final at = TrussPainter.toScreen(truss, mid, size);
    const box = 44.0;
    return Positioned(
      key: ValueKey('member-$m'),
      left: at.dx - box / 2,
      top: at.dy - box / 2,
      width: box,
      height: box,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(m),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _NoneRow extends StatelessWidget {
  const _NoneRow({
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
      key: const ValueKey('everything-works'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            everythingWorks,
            style: const TextStyle(fontSize: 14.5, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
