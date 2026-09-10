import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'friction_figures.dart';
import 'lesson_brief.dart';

/// Harder or Easier — the third item for `friction`.
///
/// The lesson's hardest problem turns on one thing nobody sees the first time:
/// a horizontal push on a ramp does two jobs at once. Part of it runs up the
/// slope and helps, and part of it presses the block into the slope and makes
/// the friction it has to beat bigger. Miss the second job and the answer
/// comes out a quarter light.
///
/// So nothing is calculated here. Something about the arrangement is changed,
/// both versions are drawn side by side, and the answer is whether the force
/// needed to start it sliding goes up, goes down, or does not move. One round
/// changes only how the block is lying, which changes nothing at all, because
/// friction has never cared how much of the block is touching the floor.
class HarderOrEasierGame extends StatefulWidget {
  const HarderOrEasierGame({super.key});

  @override
  State<HarderOrEasierGame> createState() => _HarderOrEasierGameState();
}

/// Which way the force needed to start it moving went.
enum Shift { harder, same, easier }

@immutable
class ChangeRound {
  const ChangeRound({
    required this.subject,
    required this.change,
    required this.before,
    required this.after,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What was done to it, in the round's own words.
  final String change;

  final Rig before;
  final Rig after;
  final String why;
  final String source;

  /// Both halves of a comparison are drawn to the SAME scale, set by whichever
  /// of them is steeper. Let each stretch to fill its own box and the steeper
  /// ramp comes out smaller, which hides the very thing being asked about.
  double get frameDeg =>
      before.rampDeg > after.rampDeg ? before.rampDeg : after.rampDeg;

  /// Worked out by putting the two arrangements through the same equilibrium
  /// and comparing, never declared beside the round.
  Shift get answer {
    final was = before.pushToSlide;
    final now = after.pushToSlide;
    if ((now - was).abs() < was * 0.005) return Shift.same;
    return now > was ? Shift.harder : Shift.easier;
  }
}

const changeRounds = <ChangeRound>[
  ChangeRound(
    subject: 'a second crate on top',
    change: 'Another identical crate is stacked on the first one.',
    before: Rig(weight: 500, mu: 0.40),
    after: Rig(weight: 1000, mu: 0.40),
    why:
        'Harder, and exactly twice as hard. Doubling the weight doubles what '
        'the floor is pressed with, and the ceiling on friction goes up in '
        'step with it. This is the one everybody gets, and it is worth being '
        'sure of before the rounds where the weight does not change.',
    source: 'stat-fri-q1',
  ),
  ChangeRound(
    subject: 'the same push, aimed downward',
    change:
        'Instead of pushing level, they push at a downward slant, twenty '
        'degrees into the floor.',
    before: Rig(weight: 500, mu: 0.40),
    after: Rig(weight: 500, mu: 0.40, pushDeg: -20),
    why:
        'Harder. Slanting the push down means only part of it is doing the '
        'sliding, and the rest is pressing the crate into the floor and '
        'raising the very friction it has to beat. Pushing a lawnmower is '
        'this round: the handle angle is working against you.',
    source: 'stat-fri-q3',
  ),
  ChangeRound(
    subject: 'the same push, aimed upward',
    change:
        'Now they take a rope and pull at an upward slant instead, twenty '
        'degrees off the floor.',
    before: Rig(weight: 500, mu: 0.40),
    after: Rig(weight: 500, mu: 0.40, pushDeg: 20),
    why:
        'Easier. Pulling upward takes some of the crate weight off the floor, '
        'the normal force drops, and the friction ceiling drops with it. This '
        'is why a hand truck is tilted back and why you pull a heavy case '
        'rather than shove it.',
    source: 'stat-fri-q3',
  ),
  ChangeRound(
    subject: 'the same crate, lying on its side',
    change:
        'The crate is tipped over and laid on its broad face, so far more of '
        'it is touching the floor. Same crate, same floor.',
    before: Rig(weight: 500, mu: 0.40),
    after: Rig(weight: 500, mu: 0.40, wide: true),
    why:
        'No difference at all. Nothing in friction reads how much of the block '
        'is touching: spreading the same weight over more floor lowers the '
        'pressure by exactly as much as it adds area. Wide tires are for wear '
        'and heat, not for grip on a rigid surface.',
    source: 'stat-fri-q1',
  ),
  ChangeRound(
    subject: 'pushing along the ramp instead of level',
    change:
        'The block on the ramp was being pushed horizontally. Now it is pushed '
        'straight up the slope instead, along the surface.',
    before: Rig(weight: 800, mu: 0.50, rampDeg: 25, pushDeg: -25),
    after: Rig(weight: 800, mu: 0.50, rampDeg: 25),
    why:
        'Easier, and by a lot. A horizontal push on a slope is partly aimed '
        'into the surface, so it was quietly adding to the normal force and '
        'paying for the extra friction all along. Push along the ramp and none '
        'of it is wasted. This is the lesson problem, inside out.',
    source: 'stat-fri-q3',
  ),
  ChangeRound(
    subject: 'a steeper ramp under the same push',
    change:
        'The ramp is jacked from twenty five degrees up to thirty five. The '
        'push stays horizontal.',
    before: Rig(weight: 800, mu: 0.50, rampDeg: 25, pushDeg: -25),
    after: Rig(weight: 800, mu: 0.50, rampDeg: 35, pushDeg: -35),
    why:
        'Harder, and much more than the ten degrees suggests. More of the '
        'weight now runs down the slope, and the horizontal push is aimed even '
        'further into the surface than before, so both terms move the wrong '
        'way at once. Steepening a ramp punishes a level push twice.',
    source: 'stat-fri-q3',
  ),
];

class _HarderOrEasierGameState extends State<HarderOrEasierGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'harder-or-easier',
    chapterId: 'statics',
    total: changeRounds.length,
    sourceProblemIdOf: (round) => changeRounds[round].source,
  )..addListener(_onSession);

  Shift? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ChangeRound get _round => changeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Harder or Easier',
        closing:
            'Anything that presses the block harder into the surface raises '
            'the friction it has to beat, and a slanted push does that to '
            'itself. Ask two questions of every force: how much of it slides '
            'the thing, and how much of it holds the thing down. How much of '
            'the block is touching is never one of them.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: normalForceBrief,
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
            'WHAT HAPPENS TO THE PUSH NEEDED',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Panel(
                  rig: r.before,
                  frameDeg: r.frameDeg,
                  caption: 'as it was',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Panel(
                  rig: r.after,
                  frameDeg: r.frameDeg,
                  caption: 'after the change',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final option in Shift.values) ...[
                if (option != Shift.values.first) const SizedBox(width: 8),
                Expanded(
                  child: _ShiftButton(
                    key: ValueKey('shift-${option.name}'),
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
              title: _session.correct! ? 'THAT IS THE WAY IT MOVES' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.rig,
    required this.frameDeg,
    required this.caption,
  });

  final Rig rig;
  final double frameDeg;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: EngineeringGrid(
              minor: 18,
              major: 90,
              child: CustomPaint(
                painter: BlockPainter(
                  rig: rig,
                  showPush: true,
                  frameDeg: frameDeg,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(caption, style: AppTheme.mono(size: 10.5, color: AppColors.ink3)),
      ],
    );
  }
}

class _ShiftButton extends StatelessWidget {
  const _ShiftButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Shift option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Shift.harder: 'Harder',
    Shift.same: 'No change',
    Shift.easier: 'Easier',
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
          height: 82,
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
                width: 30,
                height: 32,
                child: CustomPaint(painter: _ShiftGlyph(option, ink)),
              ),
              const SizedBox(height: 6),
              Text(
                _titles[option]!,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftGlyph extends CustomPainter {
  const _ShiftGlyph(this.option, this.colour);

  final Shift option;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;

    if (option == Shift.same) {
      canvas.drawLine(Offset(x - 9, size.height / 2 - 4),
          Offset(x + 9, size.height / 2 - 4), paint);
      canvas.drawLine(Offset(x - 9, size.height / 2 + 4),
          Offset(x + 9, size.height / 2 + 4), paint);
      return;
    }

    final up = option == Shift.harder;
    final tip = Offset(x, up ? 5 : size.height - 5);
    final tail = Offset(x, up ? size.height - 5 : 5);
    canvas.drawLine(tail, tip, paint);
    final back = up ? 1.0 : -1.0;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - 5.5, tip.dy + back * 8)
        ..lineTo(tip.dx + 5.5, tip.dy + back * 8)
        ..close(),
      Paint()..color = colour,
    );
  }

  @override
  bool shouldRepaint(_ShiftGlyph old) =>
      old.option != option || old.colour != colour;
}
