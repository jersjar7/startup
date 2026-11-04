# The lesson node, drawn by Rive

The nodes on a chapter path are drawn by a Rive artboard. The app still owns
every decision about a node; Rive only owns how it looks and moves. This
document is the contract between the two, and the reasoning behind the split.

## Where things live

| What | Where |
|---|---|
| The artboard, as text | `mobile/rive/lesson_node/scene.rml` |
| The built file the app bundles | `mobile/assets/rive/lesson_node.riv` |
| The loader and the Rive-backed widget | `mobile/lib/features/games/lesson_node_rive.dart` |
| The state model, the painter, the animation timing | `mobile/lib/features/games/lesson_node.dart` |
| The drift test | `mobile/test/lesson_node_rive_test.dart` |

The `.rml` is the source. The `.riv` is a build product that is committed
anyway, so a checkout runs without the Rive CLI installed. Rebuild it after
any change to the markup:

```
rive mobile/rive/lesson_node --once
```

The CLI installs with `curl -fsSL https://releases.rive.app/cli/install.sh | sh`
and lives in `~/.rive/bin`. No account is needed for `--once`.

## The split, and why

**Dart decides. Rive draws.** The four states (`notBuilt`, `notStarted`,
`inProgress`, `cleared`), the progress fraction, the rule that a just-finished
lesson keeps its unfinished face until the wedge has closed, the rule that the
wedge only animates once the map is back on screen, and the `onSettled`
callback the map uses to remember what it showed: all of that stays in
`lesson_node.dart`, unchanged, and unit tested without a native runtime.

The Rive widget receives the result of those decisions every frame and pushes
it into the artboard's view model. It decides exactly one thing itself: the
finished pop fires when the state it is told to show turns from in-progress to
cleared while the widget is on screen. That is the moment the wedge closes, and
it never fires on a first build, so a map full of finished lessons does not
pop on arrival.

**The brand colors stay in Dart.** The artboard has no color of its own that
matters; every paint is bound to a view model color property, and
`NodeSkin.of(state)` in Dart supplies them, so cream, charcoal and ember are
defined once, in `app_colors.dart`. The consequence is that when a node
changes state the geometry cross-fades inside Rive (220 ms) and the colors
cross-fade in Dart (also 220 ms, `RiveLessonNode._tint`). Keep those two
numbers the same.

**The painter is the fallback, and the test double.** If the `.riv` fails to
load, or has not loaded yet, the node paints the same platform itself
(`PlatformPainter` in `lesson_node.dart`), pose for pose, with the same rise
and bounce; only the breath and the finishing pop are Rive's alone, so a
test settles. Widget tests and goldens never load the file, so they exercise
the painter and every piece of app logic, and none of them need a native
library. The visual result of the Rive path is checked by eye:
`integration_test/node_art_test.dart` photographs the four states on a
simulator into `/tmp/node_art.png`
(`flutter test integration_test/node_art_test.dart -d <simulator id>`).

## The contract: view model `LessonNode`

The artboard is named `LessonNode`, its state machine `Node`. The app sets
these properties by name and nothing else in the file is reachable.

| Property | Type | Set to |
|---|---|---|
| `state` | enum `NodeState` | `notBuilt` / `notStarted` / `inProgress` / `cleared`, the state to wear now |
| `progress` | number 0..1 | how full the wedge is this frame |
| `pressed` | boolean | a finger is on the node |
| `celebrate` | trigger | fire once when a lesson has just been finished |
| `face` | color | the face |
| `plinth` | color | the slab under the face |
| `rim` | color | the track the progress ring runs on, shown only while underway |
| `wedge` | color | the progress arc on the track (the name is historical: it was a pie until 2026-09-19) |
| `ink` | color | the glyph on the face (check, or ellipsis) |
| `halo` | color | the ring that leaves the face at the finished moment |
| `current` | boolean | this is the lesson the student is in the middle of |
| `ahead` | boolean | the walked road has not reached this platform: it rests at 95%; turning false plays the rise |
| `arrive` | trigger | one arrival bounce, to 105% and back |
| `depth` | number | the plinth's height in artboard units (points x 100 / face width), 9 to 26 |

`lesson_node_rive_test.dart` reads `scene.rml` and fails if this list, the
enum values, the artboard name, the state machine name or the artboard size
drift from what `LessonNodeArt` in Dart expects. Renaming a property is a
breaking change on both sides; do it in both places and rebuild the `.riv`.

## What the artboard does with it

Four state machine layers run at once, so press, state, the breath and the
finished moment never have to know about each other:

- **State**: one hold pose per `NodeState`, with a 220 ms eased transition
  between every pair. The pose keys the face's width and corner radius (a
  100 circle, or a 72 rounded square for `notBuilt`), the rim's opacity, the
  check's opacity, the ellipsis's opacity, and the wedge group's opacity.
  Circle to square is a morph, not a swap.
- **Press**: `pressed` moves everything but the plinth down 9 units in 90 ms,
  onto the plinth.
- **Breathe**: `current` fades in (300 ms) a slow ping-pong breath, 1.0 to
  1.035 over 1.3 s each way, on everything but the plinth. Nothing on the map
  locks, so this is the one cue about where to go. `GameProgress.
  currentLessonIn` names the lesson: the one a round was last cleared in
  while it is still unfinished, else the first started-but-unfinished lesson
  on the path, else none. Never an untouched lesson, for the same reason the
  old "start here" pill was dropped.
- **Clear**: `celebrate` plays a 40-frame pop (the face lifts to 1.09, settles
  to 0.985, returns) while a stroke-only ring scales out to 1.42 and fades.
  It returns to idle on its own.

Two things are bound directly rather than keyed. The arc's trim end is
bound to `progress` through a clamp so the arc is never a sliver below 54
degrees; it does close at 1. (The painter also capped it at 330 degrees so a
nearly-done node could not pass for a finished one. That mattered when
finished looked like a full wedge; now finished is a charcoal face with a
check, so the cap only cost the finishing moment.) The arc's own opacity is
bound to `progress` through a 0..0.02 ramp, so a fraction of zero hides it
entirely (the painter's `fraction > 0` rule).

**The platform (2026-11-03, ROAD.md).** The node is an isometric platform:
the face is the node circle squashed to half height (100 by 50 units), on a
plinth `depth` tall whose foot is the face's ellipse moved straight down.
Every platform's side is the plinth tan (`RoadColors.plinth`), the same as
the road's walls; only the not-built square keeps a tone of its own face.
The face, the ring, the check, the dots and the halo all sit in a node
squashed to half height, so they are foreshortened with the face and their
strokes thin at the top and bottom, as in the approved mockups. The faces
are flat, with no gradients.

Progress is a spring track 11 units thick (0.22 of the face radius, as in
road.mjs) with the charcoal arc over it, butt ended, trimmed from the top.

A press sinks the face 8 units. The side is two shapes so that works: the
top 8 of the side goes down with the face, the rest (bound to `depth`
minus 8) stays, so no corner of the side ever shows beside the face.

**Ahead and arrive.** Two more layers: `Ahead` (Up, Ahead, Rise) and
`Arrive` (Rest, Bounce). A platform set `ahead` before its first frame is
at 95% at once and never plays the rise; turning `ahead` false plays Rise,
18 frames (300 ms) sampled frame by frame from `AppRoad.riseScale` and
`AppRoad.riseLift` in road.dart, so Rive and the painter move identically.
`arrive` plays Bounce, 18 frames sampled from `AppRoad.arriveBounce`. The
rise, the bounce and the breath all scale about the middle of the side.
The lift is keyed in units (4 points at an 84 point face), so on a 92 point
tablet face it is 4.4 points.

Geometry: the artboard is 124 by 100 with the face centre at (62, 39).
`RiveLessonNode` places it so that point lands on the widget's face centre
(`PlatformBox.face`) and lets it hang over the box.

The scene is generated by `mobile/rive/build_lesson_node.mjs` (the numbers
come from road.mjs and road.dart): change it and run
`node rive/build_lesson_node.mjs && rive rive/lesson_node --once` from
`mobile/` rather than hand-editing a pose.

## Checking the artwork without the app

```
cd mobile/rive/lesson_node
rive . --verify                                   # compiles?
rive inspect . --json | jq '.problems'            # anything unresolved?
rive . --screenshot=build/a.png --data=state=inProgress --data=progress=0.5 --advance=20
rive . --screenshot=build/b.png --data=state=cleared --data=celebrate=1 --advance=20 --advance=10
```

`--advance=20` is there because the machine starts in `notStarted` and takes
220 ms to arrive at whatever `--data` asked for. The headless render uses the
authored default colors (a white face), not the app's; the app overwrites all
six the moment the widget mounts.

## Haptics

Two, both in `LessonNodeWidget` so they happen with or without Rive: a light
impact on touch-down, and a medium impact at the turn-over, after the closed
circle's hold and before the face changes. Nothing on the fill itself.

## Runtime notes

- `rive` 0.14.11 on `rive_native` 0.1.11. The file is decoded with
  `Factory.flutter`, not `Factory.rive`: a chapter map draws a couple of dozen
  nodes at once and the Rive renderer would give each its own texture. Flat
  vector shapes are cheap on Flutter's canvas.
- The file is loaded once (`LessonNodeArt.warmUp()`, started from `main` and
  not awaited) and shared; every node makes its own artboard instance and
  controller from it and disposes them with the widget.
- `RiveWidget` is given `RiveHitTestBehavior.none`. Taps belong to the
  `GestureDetector` in `LessonNodeWidget`, which is also what drives
  `pressed`.
- The artboard uses no pointer listeners, fonts, images or scripts, so the
  `.riv` is about 3.5 KB and needs no `--publish`.
