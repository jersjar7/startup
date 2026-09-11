import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'aquifer_figures.dart';

/// Which Well Formula — the second item for `groundwater-wells`.
///
/// Two well formulas sit next to each other and the only thing that picks
/// between them is whether there is a layer of clay over the aquifer. Under
/// clay the aquifer cannot change thickness, so the heads enter as they are
/// and the transmissivity is a fixed K times b. With a free water table the
/// saturated thickness FALLS as the water table does, and that is where the
/// squared heads come from: it is not a different convention, it is the
/// thickness varying.
class WhichWellFormulaGame extends StatefulWidget {
  const WhichWellFormulaGame({super.key});

  @override
  State<WhichWellFormulaGame> createState() => _WhichWellFormulaGameState();
}

/// Which formula the drawing calls for.
enum Formula2 { dupuit, thiem }

extension Formula2Words on Formula2 {
  String get latex => switch (this) {
        Formula2.dupuit => r'$Q = \dfrac{\pi K (h_2^2 - h_1^2)}{\ln(r_2/r_1)}$',
        Formula2.thiem => r'$Q = \dfrac{2\pi T (h_2 - h_1)}{\ln(r_2/r_1)}$',
      };
}

@immutable
class WellRound {
  const WellRound({
    required this.subject,
    required this.setting,
    required this.aquifer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Aquifer aquifer;
  final String why;
  final String source;

  /// Read off the drawing: clay over the top means confined.
  Formula2 get answer => aquifer.kind == Ground.unconfined
      ? Formula2.dupuit
      : Formula2.thiem;
}

const wellRounds = <WellRound>[
  WellRound(
    subject: 'the lesson\'s own unconfined well',
    setting:
        'The water table is free to the air and dips toward the well. K is '
        '5 times ten to the minus four feet a second.',
    aquifer: Aquifer(
        kind: Ground.unconfined,
        conductivity: 5e-4,
        headAtWell: 40,
        radiusAtWell: 0.5,
        headOut: 60,
        radiusOut: 200),
    why:
        'Dupuit, with the heads SQUARED. The water table is the top of the '
        'saturated ground, so as it drops toward the well the aquifer gets '
        'thinner, and less thickness means less room to carry water. Squaring '
        'the heads is what accounts for that. Using the plain difference here '
        'gives 0.011 cubic feet a second instead of 0.52, a factor of fifty, '
        'and the lesson offers it.',
    source: 'wr-gw-q2',
  ),
  WellRound(
    subject: 'the lesson\'s own confined well',
    setting:
        'A layer of clay caps the aquifer, which is 20 meters thick. The '
        'levels shown are pressure levels in standpipes, not a water table.',
    aquifer: Aquifer(
        kind: Ground.confined,
        conductivity: 3e-5,
        headAtWell: 25,
        radiusAtWell: 10,
        headOut: 30,
        radiusOut: 100,
        thickness: 20),
    why:
        'Thiem, with the heads as they are. The clay holds the water down, so '
        'the aquifer is 20 meters thick whatever the pumping does and the '
        'transmissivity is a fixed K times b. The surface drawn above the '
        'clay is where water would STAND in a standpipe, not where the '
        'saturated ground ends, and dropping it does not thin the aquifer at '
        'all.',
    source: 'wr-gw-q3',
  ),
  WellRound(
    subject: 'a shallow sand under a field',
    setting:
        'No cap over the aquifer: the top of the saturated ground is the '
        'water table itself.',
    aquifer: Aquifer(
        kind: Ground.unconfined,
        conductivity: 2e-4,
        headAtWell: 18,
        radiusAtWell: 1,
        headOut: 25,
        radiusOut: 150),
    why:
        'Dupuit again. The test is never the depth or the conductivity, it '
        'is whether there is something impermeable over the top. Nothing over '
        'the top means the aquifer can be dewatered from above, so the '
        'thickness varies and the heads get squared.',
    source: 'wr-gw-q2',
  ),
  WellRound(
    subject: 'an artesian sand under clay',
    setting:
        'A sand 12 meters thick, capped with clay, with water standing well '
        'above the top of the sand in every standpipe.',
    aquifer: Aquifer(
        kind: Ground.confined,
        conductivity: 8e-5,
        headAtWell: 34,
        radiusAtWell: 5,
        headOut: 40,
        radiusOut: 250,
        thickness: 12),
    why:
        'Thiem. The water standing above the top of the sand is what makes '
        'this artesian, and it is the clearest sign of confinement there is: '
        'water cannot stand above the ground it saturates unless something is '
        'holding it down. The 12 meters of sand is the b in T equals K b, and '
        'forgetting to work T out first is the lesson\'s named trap.',
    source: 'wr-gw-q3',
  ),
  WellRound(
    subject: 'a gravel bank beside a river',
    setting:
        'Open gravel down to bedrock with no cap at all, drawn down hard by '
        'a dewatering well.',
    aquifer: Aquifer(
        kind: Ground.unconfined,
        conductivity: 1e-3,
        headAtWell: 6,
        radiusAtWell: 0.5,
        headOut: 20,
        radiusOut: 120),
    why:
        'Dupuit, and here the difference between the two formulas is at its '
        'largest. The head at the well is down to 6 of the 20 meters, so the '
        'aquifer at the well is less than a third the thickness it is further '
        'out. On a drawdown this deep the squared form is not a refinement, '
        'it is the whole answer.',
    source: 'wr-gw-q2',
  ),
  WellRound(
    subject: 'a deep aquifer under rock',
    setting:
        'A limestone 30 meters thick, sealed above by shale. The heads are '
        'measured in sealed piezometers.',
    aquifer: Aquifer(
        kind: Ground.confined,
        conductivity: 4e-5,
        headAtWell: 48,
        radiusAtWell: 8,
        headOut: 52,
        radiusOut: 300,
        thickness: 30),
    why:
        'Thiem. Sealed piezometers measure pressure, and a sealed cap above '
        'means the aquifer keeps its 30 meters. Note how small the drawdown '
        'is, four meters over a radius of 300: confined aquifers spread their '
        'drawdown a long way because nothing is being emptied, only '
        'depressurized.',
    source: 'wr-gw-q3',
  ),
];

class _WhichWellFormulaGameState extends State<WhichWellFormulaGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-well-formula',
    chapterId: 'water-resources',
    total: wellRounds.length,
    sourceProblemIdOf: (round) => wellRounds[round].source,
  )..addListener(_onSession);

  Formula2? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  WellRound get _round => wellRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Well Formula',
        closing:
            'One question picks the formula: is there something impermeable '
            'over the aquifer. Clay on top means confined, the thickness is '
            'fixed, the transmissivity is K times b, and the heads go in as '
            'they are. A free water table means the saturated thickness falls '
            'as the water table does, and the squared heads in Dupuit are '
            'what account for it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: wellBrief,
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
            'WHICH FORMULA DOES THIS WELL TAKE',
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
            height: 234,
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
                  painter: AquiferPainter(
                    aquifer: r.aquifer,
                    showFormula: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in [Formula2.dupuit, Formula2.thiem]) ...[
            _FormulaChoice(
              latex: option.latex,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Formula2.thiem) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'THE OTHER ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _FormulaChoice extends StatelessWidget {
  const _FormulaChoice({
    required this.latex,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String latex;
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: MathText(
            latex,
            style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }
}
