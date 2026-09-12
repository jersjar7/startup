import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'wall_stability_figures.dart';

/// Moments or Forces — the first item for `retaining-walls`.
///
/// That a factor of safety is what resists over what drives is not new here:
/// the slope lesson taught it. What IS new is that a wall gets THREE such
/// ratios, each comparing a different kind of quantity, and that passing two
/// of them says nothing about the third.
class MomentsOrForcesGame extends StatefulWidget {
  const MomentsOrForcesGame({super.key});

  @override
  State<MomentsOrForcesGame> createState() => _MomentsOrForcesGameState();
}

@immutable
class CheckRound {
  const CheckRound({
    required this.subject,
    required this.asked,
    required this.wall,
    required this.which,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Gravity wall;
  final Check which;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own wall: 15,000 resisting against 5,000 overturning.
const _lessonWall = Gravity(
  baseWidth: 6,
  vertical: 5000,
  resisting: 15000,
  overturning: 5000,
);

const checkRounds = <CheckRound>[
  CheckRound(
    subject: 'what goes on top',
    asked:
        'The factor of safety against overturning is a ratio. What belongs on '
        'top of it?',
    wall: _lessonWall,
    which: Check.overturning,
    options: [
      'The overturning moment, since that is what you are checking',
      'The moments that resist the tipping',
      'The difference between the two moments',
      'The vertical force on the base',
    ],
    answer: 1,
    why:
        'What resists goes on top, every time. The wall is safe when the '
        'moments holding it down are the larger of the two, so a factor above '
        'one means safe and a bigger number means safer. A wall with 15,000 '
        'resisting and 5,000 overturning is at 3.0.',
    source: 'geo-rw-q1',
  ),
  CheckRound(
    subject: 'the ratio upside down',
    asked:
        'Another student works the same wall and reports a factor of safety '
        'of 0.33. What did they do?',
    wall: _lessonWall,
    which: Check.overturning,
    options: [
      'They divided the wrong way round',
      'They subtracted instead of dividing',
      'They used the wrong pivot',
      'They forgot the weight of the wall',
    ],
    answer: 0,
    why:
        'Upside down. A third is the reciprocal of three, which is the '
        'signature of putting the overturning moment on top. It is worth '
        'knowing what a wrong answer LOOKS like: any factor of safety below '
        'one that comes out suspiciously like the reciprocal of a sensible '
        'number is this mistake.',
    source: 'geo-rw-q1',
  ),
  CheckRound(
    subject: 'what sliding compares',
    asked:
        'The same wall is checked against sliding along its base. What two '
        'quantities does that ratio compare?',
    wall: _lessonWall,
    which: Check.sliding,
    options: [
      'Moments about the toe',
      'Pressures under the base',
      'Forces along the base: the friction against the push',
      'The eccentricity against the base width',
    ],
    answer: 2,
    why:
        'Forces, not moments. Sliding is a horizontal tug of war: the earth '
        'pressure pushing the wall out against the friction under the footing '
        'holding it back. Nothing turns, so nothing has an arm, and no moment '
        'belongs in it.',
    source: 'geo-rw-q1',
  ),
  CheckRound(
    subject: 'what bearing compares',
    asked: 'And the third check, bearing. What does that one compare?',
    wall: _lessonWall,
    which: Check.bearing,
    options: [
      'Forces along the base',
      'Pressures: what the soil can carry against what the base puts on it',
      'Moments about the heel',
      'The height of the wall against its base width',
    ],
    answer: 1,
    why:
        'Pressures. The base presses down on the soil and the soil has a '
        'capacity, both in pounds a square foot, and the ratio of the two is '
        'the third check. Three checks, three different kinds of quantity, '
        'and the same wall can pass one and fail another.',
    source: 'geo-rw-q1',
  ),
  CheckRound(
    subject: 'which one is held to the highest standard',
    asked:
        'The three checks are not held to the same minimum. Which is usually '
        'asked for the largest factor of safety?',
    wall: _lessonWall,
    which: Check.bearing,
    options: [
      'Overturning, at about two',
      'Sliding, at about one and a half',
      'Bearing, at about three',
      'All three, at the same number',
    ],
    answer: 2,
    why:
        'Bearing, at about three, against roughly one and a half for sliding '
        'and one and a half to two for overturning. Bearing gets the largest '
        'margin because the soil underneath is the part nobody can see and '
        'the consequences of getting it wrong are settlement or a collapse '
        'with no warning.',
    source: 'geo-rw-q1',
  ),
  CheckRound(
    subject: 'passing two of three',
    asked:
        'A wall comes out at 2.5 against overturning and 1.2 against '
        'sliding. Is it acceptable?',
    wall: _lessonWall,
    which: Check.sliding,
    options: [
      'Yes: the average is comfortably above one and a half',
      'Yes: overturning is the governing check',
      'No: sliding is short, and each check stands on its own',
      'It cannot be judged without the bearing check',
    ],
    answer: 2,
    why:
        'No. The three do not average and they do not trade. A wall that will '
        'not tip but will slide is a wall that slides. Each check has to be '
        'met on its own, which is why a wall is often widened at the base or '
        'given a key under the footing to fix sliding alone.',
    source: 'geo-rw-q1',
  ),
];

class _MomentsOrForcesGameState extends State<MomentsOrForcesGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'moments-or-forces',
    chapterId: 'geotechnical',
    total: checkRounds.length,
    sourceProblemIdOf: (round) => checkRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  CheckRound get _round => checkRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Moments or Forces',
        closing:
            'Three checks on one wall. Overturning compares moments about the '
            'toe, sliding compares forces along the base, and bearing '
            'compares pressures under it. What resists goes on top in all '
            'three, the minimums are different, and passing two of them says '
            'nothing at all about the third.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: threeChecksBrief,
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
            'WHICH CHECK IS IT',
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
                  painter: StabilityPainter(
                    wall: r.wall,
                    which: r.which,
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
