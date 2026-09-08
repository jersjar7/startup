import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Both Sides — the third item for `lhopitals-rule`.
///
/// When substituting gives a number over zero the rule is out, and what is
/// left is a question the lesson answers in one line and students lose marks
/// on constantly: it blows up, but to which infinity, and does the two-sided
/// limit exist at all. The answer here is therefore one report per side, laid
/// out on the page the way the approaches are laid out on a number line, and
/// the verdict falls out of the pair rather than being asked for. Choosing
/// infinity when the two sides disagree is the named trap.
class BothSidesGame extends StatefulWidget {
  const BothSidesGame({super.key});

  @override
  State<BothSidesGame> createState() => _BothSidesGameState();
}

@immutable
class SidesRound {
  const SidesRound({
    required this.expr,
    required this.point,
    required this.top,
    required this.leftPositive,
    required this.rightPositive,
    required this.why,
    required this.source,
  });

  final String expr;

  /// Where x is heading, written the way it appears under the limit.
  final String point;

  /// What the top settles to, said in words, because the sign of the top is
  /// half of the reasoning and it is not always 1.
  final String top;

  final bool leftPositive;
  final bool rightPositive;
  final String why;
  final String source;

  /// Falls out of the two sides rather than being declared next to them.
  bool get exists => leftPositive == rightPositive;

  String get verdict => exists
      ? (leftPositive ? r'+\infty' : r'-\infty')
      : r'\text{does not exist}';
}

const sidesRounds = <SidesRound>[
  SidesRound(
    expr: r'\frac{e^x}{x}',
    point: r'x \to 0',
    top: 'the top settles at 1',
    leftPositive: false,
    rightPositive: true,
    why:
        'One over a small positive number is large and positive; one over a '
        'small negative number is large and negative. The sides disagree, so '
        'there is no two-sided limit. Answering plus infinity here is the '
        'other half of the trap on this problem.',
    source: 'math-lh-q3',
  ),
  SidesRound(
    expr: r'\frac{1}{x^2}',
    point: r'x \to 0',
    top: 'the top is 1',
    leftPositive: true,
    rightPositive: true,
    why:
        'Squaring kills the sign, so the bottom is positive from both '
        'directions. The sides agree, and here the limit really is plus '
        'infinity.',
    source: 'math-lh-q3',
  ),
  SidesRound(
    expr: r'\frac{1}{x - 3}',
    point: r'x \to 3',
    top: 'the top is 1',
    leftPositive: false,
    rightPositive: true,
    why:
        'The bottom changes sign as you pass through 3, so the fraction '
        'flips with it. Same shape as one over x, moved along the axis.',
    source: 'math-lh-q3',
  ),
  SidesRound(
    expr: r'\frac{-1}{x^2}',
    point: r'x \to 0',
    top: 'the top is -1',
    leftPositive: false,
    rightPositive: false,
    why:
        'The bottom is positive from both sides and the top is negative, so '
        'the whole thing runs to minus infinity either way. The sides agree, '
        'so this limit exists, and it is not a number.',
    source: 'math-lh-q3',
  ),
  SidesRound(
    expr: r'\frac{x + 2}{(x - 1)^2}',
    point: r'x \to 1',
    top: 'the top settles at 3',
    leftPositive: true,
    rightPositive: true,
    why:
        'The top is heading for a positive 3 and the squared bottom is '
        'positive from both directions. Plus infinity, and the top being '
        'something other than 1 changes nothing about the reasoning.',
    source: 'math-lh-q3',
  ),
  SidesRound(
    expr: r'\frac{x - 4}{x}',
    point: r'x \to 0',
    top: 'the top settles at -4',
    leftPositive: true,
    rightPositive: false,
    why:
        'A negative top over a small positive bottom is negative, and over a '
        'small negative bottom it is positive. The sign flips because of the '
        'BOTTOM, and the sides disagree.',
    source: 'math-lh-q3',
  ),
];

class _BothSidesGameState extends State<BothSidesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'both-sides',
    chapterId: 'mathematics',
    total: sidesRounds.length,
    sourceProblemIdOf: (round) => sidesRounds[round].source,
  )..addListener(_onSession);

  bool? _left;
  bool? _right;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SidesRound get _round => sidesRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Both Sides',
        closing:
            'A number over zero blows up, and which way it blows up depends '
            'on the side you came from. The two-sided limit exists only when '
            'the two directions agree.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final ready = _left != null && _right != null;

    return BoardShell(
      session: _session,
      brief: bothSidesBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() {
                _left = null;
                _right = null;
              });
              _session.next();
            }
          : (!ready
                ? null
                : () => _session.submit(
                    ok:
                        _left == r.leftPositive && _right == r.rightPositive,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE RULE IS OUT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Substituting gave a number over zero. Report which way the '
            'fraction runs from each side.',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                MathBlock('\\lim_{${r.point}}${r.expr}', fontSize: 20),
                const SizedBox(height: 10),
                Text(
                  '${r.top}, and the bottom goes to zero',
                  style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SidePanel(
                  keyPrefix: 'left',
                  title: 'COMING FROM THE LEFT',
                  arrow: '→',
                  picked: _left,
                  truth: answered ? r.leftPositive : null,
                  onPick: answered
                      ? null
                      : (up) => setState(() => _left = up),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SidePanel(
                  keyPrefix: 'right',
                  title: 'COMING FROM THE RIGHT',
                  arrow: '←',
                  picked: _right,
                  truth: answered ? r.rightPositive : null,
                  onPick: answered
                      ? null
                      : (up) => setState(() => _right = up),
                ),
              ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.creamDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'SO THE LIMIT IS',
                    style: AppTheme.overline(color: AppColors.ink2),
                  ),
                  const SizedBox(height: 6),
                  MathBlock(r.verdict, fontSize: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'BOTH SIDES READ RIGHT' : 'NOT BOTH',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({
    required this.keyPrefix,
    required this.title,
    required this.arrow,
    required this.picked,
    required this.truth,
    required this.onPick,
  });

  final String keyPrefix;
  final String title;

  /// Which way the approach runs, drawn rather than described.
  final String arrow;
  final bool? picked;
  final bool? truth;
  final void Function(bool up)? onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$arrow  $title',
          style: AppTheme.overline(color: AppColors.ink2),
        ),
        const SizedBox(height: 8),
        _RunButton(
          key: ValueKey('$keyPrefix-up'),
          label: 'runs up',
          detail: 'to a big positive',
          selected: picked == true,
          truth: truth,
          isUp: true,
          onTap: onPick == null ? null : () => onPick!(true),
        ),
        const SizedBox(height: 6),
        _RunButton(
          key: ValueKey('$keyPrefix-down'),
          label: 'runs down',
          detail: 'to a big negative',
          selected: picked == false,
          truth: truth,
          isUp: false,
          onTap: onPick == null ? null : () => onPick!(false),
        ),
      ],
    );
  }
}

class _RunButton extends StatelessWidget {
  const _RunButton({
    super.key,
    required this.label,
    required this.detail,
    required this.selected,
    required this.truth,
    required this.isUp,
    required this.onTap,
  });

  final String label;
  final String detail;
  final bool selected;
  final bool? truth;
  final bool isUp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locked = truth != null;
    final isTruth = truth == isUp;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isUp ? Icons.north_east_rounded : Icons.south_east_rounded,
                size: 18,
                color: AppColors.ink2,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTheme.heading(size: 14)),
                    Text(
                      detail,
                      style: AppTheme.mono(size: 10, color: AppColors.ink3),
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
