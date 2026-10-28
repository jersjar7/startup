import 'dart:math' as maths;

import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/games/above_or_below_game.dart'
    show sitRounds, SitGlyph;
import 'package:mobile/features/games/along_it_or_not_game.dart'
    show pinRounds;
import 'package:mobile/features/games/does_it_multiply_game.dart'
    show leverRounds;
import 'package:mobile/features/games/frame_figures.dart'
    show FramePainter, Kind, Lever, LeverPainter, Pull;
import 'package:mobile/features/games/frame_truss_or_machine_game.dart'
    show kindRounds, KindGlyph;
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/move_it_right_game.dart'
    show axisRounds, MoveGlyph;
import 'package:mobile/features/games/rank_by_stiffness_game.dart'
    show rankRounds;
import 'package:mobile/features/games/section_figures.dart'
    show Datum, JobPainter, LineUpPainter, Needs, ProfilePainter, Sit, Transfer;
import 'package:mobile/features/games/tap_its_centroid_game.dart'
    show spotRounds;
import 'package:mobile/features/games/which_barely_matters_game.dart'
    show shareRounds;
import 'package:mobile/features/games/which_distance_goes_in_game.dart'
    show dropRounds;
import 'package:mobile/features/games/which_second_moment_game.dart'
    show jobRounds, NeedsGlyph;

import 'package:flutter/material.dart' hide Path, TextPainter;

import 'builder.dart';
import 'fluids.dart' show tapDrawing, top;
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show feedback, stacked, withRounds;

/// The Statics games, second half: frames and machines, centroids and
/// second moments. Every round is the problem over a drawing, answered
/// either on the drawing (an arrow, a point, a distance, a piece, or the
/// shapes in order) or on buttons that carry a small drawing of their own,
/// so the screens are written as screen nodes.

/// A small drawing on an answer button, drawn in the ink each state of
/// the button gives it.
Object glyph(
  void Function(Canvas canvas, Size size, Color ink) paint,
  double w,
  double h, {
  required String what,
}) {
  Object at(Color ink, String state) => record(
    (canvas, size) => paint(canvas, size, ink),
    h,
    range: (w, w + 1),
    what: '$what $state',
  );
  return tone(
    at(AppColors.charcoal, 'idle'),
    at(AppColors.ember, 'picked'),
    at(AppColors.forest, 'right'),
    at(AppColors.error, 'wrong'),
  );
}

/// A button with its drawing on the left and a title over a note: the
/// answers one under another.
Node noteButton(
  int i, {
  required Object glyph,
  required double glyphW,
  required double glyphH,
  required double space,
  required double h,
  required List<num> pad,
  required String title,
  required String note,
}) => tinted(
  i,
  row([
    box(w: glyphW, h: glyphH, child: draw(glyph)),
    gapW(space),
    flex(
      col(
        [
          t(title, size: 15, bold: true),
          gapH(2),
          t(note, font: 'mono', size: 10.5, color: 'ink3'),
        ],
        main: 'center',
        cross: 'start',
      ),
    ),
  ]),
  h: h,
  pad: pad,
);

/// A drawing answered by tapping on it, on the grid, clipped to the
/// games' 16 pixel corner.
Node tapFigure(Node tap, double h) =>
    clip(box(w: 'max', h: h, child: grid(tap)), 16);

/// Rectangles to tap, the later one winning where two overlap, as the
/// topmost of the built-in game's stack of tap areas does.
Draw areas(int n, Rect Function(Size size, int i) area) => (canvas, size) {
  for (var i = 0; i < n; i++) {
    canvas.drawRect(area(size, i), Paint());
  }
};

Map<String, Object?> alongItOrNot() => pickScreen(
  id: 'along-it-or-not',
  chapter: 'statics',
  title: 'Along It or Not',
  closing:
      'Count the places something touches a member. Exactly two, and its '
      'force is along the line joining them, whatever shape the member '
      'is. Three or more and you know nothing about the direction until '
      'you have solved for it. That count is the cheapest thing you will '
      'ever do to a frame and it hands you free unknowns.',
  right: 'THAT IS THE DIRECTION',
  wrong: 'NOT THAT ONE',
  brief: briefJson(twoForceBrief, 'twoForceBrief'),
  rounds: [
    for (final (i, r) in pinRounds.indexed)
      () {
        final arrows = r.aims.length;
        // Minus one in the game, "none of them", is the answer after the
        // arrows.
        final answer = r.answer < 0 ? arrows : r.answer;
        return (
          options: [
            for (var a = 0; a < arrows; a++) 'Arrow ${a + 1}',
            'None of them, not from the shape',
          ],
          notes: null,
          tex: null,
          answer: answer,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHICH WAY DOES THAT FORCE ACT', r.subject, r.setting),
            gap(10),
            tapFigure(
              tapDrawing(
                h: 300,
                hits: [for (var a = 0; a < arrows; a++) a],
                targets: areas(
                  arrows,
                  (size, a) => Rect.fromCenter(
                    center: FramePainter.aimTip(
                      r.rig,
                      size,
                      r.limb,
                      r.atPin,
                      r.aims,
                      a,
                    ),
                    width: 48,
                    height: 48,
                  ),
                ),
                draw: (pick, answered) =>
                    (canvas, size) => FramePainter(
                      rig: r.rig,
                      spotlight: r.limb,
                      atPin: r.atPin,
                      aims: r.aims,
                      picked: pick,
                      truth: r.answer,
                      locked: answered,
                    ).paint(canvas, size),
                other: true,
                what: 'along-it-or-not round $i',
              ),
              300,
            ),
            gap(8),
            tinted(
              arrows,
              col(
                [
                  t('None of them, not from the shape', size: 15, bold: true),
                  gapH(2),
                  t(
                    'this member is touched in more than two places',
                    font: 'mono',
                    size: 10.5,
                    color: 'ink3',
                  ),
                ],
                main: 'center',
                cross: 'start',
              ),
              h: 58,
              pad: const [14, 0, 14, 0],
              align: 'left',
            ),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> doesItMultiply() {
  const titles = {
    Pull.multiplies: 'More force than you put in',
    Pull.divides: 'Less force than you put in',
    Pull.neither: 'The same force, turned around',
  };
  const notes = {
    Pull.multiplies: 'your arm is the longer one',
    Pull.divides: 'your arm is the shorter one, and you buy reach',
    Pull.neither: 'the two arms are the same',
  };
  // A lever with the pivot where each answer would put it.
  const shapes = {
    Pull.multiplies: Lever(pivotAt: 0.22, effortAt: 1.0, loadAt: 0.0),
    Pull.divides: Lever(pivotAt: 0.78, effortAt: 1.0, loadAt: 0.0),
    Pull.neither: Lever(pivotAt: 0.5, effortAt: 1.0, loadAt: 0.0),
  };
  final glyphs = {
    for (final p in Pull.values)
      p: record(
        LeverPainter(lever: shapes[p]!, plain: true).paint,
        34,
        range: (62, 63),
        what: 'does-it-multiply ${p.name} glyph',
      ),
  };
  return pickScreen(
    id: 'does-it-multiply',
    chapter: 'statics',
    title: 'Does It Multiply',
    closing:
        'Moments about the pivot, and the force out is the force in times '
        'YOUR arm over ITS arm. Long arm on top and the machine gives you '
        'more force than you put in. Short arm on top and it gives you '
        'less, and buys you speed and reach instead. Look at which arm is '
        'longer before you touch a calculator.',
    right: 'THAT IS WHAT IT DOES',
    wrong: 'THE OTHER WAY',
    brief: briefJson(leverBrief, 'leverBrief'),
    rounds: [
      for (final (i, r) in leverRounds.indexed)
        (
          options: [for (final p in Pull.values) titles[p]!],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHAT DOES IT DO TO YOUR FORCE', r.subject, r.setting),
            gap(10),
            pictured(
              record(
                LeverPainter(lever: r.lever).paint,
                230,
                what: 'does-it-multiply round $i',
              ),
              230,
            ),
            gap(12),
            ...stacked([
              for (final p in Pull.values)
                noteButton(
                  p.index,
                  glyph: glyphs[p]!,
                  glyphW: 62,
                  glyphH: 34,
                  space: 8,
                  h: 64,
                  pad: const [6, 0, 14, 0],
                  title: titles[p]!,
                  note: notes[p]!,
                ),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> frameTrussOrMachine() {
  const titles = {
    Kind.truss: 'A truss',
    Kind.frame: 'A frame',
    Kind.machine: 'A machine',
  };
  const notes = {
    Kind.truss: 'every member touched twice',
    Kind.frame: 'holds still, something bends',
    Kind.machine: 'parts move against each other',
  };
  final glyphs = {
    for (final k in Kind.values)
      k: glyph(
        (canvas, size, ink) => KindGlyph(k, ink).paint(canvas, size),
        48,
        32,
        what: 'frame-truss-or-machine ${k.name} glyph',
      ),
  };
  return pickScreen(
    id: 'frame-truss-or-machine',
    chapter: 'statics',
    title: 'Frame, Truss or Machine',
    closing:
        'Does it move? Then it is a machine. If it holds still, count the '
        'places something touches each member: all of them touched twice '
        'and it is a truss, any one of them touched three times and it is '
        'a frame. The name is not trivia. It says whether you may assume '
        'every force runs along its member.',
    right: 'THAT IS WHAT IT IS',
    wrong: 'SOMETHING ELSE',
    brief: briefJson(whatItIsBrief, 'whatItIsBrief'),
    rounds: [
      for (final (i, r) in kindRounds.indexed)
        (
          options: [for (final k in Kind.values) titles[k]!],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHAT IS THIS THING', r.subject, r.setting),
            gap(10),
            pictured(
              record(
                FramePainter(rig: r.rig).paint,
                250,
                what: 'frame-truss-or-machine round $i',
              ),
              250,
            ),
            gap(14),
            answerRow([
              for (final k in Kind.values)
                tinted(
                  k.index,
                  col([
                    box(w: 48, h: 32, child: draw(glyphs[k]!)),
                    gapH(6),
                    t(titles[k]!, size: 14, bold: true),
                    gapH(3),
                    t(
                      notes[k]!,
                      font: 'mono',
                      size: 9,
                      color: 'ink3',
                      align: 'center',
                    ),
                  ], main: 'center'),
                  h: 112,
                  pad: const [6, 0, 6, 0],
                ),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> aboveOrBelowMiddle() {
  const titles = {
    Sit.above: 'Above',
    Sit.onIt: 'On the line',
    Sit.below: 'Below',
  };
  final glyphs = {
    for (final s in Sit.values)
      s: glyph(
        (canvas, size, ink) => SitGlyph(s, ink).paint(canvas, size),
        46,
        34,
        what: 'above-or-below-middle ${s.name} glyph',
      ),
  };
  return pickScreen(
    id: 'above-or-below-middle',
    chapter: 'statics',
    title: 'Above or Below the Middle',
    closing:
        'The centroid is an area-weighted average, so it sits where the '
        'metal is, not where the height is. Halfway up is right only when '
        'the section is symmetric about that line. And a hole is a piece '
        'with negative area: take material from one end and the centroid '
        'moves toward the other.',
    right: 'THAT IS WHERE IT SITS',
    wrong: 'THE OTHER SIDE',
    brief: briefJson(areaWeightedBrief, 'areaWeightedBrief'),
    rounds: [
      for (final (i, r) in sitRounds.indexed)
        (
          options: [for (final s in Sit.values) titles[s]!],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHERE DOES THE CENTROID SIT', r.subject, r.setting),
            gap(10),
            pictured(
              askDone(
                record(
                  ProfilePainter(
                    profile: r.profile,
                    showMiddle: true,
                  ).paint,
                  250,
                  what: 'above-or-below-middle round $i',
                ),
                record(
                  ProfilePainter(
                    profile: r.profile,
                    showMiddle: true,
                    markCentroid: true,
                  ).paint,
                  250,
                  what: 'above-or-below-middle round $i answered',
                ),
              ),
              250,
            ),
            gap(14),
            answerRow([
              for (final s in Sit.values)
                tinted(
                  s.index,
                  col([
                    box(w: 46, h: 34, child: draw(glyphs[s]!)),
                    gapH(7),
                    t(titles[s]!, size: 13.5, bold: true, align: 'center'),
                  ], main: 'center'),
                  h: 92,
                  pad: const [4, 0, 4, 0],
                ),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> tapItsCentroid() => pickScreen(
  id: 'tap-its-centroid',
  chapter: 'statics',
  title: 'Tap Its Centroid',
  closing:
      'A third of the way from the wide end of a triangle. Four r over '
      'three pi from the flat side of a half disc. The middle of a '
      'rectangle. The handbook has them all and you are not asked to '
      'derive any of them, only to know which shape you are holding and '
      'to measure from the right corner of it.',
  right: 'THAT IS THE POINT',
  wrong: 'NOT THAT ONE',
  brief: briefJson(tableBrief, 'tableBrief'),
  rounds: [
    for (final (i, r) in spotRounds.indexed)
      (
        options: [for (var s = 0; s < r.spots.length; s++) 'Point ${s + 1}'],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('TAP THE CENTROID', r.subject, r.setting),
          gap(10),
          tapFigure(
            tapDrawing(
              h: 340,
              hits: [for (var s = 0; s < r.spots.length; s++) s],
              targets: areas(
                r.spots.length,
                (size, s) => Rect.fromCenter(
                  center: ProfilePainter.toScreen(r.profile, r.spots[s], size),
                  width: 46,
                  height: 46,
                ),
              ),
              draw: (pick, answered) =>
                  (canvas, size) => ProfilePainter(
                    profile: r.profile,
                    spots: r.spots,
                    picked: pick,
                    truth: r.answer,
                    locked: answered,
                  ).paint(canvas, size),
              what: 'tap-its-centroid round $i',
            ),
            340,
          ),
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> whichDistanceGoesIn() => pickScreen(
  id: 'which-distance-goes-in',
  chapter: 'statics',
  title: 'Which Distance Goes In',
  closing:
      'Choose one axis before you start and measure every piece from it, '
      'to that piece\'s own centroid and nowhere else. The whole of the '
      'weighted average is areas times those distances. Switch reference '
      'partway through and the arithmetic still works and the answer is '
      'still wrong.',
  right: 'THAT IS THE ONE',
  wrong: 'A DIFFERENT ONE',
  brief: briefJson(referenceBrief, 'referenceBrief'),
  rounds: [
    for (final (i, r) in dropRounds.indexed)
      (
        options: [for (final d in r.drops) d.label],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH ONE GOES IN THE SUM', r.subject, r.setting),
          gap(10),
          tapFigure(
            tapDrawing(
              h: 260,
              hits: [for (var d = 0; d < r.drops.length; d++) d],
              // A dimension is tall and thin, so its target is the height of
              // its lane and wide enough for a thumb.
              targets: areas(r.drops.length, (size, d) {
                final lane = ProfilePainter.laneFor(
                  r.profile,
                  size,
                  r.drops,
                  d,
                );
                Offset at(double y) => ProfilePainter.toScreen(
                  r.profile,
                  Offset(r.profile.bounds.left, y),
                  size,
                  drops: r.drops,
                );
                final a = at(r.drops[d].from);
                final b = at(r.drops[d].to);
                final upper = a.dy < b.dy ? a.dy : b.dy;
                final tall = (a.dy - b.dy).abs();
                return Rect.fromLTWH(
                  lane - 22,
                  upper - 8,
                  44,
                  tall < 44 ? 44 : tall + 16,
                );
              }),
              draw: (pick, answered) =>
                  (canvas, size) => ProfilePainter(
                    profile: r.profile,
                    drops: r.drops,
                    spotlight: r.piece,
                    picked: pick,
                    truth: r.answer,
                    locked: answered,
                  ).paint(canvas, size),
              what: 'which-distance-goes-in round $i',
            ),
            260,
          ),
          gap(10, when: 'done'),
          for (final (d, drop) in r.drops.indexed)
            box(
              pad: const [0, 0, 0, 3],
              when: 'done',
              child: t(
                '${d + 1}  ${drop.label}',
                font: 'mono',
                size: 11,
                color: d == r.answer ? 'forest' : 'ink3',
              ),
            ),
          ...feedback(12),
        ],
      ),
  ],
);

/// Every order of picks from [n] marks, none to all of them.
List<List<int>> _orders(int n) {
  final out = <List<int>>[[]];
  for (var k = 0; k < out.length; k++) {
    if (out[k].length == n) continue;
    for (var m = 0; m < n; m++) {
      if (!out[k].contains(m)) out.add([...out[k], m]);
    }
  }
  return out;
}

Map<String, Object?> rankByStiffness() => withRounds(
  pickSeveral(
    id: 'rank-by-stiffness',
    chapter: 'statics',
    title: 'Rank Them by Stiffness',
    closing:
        'The farther the material from the axis, the stiffer the section, '
        'and the distance is squared, so metal near the axis is nearly '
        'wasted. Depth is cubed in the formula and width is not. Before '
        'you look anything up, look at where the material is.',
    right: 'THAT IS THE ORDER',
    wrong: 'A DIFFERENT ORDER',
    brief: briefJson(farFromAxisBrief, 'farFromAxisBrief'),
    rounds: [
      for (final (i, r) in rankRounds.indexed)
        (
          options: [
            for (var s = 0; s < r.shapes.length; s++) 'Section ${s + 1}',
          ],
          answer: r.answer,
          alone: const [],
          why: r.why,
          source: r.source,
          screen: [
            ...top('TAP THEM STIFFEST FIRST', r.subject, r.setting),
            gap(10),
            tapFigure({
              'k': 'tapdraw',
              'by': 'order',
              // The shapes numbered in the order they were tapped, every
              // order that can be on screen, and once answered the full
              // ones only.
              'd': {
                for (final order in _orders(r.shapes.length))
                  for (final answered in [false, true])
                    if (!answered || order.length == r.shapes.length)
                      '${order.isEmpty ? '-' : order.join(',')}|'
                          '${answered ? 1 : 0}': record(
                        LineUpPainter(
                          shapes: r.shapes,
                          order: order,
                          truth: r.answer,
                          locked: answered,
                        ).paint,
                        215,
                        what: 'rank-by-stiffness round $i $order $answered',
                      ),
              },
              'targets': record(
                areas(
                  r.shapes.length,
                  (size, s) => LineUpPainter.cellFor(r.shapes, size, s),
                ),
                215,
                what: 'rank-by-stiffness round $i targets',
              ),
              'hits': [for (var s = 0; s < r.shapes.length; s++) s],
              'h': 215,
            }, 215),
            gap(8),
            t(
              askDone(
                'tap again to take one back',
                'the green numbers are the order it should have been in',
              ),
              font: 'mono',
              size: 11,
              color: 'ink3',
            ),
            ...feedback(14),
          ],
        ),
    ],
  ),
  (i) => {
    'need': rankRounds[i].shapes.length,
    'order': 'list',
    'trim': true,
  },
);

Map<String, Object?> moveItRight() {
  const titles = {
    Transfer.add: 'Add the transfer term',
    Transfer.subtract: 'Take the transfer term off',
    Transfer.cannot: 'It will not go straight there',
  };
  const notes = {
    Transfer.add: 'leaving the centroidal axis',
    Transfer.subtract: 'arriving at the centroidal axis',
    Transfer.cannot: 'neither axis is the centroidal one',
  };
  final glyphs = {
    for (final m in Transfer.values)
      m: glyph(
        (canvas, size, ink) => MoveGlyph(m, ink).paint(canvas, size),
        44,
        36,
        what: 'move-it-right ${m.name} glyph',
      ),
  };
  return pickScreen(
    id: 'move-it-right',
    chapter: 'statics',
    title: 'Move It Right',
    closing:
        'The centroidal axis is where a section has its smallest moment of '
        'inertia, so leaving it adds the transfer term and arriving at it '
        'takes the term off. Between two axes that both miss the centroid '
        'there is no single step at all: go back through the centroid, '
        'every time.',
    right: 'THAT IS THE MOVE',
    wrong: 'NOT THAT MOVE',
    brief: briefJson(transferBrief, 'transferBrief'),
    rounds: [
      for (final (i, r) in axisRounds.indexed)
        (
          options: [for (final m in Transfer.values) titles[m]!],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHAT DOES THE TRANSFER TERM DO', r.subject, r.setting),
            gap(10),
            pictured(
              record(
                ProfilePainter(
                  profile: r.profile,
                  axes: [r.from, r.to],
                  markCentroid: true,
                ).paint,
                250,
                what: 'move-it-right round $i',
              ),
              250,
            ),
            gap(6),
            {
              'mono': 'the chain line is the centroidal axis',
              'size': 11,
              'color': 'ink3',
            },
            gap(12),
            ...stacked([
              for (final m in Transfer.values)
                noteButton(
                  m.index,
                  glyph: glyphs[m]!,
                  glyphW: 44,
                  glyphH: 36,
                  space: 12,
                  h: 64,
                  pad: const [12, 0, 12, 0],
                  title: titles[m]!,
                  note: notes[m]!,
                ),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

Map<String, Object?> whichBarelyMatters() => pickScreen(
  id: 'which-barely-matters',
  chapter: 'statics',
  title: 'Which One Barely Matters',
  closing:
      'Every piece brings its own value and a transfer term, and the '
      'transfer term carries the distance SQUARED. A piece on the axis '
      'therefore contributes almost nothing however much metal is in it, '
      'and a small piece a long way out can carry most of the section. '
      'Look at where a piece sits before you look at how big it is.',
  right: 'BARELY WORTH ADDING',
  wrong: 'THAT ONE EARNS ITS PLACE',
  brief: briefJson(compositeIBrief, 'compositeIBrief'),
  rounds: [
    for (final (i, r) in shareRounds.indexed)
      () {
        final axes = [Datum(r.profile.centroid.dy, 'axis')];
        final pieces = r.profile.pieces.length;
        return (
          options: r.names,
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: [
            ...top('TAP THE PIECE THAT BARELY COUNTS', r.subject, r.setting),
            gap(10),
            tapFigure(
              tapDrawing(
                h: 270,
                hits: [for (var p = 0; p < pieces; p++) p],
                // A thin flange is only a few pixels deep, so its target
                // is grown to something a thumb can find.
                targets: areas(pieces, (size, p) {
                  final box = ProfilePainter.pieceRect(
                    r.profile,
                    size,
                    p,
                    axes: axes,
                  );
                  return Rect.fromCenter(
                    center: box.center,
                    width: maths.max(box.width, 40),
                    height: maths.max(box.height, 34),
                  );
                }),
                draw: (pick, answered) =>
                    (canvas, size) => ProfilePainter(
                      profile: r.profile,
                      axes: axes,
                      spotlight: pick ?? -1,
                      truth: r.answer,
                      locked: answered,
                    ).paint(canvas, size),
                what: 'which-barely-matters round $i',
              ),
              270,
            ),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichSecondMoment() {
  const titles = {
    Needs.iAboutX: 'I about the horizontal axis',
    Needs.iAboutY: 'I about the vertical axis',
    Needs.polarJ: 'The polar moment J',
  };
  const notes = {
    Needs.iAboutX: 'bending from a load pushing up or down',
    Needs.iAboutY: 'bending from a load pushing sideways',
    Needs.polarJ: 'twisting about the member, and J is the two I added',
  };
  final glyphs = {
    for (final n in Needs.values)
      n: glyph(
        (canvas, size, ink) => NeedsGlyph(n, ink).paint(canvas, size),
        38,
        34,
        what: 'which-second-moment ${n.name} glyph',
      ),
  };
  return pickScreen(
    id: 'which-second-moment',
    chapter: 'statics',
    title: 'Which Second Moment',
    closing:
        'Bending needs I, and it is I about the axis SQUARE to the load, '
        'whichever way round the member is drawn. Twisting needs J, which '
        'is the two I values added about the same point. Reaching for one '
        'where the other belongs is on the trap list for this whole '
        'chapter, and it is decided before any number is looked up.',
    right: 'THAT IS THE ONE',
    wrong: 'A DIFFERENT ONE',
    brief: briefJson(polarBrief, 'polarBrief'),
    rounds: [
      for (final (i, r) in jobRounds.indexed)
        (
          options: [for (final n in Needs.values) titles[n]!],
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: [
            ...top('WHICH ONE DOES THIS JOB NEED', r.subject, r.setting),
            gap(10),
            pictured(
              askDone(
                record(
                  JobPainter(profile: r.profile, job: r.job).paint,
                  250,
                  what: 'which-second-moment round $i',
                ),
                record(
                  JobPainter(profile: r.profile, job: r.job, showAxis: true)
                      .paint,
                  250,
                  what: 'which-second-moment round $i answered',
                ),
              ),
              250,
            ),
            gap(12),
            ...stacked([
              for (final n in Needs.values)
                noteButton(
                  n.index,
                  glyph: glyphs[n]!,
                  glyphW: 38,
                  glyphH: 34,
                  space: 12,
                  h: 60,
                  pad: const [12, 0, 12, 0],
                  title: titles[n]!,
                  note: notes[n]!,
                ),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

final adapters = <String, Map<String, Object?> Function()>{
  'along-it-or-not': alongItOrNot,
  'does-it-multiply': doesItMultiply,
  'frame-truss-or-machine': frameTrussOrMachine,
  'above-or-below-middle': aboveOrBelowMiddle,
  'tap-its-centroid': tapItsCentroid,
  'which-distance-goes-in': whichDistanceGoesIn,
  'rank-by-stiffness': rankByStiffness,
  'move-it-right': moveItRight,
  'which-barely-matters': whichBarelyMatters,
  'which-second-moment': whichSecondMoment,
};
