import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'hazen_figures.dart';

/// Smoother or Rougher — the third item for `pipe-systems-weirs`.
///
/// Hazen-Williams runs on a single coefficient C, and it runs the opposite
/// way to Manning's n, which sits two pages away in the same handbook and
/// behaves backward. A bigger C is a SMOOTHER pipe carrying MORE water, and
/// it sits on the top of the equation in the first power, so the flows are
/// simply in the ratio of the two coefficients. The lesson's own problem
/// names both halves of that as traps: getting the direction wrong, and
/// raising the ratio to one of the powers that belong to other terms.
class SmootherOrRougherGame extends StatefulWidget {
  const SmootherOrRougherGame({super.key});

  @override
  State<SmootherOrRougherGame> createState() => _SmootherOrRougherGameState();
}

/// Which main carries the most, everything else being equal.
enum Carries { top, bottom, same }

extension CarriesWords on Carries {
  String get plain => switch (this) {
        Carries.top => 'Main A, the top one',
        Carries.bottom => 'Main B, the bottom one',
        Carries.same => 'Neither: the same flow',
      };
}

@immutable
class CarryRound {
  const CarryRound({
    required this.subject,
    required this.top,
    required this.bottom,
    required this.why,
    required this.source,
  });

  final String subject;
  final Main top;
  final Main bottom;
  final String why;
  final String source;

  /// Everything but C is equal in every round, so the flows are in the
  /// ratio of the coefficients. Worked out rather than declared.
  Carries get answer {
    final gap = top.carries - bottom.carries;
    if (gap.abs() / bottom.carries < 0.001) return Carries.same;
    return gap > 0 ? Carries.top : Carries.bottom;
  }

  double get ratio => top.carries > bottom.carries
      ? top.carries / bottom.carries
      : bottom.carries / top.carries;
}

const carryRounds = <CarryRound>[
  CarryRound(
    subject: 'the lesson\'s own pair',
    top: Main(material: 'new PVC', coefficient: 150),
    bottom: Main(material: '20-year-old cast iron', coefficient: 100),
    why:
        'The PVC, by exactly half again. C sits on top of Hazen-Williams in '
        'the FIRST power, so with the same diameter, length and gradient the '
        'flows are simply in the ratio of the coefficients: 150 over 100 is '
        '1.50. The lesson offers 1.22 as a wrong answer, which is that ratio '
        'raised to 0.63, a power that belongs to the hydraulic radius and not '
        'to C.',
    source: 'wr-psw-q3',
  ),
  CarryRound(
    subject: 'two mains of the same age',
    top: Main(material: 'ductile iron', coefficient: 140),
    bottom: Main(material: 'asbestos-cement', coefficient: 140),
    why:
        'Neither: both are 140 and both carry the same. Two quite different '
        'materials can land on the same coefficient, because C is a measure '
        'of how the water finds the wall rather than of what the wall is made '
        'from. There is no credit in this question for knowing which pipe is '
        'the more modern.',
    source: 'wr-psw-q3',
  ),
  CarryRound(
    subject: 'a main that has been in the ground a while',
    top: Main(material: 'old cast iron', coefficient: 100),
    bottom: Main(material: 'new cast iron', coefficient: 130),
    why:
        'The new one. The same pipe loses coefficient as it ages: tubercles '
        'and deposits build on the wall and the C for cast iron drops from '
        'about 130 when it goes in to about 100 after twenty years. That is a '
        'quarter of the capacity gone, which is why design is done on the '
        'aged value rather than the shiny one.',
    source: 'wr-psw-q3',
  ),
  CarryRound(
    subject: 'the ratio worth recognizing',
    top: Main(material: 'plastic', coefficient: 150),
    bottom: Main(material: 'badly tuberculated iron', coefficient: 75),
    why:
        'The plastic, at exactly twice the flow. Twice the C is twice the '
        'water, with no power to apply and no square root to take, which is '
        'the one thing that makes Hazen-Williams pleasant to use. Contrast '
        'Manning\'s, where the roughness sits UNDERNEATH: there, twice the n '
        'is half the flow, and the two conventions run in opposite '
        'directions.',
    source: 'wr-psw-q3',
  ),
  CarryRound(
    subject: 'a small difference',
    top: Main(material: 'concrete', coefficient: 130),
    bottom: Main(material: 'ductile iron', coefficient: 140),
    why:
        'The ductile iron, but only by about 8 percent. Most of the '
        'coefficients on the list sit between 100 and 150, so picking the '
        'wrong one off the table is rarely catastrophic. Picking the wrong '
        'DIRECTION is: reading a high C as a rough pipe turns an 8 percent '
        'error into a factor of 1.16 in the other direction.',
    source: 'wr-psw-q3',
  ),
  CarryRound(
    subject: 'the same coefficient, different sizes on the label',
    top: Main(material: 'PVC', coefficient: 150),
    bottom: Main(material: 'polyethylene', coefficient: 150),
    why:
        'Neither, again. Both plastics run at 150 and the question gives '
        'them the same diameter, length and gradient, so there is nothing '
        'left to separate them. When a Hazen-Williams question has no '
        'difference in C, the answer is that there is no difference in flow: '
        'the equation has nowhere else to put one.',
    source: 'wr-psw-q3',
  ),
];

class _SmootherOrRougherGameState extends State<SmootherOrRougherGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'smoother-or-rougher',
    chapterId: 'water-resources',
    total: carryRounds.length,
    sourceProblemIdOf: (round) => carryRounds[round].source,
  )..addListener(_onSession);

  Carries? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CarryRound get _round => carryRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Smoother or Rougher',
        closing:
            'A bigger Hazen-Williams C is a smoother pipe carrying more '
            'water, which is the opposite of Manning\'s n underneath. C '
            'enters in the first power, so two otherwise identical mains '
            'carry flows in the plain ratio of their coefficients: no 0.63, '
            'no 0.54, no square root. Those powers belong to the hydraulic '
            'radius and the gradient.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: hazenBrief,
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
            'WHICH MAIN CARRIES MORE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          const Text(
            'Same diameter, same length, same hydraulic gradient. The only '
            'difference between the two is what they are made of.',
            style: TextStyle(
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
                  painter: MainsPainter(
                    top: r.top,
                    bottom: r.bottom,
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
              r'$Q = k_1 C A R_H^{0.63} S_v^{0.54}$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Carries.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Carries.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SMOOTHER ONE' : 'THE OTHER WAY',
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
