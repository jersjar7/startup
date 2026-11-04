# The road between lessons

The black lines between lesson nodes become a road. The road behind the
student is charcoal with a cream centre line. The road ahead is pale. Finishing
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
| tablet-screens T01 | Tablet landscape, mid-chapter, day |

## The look

The road is a calm, flat road seen from above. It is not a racing track: there
are no kerbs, no arrows, no perspective and no speed lines.

**Walked.** Each walked segment has four layers, bottom to top:

1. **Shadow.** pipOff, 3 down, blurred 2.5 (3 on tablet). Only walked road
   casts a shadow, so it sits in the ground and the pale road does not.
2. **Shoulders.** tile2, 2 wide on each side. This is a slightly lighter edge
   that you notice only up close.
3. **Surface.** charcoal. A finished node is charcoal too, so the walked road
   and the finished lessons read as one thing.
4. **Centre line.** cream, 2 wide (2.5 on tablet), 7 on and 9 off (9 and 10
   on tablet), with round ends.

**Not walked.** A flat creamDark band with a plinth edge, and no line or
shadow. These are the untouched node's own materials (a cream face on a
plinth), so the road ahead looks like part of the nodes it leads to.

**Width.** The total width is 20 on the phone, where nodes are 84, and 24 on
the tablet, where nodes are 100. That is about a quarter of a node: wide enough
to read as a road, never as heavy as a node.

**Night (Warm night, ADR 0025).** At night the charcoal role turns light. A
light road would be the loudest thing on the screen, so the road does not use
the charcoal role:

| Role | Day | Night |
|---|---|---|
| Walked surface | charcoal #2C2C2C | lineOnDark #4A463F |
| Shoulders | tile2 #47453F | plinth #5A544C |
| Centre line | cream #FFF9F0 | night ink #F2ECE2 |
| Not walked | creamDark #F5EDE0, plinth edge | cream #272522, sheet #2E2B27 edge |
| Shadow | pipOff | black at 50% |
| Pulse | spring | spring |

At night the walked road is lighter than the ground, and the road ahead is
barely lighter than the ground. This keeps the same order as by day: the walked
road is the defined one.

**Shape.** Use the app's own curve rule, unchanged, from `RoadPainter._road`
in `road_segment.dart`. The road leaves the finished node and leans 80% of the
way toward the next node's column at 52% of the drop. It is trimmed by arc
length where it enters each node, tucked 3 under the face. The mockups draw
exactly this curve.

## Labels: two collisions fixed

On the tablet, "0 of 3 done" under "Law of Sines & Law of Cosines" ran into
its node, and the current-node ring nearly touched "Straight Lines &
Quadratics". The label gap was 12 from the face (`ChapterPath._labelGap`),
which is less than the ring's own 10 (a 6 gap and a 4 stroke).

**Rule:** a label starts **28** from the node face on both sides. That clears
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
the `celebrate` pop. The road then starts from that node's `onSettled`. Times
below are counted from there.

| # | What | When | Curve |
|---|---|---|---|
| 1 | The next node rises from 95% to 100% with a 4 pt lift | 0 to 300 ms | ease out with a slight overshoot |
| 2 | The road fills from pale to charcoal, from the finished node along the curve | 150 to 1200 ms (1050) | ease in-out |
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

- **At rest** it sits on the road 72% of the way into the lesson the student
  goes to next. On the first node, where no road arrives, it peeks over the
  top of the node.
- **During the moment** it follows just behind the pulse and parks at 72% of
  the new segment.

If the owner drops it, nothing else changes, because the pulse already carries
the motion.

## Reduce Motion

When the system asks for less motion (`MediaQuery.disableAnimations`):

- The whole segment, charcoal and centre line together, cross-fades in over
  **180 ms**.
- Nothing runs along the curve. There is no pulse, no lift and no bounce.
- Every node sits at 100%. The 95% rest size is turned off.
- The marker fades out where it was and fades in at its new place, over the
  same 180 ms.

The node's own finishing moment follows its existing reduced-motion rule.

## How to build it: one approach

**The road is drawn in Dart, by extending the `RoadSegment` and `RoadPainter`
that already exist. Rive draws only the nodes.**

- **The road.** `RoadPainter` already takes two node centres, builds the
  curve, trims it by arc length, and owns a `travelled` value per segment. The
  new look is four `drawPath` calls in place of one: shadow, shoulder, surface
  and centre line. The walked part is a `PathMetric.extractPath(0, length *
  fill)`. The centre line uses the dash loop the painter already has, cut at
  `line`. The pulse is one blurred spring oval at `getTangentForOffset(length
  * pulse)`. Colours come from `AppColors` (ThemedColor), so night needs no
  extra work.
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
and is tested by the goldens that already exist.
