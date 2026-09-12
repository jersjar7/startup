import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'tension_figures.dart';

/// How Big Is the Hole — the second item for `steel-tension`.
///
/// The net area is where tension members are most often lost, and never for
/// want of algebra: the hole is bigger than the bolt, the allowance is a
/// width rather than an area, and only the bolts on ONE cross-section come
/// off it. Each of those is a sentence, and each of them is a wrong answer
/// in the lesson's own choices.
class HowBigIsTheHoleGame extends StatefulWidget {
  const HowBigIsTheHoleGame({super.key});

  @override
  State<HowBigIsTheHoleGame> createState() => _HowBigIsTheHoleGameState();
}

@immutable
class HoleRound {
  const HoleRound({
    required this.subject,
    required this.asked,
    required this.tie,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Tie tie;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const holeRounds = <HoleRound>[
  HoleRound(
    subject: 'the lesson\'s own plate',
    asked:
        'A plate with two seven-eighths inch bolts on one cross-section. What '
        'comes off the width for each of them?',
    tie: Tie(
        width: 10,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.875,
        fy: 36,
        fu: 58),
    options: [
      'The bolt diameter plus an eighth of an inch',
      'The bolt diameter exactly',
      'The bolt diameter plus a sixteenth',
      'Nothing, because the bolt fills the hole',
    ],
    answer: 0,
    why:
        'The bolt plus an eighth. A seven-eighths bolt therefore costs a full '
        'inch of width, which is one of those numbers worth noticing because '
        'it comes out so tidily. Subtracting only the bolt diameter is the '
        'wrong answer the lesson lists, and it flatters the member every '
        'time.',
    source: 'str-st-q2',
  ),
  HoleRound(
    subject: 'where the eighth comes from',
    asked: 'Why an eighth of an inch rather than nothing?',
    tie: Tie(
        width: 10,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.875,
        fy: 36,
        fu: 58),
    options: [
      'A sixteenth for clearance and another for the damage punching does',
      'To allow for the bolt stretching under load',
      'To allow for corrosion over the life of the member',
      'It is a safety factor, and the code rounds it off',
    ],
    answer: 0,
    why:
        'A sixteenth of clearance so the bolt goes in at all, and another '
        'sixteenth written off because punching a hole tears the steel round '
        'its edge. Neither has anything to do with safety factors: they are '
        'both statements about the hole that actually gets made in the shop.',
    source: 'str-st-q2',
  ),
  HoleRound(
    subject: 'two bolts, one line',
    asked:
        'Two bolts sit side by side on the same cross-section of the plate. '
        'How much width is lost there?',
    tie: Tie(
        width: 10,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.875,
        fy: 36,
        fu: 58),
    options: [
      'Both allowances, since the tear would pass through both holes',
      'One allowance, since a tear only needs one hole',
      'Both, but halved, because the bolts share the load',
      'Neither: a cross-section with bolts in it is not the weak one',
    ],
    answer: 0,
    why:
        'Both. The net section is a cut right across the member, and the cut '
        'that matters goes through every hole on that line. Two one-inch '
        'allowances take two inches off a ten inch plate, leaving eight, and '
        'that eight is what gets multiplied by the thickness.',
    source: 'str-st-q2',
  ),
  HoleRound(
    subject: 'one behind the other',
    asked:
        'Now the two bolts are one BEHIND the other, along the line of pull, '
        'each on its own cross-section. What comes off?',
    tie: Tie(
        width: 10,
        thickness: 0.5,
        holes: 1,
        trailing: 1,
        boltDiameter: 0.875,
        fy: 36,
        fu: 58),
    options: [
      'One allowance: only one hole lies on any one cross-section',
      'Both allowances, as before',
      'Both, because the load passes through both',
      'Neither, because the holes do not line up',
    ],
    answer: 0,
    why:
        'One. The net area is worked out on a cut, and a cut across the plate '
        'here meets one hole at a time. Bolts strung out along the pull do '
        'not add up: they share the load between cross-sections instead of '
        'weakening a single one, which is a large part of why connections are '
        'made long rather than wide.',
    source: 'str-st-q2',
  ),
  HoleRound(
    subject: 'width or area',
    asked:
        'The allowance for a hole is an inch. What does that inch come off?',
    tie: Tie(
        width: 10,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.875,
        fy: 36,
        fu: 58),
    options: [
      'The WIDTH, and the reduced width is then multiplied by the thickness',
      'The area, in square inches',
      'The thickness of the plate',
      'The gross area, as a percentage',
    ],
    answer: 0,
    why:
        'The width. Take the allowances off the width first and multiply by '
        'the thickness afterward, which is why a thicker plate loses more '
        'AREA to the same bolt than a thin one does. Subtracting the '
        'allowance from the area directly gives a number that is wrong by the '
        'thickness, and on a half inch plate it is wrong by a factor of two.',
    source: 'str-st-q2',
  ),
  HoleRound(
    subject: 'the other check',
    asked:
        'Does the hole allowance change the area used in the YIELDING check '
        'as well?',
    tie: Tie(
        width: 10,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.875,
        fy: 36,
        fu: 58),
    options: [
      'No: yielding uses the gross area, holes and all',
      'Yes: every check uses the net area once there are holes',
      'Yes, but only half the allowance is taken off',
      'Only if there are more than two bolts',
    ],
    answer: 0,
    why:
        'No. The holes belong to the rupture check alone. Yielding is about '
        'the whole bar stretching along its length and the few inches beside '
        'the holes do not decide that, so the gross area stands. Keeping the '
        'two areas apart is the whole of the bookkeeping in this lesson.',
    source: 'str-st-q1',
  ),
];

class _HowBigIsTheHoleGameState extends State<HowBigIsTheHoleGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-big-is-the-hole',
    chapterId: 'structural',
    total: holeRounds.length,
    sourceProblemIdOf: (round) => holeRounds[round].source,
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

  HoleRound get _round => holeRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Big Is the Hole',
        closing:
            'A hole costs the bolt diameter plus an eighth: a sixteenth of '
            'clearance and a sixteenth of damage. The allowance comes off the '
            'WIDTH and the answer is multiplied by the thickness afterward. '
            'Only the holes on one cross-section come off that section, so '
            'bolts strung out along the pull do not add up. And none of it '
            'touches the gross area the yielding check uses.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: netAreaBrief,
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
            'WHAT COMES OFF THE WIDTH',
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
            height: 178,
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
                  painter: TiePainter(
                    tie: r.tie,
                    showSections: false,
                    answered: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$A_n = \left[b_g - \Sigma\left(d_b + \tfrac{1}{8}\right)\right] t$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
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
