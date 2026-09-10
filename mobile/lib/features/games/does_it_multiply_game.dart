import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'frame_figures.dart';
import 'lesson_brief.dart';

/// Does It Multiply — the second item for `frames-machines`.
///
/// The lesson's lever problem has one named trap and it is dividing by the arm
/// ratio instead of multiplying. That is not an arithmetic slip, it is not
/// knowing which arm belongs on top, and no amount of practice at the
/// multiplication fixes it.
///
/// So the numbers are gone. The lever is drawn with both arms measured under
/// it, and the answer is whether this machine gives you more force than you
/// put in, less, or the same. Half these rounds are everyday tools that hand
/// back LESS force than you give them, on purpose, because what they are
/// really buying is reach and speed.
class DoesItMultiplyGame extends StatefulWidget {
  const DoesItMultiplyGame({super.key});

  @override
  State<DoesItMultiplyGame> createState() => _DoesItMultiplyGameState();
}

@immutable
class LeverRound {
  const LeverRound({
    required this.subject,
    required this.setting,
    required this.lever,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Lever lever;
  final String why;
  final String source;

  /// Worked out from the two arms, never declared beside the round.
  Pull get answer => lever.pull;
}

const leverRounds = <LeverRound>[
  LeverRound(
    subject: 'a crowbar under a crate',
    setting:
        'The bar is jammed under the crate with a block right beside it, and '
        'you push down on the far end.',
    lever: Lever(pivotAt: 0.15, effortAt: 1.0, loadAt: 0.0),
    why:
        'It multiplies, and by a lot. Your arm is the long one and the load '
        'arm is the stub between the block and the crate, so the force comes '
        'out scaled by that ratio. Moving the block closer to the crate makes '
        'it stronger still, which is the whole reason you shuffle it in before '
        'leaning on the bar.',
    source: 'stat-fm-q2',
  ),
  LeverRound(
    subject: 'a fishing rod',
    setting:
        'Your lower hand holds the butt still and your upper hand is only a '
        'little way up the rod. The fish is out at the tip.',
    lever: Lever(pivotAt: 0.85, effortAt: 1.0, loadAt: 0.0),
    why:
        'It divides. Your arm here is the short one, so you have to pull far '
        'harder than the fish is pulling. Nobody designs a rod for force: what '
        'that ratio buys, running the other way, is that a small movement of '
        'your hand sweeps the tip a long way. Force and distance trade, always.',
    source: 'stat-fm-q2',
  ),
  LeverRound(
    subject: 'a loaded wheelbarrow',
    setting:
        'The wheel is the pivot, the load sits well forward in the barrow, and '
        'you lift at the handles.',
    lever: Lever(pivotAt: 0.0, effortAt: 1.0, loadAt: 0.32),
    why:
        'It multiplies. Both the load and your hands are on the same side of '
        'the pivot here, so you lift rather than push down, and it works just '
        'as well: your arm is still the longer one. Slide the load back toward '
        'the handles and the barrow gets heavier to lift, which anyone who has '
        'packed one badly already knows.',
    source: 'stat-fm-q2',
  ),
  LeverRound(
    subject: 'your own forearm',
    setting:
        'The elbow is the pivot. The biceps pulls on the bone barely a couple '
        'of centimeters from it, and whatever you are holding is out at your '
        'hand.',
    lever: Lever(pivotAt: 0.0, effortAt: 0.14, loadAt: 1.0),
    why:
        'It divides, and severely. Your biceps has to pull many times harder '
        'than the weight in your hand, which is why a modest dumbbell is such '
        'hard work. The body traded force away deliberately: a tiny muscle '
        'contraction throws your hand a long way, fast.',
    source: 'stat-fm-q2',
  ),
  LeverRound(
    subject: 'two children on a seesaw',
    setting: 'The plank is pivoted exactly at its middle.',
    lever: Lever(pivotAt: 0.5, effortAt: 1.0, loadAt: 0.0),
    why:
        'Neither. Equal arms, so the ratio is one and the force comes out the '
        'same as it went in. This is still a machine and still worth having, '
        'because it reverses the direction, but it is not buying you any force '
        'and a heavier child still wins.',
    source: 'stat-fm-q2',
  ),
  LeverRound(
    subject: 'an oar in its lock',
    setting:
        'The oarlock holds the oar at the side of the boat. Your hands are '
        'close in on the handle and the blade is right out in the water.',
    lever: Lever(pivotAt: 0.22, effortAt: 0.0, loadAt: 1.0),
    why:
        'It divides. Your hands sit close to the lock and the blade is far '
        'from it, so you pull harder than the water pushes back. What you get '
        'for it is the blade sweeping a long arc through the water for a short '
        'movement of your hands, and that is what moves a boat.',
    source: 'stat-fm-q2',
  ),
];

class _DoesItMultiplyGameState extends State<DoesItMultiplyGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-it-multiply',
    chapterId: 'statics',
    total: leverRounds.length,
    sourceProblemIdOf: (round) => leverRounds[round].source,
  )..addListener(_onSession);

  Pull? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  LeverRound get _round => leverRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does It Multiply',
        closing:
            'Moments about the pivot, and the force out is the force in times '
            'YOUR arm over ITS arm. Long arm on top and the machine gives you '
            'more force than you put in. Short arm on top and it gives you '
            'less, and buys you speed and reach instead. Look at which arm is '
            'longer before you touch a calculator.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: leverBrief,
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
            'WHAT DOES IT DO TO YOUR FORCE',
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
              height: 230,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: LeverPainter(lever: r.lever),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Pull.values) ...[
            _PullButton(
              key: ValueKey('pull-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Pull.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT DOES' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _PullButton extends StatelessWidget {
  const _PullButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Pull option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Pull.multiplies: 'More force than you put in',
    Pull.divides: 'Less force than you put in',
    Pull.neither: 'The same force, turned around',
  };

  static const _notes = {
    Pull.multiplies: 'your arm is the longer one',
    Pull.divides: 'your arm is the shorter one, and you buy reach',
    Pull.neither: 'the two arms are the same',
  };

  /// A lever with the pivot where this answer would put it.
  static const _shape = {
    Pull.multiplies: Lever(pivotAt: 0.22, effortAt: 1.0, loadAt: 0.0),
    Pull.divides: Lever(pivotAt: 0.78, effortAt: 1.0, loadAt: 0.0),
    Pull.neither: Lever(pivotAt: 0.5, effortAt: 1.0, loadAt: 0.0),
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
          height: 64,
          padding: const EdgeInsets.only(left: 6, right: 14),
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
                width: 62,
                height: 34,
                child: CustomPaint(
                  painter: LeverPainter(lever: _shape[option]!, plain: true),
                ),
              ),
              const SizedBox(width: 8),
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
