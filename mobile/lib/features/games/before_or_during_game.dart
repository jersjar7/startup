import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'coupon_figures.dart';
import 'lesson_brief.dart';

/// Before or During — the first item for `stress-strain-material-behavior`.
///
/// Every formula on this page is a force or a stretch over one measurement,
/// and the lesson's whole trap list is about WHICH measurement: engineering
/// stress keeps dividing by the area the bar started with even after the bar
/// has thinned, engineering strain divides by the gauge length rather than
/// using the stretch as if it were already a strain, and true values are the
/// same forces and stretches held against what the bar measures right now.
/// The arithmetic is a desk job. Knowing what goes underneath is not, and it
/// is what the exam is really testing here.
class BeforeOrDuringGame extends StatefulWidget {
  const BeforeOrDuringGame({super.key});

  @override
  State<BeforeOrDuringGame> createState() => _BeforeOrDuringGameState();
}

@immutable
class DimRound {
  const DimRound({
    required this.subject,
    required this.asked,
    required this.coupon,
    required this.answer,
    required this.why,
    required this.source,
    this.formula,
  });

  final String subject;

  /// What is being worked out, in words, never with the symbol given away.
  final String asked;

  final Coupon coupon;
  final Dim answer;
  final String why;
  final String source;

  /// The definition being filled in, with the denominator left blank.
  final String? formula;
}

const dimRounds = <DimRound>[
  DimRound(
    subject: 'a bar pulled with sixty kilonewtons',
    asked:
        'Engineering stress is the force divided by an area. Tap the area it '
        'means.',
    coupon: Coupon(
      areaBefore: 150,
      lengthBefore: 50,
      stretch: 0.125,
      thinnedTo: 0.99,
    ),
    formula: r'$\sigma = \dfrac{F}{\;?\;}$',
    answer: Dim.areaBefore,
    why:
        'The area it started with. That is what makes it ENGINEERING stress: '
        'the force is held against the bar you put in the machine, not the '
        'bar you have at that instant. It is the one everybody quotes, '
        'because it is the one you can measure before the test rather than '
        'during it.',
    source: 'mat-ssm-q1',
  ),
  DimRound(
    subject: 'the same bar, now a tenth of a millimeter longer',
    asked:
        'Engineering strain is the stretch divided by a length. Tap the '
        'length it means.',
    coupon: Coupon(
      areaBefore: 150,
      lengthBefore: 50,
      stretch: 0.125,
      thinnedTo: 0.99,
    ),
    formula: r'$\varepsilon = \dfrac{\Delta L}{\;?\;}$',
    answer: Dim.lengthBefore,
    why:
        'The gauge length it started with. Strain is a stretch per unit of '
        'original length, which is why it has no units at all: millimeters '
        'over millimeters cancel. The same tenth of a millimeter is a large '
        'strain in a short coupon and a small one in a long bar, and dividing '
        'is the only thing that tells them apart.',
    source: 'mat-ssm-q2',
  ),
  DimRound(
    subject: 'necking has started',
    asked:
        'The bar has drawn down to a waist. True stress is the force divided '
        'by an area. Tap the area it means.',
    coupon: Coupon(
      areaBefore: 200,
      lengthBefore: 60,
      stretch: 9,
      thinnedTo: 0.7,
    ),
    formula: r'$\sigma_T = \dfrac{F}{\;?\;}$',
    answer: Dim.areaNow,
    why:
        'The area it has right now, at the waist. That is the whole '
        'difference between the two stresses: the same force, the same '
        'moment, one held against the bar as it was and one against the bar '
        'as it is. Since the waist is smaller, true stress is the higher of '
        'the two, and by more and more as the waist draws in.',
    source: 'mat-ssm-q3',
  ),
  DimRound(
    subject: 'the same necked bar, on the test report',
    asked:
        'The report wants engineering stress at this instant. The waist is '
        'down to seven tenths of what it was. Tap the area the report uses.',
    coupon: Coupon(
      areaBefore: 200,
      lengthBefore: 60,
      stretch: 9,
      thinnedTo: 0.7,
    ),
    formula: r'$\sigma = \dfrac{F}{\;?\;}$',
    answer: Dim.areaBefore,
    why:
        'Still the area it started with, and this is the round worth '
        'remembering. Engineering stress never changes its divisor, however '
        'thin the bar gets. That is exactly why the curve turns over and '
        'comes down after the top: the force is falling while the divisor is '
        'held fixed. The steel is not getting weaker.',
    source: 'mat-ssm-q1',
  ),
  DimRound(
    subject: 'a strain written down wrong',
    asked:
        'Someone read the stretch off the machine and wrote the strain down '
        'as 0.125. Tap what they forgot to divide by.',
    coupon: Coupon(
      areaBefore: 150,
      lengthBefore: 50,
      stretch: 0.125,
      thinnedTo: 0.99,
    ),
    answer: Dim.lengthBefore,
    why:
        'The gauge length. Their strain is fifty times too big, so the '
        'modulus they get from it comes out fifty times too small: about 1.4 '
        'gigapascals for a metal that is really 70. A strain is a bare '
        'number. If what you wrote down has millimeters after it, you have '
        'written down a stretch.',
    source: 'mat-ssm-q2',
  ),
  DimRound(
    subject: 'the true strain',
    asked:
        'True strain is the natural log of one length over the other. Tap '
        'the one on TOP.',
    coupon: Coupon(
      areaBefore: 200,
      lengthBefore: 60,
      stretch: 9,
      thinnedTo: 0.7,
    ),
    formula: r'$\varepsilon_T = \ln\dfrac{\;?\;}{L_0}$',
    answer: Dim.lengthNow,
    why:
        'The length it has now, over the length it started with, which is the '
        'same thing the lesson writes as the log of one plus the engineering '
        'strain. Both forms say it: the bar is measured against itself as it '
        'goes, rather than once at the start. The two agree while the numbers '
        'are small and part company once the stretching is serious.',
    source: 'mat-ssm-q3',
  ),
];

class _BeforeOrDuringGameState extends State<BeforeOrDuringGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'before-or-during',
    chapterId: 'materials',
    total: dimRounds.length,
    sourceProblemIdOf: (round) => dimRounds[round].source,
  )..addListener(_onSession);

  Dim? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DimRound get _round => dimRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Before or During',
        closing:
            'Engineering values divide by the bar you started with, every '
            'time, however thin it gets. True values divide by the bar you '
            'have at that instant. And a strain is always a length over a '
            'length, so if yours has millimeters after it, it is a stretch '
            'and not a strain yet.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: underneathBrief,
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
            'TAP THE MEASUREMENT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.asked,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          if (r.formula != null) ...[
            const SizedBox(height: 12),
            Center(
              child: MathText(
                r.formula!,
                style: const TextStyle(fontSize: 18, color: AppColors.charcoal),
              ),
            ),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 250);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit = CouponPainter.nearest(
                          size,
                          details.localPosition,
                        );
                        if (hit != null) setState(() => _picked = hit);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: CouponPainter(
                        coupon: r.coupon,
                        picked: _picked,
                        answer: r.answer,
                        locked: answered,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'the stretch is drawn far bigger than it is, so it can be seen',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct!
                  ? 'THAT IS WHAT GOES UNDERNEATH'
                  : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
