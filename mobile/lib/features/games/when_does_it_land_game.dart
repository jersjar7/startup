import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'cash_flow_figures.dart';
import 'lesson_brief.dart';

/// When Does It Land — the fourth item for `equivalence-interest-factors`.
///
/// The other three items in this lesson pick factors, read rates and count
/// pieces, and all three of them assume the diagram underneath is drawn right.
/// This one is about the diagram. The lesson's convention warning is that
/// every payment lands at the END of its period unless the problem says
/// otherwise, and that the beginning of year three and the end of year two are
/// the same instant.
///
/// It is worth its own game because getting it wrong does not look like a
/// mistake. Every factor after it is chosen correctly and applied correctly to
/// a cash flow that is one period out, and the arithmetic is flawless.
class WhenDoesItLandGame extends StatefulWidget {
  const WhenDoesItLandGame({super.key});

  @override
  State<WhenDoesItLandGame> createState() => _WhenDoesItLandGameState();
}

@immutable
class MomentRound {
  const MomentRound({
    required this.subject,
    required this.setting,
    required this.moment,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Moment moment;
  final String why;
  final String source;

  /// Worked out from the convention, never declared beside the round.
  int get answer => moment.period;
}

const momentRounds = <MomentRound>[
  MomentRound(
    subject: 'the plain case',
    setting:
        'A contractor is paid a bonus at the END of year three. Tap the period '
        'it belongs on.',
    moment: Moment(year: 3, atEnd: true),
    why:
        'Period three. End of year three is period three, and this is the '
        'default the whole convention is built on: unless a problem says '
        'otherwise, everything lands at the end of its period. Every factor in '
        'the handbook is written expecting that.',
    source: 'econ-eif-q1',
  ),
  MomentRound(
    subject: 'the same year, the other end of it',
    setting:
        'A different contract pays its bonus at the BEGINNING of year three '
        'instead.',
    moment: Moment(year: 3, atEnd: false),
    why:
        'Period two. The beginning of year three and the end of year two are '
        'the same instant, and the diagram only has one mark for it. This is '
        'the whole warning in the lesson: the words moved by a year and the '
        'period moved by one, and a factor applied at period three would be '
        'discounting a year too far.',
    source: 'econ-eif-q1',
  ),
  MomentRound(
    subject: 'money changing hands today',
    setting: 'A deposit is made right now, before anything else happens.',
    moment: Moment(year: 1, atEnd: false),
    why:
        'Period zero. Today is period zero, and a present worth is simply a '
        'number sitting on that mark. Every P in every factor lives here, '
        'which is why moving a cash flow to period zero is the commonest thing '
        'you do in this chapter.',
    source: 'econ-eif-q1',
  ),
  MomentRound(
    subject: 'the first of a run of payments',
    setting:
        'A five year maintenance contract, paid annually, with the first '
        'payment falling due a year from today.',
    moment: Moment(year: 1, atEnd: true),
    why:
        'Period one. An ordinary annuity starts at the end of the first '
        'period, not today, and every uniform series factor in the handbook '
        'assumes exactly that. If the first payment were due today it would be '
        'an annuity due and would need handling separately.',
    source: 'econ-eif-q2',
  ),
  MomentRound(
    subject: 'where a gradient really starts',
    setting:
        'Maintenance is ten thousand in year one and rises by two thousand a '
        'year after that. Tap the period the FIRST two thousand of extra cost '
        'lands on.',
    moment: Moment(year: 2, atEnd: true),
    why:
        'Period two. A gradient is zero in the first period by definition, '
        'and the first step appears at the end of period two. The flat ten '
        'thousand runs from period one and the triangle starts a period later, '
        'which is why the two have to be handled as separate cash flows.',
    source: 'econ-eif-q3',
  ),
  MomentRound(
    subject: 'the same instant, said the other way',
    setting: 'A grant is received at the BEGINNING of year one.',
    moment: Moment(year: 1, atEnd: false),
    why:
        'Period zero, and it is the same mark as the deposit two rounds ago. '
        'The beginning of year one IS today. Two different sentences, one '
        'instant, one place on the diagram, and if you had drawn it before '
        'reaching for a factor you would never have doubted it.',
    source: 'econ-eif-q1',
  ),
];

class _WhenDoesItLandGameState extends State<WhenDoesItLandGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'when-does-it-land',
    chapterId: 'economics',
    total: momentRounds.length,
    sourceProblemIdOf: (round) => momentRounds[round].source,
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

  MomentRound get _round => momentRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'When Does It Land',
        closing:
            'Everything lands at the end of its period unless the problem says '
            'otherwise. The beginning of year n is the end of year n minus '
            'one, and today is period zero. Draw the diagram before you pick a '
            'factor, because a cash flow one period out is a mistake that '
            'leaves no trace in the arithmetic.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: periodBrief,
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
            'TAP THE PERIOD IT LANDS ON',
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
          _Timeline(
            picked: _picked,
            truth: r.answer,
            locked: answered,
            onTap: answered ? null : (p) => setState(() => _picked = p),
          ),
          const SizedBox(height: 8),
          Text(
            'the numbers under the line are periods, the labels are years',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE MARK' : 'A PERIOD OUT',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.picked,
    required this.truth,
    required this.locked,
    required this.onTap,
  });

  final int? picked;
  final int truth;
  final bool locked;
  final void Function(int)? onTap;

  static const _height = 190.0;
  static const _periods = 5;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: EngineeringGrid(
          minor: 18,
          major: 90,
          child: LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, _height);
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TimelinePainter(
                        periods: _periods,
                        picked: picked,
                        truth: truth,
                        locked: locked,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  for (var p = 0; p <= _periods; p++) _target(p, size),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _target(int p, Size size) {
    final x = TimelinePainter.xFor(size, _periods, p);
    final axis = TimelinePainter.axisFor(size);
    const wide = 48.0;
    return Positioned(
      key: ValueKey('period-$p'),
      left: x - wide / 2,
      top: axis - 62,
      width: wide,
      height: 92,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(p),
        child: const SizedBox.expand(),
      ),
    );
  }
}
