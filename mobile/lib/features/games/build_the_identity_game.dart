import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Build the Identity — the third item for `unit-circle-trig-identities`.
///
/// Assembled from chips rather than chosen from a list, which is a way of
/// answering nothing else in the app has needed. Recognising the right
/// identity in a list of four is not the same as being able to produce it, and
/// the lesson's headline trap is a student who "remembers" that sin 2θ is
/// twice sin θ. Pick from a list and that trap is a coin flip; build it from
/// parts and it is not.
class BuildTheIdentityGame extends StatefulWidget {
  const BuildTheIdentityGame({super.key});

  @override
  State<BuildTheIdentityGame> createState() => _BuildTheIdentityGameState();
}

@immutable
class Identity {
  const Identity({
    required this.left,
    required this.slots,
    required this.chips,
    required this.why,
    required this.source,
  });

  /// The left-hand side, already written.
  final String left;

  /// The right-hand side in order, one chip per slot.
  final List<String> slots;

  /// Everything on offer, correct parts and distractors together.
  final List<String> chips;

  final String why;
  final String source;
}

const identities = <Identity>[
  Identity(
    left: r'\sin^2\theta + \cos^2\theta',
    slots: ['1'],
    chips: ['1', '0', r'2\sin\theta', r'\sin 2\theta'],
    why:
        'The Pythagorean identity. Know this one cold: it is the one the '
        'lesson says to memorize and the one every other step leans on.',
    source: 'math-uci-q2',
  ),
  Identity(
    left: r'\sin 2\theta',
    slots: ['2', r'\sin\theta', r'\cos\theta'],
    chips: [
      '2',
      r'\sin\theta',
      r'\cos\theta',
      r'\sin^2\theta',
      '-',
      r'\cos^2\theta',
    ],
    why:
        'Two, sine, cosine. Doubling the angle is not doubling the sine: it '
        'needs BOTH functions, and the 2 in front is the part most often '
        'dropped.',
    source: 'math-uci-q3',
  ),
  Identity(
    left: r'\cos 2\theta',
    slots: [r'\cos^2\theta', '-', r'\sin^2\theta'],
    chips: [r'\cos^2\theta', '-', r'\sin^2\theta', '+', '2', r'\sin\theta'],
    why:
        'Cosine squared minus sine squared, in that order. Swap them and you '
        'have the negative of the right answer.',
    source: 'math-uci-q3',
  ),
  Identity(
    left: r'\cos^2\theta',
    slots: ['1', '-', r'\sin^2\theta'],
    chips: ['1', '-', r'\sin^2\theta', '+', r'\cos^2\theta', r'\sin\theta'],
    why:
        'The Pythagorean identity rearranged. This is the move that turns a '
        'known sine into a cosine, up to the sign the quadrant decides.',
    source: 'math-uci-q2',
  ),
  Identity(
    left: r'\sin\theta',
    slots: [r'\frac{\text{opp}}{\text{hyp}}'],
    chips: [
      r'\frac{\text{opp}}{\text{hyp}}',
      r'\frac{\text{adj}}{\text{hyp}}',
      r'\frac{\text{opp}}{\text{adj}}',
    ],
    why:
        'On the unit circle the hypotenuse is 1, which is exactly why the '
        'y-coordinate IS the sine.',
    source: 'math-uci-q1',
  ),
  Identity(
    left: r'\sin 2\theta \text{ when } \sin\theta = \tfrac{5}{13}',
    slots: ['2', r'\tfrac{5}{13}', r'\tfrac{12}{13}'],
    chips: [
      '2',
      r'\tfrac{5}{13}',
      r'\tfrac{12}{13}',
      r'\tfrac{10}{13}',
      r'\tfrac{25}{169}',
    ],
    why:
        'Build the shape, do not work it out. The missing cosine comes from '
        'the Pythagorean identity, and then it is two times sine times '
        'cosine. Multiplying it through is desk work.',
    source: 'math-uci-q3',
  ),
];

class _BuildTheIdentityGameState extends State<BuildTheIdentityGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'build-the-identity',
    chapterId: 'mathematics',
    total: identities.length,
    sourceProblemIdOf: (round) => identities[round].source,
  )..addListener(_onSession);

  /// One entry per slot: the chip index placed there, or null.
  List<int?> _placed = [];
  int _forRound = -1;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Identity get _round => identities[_session.round];

  void _syncSlots() {
    if (_forRound == _session.round) return;
    _forRound = _session.round;
    _placed = List<int?>.filled(_round.slots.length, null);
  }

  void _tapChip(int chipIndex) {
    if (_placed.contains(chipIndex)) return;
    final next = _placed.indexOf(null);
    if (next == -1) return;
    setState(() => _placed[next] = chipIndex);
  }

  void _clearSlot(int slot) => setState(() => _placed[slot] = null);

  bool get _full => !_placed.contains(null);

  bool get _isRight {
    for (var i = 0; i < _round.slots.length; i++) {
      final chip = _placed[i];
      if (chip == null || _round.chips[chip] != _round.slots[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Build the Identity',
        closing:
            'Producing an identity is a different thing from recognising '
            'one. Putting numbers through it is desk work; knowing its shape '
            'is what you carry into the exam.',
      );
    }

    _syncSlots();
    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: identitiesBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              _forRound = -1;
              _session.next();
            }
          : (!_full
                ? null
                : () => _session.submit(ok: _isRight, context: context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUILD THE RIGHT-HAND SIDE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the parts, in order. Tap one you have placed to take it back.',
            style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.ink2),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                MathBlock(r.left, fontSize: 20),
                const SizedBox(height: 12),
                Text('=', style: AppTheme.heading(size: 18)),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _placed.length; i++)
                      _Slot(
                        latex: _placed[i] == null ? null : r.chips[_placed[i]!],
                        locked: answered,
                        correct: answered
                            ? (_placed[i] != null &&
                                  r.chips[_placed[i]!] == r.slots[i])
                            : null,
                        onTap: answered ? null : () => _clearSlot(i),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('PARTS', style: AppTheme.overline()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < r.chips.length; i++)
                _Chip(
                  latex: r.chips[i],
                  used: _placed.contains(i),
                  onTap: answered ? null : () => _tapChip(i),
                ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 18),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT QUITE',
              body: r.why,
            ),
            if (!_session.correct!) ...[
              const SizedBox(height: 12),
              Center(
                child: MathBlock(
                  '${r.left} = ${r.slots.join(' ')}',
                  fontSize: 19,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.latex,
    required this.locked,
    required this.correct,
    required this.onTap,
  });

  final String? latex;
  final bool locked;
  final bool? correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = correct == null
        ? (latex == null ? AppColors.line : AppColors.ember)
        : (correct! ? AppColors.forest : AppColors.error);

    return GestureDetector(
      onTap: latex == null ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 74,
          maxWidth: 150,
          minHeight: 56,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: latex == null ? AppColors.cream : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: border,
            width: latex == null ? 1.5 : 2,
            style: latex == null ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: latex == null
            ? Text(
                '?',
                style: AppTheme.heading(size: 17, color: AppColors.ink3),
              )
            : MathBlock(latex!, fontSize: 17),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.latex, required this.used, required this.onTap});

  final String latex;
  final bool used;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: used ? 0.3 : 1,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: used ? null : onTap,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 68,
              maxWidth: 150,
              minHeight: 54,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: MathBlock(latex, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
