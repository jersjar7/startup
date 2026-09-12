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
load, or has not loaded yet, the node paints itself exactly as it did before
Rive existed. Widget tests and goldens never load the file, so they exercise
the painter and every piece of app logic, and none of them need a native
library. The visual result of the Rive path is checked by eye, in the
simulator or with the CLI's headless renderer (below).

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
| `rim` | color | the stroke around an unfinished circle |
| `wedge` | color | the progress wedge |
| `ink` | color | the glyph on the face (check, or ellipsis) |
| `halo` | color | the ring that leaves the face at the finished moment |

`lesson_node_rive_test.dart` reads `scene.rml` and fails if this list, the
enum values, the artboard name, the state machine name or the artboard size
drift from what `LessonNodeArt` in Dart expects. Renaming a property is a
breaking change on both sides; do it in both places and rebuild the `.riv`.

## What the artboard does with it

Three state machine layers run at once, so press, state and the finished
moment never have to know about each other:

- **State**: one hold pose per `NodeState`, with a 220 ms eased transition
  between every pair. The pose keys the face's width and corner radius (a
  100 circle, or a 72 rounded square for `notBuilt`), the rim's opacity, the
  check's opacity, the ellipsis's opacity, and the wedge group's opacity.
  Circle to square is a morph, not a swap.
- **Press**: `pressed` moves everything but the plinth down 6 units in 90 ms,
  the same travel the painter used.
- **Clear**: `celebrate` plays a 40-frame pop (the face lifts to 1.09, settles
  to 0.985, returns) while a stroke-only ring scales out to 1.42 and fades.
  It returns to idle on its own.

Two things are bound directly rather than keyed. The wedge's trim end is
bound to `progress` through a clamp so the wedge is never a sliver below 54
degrees and never closes past 330, exactly as the painter drew it. The wedge's
own opacity is bound to `progress` through a 0..0.02 ramp, so a fraction of
zero hides it entirely (the painter's `fraction > 0` rule).

Geometry is in artboard units where the face is 100 across. The plinth shows 7
below it and there is 12 of air on every side, so the pop and halo have room.
`RiveLessonNode` positions the artboard so the face lands exactly where the
painter's face was in the node's slot, and lets it hang over the edges. One
knowing difference from the painter: the plinth is 7% of the face rather than
a fixed 7 points, so at the map's 62 to 82 point nodes it shows 4.3 to 5.7
points. It reads the same.

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
