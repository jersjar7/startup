import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'runoff_figures.dart';

/// Where the Blend Lands — the second item for `rainfall-runoff`.
///
/// When a catchment has two covers on it, the coefficient that stands for
/// the whole is weighted BY AREA, and the lesson's own third problem names
/// the plain average of the two as its trap. The useful form of the rule is
/// not the formula but the direction: the blend always leans toward whichever
/// cover has more ground under it, and it lands halfway only when the two
/// areas are equal.
class WhereTheBlendLandsGame extends StatefulWidget {
  const WhereTheBlendLandsGame({super.key});

  @override
  State<WhereTheBlendLandsGame> createState() =>
      _WhereTheBlendLandsGameState();
}

/// Which end of the range the combined coefficient sits nearer.
enum Leans { firstPatch, secondPatch, halfway }

@immutable
class BlendRound {
  const BlendRound({
    required this.subject,
    required this.catchment,
    required this.why,
    required this.source,
  });

  final String subject;
  final Catchment catchment;
  final String why;
  final String source;

  Patch get first => catchment.patches.first;

  Patch get second => catchment.patches.last;

  /// Read off the two areas, which is the only thing that decides it.
  Leans get answer {
    final gap = first.acres - second.acres;
    if (gap.abs() / catchment.acres < 0.02) return Leans.halfway;
    return gap > 0 ? Leans.firstPatch : Leans.secondPatch;
  }

  String label(Leans which) => switch (which) {
        Leans.firstPatch =>
          'Nearer ${first.cover}, C ${first.coefficient.toStringAsFixed(2)}',
        Leans.secondPatch =>
          'Nearer ${second.cover}, C ${second.coefficient.toStringAsFixed(2)}',
        Leans.halfway => 'Halfway between the two',
      };
}

const blendRounds = <BlendRound>[
  BlendRound(
    subject: 'the lesson\'s own pair',
    catchment: Catchment([
      Patch(cover: 'paving', acres: 30, coefficient: 0.90),
      Patch(cover: 'grass', acres: 20, coefficient: 0.40),
    ]),
    why:
        'Nearer the paving, because there is more of it. The weighted '
        'coefficient is 27 plus 8 over 50, which is 0.70, and the plain '
        'average of 0.90 and 0.40 would have been 0.65. That gap is the '
        'lesson\'s own trap, and it is worth noting which way it errs: the '
        'unweighted average understates the peak here, so the drain comes out '
        'too small.',
    source: 'wr-rr-q3',
  ),
  BlendRound(
    subject: 'a little paving in a big field',
    catchment: Catchment([
      Patch(cover: 'pasture', acres: 90, coefficient: 0.25),
      Patch(cover: 'farmyard', acres: 10, coefficient: 0.85),
    ]),
    why:
        'Nearer the pasture, and very near it: the blend is 0.31. Ninety '
        'acres out of a hundred is doing almost all of the talking, and the '
        'hard yard barely lifts it. The plain average would have said 0.55, '
        'which is nearly double, and would have sized the whole system on a '
        'tenth of the catchment.',
    source: 'wr-rr-q3',
  ),
  BlendRound(
    subject: 'equal halves',
    catchment: Catchment([
      Patch(cover: 'rooftops', acres: 25, coefficient: 0.95),
      Patch(cover: 'lawns', acres: 25, coefficient: 0.35),
    ]),
    why:
        'Halfway, at 0.65. This is the one case where the plain average is '
        'right, and it is right by accident rather than by method: equal '
        'areas make the weighting do nothing. Working the average out this '
        'way and finding it agrees is fine; assuming it always will is what '
        'the trap is.',
    source: 'wr-rr-q3',
  ),
  BlendRound(
    subject: 'mostly hard ground',
    catchment: Catchment([
      Patch(cover: 'car park', acres: 70, coefficient: 0.90),
      Patch(cover: 'planting strips', acres: 10, coefficient: 0.20),
    ]),
    why:
        'Nearer the car park, at 0.81. Seven eighths of the site is paved, so '
        'the planting hardly registers. This is the usual shape of a '
        'commercial site, and it is why single coefficients around 0.85 are '
        'quoted for commercial land in the first place: the strips of green '
        'are already in that number.',
    source: 'wr-rr-q1',
  ),
  BlendRound(
    subject: 'a third and two thirds',
    catchment: Catchment([
      Patch(cover: 'gravel', acres: 20, coefficient: 0.40),
      Patch(cover: 'roof', acres: 40, coefficient: 0.95),
    ]),
    why:
        'Nearer the roof, at 0.77. Two thirds of the ground pulls the blend '
        'two thirds of the way, which is the whole of the rule: the weighted '
        'coefficient sits at the balance point of the areas. Naming which end '
        'it leans toward is usually enough to reject two of the four choices '
        'on an exam question.',
    source: 'wr-rr-q3',
  ),
  BlendRound(
    subject: 'equal halves again, further apart',
    catchment: Catchment([
      Patch(cover: 'woodland', acres: 40, coefficient: 0.15),
      Patch(cover: 'concrete', acres: 40, coefficient: 0.95),
    ]),
    why:
        'Halfway once more, at 0.55, however far apart the two covers are. '
        'What decides the lean is the AREAS and nothing else: the spread '
        'between the coefficients changes how much is at stake, not where the '
        'balance point sits.',
    source: 'wr-rr-q3',
  ),
];

class _WhereTheBlendLandsGameState extends State<WhereTheBlendLandsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'where-the-blend-lands',
    chapterId: 'water-resources',
    total: blendRounds.length,
    sourceProblemIdOf: (round) => blendRounds[round].source,
  )..addListener(_onSession);

  Leans? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  BlendRound get _round => blendRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Where the Blend Lands',
        closing:
            'A catchment with two covers takes one coefficient weighted by '
            'AREA, and it always leans toward whichever cover has more ground '
            'under it. It lands halfway only when the areas are equal, which '
            'is the single case where the plain average happens to be right. '
            'Knowing which way it leans is usually enough to throw out half '
            'the choices on offer.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: catchmentBrief,
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
            'WHERE DOES THE ONE COEFFICIENT SIT',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 10),
          const Text(
            'This catchment has two covers on it and drains to one inlet, so '
            'it needs one coefficient standing for the whole. Where does that '
            'number sit?',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 176,
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
                  painter: CatchmentPainter(
                    catchment: r.catchment,
                    showWeighted: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$C = \dfrac{\sum C_i A_i}{\sum A_i}$',
              style: const TextStyle(fontSize: 16, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          for (final option in Leans.values) ...[
            _Choice(
              label: r.label(option),
              selected: _picked == option,
              locked: answered,
              isTruth: r.answer == option,
              onTap: answered ? null : () => setState(() => _picked = option),
            ),
            if (option != Leans.values.last) const SizedBox(height: 8),
          ],
          if (answered) ...[
            const SizedBox(height: 14),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHERE IT LANDS' : 'IT LEANS THE OTHER WAY',
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
