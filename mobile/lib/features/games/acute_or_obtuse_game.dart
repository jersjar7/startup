import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Acute or Obtuse — the third item for `law-of-sines-cosines`.
///
/// The lesson's hardest trap is not arithmetic: it is not trusting a negative
/// cosine and "correcting" it by subtracting from 180. Here the number is
/// handed over already worked out, or the three sides are compared, and the
/// student says what kind of angle it is. Nothing to compute, everything to
/// decide.
class AcuteOrObtuseGame extends StatefulWidget {
  const AcuteOrObtuseGame({super.key});

  @override
  State<AcuteOrObtuseGame> createState() => _AcuteOrObtuseGameState();
}

enum AngleKind { acute, right, obtuse }

extension AngleKindName on AngleKind {
  String get label => switch (this) {
    AngleKind.acute => 'Acute',
    AngleKind.right => 'Right',
    AngleKind.obtuse => 'Obtuse',
  };

  String get detail => switch (this) {
    AngleKind.acute => 'under 90°',
    AngleKind.right => 'exactly 90°',
    AngleKind.obtuse => 'over 90°',
  };
}

@immutable
class Verdict {
  const Verdict({
    required this.given,
    required this.latex,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// What the student is handed, in words.
  final String given;
  final String latex;
  final AngleKind answer;
  final String why;
  final String source;
}

const verdicts = <Verdict>[
  Verdict(
    given:
        'You worked the rearranged Law of Cosines and this came out. What '
        'kind of angle is C?',
    latex: r'\cos C = -0.219',
    answer: AngleKind.obtuse,
    why:
        'A negative cosine means the angle is over 90 degrees. Take the '
        'inverse cosine and it hands you the obtuse angle directly. There is '
        'nothing to subtract from 180.',
    source: 'math-lsc-q3',
  ),
  Verdict(
    given: 'Same setup, different triangle.',
    latex: r'\cos C = 0.43',
    answer: AngleKind.acute,
    why: 'A positive cosine is an angle under 90 degrees.',
    source: 'math-lsc-q3',
  ),
  Verdict(
    given:
        'The numerator of the rearranged formula came out as this, with a '
        'positive denominator.',
    latex: r'a^2 + b^2 - c^2 = 0',
    answer: AngleKind.right,
    why:
        'Zero on top means the cosine is zero, which is exactly 90 degrees. '
        'That is the Pythagorean theorem falling out of the Law of Cosines.',
    source: 'math-lsc-q3',
  ),
  Verdict(
    given:
        'A truss has sides 6, 8 and 11. What kind of angle sits opposite the '
        'longest side?',
    latex: r'11^2 \;>\; 6^2 + 8^2',
    answer: AngleKind.obtuse,
    why:
        'The longest side squared beats the other two put together, so the '
        'numerator goes negative and the angle is obtuse. You can see this '
        'before computing anything.',
    source: 'math-lsc-q3',
  ),
  Verdict(
    given: 'A triangle with sides 5, 12 and 13.',
    latex: r'13^2 \;=\; 5^2 + 12^2',
    answer: AngleKind.right,
    why:
        'The squares balance exactly, so the angle opposite the longest side '
        'is 90 degrees. This is a right triangle hiding in an oblique '
        'question.',
    source: 'math-lsc-q3',
  ),
  Verdict(
    given: 'A triangle with sides 7, 9 and 10.',
    latex: r'10^2 \;<\; 7^2 + 9^2',
    answer: AngleKind.acute,
    why:
        'Even the largest angle comes out under 90 degrees, so every angle in '
        'this triangle is acute.',
    source: 'math-lsc-q3',
  ),
];

class _AcuteOrObtuseGameState extends State<AcuteOrObtuseGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'acute-or-obtuse',
    chapterId: 'mathematics',
    total: verdicts.length,
    sourceProblemIdOf: (round) => verdicts[round].source,
  )..addListener(_onSession);

  AngleKind? _choice;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  Verdict get _round => verdicts[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Acute or Obtuse',
        closing:
            'A negative cosine is not a mistake, it is an obtuse angle. '
            'Inverse cosine already accounts for it, so nothing needs '
            'subtracting from 180.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: obtuseBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _choice = null);
              _session.next();
            }
          : (_choice == null
                ? null
                : () => _session.submit(
                    ok: _choice == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT KIND OF ANGLE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.given,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.line),
            ),
            child: Center(child: MathBlock(r.latex, fontSize: 22)),
          ),
          const SizedBox(height: 16),
          for (final kind in AngleKind.values) ...[
            _KindButton(
              kind: kind,
              selected: _choice == kind,
              locked: answered,
              isTruth: kind == r.answer,
              onTap: answered ? null : () => setState(() => _choice = kind),
            ),
            const SizedBox(height: 10),
          ],
          if (answered) ...[
            const SizedBox(height: 4),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'CORRECT' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _KindButton extends StatelessWidget {
  const _KindButton({
    required this.kind,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final AngleKind kind;
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Text(kind.label, style: AppTheme.heading(size: 17)),
              const SizedBox(width: 10),
              Text(
                kind.detail,
                style: AppTheme.mono(size: 12.5, color: AppColors.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
