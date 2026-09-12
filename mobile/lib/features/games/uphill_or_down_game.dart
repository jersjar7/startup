import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'sight_figures.dart';

/// Uphill or Down — the second item for `stopping-sight-distance`.
///
/// The lesson's loudest warning. Uphill helps a driver stop, so the sight
/// distance is SHORTER. Downhill fights the brakes, so it is LONGER. The
/// sign in the denominator is the whole of it, and reversing it is the trap
/// the problem is built around.
class UphillOrDownGame extends StatefulWidget {
  const UphillOrDownGame({super.key});

  @override
  State<UphillOrDownGame> createState() => _UphillOrDownGameState();
}

@immutable
class HillRound {
  const HillRound({
    required this.subject,
    required this.asked,
    required this.stop,
    this.against,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Braking stop;
  final Braking? against;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's three cases at 60 mph: 566 ft level, 610 down a four per
/// cent grade, 530 up one.
const _level = Braking(speed: 60);
const _down = Braking(speed: 60, grade: -0.04);
const _up = Braking(speed: 60, grade: 0.04);

const hillRounds = <HillRound>[
  HillRound(
    subject: 'a four per cent downgrade',
    asked:
        'The same 60 mph road now runs down a four per cent grade. Compared '
        'with the level road, the sight distance needed is:',
    stop: _down,
    against: _level,
    options: [
      'Shorter',
      'Longer',
      'The same: grade does not affect stopping',
      'Shorter, but only above 50 mph',
    ],
    answer: 1,
    why:
        'Longer, 610 ft against 566. Going downhill the car is being helped '
        'along by its own weight the whole time it is braking, so it takes '
        'more road to stop, so the driver needs to see further. Everything '
        'about a downgrade makes stopping worse.',
    source: 'trans-ssd-q2',
  ),
  HillRound(
    subject: 'which way the sign goes',
    asked:
        'In the formula the grade sits in the denominator. What goes in for a '
        'four per cent DOWNgrade?',
    stop: _down,
    options: [
      'Plus 0.04',
      'Minus 0.04',
      'Plus 4',
      'Nothing: grade is only used for uphill',
    ],
    answer: 1,
    why:
        'Minus 0.04. Uphill is positive and downhill negative, and the grade '
        'goes in as a fraction, not as a whole number of per cent. A minus '
        'makes the denominator smaller, which makes the braking distance '
        'longer, which is the physical answer.',
    source: 'trans-ssd-q2',
  ),
  HillRound(
    subject: 'the same hill, climbing',
    asked:
        'Now the road climbs the same four per cent. What happens to the '
        'sight distance?',
    stop: _up,
    against: _level,
    options: [
      'It gets longer, since the engine is working harder',
      'It is unchanged',
      'It gets shorter, because gravity is helping the brakes',
      'It doubles',
    ],
    answer: 2,
    why:
        'Shorter, 530 ft against 566. Climbing, the car\'s own weight is '
        'pulling it back, so the brakes have less to do. This is the half '
        'people get right by instinct, which is precisely why the downhill '
        'case catches them.',
    source: 'trans-ssd-q2',
  ),
  HillRound(
    subject: 'which part of the distance moves',
    asked: 'When the grade changes, which part of the distance changes?',
    stop: _down,
    against: _level,
    options: [
      'Both parts',
      'Only the thinking distance',
      'Only the braking distance: the thinking part is the same on any grade',
      'Neither, until the grade passes six per cent',
    ],
    answer: 2,
    why:
        'Only the braking part. During the thinking stretch nothing has '
        'happened yet, and the car covers the same ground at the same speed '
        'whatever the hill is doing. The grade only shows up once the brakes '
        'are on.',
    source: 'trans-ssd-q2',
  ),
  HillRound(
    subject: 'a student with the sign reversed',
    asked:
        'The right answer for the downgrade is 610 ft. A student reports 530. '
        'What did they do?',
    stop: _down,
    against: _up,
    options: [
      'Used a plus where the minus belonged, and so worked the uphill case',
      'Forgot the thinking distance',
      'Used the wrong speed',
      'Used a grade of 0.4 instead of 0.04',
    ],
    answer: 0,
    why:
        'They worked the uphill case. 530 is the answer for a four per cent '
        'CLIMB, so the sign was reversed and the road made easier than it is. '
        'That is the dangerous direction to be wrong in: it designs a road '
        'with less sight distance than the hill actually needs.',
    source: 'trans-ssd-q2',
  ),
  HillRound(
    subject: 'why it matters more than it looks',
    asked:
        'Four per cent is a gentle grade. Why does the lesson make so much of '
        'the sign?',
    stop: _down,
    against: _level,
    options: [
      'Because the number is very large',
      'Because it is the only formula with a grade in it',
      'Because getting it backwards moves the answer the wrong way by about '
          'eighty feet, and always toward less safety',
      'Because grades are rare on highways',
    ],
    answer: 2,
    why:
        'Because a reversed sign does not merely give a wrong number, it '
        'gives a wrong number in the unsafe direction, and by more than the '
        'length of a semi and its load. A crest on a downgrade is exactly '
        'where the extra distance is hardest to provide.',
    source: 'trans-ssd-q2',
  ),
];

class _UphillOrDownGameState extends State<UphillOrDownGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'uphill-or-down',
    chapterId: 'transportation',
    total: hillRounds.length,
    sourceProblemIdOf: (round) => hillRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  HillRound get _round => hillRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Uphill or Down',
        closing:
            'Uphill is a plus and shortens the distance, because gravity is '
            'helping the brakes. Downhill is a minus and lengthens it. Only '
            'the braking half moves: the thinking half is the same on any '
            'grade. Reverse the sign and the answer comes out short, which is '
            'the unsafe direction.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: gradeSignBrief,
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
            'THE SIGN ON THE GRADE',
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
            height: 214,
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
                  painter: StoppingPainter(
                    stop: r.stop,
                    against: r.against,
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
