import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'alignment_figures.dart';

/// Which Curve Is Sharper — the second item for `horizontal-curves`.
///
/// A curve gets described two ways and they run in opposite directions. The
/// radius is a length, and a bigger one is a gentler curve. The degree of
/// curve is an angle, the one a hundred feet of arc subtends, and a bigger
/// one is a SHARPER curve. Their product is always about 5,730, so knowing
/// either one gives the other, and the lesson asks for that relationship by
/// heart. What it is worth having by heart is the direction: the two numbers
/// move opposite ways.
class WhichCurveIsSharperGame extends StatefulWidget {
  const WhichCurveIsSharperGame({super.key});

  @override
  State<WhichCurveIsSharperGame> createState() =>
      _WhichCurveIsSharperGameState();
}

/// Which of the two bends is the tighter one.
enum Sharper { left, right, same }

extension SharperWords on Sharper {
  String get plain => switch (this) {
        Sharper.left => 'Curve A',
        Sharper.right => 'Curve B',
        Sharper.same => 'Neither: the same curve',
      };
}

@immutable
class SharpRound {
  const SharpRound({
    required this.subject,
    required this.setting,
    required this.left,
    required this.right,
    required this.leftLabel,
    required this.rightLabel,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Bend2 left;
  final Bend2 right;

  /// How each curve is described on its own drawing: some jobs quote the
  /// radius and some quote the degree of curve.
  final String leftLabel;
  final String rightLabel;
  final String why;
  final String source;

  /// The outer curve is the one with the bigger radius, and the drawing
  /// tucks the other inside it.
  bool get leftIsWider => left.radius >= right.radius;

  Bend2 get wider => leftIsWider ? left : right;

  Bend2 get tighter => leftIsWider ? right : left;

  /// The names in the order the drawing puts them: wider first.
  (String, String) get namesInOrder =>
      leftIsWider ? ('A', 'B') : ('B', 'A');

  /// Worked out from the two radii, never declared. Sharper is smaller.
  Sharper get answer {
    final gap = left.radius - right.radius;
    if (gap.abs() < 5) return Sharper.same;
    return gap < 0 ? Sharper.left : Sharper.right;
  }
}

const sharpRounds = <SharpRound>[
  SharpRound(
    subject: 'two radii',
    setting: 'Both curves are quoted by their radius.',
    left: Bend2(radius: 400, turn: 60),
    right: Bend2(radius: 1200, turn: 60),
    leftLabel: 'R 400 ft',
    rightLabel: 'R 1,200 ft',
    why:
        'The left one. A radius is a length and a short one bends hard: 400 '
        'feet is a curve a truck has to slow for, and 1,200 is one most '
        'drivers would not notice taking. Same turn through the same 60 '
        'degrees in both, so the only thing separating them is how tightly '
        'they do it.',
    source: 'surv-hc-q1',
  ),
  SharpRound(
    subject: 'two degrees of curve',
    setting: 'Both are quoted the other way, by the degree of curve.',
    left: Bend2(radius: 2865, turn: 60),
    right: Bend2(radius: 716, turn: 60),
    leftLabel: 'D 2 degrees',
    rightLabel: 'D 8 degrees',
    why:
        'The right one, and this is the direction that catches people. The '
        'degree of curve is the angle a hundred feet of road turns through, '
        'so more degrees in the same hundred feet means a tighter bend. Two '
        'degrees is a radius of about 2,900 feet; eight degrees is about '
        '720.',
    source: 'surv-hc-q1',
  ),
  SharpRound(
    subject: 'one of each, and they match',
    setting:
        'The left is quoted by degree of curve and the right by radius.',
    left: Bend2(radius: 5729.58, turn: 30),
    right: Bend2(radius: 5730, turn: 30),
    leftLabel: 'D 1 degree',
    rightLabel: 'R 5,730 ft',
    why:
        'Neither: they are the same curve. A one degree curve has a radius '
        'of 5,729.58 feet, which is where the number in the formula comes '
        'from: it is the radius whose hundred foot arc turns through exactly '
        'one degree. Every other degree of curve is that number divided by '
        'the degrees.',
    source: 'surv-hc-q1',
  ),
  SharpRound(
    subject: 'the lesson\'s own curve, twice',
    setting:
        'The left is quoted by degree of curve, the right by radius.',
    left: Bend2(radius: 954.93, turn: 40),
    right: Bend2(radius: 955, turn: 40),
    leftLabel: 'D 6 degrees',
    rightLabel: 'R 955 ft',
    why:
        'Neither: the same curve again, and this is the lesson\'s own '
        'problem. Six degrees into 5,729.58 gives 954.93 feet, which rounds '
        'to the 955 beside it. Quoting a curve both ways on the same drawing '
        'is ordinary: the degree of curve suits laying it out by deflection '
        'angles and the radius suits coordinate work.',
    source: 'surv-hc-q1',
  ),
  SharpRound(
    subject: 'a four degree curve against a long radius',
    setting: 'Left by degree of curve, right by radius.',
    left: Bend2(radius: 1432, turn: 50),
    right: Bend2(radius: 2000, turn: 50),
    leftLabel: 'D 4 degrees',
    rightLabel: 'R 2,000 ft',
    why:
        'The left one. The two numbers multiply to about 5,730, so a four '
        'degree curve is a radius of roughly 1,430 feet, which is tighter '
        'than 2,000. That product is the quickest way to compare a curve '
        'quoted one way against a curve quoted the other, and it is worth '
        'more than either formula.',
    source: 'surv-hc-q1',
  ),
  SharpRound(
    subject: 'a tight one against a fairly tight one',
    setting: 'Left by radius, right by degree of curve.',
    left: Bend2(radius: 300, turn: 70),
    right: Bend2(radius: 573, turn: 70),
    leftLabel: 'R 300 ft',
    rightLabel: 'D 10 degrees',
    why:
        'The left one. Ten degrees is about 573 feet of radius, so both of '
        'these are sharp, and the 300 is sharper still. Curves this tight '
        'turn up on ramps and in mountain work, where the degree of curve '
        'gets into double figures and the superelevation and the speed limit '
        'both start to matter.',
    source: 'surv-hc-q1',
  ),
];

class _WhichCurveIsSharperGameState extends State<WhichCurveIsSharperGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-curve-is-sharper',
    chapterId: 'surveying',
    total: sharpRounds.length,
    sourceProblemIdOf: (round) => sharpRounds[round].source,
  )..addListener(_onSession);

  Sharper? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SharpRound get _round => sharpRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Curve Is Sharper',
        closing:
            'The radius is a length and the degree of curve is an angle, and '
            'they run opposite ways: a bigger radius is gentler, a bigger '
            'degree is sharper. Their product is always about 5,730, which '
            'is the radius of a one degree curve and the fastest way to '
            'compare a curve quoted one way against one quoted the other.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: degreeBrief,
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
            'WHICH ONE BENDS HARDER',
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
          // Both curves in ONE corner, between the same two tangents and to
          // one scale. Drawn apart they would be the same picture twice:
          // only the corner a curve has to fit shows how hard it bends.
          Container(
            height: 250,
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
                  painter: AlignPainter(
                    bend: r.wider,
                    other: r.tighter,
                    names: r.namesInOrder,
                    pickedCurve: _picked == null || _picked == Sharper.same
                        ? null
                        : (_picked == Sharper.left) == r.leftIsWider ? 0 : 1,
                    answerCurve: !answered || r.answer == Sharper.same
                        ? null
                        : (r.answer == Sharper.left) == r.leftIsWider ? 0 : 1,
                    locked: answered,
                    label: '${r.leftLabel} and ${r.rightLabel}',
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$D = \dfrac{5{,}729.58}{R}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Choice(
            label: Sharper.same.plain,
            selected: _picked == Sharper.same,
            locked: answered,
            isTruth: r.answer == Sharper.same,
            onTap:
                answered ? null : () => setState(() => _picked = Sharper.same),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE TIGHTER ONE' : 'THE OTHER ONE',
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
