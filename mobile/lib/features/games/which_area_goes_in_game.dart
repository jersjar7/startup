import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'meter_figures.dart';

/// Which Area Goes In — the first item for `flow-measurement`.
///
/// Both of the lesson's meter problems name the same trap first: the area in
/// the formula is the throat or the hole, never the pipe. The way to find it
/// on a drawing is not to hunt for the narrowest thing in the picture, which
/// may be a reducer or a valve that has nothing to do with the meter. It is
/// to look at the two pressure tappings. What the meter measures is the drop
/// between those two, so the opening that sits between them is the one the
/// flow rate is metered on.
class WhichAreaGoesInGame extends StatefulWidget {
  const WhichAreaGoesInGame({super.key});

  @override
  State<WhichAreaGoesInGame> createState() => _WhichAreaGoesInGameState();
}

@immutable
class MeterRound {
  const MeterRound({
    required this.subject,
    required this.setting,
    required this.gauge,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Gauge gauge;
  final String why;
  final String source;

  /// Read off the drawing rather than declared beside it.
  int get answer => gauge.answer;
}

const meterRounds = <MeterRound>[
  MeterRound(
    subject: 'a venturi in a 200 millimeter main',
    setting:
        'The meter narrows to a throat and opens out again. Which of the four '
        'openings does the flow rate go on?',
    gauge: Gauge(
      wall: [(0, 200), (0.3, 200), (0.42, 100), (0.55, 100), (0.72, 200),
        (1, 200)],
      taps: (0.18, 0.48),
      stations: [
        Sta(at: 0.15),
        Sta(at: 0.33),
        Sta(at: 0.48, meters: true),
        Sta(at: 0.85),
      ],
    ),
    why:
        'The throat, at 3. Everything in the venturi formula that is an area '
        'is the throat: the A the coefficient multiplies, and the A on top of '
        'the ratio underneath. The upstream pipe appears only in that ratio, '
        'never on its own. Metering on the pipe instead is the lesson\'s own '
        'wrong answer of 0.284, four times too much, because four times the '
        'area passes four times the water at the same speed.',
    source: 'fm-fme-q2',
  ),
  MeterRound(
    subject: 'an orifice plate',
    setting:
        'A sharp-edged plate with a hole in it, set in a 150 millimeter pipe. '
        'The tappings are either side of it.',
    gauge: Gauge(
      wall: [(0, 150), (0.43, 150), (0.44, 75), (0.46, 75), (0.47, 150),
        (1, 150)],
      plateAt: 0.45,
      taps: (0.3, 0.62),
      stations: [
        Sta(at: 0.15),
        Sta(at: 0.45, meters: true),
        Sta(at: 0.7),
        Sta(at: 0.9),
      ],
    ),
    why:
        'The hole, at 2. The orifice formula is the venturi formula with the '
        'hole where the throat was: same shape, same place for the area, a '
        'different coefficient in front. Nothing about the pipe goes in '
        'except through the ratio underneath.',
    source: 'fm-fme-q3',
  ),
  MeterRound(
    subject: 'a venturi with a reducer past it',
    setting:
        'The 300 millimeter main carries a venturi, and further down it steps '
        'to 120 millimeter, narrower than anything in the meter.',
    gauge: Gauge(
      wall: [(0, 300), (0.28, 300), (0.38, 150), (0.46, 150), (0.6, 300),
        (0.8, 300), (0.86, 120), (1, 120)],
      taps: (0.16, 0.42),
      stations: [
        Sta(at: 0.15),
        Sta(at: 0.42, meters: true),
        Sta(at: 0.72),
        Sta(at: 0.92),
      ],
    ),
    why:
        'The throat, at 2, though 4 is the narrowest thing on the drawing. '
        'The tappings are what say where the meter is. A reducer with no '
        'tappings on it measures nothing: there is no pressure difference '
        'being read across it, so it cannot tell you a flow. Pick the opening '
        'between the two tappings, not the smallest pipe in sight.',
    source: 'fm-fme-q2',
  ),
  MeterRound(
    subject: 'the squeezed jet past a plate',
    setting:
        'The same plate again, with the jet drawn. It keeps shrinking after '
        'it leaves the hole before it spreads out to fill the pipe.',
    gauge: Gauge(
      wall: [(0, 150), (0.43, 150), (0.44, 75), (0.46, 75), (0.47, 150),
        (1, 150)],
      plateAt: 0.45,
      jet: [(0.46, 75), (0.57, 59), (0.78, 150)],
      taps: (0.3, 0.62),
      stations: [
        Sta(at: 0.2),
        Sta(at: 0.45, meters: true),
        Sta(at: 0.57, bore: 59),
        Sta(at: 0.85),
      ],
    ),
    why:
        'The hole, at 2, not the squeezed jet at 3. The jet really is '
        'narrower than the hole, and that squeeze is exactly what the '
        'contraction coefficient of 0.62 in the lesson is FOR. It is already '
        'inside the coefficient, so measuring the jet and applying the '
        'coefficient as well would count the same squeeze twice. Put the hole '
        'in the formula and let C do its job.',
    source: 'fm-fme-q3',
  ),
  MeterRound(
    subject: 'a plain reducer and then a meter',
    setting:
        'The main steps from 250 to 200 millimeter early on, and the venturi '
        'is further along.',
    gauge: Gauge(
      wall: [(0, 250), (0.16, 250), (0.22, 200), (0.45, 200), (0.52, 120),
        (0.6, 120), (0.7, 200), (1, 200)],
      taps: (0.38, 0.56),
      stations: [
        Sta(at: 0.15),
        Sta(at: 0.32),
        Sta(at: 0.56, meters: true),
        Sta(at: 0.85),
      ],
    ),
    why:
        'The throat, at 3. Two places on this run narrow the water, and only '
        'one of them is a meter. The step at the start changes the speed and '
        'the pressure exactly as a throat does, and nobody is reading the '
        'difference across it, so it is not measuring anything.',
    source: 'fm-fme-q2',
  ),
  MeterRound(
    subject: 'a meter near the inlet',
    setting:
        'The plate is close to the start of the run, and the pipe necks down '
        'to 80 millimeter well past it before opening out again.',
    gauge: Gauge(
      wall: [(0, 200), (0.26, 200), (0.27, 100), (0.29, 100), (0.3, 200),
        (0.62, 200), (0.7, 80), (0.76, 80), (0.84, 200), (1, 200)],
      plateAt: 0.28,
      taps: (0.17, 0.4),
      stations: [
        Sta(at: 0.28, meters: true),
        Sta(at: 0.48),
        Sta(at: 0.73),
        Sta(at: 0.92),
      ],
    ),
    why:
        'The hole, at 1. The 80 millimeter neck at 3 is the narrowest opening '
        'on the run and it is not the meter, for the same reason as before: '
        'no tappings. Reading the drawing for the tappings first takes a '
        'second and settles which opening the whole calculation hangs on.',
    source: 'fm-fme-q3',
  ),
];

class _WhichAreaGoesInGameState extends State<WhichAreaGoesInGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-area-goes-in',
    chapterId: 'fluid-mechanics',
    total: meterRounds.length,
    sourceProblemIdOf: (round) => meterRounds[round].source,
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

  MeterRound get _round => meterRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Area Goes In',
        closing:
            'The area in a meter formula is the throat or the hole, and the '
            'way to find it is the pair of tappings: the meter is what sits '
            'between them. The narrowest pipe on the drawing may be a reducer '
            'or a valve, and the squeezed jet past a plate is already paid '
            'for by the coefficient. The upstream pipe only ever turns up in '
            'the ratio underneath.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: meteringBrief,
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
            'TAP THE OPENING THE FLOW GOES ON',
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
          const SizedBox(height: 12),
          _Section(
            gauge: r.gauge,
            picked: _picked,
            locked: answered,
            onPick: answered ? null : (i) => setState(() => _picked = i),
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'ANOTHER OPENING',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.gauge,
    required this.picked,
    required this.locked,
    required this.onPick,
  });

  final Gauge gauge;
  final int? picked;
  final bool locked;
  final void Function(int)? onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 190);
        return GestureDetector(
          onTapUp: onPick == null
              ? null
              : (details) {
                  final hit =
                      GaugePainter.at(size, gauge, details.localPosition);
                  if (hit != null) onPick!(hit);
                },
          child: Container(
            height: size.height,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: GaugePainter(
                    gauge: gauge,
                    picked: picked,
                    locked: locked,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
