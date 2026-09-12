import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'consolidation_figures.dart';

/// How Long Does It Take — the third item for `consolidation`.
///
/// How MUCH a clay settles and how LONG it takes are separate questions with
/// separate inputs, and the time one turns almost entirely on how far the
/// squeezed-out water has to travel to get out. That distance is half the
/// layer when water can leave both faces and the whole of it when it cannot,
/// and since the time goes as the square of it, one impermeable boundary
/// makes the wait four times as long.
class HowLongDoesItTakeGame extends StatefulWidget {
  const HowLongDoesItTakeGame({super.key});

  @override
  State<HowLongDoesItTakeGame> createState() =>
      _HowLongDoesItTakeGameState();
}

@immutable
class TimeRound {
  const TimeRound({
    required this.subject,
    required this.asked,
    required this.drain,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Drainage drain;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const _bothWays =
    Drainage(thickness: 10, topDrains: true, bottomDrains: true);
const _onRock =
    Drainage(thickness: 10, topDrains: true, bottomDrains: false);

const timeRounds = <TimeRound>[
  TimeRound(
    subject: 'sand above and below',
    asked:
        'Ten feet of clay with sand on both faces. How far does the water '
        'have to travel to get out?',
    drain: _bothWays,
    options: [
      'Five feet: the worst-placed water is in the middle and can go either '
          'way',
      'Ten feet: the whole thickness',
      'Twenty feet: both directions added',
      'It depends on the permeability, not the geometry',
    ],
    answer: 0,
    why:
        'Five feet. The drainage path is the longest journey any water has to '
        'make, and with an escape at both faces the unluckiest drop is the '
        'one in the middle, five feet from either. That is why the path is '
        'half the layer whenever both boundaries drain.',
    source: 'geo-co-q2',
  ),
  TimeRound(
    subject: 'clay on rock',
    asked:
        'The same ten feet of clay, but now it sits on rock with sand only '
        'above it. How far does the water travel?',
    drain: _onRock,
    options: [
      'Ten feet: the water at the bottom has to reach the top',
      'Five feet, as before',
      'Still five feet, but it takes twice as long',
      'Nothing changes: rock drains as well as sand',
    ],
    answer: 0,
    why:
        'The whole ten feet. Water at the base of the layer has nowhere to go '
        'but up, so the longest journey is the full thickness. One '
        'impermeable boundary doubles the path, and the lesson calls this out '
        'because the arithmetic afterward is trivial and the setup is where '
        'the marks go.',
    source: 'geo-co-q2',
  ),
  TimeRound(
    subject: 'what that costs in time',
    asked:
        'Same clay, same load, same degree of consolidation. How much longer '
        'does the layer on rock take than the layer with sand both sides?',
    drain: _onRock,
    options: [
      'Four times as long',
      'Twice as long',
      'The same: only the amount of settlement changes',
      'Half as long',
    ],
    answer: 0,
    why:
        'Four times, because the time goes as the SQUARE of the drainage '
        'path. Doubling the distance the water has to travel quadruples the '
        'wait: a settlement that would have finished in a year takes four. '
        'This is the single most useful line in the lesson, and it is also '
        'the wrong answer people give, because doubling feels like doubling.',
    source: 'geo-co-q2',
  ),
  TimeRound(
    subject: 'a thicker layer',
    asked:
        'Twenty feet of clay instead of ten, drained both sides, everything '
        'else the same. How much longer?',
    drain: Drainage(thickness: 20, topDrains: true, bottomDrains: true),
    options: [
      'Four times as long, since the path has doubled',
      'Twice as long, since the layer has doubled',
      'The same, since it drains both ways',
      'Eight times as long',
    ],
    answer: 0,
    why:
        'Four times again, and for the same reason: doubling the thickness '
        'doubles the drainage path, and the square does the rest. Notice that '
        'the amount of settlement only doubles while the time quadruples, '
        'which is why thick soft layers are the ones that keep moving long '
        'after everybody expected them to stop.',
    source: 'geo-co-q2',
  ),
  TimeRound(
    subject: 'what does not change the time',
    asked:
        'The load applied to the clay is doubled. What happens to the time to '
        'reach half of the final settlement?',
    drain: _bothWays,
    options: [
      'Nothing: the time depends on the clay and the path, not the load',
      'It doubles, since there is twice as much settling to do',
      'It halves, since the squeeze is harder',
      'It quadruples',
    ],
    answer: 0,
    why:
        'Nothing at all. A bigger load means MORE settlement, not slower '
        'settlement: the fraction completed at any time depends on the '
        'coefficient of consolidation and the drainage path alone. Half of a '
        'large settlement and half of a small one arrive on the same day.',
    source: 'geo-co-q2',
  ),
  TimeRound(
    subject: 'sand drains in the clay',
    asked:
        'Vertical sand drains are installed through the clay at close '
        'spacing. Why does that help?',
    drain: _onRock,
    options: [
      'They shorten the journey the water has to make, and the time goes as '
          'the square of it',
      'They make the clay stronger',
      'They reduce the total settlement',
      'They lower the water table',
    ],
    answer: 0,
    why:
        'They shorten the path, and the square does the rest. Cut the '
        'distance to a tenth and the wait falls to a hundredth, which is why '
        'a soft site under a surcharge can be made to do its settling in '
        'months rather than decades. The amount of settlement is untouched: '
        'drains change only how long the waiting takes.',
    source: 'geo-co-q2',
  ),
];

class _HowLongDoesItTakeGameState extends State<HowLongDoesItTakeGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-long-does-it-take',
    chapterId: 'geotechnical',
    total: timeRounds.length,
    sourceProblemIdOf: (round) => timeRounds[round].source,
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

  TimeRound get _round => timeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Long Does It Take',
        closing:
            'How much a clay settles and how long it takes are different '
            'questions. The time turns on the drainage path, which is half '
            'the layer when water escapes both faces and the whole of it when '
            'one face is rock, and the time goes as the SQUARE of that path. '
            'So one impermeable boundary costs four times the wait, and so '
            'does doubling the thickness. The size of the load changes the '
            'settlement and not the schedule.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: drainageBrief,
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
            'HOW FAR THE WATER GOES',
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
          Container(
            height: 196,
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
                  painter:
                      DrainagePainter(drain: r.drain, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$t = \frac{T_v H_{dr}^2}{c_v}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < r.options.length; i++) ...[
            _Choice(
              label: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: r.answer == i,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
            if (i != r.options.length - 1) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS IT' : 'NOT THAT ONE',
              body: r.why,
            ),
          ],
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
