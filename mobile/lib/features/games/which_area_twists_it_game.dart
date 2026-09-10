import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'torsion_figures.dart';

/// Which Area Twists It — the third item for `torsion`.
///
/// The lesson's third topic is the thin-walled tube and nothing else in the
/// chapter touches it. Its formula reads tau equals T over two t A sub m, and
/// the lesson goes out of its way to say what A sub m is NOT: it is not the
/// cross-sectional area of the material. It is the area enclosed by the middle
/// of the wall, a line that is not drawn on any real object and encloses metal
/// that is not there.
///
/// It is worth a game because the wrong area is the one anybody would reach
/// for. On a thin tube the material area is a tiny fraction of the right
/// answer, so the mistake is not a few per cent, it is an order of magnitude.
class WhichAreaTwistsItGame extends StatefulWidget {
  const WhichAreaTwistsItGame({super.key});

  @override
  State<WhichAreaTwistsItGame> createState() => _WhichAreaTwistsItGameState();
}

@immutable
class AreaRound {
  const AreaRound({
    required this.subject,
    required this.setting,
    required this.tube,
    required this.panels,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Tube tube;

  /// The three regions on offer, in the order they are drawn.
  final List<Region> panels;

  final String why;
  final String source;

  /// The panel showing the area enclosed by the middle of the wall. Found by
  /// looking, never declared beside the round.
  int get answer => panels.indexOf(Region.median);
}

const areaRounds = <AreaRound>[
  AreaRound(
    subject: 'a round tube',
    setting:
        'A circular tube with a thin wall. Which shaded area is the one the '
        'formula calls A sub m?',
    tube: Tube(shape: TubeShape.round, width: 100, height: 100, wall: 4),
    panels: [Region.material, Region.median, Region.outer],
    why:
        'The middle one, enclosed by the dashed line halfway through the wall. '
        'The first is the metal itself, which is the area anybody would name '
        'if asked for the area of a tube, and on a wall this thin it is about '
        'a sixth of the right answer. The formula is not asking about the '
        'metal. It is asking about the space the shear flow runs around.',
    source: 'mm-tor-q3',
  ),
  AreaRound(
    subject: 'a square hollow section',
    setting:
        'A square tube, the sort a handrail is made from. Same question.',
    tube: Tube(shape: TubeShape.square, width: 80, height: 80, wall: 4),
    panels: [Region.outer, Region.material, Region.median],
    why:
        'The last one. The shape does not change the rule: the middle of the '
        'wall, all the way round. Note that the first panel, everything inside '
        'the outside face, is quite close to the right answer on a thin wall '
        'and is still not it, and on a thicker wall the gap opens up fast.',
    source: 'mm-tor-q3',
  ),
  AreaRound(
    subject: 'a rectangular section',
    setting: 'An oblong tube rather than a square one.',
    tube: Tube(shape: TubeShape.oblong, width: 100, height: 70, wall: 5),
    panels: [Region.median, Region.inner, Region.material],
    why:
        'The first one. The second is everything inside the BORE, which is the '
        'other near miss: inside the bore, inside the outside face, and inside '
        'the middle of the wall are three different areas and only the middle '
        'one is A sub m, and it sits between the other two.',
    source: 'mm-tor-q3',
  ),
  AreaRound(
    subject: 'a wall thick enough to see',
    setting:
        'The same round tube, but the wall is now sixteen millimeters on a '
        'fifty millimeter radius.',
    tube: Tube(shape: TubeShape.round, width: 100, height: 100, wall: 16),
    panels: [Region.outer, Region.median, Region.material],
    why:
        'Still the middle one, and the rule never depended on how thin the '
        'wall was. What DOES depend on it is whether you should be using this '
        'formula at all: the lesson says use it while the wall is under a '
        'tenth of the radius, and a sixteen on fifty is three times that. On a '
        'real section like this one, go back to T c over J.',
    source: 'mm-tor-q3',
  ),
  AreaRound(
    subject: 'a tall thin section',
    setting: 'A narrow upright tube, the sort used for a post.',
    tube: Tube(shape: TubeShape.oblong, width: 60, height: 100, wall: 4),
    panels: [Region.material, Region.outer, Region.median],
    why:
        'The last one again, and the panel order changes from round to round '
        'on purpose. Reaching for a position rather than for the dashed line is '
        'the habit this is meant to break. Find the middle of the wall, then '
        'answer.',
    source: 'mm-tor-q3',
  ),
  AreaRound(
    subject: 'a square tube with a heavy wall',
    setting:
        'A square section, ninety millimeters across, with a fourteen '
        'millimeter wall.',
    tube: Tube(shape: TubeShape.square, width: 90, height: 90, wall: 14),
    panels: [Region.median, Region.material, Region.inner],
    why:
        'The first. The panels are drawn with the wall opened up so the three '
        'lines can be told apart, and that is worth knowing, because on the '
        'real thin sections this formula is for, the metal is a sliver and the '
        'area it encloses is nearly the whole section. Reaching for the metal '
        'there is not a small error, it is a different order of magnitude.',
    source: 'mm-tor-q3',
  ),
];

class _WhichAreaTwistsItGameState extends State<WhichAreaTwistsItGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-area-twists-it',
    chapterId: 'mechanics-materials',
    total: areaRounds.length,
    sourceProblemIdOf: (round) => areaRounds[round].source,
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

  AreaRound get _round => areaRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Area Twists It',
        closing:
            'A sub m is the area enclosed by the MIDDLE of the wall. Not the '
            'metal, not the bore, not the outside. It is a line that is not on '
            'the object and it encloses space that is not metal, and it is the '
            'only one of the four that belongs in the formula.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: thinWallBrief,
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
            'TAP THE AREA THE FORMULA WANTS',
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
          Center(
            child: MathText(
              r'$\tau = \dfrac{T}{2\,t\,A_m}$',
              style:
                  const TextStyle(fontSize: 18, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < r.panels.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Panel(
                    key: ValueKey('area-$i'),
                    tube: r.tube,
                    region: r.panels[i],
                    selected: _picked == i,
                    locked: answered,
                    isTruth: i == r.answer,
                    onTap: answered ? null : () => setState(() => _picked = i),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'dashed line: the middle of the wall, drawn thicker than scale',
            style: AppTheme.mono(size: 11, color: AppColors.ink3),
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE AREA' : 'A DIFFERENT AREA',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    super.key,
    required this.tube,
    required this.region,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Tube tube;
  final Region region;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color tone;
    if (locked && isTruth) {
      border = AppColors.forest;
      tone = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      tone = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      tone = AppColors.ember;
    } else {
      border = AppColors.line;
      tone = AppColors.info;
    }

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 118,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: EngineeringGrid(
              minor: 16,
              major: 80,
              child: CustomPaint(
                painter: TubePainter(tube: tube, region: region, tone: tone),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
