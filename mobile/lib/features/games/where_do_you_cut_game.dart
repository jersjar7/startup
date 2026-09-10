import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'beam_figures.dart' show Prop;
import 'board.dart';
import 'lesson_brief.dart';
import 'truss_figures.dart';

/// Where Do You Cut — the third item for `trusses-joints-sections`.
///
/// The lesson's third problem is the one that separates people who know the
/// method of sections from people who have read about it. Joint by joint from
/// the end will get you there eventually. One cut gets you there in a single
/// set of equations, but only if the cut is in the right place: it has to pass
/// through the member you want, and it has to pass through no more than three
/// members altogether, because three is all the equations you have.
///
/// So the truss is drawn with candidate cuts already on it and the answer is
/// which one you would take. The distractors are not silly. Each one either
/// misses the member or severs four, which is the mistake that costs a whole
/// question.
class WhereDoYouCutGame extends StatefulWidget {
  const WhereDoYouCutGame({super.key});

  @override
  State<WhereDoYouCutGame> createState() => _WhereDoYouCutGameState();
}

@immutable
class CutRound {
  const CutRound({
    required this.subject,
    required this.setting,
    required this.truss,
    required this.member,
    required this.cuts,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Truss truss;

  /// The member the round wants the force in.
  final int member;

  final List<Cut> cuts;
  final String why;
  final String source;

  /// The cut that passes through the wanted member and through exactly three
  /// members altogether. Worked out from the geometry, never declared, so a
  /// round cannot draw one set of lines and grade another.
  int get answer {
    for (var i = 0; i < cuts.length; i++) {
      final through = cuts[i].through(truss);
      if (through.length == 3 && through.contains(member)) return i;
    }
    return -1;
  }
}

/// Simply supported, nine meters, load hung on the top chord at F.
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

/// Four panels, verticals at every bottom joint and a diagonal each side of
/// the middle.
const _fourPanel = Truss(
  joints: [
    Joint('A', Offset(0, 0)),
    Joint('B', Offset(2, 0)),
    Joint('C', Offset(4, 0)),
    Joint('D', Offset(6, 0)),
    Joint('E', Offset(8, 0)),
    Joint('F', Offset(2, 3)),
    Joint('G', Offset(4, 3)),
    Joint('H', Offset(6, 3)),
  ],
  members: [
    (0, 1), // 0 AB
    (1, 2), // 1 BC
    (2, 3), // 2 CD
    (3, 4), // 3 DE
    (5, 6), // 4 FG
    (6, 7), // 5 GH
    (0, 5), // 6 AF
    (7, 4), // 7 HE
    (1, 5), // 8 BF
    (2, 6), // 9 CG
    (3, 7), // 10 DH
    (5, 2), // 11 FC
    (2, 7), // 12 CH
  ],
  supports: {0: Prop.pin, 4: Prop.roller},
  loads: {6: '20 kN'},
);

const cutRounds = <CutRound>[
  CutRound(
    subject: 'the top chord over the middle',
    setting:
        'You want the force in EF and nothing else. Three lines are drawn '
        'across the truss. Tap the one you would take the section on.',
    truss: _deck,
    member: 4,
    cuts: [
      Cut('cut 1', Offset(1.5, -0.45), Offset(1.5, 4.45)),
      Cut('cut 2', Offset(4.5, -0.45), Offset(4.5, 4.45)),
      Cut('cut 3', Offset(7.5, -0.45), Offset(7.5, 4.45)),
    ],
    why:
        'Cut 2, the only one that goes through EF at all. It severs three '
        'members, BC, CE and EF, and three unknowns is exactly what three '
        'equations will buy you. The other two never touch the member you were '
        'asked for, so no amount of algebra on them will produce it.',
    source: 'stat-tjs-q3',
  ),
  CutRound(
    subject: 'a cut that takes one member too many',
    setting:
        'You want GH. One of these lines does cross it and still will not do.',
    truss: _fourPanel,
    member: 5,
    cuts: [
      Cut('cut 1', Offset(2.6, -0.45), Offset(2.6, 3.45)),
      Cut('cut 2', Offset(5.6, -0.45), Offset(5.6, 3.45)),
      Cut('cut 3', Offset(6.34, -0.45), Offset(4.3, 3.45)),
    ],
    why:
        'Cut 2. Cut 3 runs through GH as well, but it also takes DE, DH and '
        'CH, which is four unknowns against three equations and nothing you '
        'can do about it. Cut 1 is a clean three member cut somewhere else '
        'entirely. Crossing the member is half the test. Counting what else '
        'you crossed is the other half.',
    source: 'stat-tjs-q3',
  ),
  CutRound(
    subject: 'a bottom chord member near the support',
    setting: 'This time the force wanted is in BC, down on the bottom chord.',
    truss: _fourPanel,
    member: 1,
    cuts: [
      Cut('cut 1', Offset(1, -0.45), Offset(1, 3.45)),
      Cut('cut 2', Offset(3, -0.45), Offset(3, 3.45)),
      Cut('cut 3', Offset(5, -0.45), Offset(5, 3.45)),
    ],
    why:
        'Cut 2, through BC, FG and FC. Cut 1 is not wrong so much as it is not '
        'a section: it fences off joint A on its own with two members, which is '
        'the method of joints wearing a dashed line. Cut 3 is a proper section '
        'through the wrong panel.',
    source: 'stat-tjs-q3',
  ),
  CutRound(
    subject: 'a diagonal rather than a chord',
    setting:
        'The force wanted is in the diagonal CE. Sections work on diagonals '
        'the same way they work on chords.',
    truss: _deck,
    member: 7,
    cuts: [
      Cut('cut 1', Offset(4.5, -0.45), Offset(4.5, 4.45)),
      Cut('cut 2', Offset(0.6, -0.45), Offset(6.3, 4.45)),
      Cut('cut 3', Offset(8.5, -0.45), Offset(8.5, 4.45)),
    ],
    why:
        'Cut 1, the same three member cut as the first round. That is the '
        'point worth taking away: one section hands you all three of the '
        'members it severs, so the cut you take for the top chord is the cut '
        'you take for the diagonal beside it. Cut 2 leans over far enough to '
        'pick up AB and BE as well, which is four.',
    source: 'stat-tjs-q3',
  ),
  CutRound(
    subject: 'a cut that does not have to be vertical',
    setting:
        'The force wanted is in the vertical CF. A line straight down the '
        'middle of it would pass through both of its ends, which is no cut at '
        'all.',
    truss: _deck,
    member: 8,
    cuts: [
      Cut('cut 1', Offset(3.6, -0.45), Offset(3.6, 4.45)),
      Cut('cut 2', Offset(7.42, -0.45), Offset(5.78, 4.45)),
      Cut('cut 3', Offset(8.2, -0.45), Offset(8.2, 4.45)),
    ],
    why:
        'Cut 2, leaning across. Nothing says a section has to be vertical, and '
        'for a member standing straight up it cannot be: it has to cross the '
        'member, not run along it. This one takes EF, CF and CD, and three is '
        'three however the line is tilted.',
    source: 'stat-tjs-q3',
  ),
  CutRound(
    subject: 'the same cut, a different member',
    setting: 'Back to the four panel truss. Now the force wanted is in CH.',
    truss: _fourPanel,
    member: 12,
    cuts: [
      Cut('cut 1', Offset(2.6, -0.45), Offset(2.6, 3.45)),
      Cut('cut 2', Offset(5.6, -0.45), Offset(5.6, 3.45)),
      Cut('cut 3', Offset(6.34, -0.45), Offset(4.3, 3.45)),
    ],
    why:
        'Cut 2, which is where you cut for GH earlier on. A section is not '
        'aimed at a member, it is aimed at a panel, and it gives you every '
        'member it severs. Cut 3 crosses CH too and costs you a fourth '
        'unknown for the privilege.',
    source: 'stat-tjs-q3',
  ),
];

class _WhereDoYouCutGameState extends State<WhereDoYouCutGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-do-you-cut',
    chapterId: 'statics',
    total: cutRounds.length,
    sourceProblemIdOf: (round) => cutRounds[round].source,
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

  CutRound get _round => cutRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where Do You Cut',
        closing:
            'A section has to cross the member you were asked for, and it has '
            'to cross no more than three members altogether, because three '
            'equations is all a flat body gives you. Count the members the '
            'line crosses before you write anything down. If it is four, move '
            'the line.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: sectionBrief,
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
            'TAP THE CUT YOU WOULD TAKE',
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
          const SizedBox(height: 6),
          Text(
            'wanted: member ${r.truss.memberName(r.member)}',
            style: AppTheme.mono(size: 11.5, color: AppColors.ember),
          ),
          const SizedBox(height: 10),
          _CutBoard(
            round: r,
            picked: _picked,
            locked: answered,
            onTap: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE CUT' : 'NOT THAT LINE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _CutBoard extends StatelessWidget {
  const _CutBoard({
    required this.round,
    required this.picked,
    required this.locked,
    required this.onTap,
  });

  final CutRound round;
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
                      painter: TrussPainter(
                        truss: round.truss,
                        mode: TrussMode.cuts,
                        spotlight: round.member,
                        cuts: round.cuts,
                        selected: picked,
                        truth: round.answer,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var i = 0; i < round.cuts.length; i++) _target(i, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// The tap target sits on the label at the top of the cut, which is the one
  /// part of a cut line guaranteed to be clear of the truss.
  Widget _target(int i, Size size) {
    final at = TrussPainter.labelSpot(round.truss, round.cuts[i], size,
        round.cuts);
    const box = 46.0;
    return Positioned(
      key: ValueKey('cut-$i'),
      left: at.dx - box / 2,
      top: at.dy - box / 2 + 6,
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
