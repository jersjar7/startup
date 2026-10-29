import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/games/beam_figures.dart';
import 'package:mobile/features/games/can_statics_solve_it_game.dart';
import 'package:mobile/features/games/friction_figures.dart';
import 'package:mobile/features/games/harder_or_easier_game.dart';
import 'package:mobile/features/games/is_it_about_to_move_game.dart';
import 'package:mobile/features/games/lesson_brief.dart';
import 'package:mobile/features/games/statics_figures.dart';
import 'package:mobile/features/games/stretched_or_squashed_game.dart';
import 'package:mobile/features/games/truss_figures.dart';
import 'package:mobile/features/games/what_the_support_gives_game.dart';
import 'package:mobile/features/games/where_do_you_cut_game.dart';
import 'package:mobile/features/games/where_it_all_acts_game.dart';
import 'package:mobile/features/games/which_arrow_is_that_game.dart';
import 'package:mobile/features/games/which_carry_nothing_game.dart';
import 'package:mobile/features/games/which_distance_counts_game.dart';
import 'package:mobile/features/games/which_ones_turn_it_game.dart';
import 'package:mobile/features/games/which_side_is_tight_game.dart';
import 'package:mobile/features/games/will_it_hold_itself_game.dart';

import 'package:flutter/material.dart' hide Path;

import 'builder.dart';
import 'fluids.dart' show tapDrawing, top;
import 'nodes.dart';
import 'pick_one_adapter.dart';
import 'statistics.dart' show doneOverline, feedback, overline, subject;

/// The Statics games, first half. Each is the problem, then a drawing that
/// is tapped or a drawing over answer buttons of the chapter's own kind
/// (a glyph and two lines of words, a picture and a count), written as
/// screen nodes.

/// The small mono line under a problem saying how to answer it.
Map<String, Object?> hint(String words) => {
  'mono': words,
  'size': 11,
  'color': 'ink3',
};

/// A drawing on the grid, clipped to the games' 16 pixel corner, holding
/// [child] (a drawing, or one answered by tapping), on a grid of [minor]
/// and [major].
Node framed(Node child, num h, {num? minor, num? major}) => clip(
  box(
    w: 'max',
    h: h,
    child: grid(child, minor: minor, major: major),
  ),
  16,
);

/// A drawing that never changes with the pick, before and after the answer.
Node still(Draw Function(bool answered) paint, double h, String what) => framed(
  draw({
    'ask': record(paint(false), h, what: '$what asked'),
    'done': record(paint(true), h, what: '$what answered'),
  }),
  h,
);

/// The chapter's answer button: white, ember once picked, then forest or
/// red, its border a pixel thicker once it is anything but idle.
Node toned(
  int i, {
  Object? w = 'max',
  num? h,
  num? minH,
  List<num>? pad,
  String? align,
  Node? child,
  List<Node>? c,
  String? cross,
}) => answer(
  i,
  box(
    w: w,
    h: h,
    minH: minH,
    pad: pad,
    align: align,
    radius: 12,
    border: tone('line', 'ember', 'forest', 'error'),
    stroke: tone(1, 2, 2, 2),
    child: child,
    c: c,
    cross: cross,
  ),
  fill: tone('white', 'emberBg', 'forestBg', 'errorBg'),
);

/// The row under a tapped drawing for "none of them".
Node noneRow(int i, String words) => toned(
  i,
  h: 50,
  pad: const [14, 0, 14, 0],
  align: 'left',
  child: t(words, size: 14.5),
);

/// A bold title over a mono note, the words of most of the chapter's
/// answer buttons.
Node titled(String title, String note) => col(
  [
    t(title, size: 15, bold: true),
    gapH(2),
    t(note, font: 'mono', size: 10.5, color: 'ink3'),
  ],
  main: 'center',
  cross: 'start',
);

/// An answer button with a small fixed drawing before its words.
Node glyphButton(
  int i, {
  required num h,
  required double gw,
  required double gh,
  required Draw glyph,
  required String title,
  required String note,
  required String what,
  bool grow = false,
}) => toned(
  i,
  // [grow]: at least [h] tall, taller when the note wraps.
  h: grow ? null : h,
  minH: grow ? h : null,
  pad: grow ? const [14, 8, 14, 8] : const [14, 0, 14, 0],
  child: row([
    box(
      w: gw,
      h: gh,
      child: draw(record(glyph, gh, range: (gw, gw + 1), what: what)),
    ),
    gapW(12),
    flex(titled(title, note)),
  ]),
);

/// Answers one under another, 8 apart, none after the last.
List<Node> stack(List<Node> answers) => [
  for (final (i, a) in answers.indexed) ...[if (i > 0) gapH(8), a],
];

/// Tap areas laid over a drawing as a stack of them, the topmost (the last)
/// taking the tap, as the pack does.
({List<int> hits, Draw targets}) zones(
  int n,
  Rect Function(Size size, int i) area,
) => (
  hits: [for (var i = 0; i < n; i++) i],
  targets: (canvas, size) {
    for (var i = 0; i < n; i++) {
      canvas.drawRect(area(size, i), Paint());
    }
  },
);

/// A square tap area [side] across, centred on [at] and moved down [down].
Rect square(Offset at, double side, {double down = 0}) =>
    Rect.fromLTWH(at.dx - side / 2, at.dy - side / 2 + down, side, side);

/// A drawing answered by tapping any number of its parts: drawn as
/// [under], then each part picked or not, then [over], so no drawing is
/// kept for every set of picks.
Node layeredTap({
  required double h,
  required int parts,
  required Draw under,
  required Draw Function(int part, bool picked, bool answered) part,
  Draw? over,
  required ({List<int> hits, Draw targets}) zones,
  required String what,
}) => {
  'k': 'tapdraw',
  'layers': [
    {'d': record(under, h, what: '$what under')},
    for (var m = 0; m < parts; m++)
      {
        'mark': m,
        'd': {
          for (final picked in [false, true])
            for (final answered in [false, true])
              '${picked ? 1 : 0}|${answered ? 1 : 0}': record(
                part(m, picked, answered),
                h,
                what:
                    '$what part $m${picked ? ' picked' : ''}'
                    '${answered ? ' answered' : ''}',
              ),
        },
      },
    if (over != null) {'d': record(over, h, what: '$what over')},
  ],
  'targets': record(zones.targets, h, what: '$what targets'),
  'hits': zones.hits,
  'h': h,
};

Map<String, Object?> whichArrowIsThat() => pickScreen(
  id: 'which-arrow-is-that',
  chapter: 'statics',
  title: 'Which Arrow Is That',
  closing:
      'The cosine goes with the axis the angle is measured FROM, and the '
      'horizontal leg goes with the horizontal component. Neither rule '
      'is about which number is bigger. A component is always shorter '
      'than the force it came from, which is the one check worth making '
      'every time.',
  right: 'THAT ONE',
  wrong: 'A DIFFERENT ARROW',
  brief: briefJson(resolveBrief, 'resolveBrief'),
  rounds: [
    for (final (n, r) in arrowRounds.indexed)
      (
        options: const [
          'the horizontal component',
          'the vertical component',
          'the whole force',
        ],
        notes: null,
        tex: null,
        answer: r.answer,
        why: r.why,
        source: r.source,
        screen: [
          ...top('WHICH ARROW IS ${r.named}', r.subject, r.setting),
          gap(6),
          hint('tap the arrow on the drawing'),
          gap(10),
          framed(
            {
              ...tapDrawing(
                h: 230,
                hits: const [0, 1, 2],
                // The game takes the arrow nearest the tap, wherever it
                // is: each arrow is the line the game measures to, from
                // a little way off the corner to its tip.
                targets: (canvas, size) {
                  final l = ForceTrianglePainter.layout(r.dx, r.dy, size);
                  for (final end in [l.alongX, l.alongY, l.tip]) {
                    final run = end - l.origin;
                    final len = run.distance;
                    final trim = len * 0.22 < 22 ? len * 0.22 : 22.0;
                    canvas.drawLine(l.origin + run / len * trim, end, Paint());
                  }
                },
                draw: (pick, answered) => ForceTrianglePainter(
                  dx: r.dx,
                  dy: r.dy,
                  angleFrom: r.angleFrom,
                  angleLabel: r.angleLabel,
                  xLabel: r.xLabel,
                  yLabel: r.yLabel,
                  selected: pick,
                  locked: answered,
                  truth: r.answer,
                ).paint,
                what: 'which-arrow-is-that round $n',
              ),
            },
            230,
            minor: 20,
            major: 100,
          ),
          ...feedback(),
        ],
      ),
  ],
);

Map<String, Object?> whichDistanceCounts() => pickScreen(
  id: 'which-distance-counts',
  chapter: 'statics',
  title: 'Which Distance Counts',
  closing:
      'Draw the line of action first. The arm is whatever runs square '
      'from the point to that line, which is a horizontal distance for a '
      'vertical force and a vertical one for a horizontal force. It can '
      'be longer than the member, and if the line goes through the '
      'point there is no moment at all.',
  right: 'THAT DISTANCE',
  wrong: 'A DIFFERENT ONE',
  brief: briefJson(momentBrief, 'momentBrief'),
  rounds: [
    for (final (n, r) in armRounds.indexed)
      () {
        final marks = r.scene.marks.length;
        // Each dimension line's tap area, worked out as the game does.
        final areas = zones(marks, (size, i) {
          final (from, to) = r.scene.placedMarks(size)[i];
          final left = (from.dx < to.dx ? from.dx : to.dx) - 6;
          final right = (from.dx > to.dx ? from.dx : to.dx) + 6;
          final up = (from.dy < to.dy ? from.dy : to.dy) - 6;
          final down = (from.dy > to.dy ? from.dy : to.dy) + 6;
          final w = right - left > 44 ? right - left : 44.0;
          final h = down - up > 30 ? down - up : 30.0;
          return Rect.fromCenter(
            center: Offset((left + right) / 2, (up + down) / 2),
            width: w,
            height: h,
          );
        });
        return (
          options: [for (final m in r.scene.marks) m.label, noArm],
          notes: null,
          tex: null,
          answer: r.answer ?? marks,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP THE MOMENT ARM', r.subject, r.setting),
            gap(10),
            framed(
              // Kept closer than plain: the line of action runs dashed
              // down the middle of a slanted strut (see [closer]).
              closer(
                1e-7,
                () => tapDrawing(
                  h: 260,
                  hits: areas.hits,
                  targets: areas.targets,
                  other: true,
                  draw: (pick, answered) => MomentPainter(
                    scene: r.scene,
                    mode: SceneMode.marks,
                    selected: pick,
                    chosen: const {},
                    locked: answered,
                    truth: r.answer ?? -1,
                    truths: const {},
                  ).paint,
                  what: 'which-distance-counts round $n',
                ),
              ),
              260,
              minor: 20,
              major: 100,
            ),
            gap(8),
            noneRow(marks, noArm),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichOnesTurnIt() => pickSeveral(
  id: 'which-ones-turn-it',
  chapter: 'statics',
  title: 'Which Ones Turn It',
  closing:
      'Which way a force turns a body depends on which side of the point '
      'it sits as much as on which way it points. A force aimed through '
      'the point turns it neither way. And two opposite forces on '
      'opposite sides turn it the same way, which is why a couple is a '
      'turn with no push behind it.',
  right: 'THAT IS THE SET',
  wrong: 'NOT THAT SET',
  brief: briefJson(senseBrief, 'senseBrief'),
  rounds: [
    for (final (n, r) in senseRounds.indexed)
      () {
        final forces = r.scene.forces.length;
        MomentPainter painter({Set<int> chosen = const {}, bool on = false}) =>
            MomentPainter(
              scene: r.scene,
              mode: SceneMode.forces,
              selected: null,
              chosen: chosen,
              locked: on,
              truth: -1,
              truths: r.answer,
            );
        void clipped(Canvas canvas, Size size) =>
            canvas.clipRect(Offset.zero & size);
        return (
          options: [for (final f in r.scene.forces) f.label, nothingTurnsIt],
          answer: r.answer.isEmpty ? [forces] : (r.answer.toList()..sort()),
          alone: [forces],
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('WHICH ONES TURN IT CLOCKWISE', r.subject, r.setting),
            gap(6),
            hint('tap every arrow that does, which may be none'),
            gap(10),
            framed(
              layeredTap(
                h: 250,
                parts: forces,
                under: (canvas, size) {
                  clipped(canvas, size);
                  painter().paintBody(canvas, size);
                },
                part: (m, picked, answered) => (canvas, size) {
                  clipped(canvas, size);
                  painter(
                    chosen: {if (picked) m},
                    on: answered,
                  ).paintForce(canvas, size, m);
                },
                over: r.scene.marks.isEmpty
                    ? null
                    : (canvas, size) {
                        clipped(canvas, size);
                        painter().paintMarks(canvas, size);
                      },
                // Centred on each arrow's middle, as the game puts them.
                zones: zones(forces, (size, i) {
                  final f = r.scene.forces[i];
                  final origin = r.scene.toScreen(f.at, size);
                  final len = f.dir.distance;
                  final unit = Offset(f.dir.dx / len, -f.dir.dy / len);
                  return square(origin + unit * 30, 52);
                }),
                what: 'which-ones-turn-it round $n',
              ),
              250,
              minor: 20,
              major: 100,
            ),
            gap(8),
            noneRow(forces, nothingTurnsIt),
            gap(16, when: 'done'),
            doneOverline('EACH ONE'),
            gap(4, when: 'done'),
            for (var i = 0; i < forces; i++)
              box(
                pad: const [0, 0, 0, 3],
                when: 'done',
                child: t(
                  '${r.scene.forces[i].label}   ${r.senseOf(i)}',
                  font: 'code',
                  size: 12,
                ),
              ),
            ...feedback(14),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whatTheSupportGives() {
  // The count under each picture, one line of mono 10, and its 7 below.
  final words = TextPainter(
    // Set the way a Text sets it: over the theme's body style.
    text: TextSpan(
      text: 'one unknown',
      style: ThemeData.localize(
        AppTheme.light,
        AppTheme.light.typography.englishLike,
      ).textTheme.bodyMedium!.merge(AppTheme.mono(size: 10)),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final under = words.height + 7;
  return pickScreen(
    id: 'what-the-support-gives',
    chapter: 'statics',
    title: 'What the Support Gives',
    closing:
        'Whatever a support prevents, it supplies. A roller stops one '
        'direction and gives one force, square to whatever it runs on. A '
        'pin stops two and gives two. A fixed end stops rotation as well, '
        'so it gives a moment on top. Count them before you write anything '
        'down.',
    right: 'THAT IS THE SET',
    wrong: 'A DIFFERENT SET',
    brief: briefJson(supportsBrief, 'supportsBrief'),
    rounds: [
      for (final (n, r) in propRounds.indexed)
        (
          options: [
            for (final (i, o) in r.options.indexed)
              '${i + 1}: ${[if (o.square) 'square', if (o.along) 'along', if (o.moment) 'moment'].join(', ')}',
          ],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('WHAT DOES IT HAND YOU', r.subject, r.setting),
            gap(12),
            framed(
              draw(
                record(
                  BeamPainter(
                    span: 4,
                    supports: [
                      Support(Offset(r.at, 0), r.kind, slope: r.slope),
                    ],
                  ).paint,
                  150,
                  what: 'what-the-support-gives round $n',
                ),
              ),
              150,
            ),
            gap(14),
            answerRow([
              for (final (i, o) in r.options.indexed)
                () {
                  Object glyph(String state) {
                    final stroke = state == 'idle' ? 1 : 2;
                    return record(
                      ReactionGlyphPainter(
                        vertical: o.square,
                        horizontal: o.along,
                        moment: o.moment,
                        slope: o.slope,
                        colour: inkOf(state),
                      ).paint,
                      92 - 2.0 * stroke - under,
                      range: (60, 500),
                      what: 'what-the-support-gives round $n answer $i $state',
                    );
                  }

                  return toned(
                    i,
                    w: null,
                    h: 92,
                    c: [
                      flex(
                        draw(
                          tone(
                            glyph('idle'),
                            glyph('picked'),
                            glyph('right'),
                            glyph('wrong'),
                          ),
                        ),
                      ),
                      box(
                        pad: const [0, 0, 0, 7],
                        child: t(
                          o.count == 1 ? 'one unknown' : '${o.count} unknowns',
                          font: 'mono',
                          size: 10,
                          color: 'ink3',
                        ),
                      ),
                    ],
                  );
                }(),
            ]),
            ...feedback(),
          ],
        ),
    ],
  );
}

/// The ink an answer's drawing takes in each state: charcoal when idle,
/// ember when picked, then forest or red.
Color inkOf(String state) => switch (state) {
  'right' => AppColors.forest,
  'wrong' => AppColors.error,
  'picked' => AppColors.ember,
  _ => AppColors.charcoal,
};

Map<String, Object?> whereItAllActs() => pickScreen(
  id: 'where-it-all-acts',
  chapter: 'statics',
  title: 'Where It All Acts',
  closing:
      'A spread load is replaced by one force at the centroid of its own '
      'shape. Uniform puts it in the middle of the LOADED part, a '
      'triangle a third of the way in from the heavy end, and anything '
      'in between lands in between. The middle of the beam is a guess, '
      'not a rule.',
  right: 'RIGHT THERE',
  wrong: 'SOMEWHERE ELSE',
  brief: briefJson(resultantBrief, 'resultantBrief'),
  rounds: [
    for (final (n, r) in actsRounds.indexed)
      () {
        final areas = zones(
          r.stations.length,
          (size, i) => square(
            BeamPainter.stationAt(size, r.span, r.stations[i].at),
            46,
            down: 8,
          ),
        );
        return (
          options: [for (final s in r.stations) s.label],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP WHERE IT ALL ACTS', r.subject, r.setting),
            gap(6),
            hint('one force, standing in for the whole load'),
            gap(10),
            framed(
              tapDrawing(
                h: 210,
                hits: areas.hits,
                targets: areas.targets,
                draw: (pick, answered) => BeamPainter(
                  span: r.span,
                  supports: r.supports,
                  spreads: [r.load],
                  stations: r.stations,
                  selected: pick,
                  locked: answered,
                  truth: r.answer,
                  markResultant: answered,
                ).paint,
                what: 'where-it-all-acts round $n',
              ),
              210,
            ),
            ...feedback(),
          ],
        );
      }(),
  ],
);

String _propName(Prop kind) => switch (kind) {
  Prop.roller => 'roller',
  Prop.slopedRoller => 'roller on a slope',
  Prop.pin => 'pin',
  Prop.fixed => 'fixed',
  Prop.cable => 'cable',
};

Map<String, Object?> canStaticsSolveIt() => pickScreen(
  id: 'can-statics-solve-it',
  chapter: 'statics',
  title: 'Can Statics Solve It',
  closing:
      'Count the unknowns before you write anything: one for a roller, '
      'two for a pin, three for a fixed end. More than three and '
      'equilibrium runs out, which says nothing against the beam. And '
      'check they point in useful directions, because three vertical '
      'unknowns still leave nothing to hold the beam sideways.',
  right: 'THAT IS IT',
  wrong: 'NOT QUITE',
  brief: briefJson(determinacyBrief, 'determinacyBrief'),
  rounds: [
    for (final (n, r) in solveRounds.indexed)
      () {
        const labels = [
          'Yes, three will do it',
          'No, too many unknowns',
          'No, it will not stand up',
        ];
        const notes = [
          'determinate',
          'statically indeterminate',
          'a mechanism, not a structure',
        ];
        return (
          options: labels,
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('THREE EQUATIONS. ENOUGH?', r.subject, r.setting),
            gap(10),
            framed(
              draw(
                record(
                  BeamPainter(
                    span: r.span,
                    supports: r.supports,
                    loads: r.loads,
                    couples: r.couples,
                  ).paint,
                  190,
                  what: 'can-statics-solve-it round $n',
                ),
              ),
              190,
            ),
            gap(14),
            ...stack([
              for (final v in Enough.values)
                toned(
                  v.index,
                  pad: const [14, 11, 14, 11],
                  cross: 'start',
                  c: [
                    t(labels[v.index], size: 15),
                    gapH(2),
                    t(notes[v.index], font: 'mono', size: 11, color: 'ink3'),
                  ],
                ),
            ]),
            gap(16, when: 'done'),
            doneOverline('THE COUNT'),
            gap(4, when: 'done'),
            {
              'code': [
                for (final s in r.supports)
                  '${s.label.isEmpty ? 'support' : s.label}   '
                      '${_propName(s.kind)}   ${unknownsIn(s.kind)}',
                'total   ${r.unknowns}   against 3 equations',
              ].join('\n'),
              'size': 12,
              'when': 'done',
            },
            ...feedback(14),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichCarryNothing() => pickSeveral(
  id: 'which-carry-nothing',
  chapter: 'statics',
  title: 'Which Ones Carry Nothing',
  closing:
      'Two members at a joint nobody is pulling on, and both are idle. '
      'Three with two of them in line, and the odd one out is idle. Both '
      'rules need the joint to be UNLOADED, and both stop at three '
      'members. Scan for them before writing an equation, because each '
      'one is an unknown you never have to find.',
  right: 'THAT IS THE SET',
  wrong: 'NOT THAT SET',
  brief: briefJson(zeroForceBrief, 'zeroForceBrief'),
  rounds: [
    for (final (n, r) in idleRounds.indexed)
      () {
        final truss = r.truss;
        final members = truss.members.length;
        TrussPainter painter({Set<int> chosen = const {}, bool on = false}) =>
            TrussPainter(
              truss: truss,
              mode: TrussMode.members,
              chosen: chosen,
              truths: r.answer,
              locked: on,
            );
        return (
          options: [
            for (var m = 0; m < members; m++) truss.memberName(m),
            everythingWorks,
          ],
          answer: r.answer.isEmpty ? [members] : (r.answer.toList()..sort()),
          alone: [members],
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP EVERY MEMBER CARRYING NOTHING', r.subject, r.setting),
            gap(10),
            framed(
              layeredTap(
                h: 250,
                parts: members,
                under: painter().paintBack,
                part: (m, picked, answered) =>
                    (canvas, size) => painter(
                      chosen: {if (picked) m},
                      on: answered,
                    ).paintMember(canvas, size, m),
                over: painter().paintFront,
                // Over the middle of every member, as the game puts them.
                zones: zones(members, (size, m) {
                  final (a, b) = truss.members[m];
                  final mid = (truss.joints[a].at + truss.joints[b].at) / 2;
                  return square(TrussPainter.toScreen(truss, mid, size), 44);
                }),
                what: 'which-carry-nothing round $n',
              ),
              250,
            ),
            gap(8),
            noneRow(members, everythingWorks),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> stretchedOrSquashed() => pickScreen(
  id: 'stretched-or-squashed',
  chapter: 'statics',
  title: 'Stretched or Squashed',
  closing:
      'Assume tension, always, and let the sign tell you the truth: '
      'negative means compression. A number on its own is not an answer '
      'on this exam. Say which way the member is being worked or you '
      'have not finished it.',
  right: 'THAT IS THE SENSE',
  wrong: 'THE OTHER WAY',
  brief: briefJson(senseOfForceBrief, 'senseOfForceBrief'),
  rounds: [
    for (final (n, r) in workRounds.indexed)
      () {
        const titles = ['Stretched', 'Squashed', 'Neither'];
        const notes = [
          'tension, a positive answer',
          'compression, a negative answer',
          'a zero-force member',
        ];
        return (
          options: titles,
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('WHICH WAY IS IT BEING WORKED', r.subject, r.setting),
            gap(10),
            framed(
              draw(
                record(
                  TrussPainter(
                    truss: r.truss,
                    mode: TrussMode.oneMember,
                    spotlight: r.member,
                  ).paint,
                  220,
                  what: 'stretched-or-squashed round $n',
                ),
              ),
              220,
            ),
            gap(6),
            {
              'mono': 'member ${r.truss.memberName(r.member)}',
              'size': 11.5,
              'color': 'ember',
            },
            gap(12),
            ...stack([
              for (final o in Working.values)
                glyphButton(
                  o.index,
                  h: 62,
                  gw: 46,
                  gh: 30,
                  glyph: WorkingGlyph(o).paint,
                  title: titles[o.index],
                  note: notes[o.index],
                  what: 'stretched-or-squashed glyph ${o.name}',
                ),
            ]),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whereDoYouCut() => pickScreen(
  id: 'where-do-you-cut',
  chapter: 'statics',
  title: 'Where Do You Cut',
  closing:
      'A section has to cross the member you were asked for, and it has '
      'to cross no more than three members altogether, because three '
      'equations is all a flat body gives you. Count the members the '
      'line crosses before you write anything down. If it is four, move '
      'the line.',
  right: 'THAT IS THE CUT',
  wrong: 'NOT THAT LINE',
  brief: briefJson(sectionBrief, 'sectionBrief'),
  rounds: [
    for (final (n, r) in cutRounds.indexed)
      () {
        // On the label at the top of each cut, as the game puts them.
        final areas = zones(
          r.cuts.length,
          (size, i) => square(
            TrussPainter.labelSpot(r.truss, r.cuts[i], size, r.cuts),
            46,
            down: 6,
          ),
        );
        return (
          options: [for (final c in r.cuts) c.label],
          notes: null,
          tex: null,
          answer: r.answer,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP THE CUT YOU WOULD TAKE', r.subject, r.setting),
            gap(6),
            {
              'mono': 'wanted: member ${r.truss.memberName(r.member)}',
              'size': 11.5,
              'color': 'ember',
            },
            gap(10),
            framed(
              tapDrawing(
                h: 260,
                hits: areas.hits,
                targets: areas.targets,
                draw: (pick, answered) => TrussPainter(
                  truss: r.truss,
                  mode: TrussMode.cuts,
                  spotlight: r.member,
                  cuts: r.cuts,
                  selected: pick,
                  truth: r.answer,
                  locked: answered,
                ).paint,
                what: 'where-do-you-cut round $n',
              ),
              260,
            ),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> isItAboutToMove() => pickScreen(
  id: 'is-it-about-to-move',
  chapter: 'statics',
  title: 'Is It About to Move',
  closing:
      'Friction is a ceiling, not a value. It sits at whatever holds the '
      'thing still and reaches its maximum only at the instant motion is '
      'impending. Before writing the formula down, find the words in the '
      'problem that say the thing is about to move. If they are not '
      'there, the maximum is not the answer.',
  right: 'THAT IS WHERE IT SITS',
  wrong: 'NOT THERE',
  brief: briefJson(ceilingBrief, 'ceilingBrief'),
  rounds: [
    for (final (n, r) in vergeRounds.indexed)
      () {
        const titles = [
          'Just enough to hold it',
          'The most this surface can give',
          'Nothing at all',
        ];
        const notes = [
          'below the ceiling, with room to spare',
          'at the ceiling, on the verge of moving',
          'nothing is trying to slide it',
        ];
        return (
          options: titles,
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('HOW HARD IS FRICTION WORKING', r.subject, r.setting),
            gap(10),
            // Kept closer than plain: the block on its slope lands its
            // edges a sample off otherwise (see [closer]).
            closer(
              1e-7,
              () => still(
                (answered) => BlockPainter(
                  rig: r.rig,
                  showPush: r.push > 0,
                  pushLabel: r.pushLabel,
                  grip: answered ? r.answer : null,
                ).paint,
                210,
                'is-it-about-to-move round $n',
              ),
            ),
            gap(12),
            ...stack([
              for (final o in Grip.values)
                glyphButton(
                  o.index,
                  h: 64,
                  grow: true,
                  gw: 52,
                  gh: 36,
                  glyph: GripGlyph(o).paint,
                  title: titles[o.index],
                  note: notes[o.index],
                  what: 'is-it-about-to-move glyph ${o.name}',
                ),
            ]),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> whichSideIsTight() => pickScreen(
  id: 'which-side-is-tight',
  chapter: 'statics',
  title: 'Which Side Is Tight',
  closing:
      'The tight side is the end the belt is being dragged toward. Find '
      'that before anything else, because the formula puts the tight '
      'side on the left and the slack side on the right, and swapping '
      'them turns a holding force into a fraction of one. Then, and only '
      'then, put the lap angle into radians.',
  right: 'THAT IS THE TIGHT SIDE',
  wrong: 'THE OTHER END',
  brief: briefJson(beltBrief, 'beltBrief'),
  rounds: [
    for (final (n, r) in lapRounds.indexed)
      () {
        // The start end, then the finish end, as the game stacks them.
        final areas = zones(
          2,
          (size, i) => square(DrumPainter.endPoint(r.lap, size, i == 1), 52),
        );
        return (
          options: const ['the start end', 'the finish end'],
          notes: null,
          tex: null,
          answer: r.answer ? 1 : 0,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('TAP THE END CARRYING MORE', r.subject, r.setting),
            gap(10),
            framed(
              // Kept closer than plain: the belt's arc at a 320 phone
              // lands its edges a sample off otherwise (see [closer]). In
              // layers, so the belt's two hundred points are kept once
              // rather than once per pick.
              closer(
                1e-7,
                () => layeredTap(
                  h: 270,
                  parts: 2,
                  under: DrumPainter(lap: r.lap).paintDrum,
                  part: (m, picked, answered) =>
                      (canvas, size) => DrumPainter(
                        lap: r.lap,
                        picked: picked ? m == 1 : null,
                        locked: answered,
                      ).paintEnd(canvas, size, m == 1),
                  over: DrumPainter(lap: r.lap).paintCreep,
                  zones: areas,
                  what: 'which-side-is-tight round $n',
                ),
              ),
              270,
            ),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> harderOrEasier() => pickScreen(
  id: 'harder-or-easier',
  chapter: 'statics',
  title: 'Harder or Easier',
  closing:
      'Anything that presses the block harder into the surface raises '
      'the friction it has to beat, and a slanted push does that to '
      'itself. Ask two questions of every force: how much of it slides '
      'the thing, and how much of it holds the thing down. How much of '
      'the block is touching is never one of them.',
  right: 'THAT IS THE WAY IT MOVES',
  wrong: 'THE OTHER WAY',
  brief: briefJson(normalForceBrief, 'normalForceBrief'),
  rounds: [
    for (final (n, r) in changeRounds.indexed)
      () {
        const titles = ['Harder', 'No change', 'Easier'];
        Node panel(Rig rig, String caption) => col([
          clip(
            box(
              w: 'max',
              h: 180,
              child: grid(
                draw(
                  record(
                    BlockPainter(
                      rig: rig,
                      showPush: true,
                      frameDeg: r.frameDeg,
                    ).paint,
                    180,
                    range: pairRange,
                    what: 'harder-or-easier round $n $caption',
                  ),
                ),
              ),
            ),
            14,
          ),
          gapH(6),
          t(caption, font: 'mono', size: 10.5, color: 'ink3'),
        ]);
        return (
          options: titles,
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            overline('WHAT HAPPENS TO THE PUSH NEEDED'),
            gap(6),
            subject(r.subject),
            gap(10),
            {'text': r.change, 'size': 15},
            gap(10),
            row([
              flex(panel(r.before, 'as it was')),
              gapW(8),
              flex(panel(r.after, 'after the change')),
            ], cross: 'start'),
            gap(14),
            answerRow([
              for (final o in Shift.values)
                () {
                  Object glyph(String state) => record(
                    ShiftGlyph(o, inkOf(state)).paint,
                    32,
                    range: (30, 31),
                    what: 'harder-or-easier glyph ${o.name} $state',
                  );
                  return toned(
                    o.index,
                    w: null,
                    h: 82,
                    child: col([
                      box(
                        w: 30,
                        h: 32,
                        child: draw(
                          tone(
                            glyph('idle'),
                            glyph('picked'),
                            glyph('right'),
                            glyph('wrong'),
                          ),
                        ),
                      ),
                      gapH(6),
                      t(titles[o.index], size: 13.5, bold: true),
                    ], main: 'center'),
                  );
                }(),
            ]),
            ...feedback(),
          ],
        );
      }(),
  ],
);

Map<String, Object?> willItHoldItself() => pickScreen(
  id: 'will-it-hold-itself',
  chapter: 'statics',
  title: 'Will It Hold Itself',
  closing:
      'Raising a load is always work and the friction angle is added on. '
      'Lowering is the interesting one: if the thread is shallower than '
      'the friction angle the screw is self-locking and you have to '
      'drive it down, and if it is steeper the load runs away and you '
      'have to hold it. Compare the two angles before anything else.',
  right: 'THAT IS THE JOB',
  wrong: 'SOMETHING ELSE',
  brief: briefJson(screwBrief, 'screwBrief'),
  rounds: [
    for (final (n, r) in screwRounds.indexed)
      () {
        const titles = ['Drive it up', 'Drive it down', 'Hold it back'];
        const notes = [
          'raising is always work',
          'self-locking, so it will not come down on its own',
          'the load is driving the screw down by itself',
        ];
        return (
          options: titles,
          notes: null,
          tex: null,
          answer: r.answer.index,
          why: r.why,
          source: r.source,
          screen: <Map<String, Object?>>[
            ...top('WHAT DOES THE HANDLE HAVE TO DO', r.subject, r.setting),
            gap(10),
            still(
              (answered) =>
                  ScrewPainter(screw: r.screw, showWinner: answered).paint,
              240,
              'will-it-hold-itself round $n',
            ),
            gap(12),
            ...stack([
              for (final o in Effort.values)
                toned(
                  o.index,
                  h: 58,
                  align: 'left',
                  pad: const [14, 0, 14, 0],
                  child: titled(titles[o.index], notes[o.index]),
                ),
            ]),
            ...feedback(),
          ],
        );
      }(),
  ],
);

final adapters = <String, Map<String, Object?> Function()>{
  'which-arrow-is-that': whichArrowIsThat,
  'which-distance-counts': whichDistanceCounts,
  'which-ones-turn-it': whichOnesTurnIt,
  'what-the-support-gives': whatTheSupportGives,
  'where-it-all-acts': whereItAllActs,
  'can-statics-solve-it': canStaticsSolveIt,
  'which-carry-nothing': whichCarryNothing,
  'stretched-or-squashed': stretchedOrSquashed,
  'where-do-you-cut': whereDoYouCut,
  'is-it-about-to-move': isItAboutToMove,
  'which-side-is-tight': whichSideIsTight,
  'harder-or-easier': harderOrEasier,
  'will-it-hold-itself': willItHoldItself,
};
