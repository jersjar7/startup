import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Pick u, Pick du — the first item for `integral-calculus`.
///
/// Substitution is two decisions that have to agree with each other, and the
/// lesson's trap list says so outright: students mix up which function is u
/// and which one is du. So the answer here is a PAIR. Getting u right and du
/// wrong is not partial credit, it is the mistake, and the round says which
/// half went wrong. One round has no substitution in it at all, because a
/// student who always finds a du will reach for one where there is none.
class PickUGame extends StatefulWidget {
  const PickUGame({super.key});

  @override
  State<PickUGame> createState() => _PickUGameState();
}

@immutable
class USubRound {
  const USubRound({
    required this.integrand,
    required this.uOptions,
    required this.duOptions,
    required this.uAnswer,
    required this.duAnswer,
    required this.why,
    required this.source,
    this.noSub = false,
  });

  final String integrand;
  final List<String> uOptions;
  final List<String> duOptions;

  /// Index into [uOptions] and [duOptions]. Ignored when [noSub].
  final int uAnswer;
  final int duAnswer;

  /// True when nothing in the integrand is the derivative of anything else in
  /// it, so substitution is the wrong tool.
  final bool noSub;
  final String why;
  final String source;
}

const uSubRounds = <USubRound>[
  USubRound(
    integrand: r'\int \sin^3 x\,\cos x\,dx',
    uOptions: [r'\sin x', r'\cos x', r'\sin^3 x'],
    duOptions: [r'\cos x\,dx', r'-\sin x\,dx', r'3\sin^2 x\,dx'],
    uAnswer: 0,
    duAnswer: 0,
    why:
        'The cosine is the derivative of the sine, which is what makes the '
        'substitution work. With u = sin x the whole thing becomes the '
        'integral of u cubed.',
    source: 'math-ic-q3',
  ),
  USubRound(
    integrand: r'\int (x^2+1)^5\,2x\,dx',
    uOptions: [r'(x^2+1)^5', r'x^2+1', r'2x'],
    duOptions: [r'5(x^2+1)^4\,dx', r'2x\,dx', r'x^2\,dx'],
    uAnswer: 1,
    duAnswer: 1,
    why:
        'u is the INSIDE, not the whole power. Its derivative, 2x dx, is '
        'sitting right there beside it, which is the sign that substitution '
        'is the way in.',
    source: 'math-ic-q3',
  ),
  USubRound(
    integrand: r'\int \cos^4 x\,\sin x\,dx',
    uOptions: [r'\sin x', r'\cos^4 x', r'\cos x'],
    duOptions: [r'\sin x\,dx', r'-\sin x\,dx', r'\cos x\,dx'],
    uAnswer: 2,
    duAnswer: 1,
    why:
        'The derivative of cosine carries a minus sign, and it does not go '
        'away because it is inconvenient. du = -sin x dx, so the sine in the '
        'integrand is -du.',
    source: 'math-ic-q3',
  ),
  USubRound(
    integrand: r'\int x\,e^{3x^2}\,dx',
    uOptions: [r'e^{3x^2}', r'3x^2', r'x'],
    duOptions: [r'6x\,dx', r'x\,dx', r'3x^2\,dx'],
    uAnswer: 1,
    duAnswer: 0,
    why:
        'u is the exponent. Its derivative is 6x dx, and the x dx you were '
        'handed is one sixth of that. A constant factor is allowed to be '
        'fixed up; a missing x is not.',
    source: 'math-ic-q3',
  ),
  USubRound(
    integrand: r'\int \frac{\ln x}{x}\,dx',
    uOptions: [r'\ln x', r'\frac{1}{x}', r'x'],
    duOptions: [r'\frac{1}{x}\,dx', r'\ln x\,dx', r'-\frac{1}{x^2}\,dx'],
    uAnswer: 0,
    duAnswer: 0,
    why:
        'The derivative of ln x is 1/x, and 1/x is exactly what is dividing '
        'it. The integral becomes u du.',
    source: 'math-ic-q3',
  ),
  USubRound(
    integrand: r'\int x\,e^{2x}\,dx',
    uOptions: [r'x', r'e^{2x}', r'2x'],
    duOptions: [r'dx', r'2e^{2x}\,dx', r'e^{2x}\,dx'],
    uAnswer: 0,
    duAnswer: 0,
    noSub: true,
    why:
        'Nothing here is the derivative of anything else: x is not the '
        'derivative of e to the 2x, and the exponential is not the derivative '
        'of x. This one is integration by parts.',
    source: 'math-ic-q2',
  ),
];

class _PickUGameState extends State<PickUGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'pick-u',
    chapterId: 'mathematics',
    total: uSubRounds.length,
    sourceProblemIdOf: (round) => uSubRounds[round].source,
  )..addListener(_onSession);

  int? _u;
  int? _du;
  bool _none = false;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  USubRound get _round => uSubRounds[_session.round];

  void _clear() {
    _u = null;
    _du = null;
    _none = false;
  }

  bool _isRight(USubRound r) =>
      r.noSub ? _none : (_u == r.uAnswer && _du == r.duAnswer);

  /// What the feedback should say. Half right is its own answer, because half
  /// right is the mistake this item exists to name.
  String _verdict(USubRound r) {
    if (r.noSub) return _none ? 'NO SUBSTITUTION, CORRECTLY' : 'THERE IS NO du';
    if (_none) return 'THERE IS A SUBSTITUTION HERE';
    if (_u == r.uAnswer && _du != r.duAnswer) return 'RIGHT u, WRONG du';
    if (_u != r.uAnswer && _du == r.duAnswer) return 'THAT du, BUT NOT THAT u';
    return _isRight(r) ? 'BOTH HALVES' : 'NOT THIS PAIR';
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Pick u, Pick du',
        closing:
            'Substitution works when the derivative of the inside is already '
            'in the integrand. Choosing u and du is the decision; carrying it '
            'through, limits and all, is desk work.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final ready = _none || (_u != null && _du != null);

    return BoardShell(
      session: _session,
      brief: substitutionBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_clear);
              _session.next();
            }
          : (!ready
                ? null
                : () => _session.submit(ok: _isRight(r), context: context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BOTH HALVES HAVE TO AGREE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set u, then set du. They only work as a pair.',
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: MathBlock(r.integrand, fontSize: 19),
          ),
          const SizedBox(height: 16),
          _OptionRow(
            keyPrefix: 'u',
            label: 'LET u =',
            options: r.uOptions,
            picked: _none ? null : _u,
            truth: answered && !r.noSub ? r.uAnswer : null,
            dimmed: _none,
            onPick: answered
                ? null
                : (i) => setState(() {
                    _u = i;
                    _none = false;
                  }),
          ),
          const SizedBox(height: 14),
          _OptionRow(
            keyPrefix: 'du',
            label: 'THEN du =',
            options: r.duOptions,
            picked: _none ? null : _du,
            truth: answered && !r.noSub ? r.duAnswer : null,
            dimmed: _none,
            onPick: answered
                ? null
                : (i) => setState(() {
                    _du = i;
                    _none = false;
                  }),
          ),
          const SizedBox(height: 14),
          _NoneButton(
            selected: _none,
            locked: answered,
            isTruth: r.noSub,
            onTap: answered
                ? null
                : () => setState(() {
                    _none = true;
                    _u = null;
                    _du = null;
                  }),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _verdict(r),
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.keyPrefix,
    required this.label,
    required this.options,
    required this.picked,
    required this.truth,
    required this.dimmed,
    required this.onPick,
  });

  /// So a test (and a screenshot) can name one chip out of the two rows.
  final String keyPrefix;
  final String label;
  final List<String> options;
  final int? picked;

  /// Null while the round is live.
  final int? truth;

  /// Grayed while the student is saying no substitution fits.
  final bool dimmed;
  final void Function(int)? onPick;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.4 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.overline(color: AppColors.ink2)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Chip(
                    key: ValueKey('$keyPrefix-$i'),
                    latex: options[i],
                    selected: picked == i,
                    locked: truth != null,
                    isTruth: truth == i,
                    onTap: onPick == null ? null : () => onPick!(i),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.latex,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String latex;
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
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Center(child: MathBlock(latex, fontSize: 15)),
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
            'No substitution fits this one',
            style: AppTheme.heading(size: 14.5),
          ),
        ),
      ),
    );
  }
}
