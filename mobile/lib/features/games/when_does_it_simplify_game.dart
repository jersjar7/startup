import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'phase_figures.dart';

/// When Does It Simplify — the second item for `phase-relations`.
///
/// One relationship ties the two sides of the phase diagram together, and
/// the lesson's own shortcut comes out of it: saturation times void ratio
/// equals water content times specific gravity, so at full saturation the
/// void ratio is just w times Gs. The exam hands out marks for knowing when
/// that shortcut is allowed, and takes them back for using a percentage
/// where a decimal belongs.
class WhenDoesItSimplifyGame extends StatefulWidget {
  const WhenDoesItSimplifyGame({super.key});

  @override
  State<WhenDoesItSimplifyGame> createState() =>
      _WhenDoesItSimplifyGameState();
}

@immutable
class MasterRound {
  const MasterRound({
    required this.subject,
    required this.asked,
    required this.soil,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asked;
  final Soil soil;
  final List<String> options;
  final int answer;
  final String why;
  final String source;
}

const masterRounds = <MasterRound>[
  MasterRound(
    subject: 'the lesson\'s own sample',
    asked:
        'A sample is FULLY SATURATED, with a water content of 20 per cent and '
        'a specific gravity of 2.70. What is the void ratio?',
    soil: Soil(gs: 2.70, water: 0.20, voidRatio: 0.54),
    options: [
      'The water content times the specific gravity, 0.54',
      'The water content itself, 0.20',
      'The specific gravity itself, 2.70',
      'It cannot be found without the unit weight',
    ],
    answer: 0,
    why:
        'At full saturation the master relationship loses its S and leaves e '
        'equal to w times Gs, which is 0.54 here. That one substitution '
        'unlocks the void ratio from two numbers a lab reports as a matter of '
        'routine, and the lesson calls it out for exactly that reason.',
    source: 'geo-pr-q1',
  ),
  MasterRound(
    subject: 'when the shortcut is allowed',
    asked:
        'A second sample has the same water content and specific gravity, but '
        'the stem does NOT say it is saturated. Can you still say the void '
        'ratio is w times Gs?',
    soil: Soil(gs: 2.65, water: 0.15, voidRatio: 0.586),
    options: [
      'No: without full saturation the S stays in, and the void ratio is '
          'larger than w times Gs',
      'Yes: the relationship holds whatever the saturation',
      'Yes, as long as the soil is below the water table',
      'No, and nothing about the void ratio can be said at all',
    ],
    answer: 0,
    why:
        'No. With air still in the voids, S is less than one and the void '
        'ratio is w times Gs DIVIDED by S, which makes it bigger. Assuming '
        'saturation when the stem never claimed it is the commonest way to '
        'get a phase problem wrong, and the answer always comes out on the '
        'wrong side.',
    source: 'geo-pr-q2',
  ),
  MasterRound(
    subject: 'per cent or decimal',
    asked:
        'Somebody puts the water content into the master relationship as 20 '
        'rather than 0.20. What comes out?',
    soil: Soil(gs: 2.70, water: 0.20, voidRatio: 0.54),
    options: [
      'A void ratio a hundred times too big, which is 54 rather than 0.54',
      'A void ratio a hundred times too small',
      'The right answer, since the units cancel',
      'A saturation over 100 per cent, which is the giveaway',
    ],
    answer: 0,
    why:
        'A hundred times too big. The lesson makes a point of this because '
        'the formula takes the DECIMAL and the lab reports the percentage, so '
        'the mistake is a natural one. A void ratio of 54 is absurd on its '
        'face: real ones run from about 0.3 in dense sand to perhaps 3 in a '
        'very soft clay, so a sanity check catches it at once.',
    source: 'geo-pr-q1',
  ),
  MasterRound(
    subject: 'what saturation really says',
    asked:
        'Two samples have the same void ratio, one at 60 per cent saturation '
        'and one at 100. What is different about them?',
    soil: Soil(gs: 2.65, water: 0.15, voidRatio: 0.586),
    options: [
      'The wetter one has water where the other has air, so it weighs more '
          'with the same volume',
      'The wetter one has more void space',
      'The wetter one has less solid',
      'Nothing: saturation is a property of the water, not the soil',
    ],
    answer: 0,
    why:
        'Same voids, different contents. Saturation says how much of the '
        'existing void space holds water rather than air, so filling it '
        'changes the weight and leaves every volume alone. That is why the '
        'saturated unit weight is the heaviest of the four and the void ratio '
        'does not budge.',
    source: 'geo-pr-q2',
  ),
  MasterRound(
    subject: 'going the other way',
    asked:
        'A saturated sample gives a void ratio of 0.714 and a specific '
        'gravity of 2.72. What is the water content?',
    soil: Soil(gs: 2.72, water: 0.263, voidRatio: 0.714),
    options: [
      'The void ratio divided by the specific gravity, about 26 per cent',
      'The void ratio itself, about 71 per cent',
      'The void ratio times the specific gravity, about 194 per cent',
      'It cannot be found from these two alone',
    ],
    answer: 0,
    why:
        'Run the same relationship backwards: with S at one, w is e over Gs, '
        'which is about 26 per cent. The lesson\'s own hard problem offers 71 '
        'per cent as a choice, which is the void ratio wearing a percent sign '
        'and nothing else. The two are not interchangeable, and the specific '
        'gravity is what stands between them.',
    source: 'geo-pr-q3',
  ),
  MasterRound(
    subject: 'what carries you across',
    asked:
        'The master relationship connects a weight ratio to a volume ratio. '
        'Which quantity in it does that work?',
    soil: Soil(gs: 2.70, water: 0.20, voidRatio: 0.54),
    options: [
      'The specific gravity, which is how much heavier the solids are than '
          'water',
      'The degree of saturation',
      'The void ratio',
      'The unit weight of water',
    ],
    answer: 0,
    why:
        'The specific gravity. Water content is weights, void ratio and '
        'saturation are volumes, and the only way across is to know how heavy '
        'the solids are for their size, which is what Gs says. Almost every '
        'phase problem is that one walk: measure on one side, cross over, '
        'report on the other.',
    source: 'geo-pr-q1',
  ),
];

class _WhenDoesItSimplifyGameState extends State<WhenDoesItSimplifyGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'when-does-it-simplify',
    chapterId: 'geotechnical',
    total: masterRounds.length,
    sourceProblemIdOf: (round) => masterRounds[round].source,
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

  MasterRound get _round => masterRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'When Does It Simplify',
        closing:
            'Saturation times void ratio equals water content times specific '
            'gravity, and that one line is the bridge between the weight side '
            'of the diagram and the volume side. At full saturation the S '
            'drops out and the void ratio is just w times Gs, but only then: '
            'assume it when the stem has not said so and the answer comes out '
            'too small. Keep the water content a decimal.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: masterBrief,
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
            'WHAT THE RELATIONSHIP GIVES',
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
                  painter: PhaseDiagramPainter(soil: r.soil),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$S\,e = \omega\,G_s$',
              style: const TextStyle(fontSize: 17, color: AppColors.charcoal),
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
