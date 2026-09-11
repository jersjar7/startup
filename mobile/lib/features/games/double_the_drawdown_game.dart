import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'aquifer_figures.dart';

/// Double the Drawdown — the third item for `groundwater-wells`.
///
/// In a confined aquifer everything in the Thiem equation is a plain
/// proportion: twice the drawdown is twice the water, and so is twice the
/// conductivity or twice the thickness. In an unconfined one the heads are
/// squared, and the difference of two squares is the difference TIMES the
/// sum, so what a change buys depends on where the heads are. Pulling the
/// well down twice as far buys less than twice the water; a wetter season
/// that raises the water table buys more. That is the squared form doing
/// something, rather than being a notation to remember.
class DoubleTheDrawdownGame extends StatefulWidget {
  const DoubleTheDrawdownGame({super.key});

  @override
  State<DoubleTheDrawdownGame> createState() =>
      _DoubleTheDrawdownGameState();
}

/// What the change buys, against a plain doubling.
enum Buys { exactly, more, less }

extension BuysWords on Buys {
  String get plain => switch (this) {
        Buys.exactly => 'Exactly twice the water',
        Buys.more => 'More than twice',
        Buys.less => 'Less than twice',
      };
}

@immutable
class DrawRound {
  const DrawRound({
    required this.subject,
    required this.change,
    required this.before,
    required this.after,
    required this.why,
    required this.source,
  });

  final String subject;
  final String change;
  final Aquifer before;
  final Aquifer after;
  final String why;
  final String source;

  double get ratio => after.discharge / before.discharge;

  /// Worked out of the two wells, never declared.
  Buys get answer {
    if ((ratio - 2).abs() < 0.01) return Buys.exactly;
    return ratio > 2 ? Buys.more : Buys.less;
  }
}

const drawRounds = <DrawRound>[
  DrawRound(
    subject: 'a confined well pulled down twice as far',
    change:
        'The pump works harder and the drawdown at the well goes from 5 '
        'meters to 10. The aquifer is under clay.',
    before: Aquifer(
        kind: Ground.confined,
        conductivity: 3e-5,
        headAtWell: 25,
        radiusAtWell: 10,
        headOut: 30,
        radiusOut: 100),
    after: Aquifer(
        kind: Ground.confined,
        conductivity: 3e-5,
        headAtWell: 20,
        radiusAtWell: 10,
        headOut: 30,
        radiusOut: 100),
    why:
        'Exactly twice. The Thiem equation has the head difference in it '
        'once, on the top, and nothing else in the equation changed, so the '
        'discharge follows in plain proportion. Confined aquifers are '
        'well-behaved this way: nothing is being emptied, only depressurized, '
        'and the aquifer keeps its thickness whatever the pressure does.',
    source: 'wr-gw-q3',
  ),
  DrawRound(
    subject: 'an unconfined well pulled down twice as far',
    change:
        'A free water table. The head at the well goes from 40 feet down to '
        '20, so the drawdown doubles from 20 feet to 40.',
    before: Aquifer(
        kind: Ground.unconfined,
        conductivity: 5e-4,
        headAtWell: 40,
        radiusAtWell: 0.5,
        headOut: 60,
        radiusOut: 200),
    after: Aquifer(
        kind: Ground.unconfined,
        conductivity: 5e-4,
        headAtWell: 20,
        radiusAtWell: 0.5,
        headOut: 60,
        radiusOut: 200),
    why:
        'Less than twice: about 1.6 times. The difference of two squares is '
        'the difference times the SUM, and pulling the well down lowers the '
        'sum at the same time as it raises the difference. Physically the '
        'aquifer is thinner at the well than it was, so there is less ground '
        'to carry water through. Pumping an unconfined well harder gives '
        'diminishing returns, and that is the squared form telling you so.',
    source: 'wr-gw-q2',
  ),
  DrawRound(
    subject: 'a wetter year on the same unconfined well',
    change:
        'The regional water table rises, taking the far head from 50 feet to '
        '60 while the well is held at 40. The drawdown doubles from 10 to 20.',
    before: Aquifer(
        kind: Ground.unconfined,
        conductivity: 5e-4,
        headAtWell: 40,
        radiusAtWell: 0.5,
        headOut: 50,
        radiusOut: 200),
    after: Aquifer(
        kind: Ground.unconfined,
        conductivity: 5e-4,
        headAtWell: 40,
        radiusAtWell: 0.5,
        headOut: 60,
        radiusOut: 200),
    why:
        'More than twice: about 2.2. The same doubling of the drawdown, '
        'arrived at the other way round, and now the sum of the heads goes UP '
        'as well as the difference. A wetter year makes the aquifer thicker '
        'everywhere, so the same drawdown moves more water. Which end of the '
        'drawdown changed is the whole of the difference between this round '
        'and the last one.',
    source: 'wr-gw-q2',
  ),
  DrawRound(
    subject: 'a coarser sand',
    change:
        'The same confined well, but the aquifer turns out to be twice as '
        'conductive as it was thought to be.',
    before: Aquifer(
        kind: Ground.confined,
        conductivity: 3e-5,
        headAtWell: 25,
        radiusAtWell: 10,
        headOut: 30,
        radiusOut: 100),
    after: Aquifer(
        kind: Ground.confined,
        conductivity: 6e-5,
        headAtWell: 25,
        radiusAtWell: 10,
        headOut: 30,
        radiusOut: 100),
    why:
        'Exactly twice. K is a plain multiplier in both formulas, so this one '
        'is the same answer whichever aquifer you are in. It is also the '
        'reason a pumping test is worth doing: an estimate of K that is out '
        'by a factor of two puts the yield out by the same factor, and no '
        'amount of care with the rest of the equation will recover it.',
    source: 'wr-gw-q3',
  ),
  DrawRound(
    subject: 'a thicker aquifer',
    change:
        'The confined sand is found to be 40 meters thick rather than 20. '
        'Everything else is unchanged.',
    before: Aquifer(
        kind: Ground.confined,
        conductivity: 3e-5,
        headAtWell: 25,
        radiusAtWell: 10,
        headOut: 30,
        radiusOut: 100,
        thickness: 20),
    after: Aquifer(
        kind: Ground.confined,
        conductivity: 3e-5,
        headAtWell: 25,
        radiusAtWell: 10,
        headOut: 30,
        radiusOut: 100,
        thickness: 40),
    why:
        'Exactly twice, through the transmissivity. T is K times b and it '
        'enters Thiem once, so doubling the thickness doubles the yield. Note '
        'that there is no b anywhere in Dupuit: an unconfined aquifer has no '
        'fixed thickness to multiply by, which is exactly why the heads have '
        'to be squared instead.',
    source: 'wr-gw-q3',
  ),
  DrawRound(
    subject: 'a small drawdown in a deep unconfined sand',
    change:
        'A deep water table at 25 meters, and the drawdown at the well goes '
        'from 1 meter to 2.',
    before: Aquifer(
        kind: Ground.unconfined,
        conductivity: 4e-4,
        headAtWell: 24,
        radiusAtWell: 0.5,
        headOut: 25,
        radiusOut: 150),
    after: Aquifer(
        kind: Ground.unconfined,
        conductivity: 4e-4,
        headAtWell: 23,
        radiusAtWell: 0.5,
        headOut: 25,
        radiusOut: 150),
    why:
        'Less than twice, but only just: 1.96 rather than 2. When the '
        'drawdown is small against the saturated thickness, the sum of the '
        'heads barely moves and the squared form behaves almost like the '
        'plain one. That is why treating a lightly pumped unconfined aquifer '
        'as though it were confined is a common approximation and usually a '
        'harmless one. It stops being harmless when the drawdown gets deep.',
    source: 'wr-gw-q2',
  ),
];

class _DoubleTheDrawdownGameState extends State<DoubleTheDrawdownGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'double-the-drawdown',
    chapterId: 'water-resources',
    total: drawRounds.length,
    sourceProblemIdOf: (round) => drawRounds[round].source,
  )..addListener(_onSession);

  Buys? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  DrawRound get _round => drawRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Double the Drawdown',
        closing:
            'In a confined aquifer every term is a plain proportion: twice '
            'the drawdown, the conductivity or the thickness is twice the '
            'water. In an unconfined one the heads are squared, and the '
            'difference of two squares is the difference times the SUM, so '
            'pulling the well down harder buys less than proportionally and a '
            'higher water table buys more. The squared form is the aquifer '
            'getting thinner, written down.',
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
            'WHAT DOES THE CHANGE BUY',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          Text(
            r.change,
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
                    aquifer: answered ? r.after : r.before,
                    showFormula: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$h_2^2 - h_1^2 = (h_2 - h_1)(h_2 + h_1)$',
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Buys.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Buys.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHAT IT BUYS' : 'NOT QUITE',
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
