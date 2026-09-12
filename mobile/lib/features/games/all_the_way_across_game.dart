import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'signal_figures.dart';

/// All the Way Across — the second item for `signal-timing`.
///
/// The all-red exists for the vehicle that entered on yellow. It is not
/// clear of the intersection when its front bumper reaches the far curb: it
/// is clear when its BACK bumper does, which is why the vehicle length goes
/// in the numerator beside the width.
class AllTheWayAcrossGame extends StatefulWidget {
  const AllTheWayAcrossGame({super.key});

  @override
  State<AllTheWayAcrossGame> createState() => _AllTheWayAcrossGameState();
}

@immutable
class ClearanceRound {
  const ClearanceRound({
    required this.subject,
    required this.asked,
    required this.clearance,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Clearance clearance;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own crossing: 60 ft wide, a 20 ft vehicle at 50 mph, which
/// comes to 1.1 seconds.
const _theCrossing =
    Clearance(width: 60, vehicleLength: 20, speedMph: 50);

/// A wide crossing at a slower speed, where the all-red is much longer.
const _wideAndSlow =
    Clearance(width: 120, vehicleLength: 20, speedMph: 25);

/// A long truck on the lesson's crossing.
const _withATruck =
    Clearance(width: 60, vehicleLength: 65, speedMph: 50);

const clearanceRounds = <ClearanceRound>[
  ClearanceRound(
    subject: 'who the all-red is for',
    asked:
        'Every direction has a red at once for a moment. Who is that moment '
        'for?',
    clearance: _theCrossing,
    options: [
      'Pedestrians starting to cross',
      'Nobody: it is a safety margin with no particular user',
      'The vehicle that entered on the yellow and is still in the '
          'intersection',
      'Vehicles waiting to turn left',
    ],
    answer: 2,
    why:
        'The vehicle already inside. Somebody entered legally on the yellow '
        'and is still crossing when it turns red, and the all-red is the time '
        'that lets them get out before the cross street is released. '
        'Everything about the calculation follows from that one picture.',
    source: 'trans-st-q2',
  ),
  ClearanceRound(
    subject: 'what distance it has to cover',
    asked:
        'The intersection is 60 ft curb to curb and the vehicle is 20 ft '
        'long. How far does it have to travel to be clear?',
    clearance: _theCrossing,
    options: [
      '60 ft: the width of the intersection',
      '40 ft: the width less the vehicle',
      '20 ft: its own length',
      '80 ft: the width plus its own length',
    ],
    answer: 3,
    why:
        'Eighty. The vehicle is not out until its BACK bumper passes the far '
        'curb, and that bumper starts a vehicle length short of the near one. '
        'Using 60 gives 0.8 seconds instead of 1.1, which is the lesson\'s '
        'wrong answer and a third of the protection short.',
    source: 'trans-st-q2',
  ),
  ClearanceRound(
    subject: 'the units again',
    asked:
        'The speed is 50 mph and the distance is in feet. What has to happen '
        'before dividing?',
    clearance: _theCrossing,
    options: [
      'Nothing: the units cancel',
      'The distance goes into miles',
      'The speed goes into feet per second, 73.3 of them',
      'The time comes out in minutes',
    ],
    answer: 2,
    why:
        'Feet per second, as everywhere else in this lesson. Dividing 80 ft '
        'by 50 gives 1.6, which is not seconds and is not anything: it is the '
        'lesson\'s other printed wrong answer, and it is bigger than the '
        'right one, so it does not even fail safe in an obvious direction.',
    source: 'trans-st-q2',
  ),
  ClearanceRound(
    subject: 'a longer vehicle',
    asked:
        'The design vehicle is a 65 ft truck instead of a 20 ft car. What '
        'happens to the all-red?',
    clearance: _withATruck,
    options: [
      'Nothing: the intersection is the same width',
      'It goes up, because the distance to clear is now the width plus 65 ft',
      'It goes down',
      'It doubles, whatever the truck length',
    ],
    answer: 1,
    why:
        'It goes up, and by a lot: 125 ft to clear instead of 80. On a route '
        'with heavy truck traffic the design vehicle matters as much as the '
        'width of the road does, which is why an all-red set for a car can be '
        'short for the traffic actually using the intersection.',
    source: 'trans-st-q2',
  ),
  ClearanceRound(
    subject: 'a wide crossing on a slow street',
    asked:
        'This one is 120 ft across and the approach speed is 25 mph. What '
        'does that do to the all-red?',
    clearance: _wideAndSlow,
    options: [
      'Shortens it, since the traffic is slower',
      'Leaves it about the same',
      'Lengthens it twice over: further to go, and more slowly',
      'Makes it unnecessary',
    ],
    answer: 2,
    why:
        'Both changes push the same way. The distance has roughly doubled and '
        'the speed has halved, so the time is about four times what the '
        'lesson\'s crossing needed. A wide slow intersection can want three '
        'or four seconds of all-red, which is why they feel so long.',
    source: 'trans-st-q2',
  ),
  ClearanceRound(
    subject: 'the ratio the wrong way up',
    asked:
        'A student divides the speed by the distance and reports 0.9. How '
        'would you know that is wrong without redoing it?',
    clearance: _theCrossing,
    options: [
      'Because feet per second divided by feet is not seconds: the units '
          'come out upside down',
      'Because the answer should be under a second',
      'Because 0.9 is too small a number',
      'You would not: it is a plausible answer',
    ],
    answer: 0,
    why:
        'The units. Feet over feet per second gives seconds, and turning it '
        'over gives one over seconds, which is not a time at all. Checking '
        'the units of an answer catches a whole class of inversions without '
        'any arithmetic, and this lesson offers two of them.',
    source: 'trans-st-q2',
  ),
];

class _AllTheWayAcrossGameState extends State<AllTheWayAcrossGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'all-the-way-across',
    chapterId: 'transportation',
    total: clearanceRounds.length,
    sourceProblemIdOf: (round) => clearanceRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  ClearanceRound get _round => clearanceRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'All the Way Across',
        closing:
            'The all-red is for the vehicle that entered on the yellow, and '
            'it is clear when its BACK bumper passes the far curb. So the '
            'distance is the width plus the vehicle length, and the speed '
            'goes in as feet per second. Forget the vehicle and the interval '
            'comes out a third short.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: allRedBrief,
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
            'THE ALL-RED',
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
            height: 210,
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
                  painter: CrossingPainter(
                    clearance: r.clearance,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
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
