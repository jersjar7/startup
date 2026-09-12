import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'superelevation_figures.dart';

/// How Much Bank — the only new item for `horizontal-curves`.
///
/// The curve geometry in this lesson, the radius against the degree of
/// curve and the tangent out to the PI, is already taught in the surveying
/// chapter. Superelevation is not, and it has three wrong answers of its
/// own: forgetting the friction, leaving the rate as a decimal, and
/// reporting the friction factor itself.
class HowMuchBankGame extends StatefulWidget {
  const HowMuchBankGame({super.key});

  @override
  State<HowMuchBankGame> createState() => _HowMuchBankGameState();
}

@immutable
class TiltRound {
  const TiltRound({
    required this.subject,
    required this.asked,
    required this.curve,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Superelevation curve;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

/// The lesson's own curve: 45 mph round 600 ft with a side friction factor
/// of 0.15. The curve asks for 0.225 and the tilt supplies 7.5 per cent.
const _theCurve =
    Superelevation(speed: 45, radius: 600, friction: 0.15);

/// The same curve at twice the speed: four times the demand.
const _fast = Superelevation(speed: 90, radius: 600, friction: 0.15);

/// And a curve twice as flat at the original speed.
const _flatter =
    Superelevation(speed: 45, radius: 1200, friction: 0.15);

const tiltRounds = <TiltRound>[
  TiltRound(
    subject: 'the two things holding the car on',
    asked:
        'A car goes round a curve at speed. What keeps it from sliding off '
        'the outside?',
    curve: _theCurve,
    options: [
      'The tilt of the pavement alone',
      'The grip of the tires sideways, and the tilt of the pavement, together',
      'The weight of the car alone',
      'The engine',
    ],
    answer: 1,
    why:
        'Both together. The tires can hold a certain amount sideways, and '
        'tilting the road toward the inside of the curve leans the car into '
        'the turn so its own weight helps. The formula simply adds the two '
        'and sets them against what the curve demands.',
    source: 'trans-hc-q3',
  ),
  TiltRound(
    subject: 'what is left for the pavement',
    asked:
        'This curve asks for 0.225 and the tires can hold 0.15 of it. What '
        'does the tilt have to supply?',
    curve: _theCurve,
    options: [
      '0.225: the tilt carries all of it',
      '0.375: the two add up',
      '0.075, which written as a rate is 7.5 per cent',
      '0.15: the same as the tires',
    ],
    answer: 2,
    why:
        'The remainder, 0.075, which is a superelevation rate of 7.5 per '
        'cent: about nine inches of drop across a twelve foot lane. The '
        'friction is not an extra requirement, it is help already in hand, so '
        'it comes off what the curve asks for.',
    source: 'trans-hc-q3',
  ),
  TiltRound(
    subject: 'a student who forgot the tires',
    asked:
        'Another student reports 22.5 per cent for this curve. What did they '
        'leave out?',
    curve: _theCurve,
    options: [
      'The side friction: they asked the pavement for the whole demand',
      'The design speed',
      'The radius',
      'The conversion from per cent',
    ],
    answer: 0,
    why:
        'The friction. Twenty two and a half per cent is what the curve asks '
        'for altogether, and no road is built at that tilt: a stopped vehicle '
        'would slide into the ditch and any ice at all would be lethal. An '
        'answer above about twelve per cent is a sign that the friction has '
        'been dropped.',
    source: 'trans-hc-q3',
  ),
  TiltRound(
    subject: 'a decimal where a rate belongs',
    asked:
        'A third student reports 0.075 per cent. What is the matter with it?',
    curve: _theCurve,
    options: [
      'Nothing: it is the same number',
      'They left the answer as a decimal and then called it a percentage',
      'They used the wrong friction factor',
      'They divided by the radius twice',
    ],
    answer: 1,
    why:
        'The 0.075 is right as a decimal and wrong as a per cent: the two '
        'differ by a factor of a hundred. The formula carries a 0.01 in front '
        'of the rate for exactly this reason, so that the rate can be quoted '
        'the way a drawing quotes it, in per cent.',
    source: 'trans-hc-q3',
  ),
  TiltRound(
    subject: 'the same curve, faster',
    asked:
        'The design speed doubles on the same curve. What happens to what the '
        'curve asks for?',
    curve: _fast,
    options: [
      'It doubles',
      'It is unchanged',
      'It halves',
      'It quadruples, because the speed is squared',
    ],
    answer: 3,
    why:
        'Four times, because the speed is squared. That is why a curve that '
        'is comfortable at 45 mph is frightening at 90 rather than merely '
        'twice as demanding, and why raising a design speed usually means '
        'flattening the curve rather than tilting it further.',
    source: 'trans-hc-q3',
  ),
  TiltRound(
    subject: 'flattening it instead',
    asked:
        'The same speed, but the curve is laid out with twice the radius. '
        'What happens to the demand?',
    curve: _flatter,
    options: [
      'It halves, since the radius is on the bottom with no power on it',
      'It quarters',
      'It doubles',
      'Nothing changes',
    ],
    answer: 0,
    why:
        'It halves, straight. Radius and speed are the two design levers, and '
        'they are not equally strong: doubling the radius halves the demand, '
        'while doubling the speed quadruples it. Friction is not a lever at '
        'all, since it belongs to the tire and the pavement rather than to '
        'the designer.',
    source: 'trans-hc-q3',
  ),
];

class _HowMuchBankGameState extends State<HowMuchBankGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-much-bank',
    chapterId: 'transportation',
    total: tiltRounds.length,
    sourceProblemIdOf: (round) => tiltRounds[round].source,
  );

  int? _picked;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  TiltRound get _round => tiltRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Much Bank',
        closing:
            'The curve asks for the speed squared over fifteen times the '
            'radius. The tires supply what they can and the tilt of the '
            'pavement supplies the rest, quoted in per cent. Forget the '
            'friction and the answer comes out three times too big. Leave it '
            'a decimal and it comes out a hundred times too small.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: superelevationBrief,
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
            'THE TILT ON THE CURVE',
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
                  painter: SuperPainter(
                    curve: r.curve,
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
