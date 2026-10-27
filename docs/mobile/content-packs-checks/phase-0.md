# Phase 0 results: three games played from a pack

Date: 2026-10-26. Branch `content-packs-phase0`.
Plan: [content-packs-migration.md](../content-packs-migration.md),
decision: [ADR 0030](../../adr/0030-content-packs-and-game-types.md).

## The answer

It works. Three FE Civil games, with their rounds, drawings and concept
sheets, were turned into pack data and played back by three game types in
the app. Every screen of every game matched the built-in version **to the
pixel**, in day and night, on a small, a typical and a large phone. The
answers recorded were identical too.

## What was built

All of it behind the scenes; no student sees any of it yet.

- **The recorder** (`mobile/lib/features/packs/drawing/recording_canvas.dart`).
  Runs a drawing routine and writes down every shape, color and label
  instead of drawing it. Anything it cannot write down exactly stops the
  build and names the call, so a figure can never ship with a part
  missing.
- **The figures' text painter** (`figure_text.dart`). Flutter's own text
  painter, plus the ability to tell the recorder what it wrote. On a real
  screen it behaves exactly like Flutter's. Phase 0 switched seven drawing
  files to it; the rest switch as their chapter moves.
- **The pack builder** (`mobile/test/packs/builder.dart`, `adapters.dart`,
  `build_pack_test.dart`). Records every drawing across every width a
  phone can give it (from the smallest phone to a large Android tablet)
  and in both themes, and keeps the rule each number follows as the width
  changes. Writes the pack to `mobile/build/packs/`.
- **The drawing player** (`drawing_painter.dart`). Draws a recorded figure
  at whatever width the phone has, in the current theme.
- **Three game types** (`mobile/lib/features/packs/games/`): pick one,
  tap the drawing, tap in order. Each was built from one existing game,
  screen for screen.
- **The comparison** (`mobile/test/packs/parity_test.dart`, `curves_test.dart`).
  Checks 1 to 4 of the plan.

## Checks run

| Check (from the plan) | Result |
|---|---|
| 1. Looks the same | 888 screens compared across 18 runs (3 games, day and night, phones 320, 390 and 430 wide). 0 pixels differ. |
| 2. Plays the same | Every round answered wrong with each wrong option in turn, then right; an empty spot tapped on the drawing; the concept sheet opened and scrolled; the done screen reached. Identical every time. |
| 3. Records the same | The answers (24, 24 and 18 per run) sent with the same game, chapter, source problem, round and verdict, in the same order. Rounds cleared match. |
| 4. Concept sheet reads the same | Included in check 1: sheet top and scrolled, pictures included. |
| 5. Game checks (audit) | Not run yet. The audit reads the built-in games; it is pointed at packs in phase 2. |
| Curves | 72 coupon drawings (6 rounds, before and after answering, day and night, 3 phone sizes): 0 pixels differ. |
| Rest of the app | All 3,397 tests pass with the phase 0 changes. |

## What was found

1. **Exact is achievable, but only by keeping full precision.** The first
   comparison was off by a few faint pixels. Three causes, all fixed:
   rounding numbers to four decimals moved rectangle corners; a stroke
   setting left at its default was being recorded as zero; and colors
   with a fractional transparency were being rounded to 256 levels. A
   fourth showed up on the In What Order sheet: one drawing asks for
   semi-bold text on a medium-weight font, and the player must load that
   same font, not the semi-bold one.
2. **Drawings follow the screen width simply, but not always in a
   straight line.** 63 of the 94 recorded drawings have at least one
   number that bends with width, almost always a label nudged back
   inside the frame on a narrow screen. The builder finds every bend to
   within a quarter of a pixel of width.
3. **Size.** The three games, with drawings and concept sheets, come to
   about 12.5 KB compressed. Extrapolated, all 375 games would be about 2
   MB to download. Today they are about 5.2 MB of the app's compiled code
   (measured from an Android release build: 50 MB download, of which the
   app's own code is 14 MB uncompressed, and 5.2 MB of that is the games).
   So each new exam built the old way would add about 5 MB to the app.
   Less than first estimated, but it grows with every exam, and every
   content fix still needs a store review.
4. **Ten game types, confirmed by reading all 375 games** (counts add up
   to 375):

   | Game type | How the student answers | Games |
   |---|---|---|
   | Pick one | One of several answers, then Lock it in | 293 |
   | Tap the drawing | A part or spot on the drawing | 50 |
   | Pick all that apply | Any number of items on or off | 11 |
   | Tap in order | Items in sequence, the order graded | 5 |
   | Mark each row | Its own yes or no for every row | 3 |
   | Two-part answer | One from list A and one from list B | 3 |
   | Fill the blanks | Chips from a bank into numbered slots | 3 |
   | Set a value | A stepper, toggles or a drag until the drawing matches | 3 |
   | Tap a term | One piece of an equation shown in the round | 3 |
   | Step by step | Each tap must be the next correct move | 1 |

   The real variety is inside "pick one": answers in a list (about 210),
   in a row of buttons (about 41), as small drawings (about 23), with an
   icon, with a "none of these" button, with a second drawing, a formula
   or a code panel. These become layout options of the one type, not new
   types. Each needs building and checking once.
5. **Curves needed their own fix.** A built path cannot say how it was
   built, so the first recorder traced curves as very fine straight
   segments. On the steel test coupon that left up to 1,200 pixels wrong in
   one drawing, some clearly, and recording took ten minutes for twelve
   drawings. Fixed with a figure path (`figure_path.dart`) that notes each
   move as the drawing makes it, at no cost on a real screen. Result: 0
   pixels differ, in four seconds. 16 of the 129 drawing files use curves
   and switch to it with their chapter. Tracing stays only as a fallback,
   counted in the build report so it is never silent.
6. **Concept sheet layouts.** 303 of the 365 concept pictures use the two
   layouts phase 0 handles (one drawing, or two side by side). The other
   62 stack drawings in a column or overlay them, and need two or three
   more layouts.
7. **Building is slow if done naively.** Recording every drawing across
   every width means about 150 recordings per drawing. Fine for three
   games (seconds), but the full bank needs the builder to record only
   once per drawing and run chapters in parallel.
8. **A bug in a live game, found by reading the games.** In "Which Curve
   Is Sharper" (horizontal curves, Transportation), 4 of the 6 rounds
   cannot be answered correctly: the only button is "about the same" and
   the curves themselves cannot be tapped. A student who meets one of
   those rounds can never clear it. Not part of the move; to be fixed on
   its own.

## Not done in phase 0, on purpose

- Nothing reaches students: the app still plays its built-in games.
- The pack is not on the server, not downloaded, not bundled.
- The game catalog (chapters and lessons) is still built in.

## Next

Phase 1: the pack format and the server, per the plan. Separately, the
owner decides how Which Curve Is Sharper should be fixed.
