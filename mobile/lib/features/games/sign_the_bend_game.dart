import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'calculus_figures.dart';
import 'lesson_brief.dart';

/// Sign the Bend — the second item for `applications-derivatives`.
///
/// The lesson does not say an inflection point is where the second derivative
/// is zero. It says it is where the second derivative is zero AND CHANGES
/// SIGN, and the trap list calls out students who never check the second half.
/// So the answer here is not a point: it is the sign of the bend in every
/// region at once, and the flip either falls out of it or does not exist.
/// Rounds where nothing flips are the whole reason the item is shaped this way.
class SignTheBendGame extends StatefulWidget {
  const SignTheBendGame({super.key});

  @override
  State<SignTheBendGame> createState() => _SignTheBendGameState();
}

@immutable
class BendRound {
  const BendRound({
    required this.subject,
    required this.unit,
    required this.poly,
    required this.x0,
    required this.x1,
    required this.cuts,
    required this.why,
    required this.source,
  });

  final String subject;
  final String unit;
  final Poly poly;
  final double x0;
  final double x1;

  /// Where the span is divided. A divider is a place worth asking about, not a
  /// promise that anything changes there.
  final List<double> cuts;
  final String why;
  final String source;

  List<(double, double)> get regions {
    final edges = [x0, ...cuts, x1];
    return [for (var i = 0; i < edges.length - 1; i++) (edges[i], edges[i + 1])];
  }

  /// True where the curve smiles. Read off the second derivative rather than
  /// declared, so a round cannot disagree with its own curve.
  List<bool> get bendsUp => [
    for (final (a, b) in regions) poly.dd.at((a + b) / 2) > 0,
  ];

  /// The divider the bend actually flips at, if any.
  double? get inflection {
    final up = bendsUp;
    for (var i = 0; i < cuts.length; i++) {
      if (up[i] != up[i + 1]) return cuts[i];
    }
    return null;
  }
}

const bendRounds = <BendRound>[
  BendRound(
    subject: r'y(x) = x^3 - 12x^2 + 36x',
    unit: 'x, meters along the beam',
    poly: Poly([0, 36, -12, 1]),
    x0: 0,
    x1: 8,
    cuts: [4],
    why:
        'The bend flips at x = 4, so that is the inflection point. It is the '
        'one place on this beam where the curvature changes direction, and it '
        'is nowhere near either flat spot.',
    source: 'math-ad-q3',
  ),
  BendRound(
    subject: r'f(x) = -2x^2 + 16x - 5',
    unit: 'x',
    poly: Poly([-5, 16, -2]),
    x0: 0,
    x1: 8,
    cuts: [4],
    why:
        'Frowning on both sides. x = 4 is where the SLOPE is zero, not where '
        'the bend changes, and a parabola never changes its bend at all. A '
        'critical point is not an inflection point.',
    source: 'math-ad-q1',
  ),
  BendRound(
    subject: r'C(h) = 3h^2 - 36h + 150',
    unit: 'h, meters',
    poly: Poly([150, -36, 3]),
    x0: 0,
    x1: 12,
    cuts: [6],
    why:
        'Smiling the whole way. The second derivative is a constant 6, so it '
        'is never zero and there is no inflection point. Smiling everywhere '
        'is also why the flat spot at h = 6 has to be a minimum.',
    source: 'math-ad-q2',
  ),
  BendRound(
    subject: r'y(x) = x^3 - 6x^2 + 9x',
    unit: 'x, meters',
    poly: Poly([0, 9, -6, 1]),
    x0: 0,
    x1: 4,
    cuts: [2],
    why:
        'Frown then smile, so the bend flips at x = 2. Read it off the '
        'picture: the curve turns from holding water off its back to holding '
        'water in it.',
    source: 'math-ad-q3',
  ),
  BendRound(
    subject: r'y(x) = -x^3 + 9x^2 - 15x',
    unit: 'x, meters',
    poly: Poly([0, -15, 9, -1]),
    x0: 0,
    x1: 7,
    cuts: [3],
    why:
        'Smile then frown. The flip runs the other way here, and x = 3 is '
        'still the inflection point. The direction of the change does not '
        'matter, only that there is one.',
    source: 'math-ad-q3',
  ),
  BendRound(
    subject: r'y(x) = x^3 - 12x^2 + 36x',
    unit: 'x, meters along the beam',
    poly: Poly([0, 36, -12, 1]),
    x0: 0,
    x1: 8,
    cuts: [2, 4],
    why:
        'Two dividers, one flip. x = 2 is a flat spot and the bend is the '
        'same on both sides of it. Only x = 4 separates a frown from a smile, '
        'so only x = 4 is the inflection point.',
    source: 'math-ad-q3',
  ),
];

class _SignTheBendGameState extends State<SignTheBendGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'sign-the-bend',
    chapterId: 'mathematics',
    total: bendRounds.length,
    sourceProblemIdOf: (round) => bendRounds[round].source,
  )..addListener(_onSession);

  /// One entry per region: null until the student has said which way it bends.
  final Map<int, bool> _marked = {};

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  BendRound get _round => bendRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Sign the Bend',
        closing:
            'An inflection point needs the second derivative to be zero AND '
            'to change sign through it. Where the bend never changes there is '
            'no inflection point, however many flat spots the curve has.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final truth = r.bendsUp;
    final (yLo, yHi) = r.poly.range(r.x0, r.x1);
    final complete = _marked.length == r.regions.length;

    return BoardShell(
      session: _session,
      brief: concavityBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_marked.clear);
              _session.next();
            }
          : (!complete
                ? null
                : () => _session.submit(
                    ok: [
                      for (var i = 0; i < truth.length; i++) _marked[i] == truth[i],
                    ].every((ok) => ok),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIGN EVERY REGION',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mark each region: does the curve smile or frown through it? '
            'Then the flip, if there is one, is the inflection point.',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: MathBlock(r.subject, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: CurvePainter(
                    poly: r.poly,
                    x0: r.x0,
                    x1: r.x1,
                    yLo: yLo,
                    yHi: yHi,
                    cuts: r.cuts,
                    reveal: answered ? r.inflection : null,
                    revealIsRight: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CurveGeometry.padX,
            ),
            child: Row(
              children: [
                for (var i = 0; i < r.regions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    flex: ((r.regions[i].$2 - r.regions[i].$1) * 10).round(),
                    child: _BendCell(
                      from: r.regions[i].$1,
                      to: r.regions[i].$2,
                      marked: _marked[i],
                      truth: answered ? truth[i] : null,
                      onTap: answered
                          ? null
                          : (up) => setState(() => _marked[i] = up),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            r.unit,
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? (r.inflection == null ? 'NO FLIP, CORRECTLY' : 'FLIP FOUND')
                  : 'NOT THE BEND IT HAS',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// One region of the span, with the two ways a curve can bend through it.
class _BendCell extends StatelessWidget {
  const _BendCell({
    required this.from,
    required this.to,
    required this.marked,
    required this.truth,
    required this.onTap,
  });

  final double from;
  final double to;
  final bool? marked;

  /// Null while the round is live; the real answer once it is graded.
  final bool? truth;
  final void Function(bool up)? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${from.toInt()} to ${to.toInt()}',
          textAlign: TextAlign.center,
          style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
        ),
        const SizedBox(height: 4),
        // Stacked rather than side by side: a span can be a quarter of the
        // width, and two buttons across that is a sliver no thumb can hit.
        _BendButton(
          up: false,
          selected: marked == false,
          truth: truth,
          onTap: onTap == null ? null : () => onTap!(false),
        ),
        const SizedBox(height: 5),
        _BendButton(
          up: true,
          selected: marked == true,
          truth: truth,
          onTap: onTap == null ? null : () => onTap!(true),
        ),
      ],
    );
  }
}

class _BendButton extends StatelessWidget {
  const _BendButton({
    required this.up,
    required this.selected,
    required this.truth,
    required this.onTap,
  });

  final bool up;
  final bool selected;
  final bool? truth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = truth != null;
    final isTruth = truth == up;
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
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 46,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: CustomPaint(
            painter: _ArcPainter(
              up: up,
              color: (locked && isTruth)
                  ? AppColors.forest
                  : (locked && selected)
                  ? AppColors.error
                  : selected
                  ? AppColors.ember
                  : AppColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

/// A smile or a frown, drawn rather than named: the shape IS the vocabulary,
/// and a student who has to translate "concave up" into a picture every time
/// is doing the translation instead of the reading.
class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.up, required this.color});

  final bool up;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width * 0.52;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bend = up ? 14.0 : -14.0;
    final path = Path()
      ..moveTo(cx - w / 2, cy - bend / 2)
      ..quadraticBezierTo(cx, cy + bend * 1.5, cx + w / 2, cy - bend / 2);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.up != up || old.color != color;
}
