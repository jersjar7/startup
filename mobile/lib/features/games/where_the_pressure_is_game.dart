import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'pipe_figures.dart';

/// Where the Pressure Is — the second item for `continuity-bernoulli`.
///
/// Bernoulli traded against continuity is the whole of this lesson's middle
/// problem, and the part people refuse to believe is the direction: the water
/// goes FASTER in the narrow section, and the pressure there is LOWER, not
/// higher. It feels backwards because a squeezed pipe feels like a squeezed
/// pipe. So the run is drawn with its narrows and its widenings and the round
/// asks where the pressure sits, which is the judgment the arithmetic hangs
/// off.
class WhereThePressureIsGame extends StatefulWidget {
  const WhereThePressureIsGame({super.key});

  @override
  State<WhereThePressureIsGame> createState() =>
      _WhereThePressureIsGameState();
}

@immutable
class RunRound {
  const RunRound({
    required this.subject,
    required this.asked,
    required this.run,
    required this.wantsFastest,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Run run;

  /// True when the round asks where the water moves fastest, false when it
  /// asks where the pressure is lowest. They are the same section, which is
  /// the point of the item.
  final bool wantsFastest;
  final String why;
  final String source;

  /// Worked out from the run, never declared: the narrowest section is both
  /// the fastest and the one at the lowest pressure.
  int get answer => run.fastest;
}

const _reducer = Run(bores: [Bore(millimeters: 200), Bore(millimeters: 100)]);

const _venturi = Run(bores: [
  Bore(millimeters: 200, share: 0.9),
  Bore(millimeters: 90, share: 0.6),
  Bore(millimeters: 200, share: 0.9),
]);

const _opening = Run(bores: [
  Bore(millimeters: 120, share: 1),
  Bore(millimeters: 250, share: 1),
]);

const _threeStep = Run(bores: [
  Bore(millimeters: 250, share: 0.8),
  Bore(millimeters: 160, share: 0.8),
  Bore(millimeters: 110, share: 0.8),
]);

const pressureRounds = <RunRound>[
  RunRound(
    subject: 'the lesson\'s reducer',
    asked: 'Tap the section where the water is moving faster.',
    run: _reducer,
    wantsFastest: true,
    why:
        'The narrow one, four times as fast: the same flow through a quarter '
        'of the opening. Nothing surprising yet. The surprise is in the next '
        'round, which asks the same picture a different question.',
    source: 'fm-cb-q1',
  ),
  RunRound(
    subject: 'the same reducer',
    asked: 'Now tap the section where the PRESSURE is lower.',
    run: _reducer,
    wantsFastest: false,
    why:
        'The narrow one again, and this is the round worth arguing with. '
        'Bernoulli says the three heads add to a constant, so if the velocity '
        'head goes up the pressure head must come down. In the lesson\'s own '
        'numbers the pressure falls from 250 to 233 kilopascals as the water '
        'speeds from 1.5 to 6 m/s. Faster means lower pressure, every time.',
    source: 'fm-cb-q2',
  ),
  RunRound(
    subject: 'a venturi',
    asked: 'Tap the section where the pressure is lowest.',
    run: _venturi,
    wantsFastest: false,
    why:
        'The throat in the middle. This is a venturi, and the pressure drop '
        'at its throat is not a side effect, it is the whole instrument: '
        'measure that drop and you know the flow. Note that the pressure '
        'comes back up again in the wide section past it, because the water '
        'slows down again.',
    source: 'fm-cb-q2',
  ),
  RunRound(
    subject: 'a pipe that opens out',
    asked: 'Tap the section where the pressure is lower.',
    run: _opening,
    wantsFastest: false,
    why:
        'The narrow one, which is now the FIRST section rather than the last. '
        'Nothing about upstream or downstream decides this: the pressure is '
        'lower wherever the water is quicker, and here it slows down on its '
        'way out into the bigger pipe, so the pressure rises along the way.',
    source: 'fm-cb-q2',
  ),
  RunRound(
    subject: 'three sizes in a row',
    asked: 'Tap the section where the water is fastest.',
    run: _threeStep,
    wantsFastest: true,
    why:
        'The smallest, which is about five times the speed of the biggest: '
        '250 down to 110 millimeters is a ratio of 2.3, squared. Continuity '
        'does not care how many steps there are, only what the opening is at '
        'the section you are asking about.',
    source: 'fm-cb-q1',
  ),
  RunRound(
    subject: 'the same three sections',
    asked: 'Tap the section where the pressure is lowest.',
    run: _threeStep,
    wantsFastest: false,
    why:
        'The smallest again, and the two questions have the same answer in '
        'every round of this item. That is the whole lesson: velocity head '
        'and pressure head trade against each other along a level pipe, so '
        'the fastest section is always the one at the lowest pressure, and if '
        'you know where one is you know where the other is.',
    source: 'fm-cb-q2',
  ),
];

class _WhereThePressureIsGameState extends State<WhereThePressureIsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-the-pressure-is',
    chapterId: 'fluid-mechanics',
    total: pressureRounds.length,
    sourceProblemIdOf: (round) => pressureRounds[round].source,
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

  RunRound get _round => pressureRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where the Pressure Is',
        closing:
            'Along a level pipe the heads trade: where the water speeds up, '
            'the pressure falls, and where it slows down again the pressure '
            'comes back. So the narrowest section is both the fastest and the '
            'one at the lowest pressure, which feels backwards and is the '
            'whole of Bernoulli. A venturi is that drop, sold as an '
            'instrument.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: bernoulliBrief,
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
            'TAP THE SECTION',
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
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final size = Size(box.maxWidth, 210);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: answered
                    ? null
                    : (details) {
                        final hit =
                            RunPainter.at(size, r.run, details.localPosition);
                        if (hit != null) setState(() => _picked = hit);
                      },
                child: EngineeringGrid(
                  minor: 18,
                  major: 90,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomPaint(
                      painter: RunPainter(
                        run: r.run,
                        picked: _picked,
                        answer: answered ? r.answer : null,
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
            answered
                ? 'speeds: ${[
                    for (var i = 0; i < r.run.bores.length; i++)
                      '${i + 1} at ${r.run.speedAt(i).toStringAsFixed(1)}'
                  ].join(', ')} m/s'
                : 'one flow, drawn to scale across every section',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\dfrac{P}{\gamma} + \dfrac{v^2}{2g} + z = \text{constant}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}
