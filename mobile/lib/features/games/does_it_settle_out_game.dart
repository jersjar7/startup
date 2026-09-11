import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'clarifier_figures.dart';

/// Does It Settle Out — the first item for `water-treatment`.
///
/// The overflow rate is Q over A and its units are a velocity, which is the
/// whole of what makes it useful: it is the speed the water rises through
/// the tank, and anything falling faster than that reaches the floor while
/// anything slower is carried over the weir. Because it is Q over the
/// SURFACE area, the depth of the tank does not appear in it. A deeper tank
/// holds the water longer without capturing one extra particle, and a wider
/// one captures more without holding the water any longer at all.
class DoesItSettleOutGame extends StatefulWidget {
  const DoesItSettleOutGame({super.key});

  @override
  State<DoesItSettleOutGame> createState() => _DoesItSettleOutGameState();
}

/// What becomes of the particle.
enum Settles { caught, carried }

extension SettlesWords on Settles {
  String get plain => switch (this) {
        Settles.caught => 'It reaches the floor and is removed',
        Settles.carried => 'It is carried out over the weir',
      };
}

@immutable
class SettleRound {
  const SettleRound({
    required this.subject,
    required this.setting,
    required this.clarifier,
    required this.falling,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Clarifier clarifier;

  /// The particle's settling velocity in feet an hour.
  final double falling;
  final String why;
  final String source;

  /// Read off the two arrows, never declared.
  Settles get answer =>
      falling > clarifier.riseFeetPerHour ? Settles.caught : Settles.carried;
}

const captureRounds = <SettleRound>[
  SettleRound(
    subject: 'the lesson\'s own clarifier',
    setting:
        'Two million gallons a day into a tank 60 feet across and 10 feet '
        'deep. The grit falls at 6 feet an hour.',
    clarifier: Clarifier(flowGpd: 2000000, diameter: 60, depth: 10),
    falling: 6,
    why:
        'It is caught. The overflow rate works out at 708 gallons a day per '
        'square foot, which is water rising at about 3.9 feet an hour, and '
        'grit falling at 6 gets to the floor before the water carries it to '
        'the weir. Read the overflow rate as a speed and the question answers '
        'itself.',
    source: 'wr-wt-q1',
  ),
  SettleRound(
    subject: 'a lighter particle in the same tank',
    setting:
        'The same tank and the same flow, but this floc settles at only 2 '
        'feet an hour.',
    clarifier: Clarifier(flowGpd: 2000000, diameter: 60, depth: 10),
    falling: 2,
    why:
        'Carried out. Falling at 2 against water rising at 3.9, it never '
        'reaches the floor: the tank is passing it. Everything the clarifier '
        'removes and everything it fails to remove is decided by this one '
        'comparison, which is why the overflow rate is the number a settling '
        'tank is designed on.',
    source: 'wr-wt-q1',
  ),
  SettleRound(
    subject: 'the same tank made deeper',
    setting:
        'The same 60 foot tank and the same flow, but it is built 16 feet '
        'deep instead of 10. The same 2 foot an hour floc.',
    clarifier: Clarifier(flowGpd: 2000000, diameter: 60, depth: 16),
    falling: 2,
    why:
        'Still carried out, and this is the round worth remembering. Depth '
        'does not appear in Q over A: the overflow rate is unchanged at 708, '
        'the water still rises at 3.9 feet an hour, and the same floc still '
        'goes over the weir. What the extra depth bought was detention TIME, '
        'which matters for other reasons and not for this one.',
    source: 'wr-wt-q1',
  ),
  SettleRound(
    subject: 'the same tank made wider',
    setting:
        'The same flow and the same 2 foot an hour floc, but the tank is 90 '
        'feet across rather than 60.',
    clarifier: Clarifier(flowGpd: 2000000, diameter: 90, depth: 10),
    falling: 2,
    why:
        'Caught now. Half again on the diameter is more than twice the '
        'surface, so the overflow rate falls to 314 and the water rises at '
        'only 1.7 feet an hour, slower than the floc falls. Surface area is '
        'what a settling tank is buying, and going wider is the only way to '
        'buy it.',
    source: 'wr-wt-q1',
  ),
  SettleRound(
    subject: 'a wet weather flow',
    setting:
        'The 60 foot tank again, but the storm flow has pushed the plant to '
        '4 million gallons a day. The grit still falls at 6 feet an hour.',
    clarifier: Clarifier(flowGpd: 4000000, diameter: 60, depth: 10),
    falling: 6,
    why:
        'Carried out, and the tank has stopped doing its job. Doubling the '
        'flow doubles the overflow rate to 1,415 and the rise to 7.9 feet an '
        'hour, which is faster than even the grit falls. This is what washout '
        'looks like in a storm, and it is why plants have flow equalization '
        'or a second tank to bring in.',
    source: 'wr-wt-q1',
  ),
  SettleRound(
    subject: 'a small secondary clarifier',
    setting:
        'Half a million gallons a day into a 40 foot tank. The biological '
        'floc settles at 1.5 feet an hour.',
    clarifier: Clarifier(flowGpd: 500000, diameter: 40, depth: 12),
    falling: 1.5,
    why:
        'Caught, but not by much: 398 gallons a day per square foot is water '
        'rising at 2.2 feet an hour against a floc that falls... and there is '
        'the trap. Read the arrows: the floc at 1.5 is SLOWER than the rise '
        'at 2.2, so it goes over. Secondary clarifiers are sized at 400 to '
        '800 gallons a day per square foot precisely because biological floc '
        'settles so slowly.',
    source: 'wr-wt-q1',
  ),
];

class _DoesItSettleOutGameState extends State<DoesItSettleOutGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-it-settle-out',
    chapterId: 'water-resources',
    total: captureRounds.length,
    sourceProblemIdOf: (round) => captureRounds[round].source,
  )..addListener(_onSession);

  Settles? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SettleRound get _round => captureRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does It Settle Out',
        closing:
            'The overflow rate is a velocity: the speed the water rises '
            'through the tank. A particle falling faster than it reaches the '
            'floor, and one falling slower goes over the weir. It is Q over '
            'the SURFACE area, so the depth of the tank is nowhere in it: '
            'deeper buys detention time and captures nothing extra, while '
            'wider buys capture.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: overflowBrief,
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
            'CAUGHT, OR OVER THE WEIR',
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
          Container(
            height: 240,
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
                  painter: ClarifierPainter(
                    clarifier: r.clarifier,
                    settlingFeetPerHour: r.falling,
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
              r'$v_o = \dfrac{Q}{A_{surface}}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Settles.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Settles.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT BECOMES OF IT' : 'THE OTHER WAY',
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
