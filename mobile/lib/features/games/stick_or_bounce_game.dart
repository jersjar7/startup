import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'collision_figures.dart';
import 'lesson_brief.dart';

/// Stick or Bounce — the first item for `impulse-and-momentum`.
///
/// The lesson's own tip is that a perfectly plastic crash needs one equation
/// and anything else needs two, so the first thing to read out of a collision
/// problem is which kind it is. The word to look for is in the sentence: stuck
/// together, locked bumpers, embedded, all mean the coefficient of restitution
/// is nothing.
class StickOrBounceGame extends StatefulWidget {
  const StickOrBounceGame({super.key});

  @override
  State<StickOrBounceGame> createState() => _StickOrBounceGameState();
}

/// What kind of impact the sentence describes.
enum Impact { plastic, elastic, between }

extension ImpactWords on Impact {
  String get plain => switch (this) {
        Impact.plastic => 'They stick: e is nothing',
        Impact.elastic => 'A perfect bounce: e is one',
        Impact.between => 'Somewhere between: e is given',
      };
}

@immutable
class ImpactRound {
  const ImpactRound({
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

  /// Read off the crash rather than declared beside it.
  Impact get answer {
    if (crash.e == 0) return Impact.plastic;
    if (crash.e == 1) return Impact.elastic;
    return Impact.between;
  }

  /// How many equations that leaves you needing.
  int get equations => crash.e == 0 ? 1 : 2;
}

const impactRounds = <ImpactRound>[
  ImpactRound(
    subject: 'cars with locked bumpers',
    setting:
        'A two tonne car doing fifteen meters a second runs into a one tonne '
        'car at rest. The two lock bumpers and move off together.',
    crash: Crash(massA: 2000, massB: 1000, speedA: 15, e: 0),
    why:
        'They stick, so e is nothing and one equation does it: the momentum '
        'before equals the momentum after, with the two masses added together '
        'on the right. This is the lesson\'s own first problem. Note what you '
        'must NOT do here, which is conserve the energy: a great deal of it '
        'goes into bending the cars.',
    source: 'dyn-im-q1',
  ),
  ImpactRound(
    subject: 'a ball with a restitution given',
    setting:
        'A two kilogram ball at eight meters a second strikes an identical '
        'ball at rest. The coefficient of restitution is nought point five.',
    crash: Crash(massA: 2, massB: 2, speedA: 8, e: 0.5),
    why:
        'In between, and that takes TWO equations: momentum for the pair, and '
        'the restitution relation for the difference between the two speeds. '
        'Two unknowns need two equations, and trying to do it on momentum '
        'alone leaves you one short. This is the lesson\'s middle problem.',
    source: 'dyn-im-q2',
  ),
  ImpactRound(
    subject: 'a bullet in a block',
    setting:
        'A bullet is fired into a wooden block and stays buried in it. The '
        'block swings away with the bullet inside.',
    crash: Crash(massA: 0.02, massB: 3, speedA: 400, e: 0),
    why:
        'They stick. Embedded, buried, lodged: the words change and the '
        'physics does not. One equation, masses added, and almost all of the '
        'bullet\'s energy is gone into splintering the wood, so conserving '
        'energy here would be badly wrong.',
    source: 'dyn-im-q1',
  ),
  ImpactRound(
    subject: 'steel balls on a cradle',
    setting:
        'A hardened steel ball swings into another identical one and bounces '
        'off it with almost no loss at all.',
    crash: Crash(massA: 1, massB: 1, speedA: 3, e: 1),
    why:
        'A perfect bounce, e of one, which is the only case where the kinetic '
        'energy survives as well as the momentum. Two equations again, and '
        'with equal masses they give the famous answer: the striker stops dead '
        'and the struck one leaves at the speed the striker arrived with.',
    source: 'dyn-im-q2',
  ),
  ImpactRound(
    subject: 'railway wagons coupling',
    setting:
        'A loaded wagon rolls into a stationary one and the couplers engage, '
        'so the two roll on as a single train.',
    crash: Crash(massA: 40000, massB: 25000, speedA: 1.5, e: 0),
    why:
        'They stick. Coupling is the plainest case of e being nothing, and the '
        'size of the wagons changes nothing about the method: one equation, '
        'both masses on the right hand side. It is also why shunting is done '
        'slowly, since everything the momentum does not carry away has to be '
        'absorbed by the couplers.',
    source: 'dyn-im-q1',
  ),
  ImpactRound(
    subject: 'a dropped ball that comes back part way',
    setting:
        'A ball dropped on a concrete floor bounces back to about half the '
        'height it was let go from.',
    crash: Crash(massA: 0.2, massB: 100000, speedA: 5, e: 0.7),
    why:
        'In between. It clearly bounces, so e is not nothing, and it does not '
        'come back to where it started, so e is not one either: coming back to '
        'half the height means an e of about nought point seven, since the '
        'height goes with the square of the speed. A real impact is nearly '
        'always in this middle country.',
    source: 'dyn-im-q2',
  ),
];

class _StickOrBounceGameState extends State<StickOrBounceGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'stick-or-bounce',
    chapterId: 'dynamics',
    total: impactRounds.length,
    sourceProblemIdOf: (round) => impactRounds[round].source,
  )..addListener(_onSession);

  Impact? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ImpactRound get _round => impactRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Stick or Bounce',
        closing:
            'Stuck, locked, coupled, embedded: all of them mean e is nothing '
            'and one equation does it, with the masses added together. A '
            'perfect bounce is e of one and is the only case where the energy '
            'survives too. Anything else needs the momentum equation AND the '
            'restitution equation, because two unknown speeds need two '
            'equations.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: impactBrief,
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
            'WHAT KIND OF IMPACT IS THIS',
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
              height: answered ? 150 : 90,
              child: CustomPaint(
                painter: CrashPainter(crash: r.crash, showAfter: answered),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r"$e = \dfrac{v_2' - v_1'}{v_1 - v_2}$",
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final i in Impact.values) ...[
            _Choice(
              label: i.plain,
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            Text(
              r.equations == 1
                  ? 'one equation is enough'
                  : 'this one needs two equations',
              style: AppTheme.mono(size: 12, color: AppColors.forest),
            ),
            const SizedBox(height: 10),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE KIND' : 'A DIFFERENT KIND',
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
