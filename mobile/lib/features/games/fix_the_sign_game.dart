import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Fix the Sign — the third item for `cross-product-applications`.
///
/// The lesson gives the cofactor expansion one tip and it is about a sign: the
/// middle term is subtracted, plus minus plus across the three. That single
/// minus accounts for more wrong cross products on this exam than anything
/// else. So every round shows an expansion already worked out, WITH its
/// working written beside each term, and asks whether the plus minus plus
/// pattern survived. The working is shown on purpose: the question is about
/// the pattern, not about whether anyone can multiply four by five.
class FixTheSignGame extends StatefulWidget {
  const FixTheSignGame({super.key});

  @override
  State<FixTheSignGame> createState() => _FixTheSignGameState();
}

@immutable
class SignTerm {
  const SignTerm({required this.working, required this.value});

  /// The cofactor as it comes out of the determinant, minus sign and all.
  final String working;

  /// What the line claims the component is.
  final String value;
}

@immutable
class ExpansionRound {
  const ExpansionRound({
    required this.setup,
    required this.terms,
    required this.bad,
    required this.why,
    required this.source,
  });

  /// The cross product being taken, as a determinant.
  final String setup;

  /// The i, j and k lines as somebody wrote them down.
  final List<SignTerm> terms;

  /// Which line is wrong, or null when the whole thing is right.
  final int? bad;
  final String why;
  final String source;
}

const expansions = <ExpansionRound>[
  ExpansionRound(
    setup: r'\vec{r} \times \vec{F},\quad \vec{r} = (3, 4, 0),\ '
        r'\vec{F} = (0, 0, -5)',
    terms: [
      SignTerm(working: r'+\big[(4)(-5) - (0)(0)\big]', value: '-20'),
      SignTerm(working: r'+\big[(3)(-5) - (0)(0)\big]', value: '-15'),
      SignTerm(working: r'+\big[(3)(0) - (4)(0)\big]', value: '0'),
    ],
    bad: 1,
    why:
        'The middle term is SUBTRACTED. It should read minus the bracket, '
        'which turns minus fifteen into plus fifteen. A minus in front of a '
        'negative is where this goes wrong, and it flips the whole moment.',
    source: 'math-cpa-q2',
  ),
  ExpansionRound(
    setup: r'\vec{r} \times \vec{F},\quad \vec{r} = (3, 4, 0),\ '
        r'\vec{F} = (0, 0, -5)',
    terms: [
      SignTerm(working: r'+\big[(4)(-5) - (0)(0)\big]', value: '-20'),
      SignTerm(working: r'-\big[(3)(-5) - (0)(0)\big]', value: '+15'),
      SignTerm(working: r'+\big[(3)(0) - (4)(0)\big]', value: '0'),
    ],
    bad: null,
    why:
        'Plus, minus, plus, and the minus did its job. The moment points up '
        'and back, and this is the worked answer with the fifty scaled down '
        'to a five.',
    source: 'math-cpa-q2',
  ),
  ExpansionRound(
    setup: r'\vec{A} \times \vec{B},\quad \vec{A} = (1, 0, 0),\ '
        r'\vec{B} = (0, 1, 0)',
    terms: [
      SignTerm(working: r'+\big[(0)(0) - (0)(1)\big]', value: '0'),
      SignTerm(working: r'-\big[(1)(0) - (0)(0)\big]', value: '0'),
      SignTerm(working: r'+\big[(1)(1) - (0)(0)\big]', value: '-1'),
    ],
    bad: 2,
    why:
        'One times one is a positive one, and the k term is added, so it is '
        'plus one. Minus one would be j crossed with i, the other way round. '
        'This is the one worth knowing on sight: i cross j is k.',
    source: 'math-cpa-q1',
  ),
  ExpansionRound(
    setup: r'\vec{u} \times \vec{v},\quad \vec{u} = (4, 0, 0),\ '
        r'\vec{v} = (2, 3, 0)',
    terms: [
      SignTerm(working: r'+\big[(0)(0) - (0)(3)\big]', value: '12'),
      SignTerm(working: r'-\big[(4)(0) - (0)(2)\big]', value: '0'),
      SignTerm(working: r'+\big[(4)(3) - (0)(2)\big]', value: '12'),
    ],
    bad: 0,
    why:
        'The i bracket is all zeros, so the i component is nothing. The 12 '
        'belongs to k and has been copied into the wrong line. Both edges lie '
        'flat, so the answer can only point out of the page.',
    source: 'math-cpa-q3',
  ),
  ExpansionRound(
    setup: r'\vec{A} \times \vec{B},\quad \vec{A} = (2, 1, 3),\ '
        r'\vec{B} = (0, 4, 1)',
    terms: [
      SignTerm(working: r'+\big[(1)(1) - (3)(4)\big]', value: '-11'),
      SignTerm(working: r'-\big[(2)(1) - (3)(0)\big]', value: '+2'),
      SignTerm(working: r'+\big[(2)(4) - (1)(0)\big]', value: '8'),
    ],
    bad: 1,
    why:
        'The bracket comes to two and it is subtracted, so the j component is '
        'minus two. The working is right and the sign in front of it was '
        'ignored, which is the most common way to lose this question.',
    source: 'math-cpa-q2',
  ),
  ExpansionRound(
    setup: r'\vec{A} \times \vec{B},\quad \vec{A} = (1, 2, 0),\ '
        r'\vec{B} = (3, 0, 4)',
    terms: [
      SignTerm(working: r'+\big[(2)(4) - (0)(0)\big]', value: '8'),
      SignTerm(working: r'-\big[(1)(4) - (0)(3)\big]', value: '-4'),
      SignTerm(working: r'+\big[(1)(0) - (2)(3)\big]', value: '-6'),
    ],
    bad: null,
    why:
        'All three survive the check. Two of the components come out negative '
        'and neither of them is a mistake: a cross product is a vector and it '
        'is allowed to point wherever it likes.',
    source: 'math-cpa-q1',
  ),
];

class _FixTheSignGameState extends State<FixTheSignGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'fix-the-sign',
    chapterId: 'mathematics',
    total: expansions.length,
    sourceProblemIdOf: (round) => expansions[round].source,
  )..addListener(_onSession);

  /// The line the student says is wrong, or -1 for "it is all fine".
  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  ExpansionRound get _round => expansions[_session.round];

  static const _axes = ['i', 'j', 'k'];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Fix the Sign',
        closing:
            'Plus, minus, plus across the three components. The middle one is '
            'subtracted every single time, and a minus in front of a negative '
            'bracket is where the moments go backwards.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: cofactorBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == (r.bad ?? -1),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLUS, MINUS, PLUS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'One line may have the wrong sign. Tap it, or say the whole thing '
            'is right.',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MathBlock(r.setup, fontSize: 14),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.terms.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _TermRow(
              key: ValueKey('term-$i'),
              axis: _axes[i],
              term: r.terms[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.bad == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          const SizedBox(height: 10),
          _CleanButton(
            selected: _picked == -1,
            locked: answered,
            isTruth: r.bad == null,
            onTap: answered ? null : () => setState(() => _picked = -1),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? (r.bad == null ? 'ALL THREE STAND' : 'THAT IS THE ONE')
                  : 'NOT THAT LINE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _TermRow extends StatelessWidget {
  const _TermRow({
    super.key,
    required this.axis,
    required this.term,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String axis;
  final SignTerm term;
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                width: 22,
                child: Text(
                  axis,
                  style: AppTheme.mono(size: 15, color: AppColors.ink2),
                ),
              ),
              Expanded(
                child: MathBlock(
                  '${term.working} = ${term.value}',
                  fontSize: 15,
                  align: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CleanButton extends StatelessWidget {
  const _CleanButton({
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
      key: const ValueKey('term-clean'),
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
            'All three signs are right',
            style: AppTheme.heading(size: 14.5),
          ),
        ),
      ),
    );
  }
}
