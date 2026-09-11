import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'kinetics_figures.dart';
import 'lesson_brief.dart';

/// Push It or Spin It — the third item for `force-and-acceleration`.
///
/// A rigid body has two equations, not one: the forces move its mass center
/// and the moments about that center spin it. Which of the two you need is
/// decided by what is holding the body and where the force lands, and the
/// lesson's hardest problem names both mistakes: using F equals m a on a
/// rotation problem, and putting a force into a moment equation without
/// turning it into a torque first.
class PushItOrSpinItGame extends StatefulWidget {
  const PushItOrSpinItGame({super.key});

  @override
  State<PushItOrSpinItGame> createState() => _PushItOrSpinItGameState();
}

/// Which equation the situation needs.
enum Needs2 { force, moment, both }

extension Needs2Words on Needs2 {
  String get plain => switch (this) {
        Needs2.force => 'Only the force equation',
        Needs2.moment => 'Only the moment equation',
        Needs2.both => 'Both of them together',
      };
}

@immutable
class ShoveRound {
  const ShoveRound({
    required this.subject,
    required this.setting,
    required this.pushed,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Pushed pushed;
  final String why;
  final String source;

  /// Read off the situation: an axle stops it moving off, a force through the
  /// mass center gives it nothing to spin about.
  Needs2 get answer {
    if (pushed.translates && pushed.rotates) return Needs2.both;
    return pushed.translates ? Needs2.force : Needs2.moment;
  }
}

const shoveRounds = <ShoveRound>[
  ShoveRound(
    subject: 'a crate pushed across the floor',
    setting:
        'A horizontal push through the middle of a crate sliding on a '
        'frictionless floor.',
    pushed: Pushed(round: false, held: Held2.floor, lands: Lands.middle),
    why:
        'The force equation on its own. The push goes through the mass center, '
        'so there is nothing for it to turn the crate about, and the crate '
        'simply moves off. Sum F equals m a in one direction is the whole '
        'problem, which is the lesson\'s first one.',
    source: 'dyn-fa-q1',
  ),
  ShoveRound(
    subject: 'a disk on a fixed axle',
    setting:
        'A disk is mounted on a frictionless axle through its center and '
        'pushed at the rim.',
    pushed: Pushed(round: true, held: Held2.axle, lands: Lands.rim),
    why:
        'The moment equation on its own. The axle holds the middle of the disk '
        'exactly where it is, so nothing moves off anywhere: the push goes to '
        'spinning it. Sum M equals I alpha, and the force has to be turned '
        'into a torque first by multiplying by the radius. That last step is '
        'the named trap in this lesson\'s hardest problem.',
    source: 'dyn-fa-q3',
  ),
  ShoveRound(
    subject: 'a free disk pushed off center',
    setting:
        'The same disk floating free, nothing holding it, pushed at the rim.',
    pushed: Pushed(round: true, held: Held2.free, lands: Lands.rim),
    why:
        'Both. With the axle gone there is nothing to stop the disk moving '
        'off, so the force still accelerates its mass center, AND the push is '
        'off center so it spins as well. Two equations, and they are answering '
        'two different questions about the same push.',
    source: 'dyn-fa-q3',
  ),
  ShoveRound(
    subject: 'a free disk pushed through the middle',
    setting: 'The same free disk, pushed straight through its center.',
    pushed: Pushed(round: true, held: Held2.free, lands: Lands.middle),
    why:
        'The force equation only. Nothing is holding it, so it moves off, and '
        'the push lines up with the mass center so there is no moment about '
        'that center at all. It slides without turning. Where a force LANDS '
        'decides whether it spins anything.',
    source: 'dyn-fa-q1',
  ),
  ShoveRound(
    subject: 'a crate shoved at its top corner',
    setting:
        'A crate on a frictionless floor, pushed at its top corner rather '
        'than through the middle.',
    pushed: Pushed(round: false, held: Held2.floor, lands: Lands.corner),
    why:
        'Both. It slides off exactly as before, since the same force acts on '
        'the same mass, and it also starts to tip, because the push has a '
        'moment about the mass center. This is why a tall load is shoved low '
        'rather than high.',
    source: 'dyn-fa-q3',
  ),
  ShoveRound(
    subject: 'a wheel on its axle, pushed at the middle',
    setting:
        'A wheel on a fixed axle, with the force applied at the axle itself '
        'rather than at the rim.',
    pushed: Pushed(round: true, held: Held2.axle, lands: Lands.middle),
    why:
        'The moment equation, and it gives zero: this push does nothing at '
        'all. The axle holds the middle so it cannot move off, and the force '
        'goes straight through the axle so it has no arm and no moment. A '
        'force through the point a body turns about spins it exactly as much '
        'as no force would.',
    source: 'dyn-fa-q3',
  ),
];

class _PushItOrSpinItGameState extends State<PushItOrSpinItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'push-it-or-spin-it',
    chapterId: 'dynamics',
    total: shoveRounds.length,
    sourceProblemIdOf: (round) => shoveRounds[round].source,
  )..addListener(_onSession);

  Needs2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ShoveRound get _round => shoveRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Push It or Spin It',
        closing:
            'Forces move the mass center and moments about that center spin '
            'the body. An axle stops it moving off, so only the moment '
            'equation is left. A force through the mass center has no arm, so '
            'only the force equation is left. Anything else needs both, and a '
            'force only becomes a moment once you multiply it by its distance '
            'from the center.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: twoEquationsBrief,
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
            'WHICH EQUATION DOES THIS NEED',
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
              height: 180,
              child: CustomPaint(
                painter: PushPainter(pushed: r.pushed),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            r.pushed.held == Held2.axle
                ? 'the ring at the middle is a fixed axle'
                : r.pushed.held == Held2.floor
                    ? 'resting on a frictionless floor'
                    : 'nothing is holding it',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\sum F = ma_c, \quad \sum M_c = I_c\alpha$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final n in Needs2.values) ...[
            _Choice(
              label: n.plain,
              selected: _picked == n,
              locked: answered,
              isTruth: n == r.answer,
              onTap: answered ? null : () => setState(() => _picked = n),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 8),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT NEEDS' : 'NOT QUITE',
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
