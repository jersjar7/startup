import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'fluid_figures.dart';
import 'lesson_brief.dart';

/// Which One Drags More — the second item for `fluid-properties`.
///
/// Newton's law of viscosity has three things in it and they do not all pull
/// the same way: the oil and the speed multiply, and the film thickness
/// divides. The lesson's problem is one arithmetic line and three of its four
/// wrong answers are the thickness converted wrongly, so the number is a desk
/// job. What is worth practicing is the SHAPE: a thinner film drags harder,
/// which is the piece that surprises people, and it is why a bearing runs on
/// a film measured in thousandths.
class WhichDragsMoreGame extends StatefulWidget {
  const WhichDragsMoreGame({super.key});

  @override
  State<WhichDragsMoreGame> createState() => _WhichDragsMoreGameState();
}

/// Which plate takes more force to slide, or neither.
enum Drags { left, right, same }

extension DragsWords on Drags {
  String get plain => switch (this) {
        Drags.left => 'The left one',
        Drags.right => 'The right one',
        Drags.same => 'Neither: the same shear stress',
      };
}

@immutable
class DragRound {
  const DragRound({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Film left;
  final Film right;
  final String why;
  final String source;

  /// Worked out from the two films, never declared.
  Drags get answer {
    final gap = (left.shear - right.shear).abs() /
        (left.shear > right.shear ? left.shear : right.shear);
    if (gap < 0.01) return Drags.same;
    return left.shear > right.shear ? Drags.left : Drags.right;
  }

  double get ratio => left.shear > right.shear
      ? left.shear / right.shear
      : right.shear / left.shear;

  double get thickest =>
      left.millimeters > right.millimeters ? left.millimeters : right.millimeters;
}

const dragRounds = <DragRound>[
  DragRound(
    subject: 'the same oil, one film thinner',
    setting:
        'The same oil and the same plate speed. Only the film thickness is '
        'different.',
    left: Film(mu: 0.1, speed: 0.5, millimeters: 2),
    right: Film(mu: 0.1, speed: 0.5, millimeters: 6),
    why:
        'The thinner film, and this is the one people get backwards. The '
        'thickness is UNDERNEATH: squeezing the same speed difference into a '
        'third of the gap makes the velocity change three times as steep, so '
        'three times the shear. A bearing film is thousandths of a millimeter '
        'thick, and that is exactly why it can carry what it does.',
    source: 'fm-fp-q2',
  ),
  DragRound(
    subject: 'the same film, one plate faster',
    setting:
        'The same oil in the same two millimeter film. One plate is being '
        'dragged three times as fast.',
    left: Film(mu: 0.1, speed: 0.5, millimeters: 2),
    right: Film(mu: 0.1, speed: 1.5, millimeters: 2),
    why:
        'The faster one, in direct proportion: three times the speed is three '
        'times the shear. Speed sits on top of the fraction where thickness '
        'sits underneath, which is the whole of the formula\'s shape and all '
        'you need to answer any round of this.',
    source: 'fm-fp-q2',
  ),
  DragRound(
    subject: 'two different oils',
    setting:
        'The same speed and the same film. The right hand one is a heavier '
        'oil.',
    left: Film(mu: 0.1, speed: 0.5, millimeters: 2),
    right: Film(mu: 0.4, speed: 0.5, millimeters: 2, fluid: 'heavy oil'),
    why:
        'The heavier oil, four times over. Viscosity is the constant of '
        'proportionality between the stress and the velocity gradient, so it '
        'multiplies directly. Note that it has to be the DYNAMIC viscosity: '
        'putting a kinematic one, in meters squared a second, into this '
        'formula is the lesson\'s other named trap.',
    source: 'fm-fp-q2',
  ),
  DragRound(
    subject: 'faster, but on a thicker film',
    setting:
        'The right hand plate runs at twice the speed on three times the '
        'film.',
    left: Film(mu: 0.1, speed: 0.5, millimeters: 2),
    right: Film(mu: 0.1, speed: 1.0, millimeters: 6),
    why:
        'The left one, because the thickness wins the argument here: twice '
        'the speed over three times the gap is two thirds of the shear. The '
        'two do not cancel and the bigger number in a problem is not '
        'automatically the deciding one. Read which side of the line each '
        'thing is on.',
    source: 'fm-fp-q2',
  ),
  DragRound(
    subject: 'a tenth of everything',
    setting:
        'The right hand plate crawls at a tenth the speed, over a film a '
        'tenth as thick.',
    left: Film(mu: 0.1, speed: 0.5, millimeters: 2),
    right: Film(mu: 0.1, speed: 0.05, millimeters: 0.2),
    why:
        'Neither: exactly the same. What the fluid feels is the velocity '
        'GRADIENT, the speed divided by the gap, and dividing both by ten '
        'leaves that alone. This is why the shear in a bearing running slowly '
        'on a very thin film can match a fast plate on a thick one.',
    source: 'fm-fp-q2',
  ),
  DragRound(
    subject: 'a heavy oil on a thick film',
    setting:
        'A heavy oil in a four millimeter film against a light oil in a two '
        'millimeter one, at the same speed.',
    left: Film(mu: 0.4, speed: 0.5, millimeters: 4, fluid: 'heavy oil'),
    right: Film(mu: 0.1, speed: 0.5, millimeters: 2),
    why:
        'The left one, by two. Four times the viscosity against twice the '
        'thickness leaves a factor of two in favor of the heavy oil, even '
        'though its film is the fatter of the pair. Both numbers moved and '
        'the question is only ever which moved further.',
    source: 'fm-fp-q2',
  ),
];

class _WhichDragsMoreGameState extends State<WhichDragsMoreGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-drags-more',
    chapterId: 'fluid-mechanics',
    total: dragRounds.length,
    sourceProblemIdOf: (round) => dragRounds[round].source,
  )..addListener(_onSession);

  Drags? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DragRound get _round => dragRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Drags More',
        closing:
            'The oil and the speed multiply and the film thickness divides, '
            'so a thinner film drags harder: that is the one that reads '
            'backwards. What the fluid actually feels is the velocity '
            'gradient, the speed over the gap, which is why halving both '
            'changes nothing. And the viscosity in this formula is always the '
            'dynamic one, in pascal seconds.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: viscosityBrief,
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
            'WHICH PLATE IS HARDER TO SLIDE',
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
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Panel(
                    film: i == 0 ? r.left : r.right,
                    thickest: r.thickest,
                    selected: _picked == (i == 0 ? Drags.left : Drags.right),
                    locked: answered,
                    isTruth: r.answer == (i == 0 ? Drags.left : Drags.right),
                    onTap: answered
                        ? null
                        : () => setState(
                            () => _picked = i == 0 ? Drags.left : Drags.right),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\tau = \mu \dfrac{v}{\delta}$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Drags.same.plain,
            selected: _picked == Drags.same,
            locked: answered,
            isTruth: r.answer == Drags.same,
            onTap: answered ? null : () => setState(() => _picked = Drags.same),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER WAY',
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
    required this.film,
    required this.thickest,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Film film;
  final double thickest;
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
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 190,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: FilmPainter(film: film, thickest: thickest),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
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
