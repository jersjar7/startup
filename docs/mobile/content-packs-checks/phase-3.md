# Phase 3 results: moving the chapters

Plan: [content-packs-migration.md](../content-packs-migration.md). How packs
work: [content-packs.md](../content-packs.md). One section per chapter, in
the plan's order. A chapter is moved when its games are in a published pack
and pass checks 1 to 5; it is switched on for students only after check 6
(the owner plays it on his phone).

## Construction (10 games), 2026-10-27

Moved, published in FE Civil pack version 2. Not switched on.

All ten use the standard pick-one screen, so their pack descriptions are
generated from the game files (`mobile/tool/gen_pick_one_adapters.py`). The
generator refuses a game whose answer buttons or screen differ from the
standard one, so a game is never squeezed into a layout it does not have.

| Check | Result |
|---|---|
| 1 to 4, built in against pack, every screen, day and night, phones 320, 390 and 430 wide (`test/packs/parity_test.dart`) | 60 of 60 runs, 0 pixels different. Same answers recorded, same rounds cleared, same concept sheets. |
| 5, the game audit on the pack's copy (`test/packs/pack_audit_test.dart`) | Every round carried: same problem, order, answer count and right answer. |
| On the iPhone simulator | Every round of every pack game played to the end. |

What the move needed: the Construction figures were switched to the
recordable text and path (no change to how they draw), and the builder
learned to keep a repeated shape once (a dashed line had made one game
200 KB to download; it is 5 KB).

## Dynamics (17 games), 2026-10-27

Moved, published in FE Civil pack version 3. Not switched on.

None of the seventeen use the standard screen. Rather than a game type per
layout, a pick-one round can now carry its own screen as a list of blocks
(see "A round laid out as its own screen" in the reference). Eight games
have a formula, a caption or a box around the usual answers; five answer by
tapping one of several drawings; four answer by tapping near a mark on one
drawing. The descriptions are written by hand in `mobile/test/packs/
dynamics.dart`, one per game, and the parity check is what proves them.

| Check | Result |
|---|---|
| 1 to 4, as above | 102 of 102 runs, 0 pixels different. |
| All moved games again after the builder changed (phase 0, Construction, Dynamics) | 180 of 180 runs, about 8,700 screens, 0 pixels different. |
| 5, the game audit | All 17 carry their audited rounds. For a round laid out as its own screen, the answers are checked by count, position and right answer: its words are the words on screen, where the audit names enum values. |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: bundled pack opens offline, the live server's pack matches its hash, every round of all 30 pack games played to the end (drawing answers and tap marks included), old app shown the update screen. |
| Everything else | The full mobile suite and the website and server suite (see the commit that merges this). |

What the move needed:

- The Dynamics figures switched to the recordable text and path. One
  private painter (When It Runs Away's response curve) became public so the
  builder can reach it. Nothing draws differently.
- A concept sheet row of two pictures written out by hand is read as the
  side-by-side pair it is.
- Rotated shapes. Does the Mass Matter's concept sheet turns two blocks to
  lie on a slope. At the builder's usual tolerance their edges landed six
  shades out of 255 apart on a few pixels. Turns are now kept to a ten
  millionth of a radian and moves of the canvas to a hundred thousandth of
  a pixel, and an angle along a slope is kept exactly, as an arctangent,
  instead of as thousands of straight pieces (that one picture went from
  190 KB to download to 70 KB).
- The parity script learned to scroll to answers below the fold, tap a
  drawing answer by its place, and tap a mark.

## Economics (19 games), 2026-10-27

Moved, published in FE Civil pack version 5 (version 4 held the first 13).
Not switched on.

Every Economics game has its own screen. Eight answer with the app's titled
row (a title with its condition written small beneath); five with answers
that tint when picked (`tiles`), one of them as a row of rates whose bars
redraw at whichever rate is tried; one game shows a small table of costs
and benefits. The last six needed new ways to answer, all for 1.2.0:

- **Picking several answers** (Over the Bar: every project that clears the
  MARR; What Does It Take: every factor a growing series needs): a new game
  type, `pick-several`. "None
  of them clears it" stands alone: picking it clears the rest, and picking
  a project clears it, as in the game.
- **Tapping one cell of a table** (Find the Factor, the MACRS table, about
  twenty answers a round): answer tiles placed in the table's rows.
- **Tapping a stretch of a drawing** (When Does It Land, Where the Cost
  Went, Roll It Back): the tap-a-drawing block now takes areas as well as
  marks.
- **Bars against a line** (Over the Bar): a block of its own.

Descriptions are in `mobile/test/packs/economics.dart`.

| Check | Result |
|---|---|
| 1 to 4, as above | 114 of 114 runs pass. Eighteen games pixel for pixel. Which Rate's concept sheet differs by sampling only: up to 12 pixels, at most 5 shades out of 255. |
| All moved games again after the builder changed | 228 of 228 runs pass (before the last six). Three concept sheets that were exact now differ by sampling only (What Is Missing at 430 wide, 104 pixels at most 7 shades; Tap the Trajectory, under 10 pixels at most 5 shades; Which Rate as above). |
| 5, the game audit | All 19 carry their audited rounds (49 pack games in all). |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 49 pack games played to the end, several-pick, table and tap-area rounds included. |
| Everything else | 3,759 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

How the script plays the new kinds: a several-pick round is tried with
everything picked (and one answer untapped and tapped again), then with
"none of them" picked, a project picked over it and "none of them" again,
then with exactly the right ones. A round with a table of twenty answers
tries its first, middle and last wrong answer rather than every one.

One difference kept on purpose: in the built-in Find the Factor, tapping
"Nothing. It is fully written off" a second time unpicks it; in the pack it
stays picked, as every other single answer does. Nothing else about the
game changes.

What else the move needed:

- **A bar for "looks the same" that can be met.** Which Rate's concept sheet
  draws a dashed line on a diagonal. However closely its numbers were kept
  (a thousand times closer was tried), one or two pixels along it came out a
  few shades different, because the renderer samples each pixel's edge at a
  few points and any shift at all can cross one. The first three chapters
  matched exactly only because nearly all their numbers are straight lines
  in the width. Written up as [ADR 0031](../../adr/0031-pack-drawings-match-to-sampling-not-bits.md)
  (proposed, for the owner): the geometry must match to a ten thousandth
  of a pixel, and the pixels may differ only as sampling does, no more than
  32 shades on no more than 0.05% of a screen. Every differing screen is
  still printed.
- The builder keeps repeated shapes and the widths where a drawing changes
  closer than before (that is the change the full re-run checks).
- The Economics figures switched to the recordable text and path. One
  private helper (Which Side Wins's description of a side) became public.
  Nothing draws differently.
- The update screen now scrolls when the words outgrow the screen (a small
  phone at the largest text size ran its button off the bottom). At normal
  sizes it is unchanged.

## Notes for after (not changed during the move)

1. **Three Dynamics formulas run off a small phone.** On a phone 320
   pixels wide, a formula overflows the screen in What Is Missing (by 9
   pixels), When It Runs Away (24) and Speeding Up or Turning (43), in the
   built-in games today as much as in the pack. The parity check now
   compares these errors between the two instead of stopping on them, so a
   pack that adds or loses one still fails. Fix: let those formulas shrink
   or wrap to the width. Most phones are 360 or wider, where they fit.
2. **Pack size will need splitting before the big chapters.** Version 3 is
   30 games, 4.1 MB on the phone and 320 KB to download. Three games are
   most of it: Does the Mass Matter (71 KB, its slope picture), How It
   Settles (70 KB, four curves each drawn in four states) and Tap the
   Trajectory (55 KB, a flight drawn once per mark picked). At this rate
   all 375 games would be about 50 MB on the phone, which is too much to
   read at launch. Before Mathematics at the latest: one file per chapter,
   loaded when the chapter is opened, and drawings that share most of their
   steps between states stored once.
