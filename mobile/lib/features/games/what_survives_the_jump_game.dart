import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'flow_figures.dart';

/// What Survives the Jump — the third item for `energy-critical-flow`.
///
/// The conjugate depth formula is arithmetic and belongs on paper. What
/// belongs in your head is the bookkeeping either side of it: the water and
/// the momentum come through, the energy does not. That is not a detail. It
/// is the reason the conjugate depth formula exists at all rather than
/// being solved with an energy balance, and it is the reason a stilling
/// basin is built in the first place.
class WhatSurvivesTheJumpGame extends StatefulWidget {
  const WhatSurvivesTheJumpGame({super.key});

  @override
  State<WhatSurvivesTheJumpGame> createState() =>
      _WhatSurvivesTheJumpGameState();
}

/// What the quantity does from one side of the jump to the other.
enum Crossing { up, down, same }

extension CrossingWords on Crossing {
  String get plain => switch (this) {
        Crossing.up => 'It is larger downstream',
        Crossing.down => 'It is smaller downstream',
        Crossing.same => 'It comes through unchanged',
      };
}

@immutable
class WayRound {
  const WayRound({
    required this.subject,
    required this.surge,
    required this.asked,
    required this.why,
    required this.source,
  });

  final String subject;
  final Surge surge;

  /// The quantity the round is asking about.
  final Carried asked;
  final String why;
  final String source;

  /// Read off the jump itself rather than declared, so a change to the
  /// numbers can never leave the answer key behind.
  Crossing get answer {
    final before = asked.valueOn(surge, true);
    final after = asked.valueOn(surge, false);
    if (before == 0 && after == 0) return Crossing.same;
    if ((after - before).abs() / before.abs() < 0.01) return Crossing.same;
    return after > before ? Crossing.up : Crossing.down;
  }
}

const wayRounds = <WayRound>[
  WayRound(
    subject: 'the lesson\'s own jump',
    surge: Surge(beforeDepth: 0.4, froudeBefore: 3),
    asked: Carried.depth,
    why:
        'Larger, and this is what makes a jump a jump: 0.4 meters arrives '
        'and 1.51 leaves. The deeper side is always the downstream side, '
        'because a jump only ever runs from supercritical to subcritical. '
        'Water does not spontaneously speed up and get shallower in a step; '
        'that would take energy from somewhere.',
    source: 'wr-ecf-q3',
  ),
  WayRound(
    subject: 'the water itself',
    surge: Surge(beforeDepth: 0.4, froudeBefore: 3),
    asked: Carried.discharge,
    why:
        'Unchanged. Nothing is added and nothing leaves, so the discharge is '
        'the same on both sides, which is exactly why the deeper side has to '
        'be the slower one. Continuity is the quietest equation in the '
        'lesson and it is doing most of the work.',
    source: 'wr-ecf-q3',
  ),
  WayRound(
    subject: 'how fast it is going',
    surge: Surge(beforeDepth: 0.4, froudeBefore: 3),
    asked: Carried.speed,
    why:
        'Smaller, from 5.94 meters a second down to 1.57. The same water '
        'through a deeper section has to slow down in proportion, and it is '
        'that loss of speed the jump is usually built to achieve: the sheet '
        'coming off a spillway is fast enough to scour a riverbed, and a '
        'stilling basin exists to take that away before the water is let go.',
    source: 'wr-ecf-q3',
  ),
  WayRound(
    subject: 'the energy in the flow',
    surge: Surge(beforeDepth: 0.5, froudeBefore: 4),
    asked: Carried.energy,
    why:
        'Smaller. A jump is violent and turbulent and it throws energy away '
        'as heat and noise, which is the whole point of building one. This '
        'is also why the conjugate depths cannot be found from an energy '
        'balance: the energy on the two sides is not equal, and assuming it '
        'is gives the wrong depth every time.',
    source: 'wr-ecf-q3',
  ),
  WayRound(
    subject: 'the quantity that actually balances',
    surge: Surge(beforeDepth: 0.5, froudeBefore: 4),
    asked: Carried.momentum,
    why:
        'Unchanged. The momentum function is what a jump conserves, and '
        'setting it equal on the two sides is where the conjugate depth '
        'formula comes from. Energy in, momentum across: that is the pairing '
        'to keep straight, and it is the reverse of the one that works for a '
        'smooth transition, where energy is conserved and the momentum is '
        'not.',
    source: 'wr-ecf-q3',
  ),
  WayRound(
    subject: 'the Froude number',
    surge: Surge(beforeDepth: 0.3, froudeBefore: 2.5),
    asked: Carried.froude,
    why:
        'Smaller, and it always crosses one on the way: 2.5 arrives and 0.46 '
        'leaves. That crossing is the definition of a jump rather than a '
        'consequence of it. Supercritical in, subcritical out, and if a '
        'problem hands you a Froude number below one on the upstream side, '
        'there is no jump to compute.',
    source: 'wr-ecf-q2',
  ),
];

class _WhatSurvivesTheJumpGameState extends State<WhatSurvivesTheJumpGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-survives-the-jump',
    chapterId: 'water-resources',
    total: wayRounds.length,
    sourceProblemIdOf: (round) => wayRounds[round].source,
  )..addListener(_onSession);

  Crossing? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WayRound get _round => wayRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Survives the Jump',
        closing:
            'Across a hydraulic jump the discharge and the momentum function '
            'come through unchanged, the depth goes up, and the velocity, '
            'the energy and the Froude number all come down. Energy is lost '
            'on purpose, which is why a jump is built at the foot of a '
            'spillway, and why the conjugate depths have to be found from '
            'momentum rather than from energy.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: hydraulicJumpBrief,
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
            'ACROSS THE JUMP, WHAT HAPPENS TO IT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            'Water arrives fast and shallow on the left and leaves slow and '
            'deep on the right. What becomes of ${r.asked.plain}?',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: JumpPainter(
                    surge: r.surge,
                    asked: r.asked,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$y_2 = \dfrac{y_1}{2}\left(-1 + \sqrt{1 + 8Fr_1^2}\right)$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Crossing.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Crossing.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT DOES' : 'NOT QUITE',
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
