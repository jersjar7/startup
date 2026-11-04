# The road between lessons

The black lines between lesson nodes become a road. The path is drawn in an
isometric-style view (owner's choice, 2026-11-03): every node is a raised
platform and the road is a lower slab that runs between them. The road
behind the student is charcoal with a cream centre line. The road ahead is
pale. Finishing a lesson opens the next stretch, one segment at a time. This
applies to the phone and the tablet, by day and by night.

Mockups: `road/png/` (built by `road/build-road.mjs`, shot by
`road/render-road.mjs`), and every tablet path in `tablet-screens/png/`
(T01, T01n, T01p, T02, T02p, T03, T03p). Both builders draw the path with
the same `isoPath` in `road/road.mjs`.

| File | What it shows |
|---|---|
| R01-phone-new-day | A new student: the whole road pale, the marker on the first platform |
| R02-phone-mid-day | Mid-chapter: two stretches walked, the marker on the road to the lesson in flight |
| R03-phone-new-night, R04-phone-mid-night | The same two at night |
| R05-storyboard | The finishing moment in six frames, with a timeline |
| R05b-reduced-motion | What Reduce Motion shows instead |
| R06-segment-closeup | One segment at 4x, the joint close up, and the pale and night versions |
| png/checks/ | 3x crops of every joint, segment and marker, day and night (see "Checks") |

The R07 option sheet was removed once the owner chose it; every screen above
is now isometric.

## The view

- **Tilt.** Ground depth is squashed to half (K = 0.5), about a 30 degree
  view from above. Left and right are not squashed. Widths and the curve are
  worked out on the ground, then projected; heights are added on screen.
- **Platforms.** A node is an elliptical platform: its face is the node
  circle squashed to half height (84 by 42 on the phone, 92 by 46 on the
  tablet), standing on a plinth **14 tall on the phone, 16 on the tablet**.
- **Road.** The slab is **8 tall on the phone, 9 on the tablet**, a little
  over half the platform, so the platforms clearly stand taller. Its width is
  20 on the ground on the phone and 24 on the tablet, about a quarter of a
  node.
- **Rows.** Rows are 120 apart on screen on the phone and 150 on the tablet,
  the same spacing as before the tilt. The weave stays 70 at 390 and 110 on
  a tablet. A section name adds 48 (phone) or 54 (tablet).
- **Labels stay flat.** Names, counts, section eyebrows, the marker and the
  current lesson's tile are not tilted. They are type on top of the scene.
- **Shape.** The app's own curve rule, unchanged (`RoadPainter._road`): the
  road leaves the finished node and leans 80% of the way toward the next
  node's column at 52% of the drop. It is computed on the ground between the
  two platform centres, trimmed by arc length (2 inside the face at the
  start, 4 at the end), and projected.

## One material

The platforms and the road are built from the same parts, so the road reads
as part of the same small model. Each slab is a top, a side wall under its
near edge, and a soft shadow on the ground.

**Walked road (owner corrections, 2026-11-03).** Built exactly like the
pale road, only darker on top: a top surface, a thin lighter rim on both of
its edges, a tan side wall under the near edge, and the shadow.

1. **Shadow.** pipOff on the ground, 4 below the road (5 on the tablet),
   blurred 3.
2. **Side wall.** **Plinth tan**, the same colour as the platforms' sides.
   It is the road's full band moved down by the slab height, so it shows
   only under the edge facing the viewer, and it is shorter than a platform's
   side.
3. **Rim.** tile2, **2 wide on both edges** of the top, the same width as
   the pale road's rim. It is a lit edge on the charcoal, a step lighter, and
   at 2 of 20 it never reads as a second surface.
4. **Top.** Charcoal, like a finished platform's face, between the rims.
5. **Centre line.** Cream, 2 wide (2.5 on tablet), 7 on and 9 off (9 and 10
   on tablet), round ends.

**Road ahead.** The same slab in an untouched platform's materials: a
creamDark top, a 2 cream rim, a plinth tan wall and half the shadow, with no
centre line.

| Role | Day | Night |
|---|---|---|
| Walked top | charcoal #2C2C2C | tile #34312C |
| Walked rim | tile2 #47453F | lineOnDark #4A463F |
| Walked wall | plinth #CDBFA8 | plinth #5A544C |
| Centre line | cream #FFF9F0 | night ink #F2ECE2 |
| Road ahead, top | creamDark #F5EDE0 | cream #272522 |
| Road ahead, rim | cream #FFF9F0 | creamDark #3A3732 |
| Road ahead, wall | plinth #CDBFA8 | plinth #5A544C |
| Shadow | pipOff | black at 50% |
| Pulse | spring | spring |

At night the charcoal role turns light, and a light road would be the loudest
thing on the screen, so the walked top uses the night tile: lighter than the
ground and than the road ahead. Its rim is the night lineOnDark, a step
lighter again, the same relation as tile2 on charcoal by day. Its wall is
the night plinth, the same as under every platform, so the three steps (top,
rim, wall) read the same way as by day.

## Where the road meets a platform

The road arrives at a platform's side, at road height, like a road meeting a
building. It never passes under a node.

- **Order.** Platform 1, segment 1 to 2, platform 2, segment 2 to 3, and so
  on down the path. In Flutter that is the `Stack` order, with each
  `RoadSegment` between the two `LessonNodeWidget`s it joins.
- **Leaving (near side).** The segment leaves the upper platform from its
  side facing the viewer, drawn in front of the plinth. Each layer is cut by
  the platform's outline **at its own height**: the top at road height, the
  middle of the wall at half the road height, the foot of the wall and the
  shadow on the ground. That is what makes the road butt cleanly against a
  curved plinth. The plinth shows above the road, which is the platform
  standing taller.
- **The joint.** A lip of the platform's outline, 1.2 wide, runs along the
  cut on the road's top: plinth tan on walked road, the cream rim on road
  ahead. It reads as the seam where two built pieces meet.
- **Arriving (far side).** The segment ends 4 inside the lower platform's
  footprint. The platform is drawn after it and hides the end, which is
  right for a road arriving behind a platform.
- **Shadows.** The road's shadow is cut on the ground too, so it meets the
  platform's base and the two read as one shadow.

R06 shows the joint at 4x and again close up.

## Labels

A label starts 28 from the platform (phone and tablet) and stays flat.
`placeLabel` then moves it up or down by the smallest step that clears the
road, the platform and the marker. It checks a set of points: the road's top
edges and foot along each curve, the platform's outline and the marker's
circle. A narrow window still shrinks the label, never the gap.

## The marker stands on the centre line (owner, 2026-11-03)

The marker is the brand's raccoon peek on a small charcoal coin, 32 on the
phone and 36 on the tablet, with a 3 fog ring. Its size and look are
unchanged. No stem.

- **The anchor is the coin's bottom centre**, the lowest point of its outer
  ring, not its centre. That point sits exactly on the road's dashed centre
  curve. Dart takes the point at the marker's fraction along the curve (by
  arc length) on the ground, projects it and raises it by the slab height;
  that is the anchor. The coin's centre is the anchor moved straight up by
  the radius plus the ring (19 on the phone, 21 on the tablet). So the coin
  stands on the road the way a marker stands in an isometric scene, instead
  of lying over it.
- **On a platform** (the first lesson, before any road) the anchor is the
  centre of the platform's top face.
- **Contact shadow.** A soft ellipse lies flat on the road's top, in the
  same projection, centred on the anchor and drawn under the coin: a ground
  circle the width of the road's top plus 2 (18 on the phone, 22 on the
  tablet) squashed to half height, black at 38%, blurred 1.2. It is subtle
  on the walked charcoal and clearer on pale road and platform faces. It
  moves with the coin.
- **At rest** the anchor sits 72% of the way into the lesson the student
  goes to next on the phone, and 55% on the tablet.
- **During the moment** the anchor follows just behind the pulse (at 0.8 of
  the pulse, minus 0.08) and parks at 72% of the new segment. Coin and
  shadow move together, and every frame uses the same rule.
- **Labels** clear the coin where it now stands, above the road.

In Flutter: the marker is a widget positioned by its bottom centre
(`Positioned` at the anchor with a `FractionalTranslation(-0.5, -1)` on the
coin and its ring), with the shadow painted by `RoadPainter` at the same
anchor so it sits on the road's layer.

If the owner drops the marker, nothing else changes, because the pulse
already carries the motion.

## Each segment owns its progress

Each segment is its own `RoadSegment` widget and owns these values:

| Value | Range | Meaning |
|---|---|---|
| `fill` | 0..1 | How far the charcoal has run from the finished platform |
| `line` | 0..1, never more than `fill` | How far the centre line has been revealed |
| `pulse` | null or 0..1 | Where the pulse is, null when there is none |

At rest a segment is either `fill = line = 1` (the lesson behind it is
finished) or `0`. Only finishing that lesson moves it. Reopening a map draws
every segment at rest, with no replay.

## The finishing moment

The road waits for the node's own finishing moment (ring fills 1100 ms, holds
320 ms, turns charcoal with the check, `celebrate` pop) and starts when that
finished lesson settles (`onSettled`). Times are counted from there.

| # | What | When | Curve |
|---|---|---|---|
| 1 | The next platform rises from 95% to 100% with a 4 pt lift | 0 to 300 ms | ease out with a slight overshoot |
| 2 | The road fills from pale to dark, top and wall together, from the finished platform along the curve | 150 to 1200 ms (1050) | ease in-out |
| 3 | The centre line reveals behind the fill | 400 to 1200 ms (800) | ease in-out |
| 4 | A small spring pulse runs the road to the next platform | 1200 to 1800 ms (600) | ease in-out |
| 5 | The next platform does one small bounce, to 105% and back | 1800 to 2100 ms (300) | ease out with an overshoot |

The whole moment takes 2.1 s and nothing blocks input. The next platform does
not start breathing when it ends; the breath stays reserved for a started
lesson. Platforms the walked road has not reached rest at 95%.

## Reduce Motion

When the system asks for less motion (`MediaQuery.disableAnimations`):

- The whole segment (top, wall and centre line) cross-fades in over
  **180 ms**.
- Nothing runs along the curve: no pulse, no lift, no bounce.
- Every platform sits at 100%.
- The marker fades out where it was and in at its new place, over the same
  180 ms, still on the centre line.

## How to build it

**The road is drawn in Dart by extending `RoadSegment` and `RoadPainter`.
Rive draws only the platforms.**

- **The road.** `RoadPainter` keeps working on the ground: the same two
  centres, the same curve, the same arc-length trim. Each layer is the
  trimmed path stroked at road width, drawn through one projection
  (`canvas.translate(0, -height); canvas.scale(1, 0.5)`), bottom to top:
  shadow (ground, blurred), wall (two bands, at the ground and at half
  height), top (rim band, then the surface), dashes, lip. The walked
  layers are drawn over the pale ones on `PathMetric.extractPath(0, length *
  fill)`, so the wall turns with the fill. The rim is the top band at full
  width in the rim colour, with the surface band 4 narrower over it, for
  walked and pale road alike. The pulse and the marker use
  `getTangentForOffset(length * f)`, projected and raised by the slab
  height. Colours come from `AppColors`, so night needs no extra work.
- **The joint cuts.** Each layer is clipped with the platform's ellipse at
  that layer's height: `canvas.clipPath` with
  `Path.combine(PathOperation.difference, bounds, ellipse)`. The lip is the
  same ellipse stroked, clipped to the road's top band.
- **The platforms.** The `lesson_node` artboard is redrawn as a platform:
  an elliptical face and a plinth side, the progress ring as an elliptical
  arc, the check foreshortened. Two new inputs join the existing layered
  pattern: `ahead` (holds 95%, moves to 100% with the lift) and `arrive` (the
  bounce). The painter fallback draws the same ellipses and sides.
- **Timing.** One controller per segment runs the 2.1 s with `Interval`s for
  fill, line and pulse. It starts on `onSettled` and fires `ahead=false` at 0
  and `arrive` at 1800 on the next platform.

**Why not draw the road in Rive.** Node positions come from Dart
(`PathMetrics`) and differ by device and width. A Rive road stretched to each
segment's box would distort the width and the dashes differently on every
segment; following the curve would need every segment's geometry bound in
from Dart, a second copy of the maths. The painter is the fallback and the
test double either way, so drawing the road there means one road.

## What the isometric view costs to build

Compared with the flat top-down road, which kept every node as it is:

- **Rive node art (most of the work).** Every pose on `lesson_node` (four
  states, the ring, the check, the press, the breath, the finishing pop,
  plus the new `ahead` and `arrive`) is redrawn as an elliptical platform
  with a side. The ring becomes an elliptical arc that still fills by
  fraction. The golden screenshots are retaken. About as much as building
  `lesson_node` the first time.
- **Painter fallback.** The same platforms drawn in Dart, so the painter and
  Rive keep matching. Small, because it shares the projection with the road.
- **Hit areas.** A node's tap target becomes its platform (the face ellipse
  plus its side), not a circle. On the phone that is 84 by 56, which passes
  the 48 minimum. Scroll-to-lesson and the current ring move to the face's
  centre.
- **Road painter.** One projection on the canvas, the per-height ellipse
  cuts and the lip. A small change to the slab painter that was already
  planned.
- **Layout.** `PathMetrics` adds the platform height to each row's room and
  places labels with `placeLabel`'s rule (obstacle points from the road and
  the platform). Labels, eyebrows and the marker stay flat widgets on top.
- **Badges, Profile and anything else that shows a node** are not part of
  this. Only the chapter path tilts.

Rough size: the road is a few days in the painter. The platform redraw in
Rive and the painter is most of the work, roughly one to two weeks with the
goldens.

## Checks before showing

`python3 road/checks.py` (from `mobile/design`, after rendering) crops every
joint (each segment leaving and arriving), the middle of every segment, and
every marker, in day and night, from R01 to R05 and T01/T01n, at 3x into
`road/png/checks/`. Small ember ticks on the crop edges mark the exact
point. The pages write their points on load (`checkHtml` in `road.mjs`), so
the crops follow the drawing.

Each marker crop is centred on the anchor. It shows the road's true centre
curve (from the page's own maths, not a fit) in thin ember, and an ember dot
on the coin's bottom point where the page actually drew it (read back from
the coin's box). A second crop, `-pin-hidden`, shows the same spot with the
coin hidden, so the contact shadow and the dashes under it show against the
curve. The script prints, for each marker, how far the drawn coin bottom and
the shadow's centre are from the anchor, the anchor's distance from the
curve, and where the drawn dashes sit relative to the curve there.

Measured on 2026-11-03, on R01 to R05 (all six storyboard frames), T01 and
T01n: coin bottom and shadow centre 0.00 px from the anchor, anchor 0.00 px
from the curve (or from the face centre on R01 and R03), drawn dashes within
0.25 px of the curve.
