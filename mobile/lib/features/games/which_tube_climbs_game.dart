import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'fluid_figures.dart';
import 'lesson_brief.dart';

/// Which Tube Climbs Higher — the third item for `fluid-properties`.
///
/// Capillary rise is a formula with a diameter underneath it and a contact
/// angle inside a cosine, and the lesson's hardest problem is lost in both:
/// its wrong answers are the factor dropped, halved, or the radius used in
/// place of the diameter. The arithmetic belongs on paper. What belongs here
/// is the shape: a narrower tube climbs higher, a heavier liquid climbs less,
/// and a liquid that does not wet the glass goes DOWN instead.
class WhichTubeClimbsGame extends StatefulWidget {
  const WhichTubeClimbsGame({super.key});

  @override
  State<WhichTubeClimbsGame> createState() => _WhichTubeClimbsGameState();
}

/// Which tube stands highest, or neither.
enum Climbs { left, right, level }

extension ClimbsWords on Climbs {
  String get plain => switch (this) {
        Climbs.left => 'The left tube',
        Climbs.right => 'The right tube',
        Climbs.level => 'Neither: they stand at the same height',
      };
}

@immutable
class TubeRound {
  const TubeRound({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Straw left;
  final Straw right;
  final String why;
  final String source;

  /// Worked out from the two tubes, never declared.
  Climbs get answer {
    final gap = (left.rise - right.rise).abs() /
        (left.rise.abs() > right.rise.abs()
            ? left.rise.abs()
            : right.rise.abs());
    if (gap < 0.02) return Climbs.level;
    return left.rise > right.rise ? Climbs.left : Climbs.right;
  }

  double get spread => (left.rise - right.rise).abs();

  List<Straw> get both => [left, right];
}

const tubeRounds = <TubeRound>[
  TubeRound(
    subject: 'two bores in the same water',
    setting:
        'Two glass tubes standing in the same dish of water. One has twice '
        'the bore of the other.',
    left: Straw(millimeters: 1.5),
    right: Straw(millimeters: 3),
    why:
        'The narrow one, and by exactly two, because the diameter is '
        'underneath: half the bore is twice the climb. The reason is worth '
        'holding onto. The surface tension pulls around the rim, which grows '
        'with the diameter, and it lifts the column, whose weight grows with '
        'the diameter SQUARED. Narrow wins.',
    source: 'fm-fp-q3',
  ),
  TubeRound(
    subject: 'a hair of a tube',
    setting: 'One tube is four times the bore of the other, in water again.',
    left: Straw(millimeters: 4),
    right: Straw(millimeters: 1),
    why:
        'The narrow one again, four times as high. This is why capillary '
        'action matters in soil and in concrete and not in a pipe: the effect '
        'lives in bores measured in fractions of a millimeter, and dies away '
        'to nothing as soon as the opening is anything a person would call a '
        'tube.',
    source: 'fm-fp-q3',
  ),
  TubeRound(
    subject: 'the same bore, two liquids',
    setting:
        'Two tubes of the same bore, one in water and one in an oil with '
        'about half the surface tension and a slightly lighter body.',
    left: Straw(millimeters: 2),
    right: Straw(
      millimeters: 2,
      sigma: 0.03,
      gamma: 8500,
      liquid: 'oil',
    ),
    why:
        'The water. Surface tension is on top of the formula, so halving it '
        'roughly halves the climb, and the oil being a little lighter only '
        'wins a small part of that back. Both liquids and both tubes matter: '
        'the bore is not the only thing in it.',
    source: 'fm-fp-q3',
  ),
  TubeRound(
    subject: 'two tubes the same',
    setting:
        'Two tubes of the same bore, standing in the same dish of water.',
    left: Straw(millimeters: 2),
    right: Straw(millimeters: 2),
    why:
        'Neither: identical tubes in identical water climb to identical '
        'heights. Nothing else in the drawing has any say. How much liquid is '
        'in the dish does not come into it, and neither does how long the '
        'tube is, as long as it is longer than the climb.',
    source: 'fm-fp-q3',
  ),
  TubeRound(
    subject: 'a liquid that will not wet the glass',
    setting:
        'The left tube is in water, which wets glass with a contact angle of '
        'zero. The right one is in mercury, which does not wet it at all: '
        'its contact angle is about 130 degrees.',
    left: Straw(millimeters: 2),
    right: Straw(
      millimeters: 2,
      sigma: 0.48,
      angle: 130,
      gamma: 133000,
      liquid: 'mercury',
    ),
    why:
        'The water, and the mercury is not merely lower: it is pushed DOWN '
        'below the dish. The cosine does that. Past ninety degrees the cosine '
        'turns negative, so the formula gives a negative rise, which is a '
        'depression. A mercury barometer reads slightly low for exactly this '
        'reason.',
    source: 'fm-fp-q3',
  ),
  TubeRound(
    subject: 'narrow oil against wide water',
    setting:
        'A one millimeter tube in the oil, against a three millimeter tube in '
        'water.',
    left: Straw(
      millimeters: 1,
      sigma: 0.03,
      gamma: 8500,
      liquid: 'oil',
    ),
    right: Straw(millimeters: 3),
    why:
        'The narrow oil tube, even though oil climbs less readily than water. '
        'Three times the bore is a third of the climb, and that beats the '
        'oil\'s weaker pull. When two things in a formula pull opposite ways, '
        'the only question is which moved further, and here it is the bore by '
        'a comfortable margin.',
    source: 'fm-fp-q3',
  ),
];

class _WhichTubeClimbsGameState extends State<WhichTubeClimbsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-tube-climbs',
    chapterId: 'fluid-mechanics',
    total: tubeRounds.length,
    sourceProblemIdOf: (round) => tubeRounds[round].source,
  )..addListener(_onSession);

  Climbs? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TubeRound get _round => tubeRounds[_session.round];

  int? _index(Climbs? which) => switch (which) {
        Climbs.left => 0,
        Climbs.right => 1,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Tube Climbs Higher',
        closing:
            'The bore is underneath, so a narrower tube climbs higher, in '
            'direct proportion: half the bore is twice the rise. Surface '
            'tension is on top and the liquid\'s weight is underneath, so a '
            'heavier or less sticky liquid climbs less. And a liquid that '
            'does not wet the glass has a contact angle past ninety, which '
            'turns the cosine negative and pushes it down the tube instead.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: capillaryBrief,
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
            'TAP THE TUBE THAT CLIMBS HIGHER',
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
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 240);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = CapillaryPainter.at(
                            size, r.both, details.localPosition);
                        if (hit == null) return;
                        setState(() =>
                            _picked = hit == 0 ? Climbs.left : Climbs.right);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: CapillaryPainter(
                        straws: r.both,
                        picked: _index(_picked),
                        answer: answered ? _index(r.answer) : null,
                        locked: answered,
                        showLevels: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            answered
                ? 'the columns are drawn to one scale'
                : 'bores drawn far wider than they are. the liquid is drawn '
                    'once you answer',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$h = \dfrac{4\sigma \cos\beta}{\gamma d}$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Climbs.level.plain,
            selected: _picked == Climbs.level,
            locked: answered,
            isTruth: r.answer == Climbs.level,
            onTap:
                answered ? null : () => setState(() => _picked = Climbs.level),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE HIGHER ONE' : 'THE OTHER WAY',
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
