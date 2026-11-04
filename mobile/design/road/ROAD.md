# The road between lessons

The black lines between lesson nodes become a road. The road behind the
student is a dark raised slab with a cream centre line. The road ahead is a pale slab. Finishing
a lesson opens the next stretch, one segment at a time. This applies to the
phone and the tablet, by day and by night.

Mockups: `road/png/` (built by `road/build-road.mjs`, shot by
`road/render-road.mjs`), and every tablet path in `tablet-screens/png/`
(T01, T01n, T01p, T02, T02p, T03, T03p). Both builders draw the road with
the same `road/road.mjs`.

| File | What it shows |
|---|---|
| R01-phone-new-day | A new student: the whole road pale, the marker at the first node |
| R02-phone-mid-day | Mid-chapter: two stretches walked, the marker at the lesson in flight |
| R03-phone-new-night, R04-phone-mid-night | The same two at night |
| R05-storyboard | The finishing moment in six frames, with a timeline |
| R05b-reduced-motion | What Reduce Motion shows instead |
| R06-segment-closeup | One segment at 4x: surface, shoulders, centre line, shadow |
| R07-isometric | The same mid-chapter path in a true isometric-style view, for the owner to choose |
| tablet-screens T01 | Tablet landscape, mid-chapter, day |

## The look

The road is a calm, raised slab seen from above, like the owner's reference:
a top surface with a thin lit rim, a side wall under its near edge, and a
soft shadow on the ground. It is not a racing track: there are no kerbs, no
arrows, no perspective and no speed lines.

**Height (owner, 2026-11-03).** The nodes stand a little taller than the
road. The node plinth stays as it is (10% of the face: 8.4 on an 84 phone
node, 10 on a 100 tablet node). The road's wall is **0.6 of the plinth**: 5
on the phone, 6 on the tablet. The mockups draw a 7 plinth and a 4 wall. The
wall shows only under the downward-facing edge of each curve, lit from above
like the node plinths.

**Walked.** Each walked segment has five layers, bottom to top:

1. **Shadow.** pipOff, 7 down, blurred 3, on the ground under the wall.
2. **Wall.** charcoal, the band moved down by the wall depth.
3. **Rim.** tile2, 2 wide on each side: the lit top edge.
4. **Surface.** tile, a dark charcoal grey. It is a step lighter than
   charcoal so the wall under it can be darker while using only tokens.
5. **Centre line.** cream, 2 wide (2.5 on tablet), 7 on and 9 off (9 and 10
   on tablet), with round ends.

**Not walked.** The same slab in the untouched node's materials: a creamDark
surface, a cream rim, a plinth wall and half the shadow, with no centre line.
The road ahead looks like part of the nodes it leads to.

**Width.** The total width is 20 on the phone, where nodes are 84, and 24 on
the tablet, where nodes are 100. That is about a quarter of a node: wide enough
to read as a road, never as heavy as a node.

**Night (Warm night, ADR 0025).** At night the charcoal role turns light. A
light road would be the loudest thing on the screen, so the road does not use
the charcoal role:

| Role | Day | Night |
|---|---|---|
| Walked surface | tile #3A3936 | lineOnDark #4A463F |
| Walked rim | tile2 #47453F | plinth #5A544C |
| Walked wall | charcoal #2C2C2C | tile #34312C |
| Centre line | cream #FFF9F0 | night ink #F2ECE2 |
| Not walked surface | creamDark #F5EDE0 | cream #272522 |
| Not walked rim | cream #FFF9F0 | creamDark #3A3732 |
| Not walked wall | plinth #CDBFA8 | plinth #5A544C |
| Shadow | pipOff | black at 50% |
| Pulse | spring | spring |

At night the walked road is lighter than the ground, and the road ahead is
barely lighter than the ground. This keeps the same order as by day: the walked
road is the defined one. Each wall is the same material as the plinth under a
node in the same state, or darker than its surface for walked road.

**Shape.** Use the app's own curve rule, unchanged, from `RoadPainter._road`
in `road_segment.dart`. The road leaves the finished node and leans 80% of the
way toward the next node's column at 52% of the drop. The mockups draw
exactly this curve, between centres moved down to road height, and end it at
each node's side as the next section describes.

## Where the road meets a node (owner, 2026-11-03)

The whole path reads as a small built roadmap: each node is a raised
platform, and the road arrives at the platform's side, at road height, like a
road meeting a building. It never passes under a node.

- **Road height.** The road's top sits lower than the node's top face by
  the plinth depth minus the wall depth (7 minus 4 in the mockups, so 3). In
  drawing terms, the road's curve runs between the node centres moved down
  by that difference.
- **The near side.** A segment leaves the upper node from that node's lower,
  viewer-facing side. There the road is drawn in front of the node and
  butts against its wall. The road's top is cut by the node's outline at
  road height, and its wall and shadow are cut by the outline on the ground,
  the wall depth lower. A slab of plinth shows between the node's face and
  the road, which is the node standing taller.
- **The joint.** A thin lit lip (the rim colour, 1.6 wide) runs along the cut
  where the road's surface meets the node's wall, so the joint looks built,
  not overlapped. The rim's own band shows along the end of the surface too.
- **The far side.** The segment ends under the lower node's upper side. The
  node is drawn after it and hides the very end, which is correct for a road
  arriving behind a platform.
- **Shadows.** The road's ground shadow is cut by the node's footprint, so
  it meets the node's base and the two read as one shadow.
- **Order.** Each node and each segment is its own layer: node 1, segment 1
  to 2, node 2, segment 2 to 3, and so on down the path. In Flutter that is
  the `Stack` order, with each `RoadSegment` placed between the two
  `LessonNodeWidget`s it joins.
- **Painter.** The cuts are `Path.combine(PathOperation.difference, ...)`
  with the node's circle (at road height for the top layers, at ground
  height for the wall and shadow), or a `canvas.clipPath` of the same shape.
  The lip is an arc of that circle, clipped to the road band.

R06 shows the joint at 4x and again close up.

## Labels: two collisions fixed

On the tablet, "0 of 3 done" under "Law of Sines & Law of Cosines" ran into
its node, and the current-node ring nearly touched "Straight Lines &
Quadratics". The label gap was 12 from the face (`ChapterPath._labelGap`),
which is less than the ring's own 10 (a 6 gap and a 4 stroke).

**Rule:** a label starts **28** from the node face on both sides. It is
centred on the face, unless the road leaving that node would run through it.
In that case its bottom sits 8 above the road's top edge at the label's near
end (the painter knows that point from the curve). That clears
the ring by 18 and the plinth by more. On the phone at 390 this still leaves
183 for a 156 label. On the tablet it leaves the full 220. The label keeps its
existing room clamp, so a narrow window shrinks the label and never the gap.

## Each segment owns its progress

There is never one animation for the whole road. Each segment is its own
`RoadSegment` widget, as it is today, and owns these values:

| Value | Range | Meaning |
|---|---|---|
| `fill` | 0..1 | How far the charcoal has run from the finished node |
| `line` | 0..1, never more than `fill` | How far the centre line has been revealed |
| `pulse` | null or 0..1 | Where the pulse is, null when there is none |

At rest, a segment is either `fill = line = 1` (the lesson behind it is
finished) or `0` (it is not). The only thing that moves a segment is the
lesson behind it being finished. Reopening a map draws every segment at rest,
with no replay.

## The finishing moment

The road waits for the node's own finishing moment, which already exists: the
ring fills (1100 ms), holds (320 ms), turns charcoal with the check, and plays
the `celebrate` pop. The road starts when that finished lesson settles (the
node's `onSettled` in code). Times below are counted from there.

| # | What | When | Curve |
|---|---|---|---|
| 1 | The next node rises from 95% to 100% with a 4 pt lift | 0 to 300 ms | ease out with a slight overshoot |
| 2 | The road fills from pale to dark, surface and wall together, from the finished node along the curve | 150 to 1200 ms (1050) | ease in-out |
| 3 | The centre line reveals behind the fill | 400 to 1200 ms (800) | ease in-out |
| 4 | A small spring pulse runs the road to the next node | 1200 to 1800 ms (600) | ease in-out |
| 5 | The next node does one small bounce, to 105% and back | 1800 to 2100 ms (300) | ease out with an overshoot |

The whole moment takes 2.1 s. Nothing blocks input during it, so a tap
anywhere works.

The next node does not start breathing when the moment ends. The breath
(`current`) stays reserved for a started lesson, as `lesson-node-rive.md`
says. A reached but untouched lesson only bounces once.

**Nodes ahead rest at 95%.** Any node the walked road has not reached sits at
95%, and grows to 100% when the road reaches it. That is 4 points on an 84
node: you feel it more than you see it. It also gives step 1 something to
grow from.

## The marker (optional, for the owner to keep or drop)

The marker is the brand's raccoon peek on a small charcoal coin, 32 on the
phone and 36 on the tablet, with a 3 fog ring that lifts it off the road. It
uses the brand asset as drawn and is not a new character.

- **At rest** it sits on the road into the lesson the student goes to next:
  72% of the way on the phone, 45% on the tablet, where the label tile of
  the lesson in flight sits closer to the road. On the first node, where no road arrives, it peeks over the
  top of the node.
- **During the moment** it follows just behind the pulse and parks at 72% of
  the new segment.

If the owner drops it, nothing else changes, because the pulse already carries
the motion.

## The other option: a true isometric view (R07)

R07 draws the same mid-chapter path tilted about 30 degrees. The ground is
squashed to half its depth, the nodes become elliptical platforms 14 tall,
the road slabs are 8 tall in the same projection, and the labels stay flat.
It is more of a place. It is also a bigger build:

- **Rive node art.** Every node pose (four states, the ring, the check, the
  press, the breath, the finishing pop, the new `ahead` and `arrive`) has to
  be redrawn as an ellipse with a visible side. The progress ring becomes an
  elliptical arc, and the check is drawn foreshortened. That is the whole
  `lesson_node` artboard again, plus its golden screenshots.
- **Hit areas.** A node's tappable area is its platform, an ellipse plus its
  side, not a circle. The 48 minimum touch size has to be checked against
  the squashed height (an 84 node is only 42 tall on screen plus its side).
  The scroll-to-lesson and the ring position also move to the projected
  centre.
- **Painter.** The road painter draws in ground space and projects. That is
  one transform on the canvas for the slab, plus the joint cut becoming an
  ellipse. The painter fallback for nodes must draw the same ellipses and
  sides, so the painter and Rive keep matching.
- **Layout.** Rows have to be twice as far apart on the ground to keep the
  same spacing on screen, and section eyebrows and labels need their own
  placement rules, because they stay flat while the path tilts.

Rough size: the road is a small change to what is proposed here. The nodes,
in Rive and in the painter, are most of the work, about as much as building
`lesson_node` the first time. The top-down view with built joints keeps all
of today's node work.

## Reduce Motion

When the system asks for less motion (`MediaQuery.disableAnimations`):

- The whole segment, dark surface, wall and centre line together,
  cross-fades in over **180 ms**.
- Nothing runs along the curve. There is no pulse, no lift and no bounce.
- Every node sits at 100%. The 95% rest size is turned off.
- The marker fades out where it was and fades in at its new place, over the
  same 180 ms.

The node's own finishing moment follows its existing reduced-motion rule.

## How to build it: one approach

**The road is drawn in Dart, by extending the `RoadSegment` and `RoadPainter`
that already exist. Rive draws only the nodes.**

- **The road.** `RoadPainter` already takes two node centres, builds the
  curve, trims it by arc length, and owns a `travelled` value per segment.
  The slab is the same trimmed path stroked several times, bottom to top:
  1. the ground shadow: the path shifted down by the wall depth plus 3, with
     a `MaskFilter.blur`;
  2. the wall: the same path at full road width, shifted straight down by
     the wall depth (`path.shift(Offset(0, depth))`), in the wall colour;
  3. the rim at full width;
  4. the surface, 4 narrower;
  5. the dashed centre line.

  Shifting the whole band down is what makes the wall show only under the
  downward-facing edge, with no per-curve maths. The surface covers the
  shifted band everywhere else, and because the wall is shallower than the
  road is wide, there is never a gap. The pale road is drawn this way in
  full. The walked layers are then drawn over it on `PathMetric.extractPath(0,
  length * fill)`, shifted copies included, so the wall darkens with the
  fill. The centre line uses the dash loop the painter already has, cut at
  `line`. The pulse is one blurred spring oval at `getTangentForOffset(length
  * pulse)`. Colours come from `AppColors` (ThemedColor), so night needs no
  extra work. The widget's `bounds` grows by the wall depth plus the shadow
  at the bottom so nothing is clipped.
- **The nodes.** These stay on the `lesson_node` artboard and need two
  additions in the existing layered pattern, the way `current` drives the
  breath:
  - a boolean `ahead`, which holds the 95% pose and moves to 100% with a 4
    lift over 300 ms;
  - a trigger `arrive`, which plays the 300 ms bounce.

  Both get their names in `LessonNodeArt.inputs` and the contract test. The
  painter fallback applies the same scale with a `Transform`.
- **The marker.** A small widget placed by Dart at the same tangent as the
  pulse. If it ever needs an idle motion, it can be its own tiny artboard.
- **Timing.** One controller per segment runs the 2.1 s, with `Interval`s for
  fill, line and pulse. It starts on the finished node's `onSettled` and fires
  `ahead=false` at 0 and `arrive` at 1800 on the next node.

**Why this approach.** Node positions are computed in Dart (`PathMetrics`)
and differ by device and by width: the weave is 70 at 390 and 150 on a
tablet, and rows are 124 or 150 apart, with section breaks between them.

- A Rive road artboard is a fixed drawing. Stretched to each segment's box, it
  distorts the road's width and the dash spacing differently on every
  segment.
- Making a Rive road follow the curve would need every segment's vertex
  positions bound in from Dart. That would mean a second implementation of
  the geometry Dart already owns, plus a texture per segment on a map with
  twenty of them.
- The painter is the fallback and the test double whatever happens. A Rive
  road would mean two roads to keep in sync, and goldens would still only see
  the Dart one.

Drawing the road in Dart means one road, which fits any spacing on any device
and is tested by the goldens that already exist. The raised slab does not
change this: it is the same path drawn with a downward shift, which a Rive
drawing stretched to a segment could not do correctly either.
