import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'axial_figures.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Does It Build Stress — the third item for
/// `axial-stress-strain-deformation`.
///
/// The lesson's hardest problem turns on one idea: a bar that is stopped from
/// growing turns the growth it was prevented from making into stress instead,
/// and how long or how thick the bar is drops out of the answer entirely. The
/// named traps are all downstream of missing that: reporting the free growth
/// as if it were a stress, and reaching for a cross-section that cancels.
///
/// So no arithmetic. A bar is drawn between its supports, warmed or cooled,
/// and the answer is whether it ends up squeezed, stretched, or carrying
/// nothing at all. Two rounds leave it a gap to grow into, which is where
/// everyone finds out whether they were reasoning or reciting.
class DoesItBuildStressGame extends StatefulWidget {
  const DoesItBuildStressGame({super.key});

  @override
  State<DoesItBuildStressGame> createState() =>
      _DoesItBuildStressGameState();
}

@immutable
class HeatRound {
  const HeatRound({
    required this.subject,
    required this.setting,
    required this.rod,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Rod rod;
  final String why;
  final String source;

  /// Worked out from how the bar is held and how far it wanted to move,
  /// never declared beside the round.
  Outcome get answer => rod.outcome;
}

const heatRounds = <HeatRound>[
  HeatRound(
    subject: 'a bar free at one end',
    setting:
        'A steel bar built into a wall at one end with nothing at the other. '
        'It is warmed by fifty degrees.',
    rod: Rod(
      length: 1000,
      stuff: Stuff.steel,
      held: Held.oneEnd,
      warmBy: 50,
    ),
    why:
        'Nothing at all. It gets about half a millimeter longer and carries no '
        'stress whatsoever, because nothing stopped it. Heat on its own never '
        'makes stress. Being PREVENTED from moving is what makes stress, and '
        'that is worth separating in your head before anything else.',
    source: 'mm-asd-q3',
  ),
  HeatRound(
    subject: 'the same bar between two walls',
    setting:
        'The identical steel bar, but now built into a wall at each end with '
        'no room to move. Warmed by the same fifty degrees.',
    rod: Rod(
      length: 1000,
      stuff: Stuff.steel,
      held: Held.bothEnds,
      warmBy: 50,
    ),
    why:
        'Squeezed. It wanted to grow half a millimeter and the walls would not '
        'let it, so the growth it was prevented from making turns into '
        'compression. Notice what is not in that answer: how long the bar is '
        'and how thick it is both cancel out of it.',
    source: 'mm-asd-q3',
  ),
  HeatRound(
    subject: 'the same bar, cooled instead',
    setting:
        'The same bar between the same two walls, but the temperature drops by '
        'fifty degrees instead of rising.',
    rod: Rod(
      length: 1000,
      stuff: Stuff.steel,
      held: Held.bothEnds,
      warmBy: -50,
    ),
    why:
        'Stretched. It wanted to shrink and the walls held it out to length, '
        'so it ends up in tension. Same bar, same walls, same fifty degrees, '
        'opposite sign. This is why a restrained concrete slab cracks in a '
        'cold snap and not in a heatwave.',
    source: 'mm-asd-q3',
  ),
  HeatRound(
    subject: 'a bar with room to grow into',
    setting:
        'A steel bar built in at one end with a wall a small distance from the '
        'other. Warmed by forty degrees, and the gap is wider than it wants to '
        'grow.',
    rod: Rod(
      length: 1000,
      stuff: Stuff.steel,
      held: Held.withGap,
      warmBy: 40,
      gap: 0.9,
    ),
    why:
        'Nothing at all. It grows about half a millimeter, the gap is nearly a '
        'millimeter, so it never reaches the far wall and nothing ever '
        'restrains it. This is exactly what an expansion joint is for, and why '
        'a bridge deck has one.',
    source: 'mm-asd-q3',
  ),
  HeatRound(
    subject: 'the same gap, warmed further',
    setting:
        'The identical bar and the identical gap, warmed by a hundred and '
        'twenty degrees this time.',
    rod: Rod(
      length: 1000,
      stuff: Stuff.steel,
      held: Held.withGap,
      warmBy: 120,
      gap: 0.9,
    ),
    why:
        'Squeezed. It wants to grow about one point four millimeters, closes '
        'the nine tenths of a millimeter of gap, meets the wall, and fights '
        'for the rest. Only the growth AFTER contact becomes stress, so this '
        'bar is not as badly off as one with no gap at all. The gap is doing '
        'its job, just not all of it.',
    source: 'mm-asd-q3',
  ),
  HeatRound(
    subject: 'aluminum between two walls',
    setting:
        'An aluminum bar this time, held at both ends, warmed by thirty '
        'degrees. Aluminum expands about twice as readily as steel.',
    rod: Rod(
      length: 1000,
      stuff: Stuff.aluminum,
      held: Held.bothEnds,
      warmBy: 30,
    ),
    why:
        'Squeezed. It expands twice as eagerly as steel would, though its '
        'modulus is only about a third, so the stress it builds is lower than '
        'you might expect: the two effects pull against each other. What the '
        'material is changes how much, never whether.',
    source: 'mm-asd-q3',
  ),
];

class _DoesItBuildStressGameState extends State<DoesItBuildStressGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-it-build-stress',
    chapterId: 'mechanics-materials',
    total: heatRounds.length,
    sourceProblemIdOf: (round) => heatRounds[round].source,
  )..addListener(_onSession);

  Outcome? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  HeatRound get _round => heatRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does It Build Stress',
        closing:
            'Heat does not make stress. Being stopped from moving makes '
            'stress. Warm a restrained bar and it is squeezed, cool one and it '
            'is stretched, and give it room to grow into and it may never '
            'touch at all. When it does build stress, the length and the '
            'cross-section cancel out of the answer.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: thermalBrief,
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
            'WHAT IS THE BAR LEFT CARRYING',
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
              height: 190,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: RodPainter(rod: r.rod, showOutcome: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Outcome.values) ...[
            _OutcomeButton(
              key: ValueKey('outcome-${option.name}'),
              option: option,
              selected: _picked == option,
              locked: answered,
              isTruth: option == r.answer,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Outcome.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT CARRIES' : 'SOMETHING ELSE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _OutcomeButton extends StatelessWidget {
  const _OutcomeButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Outcome option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Outcome.nothing: 'No stress at all',
    Outcome.squeezed: 'Squeezed, in compression',
    Outcome.stretched: 'Stretched, in tension',
  };

  static const _notes = {
    Outcome.nothing: 'it was free to move, or never reached the wall',
    Outcome.squeezed: 'it wanted to grow and was not allowed to',
    Outcome.stretched: 'it wanted to shrink and was held out',
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
          height: 58,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
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
      ),
    );
  }
}
