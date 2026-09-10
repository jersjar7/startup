import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/engineering_grid.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'section_figures.dart';

/// Above or Below the Middle — the first item for
/// `centroids-composite-shapes`.
///
/// Every problem in this lesson names the same wrong answer: the middle of the
/// overall height. It is wrong because the centroid is an AREA-weighted
/// average, so it is dragged toward whichever end carries the most material,
/// and only lands halfway up when the area happens to be spread evenly about
/// that line.
///
/// So the halfway line is drawn on the section, and the answer is which side
/// of it the centroid falls on. No arithmetic: look at where the metal is. The
/// last two rounds are the same plate with a hole moved from above the middle
/// to below it, which is the negative-area rule made visible.
class AboveOrBelowGame extends StatefulWidget {
  const AboveOrBelowGame({super.key});

  @override
  State<AboveOrBelowGame> createState() => _AboveOrBelowGameState();
}

@immutable
class SitRound {
  const SitRound({
    required this.subject,
    required this.setting,
    required this.profile,
    required this.why,
    required this.source,
  });

  final String subject;
  final String setting;
  final Profile profile;
  final String why;
  final String source;

  /// Worked out from the pieces, never declared beside the round.
  Sit get answer => profile.sit;
}

/// The lesson's own T: a wide flange on top of a narrow web.
const _tee = Profile([
  Piece(Slab.box, Offset(50, 0), Size(20, 80)),
  Piece(Slab.box, Offset(0, 80), Size(120, 20)),
]);

/// The same T stood on its head.
const _upsideDownTee = Profile([
  Piece(Slab.box, Offset(0, 0), Size(120, 20)),
  Piece(Slab.box, Offset(50, 20), Size(20, 80)),
]);

/// Equal flanges top and bottom.
const _evenI = Profile([
  Piece(Slab.box, Offset(0, 0), Size(200, 30)),
  Piece(Slab.box, Offset(85, 30), Size(30, 140)),
  Piece(Slab.box, Offset(0, 170), Size(200, 30)),
]);

/// The lesson's built-up section, whose bottom flange is the wider one.
const _builtUp = Profile([
  Piece(Slab.box, Offset(0, 0), Size(200, 30)),
  Piece(Slab.box, Offset(85, 30), Size(30, 140)),
  Piece(Slab.box, Offset(25, 170), Size(150, 30)),
]);

/// The lesson's plate, with the hole above the middle.
const _holeHigh = Profile([
  Piece(Slab.box, Offset(0, 0), Size(300, 200)),
  Piece(Slab.disc, Offset(120, 120), Size(60, 60), hole: true),
]);

/// The same plate, with the hole moved below the middle.
const _holeLow = Profile([
  Piece(Slab.box, Offset(0, 0), Size(300, 200)),
  Piece(Slab.disc, Offset(120, 20), Size(60, 60), hole: true),
]);

const sitRounds = <SitRound>[
  SitRound(
    subject: 'a T with the flange on top',
    setting:
        'A narrow web with a wide flange laid across the top of it. The dashed '
        'line is halfway up the overall height.',
    profile: _tee,
    why:
        'Above it. The flange is six times the width of the web, so most of '
        'the metal is up at the top and the average is dragged up there with '
        'it. Halfway up would be the answer only if the section were as heavy '
        'below that line as above, and it is nowhere near.',
    source: 'stat-ccs-q1',
  ),
  SitRound(
    subject: 'the same T stood on its head',
    setting:
        'The identical two pieces, turned over, so the wide flange is now the '
        'base and the web stands up from it.',
    profile: _upsideDownTee,
    why:
        'Below it. Nothing about the pieces changed, only which way up they '
        'are, and the answer flipped with them. That is the whole idea: the '
        'centroid follows the area, so it goes wherever the heavy part goes.',
    source: 'stat-ccs-q1',
  ),
  SitRound(
    subject: 'equal flanges, top and bottom',
    setting:
        'A web with the same flange at each end, so the section reads the same '
        'either way up.',
    profile: _evenI,
    why:
        'On the line. This is the one case where halfway up is right, and it '
        'is right because the section is symmetric about that line and not '
        'because halfway is ever a rule. Spot the symmetry and you have the '
        'answer without writing anything.',
    source: 'stat-ccs-q3',
  ),
  SitRound(
    subject: 'a built-up section with unequal flanges',
    setting:
        'A web between two flanges again, but the bottom one is wider than the '
        'top one. The overall height is unchanged.',
    profile: _builtUp,
    why:
        'Below it, and by less than the T was. The bottom flange carries more '
        'area than the top one, so the average settles below halfway, but the '
        'web and the top flange pull back and it does not go far. Nearly '
        'symmetric is not symmetric.',
    source: 'stat-ccs-q3',
  ),
  SitRound(
    subject: 'a plate with a hole drilled high',
    setting:
        'A plain rectangular plate with one round hole, drilled above the '
        'halfway line.',
    profile: _holeHigh,
    why:
        'Below it. Take material away from the top and what is left is '
        'bottom-heavy, so the centroid drops. Treat the hole as a piece with '
        'NEGATIVE area and the same weighted average handles it: it subtracts '
        'from the top of the fraction and from the bottom of it too.',
    source: 'stat-ccs-q2',
  ),
  SitRound(
    subject: 'the same plate, hole drilled low',
    setting:
        'The identical plate and the identical hole, moved to the same '
        'distance below the halfway line instead of above it.',
    profile: _holeLow,
    why:
        'Above it. Removing metal from the bottom leaves the plate top-heavy, '
        'which is the last round turned over. Getting the direction backwards '
        'is the trap the lesson names, and this pair is here so you can feel '
        'which way it goes without doing the sum.',
    source: 'stat-ccs-q2',
  ),
];

class _AboveOrBelowGameState extends State<AboveOrBelowGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'above-or-below-middle',
    chapterId: 'statics',
    total: sitRounds.length,
    sourceProblemIdOf: (round) => sitRounds[round].source,
  )..addListener(_onSession);

  Sit? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  SitRound get _round => sitRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Above or Below the Middle',
        closing:
            'The centroid is an area-weighted average, so it sits where the '
            'metal is, not where the height is. Halfway up is right only when '
            'the section is symmetric about that line. And a hole is a piece '
            'with negative area: take material from one end and the centroid '
            'moves toward the other.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: areaWeightedBrief,
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
            'WHERE DOES THE CENTROID SIT',
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 250,
              width: double.infinity,
              child: EngineeringGrid(
                minor: 18,
                major: 90,
                child: CustomPaint(
                  painter: ProfilePainter(
                    profile: r.profile,
                    showMiddle: true,
                    markCentroid: answered,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final option in Sit.values) ...[
                if (option != Sit.values.first) const SizedBox(width: 8),
                Expanded(
                  child: _SitButton(
                    key: ValueKey('sit-${option.name}'),
                    option: option,
                    selected: _picked == option,
                    locked: answered,
                    isTruth: option == r.answer,
                    onTap: answered
                        ? null
                        : () => setState(() => _picked = option),
                  ),
                ),
              ],
            ],
          ),
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS WHERE IT SITS' : 'THE OTHER SIDE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _SitButton extends StatelessWidget {
  const _SitButton({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final Sit option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  static const _titles = {
    Sit.above: 'Above',
    Sit.onIt: 'On the line',
    Sit.below: 'Below',
  };

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    final Color ink;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
      ink = AppColors.forest;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
      ink = AppColors.error;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
      ink = AppColors.ember;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
      ink = AppColors.charcoal;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 92,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 46,
                height: 34,
                child: CustomPaint(painter: _SitGlyph(option, ink)),
              ),
              const SizedBox(height: 7),
              Text(
                _titles[option]!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dashed line with the centroid mark where this answer would put it.
class _SitGlyph extends CustomPainter {
  const _SitGlyph(this.option, this.colour);

  final Sit option;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height / 2;
    final dash = Paint()
      ..color = AppColors.ink3
      ..strokeWidth = 1.4;
    for (var x = 2.0; x < size.width - 2; x += 7) {
      canvas.drawLine(Offset(x, mid), Offset(x + 4, mid), dash);
    }

    final y = switch (option) {
      Sit.above => mid - 10,
      Sit.onIt => mid,
      Sit.below => mid + 10,
    };
    final here = Offset(size.width / 2, y);
    final ink = Paint()
      ..color = colour
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(here, 3, Paint()..color = AppColors.cream);
    canvas.drawLine(here - const Offset(8, 0), here + const Offset(8, 0), ink);
    canvas.drawLine(here - const Offset(0, 8), here + const Offset(0, 8), ink);
    canvas.drawCircle(
      here,
      4.6,
      Paint()
        ..color = colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SitGlyph old) =>
      old.option != option || old.colour != colour;
}
