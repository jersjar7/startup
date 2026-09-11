import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'hydrograph_figures.dart';

/// What Does the Storm Do to the Curve — the first item for
/// `hydrograph-watershed`.
///
/// A unit hydrograph is the watershed's answer to one inch of excess rain
/// falling over a stated number of hours. Scaling it for a bigger storm
/// multiplies the FLOWS and leaves the TIMES alone, because the watershed
/// routes water at the same speed whatever the storm does. What cannot be
/// scaled is the duration: a storm lasting a different number of hours needs
/// a different unit hydrograph altogether, and that is the distinction
/// worth carrying.
class WhatDoesTheStormDoGame extends StatefulWidget {
  const WhatDoesTheStormDoGame({super.key});

  @override
  State<WhatDoesTheStormDoGame> createState() =>
      _WhatDoesTheStormDoGameState();
}

/// What the storm does to the unit hydrograph.
enum Scaling { flows, times, another }

extension ScalingWords on Scaling {
  String get plain => switch (this) {
        Scaling.flows =>
          'Multiply every flow, leave the times exactly as they are',
        Scaling.times =>
          'Leave the flows, stretch the times by the same factor',
        Scaling.another => 'Neither: this needs a different unit hydrograph',
      };
}

@immutable
class StormRound {
  const StormRound({
    required this.subject,
    required this.setting,
    required this.unit,
    required this.unitHours,
    required this.rain,
    required this.stormHours,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;

  /// The watershed's unit hydrograph.
  final Wave unit;

  /// The duration the unit hydrograph was derived for.
  final double unitHours;

  /// Inches of excess rainfall in the storm.
  final double rain;
  final double stormHours;
  final String why;
  final String source;

  /// A storm of the same duration scales; one of a different duration does
  /// not, whatever its depth.
  Scaling get answer =>
      (stormHours - unitHours).abs() < 0.01 ? Scaling.flows : Scaling.another;

  Wave get result => unit.forRain(rain);
}

const stormRounds = <StormRound>[
  StormRound(
    subject: 'the lesson\'s own storm',
    setting:
        'A one hour unit hydrograph peaking at 500 cfs. The storm drops 3 '
        'inches of excess rain in one hour.',
    unit: Wave(peak: 500, toPeak: 3, base: 9),
    unitHours: 1,
    rain: 3,
    stormHours: 1,
    why:
        'Multiply the flows. Three inches is three times the inch the unit '
        'hydrograph was built for, so every ordinate triples and the peak '
        'goes to 1,500 cfs. The times do not move at all: the water still '
        'takes the same three hours to reach its peak and the same nine to '
        'finish, because the watershed has not changed shape. The volume '
        'under the curve triples too, which is what three inches of runoff '
        'means.',
    source: 'wr-hw-q1',
  ),
  StormRound(
    subject: 'a smaller storm',
    setting:
        'The same one hour unit hydrograph. This storm drops half an inch '
        'of excess rain in one hour.',
    unit: Wave(peak: 500, toPeak: 3, base: 9),
    unitHours: 1,
    rain: 0.5,
    stormHours: 1,
    why:
        'Multiply the flows, this time by a half, so the peak comes down to '
        '250 cfs. Scaling works in both directions and the times still do not '
        'move. A small storm on this watershed takes exactly as long to '
        'arrive, to peak and to drain away as a large one does; it is just '
        'lower throughout.',
    source: 'wr-hw-q1',
  ),
  StormRound(
    subject: 'a storm of a different length',
    setting:
        'The same one hour unit hydrograph. This storm drops 2 inches of '
        'excess rain over three hours.',
    unit: Wave(peak: 500, toPeak: 3, base: 9),
    unitHours: 1,
    rain: 2,
    stormHours: 3,
    why:
        'Neither: this needs a three hour unit hydrograph. The duration is '
        'part of what a unit hydrograph IS, not something to be scaled out of '
        'it. Rain spread over three hours produces a lower, longer, flatter '
        'response than the same total falling in one, and no amount of '
        'multiplying the one hour curve will produce it. The way across is to '
        'build the three hour hydrograph, by lagging and adding the one hour '
        'one.',
    source: 'wr-hw-q1',
  ),
  StormRound(
    subject: 'a big storm, same duration',
    setting:
        'A two hour unit hydrograph peaking at 300 cfs. The storm drops 4 '
        'inches of excess rain over two hours.',
    unit: Wave(peak: 300, toPeak: 4, base: 12),
    unitHours: 2,
    rain: 4,
    stormHours: 2,
    why:
        'Multiply the flows, by four, to a peak of 1,200 cfs. What matters '
        'is that the storm and the unit hydrograph share a DURATION, not that '
        'the duration is one hour: a two hour unit hydrograph scales for any '
        'two hour storm. Matching the duration first and the depth second is '
        'the whole procedure.',
    source: 'wr-hw-q1',
  ),
  StormRound(
    subject: 'a long soaking on a short curve',
    setting:
        'The one hour unit hydrograph again. This storm drops 3 inches over '
        'six hours.',
    unit: Wave(peak: 500, toPeak: 3, base: 9),
    unitHours: 1,
    rain: 3,
    stormHours: 6,
    why:
        'Neither. Same three inches as the first round and an utterly '
        'different hydrograph, because six hours of gentle rain gives the '
        'watershed time to pass the early water before the late water '
        'arrives. The peak will be far below 1,500 cfs and the curve much '
        'longer. Depth sets the volume; duration sets the shape.',
    source: 'wr-hw-q1',
  ),
  StormRound(
    subject: 'exactly one inch',
    setting:
        'The one hour unit hydrograph. This storm drops exactly 1 inch of '
        'excess rain in one hour.',
    unit: Wave(peak: 500, toPeak: 3, base: 9),
    unitHours: 1,
    rain: 1,
    stormHours: 1,
    why:
        'Multiply the flows, by one, which is to say the unit hydrograph IS '
        'the answer. That is what makes it a UNIT hydrograph: it is the '
        'watershed\'s response to one inch over the stated duration, ready to '
        'be read off directly. Every other storm of that duration is this '
        'curve times a number.',
    source: 'wr-hw-q1',
  ),
];

class _WhatDoesTheStormDoGameState extends State<WhatDoesTheStormDoGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'what-does-the-storm-do',
    chapterId: 'water-resources',
    total: stormRounds.length,
    sourceProblemIdOf: (round) => stormRounds[round].source,
  )..addListener(_onSession);

  Scaling? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  StormRound get _round => stormRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'What Does the Storm Do to the Curve',
        closing:
            'A unit hydrograph answers for one inch of excess rain over a '
            'stated duration. For a deeper storm of the SAME duration, '
            'multiply every flow and leave the times alone: the watershed '
            'routes water at its own speed whatever the storm does. For a '
            'storm of a different duration, no amount of scaling will do. '
            'Depth sets the volume; duration sets the shape.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: unitHydrographBrief,
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
            'HOW DO YOU GET THIS STORM OUT OF THAT CURVE',
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
          Container(
            height: 226,
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
                  painter: HydrographPainter(
                    waves: answered && r.answer == Scaling.flows
                        ? [r.unit, r.result]
                        : [r.unit],
                    names: answered && r.answer == Scaling.flows
                        ? const ['the unit hydrograph', 'this storm']
                        : const ['the unit hydrograph'],
                    tones: const [AppColors.ink3, AppColors.forest],
                    topFlow: answered && r.answer == Scaling.flows
                        ? null
                        : r.unit.peak * 1.18,
                    note: '${_num(r.unitHours)} hour unit hydrograph, '
                        'peak ${_num(r.unit.peak)} cfs',
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Scaling.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Scaling.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE WAY ACROSS' : 'NOT THAT WAY',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

String _num(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toString();

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
