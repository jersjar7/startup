import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'survey_figures.dart';

/// Which Rule Turns It — the second item for `angles-distances-bearings`.
///
/// There are four conversions and they are easy to mix up, which is exactly
/// what the lesson's warning is about: nobody forgets that a conversion
/// exists, they reach for the wrong one. The four rules are not worth
/// memorizing as a list either. Each one is just the reading of a clock face
/// with north at twelve, and the drawing makes that visible: where does this
/// line sit going clockwise round from north, and what do you have to do to
/// the angle written on the drawing to get there?
class WhichRuleTurnsItGame extends StatefulWidget {
  const WhichRuleTurnsItGame({super.key});

  @override
  State<WhichRuleTurnsItGame> createState() => _WhichRuleTurnsItGameState();
}

@immutable
class RuleRound {
  const RuleRound({
    required this.subject,
    required this.setting,
    required this.bearing,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Bearing bearing;
  final String why;
  final String source;

  /// Read off the quadrant rather than declared beside it.
  Rule get answer => bearing.rule;
}

const azimuthRounds = <RuleRound>[
  RuleRound(
    subject: 'the lesson\'s own line',
    setting: 'The line runs N 52° E off the station.',
    bearing: Bearing(Quad.ne, 52),
    why:
        'The azimuth is that same 52. Going clockwise from north, this line '
        'is the first quadrant you reach, and the angle off the meridian IS '
        'the angle clockwise from north. Nothing to add or subtract. The '
        'north-east quadrant is the only one where a bearing and an azimuth '
        'read the same, which is why it makes such a comfortable first '
        'problem and such a poor guide to the others.',
    source: 'surv-adb-q1',
  ),
  RuleRound(
    subject: 'the lesson\'s own warning',
    setting: 'The line runs S 45° W.',
    bearing: Bearing(Quad.sw, 45),
    why:
        '180 plus it, giving 225. This is the one the lesson warns about. '
        'Due south is already 180 clockwise from north, and this line has '
        'kept going past south toward the west, so the angle is added on top '
        'of 180. Taking it off 360 instead would put it in the north-west '
        'quadrant, on the opposite side of the sheet.',
    source: 'surv-adb-q1',
  ),
  RuleRound(
    subject: 'south and east',
    setting: 'The line runs S 30° E.',
    bearing: Bearing(Quad.se, 30),
    why:
        '180 minus it, giving 150. Coming round clockwise from north you '
        'reach this line BEFORE due south, so its azimuth is short of 180, '
        'and the 30 it leans back toward the east is exactly how short. Any '
        'south-east bearing lands between 90 and 180.',
    source: 'surv-adb-q1',
  ),
  RuleRound(
    subject: 'north and west',
    setting: 'The line runs N 68° W.',
    bearing: Bearing(Quad.nw, 68),
    why:
        '360 minus it, giving 292. This is the last quadrant you meet going '
        'clockwise, so the azimuth is almost the whole way round, and the '
        'angle off north is how far short of a full turn it stops. Every '
        'north-west bearing lands between 270 and 360.',
    source: 'surv-adb-q1',
  ),
  RuleRound(
    subject: 'nearly due east',
    setting: 'The line runs N 85° E.',
    bearing: Bearing(Quad.ne, 85),
    why:
        'That same 85, because it is still a north-east line however close '
        'to due east it gets. A large angle does not push a bearing into the '
        'next quadrant: the two letters do that, and only the two letters. '
        'At exactly 90 it would be due east, azimuth 90, and the quadrants '
        'either side of it agree on that.',
    source: 'surv-adb-q1',
  ),
  RuleRound(
    subject: 'a hair west of south',
    setting: 'The line runs S 5° W.',
    bearing: Bearing(Quad.sw, 5),
    why:
        '180 plus it, giving 185. A tiny angle in the south-west quadrant is '
        'still a south-west bearing, and its azimuth is a little MORE than '
        '180, not a little less. If the answer you write down is under 180 '
        'for a line pointing down and to the left, the rule went in '
        'backwards.',
    source: 'surv-adb-q1',
  ),
];

class _WhichRuleTurnsItGameState extends State<WhichRuleTurnsItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-rule-turns-it',
    chapterId: 'surveying',
    total: azimuthRounds.length,
    sourceProblemIdOf: (round) => azimuthRounds[round].source,
  )..addListener(_onSession);

  Rule? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RuleRound get _round => azimuthRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Rule Turns It',
        closing:
            'Azimuths run clockwise from north, so where a line sits in that '
            'turn settles the conversion. North-east is the azimuth already. '
            'South-east stops short of 180, so take it off 180. South-west '
            'has gone past 180, so add it on. North-west is nearly a full '
            'turn, so take it off 360. Picture the clock face and you will '
            'never need the list.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: azimuthBrief,
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
            'WHICH RULE MAKES IT AN AZIMUTH',
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
            height: 230,
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
                  painter: RosePainter(
                    shots: [Shot(bearing: r.bearing, name: 'B')],
                    arcOn: 0,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Rule.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE RULE' : 'ANOTHER RULE',
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
