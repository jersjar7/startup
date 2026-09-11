import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'standards_figures.dart';

/// Health or Taste — the first item for `water-quality-standards`.
///
/// The Safe Drinking Water Act sets two tiers and only one of them is law.
/// PRIMARY standards are health based and enforceable: exceed one and the
/// utility is in violation. SECONDARY standards cover taste, color and
/// staining, and are advisory. Every number looks equally official on a page
/// of limits, which is exactly why the distinction is worth carrying: a
/// rusty stain is a nuisance and an arsenic exceedance is a notice to the
/// state.
class HealthOrTasteGame extends StatefulWidget {
  const HealthOrTasteGame({super.key});

  @override
  State<HealthOrTasteGame> createState() => _HealthOrTasteGameState();
}

@immutable
class TierRound {
  const TierRound({
    required this.label,
    required this.asked,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// The contaminant and its limit, as it would appear on a table.
  final String label;
  final String asked;
  final Tier answer;
  final String why;
  final String source;
}

const tierRounds = <TierRound>[
  TierRound(
    label: 'Arsenic  0.010 mg/L',
    asked:
        'Arsenic is capped at ten parts per billion. Which kind of standard '
        'is that?',
    answer: Tier.primary,
    why:
        'Primary, and the lesson\'s own answer. Arsenic is a carcinogen, so '
        'its limit is health based, is a Maximum Contaminant Level, and is '
        'legally enforceable. Exceed it and the utility must notify its '
        'customers and the state. Nothing about the number being small makes '
        'it primary: what makes it primary is that it is about health.',
    source: 'wr-wqs-q3',
  ),
  TierRound(
    label: 'Iron  0.3 mg/L',
    asked:
        'Iron is listed at 0.3 mg/L. Which kind of standard is that?',
    answer: Tier.secondary,
    why:
        'Secondary. Iron at that level stains laundry and fixtures a rusty '
        'orange and tastes metallic, and neither of those is a health effect. '
        'The limit is advisory: a utility that exceeds it has unhappy '
        'customers rather than a violation. Utilities usually treat for it '
        'anyway, because unhappy customers are their own kind of problem.',
    source: 'wr-wqs-q3',
  ),
  TierRound(
    label: 'Nitrate as N  10 mg/L',
    asked: 'Nitrate, measured as nitrogen, is capped at 10 mg/L. Which is it?',
    answer: Tier.primary,
    why:
        'Primary. Nitrate causes methemoglobinemia in infants, which is a '
        'health effect and a serious one, so the limit is an enforceable MCL. '
        'It matters in agricultural areas where fertilizer reaches shallow '
        'wells, and it is one of the few contaminants where boiling the water '
        'makes things WORSE by concentrating it.',
    source: 'wr-wqs-q3',
  ),
  TierRound(
    label: 'Total dissolved solids  500 mg/L',
    asked: 'Total dissolved solids are listed at 500 mg/L. Which is it?',
    answer: Tier.secondary,
    why:
        'Secondary. High dissolved solids make water taste salty or brackish '
        'and can leave scale, but the salts involved are not toxic at these '
        'levels. Advisory again. Note how large this number is beside the '
        'arsenic one: the size of a limit says nothing about which tier it '
        'belongs to, only about how harmful the substance is.',
    source: 'wr-wqs-q3',
  ),
  TierRound(
    label: 'Lead  0.015 mg/L action level',
    asked:
        'Lead has an action level of 0.015 mg/L at the customer\'s tap. '
        'Which is it?',
    answer: Tier.primary,
    why:
        'Primary. Lead is a neurotoxin with no safe level, and it is '
        'regulated as a health based requirement with teeth. It is written as '
        'an ACTION LEVEL rather than a plain MCL because the lead usually '
        'comes from the pipes and solder between the main and the tap rather '
        'than from the water the plant produced, so exceeding it triggers '
        'corrosion control and pipe replacement rather than a treatment '
        'change alone.',
    source: 'wr-wqs-q3',
  ),
  TierRound(
    label: 'pH  6.5 to 8.5',
    asked:
        'The listed range for pH is 6.5 to 8.5. Which kind of standard is '
        'that?',
    answer: Tier.secondary,
    why:
        'Secondary. Water outside that band tastes odd and, more to the '
        'point, attacks pipes at the low end and scales them at the high end, '
        'but the pH itself is not a health matter at these levels. It is '
        'still watched closely, because corrosive water is how lead gets out '
        'of the pipes, and that IS a primary problem arriving by the back '
        'door.',
    source: 'wr-wqs-q3',
  ),
];

class _HealthOrTasteGameState extends State<HealthOrTasteGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'health-or-taste',
    chapterId: 'water-resources',
    total: tierRounds.length,
    sourceProblemIdOf: (round) => tierRounds[round].source,
  )..addListener(_onSession);

  Tier? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  TierRound get _round => tierRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Health or Taste',
        closing:
            'Primary standards are health based and enforceable: arsenic, '
            'nitrate, lead, the pathogens. Secondary standards are about '
            'taste, color, staining and scale: iron, manganese, dissolved '
            'solids, chloride, pH. The size of the number tells you nothing '
            'about which tier it is in, and a utility exceeding a secondary '
            'guideline has a complaint on its hands rather than a violation.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: standardsBrief,
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
            'WHICH SHELF DOES THIS LIMIT GO ON',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.label,
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
            height: 210,
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
                  painter: TierPainter(
                    label: r.label,
                    settled: answered ? r.answer : null,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in [Tier.primary, Tier.secondary]) ...[
            _Choice(
              label: option == Tier.primary
                  ? 'Primary: health based, and enforceable'
                  : 'Secondary: aesthetic, and advisory',
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Tier.secondary) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE SHELF' : 'THE OTHER SHELF',
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
