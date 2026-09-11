import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'mohr_figures.dart';

/// Which Circle Is It — the second item for
/// `combined-stresses-mohrs-circle`.
///
/// The circle is built from two numbers: the center is the AVERAGE of the two
/// normal stresses and the radius combines the half difference with the shear
/// the way the sides of a right triangle combine. Neither needs a calculator
/// to picture. What the drawing shows that a formula does not is the special
/// cases: pure shear is a circle centered on the origin, equal stress both
/// ways is a single POINT with no shear on any plane, and adding shear to a
/// stress state always pushes the largest principal stress further right.
class WhichCircleIsItGame extends StatefulWidget {
  const WhichCircleIsItGame({super.key});

  @override
  State<WhichCircleIsItGame> createState() => _WhichCircleIsItGameState();
}

/// What is wrong with a candidate circle.
enum Built {
  /// Nothing: this is the circle of the element above it.
  right,

  /// Centered on sigma x rather than on the average of the two.
  centerOnX,

  /// Radius taken as the half difference, with the shear left out.
  forgotShear,

  /// Radius taken as the shear alone, with the normal stresses left out.
  shearOnly,

  /// The two normal stresses simply added, which is not how any of this
  /// works and is a named wrong answer in the lesson.
  addedUp,

  /// Centered on the shear value, which is a place nothing belongs.
  centerOnShear,

  /// Radius taken as half of what it should be.
  halfRadius,

  /// Radius taken as the normal stress itself.
  radiusFromNormal,
}

@immutable
class MadeRound {
  const MadeRound({
    required this.subject,
    required this.setting,
    required this.stress,
    required this.options,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Stress stress;

  /// The three circles on offer, in the order they are drawn.
  final List<Built> options;

  final String why;
  final String source;

  int get answer => options.indexOf(Built.right);

  /// The circle a candidate draws, worked out from the real stresses rather
  /// than written down.
  Stress circleFor(Built built) {
    switch (built) {
      case Built.right:
        return stress;
      case Built.centerOnX:
        // Same radius, but sitting at sigma x instead of the average.
        return Stress(
          x: stress.x + stress.radius,
          y: stress.x - stress.radius,
          xy: 0,
        );
      case Built.forgotShear:
        return Stress(x: stress.x, y: stress.y, xy: 0);
      case Built.shearOnly:
        return Stress(
          x: stress.center + stress.xy.abs(),
          y: stress.center - stress.xy.abs(),
          xy: 0,
        );
      case Built.addedUp:
        final sum = stress.x + stress.y;
        return Stress(x: sum + stress.radius, y: sum - stress.radius, xy: 0);
      case Built.centerOnShear:
        final t = stress.xy.abs();
        return Stress(x: t + t, y: 0, xy: 0);
      case Built.halfRadius:
        final r = stress.radius / 2;
        return Stress(x: stress.center + r, y: stress.center - r, xy: 0);
      case Built.radiusFromNormal:
        final r = stress.x.abs();
        return Stress(x: stress.center + r, y: stress.center - r, xy: 0);
    }
  }
}

const madeRounds = <MadeRound>[
  MadeRound(
    subject: 'a bar pulled one way only',
    setting:
        'Sixty megapascals of tension along the bar, nothing across it, no '
        'shear on those faces.',
    stress: Stress(x: 60, y: 0, xy: 0),
    options: [Built.right, Built.centerOnX, Built.halfRadius],
    why:
        'The first, running from zero out to sixty with its center at thirty. '
        'Both of the numbers you were given are already on the circle, at its '
        'two ends, because a face with no shear on it IS a principal plane. '
        'And the worst shear in the bar is half the tension, out on a plane at '
        'forty five degrees, which is why a ductile bar necks down on the '
        'slant.',
    source: 'mm-csm-q1',
  ),
  MadeRound(
    subject: 'a shaft in pure torsion',
    setting:
        'No normal stress on either face, forty megapascals of shear. This is '
        'what twisting alone does to a point.',
    stress: Stress(x: 0, y: 0, xy: 40),
    options: [Built.centerOnShear, Built.right, Built.halfRadius],
    why:
        'The second, a circle centered on the ORIGIN with a radius of forty. '
        'Read what that means: the principal stresses are plus forty and minus '
        'forty, so pure shear is pure tension one way and pure compression '
        'square to it, at forty five degrees. It is why a brittle shaft in '
        'torsion cracks on a spiral rather than straight across. The first '
        'candidate has no shear at all and collapses to a point at the origin.',
    source: 'mm-csm-q2',
  ),
  MadeRound(
    subject: 'squeezed the same amount both ways',
    setting:
        'Fifty megapascals of tension on both faces and no shear at all. '
        'Something worth seeing happens here.',
    stress: Stress(x: 50, y: 50, xy: 0),
    options: [Built.addedUp, Built.right, Built.radiusFromNormal],
    why:
        'The second, which is not a circle at all: it is a single POINT at '
        'fifty. The radius is zero, so every plane through this point feels '
        'the same fifty of tension and NO shear whatever angle you cut it at. '
        'Turning the element changes nothing. The first candidate adds the two '
        'stresses into a hundred and the third gives the point a radius it '
        'has no reason to have.',
    source: 'mm-csm-q1',
  ),
  MadeRound(
    subject: 'bending and shear together',
    setting:
        'Sixty along the beam, nothing across it, forty of shear. This is the '
        'lesson\'s own second problem.',
    stress: Stress(x: 60, y: 0, xy: 40),
    options: [Built.forgotShear, Built.right, Built.addedUp],
    why:
        'The second. Its center is at thirty, the average, and its radius is '
        'fifty, a thirty and a forty combined the way a right triangle '
        'combines them. The first leaves the shear out and stops at sixty, '
        'which is the named trap: the largest principal stress is ALWAYS '
        'further out than the normal stress you started with once there is any '
        'shear. The third simply adds the numbers up.',
    source: 'mm-csm-q2',
  ),
  MadeRound(
    subject: 'tension one way, compression the other',
    setting: 'Eighty of tension one way, twenty of compression the other, no '
        'shear.',
    stress: Stress(x: 80, y: -20, xy: 0),
    options: [Built.centerOnX, Built.right, Built.shearOnly],
    why:
        'The second, from minus twenty across to eighty. Since there is no '
        'shear on these faces, the two numbers you were handed are the '
        'principal stresses already, which is the whole of the lesson\'s first '
        'problem. The circle makes that obvious: no shear means you are '
        'already standing at the ends.',
    source: 'mm-csm-q1',
  ),
  MadeRound(
    subject: 'a point held in tension both ways',
    setting:
        'A hundred and twenty one way, forty the other, thirty of shear. The '
        'lesson\'s hardest problem.',
    stress: Stress(x: 120, y: 40, xy: 30),
    options: [Built.shearOnly, Built.forgotShear, Built.right],
    why:
        'The third: center at eighty, radius fifty, so the whole circle sits '
        'well clear of zero on the tension side. That last detail is not '
        'cosmetic. A circle that never reaches the origin is the case where '
        'the worst shear at this point is NOT its radius, which is what the '
        'next item is about.',
    source: 'mm-csm-q3',
  ),
];

class _WhichCircleIsItGameState extends State<WhichCircleIsItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-circle-is-it',
    chapterId: 'mechanics-materials',
    total: madeRounds.length,
    sourceProblemIdOf: (round) => madeRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  MadeRound get _round => madeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Circle Is It',
        closing:
            'Center at the average of the two normal stresses, radius from the '
            'half difference and the shear together. Pure shear sits on the '
            'origin. Equal stress both ways is a single point with no shear '
            'anywhere. And any shear at all pushes the largest principal '
            'stress further out than the normal stress you started with.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    // One window for all three, so a circle that is bigger or further right
    // really is drawn bigger or further right.
    final window = Window.over([
      for (final option in r.options) r.circleFor(option),
    ]);

    return BoardShell(
      session: _session,
      brief: buildBrief,
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
            'TAP THE CIRCLE FOR THIS POINT',
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
              height: 128,
              child: CustomPaint(
                painter: ElementPainter(stress: r.stress),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Panel(
              stress: r.circleFor(r.options[i]),
              window: window,
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'all three on one scale, with zero marked',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE CIRCLE' : 'A DIFFERENT POINT',
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
    required this.stress,
    required this.window,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Stress stress;
  final Window window;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color tone;
    if (locked && isTruth) {
      border = AppColors.forest;
      tone = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      tone = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      tone = AppColors.ember;
    } else {
      border = AppColors.line;
      tone = AppColors.info;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 118,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: CustomPaint(
            painter: MohrPainter(
              stress: stress,
              span: window,
              tone: tone,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
