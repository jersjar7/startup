import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Balance Both Sides — the third item for `circles-conics`.
///
/// Completing the square, with the equals sign enforced. The lesson calls the
/// conversion from general form to standard form the key skill on this topic,
/// and names the failure exactly: adding the completing value on one side and
/// not the other. So the item has slots on BOTH sides, and filling only the
/// left is a wrong answer rather than an unfinished one.
class BalanceBothSidesGame extends StatefulWidget {
  const BalanceBothSidesGame({super.key});

  @override
  State<BalanceBothSidesGame> createState() => _BalanceBothSidesGameState();
}

@immutable
class Balance {
  const Balance({
    required this.left,
    required this.right,
    required this.slotsOnLeft,
    required this.answers,
    required this.chips,
    required this.why,
    required this.source,
  });

  /// Each half is a list of lines. A line is a piece of the equation and
  /// whether a blank follows it, so a blank always sits on the same row as the
  /// terms it belongs to rather than wrapping away from them.
  final List<(String, bool)> left;
  final List<(String, bool)> right;

  /// How many of the blanks belong to the left half.
  final int slotsOnLeft;

  /// What belongs in each blank, left to right.
  final List<String> answers;
  final List<String> chips;
  final String why;
  final String source;
}

const balances = <Balance>[
  Balance(
    left: [(r'x^2 - 10x \;+', true), (r'y^2 + 6y \;+', true)],
    right: [(r'-18 \;+', true), (r'+', true)],
    slotsOnLeft: 2,
    answers: ['25', '9', '25', '9'],
    chips: ['25', '9', '5', '3', '100', '36'],
    why:
        'Half of ten squared is 25, half of six squared is 9. Both have to '
        'appear on the right as well, or the equation you finish with is not '
        'the one you started with.',
    source: 'math-cc-q2',
  ),
  Balance(
    left: [(r'x^2 + 8x \;+', true)],
    right: [(r'-5 \;+', true)],
    slotsOnLeft: 1,
    answers: ['16', '16'],
    chips: ['16', '8', '4', '64'],
    why:
        'Half of eight is four, squared is 16, on both sides. Halving without '
        'squaring is the other half of this mistake.',
    source: 'math-cc-q2',
  ),
  Balance(
    left: [(r'y^2 - 14y \;+', true)],
    right: [(r'11 \;+', true)],
    slotsOnLeft: 1,
    answers: ['49', '49'],
    chips: ['49', '7', '14', '196'],
    why:
        'Half of fourteen is seven, squared is 49. The sign inside does not '
        'change what you add: squaring kills it.',
    source: 'math-cc-q2',
  ),
  Balance(
    left: [(r'x^2 - 6x \;+', true), (r'y^2 - 2y \;+', true)],
    right: [(r'-6 \;+', true), (r'+', true)],
    slotsOnLeft: 2,
    answers: ['9', '1', '9', '1'],
    chips: ['9', '1', '3', '36', '4'],
    why:
        'Nine and one, on both sides. The right-hand side becomes 4, which is '
        'r squared, so the radius is 2 rather than 4.',
    source: 'math-cc-q2',
  ),
  Balance(
    left: [(r'x^2 + 12x \;+', true)],
    right: [(r'-20 \;+', true)],
    slotsOnLeft: 1,
    answers: ['36', '36'],
    chips: ['36', '6', '12', '144'],
    why:
        'Half of twelve is six, squared is 36. The right becomes 16, a radius '
        'of 4.',
    source: 'math-cc-q2',
  ),
];

class _BalanceBothSidesGameState extends State<BalanceBothSidesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'balance-both-sides',
    chapterId: 'mathematics',
    total: balances.length,
    sourceProblemIdOf: (round) => balances[round].source,
  )..addListener(_onSession);

  List<String?> _filled = [];
  int _forRound = -1;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Balance get _round => balances[_session.round];

  void _sync() {
    if (_forRound == _session.round) return;
    _forRound = _session.round;
    _filled = List<String?>.filled(_round.answers.length, null);
  }

  void _place(String chip) {
    final next = _filled.indexOf(null);
    if (next == -1) return;
    setState(() => _filled[next] = chip);
  }

  void _clear(int slot) => setState(() => _filled[slot] = null);

  bool get _full => !_filled.contains(null);

  bool get _isRight {
    for (var i = 0; i < _round.answers.length; i++) {
      if (_filled[i] != _round.answers[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Balance Both Sides',
        closing:
            'Whatever you add to complete a square has to appear on both '
            'sides. Getting the number right and dropping it from the '
            'right-hand side gives a circle of the wrong size.',
      );
    }

    _sync();
    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: completeSquareBrief,
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
            'KEEP IT BALANCED',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete the square. Every blank has to be filled, on both sides '
            'of the equals.',
            style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.ink2),
          ),
          const SizedBox(height: 16),
          _Side(
            parts: r.left,
            slotOffset: 0,
            filled: _filled,
            answers: r.answers,
            revealed: answered,
            onClear: answered ? null : _clear,
          ),
          const SizedBox(height: 10),
          Center(child: Text('=', style: AppTheme.heading(size: 20))),
          const SizedBox(height: 10),
          _Side(
            parts: r.right,
            slotOffset: r.slotsOnLeft,
            filled: _filled,
            answers: r.answers,
            revealed: answered,
            onClear: answered ? null : _clear,
          ),
          const SizedBox(height: 18),
          Text('NUMBERS', style: AppTheme.overline()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final chip in r.chips)
                _NumberChip(
                  value: chip,
                  onTap: answered ? null : () => _place(chip),
                ),
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 18),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'BALANCED' : 'NOT BALANCED',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// One half of the line: its written parts, with a tappable blank wherever the
/// source text has a box.
class _Side extends StatelessWidget {
  const _Side({
    required this.parts,
    required this.slotOffset,
    required this.filled,
    required this.answers,
    required this.revealed,
    required this.onClear,
  });

  final List<(String, bool)> parts;
  final int slotOffset;
  final List<String?> filled;
  final List<String> answers;
  final bool revealed;
  final void Function(int slot)? onClear;

  @override
  Widget build(BuildContext context) {
    var slot = slotOffset;
    final rows = <Widget>[];

    for (final (latex, hasBlank) in parts) {
      final index = hasBlank ? slot++ : -1;
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: MathBlock(latex, fontSize: 18)),
            if (hasBlank) ...[
              const SizedBox(width: 10),
              _Blank(
                value: filled[index],
                correct: revealed ? filled[index] == answers[index] : null,
                onTap: onClear == null ? null : () => onClear!(index),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _Blank extends StatelessWidget {
  const _Blank({
    required this.value,
    required this.correct,
    required this.onTap,
  });

  final String? value;
  final bool? correct;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = correct == null
        ? (value == null ? AppColors.ink3 : AppColors.ember)
        : (correct! ? AppColors.forest : AppColors.error);

    return GestureDetector(
      onTap: value == null ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: value == null ? AppColors.cream : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 2),
        ),
        child: Text(
          value ?? '?',
          style: AppTheme.mono(
            size: 16,
            weight: FontWeight.w700,
            color: value == null ? AppColors.ink3 : AppColors.charcoal,
          ),
        ),
      ),
    );
  }
}

class _NumberChip extends StatelessWidget {
  const _NumberChip({required this.value, required this.onTap});

  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 62, minHeight: 52),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.line),
          ),
          child: Text(
            value,
            style: AppTheme.mono(size: 17, weight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
