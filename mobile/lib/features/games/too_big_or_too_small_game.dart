import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Too Big or Too Small — the second item for `flow-measurement`.
///
/// Nobody gets to check a meter calculation against the truth, so the only
/// defense is knowing which way each slip pushes the number. All of these
/// are named in the lesson's own three problems, and every one of them has a
/// direction that can be read straight off the formula: a coefficient below
/// one always brings the answer down, so leaving it out sends the answer up;
/// anything that shrinks the denominator under the root sends it up; the
/// missing 2 and the missing conversion send it down. And one of them, on a
/// level meter, does nothing at all.
class TooBigOrTooSmallGame extends StatefulWidget {
  const TooBigOrTooSmallGame({super.key});

  @override
  State<TooBigOrTooSmallGame> createState() => _TooBigOrTooSmallGameState();
}

/// Where the answer lands once the slip is in it.
enum Sits { tooBig, tooSmall, same }

extension SitsWords on Sits {
  String get plain => switch (this) {
        Sits.tooBig => 'Too big',
        Sits.tooSmall => 'Too small',
        Sits.same => 'No difference at all',
      };
}

@immutable
class SlipRound {
  const SlipRound({
    required this.subject,
    required this.setting,
    required this.formula,
    required this.belongs,
    required this.wrote,
    required this.right,
    required this.got,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// The formula the round is working in, and the one piece of it that went
  /// in wrong.
  final String formula;
  final String belongs;
  final String wrote;

  /// What the lesson's own working gives, and what this slip gives instead.
  final double right;
  final double got;

  final String why;
  final String source;

  /// Worked out from the two numbers, never declared beside them.
  Sits get answer {
    if ((got - right).abs() < right * 0.001) return Sits.same;
    return got > right ? Sits.tooBig : Sits.tooSmall;
  }
}

const slipRounds = <SlipRound>[
  SlipRound(
    subject: 'the coefficient left out',
    setting:
        'A venturi, worked correctly all the way through, except that the '
        'velocity coefficient of 0.98 never made it into the line.',
    formula: r'$Q = C_v A_2 \sqrt{\dfrac{2g h}{1 - (A_2/A_1)^2}}$',
    belongs: r'$C_v A_2$',
    wrote: r'$A_2$',
    right: 0.0711,
    got: 0.0726,
    why:
        'Too big, 0.0726 against 0.0711. Every one of these coefficients is '
        'below one, because they exist to knock the ideal formula down to '
        'what a real meter actually passes. Leave one out and you are '
        'quoting the ideal flow, which is always more than the pipe is '
        'really carrying.',
    source: 'fm-fme-q2',
  ),
  SlipRound(
    subject: 'the wrong coefficient',
    setting:
        'An orifice problem that gives a discharge coefficient of 0.62. The '
        '0.98 quoted in the lesson text went in instead.',
    formula: r'$Q = C A_0 \sqrt{\dfrac{2g h}{1 - (A_0/A_1)^2}}$',
    belongs: r'$C = 0.62$',
    wrote: r'$C = 0.98$',
    right: 0.00974,
    got: 0.0154,
    why:
        'Too big, and by more than half: 0.0154 against 0.00974. A sharp '
        'plate has two things going against it, the squeeze of the jet and '
        'the friction, and the discharge coefficient carries both. The 0.98 '
        'is only the friction part. Take whichever number the problem hands '
        'you and put it where the formula says.',
    source: 'fm-fme-q3',
  ),
  SlipRound(
    subject: 'the 2 gone from under the root',
    setting:
        'An orifice again, with the head and the areas all right, but g on '
        'its own where twice g belongs.',
    formula: r'$Q = C A_0 \sqrt{\dfrac{2g h}{1 - (A_0/A_1)^2}}$',
    belongs: r'$\sqrt{2gh}$',
    wrote: r'$\sqrt{gh}$',
    right: 0.00974,
    got: 0.00689,
    why:
        'Too small: 0.00689 against 0.00974, which is the root of a half, so '
        'about seven tenths. Losing a factor under a square root costs you '
        'less than losing it outside one, and that is exactly why this slip '
        'survives a sanity check: the answer is wrong and it still looks '
        'like a believable flow.',
    source: 'fm-fme-q3',
  ),
  SlipRound(
    subject: 'kilopascals left as they came',
    setting:
        'A Pitot tube reading a 25 kilopascal difference, put into the '
        'formula as 25.',
    formula: r'$v = \sqrt{\dfrac{2(P_0 - P_s)}{\rho}}$',
    belongs: r'$25{,}000 \text{ Pa}$',
    wrote: r'$25 \text{ kPa}$',
    right: 7.07,
    got: 0.224,
    why:
        'Too small, and wildly: 0.22 meters a second against 7.07. Under the '
        'root a thousand becomes about 32, so the answer comes out thirty '
        'times too small rather than a thousand. A tenth of a meter a second '
        'in a water main is not a believable number, and that is the check '
        'that catches this one.',
    source: 'fm-fme-q1',
  ),
  SlipRound(
    subject: 'the height terms dropped',
    setting:
        'A venturi lying level in the pipe. The two elevation terms were '
        'left out of the head.',
    formula: r'$h = \dfrac{P_1 - P_2}{\gamma} + z_1 - z_2$',
    belongs: r'$\dfrac{\Delta P}{\gamma} + z_1 - z_2$',
    wrote: r'$\dfrac{\Delta P}{\gamma}$',
    right: 0.0711,
    got: 0.0711,
    why:
        'No difference at all, and this is the one worth knowing. On a level '
        'meter the two tappings are at the same height, so z_1 minus z_2 is '
        'nothing and dropping it changes not a digit. The term earns its '
        'place in the formula for meters set on a slope, where it is the '
        'difference between the answer and a wrong one.',
    source: 'fm-fme-q2',
  ),
  SlipRound(
    subject: 'the area ratio not squared',
    setting:
        'A venturi with a 200 millimeter pipe and a 100 millimeter throat. '
        'The correction underneath went in as 1 minus a quarter.',
    formula: r'$1 - \left(\dfrac{A_2}{A_1}\right)^2$',
    belongs: r'$1 - 0.0625 = 0.9375$',
    wrote: r'$1 - 0.25 = 0.75$',
    right: 0.0711,
    got: 0.0795,
    why:
        'Too big: 0.0795 against 0.0711. The correction sits UNDER the line, '
        'so making it smaller makes the whole root bigger. What the term is '
        'doing is admitting that the water was already moving before it '
        'reached the throat, and squaring the ratio is what keeps that '
        'admission small.',
    source: 'fm-fme-q2',
  ),
];

class _TooBigOrTooSmallGameState extends State<TooBigOrTooSmallGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'too-big-or-too-small',
    chapterId: 'fluid-mechanics',
    total: slipRounds.length,
    sourceProblemIdOf: (round) => slipRounds[round].source,
  )..addListener(_onSession);

  Sits? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SlipRound get _round => slipRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Too Big or Too Small',
        closing:
            'A coefficient left out or set too high sends the answer up, and '
            'so does anything that shrinks the correction underneath, since '
            'it sits under the line. The missing 2 and the pressure left in '
            'kilopascals send it down. The elevation terms do nothing at all '
            'on a level meter, which is why they are so easy to forget on a '
            'sloped one.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: coefficientBrief,
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
            'WHERE DOES THE ANSWER LAND',
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
          const SizedBox(height: 14),
          Center(
            child: MathText(
              r.formula,
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          _Swap(belongs: r.belongs, wrote: r.wrote),
          const SizedBox(height: 14),
          for (final option in Sits.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHERE IT LANDS' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Swap extends StatelessWidget {
  const _Swap({required this.belongs, required this.wrote});

  final String belongs;
  final String wrote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('what belongs',
                    style: AppTheme.mono(size: 10.5, color: AppColors.ink3)),
                const SizedBox(height: 6),
                MathText(
                  belongs,
                  style:
                      const TextStyle(fontSize: 15, color: AppColors.charcoal),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.line),
          Expanded(
            child: Column(
              children: [
                Text('what went in',
                    style: AppTheme.mono(size: 10.5, color: AppColors.error)),
                const SizedBox(height: 6),
                MathText(
                  wrote,
                  style:
                      const TextStyle(fontSize: 15, color: AppColors.charcoal),
                ),
              ],
            ),
          ),
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
