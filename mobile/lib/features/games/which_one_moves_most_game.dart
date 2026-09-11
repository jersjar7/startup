import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'thermal_figures.dart';

/// Which One Moves Most — the first item for
/// `thermal-processing-phase-diagrams`.
///
/// The expansion formula has three things in it and they all multiply, so the
/// arithmetic is a desk job and the judgment is not: which of three members
/// takes the biggest movement, and why. Every round moves ONE of the three so
/// that the answer can be reasoned rather than computed, and the last round
/// moves something that is not in the formula at all, because believing a
/// thicker member expands more is the misconception this drives out.
class WhichOneMovesMostGame extends StatefulWidget {
  const WhichOneMovesMostGame({super.key});

  @override
  State<WhichOneMovesMostGame> createState() => _WhichOneMovesMostGameState();
}

/// Which of the three rows, or none of them.
enum Biggest { top, middle, bottom, same }

extension BiggestWords on Biggest {
  String get plain => switch (this) {
        Biggest.top => 'The top one',
        Biggest.middle => 'The middle one',
        Biggest.bottom => 'The bottom one',
        Biggest.same => 'They all move the same',
      };
}

@immutable
class GrowRound {
  const GrowRound({
    required this.subject,
    required this.asked,
    required this.members,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final List<Member> members;
  final String why;
  final String source;

  /// Worked out from the three members, never declared.
  Biggest get answer {
    var best = 0;
    for (var i = 1; i < members.length; i++) {
      if (members[i].travel > members[best].travel) best = i;
    }
    final others = [
      for (var i = 0; i < members.length; i++)
        if (i != best) members[i].travel,
    ];
    final runnerUp = others.reduce((a, b) => a > b ? a : b);
    if ((members[best].travel - runnerUp).abs() / members[best].travel < 0.01) {
      return Biggest.same;
    }
    return [Biggest.top, Biggest.middle, Biggest.bottom][best];
  }

  /// How far clear the winner is, for a test that refuses a round nobody
  /// could call without a calculator.
  double get lead {
    final sorted = [for (final m in members) m.travel]..sort();
    return sorted.last / sorted[sorted.length - 2];
  }

  double get longest =>
      members.map((m) => m.meters).reduce((a, b) => a > b ? a : b);

  double get biggest =>
      members.map((m) => m.travel).reduce((a, b) => a > b ? a : b);
}

const growRounds = <GrowRound>[
  GrowRound(
    subject: 'three steel girders on the same day',
    asked:
        'The same steel, warming through the same range. Only the span is '
        'different.',
    members: [
      Member(stuff: Stuff.steel, meters: 8, from: 5, to: 40),
      Member(stuff: Stuff.steel, meters: 25, from: 5, to: 40),
      Member(stuff: Stuff.steel, meters: 40, from: 5, to: 40),
    ],
    why:
        'The longest one, and in direct proportion: five times the span is '
        'five times the movement. This is why a long bridge gets expansion '
        'joints and a short one usually does not, and why the joints go in at '
        'intervals rather than one enormous one at the end.',
    source: 'mat-tpd-q1',
  ),
  GrowRound(
    subject: 'three materials, same length, same day',
    asked:
        'Twelve meters of each, all warming by the same thirty degrees.',
    members: [
      Member(stuff: Stuff.steel, meters: 12, from: 0, to: 30),
      Member(stuff: Stuff.aluminum, meters: 12, from: 0, to: 30),
      Member(stuff: Stuff.concrete, meters: 12, from: 0, to: 30),
    ],
    why:
        'The aluminum, which moves about twice as much as the steel and the '
        'concrete for the same warming. Steel and concrete are close enough '
        'to each other that reinforced concrete holds together through a '
        'temperature swing at all, which is not a small coincidence. Aluminum '
        'is the odd one out, and an aluminum curtain wall on a concrete frame '
        'has to be detailed for it.',
    source: 'mat-tpd-q1',
  ),
  GrowRound(
    subject: 'the same girder, three days',
    asked:
        'One twenty meter steel girder, three different temperature swings. '
        'Read each one carefully.',
    members: [
      Member(stuff: Stuff.steel, meters: 20, from: 5, to: 40),
      Member(stuff: Stuff.steel, meters: 20, from: 18, to: 30),
      Member(stuff: Stuff.steel, meters: 20, from: -5, to: 12),
    ],
    why:
        'The first, because thirty five degrees of change is the biggest of '
        'the three. What matters is the DIFFERENCE between the two '
        'temperatures and never the temperatures themselves: adding them '
        'instead of subtracting is this problem\'s own named trap, and the '
        'coldest day on the list is not the one that moves least.',
    source: 'mat-tpd-q1',
  ),
  GrowRound(
    subject: 'a warm day against a better material',
    asked:
        'Six meters of each. The aluminum barely warms and the steel warms a '
        'lot.',
    members: [
      Member(stuff: Stuff.aluminum, meters: 6, from: 20, to: 30),
      Member(stuff: Stuff.steel, meters: 6, from: 10, to: 40),
      Member(stuff: Stuff.concrete, meters: 6, from: 5, to: 25),
    ],
    why:
        'The steel, even though aluminum expands twice as readily. Three '
        'times the temperature change beats twice the coefficient, and that '
        'is the whole point of the three numbers multiplying: no one of them '
        'decides anything on its own.',
    source: 'mat-tpd-q1',
  ),
  GrowRound(
    subject: 'what a joint actually has to take',
    asked:
        'Three parts of the same building, all through the same twenty five '
        'degree swing.',
    members: [
      Member(stuff: Stuff.concrete, meters: 30, from: 10, to: 35),
      Member(stuff: Stuff.aluminum, meters: 5, from: 10, to: 35),
      Member(stuff: Stuff.steel, meters: 12, from: 10, to: 35),
    ],
    why:
        'The concrete slab, because it is by far the longest run. In real '
        'buildings the length usually wins the argument: the aluminum moves '
        'twice as readily per meter and has six times less to work with. When '
        'you are looking for where the movement will show up, look for the '
        'long uninterrupted run first.',
    source: 'mat-tpd-q1',
  ),
  GrowRound(
    subject: 'three steel members of different sections',
    asked:
        'Fifteen meters of steel each, same thirty degree warming. They are '
        'different sections.',
    members: [
      Member(
          stuff: Stuff.steel,
          meters: 15,
          from: 0,
          to: 30,
          note: 'a light angle'),
      Member(
          stuff: Stuff.steel,
          meters: 15,
          from: 0,
          to: 30,
          note: 'a heavy column'),
      Member(
          stuff: Stuff.steel, meters: 15, from: 0, to: 30, note: 'a thin rod'),
    ],
    why:
        'All the same. How thick a member is appears nowhere in the formula: '
        'the movement is the coefficient times the length times the '
        'temperature change, full stop. A heavy column and a thin rod of the '
        'same steel and the same length move by exactly the same amount. '
        'Thickness decides how much FORCE it takes to stop them moving, which '
        'is a different question.',
    source: 'mat-tpd-q1',
  ),
];

class _WhichOneMovesMostGameState extends State<WhichOneMovesMostGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-one-moves-most',
    chapterId: 'materials',
    total: growRounds.length,
    sourceProblemIdOf: (round) => growRounds[round].source,
  )..addListener(_onSession);

  Biggest? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  GrowRound get _round => growRounds[_session.round];

  int? get _pickedRow => switch (_picked) {
        Biggest.top => 0,
        Biggest.middle => 1,
        Biggest.bottom => 2,
        _ => null,
      };

  int? _answerRow(GrowRound r) => switch (r.answer) {
        Biggest.top => 0,
        Biggest.middle => 1,
        Biggest.bottom => 2,
        Biggest.same => null,
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Biggest Most',
        closing:
            'Three things multiply: what it is made of, how long it is, and '
            'how much the temperature changes. Aluminum moves about twice as '
            'readily as steel or concrete, length counts in direct '
            'proportion, and the temperature change is a difference, never a '
            'sum. How thick it is does not come into it at all.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: expandBrief,
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
            'TAP THE ONE THAT MOVES MOST',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 270);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final row =
                            MemberPainter.rowAt(size, details.localPosition);
                        if (row == null) return;
                        setState(() => _picked =
                            [Biggest.top, Biggest.middle, Biggest.bottom][row]);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: MemberPainter(
                        members: r.members,
                        longest: r.longest,
                        biggest: r.biggest,
                        picked: _pickedRow,
                        answer: _answerRow(r),
                        locked: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'bars drawn to length. the movement is shown once you answer',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\Delta L = \alpha L \Delta T$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Biggest.same.plain,
            selected: _picked == Biggest.same,
            locked: answered,
            isTruth: r.answer == Biggest.same,
            onTap: answered ? null : () => setState(() => _picked = Biggest.same),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (locked && isTruth) {
      border = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
    } else {
      border = AppColors.line;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
