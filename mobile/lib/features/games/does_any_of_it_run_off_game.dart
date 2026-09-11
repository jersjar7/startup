import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'runoff_figures.dart';

/// Does Any of It Run Off — the third item for `rainfall-runoff`.
///
/// The SCS equation has a threshold in it that the Rational Method does not:
/// the ground takes the first fifth of its retention before anything runs
/// off at all, and below that the answer is zero rather than something small.
/// Above it, how much of the storm becomes runoff depends on the curve
/// number, which is the whole of what a curve number is for. Both halves of
/// that are readable off a drawing without arithmetic.
class DoesAnyOfItRunOffGame extends StatefulWidget {
  const DoesAnyOfItRunOffGame({super.key});

  @override
  State<DoesAnyOfItRunOffGame> createState() =>
      _DoesAnyOfItRunOffGameState();
}

/// How much of the storm reaches the drain.
enum Runoff3 { none, part, nearlyAll }

extension Runoff3Words on Runoff3 {
  String get plain => switch (this) {
        Runoff3.none => 'None of it: no runoff at all',
        Runoff3.part => 'Part of it, but well under half',
        Runoff3.nearlyAll => 'Most of it, more than half',
      };
}

@immutable
class SoakRound {
  const SoakRound({
    required this.subject,
    required this.setting,
    required this.soak,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Soak soak;
  final String why;
  final String source;

  /// Worked out of the curve number and the storm, never declared.
  Runoff3 get answer {
    if (soak.runoff <= 0) return Runoff3.none;
    return soak.fraction > 0.5 ? Runoff3.nearlyAll : Runoff3.part;
  }
}

const soakRounds = <SoakRound>[
  SoakRound(
    subject: 'the lesson\'s own watershed',
    setting: 'A five inch storm on ground with a curve number of 80.',
    soak: Soak(curveNumber: 80, rain: 5),
    why:
        'Most of it: 2.89 inches of the five, which is 58 percent. The '
        'retention works out at 2.5 inches and the ground takes the first '
        'fifth of that, half an inch, before anything moves. After a storm '
        'this size the ground is well past saturated and it is passing most '
        'of what falls.',
    source: 'wr-rr-q2',
  ),
  SoakRound(
    subject: 'a shower on dry pasture',
    setting:
        'Eight tenths of an inch of rain on pasture with a curve number of '
        '60.',
    soak: Soak(curveNumber: 60, rain: 0.8),
    why:
        'None at all. A curve number of 60 gives a retention of 6.7 inches, '
        'so the ground takes the first 1.33 inches before it will pass '
        'anything, and this storm never gets there. The answer is a hard '
        'zero, not a small number: below the initial abstraction the formula '
        'does not apply and the runoff is nothing.',
    source: 'wr-rr-q2',
  ),
  SoakRound(
    subject: 'the same storm on a car park',
    setting: 'Two inches of rain on paving with a curve number of 98.',
    soak: Soak(curveNumber: 98, rain: 2),
    why:
        'Most of it, and almost all of it: 1.77 of the two inches, which is '
        '89 percent. A curve number of 98 leaves a retention of only a fifth '
        'of an inch, so the threshold is four hundredths and effectively '
        'everything that falls runs off. This is what paving does to a '
        'catchment, and it is the same story the runoff coefficient tells in '
        'the Rational Method.',
    source: 'wr-rr-q2',
  ),
  SoakRound(
    subject: 'a modest storm on ordinary ground',
    setting: 'An inch and a half of rain where the curve number is 70.',
    soak: Soak(curveNumber: 70, rain: 1.5),
    why:
        'Part of it, and not much: 0.08 inches out of an inch and a half, '
        'about five percent. The threshold here is 0.86 inches, so the storm '
        'has only just cleared it, and just past the threshold the runoff '
        'climbs very slowly. This is the shape of the SCS curve worth '
        'remembering: nothing, then a little, then nearly everything.',
    source: 'wr-rr-q2',
  ),
  SoakRound(
    subject: 'a long soaking on the same ground',
    setting: 'Ten inches of rain where the curve number is 70.',
    soak: Soak(curveNumber: 70, rain: 10),
    why:
        'Most of it: 6.22 inches of the ten, about 62 percent. Same ground '
        'as the last round and the same threshold, but the bigger the storm '
        'the less the first 0.86 inches matters and the closer the runoff '
        'gets to the rainfall. The curve number sets how quickly that '
        'happens.',
    source: 'wr-rr-q2',
  ),
  SoakRound(
    subject: 'a heavy storm on woodland',
    setting: 'Three inches of rain on woods with a curve number of 55.',
    soak: Soak(curveNumber: 55, rain: 3),
    why:
        'Part of it, and barely any: 0.20 inches of the three. Woodland '
        'on good soil has a retention over eight inches, so it can take a '
        'genuinely heavy storm and pass very little. That capacity is why '
        'clearing a wooded catchment changes the peak downstream far more '
        'than the acreage cleared would suggest.',
    source: 'wr-rr-q2',
  ),
];

class _DoesAnyOfItRunOffGameState extends State<DoesAnyOfItRunOffGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'does-any-of-it-run-off',
    chapterId: 'water-resources',
    total: soakRounds.length,
    sourceProblemIdOf: (round) => soakRounds[round].source,
  )..addListener(_onSession);

  Runoff3? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SoakRound get _round => soakRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Does Any of It Run Off',
        closing:
            'The SCS method has a threshold the Rational Method does not. '
            'The ground takes the first fifth of its retention, and below '
            'that the runoff is a hard zero. Above it the fraction that runs '
            'off climbs with the storm and with the curve number: paving at '
            '98 passes nearly everything, woodland at 55 passes very little, '
            'and the answer comes out as a DEPTH in inches rather than a '
            'discharge.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: curveNumberBrief,
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
            'HOW MUCH OF THIS STORM REACHES THE DRAIN',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            '${r.setting} The dashed line is what the ground takes before '
            'anything runs off at all.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 250,
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
                  painter: SoakPainter(soak: r.soak, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$Q = \dfrac{(P - 0.2S)^2}{P + 0.8S}$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Runoff3.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Runoff3.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS HOW MUCH' : 'NOT THAT MUCH',
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
