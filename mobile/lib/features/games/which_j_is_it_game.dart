import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'torsion_figures.dart';

/// Which J Is It — the first item for `torsion`.
///
/// Every problem in this lesson is the same formula and every named trap is an
/// ingredient put in wrong. Using the area moment instead of the polar one
/// doubles the stress, since I is half of J and it sits on the bottom. Subtracting the diameters before raising them to the
/// fourth instead of after gives a J that is not a J at all. And a circular
/// formula on a section that is not circular is not an approximation, it is
/// simply the wrong equation.
///
/// So nothing is computed. The section is drawn and the answer is which
/// expression belongs on the bottom of tau equals T c over J.
class WhichJIsItGame extends StatefulWidget {
  const WhichJIsItGame({super.key});

  @override
  State<WhichJIsItGame> createState() => _WhichJIsItGameState();
}

@immutable
class JRound {
  const JRound({
    required this.subject,
    required this.setting,
    required this.shaft,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
    this.circular = true,
  });

  final String subject;
  final String setting;
  final Shaft shaft;

  /// The candidate expressions, as LaTeX.
  final List<String> options;

  /// Which one is right. Minus one when none of them is, which happens the
  /// moment the section stops being round.
  final int answer;

  final String why;
  final String source;

  /// False when the section is not circular, and none of these formulas
  /// applies at all.
  final bool circular;
}

const jRounds = <JRound>[
  JRound(
    subject: 'a solid shaft',
    setting:
        'A solid round shaft, fifty millimeters across. Which expression goes '
        'underneath?',
    shaft: Shaft(outerD: 50),
    options: [
      r'\dfrac{\pi d^4}{64}',
      r'\dfrac{\pi d^4}{32}',
      r'\dfrac{\pi d^2}{4}',
    ],
    answer: 1,
    why:
        'Pi d to the fourth over THIRTY TWO. The one over sixty four is the '
        'area moment I, which is exactly half of it. It sits underneath, so '
        'halving it DOUBLES the stress you report, and this problem names that '
        'swap as its own trap. J is twice I for anything round. The third is '
        'just the area of the circle.',
    source: 'mm-tor-q1',
  ),
  JRound(
    subject: 'the same shaft, sized by radius',
    setting:
        'The same solid shaft, but this time the drawing gives you the radius '
        'rather than the diameter.',
    shaft: Shaft(outerD: 50),
    options: [
      r'\dfrac{\pi r^4}{2}',
      r'\dfrac{\pi r^4}{4}',
      r'\dfrac{\pi r^4}{32}',
    ],
    answer: 0,
    why:
        'Pi r to the fourth over TWO, which is the same number as pi d to the '
        'fourth over thirty two written the other way. Over four is the area '
        'moment again. Over thirty two is what you get by swapping r into the '
        'diameter formula without changing the divisor, and it is out by a '
        'factor of sixteen.',
    source: 'mm-tor-q1',
  ),
  JRound(
    subject: 'a shaft bored through',
    setting:
        'A hollow shaft, eighty millimeters outside and sixty inside. This is '
        'the lesson\'s hardest problem.',
    shaft: Shaft(outerD: 80, innerD: 60),
    options: [
      r'\dfrac{\pi (d_o - d_i)^4}{32}',
      r'\dfrac{\pi (d_o^4 - d_i^4)}{32}',
      r'\dfrac{\pi (d_o^2 - d_i^2)}{32}',
    ],
    answer: 1,
    why:
        'Raise each diameter to the fourth and THEN subtract. Subtracting '
        'first and raising afterwards gives twenty to the fourth, which is a '
        'fortieth of the truth and is named as a trap. The reason it works at '
        'all is that a hole is just a negative area, and its J comes off the '
        'solid shaft\'s the same way.',
    source: 'mm-tor-q3',
  ),
  JRound(
    subject: 'the hole forgotten',
    setting:
        'The same hollow shaft. One of these is what you get by treating it as '
        'solid, which the lesson names as the way to overestimate what it can '
        'carry.',
    shaft: Shaft(outerD: 80, innerD: 60),
    options: [
      r'\dfrac{\pi d_o^4}{32}',
      r'\dfrac{\pi (d_o^4 - d_i^4)}{32}',
      r'\dfrac{\pi d_i^4}{32}',
    ],
    answer: 1,
    why:
        'The same expression as the round before, and the first option is the '
        'trap: pretending the bore is not there. It gives a J about a third '
        'too big, so the shaft looks able to carry a third more torque than it '
        'really can, and nothing in the arithmetic afterwards will tell you.',
    source: 'mm-tor-q3',
  ),
  JRound(
    subject: 'a thin tube',
    setting:
        'A tube with a wall only a few millimeters thick. The exact expression '
        'still works here; the question is which one it is.',
    shaft: Shaft(outerD: 90, innerD: 78),
    options: [
      r'\dfrac{\pi (d_o^4 - d_i^4)}{32}',
      r'\dfrac{\pi d_o^4}{32}',
      r'2\pi r_m^3 t',
    ],
    answer: 0,
    why:
        'The same exact expression, because a thin wall is not a different '
        'kind of section, only a thinner one. The last option is the thin '
        'walled approximation, which is close here and is the sensible thing '
        'to use when a problem gives you a wall thickness rather than two '
        'diameters. It is an approximation and the first is not.',
    source: 'mm-tor-q3',
  ),
  JRound(
    subject: 'a square bar',
    setting:
        'A solid bar of square section, being twisted. Which of these gives '
        'its torsional resistance?',
    shaft: Shaft(outerD: 60),
    circular: false,
    options: [
      r'\dfrac{\pi d^4}{32}',
      r'\dfrac{\pi d^4}{64}',
      r'\dfrac{b h^3}{12}',
    ],
    answer: -1,
    why:
        'None of them. Every formula in this lesson is derived for a round '
        'section, where a flat cut across the shaft stays flat as it twists. A '
        'square bar warps out of plane instead, and it needs its own '
        'coefficient from a table. Reaching for pi d to the fourth over thirty '
        'two because the section is a bar is the mistake worth never making.',
    source: 'mm-tor-q1',
  ),
];

class _WhichJIsItGameState extends State<WhichJIsItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-j-is-it',
    chapterId: 'mechanics-materials',
    total: jRounds.length,
    sourceProblemIdOf: (round) => jRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  JRound get _round => jRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which J Is It',
        closing:
            'J is the POLAR moment and it is twice the area moment, so pi d to '
            'the fourth over thirty two and never over sixty four. A bore '
            'comes off as its own fourth power, not by subtracting diameters '
            'first. And none of it applies to a section that is not round: a '
            'square bar warps, and needs a table.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: polarJBrief,
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
            'WHICH ONE GOES UNDER Tc',
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 175,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: r.circular
                      ? ShaftPainter(shaft: r.shaft, markC: answered)
                      : const _SquareBarPainter(),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _JButton(
              key: ValueKey('j-$i'),
              latex: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          _NoneRow(
            selected: _picked == -1,
            locked: answered,
            isTruth: r.answer == -1,
            onTap: answered ? null : () => setState(() => _picked = -1),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// A square bar in section, for the round where none of the round-shaft
/// formulas applies.
class _SquareBarPainter extends CustomPainter {
  const _SquareBarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height) * 0.52;
    final box = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.46),
      width: side,
      height: side,
    );
    canvas.drawRect(box, Paint()..color = AppColors.sunbeamBg);
    canvas.drawRect(
      box,
      Paint()
        ..color = AppColors.charcoal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    final tp = TextPainter(
      text: TextSpan(
          text: 'square section',
          style: AppTheme.mono(size: 11, color: AppColors.ink3)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, box.bottom + 10));
  }

  @override
  bool shouldRepaint(_SquareBarPainter old) => false;
}

class _JButton extends StatelessWidget {
  const _JButton({
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
          width: double.infinity,
          height: 66,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: MathText(
            '\$$latex\$',
            style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}

class _NoneRow extends StatelessWidget {
  const _NoneRow({
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
      key: const ValueKey('j-none'),
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: const Text(
            'None of them fits this section',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
