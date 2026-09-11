import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'collision_figures.dart';
import 'lesson_brief.dart';

/// What Survives the Crash — the second item for `impulse-and-momentum`.
///
/// The lesson says it twice and it is still the most common wrong turn in the
/// topic: momentum survives every collision, and kinetic energy survives only
/// a perfect bounce. Since the energy question is answerable by looking at the
/// word "stick" rather than by computing anything, it belongs on a phone.
class WhatSurvivesTheCrashGame extends StatefulWidget {
  const WhatSurvivesTheCrashGame({super.key});

  @override
  State<WhatSurvivesTheCrashGame> createState() =>
      _WhatSurvivesTheCrashGameState();
}

/// Which of the two quantities comes out the other side unchanged.
enum Survives { momentumOnly, both, neither }

extension SurvivesWords on Survives {
  String get plain => switch (this) {
        Survives.momentumOnly => 'The momentum, but not the energy',
        Survives.both => 'Both of them',
        Survives.neither => 'Neither of them',
      };
}

@immutable
class SurviveRound {
  const SurviveRound({
    required this.subject,
    required this.setting,
    required this.crash,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Crash crash;
  final String why;
  final String source;

  /// Worked out by putting the crash through both books.
  Survives get answer {
    if (!crash.momentumKept) return Survives.neither;
    return crash.energyKept ? Survives.both : Survives.momentumOnly;
  }

  /// How much of the energy is left, for the feedback to quote.
  int get energyLeft =>
      (crash.energyAfter / crash.energyBefore * 100).round();
}

const surviveRounds = <SurviveRound>[
  SurviveRound(
    subject: 'the cars with locked bumpers',
    setting:
        'Two tonnes at fifteen meters a second into one tonne at rest, and '
        'they lock together.',
    crash: Crash(massA: 2000, massB: 1000, speedA: 15, e: 0),
    why:
        'The momentum only. It has to survive, because nothing outside is '
        'pushing on the pair during the bang. The energy does not: a third of '
        'it goes into bending metal here, and that is the whole reason the '
        'front of a car is built to crumple. Conserving the energy in a crash '
        'like this is the lesson\'s named trap.',
    source: 'dyn-im-q1',
  ),
  SurviveRound(
    subject: 'hardened steel balls',
    setting:
        'One steel ball swings into an identical one and bounces off it '
        'cleanly, e of one.',
    crash: Crash(massA: 1, massB: 1, speedA: 3, e: 1),
    why:
        'Both. A perfect bounce is the one case where the energy comes through '
        'untouched as well as the momentum, and it is the definition of e '
        'being one rather than a coincidence. Real steel gets close and never '
        'quite arrives.',
    source: 'dyn-im-q2',
  ),
  SurviveRound(
    subject: 'the lesson\'s two balls',
    setting:
        'Equal masses, eight meters a second into one at rest, with a '
        'restitution of nought point five.',
    crash: Crash(massA: 2, massB: 2, speedA: 8, e: 0.5),
    why:
        'The momentum only, again. Anything short of a perfect bounce loses '
        'energy, and at an e of a half this one keeps about five eighths of '
        'it. The rule has no middle ground: either e is one and the energy '
        'survives, or it is not and some of it is gone.',
    source: 'dyn-im-q2',
  ),
  SurviveRound(
    subject: 'a bullet into a block',
    setting:
        'A twenty gram bullet at four hundred meters a second buries itself '
        'in a three kilogram block.',
    crash: Crash(massA: 0.02, massB: 3, speedA: 400, e: 0),
    why:
        'The momentum only, and here the energy loss is spectacular: over '
        'ninety nine percent of it is gone into heat and splintered wood. '
        'Momentum still comes through in full. That difference is why a '
        'ballistic pendulum is solved with momentum for the impact and energy '
        'only for the swing afterward.',
    source: 'dyn-im-q1',
  ),
  SurviveRound(
    subject: 'railway wagons coupling',
    setting:
        'A forty tonne wagon at one and a half meters a second couples to a '
        'twenty five tonne one standing still.',
    crash: Crash(massA: 40000, massB: 25000, speedA: 1.5, e: 0),
    why:
        'The momentum only. The size of the things changes nothing: coupling '
        'is e of nothing, so energy goes into the couplers and the momentum '
        'carries on. About two fifths of the energy is lost in this one.',
    source: 'dyn-im-q1',
  ),
  SurviveRound(
    subject: 'a ball bouncing off a wall',
    setting:
        'A ball hits a heavy wall and comes back at almost the speed it '
        'arrived with, e near one.',
    crash: Crash(massA: 0.2, massB: 100000, speedA: 5, e: 1),
    why:
        'Both, near enough. The ball keeps its speed so it keeps its energy, '
        'and the momentum is conserved too, though it takes a moment to see '
        'how: the ball reverses, so its momentum changes by twice what it had, '
        'and the wall, with the whole planet behind it, takes up that change '
        'while moving immeasurably slowly. Momentum is conserved across the '
        'PAIR, never by one body alone.',
    source: 'dyn-im-q2',
  ),
];

class _WhatSurvivesTheCrashGameState extends State<WhatSurvivesTheCrashGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-survives-the-crash',
    chapterId: 'dynamics',
    total: surviveRounds.length,
    sourceProblemIdOf: (round) => surviveRounds[round].source,
  )..addListener(_onSession);

  Survives? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SurviveRound get _round => surviveRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Survives the Crash',
        closing:
            'Momentum survives every collision, because nothing outside is '
            'pushing on the pair while it happens. Kinetic energy survives '
            'only a perfect bounce. Everything in between loses some, and a '
            'crash where things stick together loses the most. Read the word '
            'stick and you already know the energy is gone.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: survivesBrief,
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
            'WHAT COMES THROUGH UNCHANGED',
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
          const SizedBox(height: 12),
          EngineeringGrid(
            minor: 18,
            major: 90,
            child: SizedBox(
              height: 150,
              child: CustomPaint(
                painter: CrashPainter(crash: r.crash, showAfter: true),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final s in Survives.values) ...[
            _Choice(
              label: s.plain,
              selected: _picked == s,
              locked: answered,
              isTruth: s == r.answer,
              onTap: answered ? null : () => setState(() => _picked = s),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            Text(
              'about ${r.energyLeft} percent of the energy is left',
              style: AppTheme.mono(size: 12, color: AppColors.forest),
            ),
            const SizedBox(height: 10),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT SURVIVES' : 'LOOK AGAIN',
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
