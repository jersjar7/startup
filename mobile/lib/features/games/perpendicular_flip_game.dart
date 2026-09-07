import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/app_button.dart';
import 'game_progress.dart';
import '../shared/widgets/engineering_grid.dart';

/// Perpendicular Flip — the first game for lesson `straight-lines-quadratics`
/// (Mathematics -> Analytic Geometry).
///
/// The student never computes. A boundary line is drawn on the grid and they
/// BUILD the second line's slope with two toggles (flip the fraction, negate
/// the sign), watching it swing on the grid as they do. The ask alternates
/// between perpendicular and parallel so "always flip and negate" is not a
/// winning strategy — that alternation is what makes it a retrieval item
/// instead of a pattern.
///
/// Rules obeyed: no clock, no hearts, bounded board, a miss is re-queued rather
/// than punished. See docs/mobile/question-design.md and
/// docs/mobile-app-north-star.md.
class PerpendicularFlipGame extends StatefulWidget {
  const PerpendicularFlipGame({super.key});

  @override
  State<PerpendicularFlipGame> createState() => _PerpendicularFlipGameState();
}

/// A slope held as an exact fraction so nothing is ever a decimal on screen.
@immutable
class Slope {
  const Slope(this.num, this.den);

  final int num;
  final int den;

  Slope get normalized {
    var n = num, d = den;
    if (d < 0) {
      n = -n;
      d = -d;
    }
    final g = _gcd(n.abs(), d.abs());
    return g == 0 ? Slope(n, d) : Slope(n ~/ g, d ~/ g);
  }

  Slope get flipped => Slope(den, num);
  Slope get negated => Slope(-num, den);

  double get value => den == 0 ? double.infinity : num / den;

  String get label {
    final s = normalized;
    if (s.den == 1) return '${s.num}';
    final sign = s.num < 0 ? '−' : '';
    return '$sign${s.num.abs()}/${s.den}';
  }

  bool sameAs(Slope other) {
    final a = normalized, b = other.normalized;
    return a.num == b.num && a.den == b.den;
  }

  static int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);
}

enum Ask { perpendicular, parallel }

@immutable
class Round {
  const Round({
    required this.context,
    required this.ask,
    required this.boundary,
  });

  final String context;
  final Ask ask;
  final Slope boundary;

  Slope get target => ask == Ask.perpendicular
      ? Slope(-boundary.den, boundary.num)
      : boundary;

  bool get needsFlip => ask == Ask.perpendicular;
  bool get needsNegate => ask == Ask.perpendicular;
}

const _board = <Round>[
  Round(
    context:
        'A property boundary runs from P(2, 3) to Q(8, 7). A utility easement '
        'must be laid perpendicular to it through Q.',
    ask: Ask.perpendicular,
    boundary: Slope(2, 3),
  ),
  Round(
    context: 'A retaining wall falls away at this slope. The tieback anchor '
        'runs perpendicular into the soil behind it.',
    ask: Ask.perpendicular,
    boundary: Slope(-3, 4),
  ),
  Round(
    context: 'A sidewalk is offset 5 feet from the curb line and runs parallel '
        'to it the whole block.',
    ask: Ask.parallel,
    boundary: Slope(1, 2),
  ),
  Round(
    context: 'A steep access drive meets the collector road. The stop bar is '
        'struck perpendicular to the drive.',
    ask: Ask.perpendicular,
    boundary: Slope(5, 2),
  ),
  Round(
    context: 'A second storm line is run parallel to the existing lateral, '
        '8 feet to the north.',
    ask: Ask.parallel,
    boundary: Slope(-1, 4),
  ),
  Round(
    context: 'A bridge deck crosses the stream on this alignment. The pier cap '
        'sits perpendicular to the deck.',
    ask: Ask.perpendicular,
    boundary: Slope(4, 3),
  ),
  Round(
    context: 'A parcel line bears off at this slope. The new lot split runs '
        'perpendicular to it.',
    ask: Ask.perpendicular,
    boundary: Slope(-2, 5),
  ),
  Round(
    context: 'A fence is built parallel to the shared property line, one foot '
        'inside it.',
    ask: Ask.parallel,
    boundary: Slope(3, 1),
  ),
];

class _PerpendicularFlipGameState extends State<PerpendicularFlipGame> {
  late final List<Round> _queue = List.of(_board);
  final Set<int> _cleared = {};

  final Set<int> _seen = {};

  int _i = 0;
  bool _flip = false;
  bool _negate = false;
  bool? _correct;
  int _firstTry = 0;

  Round get _round => _queue[_i];

  Slope get _built {
    var s = _round.boundary;
    if (_flip) s = s.flipped;
    if (_negate) s = s.negated;
    return s;
  }

  bool get _done => _cleared.length == _board.length;

  void _confirm() {
    final idx = _board.indexOf(_round);
    final ok = _built.sameAs(_round.target);
    setState(() {
      _correct = ok;
      if (ok) {
        _cleared.add(idx);
        if (!_seen.contains(idx)) _firstTry++;
        if (_cleared.length == _board.length) {
          GameProgress.instance.markCleared('perpendicular-flip');
        }
      } else {
        _queue.add(_round); // a miss comes back later in the same board
      }
      _seen.add(idx);
    });
  }

  void _next() {
    setState(() {
      _i++;
      _flip = false;
      _negate = false;
      _correct = null;
    });
  }

  void _restart() {
    setState(() {
      _queue
        ..clear()
        ..addAll(_board);
      _cleared.clear();
      _i = 0;
      _flip = false;
      _negate = false;
      _correct = null;
      _firstTry = 0;
      _seen.clear();
    });
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: _done ? _buildDone() : _buildRound(),
      ),
    );
  }

  Widget _buildDone() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Text('BOARD CLEAR', style: AppTheme.overline(color: AppColors.forest)),
          const SizedBox(height: 10),
          Text('Perpendicular Flip', style: AppTheme.heading(size: 32)),
          const SizedBox(height: 16),
          Text(
            'You built all ${_board.length} lines. $_firstTry landed on the '
            'first try.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.ink2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: const Text(
              'You know the rule. Perpendicular means flip the fraction and '
              'change the sign, and parallel means leave it alone. Solving a '
              'full alignment problem still belongs at the desk.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.ink2,
              ),
            ),
          ),
          const Spacer(),
          AppButton(label: 'Play again', onPressed: _restart),
          const SizedBox(height: 10),
          AppButton(label: 'Done', ghost: true, onPressed: _leave),
        ],
      ),
    );
  }

  Widget _buildRound() {
    final r = _round;
    final answered = _correct != null;

    return Column(
      children: [
        _header(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.ask == Ask.perpendicular
                      ? 'LAY IT PERPENDICULAR'
                      : 'LAY IT PARALLEL',
                  style: AppTheme.overline(
                    color: r.ask == Ask.perpendicular
                        ? AppColors.ember
                        : AppColors.info,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  r.context,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                _canvas(r),
                const SizedBox(height: 14),
                _readout(r),
                const SizedBox(height: 16),
                if (!answered) ...[
                  _toggle(
                    label: 'Flip the fraction',
                    detail: 'Swap rise and run',
                    on: _flip,
                    onTap: () => setState(() => _flip = !_flip),
                  ),
                  const SizedBox(height: 10),
                  _toggle(
                    label: 'Change the sign',
                    detail: 'Positive becomes negative',
                    on: _negate,
                    onTap: () => setState(() => _negate = !_negate),
                  ),
                ] else
                  _feedback(r),
                const SizedBox(height: 20),
                AppButton(
                  label: answered
                      ? (_cleared.length == _board.length ? 'Finish' : 'Next')
                      : 'Confirm this line',
                  onPressed: answered ? _next : _confirm,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header() {
    final progress = _cleared.length / _board.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _leave,
            icon: const Icon(Icons.close_rounded,
                color: AppColors.ink3, size: 22),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.creamDark,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.forest),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('${_cleared.length}/${_board.length}',
              style: AppTheme.mono(size: 13, color: AppColors.ink2)),
        ],
      ),
    );
  }

  Widget _canvas(Round r) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 230,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 20,
          major: 100,
          child: CustomPaint(
            painter: _LinesPainter(
              boundary: r.boundary.value,
              built: _built.value,
              locked: _correct,
              showBuilt: _flip || _negate || _correct != null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _readout(Round r) {
    Widget cell(String label, String value, Color color) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.overline()),
            const SizedBox(height: 4),
            Text(value, style: AppTheme.mono(size: 22, color: color)),
          ],
        ),
      );
    }

    return Row(
      children: [
        cell('BOUNDARY', 'm = ${r.boundary.label}', AppColors.charcoal),
        cell(
          'YOU BUILT',
          'm = ${_built.label}',
          _correct == null
              ? AppColors.ember
              : (_correct! ? AppColors.forest : AppColors.error),
        ),
      ],
    );
  }

  Widget _toggle({
    required String label,
    required String detail,
    required bool on,
    required VoidCallback onTap,
  }) {
    return Material(
      color: on ? AppColors.emberBg : AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: on ? AppColors.ember : AppColors.line,
              width: on ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTheme.heading(size: 16, height: 1.2)),
                    const SizedBox(height: 2),
                    Text(detail,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.ink2)),
                  ],
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? AppColors.ember : Colors.transparent,
                  border: Border.all(
                    color: on ? AppColors.ember : AppColors.line,
                    width: 1.5,
                  ),
                ),
                child: on
                    ? const Icon(Icons.check_rounded,
                        size: 17, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedback(Round r) {
    final ok = _correct == true;
    final String line;
    if (ok) {
      line = r.ask == Ask.perpendicular
          ? 'Square. Perpendicular needs both moves: flip the fraction and '
              'change the sign.'
          : 'Parallel. Same slope, no moves at all.';
    } else if (r.ask == Ask.parallel) {
      line = 'Parallel lines have the same slope. Leave the fraction alone.';
    } else if (_flip && !_negate) {
      line = 'You flipped but kept the sign, so both lines still climb the '
          'same way. It is not square.';
    } else if (!_flip && _negate) {
      line = 'You changed the sign without flipping. That is a mirror image, '
          'not a perpendicular.';
    } else {
      line = 'That is the same line you started with. Perpendicular needs the '
          'flip and the sign change.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ok ? AppColors.forestBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ok ? 'CORRECT' : 'NOT SQUARE',
            style: AppTheme.overline(
                color: ok ? AppColors.forest : AppColors.error),
          ),
          const SizedBox(height: 6),
          Text(
            line,
            style: const TextStyle(
                fontSize: 14, height: 1.55, color: AppColors.charcoal),
          ),
          if (!ok) ...[
            const SizedBox(height: 6),
            Text('It comes back later in this board.',
                style: const TextStyle(fontSize: 12.5, color: AppColors.ink2)),
          ],
        ],
      ),
    );
  }
}

class _LinesPainter extends CustomPainter {
  _LinesPainter({
    required this.boundary,
    required this.built,
    required this.locked,
    required this.showBuilt,
  });

  final double boundary;
  final double built;
  final bool? locked;
  final bool showBuilt;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final q = Offset(size.width * 0.5, size.height * 0.5);

    _line(canvas, size, q, boundary,
        color: AppColors.charcoal, width: 3, dashed: false);

    if (showBuilt) {
      final square = (boundary * built + 1).abs() < 1e-9;
      final color = locked == null
          ? AppColors.ember
          : (locked! ? AppColors.forest : AppColors.error);
      _line(canvas, size, q, built,
          color: color, width: 3, dashed: locked == null);

      if (square) _rightAngle(canvas, q, boundary, built, color);
    }

    // Q, the point both lines pass through.
    canvas.drawCircle(q, 5.5, Paint()..color = AppColors.charcoal);
    canvas.drawCircle(q, 2.5, Paint()..color = AppColors.cream);
  }

  void _line(
    Canvas canvas,
    Size size,
    Offset q,
    double m, {
    required Color color,
    required double width,
    required bool dashed,
  }) {
    // Screen y grows downward, so a positive slope points up-right.
    final dir = m.isInfinite
        ? const Offset(0, -1)
        : Offset(1, -m) / math.sqrt(1 + m * m);
    final reach = size.width + size.height;
    final a = q - dir * reach;
    final b = q + dir * reach;

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    if (!dashed) {
      canvas.drawLine(a, b, paint);
      return;
    }
    const dash = 11.0, gap = 7.0;
    final total = (b - a).distance;
    final unit = (b - a) / total;
    for (double t = 0; t < total; t += dash + gap) {
      final end = math.min(t + dash, total);
      canvas.drawLine(a + unit * t, a + unit * end, paint);
    }
  }

  void _rightAngle(
      Canvas canvas, Offset q, double m1, double m2, Color color) {
    Offset u(double m) => m.isInfinite
        ? const Offset(0, -1)
        : Offset(1, -m) / math.sqrt(1 + m * m);
    const s = 16.0;
    final a = u(m1) * s, b = u(m2) * s;
    final path = Path()
      ..moveTo(q.dx + a.dx, q.dy + a.dy)
      ..lineTo(q.dx + a.dx + b.dx, q.dy + a.dy + b.dy)
      ..lineTo(q.dx + b.dx, q.dy + b.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_LinesPainter old) =>
      old.boundary != boundary ||
      old.built != built ||
      old.locked != locked ||
      old.showBuilt != showBuilt;
}
