import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'slope_figures.dart';

/// Steeper Than Its Friction — the first item for `slope-stability`.
///
/// A dry slope of cohesionless soil is the one case in the chapter with a
/// one-line answer: it stands as long as it is flatter than the friction
/// angle of the soil, and how deep or how heavy the soil is does not enter
/// into it at all. Everything cancels. That is worth having by heart, and it
/// is also worth knowing why so little of the rest of geotechnics is that
/// obliging.
class SteeperThanItsFrictionGame extends StatefulWidget {
  const SteeperThanItsFrictionGame({super.key});

  @override
  State<SteeperThanItsFrictionGame> createState() =>
      _SteeperThanItsFrictionGameState();
}

/// What the slope does.
enum Stands { holds, slides, onTheEdge }

@immutable
class BankRound {
  const BankRound({
    required this.subject,
    required this.asked,
    required this.bank,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Bank bank;
  final String why;
  final String source;

  /// The angles decide it.
  Stands get answer {
    final fs = bank.factorOfSafety;
    if ((fs - 1).abs() < 0.02) return Stands.onTheEdge;
    return fs > 1 ? Stands.holds : Stands.slides;
  }

  static String label(Stands which) => switch (which) {
        Stands.holds => 'It holds, with something in hand',
        Stands.slides => 'It slides',
        Stands.onTheEdge => 'It is exactly on the edge',
      };
}

const bankRounds = <BankRound>[
  BankRound(
    subject: 'the lesson\'s own slope',
    asked:
        'A dry sand slope at 20 degrees, in a soil whose friction angle is '
        '34. What does it do?',
    bank: Bank(slopeAngle: 20, friction: 34),
    why:
        'It holds, and comfortably: the factor of safety is the tangent of '
        'the friction angle over the tangent of the slope, which comes to '
        '1.85. The rule behind it is simpler than the arithmetic: a dry '
        'cohesionless slope stands as long as it is FLATTER than the friction '
        'angle of its soil.',
    source: 'geo-slp-q1',
  ),
  BankRound(
    subject: 'steeper than the soil allows',
    asked:
        'The same sand, but tipped up to 38 degrees. Now what?',
    bank: Bank(slopeAngle: 38, friction: 34),
    why:
        'It slides. Past the friction angle there is nothing left to hold the '
        'grains, and no amount of patience will keep the face standing: a '
        'dry sand cannot be piled steeper than its friction angle, which is '
        'why every heap of sand in the world has about the same slope.',
    source: 'geo-slp-q1',
  ),
  BankRound(
    subject: 'exactly at the angle',
    asked:
        'And at 34 degrees, exactly the friction angle of the soil?',
    bank: Bank(slopeAngle: 34, friction: 34),
    why:
        'Exactly on the edge, a factor of safety of one. This is the angle of '
        'repose: the slope a poured heap settles at on its own. Nothing is '
        'wrong with the arithmetic, but nobody designs to it, because being '
        'on the edge means any small thing at all pushes it over.',
    source: 'geo-slp-q1',
  ),
  BankRound(
    subject: 'a deeper slope',
    asked:
        'The same 20 degree slope in the same sand, but the soil is fifty '
        'feet deep instead of five. What changes?',
    bank: Bank(slopeAngle: 20, friction: 34),
    why:
        'Nothing at all: the same factor of safety, 1.85. The depth and the '
        'unit weight both cancel out of the dry cohesionless case, which is '
        'why the answer is a pair of angles and nothing else. A deeper slice '
        'weighs more, which drives it harder, and presses down harder, which '
        'holds it better, in exactly equal measure.',
    source: 'geo-slp-q1',
  ),
  BankRound(
    subject: 'a denser sand',
    asked:
        'The same 20 degree slope, but a well compacted sand with a friction '
        'angle of 40 degrees. What does it do?',
    bank: Bank(slopeAngle: 20, friction: 40),
    why:
        'It holds, and with more in hand than before: 2.3 rather than 1.85. '
        'Compacting a sand raises its friction angle, which is most of why '
        'fill is compacted at all. The slope has not changed and the soil in '
        'it has become better at staying put.',
    source: 'geo-slp-q1',
  ),
  BankRound(
    subject: 'a gentle slope in a poor soil',
    asked:
        'A loose silty sand with a friction angle of only 26 degrees, on a '
        'slope of 24. What does it do?',
    bank: Bank(slopeAngle: 24, friction: 26),
    why:
        'It holds, but barely: the factor of safety is about 1.1, and that is '
        'the sort of number that fails the first time anything changes. On '
        'the next card the same slope gets rained on, and 1.1 does not '
        'survive it.',
    source: 'geo-slp-q1',
  ),
];

class _SteeperThanItsFrictionGameState
    extends State<SteeperThanItsFrictionGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'steeper-than-its-friction',
    chapterId: 'geotechnical',
    total: bankRounds.length,
    sourceProblemIdOf: (round) => bankRounds[round].source,
  )..addListener(_onSession);

  Stands? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  BankRound get _round => bankRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Steeper Than Its Friction',
        closing:
            'A dry cohesionless slope stands as long as it is flatter than '
            'the friction angle of its soil, and the factor of safety is the '
            'tangent of one over the tangent of the other. Depth and unit '
            'weight cancel out completely: a deeper slice is driven harder '
            'and held harder in equal measure. At the friction angle exactly, '
            'the slope is at its angle of repose and its factor of safety is '
            'one, which is not a design.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: infiniteSlopeBrief,
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
            'DOES IT STAND',
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
            height: 204,
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
                  painter: BankPainter(bank: r.bank, answered: answered),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$FS = \frac{\tan\phi}{\tan\beta}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Stands.values) ...[
            _Choice(
              label: BankRound.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Stands.values.last) const SizedBox(height: 8),
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
