import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'calculus_figures.dart';
import 'lesson_brief.dart';
import 'root_figures.dart';

/// Can It Start Here — the second item for `numerical-methods`.
///
/// Bisection needs one thing and only one thing to begin: the function on
/// opposite sides of the axis at the two ends. The lesson's trap is believing
/// that two same-signed ends can bracket a root, and there is a curve here
/// that makes the belief look reasonable, because it dips right through the
/// axis and comes back up between two ends that are both positive. There IS a
/// root in that span, two of them, and bisection still cannot be started on
/// it. Seeing the brackets drawn under the curve is what separates "a root is
/// in there" from "this method can find it".
class CanItStartGame extends StatefulWidget {
  const CanItStartGame({super.key});

  @override
  State<CanItStartGame> createState() => _CanItStartGameState();
}

@immutable
class BracketRound {
  const BracketRound({
    required this.shown,
    required this.poly,
    required this.from,
    required this.to,
    required this.brackets,
    required this.why,
    required this.source,
  });

  final String shown;
  final Poly poly;
  final double from;
  final double to;

  /// The spans on offer, in the order they are drawn and lettered.
  final List<(double, double)> brackets;
  final String why;
  final String source;

  /// The first span whose ends sit on opposite sides of the axis, or null
  /// when none of them do. Worked out from the curve, never declared.
  int? get answer {
    for (final (i, span) in brackets.indexed) {
      if (poly.at(span.$1) * poly.at(span.$2) < 0) return i;
    }
    return null;
  }
}

const bracketRounds = <BracketRound>[
  BracketRound(
    shown: 'f(x) = x squared minus 4',
    poly: Poly([-4, 0, 1]),
    from: 0,
    to: 6,
    brackets: [(0.5, 1.5), (1, 3), (4, 5.5)],
    why:
        'Only B has the curve below the axis at one end and above it at the '
        'other. A is entirely below and C entirely above, and neither of them '
        'has anywhere for a crossing to hide.',
    source: 'math-num-q2',
  ),
  BracketRound(
    shown: 'f(x) = x squared minus 6x plus 8',
    poly: Poly([8, -6, 1]),
    from: 0,
    to: 6,
    brackets: [(1, 5), (1.5, 2.5), (2.5, 3.5)],
    why:
        'A holds BOTH roots, so the function comes back to the same side it '
        'started on and bisection cannot be started on it even though there '
        'are two crossings inside. B holds one crossing and has opposite '
        'signs, which is the whole requirement. C sits under the axis at both '
        'ends.',
    source: 'math-num-q2',
  ),
  BracketRound(
    shown: 'f(x) = x squared minus 6x plus 8',
    poly: Poly([8, -6, 1]),
    from: 0,
    to: 6,
    brackets: [(0, 1.5), (2.2, 3.8), (3.5, 5)],
    why:
        'C crosses from below to above, so it qualifies. A is above the axis '
        'at both ends and B is below at both ends, and being close to a root '
        'is not the same as having one bracketed.',
    source: 'math-num-q2',
  ),
  BracketRound(
    shown: 'f(x) = 4 minus x squared',
    poly: Poly([4, 0, -1]),
    from: -4,
    to: 4,
    brackets: [(-1, 1), (1, 3), (-3.5, 3.5)],
    why:
        'B, and the curve running downwards rather than upwards changes '
        'nothing: the test is opposite SIGNS, not which way the function is '
        'heading. The wide span holds both roots and comes back to the sign '
        'it started with.',
    source: 'math-num-q2',
  ),
  BracketRound(
    shown: 'f(x) = x cubed minus 4x',
    poly: Poly([0, -4, 0, 1]),
    from: -3,
    to: 3,
    brackets: [(-2.5, -1.5), (0.5, 1.5), (2.5, 3)],
    why:
        'A brackets the crossing at minus two. This curve has three roots and '
        'the other two are nowhere near B or C, both of which sit entirely on '
        'one side of the axis. More roots does not mean more brackets.',
    source: 'math-num-q2',
  ),
  BracketRound(
    shown: 'f(x) = x squared plus 1',
    poly: Poly([1, 0, 1]),
    from: -3,
    to: 3,
    brackets: [(-2, -1), (-1, 1), (1, 2)],
    why:
        'None of them. This curve never touches the axis at all, so it has no '
        'root to bracket and no interval can be made to work. Bisection is '
        'not a method for finding roots that are not there.',
    source: 'math-num-q2',
  ),
];

class _CanItStartGameState extends State<CanItStartGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'can-it-start',
    chapterId: 'mathematics',
    total: bracketRounds.length,
    sourceProblemIdOf: (round) => bracketRounds[round].source,
  )..addListener(_onSession);

  /// The span the student picked, or -1 for "none of them".
  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  BracketRound get _round => bracketRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Can It Start Here',
        closing:
            'Bisection needs the two ends on opposite sides of the axis and '
            'nothing else. A span can hold two roots and still fail the test, '
            'and a curve with no roots fails it everywhere.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final truth = r.answer;

    return BoardShell(
      session: _session,
      brief: bisectionBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == (truth ?? -1),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OPPOSITE SIDES OF THE AXIS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Which span can bisection be started on?',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.shown,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: RootPainter(
                    poly: r.poly,
                    x0: r.from,
                    x1: r.to,
                    brackets: r.brackets,
                    pickedBracket: _picked,
                    truthBracket: answered ? truth : null,
                    revealed: answered,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < r.brackets.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _SpanButton(
                    key: ValueKey('span-$i'),
                    label: String.fromCharCode(65 + i),
                    selected: _picked == i,
                    locked: answered,
                    isTruth: truth == i,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          _NoneButton(
            selected: _picked == -1,
            locked: answered,
            isTruth: truth == null,
            onTap: answered ? null : () => setState(() => _picked = -1),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? (truth == null ? 'NONE OF THEM, CORRECTLY' : 'THAT SPAN')
                  : 'NOT THAT SPAN',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _SpanButton extends StatelessWidget {
  const _SpanButton({
    super.key,
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
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(label, style: AppTheme.heading(size: 17)),
        ),
      ),
    );
  }
}

class _NoneButton extends StatelessWidget {
  const _NoneButton({
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

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
      key: const ValueKey('span-none'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Text(
            'None of them will do',
            style: AppTheme.heading(size: 14.5),
          ),
        ),
      ),
    );
  }
}
