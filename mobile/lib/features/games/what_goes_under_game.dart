import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'interval_figures.dart';
import 'lesson_brief.dart';

/// What Goes Under — the first item for `confidence-intervals-estimation`.
///
/// The lesson prints a warning in bold: the margin is z times sigma over the
/// ROOT of n, not over n. It is a warning about one symbol, and on paper both
/// versions look equally reasonable. Drawn to scale they do not: dividing by n
/// collapses the interval to a sliver, and forgetting to divide at all blows it
/// out past anything a report would ever carry.
///
/// So one piece of the formula is missing and the interval on screen redraws
/// as each candidate is tried. The answer is the one whose picture is a
/// confidence interval rather than a rounding error or a shrug.
class WhatGoesUnderGame extends StatefulWidget {
  const WhatGoesUnderGame({super.key});

  @override
  State<WhatGoesUnderGame> createState() => _WhatGoesUnderGameState();
}

/// Which piece of the formula the round has taken out.
enum Blank { denominator, multiplier }

@immutable
class UnderRound {
  const UnderRound({
    required this.subject,
    required this.given,
    required this.blank,
    required this.mean,
    required this.sigma,
    required this.n,
    required this.z,
    required this.options,
    required this.names,
    required this.answer,
    required this.unit,
    required this.why,
    required this.source,
  });

  final String subject;

  /// What the problem handed over, in the lesson's own notation.
  final String given;
  final Blank blank;
  final double mean;
  final double sigma;
  final int n;

  /// The multiplier the round is actually working at.
  final double z;

  /// What is on offer for the missing piece, written as it reads.
  final List<String> options;

  /// The same three, in words, because the picture labels its bands in plain
  /// text and a band nobody can name teaches nothing.
  final List<String> names;
  final int answer;
  final String unit;
  final String why;
  final String source;
}

const underRounds = <UnderRound>[
  UnderRound(
    subject: 'liquid limit on 25 soil samples',
    given: r'\bar{x} = 42\%,\ \sigma = 5\%,\ n = 25,\ z_{\alpha/2} = 1.960',
    blank: Blank.denominator,
    mean: 42,
    sigma: 5,
    n: 25,
    z: 1.96,
    options: [r'n', r'\sqrt{n}', r'1'],
    names: ['over n', 'over root n', 'no divide'],
    answer: 1,
    unit: 'x bar',
    why:
        'The root of twenty five is five, so the standard error is one and the '
        'margin is about two. Dividing by twenty five instead gives an interval '
        'a fifth of a percent wide, which no soil lab has ever reported.',
    source: 'stat-ci-q1',
  ),
  UnderRound(
    subject: 'the same soil samples, reported at three confidence levels',
    given: r'\bar{x} = 42\%,\ \sigma = 5\%,\ n = 25,\ \text{95\% confidence}',
    blank: Blank.multiplier,
    mean: 42,
    sigma: 5,
    n: 25,
    z: 1.96,
    options: [r'1.645', r'1.960', r'2.576'],
    names: ['1.645', '1.960', '2.576'],
    answer: 1,
    unit: 'x bar',
    why:
        'Ninety five percent is the one worth knowing by heart, and the other '
        'two are in the handbook. More confidence costs width: every one of '
        'these is a real answer to a differently worded question.',
    source: 'stat-ci-q1',
  ),
  UnderRound(
    subject: 'compressive strength on 9 cylinders',
    given: r'\bar{x} = 30,\ \sigma = 6,\ n = 9,\ z_{\alpha/2} = 1.960',
    blank: Blank.denominator,
    mean: 30,
    sigma: 6,
    n: 9,
    z: 1.96,
    options: [r'\sqrt{n}', r'1', r'n'],
    names: ['over root n', 'no divide', 'over n'],
    answer: 0,
    unit: 'x bar',
    why:
        'Three and nine are close enough that the wrong one looks plausible on '
        'paper. On the picture it is the difference between an interval you '
        'would report and one that claims more precision than nine cylinders '
        'can buy.',
    source: 'stat-ci-q1',
  ),
  UnderRound(
    subject: 'a survey reported at 99% confidence',
    given: r'\bar{x} = 150,\ \sigma = 20,\ n = 100,\ \text{99\% confidence}',
    blank: Blank.multiplier,
    mean: 150,
    sigma: 20,
    n: 100,
    z: 2.576,
    options: [r'2.576', r'1.960', r'1.645'],
    names: ['2.576', '1.960', '1.645'],
    answer: 0,
    unit: 'x bar',
    why:
        'Ninety nine percent is the widest of the three, because being surer '
        'means claiming less. Reaching for 1.960 out of habit reports an '
        'interval narrower than the confidence level it is labeled with.',
    source: 'stat-ci-q1',
  ),
  UnderRound(
    subject: 'a small set of 4 field tests',
    given: r'\bar{x} = 60,\ \sigma = 8,\ n = 4,\ z_{\alpha/2} = 1.960',
    blank: Blank.denominator,
    mean: 60,
    sigma: 8,
    n: 4,
    z: 1.96,
    options: [r'1', r'n', r'\sqrt{n}'],
    names: ['no divide', 'over n', 'over root n'],
    answer: 2,
    unit: 'x bar',
    why:
        'Four samples buy a factor of two, not a factor of four. That is the '
        'whole reason the root is there: the interval improves with the root '
        'of the effort, not with the effort.',
    source: 'stat-ci-q1',
  ),
  UnderRound(
    subject: 'a routine check reported at 90% confidence',
    given: r'\bar{x} = 80,\ \sigma = 12,\ n = 16,\ \text{90\% confidence}',
    blank: Blank.multiplier,
    mean: 80,
    sigma: 12,
    n: 16,
    z: 1.645,
    options: [r'1.960', r'2.576', r'1.645'],
    names: ['1.960', '2.576', '1.645'],
    answer: 2,
    unit: 'x bar',
    why:
        'Ninety percent is the narrowest of the three, and it is narrow because '
        'it is admitting a bigger chance of being wrong. Width and confidence '
        'move together, always.',
    source: 'stat-ci-q1',
  ),
];

class _WhatGoesUnderGameState extends State<WhatGoesUnderGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-goes-under',
    chapterId: 'statistics',
    total: underRounds.length,
    sourceProblemIdOf: (round) => underRounds[round].source,
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

  UnderRound get _round => underRounds[_session.round];

  /// The half-width the interval takes if [option] is dropped into the blank.
  static double marginWith(UnderRound r, int option) {
    if (r.blank == Blank.denominator) {
      final under = switch (r.options[option]) {
        r'\sqrt{n}' => math.sqrt(r.n.toDouble()),
        r'n' => r.n.toDouble(),
        _ => 1.0,
      };
      return r.z * r.sigma / under;
    }
    return double.parse(r.options[option]) * r.sigma / math.sqrt(r.n);
  }

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Goes Under',
        closing:
            'The margin is the multiplier times sigma over the ROOT of n. The '
            'root is what makes samples expensive, and the multiplier is what '
            'makes confidence expensive. Both show up as width.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final widest = [
      for (var i = 0; i < r.options.length; i++) marginWith(r, i),
    ].reduce((a, b) => a > b ? a : b);

    return BoardShell(
      session: _session,
      brief: marginOfErrorBrief,
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
            r.blank == Blank.denominator
                ? 'WHAT GOES UNDER SIGMA'
                : 'WHICH MULTIPLIER',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                MathBlock(r.given, fontSize: 13),
                const SizedBox(height: 10),
                _Skeleton(
                  blank: r.blank,
                  filled: _picked == null ? null : r.options[_picked!],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: IntervalPainter(
                    center: r.mean,
                    widest: widest * 1.12,
                    unit: r.unit,
                    bands: [
                      // All three, always. The widths are the argument, and
                      // seeing them side by side is what makes the wrong
                      // denominator look like the wrong denominator.
                      for (var i = 0; i < r.options.length; i++)
                        Band(
                          margin: marginWith(r, i),
                          label: r.names[i],
                          tone: answered
                              ? (i == r.answer
                                    ? BandTone.truth
                                    : (i == _picked
                                          ? BandTone.wrong
                                          : BandTone.before))
                              : (i == _picked
                                    ? BandTone.live
                                    : BandTone.before),
                        ),
                    ],
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < r.options.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _PieceButton(
                    key: ValueKey('piece-$i'),
                    latex: r.options[i],
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE PIECE' : 'LOOK AT THE WIDTH',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

/// The formula with a hole in it, filling in as a candidate is tried.
class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.blank, required this.filled});

  final Blank blank;
  final String? filled;

  @override
  Widget build(BuildContext context) {
    final piece = filled ?? r'\square';
    final latex = blank == Blank.denominator
        ? '\\bar{x} \\pm z_{\\alpha/2}\\,\\frac{\\sigma}{$piece}'
        : '\\bar{x} \\pm $piece\\,\\frac{\\sigma}{\\sqrt{n}}';
    return MathBlock(latex, fontSize: 17);
  }
}

class _PieceButton extends StatelessWidget {
  const _PieceButton({
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
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Center(widthFactor: 1, child: MathBlock(latex, fontSize: 16)),
        ),
      ),
    );
  }
}
