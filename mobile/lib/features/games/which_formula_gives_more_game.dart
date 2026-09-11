import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'earthwork_figures.dart';

/// Which Formula Gives More — the first item for `earthwork-volumes`.
///
/// The two volume formulas disagree, and which way they disagree is not a
/// coin toss: it depends on one comparison that can be read straight off a
/// drawing. The average end area method assumes the section runs straight
/// from one end to the other, so it believes the middle of the run is the
/// average of the two ends. The prismoidal formula asks what the middle
/// section ACTUALLY is. If the middle stands above that average the
/// prismoidal answer is bigger; if it sags below, the end area answer is.
/// A tapering fill sags, which is why the lesson says the end area method
/// overestimates one.
class WhichFormulaGivesMoreGame extends StatefulWidget {
  const WhichFormulaGivesMoreGame({super.key});

  @override
  State<WhichFormulaGivesMoreGame> createState() =>
      _WhichFormulaGivesMoreGameState();
}

/// Which of the two comes out bigger.
enum Fatter { endAreas, prismoid, same }

extension FatterWords on Fatter {
  String get plain => switch (this) {
        Fatter.endAreas => 'The average end area method',
        Fatter.prismoid => 'The prismoidal formula',
        Fatter.same => 'Neither: they agree here',
      };
}

@immutable
class FatterRound {
  const FatterRound({
    required this.subject,
    required this.setting,
    required this.haul,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Haul haul;
  final String why;
  final String source;

  /// Worked out from the two volumes, never declared.
  Fatter get answer {
    final gap = haul.byPrismoid - haul.byEndAreas;
    if (gap.abs() < 1) return Fatter.same;
    return gap > 0 ? Fatter.prismoid : Fatter.endAreas;
  }
}

const fatterRounds = <FatterRound>[
  FatterRound(
    subject: 'the lesson\'s own three sections',
    setting:
        'Sections of 200, 350 and 400 square feet at 0, 50 and 100 feet.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 200),
      Slab(station: 50, area: 350),
      Slab(station: 100, area: 400),
    ]),
    why:
        'The prismoidal formula, 33,333 against 30,000. The two ends average '
        '300 and the middle section is 350, so there is more dirt in the '
        'middle of this run than a straight taper between the ends would '
        'have. The end area method cannot know that, because it never looks '
        'at the middle.',
    source: 'surv-ev-q2',
  ),
  FatterRound(
    subject: 'a fill running out to nothing',
    setting:
        'The fill tapers away: 400 square feet, then 100, then nothing.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 400),
      Slab(station: 50, area: 100),
      Slab(station: 100, area: 0),
    ]),
    why:
        'The average end area method, and this is the overestimate the '
        'lesson warns about. A fill that closes down to a point loses width '
        'AND height at once, so its area falls away faster than a straight '
        'line: halfway along it is a quarter of the section, not half. The '
        'end area method quietly assumes half and charges for dirt that is '
        'not there.',
    source: 'surv-ev-q2',
  ),
  FatterRound(
    subject: 'a section opening out evenly',
    setting: 'Sections of 100, 200 and 300 square feet.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 100),
      Slab(station: 50, area: 200),
      Slab(station: 100, area: 300),
    ]),
    why:
        'Neither: they agree, at 20,000 each. The middle section is exactly '
        'the average of the two ends, which is precisely what the end area '
        'method assumes, so the prismoidal formula has nothing to correct. '
        'The end area method is not an approximation here. It is exact.',
    source: 'surv-ev-q2',
  ),
  FatterRound(
    subject: 'a cutting of constant section',
    setting: 'The same 250 square feet at all three stations.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 250),
      Slab(station: 50, area: 250),
      Slab(station: 100, area: 250),
    ]),
    why:
        'Neither. A constant section is the easy case of the same rule: the '
        'middle equals the average of the ends, so both formulas give the '
        'length times the area and there is nothing to argue about. Worth '
        'knowing because it is the sanity check for both.',
    source: 'surv-ev-q1',
  ),
  FatterRound(
    subject: 'a saddle in the middle',
    setting:
        'The cut is deep at both ends and shallow between: 300, 150 and 300.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 300),
      Slab(station: 50, area: 150),
      Slab(station: 100, area: 300),
    ]),
    why:
        'The average end area method, by a long way: 30,000 against 20,000. '
        'Both ends are deep, so their average is 300, and the middle is half '
        'that. Working off the ends alone books a third more dirt than is '
        'there. A saddle between two cuts is exactly where the prismoidal '
        'formula earns its keep.',
    source: 'surv-ev-q2',
  ),
  FatterRound(
    subject: 'a hump between two shallow ends',
    setting: 'Sections of 100, 300 and 100 square feet.',
    haul: Haul(slabs: [
      Slab(station: 0, area: 100),
      Slab(station: 50, area: 300),
      Slab(station: 100, area: 100),
    ]),
    why:
        'The prismoidal formula, 30,000 against 10,000, and the ratio is '
        'worth noticing. Working end to end here misses the hump entirely, '
        'because the ends say nothing about it. The middle section is the '
        'only measurement in the run that knows the dirt is there.',
    source: 'surv-ev-q2',
  ),
];

class _WhichFormulaGivesMoreGameState extends State<WhichFormulaGivesMoreGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-formula-gives-more',
    chapterId: 'surveying',
    total: fatterRounds.length,
    sourceProblemIdOf: (round) => fatterRounds[round].source,
  )..addListener(_onSession);

  Fatter? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  FatterRound get _round => fatterRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Formula Gives More',
        closing:
            'Compare the middle section with the average of the two ends. '
            'Above it and the prismoidal formula gives more; below it and '
            'the end area method does; level with it and the two agree '
            'exactly, which is what happens on a constant section and on one '
            'that opens out evenly. A fill closing to a point sags well '
            'below, and that is the overestimate the end area method is '
            'known for.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: endAreaBrief,
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
            'WHICH ONE COMES OUT BIGGER',
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
            height: 215,
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
                  painter: HaulPainter(haul: r.haul, showEndAverage: true),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$\frac{L}{2}(A_1 + A_2) \qquad \frac{L}{6}(A_1 + 4A_m + A_2)$',
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Fatter.values) ...[
            _Choice(
              label: option.plain,
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 6),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE BIGGER ONE' : 'THE OTHER WAY',
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
