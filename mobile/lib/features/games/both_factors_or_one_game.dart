import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'rc_figures.dart';

/// Both Factors or One — the first item for `rc-columns`.
///
/// The column capacity formula carries two multipliers doing two different
/// jobs, and the lesson's own problem offers every way of dropping one of
/// them as a wrong answer. The 0.80 is not a resistance factor: it is an
/// allowance for the eccentricity no real column escapes, it belongs to
/// columns alone, and it changes to 0.85 when a spiral is holding the
/// concrete in. Phi is the usual reduction, and for a tied column in
/// compression it is 0.65, the smallest one in the code.
class BothFactorsOrOneGame extends StatefulWidget {
  const BothFactorsOrOneGame({super.key});

  @override
  State<BothFactorsOrOneGame> createState() => _BothFactorsOrOneGameState();
}

@immutable
class FactorRound2 {
  const FactorRound2({
    required this.subject,
    required this.asked,
    required this.cage,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Cage cage;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const columnFactorRounds = <FactorRound2>[
  FactorRound2(
    subject: 'the lesson\'s own column',
    asked:
        'A short TIED column, loaded straight down the middle as far as the '
        'drawing shows. What multiplies the bracketed capacity?',
    cage: Cage(width: 16, depth: 16, bars: 8, barArea: 1.0),
    options: [
      'Both: 0.80 for the eccentricity and 0.65 for the resistance factor',
      'Only the 0.65 resistance factor',
      'Only the 0.80 eccentricity allowance',
      'Neither: the bracket is the design capacity',
    ],
    answer: 0,
    why:
        'Both, and the lesson offers all three ways of getting it wrong as '
        'choices. The bracket is the raw squash load of the section, concrete '
        'plus steel. The 0.80 knocks it down for an eccentricity nobody can '
        'avoid, and phi knocks it down again for everything the code does not '
        'trust. Multiply by 0.52 in one go if you like, but do not drop '
        'either half.',
    source: 'str-rcc-q1',
  ),
  FactorRound2(
    subject: 'what the 0.80 is for',
    asked:
        'The drawing shows the load dead center. So why is the capacity cut '
        'by a fifth before phi is even applied?',
    cage: Cage(width: 16, depth: 16, bars: 8, barArea: 1.0),
    options: [
      'Because no real column is loaded perfectly centrally, and a small '
          'eccentricity is assumed whether the drawing shows one or not',
      'Because the concrete never reaches its test strength in a column',
      'Because the bars buckle before the concrete crushes',
      'Because it is the resistance factor for compression',
    ],
    answer: 0,
    why:
        'Because the load is never really where the drawing puts it. Beams '
        'land off center, columns lean a little, floors are built a little '
        'out of plumb, and the resulting small moment eats into the axial '
        'capacity. Rather than ask for a moment nobody can predict, the code '
        'takes a flat fifth off. It is an eccentricity allowance, not a '
        'material factor, which is why phi still follows it.',
    source: 'str-rcc-q1',
  ),
  FactorRound2(
    subject: 'a spiral instead of ties',
    asked:
        'The same column, but with a spiral wrapped round the bars instead of '
        'separate ties. What changes?',
    cage: Cage(width: 16, depth: 16, bars: 8, barArea: 1.0, spiral: true),
    options: [
      'Both numbers improve: 0.85 instead of 0.80, and phi of 0.75 instead of '
          '0.65',
      'Nothing: the spiral is only there to hold the bars while it is poured',
      'Only phi improves, to 0.75',
      'Only the allowance improves, to 0.85',
    ],
    answer: 0,
    why:
        'Both improve, and for one reason: a spiral confines the concrete. '
        'Once the core is squeezed from the sides it can take more before it '
        'gives way, and when it does give way it does so gradually rather '
        'than bursting the cover off in one go. The code rewards that '
        'toughness at both ends of the formula. A spiral column is the more '
        'forgiving of the two, and it is the one used where earthquakes are '
        'expected.',
    source: 'str-rcc-q1',
  ),
  FactorRound2(
    subject: 'the beam next door',
    asked:
        'A beam in the same building is being checked for bending. Does its '
        'capacity get the 0.80 as well?',
    cage: Cage(width: 14, depth: 20, bars: 6, barArea: 1.0),
    options: [
      'No: the 0.80 belongs to columns alone',
      'Yes: every concrete member gets it',
      'Yes, but only if the beam also carries axial load',
      'No, but the beam gets 0.85 instead',
    ],
    answer: 0,
    why:
        'Columns alone. A beam is already being checked for the moment it '
        'carries, so there is nothing accidental left to allow for. The '
        'lesson makes this a spotting rule and it is worth keeping: if a '
        'problem hands you a 0.80, it is talking about a column, whatever '
        'else the stem says.',
    source: 'str-rcc-q1',
  ),
  FactorRound2(
    subject: 'why phi is so small here',
    asked:
        'Bending gets a phi of 0.90 and a tied column in compression gets '
        '0.65. Why the difference?',
    cage: Cage(width: 16, depth: 16, bars: 8, barArea: 1.0),
    options: [
      'A column crushing gives no warning and takes the floors above with it',
      'Because concrete is weaker in compression than in tension',
      'Because columns are usually built less accurately',
      'Because a column carries more load than a beam',
    ],
    answer: 0,
    why:
        'Because of what failure looks like. A beam under-reinforced for '
        'bending sags and cracks for a long time before it lets go. A '
        'compression-controlled column simply crushes, without notice, and '
        'everything it was holding up comes down with it. The code answers '
        'that with the smallest phi it has.',
    source: 'str-rcc-q3',
  ),
  FactorRound2(
    subject: 'is it big enough',
    asked:
        'A column of this size works out at 793 kips of design capacity and '
        'the factored load on it is 550 kips. What is the verdict?',
    cage: Cage(width: 14, depth: 20, bars: 6, barArea: 1.0),
    options: [
      'It is adequate: the design capacity is the one to compare against',
      'It fails: the bracketed capacity should be compared instead',
      'It cannot be judged without an interaction diagram',
      'It is adequate, but only because the load is axial',
    ],
    answer: 0,
    why:
        'Adequate, and the comparison is against the DESIGN capacity, the '
        'number with both multipliers already in it. An interaction diagram '
        'is what you reach for when there is a real moment to carry as well; '
        'for a straight axial question the formula is the whole story, which '
        'is exactly what the lesson says.',
    source: 'str-rcc-q3',
  ),
];

class _BothFactorsOrOneGameState extends State<BothFactorsOrOneGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'both-factors-or-one',
    chapterId: 'structural',
    total: columnFactorRounds.length,
    sourceProblemIdOf: (round) => columnFactorRounds[round].source,
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

  FactorRound2 get _round => columnFactorRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Both Factors or One',
        closing:
            'A tied column carries two multipliers and both are needed: 0.80 '
            'for the eccentricity no real column escapes, then 0.65 because '
            'crushing gives no warning. A spiral earns 0.85 and 0.75 by '
            'confining the concrete. The 0.80 is for columns only, so seeing '
            'it in a problem tells you what you are looking at, and the '
            'number to compare the factored load against is the one with both '
            'multipliers already in it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: columnFactorBrief,
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
            'WHAT MULTIPLIES THE CAPACITY',
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
            height: 192,
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
                  painter: CagePainter(cage: r.cage, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\phi P_n = 0.80\phi\left[0.85 f_c^{\prime}(A_g - A_{st}) + '
              r'A_{st} f_y\right]$',
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
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
