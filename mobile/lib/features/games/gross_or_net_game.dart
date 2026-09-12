import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'tension_figures.dart';

/// Gross or Net — the first item for `steel-tension`.
///
/// A tension member has two ways of failing and both have to be checked: the
/// whole bar stretching until it yields, and the bar tearing across the line
/// of holes. They use different areas, different stresses and different
/// reduction factors, and the smaller of the two answers is the one the
/// member is worth. Nothing here needs arithmetic, and every wrong choice in
/// the lesson comes from mixing the two up.
class GrossOrNetGame extends StatefulWidget {
  const GrossOrNetGame({super.key});

  @override
  State<GrossOrNetGame> createState() => _GrossOrNetGameState();
}

@immutable
class LimitRound {
  const LimitRound({
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

const limitRounds = <LimitRound>[
  LimitRound(
    subject: 'the yielding check',
    asked:
        'This bar is bolted at one end through two holes. Which area does the '
        'YIELDING check use?',
    tie: Tie(
        width: 8,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.75,
        fy: 50,
        fu: 65),
    options: [
      'The gross area, with nothing taken off for the holes',
      'The area left after the holes are taken off',
      'The gross area, less half the holes',
      'Whichever of the two is the smaller',
    ],
    answer: 0,
    why:
        'The gross area, holes and all. Yielding is something the whole '
        'length of the bar does: it stretches, visibly, over its entire '
        'length. A couple of inches of steel yielding beside a hole does not '
        'make a member unusable, so the code checks yielding on the section '
        'that represents most of the bar, which is the one away from the '
        'connection.',
    source: 'str-st-q1',
  ),
  LimitRound(
    subject: 'the rupture check',
    asked: 'And which area does the RUPTURE check use?',
    tie: Tie(
        width: 8,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.75,
        fy: 50,
        fu: 65),
    options: [
      'The effective net area, through the line of holes',
      'The gross area, since the bolts fill the holes',
      'The gross area less one hole, whatever the number of bolts',
      'The average of the gross and net areas',
    ],
    answer: 0,
    why:
        'The effective net area, taken across the holes. Rupture is a tear at '
        'one cross-section, so it is decided by the weakest one, and that is '
        'where the steel has been taken away. The bolts do not help: a bolt '
        'passing through a hole carries its own load and does nothing to '
        'restore the plate around it.',
    source: 'str-st-q3',
  ),
  LimitRound(
    subject: 'the two factors',
    asked:
        'Which reduction factor goes with each check?',
    tie: Tie(
        width: 8,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.75,
        fy: 50,
        fu: 65),
    options: [
      'Yielding 0.90 and rupture 0.75',
      'Yielding 0.75 and rupture 0.90',
      '0.90 for both, since both are tension',
      '0.75 for both, since both involve a connection',
    ],
    answer: 0,
    why:
        'Yielding 0.90, rupture 0.75. A yielding member sags and stretches '
        'and tells everybody what is happening; a ruptured one parts company '
        'without notice. The code leans harder on the failure that gives no '
        'warning, which is the same reasoning that gives concrete shear a '
        'smaller factor than concrete bending.',
    source: 'str-st-q3',
  ),
  LimitRound(
    subject: 'which one wins',
    asked:
        'This bar works out at 180 kips for yielding and 152 for rupture. '
        'What is the member worth?',
    tie: Tie(
        width: 8,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.75,
        fy: 50,
        fu: 65),
    options: [
      '152 kips: the smaller of the two, and rupture controls',
      '180 kips: yielding is the proper limit state for a tension member',
      '332 kips: the two add up',
      '166 kips: the average of the two',
    ],
    answer: 0,
    why:
        'The smaller, every time. Two limit states means two ways the member '
        'can be lost, and it is lost at whichever comes first. This is the '
        'lesson\'s own hard problem, and the answer is rupture even though '
        'the ultimate stress is well above the yield stress.',
    source: 'str-st-q3',
  ),
  LimitRound(
    subject: 'a bar with no holes',
    asked:
        'A welded bar with no holes anywhere. Is there still a rupture check '
        'to do?',
    tie: Tie(
        width: 6,
        thickness: 0.5,
        holes: 0,
        boltDiameter: 0.75,
        fy: 36,
        fu: 58),
    options: [
      'Yes, with the net area equal to the gross, and yielding will control',
      'No: with no holes there is nothing to rupture',
      'No: welded members are checked differently',
      'Yes, and rupture will control because the ultimate stress is higher',
    ],
    answer: 0,
    why:
        'Both checks are always made. With no holes the net area equals the '
        'gross, and then the comparison is 0.90 times the yield stress '
        'against 0.75 times the ultimate. For ordinary mild steel the first '
        'of those is the smaller, so yielding controls, which is why a bar '
        'with no holes is usually a yielding problem.',
    source: 'str-st-q1',
  ),
  LimitRound(
    subject: 'the thing that surprises people',
    asked:
        'The ultimate stress is well above the yield stress. So how does '
        'rupture ever control?',
    tie: Tie(
        width: 8,
        thickness: 0.5,
        holes: 2,
        boltDiameter: 0.75,
        fy: 50,
        fu: 65),
    options: [
      'Two things work against it: the holes take area away, and its factor '
          'is the smaller one',
      'It does not: rupture is only a formality',
      'Because the ultimate stress is measured differently',
      'Because bolts weaken the steel around them',
    ],
    answer: 0,
    why:
        'The area and the factor together. The ultimate stress may be a third '
        'higher than the yield stress, but the net area can easily be a '
        'quarter smaller and the factor is a sixth lower again, and the two '
        'together are usually enough to swallow the difference. That is why '
        'the lesson insists on running both checks rather than guessing which '
        'will win.',
    source: 'str-st-q3',
  ),
];

class _GrossOrNetGameState extends State<GrossOrNetGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'gross-or-net',
    chapterId: 'structural',
    total: limitRounds.length,
    sourceProblemIdOf: (round) => limitRounds[round].source,
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

  LimitRound get _round => limitRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Gross or Net',
        closing:
            'Two checks, always both. Yielding stretches the whole bar, so it '
            'uses the gross area with the yield stress and a factor of 0.90. '
            'Rupture tears one cross-section, so it uses the effective net '
            'area with the ultimate stress and a factor of 0.75. The member '
            'is worth the smaller of the two answers, and rupture wins more '
            'often than the stresses alone would suggest.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: twoLimitsBrief,
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
            'WHICH CHECK IS THIS',
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
            height: 190,
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
                  painter: TiePainter(tie: r.tie, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$0.90 F_y A_g \quad \text{and} \quad 0.75 F_u A_e$',
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
