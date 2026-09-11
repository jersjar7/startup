import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'earthwork_figures.dart';

/// How Much of the Box — the third item for `earthwork-volumes`.
///
/// Three fractions cover most of the earthwork anybody estimates in their
/// head, and all three are the same picture: take the section, carry it the
/// whole length to make a box, and ask how much of that box the real solid
/// fills. Carried whole, all of it. Closing down to an EDGE, half of it,
/// which is also what the end area formula gives when one section is zero.
/// Closing down to a POINT, a third, which is the pyramid formula and the
/// reason the end area method overestimates a taper: it charges a half for
/// something that is a third.
class HowMuchOfTheBoxGame extends StatefulWidget {
  const HowMuchOfTheBoxGame({super.key});

  @override
  State<HowMuchOfTheBoxGame> createState() => _HowMuchOfTheBoxGameState();
}

/// How much of the box the solid fills.
enum Share { all, half, third }

extension ShareWords on Share {
  String get plain => switch (this) {
        Share.all => 'All of it',
        Share.half => 'Half of it',
        Share.third => 'A third of it',
      };

  double get part => switch (this) {
        Share.all => 1,
        Share.half => 0.5,
        Share.third => 1 / 3,
      };
}

@immutable
class BoxRound {
  const BoxRound({
    required this.subject,
    required this.setting,
    required this.solid,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Solid solid;
  final String why;
  final String source;

  /// Read off the solid, never declared.
  Share get answer =>
      Share.values.firstWhere((s) => (s.part - solid.share).abs() < 0.001);
}

const shareRounds2 = <BoxRound>[
  BoxRound(
    subject: 'a cutting that keeps its section',
    setting:
        'A cutting runs 300 feet at the same 250 square feet the whole way.',
    solid: Solid.prism,
    why:
        'All of it. The box IS the solid when the section never changes, so '
        'the volume is simply the area times the length. Both volume '
        'formulas agree with that and with each other, which makes it the '
        'sanity check to run when a number looks wrong.',
    source: 'surv-ev-q1',
  ),
  BoxRound(
    subject: 'an embankment running out to its toe',
    setting:
        'A fill keeps its height and its side slopes, and closes down to a '
        'level edge where it meets existing ground.',
    solid: Solid.wedge,
    why:
        'Half of it. A solid that closes to an EDGE loses its section evenly '
        'along the length, so the average section really is half the full '
        'one, and that is what the end area formula gives with one section '
        'at zero: L over 2 times A. This is the lesson\'s own third problem, '
        'twice over: two wedges back to back, 20,000 each.',
    source: 'surv-ev-q3',
  ),
  BoxRound(
    subject: 'a stockpile of sand',
    setting:
        'A conical stockpile, round at the base and coming to a point at the '
        'top.',
    solid: Solid.point,
    why:
        'A third of it. Closing down to a POINT loses the section in two '
        'directions at once, so it falls away as the square rather than '
        'straight, and the solid only fills a third of its box. This is the '
        'pyramid formula in the lesson, base area times height over three, '
        'and it is the same third whether the base is round or square.',
    source: 'surv-ev-q3',
  ),
  BoxRound(
    subject: 'the end of a fill, closing to a point',
    setting:
        'The last stretch of an embankment narrows AND drops away at once, '
        'finishing at a single point on the ground.',
    solid: Solid.point,
    why:
        'A third. This is where the end area method gets caught: it treats '
        'the section as running straight out and books half the box, when '
        'the solid is a third. Roughly fifty percent too much dirt on that '
        'last stretch, which is exactly the overestimate the lesson warns '
        'about.',
    source: 'surv-ev-q2',
  ),
  BoxRound(
    subject: 'a trench of constant depth',
    setting:
        'A pipe trench, the same width and the same depth for its whole '
        'length.',
    solid: Solid.prism,
    why:
        'All of it. Trenches are the reason estimators can do earthwork in '
        'their heads: width times depth times length, with no fractions '
        'anywhere. Every complication in this lesson comes from the section '
        'refusing to stay the same.',
    source: 'surv-ev-q1',
  ),
  BoxRound(
    subject: 'a ramp of spoil against a wall',
    setting:
        'Spoil is pushed up against a retaining wall, full height at the '
        'wall and tapering down to a straight edge on the ground away from '
        'it.',
    solid: Solid.wedge,
    why:
        'Half. Full section at one end, closing to an edge at the other, '
        'however it happens to be oriented: it is the same wedge as the '
        'embankment toe on its side. What matters is whether the far end is '
        'an edge or a point, not which way up the drawing is.',
    source: 'surv-ev-q3',
  ),
];

class _HowMuchOfTheBoxGameState extends State<HowMuchOfTheBoxGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-much-of-the-box',
    chapterId: 'surveying',
    total: shareRounds2.length,
    sourceProblemIdOf: (round) => shareRounds2[round].source,
  )..addListener(_onSession);

  Share? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  BoxRound get _round => shareRounds2[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Much of the Box',
        closing:
            'Carry the section the whole length to make a box, then ask what '
            'the far end does. Nothing changes: all of it. Closes to an '
            'edge: half, which is the end area formula with one section at '
            'zero. Closes to a point: a third, which is the pyramid formula. '
            'The gap between the half and the third is the whole reason the '
            'end area method overestimates a taper.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: solidBrief,
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
            'HOW MUCH OF ITS BOX DOES IT FILL',
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
                  painter: SolidPainter(solid: r.solid),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: MathText(
              r'$V = \frac{h A_{base}}{3}$ for a point',
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 14),
          for (final option in Share.values) ...[
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
              title: _session.correct! ? 'THAT IS THE SHARE' : 'ANOTHER SHARE',
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
