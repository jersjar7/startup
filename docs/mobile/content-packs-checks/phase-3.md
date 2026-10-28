# Phase 3 results: moving the chapters

Plan: [content-packs-migration.md](../content-packs-migration.md). How packs
work: [content-packs.md](../content-packs.md). One section per chapter, in
the plan's order. A chapter is moved when its games are in a published pack
and pass checks 1 to 5; it is switched on for students only after check 6
(the owner plays it on his phone).

## Download size

What a student's phone downloads, compressed as the server sends it. Each
chapter is measured on its own; the whole pack compresses as one file, so
it comes to a little more than the chapters added up. Updated with each
chapter.

| Chapter | Games | Download | Largest game |
|---|---|---|---|
| Construction | 10 | 37 KB | Five Feet and Twenty, 6 KB |
| Dynamics | 17 | 266 KB | Does the Mass Matter, 82 KB |
| Economics | 19 | 146 KB | Which Rate, 72 KB |
| Statistics | 19 | 259 KB | Shade the Tail, 103 KB |
| Ethics | 21 | 84 KB | Who Has to Agree, 16 KB |
| Fluid Mechanics | 21 | 185 KB | Where It Pushes, 36 KB |
| Materials | 23 | 141 KB | What This Job Needs, 15 KB |
| Statics | 23 | 435 KB | Where Do You Cut, 94 KB |
| Surveying | 23 | 251 KB | Which Traverse Closed Better, 28 KB |
| Mechanics of Materials | 27 | 250 KB | How Far Has It Yielded, 63 KB |
| Structural | 28 | 159 KB | Where Do You Take Moments, 15 KB |
| Transportation | 29 | 271 KB | Crest or Sag, 105 KB |
| Water Resources | 32 | 248 KB | What Moves the Critical Depth, 29 KB |
| Geotechnical | 35 | 234 KB | How Long Does It Take, 53 KB |
| Mathematics | 48 | 351 KB | Follow the Tangent, 40 KB |
| **Whole pack, version 18 (all of FE Civil)** | **375** | **3.40 MB** | |

The limits the builder enforces are 250 KB for any one game and 25 KB on
average. The pack grows by about 10 KB a game (Statics, all drawings, ran
to 19 KB a game), so all 375 games should come to roughly 4 MB, about one
phone photo.

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
  (accepted by the owner the same day): the geometry must match to a ten thousandth
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

## Statistics (19 games), 2026-10-27

Moved, published in FE Civil pack version 6 (68 games, 737 KB to
download). Not switched on.

Almost no two Statistics games share a layout: a calculator readout whose
lines are the answers, a table whose column headings are tapped to give
each column a role, a formula with three slots that fill as factors are
picked, a dot plot where any number of ticks are tapped, a bell curve
tapped by region. Rather than a block per game, a round's screen can now be
written as **screen nodes**, the same few widgets the built-in games are
made of, with any value able to follow the round (the answer's state, a
slot, before and after). Written up as
[ADR 0032](../../adr/0032-pack-screens-as-widget-nodes.md). The rest the
app gained, all general and for 1.2.0:

- **Several picks with limits and order:** no more than `most`, exactly
  `need` before Lock it in, and `order` (`list` for Mind the Order's
  "first minus second", `slots` for What Gets Weighted's two roles).
- **A round's own verdict** (Which Line Do You Read says "NOT ON THE
  SCREEN" when that is the answer).
- **A row of pictures on a concept sheet** (Which Way Does It Point's three
  tails side by side).
- **Drawings kept in parts.** How Many Samples' dashed "wanted" line gains a
  dash every ten pixels of width, and the builder kept the whole picture,
  a 240 point curve included, once per dash: 6.9 MB for one game. Now the
  steps before and after the stretch that changes are kept once, whenever
  that is smaller: 45 KB.

Descriptions are in `mobile/test/packs/statistics.dart`, written with the
helpers in `mobile/test/packs/nodes.dart`.

| Check | Result |
|---|---|
| 1 to 4, as above | 114 of 114 runs pass, all 19 games pixel for pixel on every screen. |
| All moved games again after the builder changed | Every one of the 68 passes. Which Rate's concept sheet still differs by sampling only (37 pixels at most 6 shades at 320 wide, 1 pixel at 430). |
| 5, the game audit | All 19 carry their audited rounds (68 pack games in all). |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 68 pack games played to the end. |
| Everything else | 3,892 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- **Drawing corners placed exactly.** Where a number bends (the Venn
  circles stop growing at 270.45 pixels wide), the builder put the corner
  at the nearest width it had looked at, so the straight piece after it
  started 0.00003 of a pixel low. The letters under the circles sit on a
  half pixel, and that was enough to round them a whole pixel up. Corners
  now go where the two straight pieces meet, checked against every value.
  This changed drawings in every chapter, which is why all 68 games were
  compared again.
- **A label's patch drawn in both themes.** A label patches the lines
  under it by day but not at night, so day and night drew different shapes
  and could not be kept as one drawing (the readout picture on Which Line
  Do You Read's sheet). The patch is now drawn clear when it is not wanted.
  Nothing looks different.
- **Answers keep their place.** An answer written as a node now keeps its
  identity when a picture appears above it once answered, as the built-in
  buttons do, so a layout error is reported once, not once per redraw.
- **The parity check plays every several-pick round to the end.** Build
  the Binomial, Mind the Order and What Gets Weighted are the first rounds
  that need a set number of picks. On its second try the script picked
  one, so Lock it in never came on and the run stopped at its turn limit
  before the last rounds; built-in and pack stopped alike, so it passed
  while covering less. Caught before merging: the second try now picks as
  many as the round needs, and the 114 runs above play every round. (The
  Economics several-pick rounds take any number of picks and were never
  affected.) The check also shows a game's real error instead of one about
  its error handler.
- The Statistics figures switched to the recordable text and path, the dot
  plot draws its axis, columns and readings as separate steps, and one
  helper in What Goes Under became public. Nothing draws differently.

## Ethics (20 games), 2026-10-27

Moved, published in FE Civil pack version 7 (88 games, 819 KB to
download). Not switched on. In What Order moved in phase 0, so all 21
Ethics games are now in the pack.

Most Ethics games are a scene over a short list of rows, each a title with
a small note, so they are written as screen nodes from a few shared pieces
in `mobile/test/packs/ethics.dart`. No game needed its own app code. The
app gained two general things:

- **A check icon node,** for the tick boxes of Who Has to Agree and How
  Many Protections.
- **Answer groups** (`groups`): answers in a group are one choice, so
  picking one replaces the other. Grounds, or Not asks four yes-or-no
  questions in one round, each question's Yes and No a group.

| Check | Result |
|---|---|
| 1 to 4, as above | 120 of 120 runs pass, all 20 games pixel for pixel on every screen, every round played. |
| Size | Every game under 16 KB to download; the largest are Who Has to Agree and Which Section, both for their concept sheet's picture. |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 88 pack games played to the end. |
| Everything else | 4,032 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- The contract and life-cycle figures switched to the recordable text and
  path. Nothing draws differently.
- The parity check fills a round of groups by picking the last answer of
  each group, so a round that needs one answer per question can be locked
  in.
- One small difference in favour of the pack, not seen by the check: in
  the built-in Who Has to Agree, tapping "No consent makes this
  acceptable" a second time keeps it picked; in the pack it unpicks it,
  like every other row.

## Fluid Mechanics (21 games), 2026-10-27

Moved, published in FE Civil pack version 8 (109 games, 1.01 MB to
download; Fluid Mechanics is 185 KB of it). Not switched on.

Every Fluid Mechanics game lays its round out as its own screen, written
with screen nodes and blocks in `mobile/test/packs/fluids.dart`. Answers
that are drawings, drawings tapped by area or near a mark, and drawings
that show their answer once it is in were all already possible. The app
gained three small, general things:

- **A formula node** (`math`), for a formula inside a row: Which One to
  Match sets the Reynolds and Froude numbers side by side under its rig.
- **Grid spacing** on the grid node, for the finer grid inside answer
  panels (How Fast the Jet, Which One Drags More, Which Target Takes More).
- **Even spacing** for a row's children.

The figures switched to the recordable path and text, and the path shim
gained `Path.from` (a copy keeps the moves of the path it copies), which
the pipe, meter and fluid figures use.

| Check | Result |
|---|---|
| 1 to 4, as above | 126 of 126 runs pass, all 21 games pixel for pixel on every screen, every round played. |
| Size | 185 KB for the chapter; every game under 40 KB, the largest Where It Pushes (36 KB). |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 109 pack games played to the end. |
| Everything else | 4,179 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What the move found in the builder, both fixed for every chapter (see
[content-packs.md](../content-packs.md)):

- **Memory.** The first Fluid Mechanics build passed four gigabytes and
  crawled for over three hours before it was caught: every label asks
  google_fonts for its style and leaves a small job for the event loop,
  and the builder never let the loop turn. Each recording now runs those
  jobs before returning, and a chapter builds in about ten minutes under
  half a gigabyte.
- **A label exactly as wide as its room.** "heavy oil, 0.4 Pa s" in Which
  One Drags More fits its panel on a 320 phone with nothing to spare; a
  hair narrower and it wraps. The builder played the gap between the two
  widths it had looked at as a slope, and drew the label's patch two
  pixels tall. It now also records the roundest width inside such a gap.

The device test now names each game as it plays it. A full run is about
23 minutes, and silent, it was once taken for stuck and stopped.

## Materials (22 games), 2026-10-28

Moved, published in FE Civil pack version 9 (131 games, 1.15 MB to
download; Materials is 141 KB of it). Not switched on. Tap the Voids
moved in phase 0, so all 23 Materials games are now in the pack.

The adapters are in `mobile/test/packs/materials_a.dart` (stress and
strain through concrete curing) and `materials_b.dart` (aggregate through
corrosion), written side by side and registered together as one chapter.
The app gained two small, general things:

- **A miss verdict per answer:** a round's `wrong` may be a list, one per
  answer, for games whose miss names the answer picked ("THAT IS APPARENT
  SPECIFIC GRAVITY" in Which Weighing, and Along or Across).
- **A weight on words in a node,** for the bold mono values of Something
  Is Wrong Here.

| Check | Result |
|---|---|
| 1 to 4, as above | 132 of 132 runs pass, all 22 games pixel for pixel on every screen, every round played. |
| Size | 141 KB for the chapter; every game under 16 KB, the largest What This Job Needs. |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 131 pack games played to the end. |
| Everything else | 4,333 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- The curve, crack, thermal, concrete and aggregate figures and the
  Materials concept pictures switched to the recordable path and text.
  Nothing draws differently.
- Two games tap points on two curves that meet. True or Engineering and
  Coarse or Fine list each curve's points from where the curves are
  furthest apart, so the parity script taps a point that belongs to one
  curve only; a tap equally near both still goes to the same curve as in
  the built-in game.
- **Fixed in both versions:** Which One Moves Most said "Which One Biggest
  Most" on its done screen.

## Statics (23 games), 2026-10-28

Moved, published in FE Civil pack version 10 (154 games, 1.60 MB to
download; Statics is 435 KB of it, the heaviest chapter so far because
nearly every round is a drawing). Not switched on.

The adapters are in `mobile/test/packs/statics_a.dart` (forces through
trusses) and `statics_b.dart` (frames through second moments), written
side by side and registered together as one chapter. The app gained:

- **A drawing answered by the nearest line** (Which Arrow Is That): every
  tap on the figure picks the line it is closest to, however far.
- **Ranked picks:** a pick-several round can be answered in order
  (`"by":"order"`), and `trim` lets a tap on a picked answer take it back
  along with every pick after it (Rank Them by Stiffness).
- **A path's matrix kept exactly:** figures that turn a whole path onto
  the screen (`Path.transform`) are recorded with that move, its numbers
  kept a hundred million times closer than a pixel.
- **Kept closer:** a figure can ask the builder to keep its numbers to a
  ten millionth of a pixel, and the builder now searches lone bands again
  and places bends from inside a width. See content-packs.md.

| Check | Result |
|---|---|
| 1 to 4, as above | 138 of 138 runs pass, all 23 games pixel for pixel on every screen, every round played. |
| Size | 435 KB for the chapter; every game under 100 KB, the largest Where Do You Cut (94 KB) and Which Side Is Tight (88 KB). |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 154 pack games played to the end. |
| Everything else | 4,494 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- The Statics figures (forces, moments, trusses, frames, sections, the
  belt drum) switched to the recordable path and text. Several large
  figures are now painted a piece at a time, so a pack keeps one drawing
  per piece instead of one per combination; the answer glyphs are shared.
  Before and after screenshots of every built-in Statics game, first round
  and concept sheet, day and night, at all three widths: 276 compared,
  none differ.
- **One built-in change, within the noise bar:** the derrick cable dashes
  in Along It or Not are now laid out slightly differently, at most 31
  shades on a few edge pixels (ADR 0031 allows 32). Nothing a student
  could see.

## Surveying (23 games), 2026-10-28

Moved, published in FE Civil pack version 11 (177 games, 1.86 MB to
download; Surveying is 251 KB of it). Not switched on.

The adapters are in `mobile/test/packs/surveying_a.dart` (bearings
through areas) and `surveying_b.dart` (earthwork through vertical
curves), written side by side and registered together as one chapter.
The app gained:

- **Dashed lines kept as their two ends.** A dashed line is recorded as
  one step and dashed on the phone with the same loop the game uses.
  Before this, the dashed slopes made Road or Grade Line 1.8 MB and Where
  It Flattens Out 6.7 MB; now they are 8 KB and 15 KB.
- **An arc to tap** (Which Curve Is Sharper): the nearer of two curves
  within 24 pixels, measured to the arc itself.
- **The first mark in reach** (`"first": true`): five Surveying games
  check their marks in order and take the first within reach, not the
  nearest, and the pack now does the same.

| Check | Result |
|---|---|
| 1 to 4, as above | 138 of 138 runs pass, all 23 games pixel for pixel on every screen, every round played. |
| Size | 251 KB for the chapter; every game under 30 KB, the largest Which Traverse Closed Better. |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 177 pack games played to the end. The first run stopped at Which Curve Is Sharper because the simulator script did not yet tap an arc; it now taps halfway round it. |
| Everything else | 4,655 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- The bearing, leveling, area, earthwork, coordinate, profile and
  alignment figures and the Surveying concept pictures switched to the
  recordable path and text. Nothing draws differently: each helper
  compared every built-in Surveying screen before and after (184
  screenshots and 3,256 drawing hashes), all identical.
- The Surveying sheets stacked two pictures in a small widget of their
  own; it is now a function that returns a plain column, and the builder
  can also read any such widget by what it builds.

## Mechanics of Materials (27 games), 2026-10-28

Moved, published in FE Civil pack version 12 (204 games, 2.12 MB to
download; Mechanics of Materials is 250 KB of it). Not switched on.

The adapters are in `mobile/test/packs/mechanics_a.dart` (axial through
beam sections) and `mechanics_b.dart` (deflection through columns),
written side by side and registered together as one chapter. The app
gained:

- **Combined paths kept as moves** (`Path.combine`): Which Area Twists It
  shades a tube's metal as one circle minus another, which could only be
  traced before, turning circles into polygons.
- **Dashes along a path:** the same game dashes the middle of the tube
  wall; the phone runs the loop the game already ran.
- **A tap measured up and down only** (`"axis": "y"`), for Which Fiber Is
  Worst, which picks the nearest layer by height.

| Check | Result |
|---|---|
| 1 to 4, as above | 162 of 162 runs pass, all 27 games pixel for pixel on every screen, every round played. |
| Size | 250 KB for the chapter; every game under 64 KB, the largest How Far Has It Yielded. |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 204 pack games played to the end. |
| Everything else | 4,844 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- The axial, torsion, diagram, stress, deflection, composite, Mohr and
  column figures and the Mechanics concept pictures switched to the
  recordable path and text. Nothing draws differently: each helper hashed
  every built-in screen of its games before and after (4,044 and 3,756
  hashes), all identical.
- Square Bar's painter in Which J Is It became public so it can be
  recorded.

## Structural (28 games), 2026-10-28

Moved, published in FE Civil pack version 13 (232 games, 2.28 MB to
download; Structural is 159 KB of it). Not switched on.

The adapters are in `mobile/test/packs/structural_a.dart` (determinacy
through influence lines) and `structural_b.dart` (Where Do You Park It,
reinforced concrete and steel), written side by side and registered
together as one chapter. Every game is a screen the pack could already
show, so the app gained nothing new; the builder gained one fix:

- **A bend on a width looked at.** How Much Comes Off draws hatched
  squares that stop growing at exactly 300 wide. The builder placed that
  bend where the lines either side meet, 299.99998, and on a 320 phone
  that moved thousands of hatch pixels a shade or two. When a width the
  builder sampled sits within a hundredth of a pixel of the meeting and
  fits every value closer, it is now the corner. This recorded 17 games
  already in the pack slightly differently; each was compared again and
  all match to the pixel.

| Check | Result |
|---|---|
| 1 to 4, as above | 168 of 168 runs pass, all 28 games pixel for pixel on every screen, every round played. |
| Size | 159 KB for the chapter; every game under 16 KB, the largest Where Do You Take Moments. |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 232 pack games played to the end. |
| Everything else | 5,040 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- The determinacy, truss, virtual work, redundant, load, influence, steel
  and reinforced concrete figures and the Structural concept pictures
  switched to the recordable path and text. Nothing draws differently:
  the helpers hashed every built-in Structural screen before and after
  (7,608 screens, and 2,896 drawings at eight widths), all identical.
- Traced, the steel column's bowed lines would have made Which Axis Wins
  Now 819 KB; kept as moves it is 4 KB. Two column cage sheets are kept
  closer, about 4 KB each, so their hatching matches to the pixel.
- Two private names became public for the adapters (the truss in Joints
  or Sections, and the load rows in Which One Controls).

## Transportation (28 games), 2026-10-28

Moved, published in FE Civil pack version 14 (260 games, 2.55 MB to
download; Transportation is 271 KB of it, counting Per Million What,
which moved in phase 0). Not switched on. All 29 Transportation games are
now in the pack.

The adapters are in `mobile/test/packs/transportation_a.dart` (stopping
sight distance through truck equivalents) and `transportation_b.dart`
(trip generation through pavement design), written side by side and
registered together as one chapter. Every game is the standard screen
Per Million What has had since phase 0, so neither the app nor the
builder needed anything new.

| Check | Result |
|---|---|
| 1 to 4, as above | 168 of 168 runs pass, all 28 games pixel for pixel on every screen, every round played. |
| Size | 271 KB for the chapter. The two largest, Crest or Sag (105 KB) and How Much Bank (50 KB), draw a car that rides a curve and tilts with the road; every other game is under 21 KB. |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 260 pack games played to the end. |
| Everything else | 5,236 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- The vertical curve, traffic flow, sign, pavement and rigid pavement
  figures switched to the recordable path and text. Nothing draws
  differently: the helpers hashed every round drawing and sheet picture
  that use them before and after (1,264 and 3,152 drawings at eight
  widths, day and night), all identical.

## Water Resources (32 games), 2026-10-28

Moved, published in FE Civil pack version 16 together with Geotechnical
(see below; Water Resources is 248 KB of it). Version 15 carried it
first, and the full phone suite then caught two things, so it was fixed
and published again rather than merged:

- **What the Water Touches numbered its answers its own way.** The game's
  answers are the six pieces a boundary can have; the pack listed only
  the pieces a channel draws, so on a channel with no freeboard (round 4)
  the answer was a different number from the game's, which the pack
  audit test caught. The pack now keeps all six, as the game does.
- **A shape's bounds tested inline** (`figure_ink.dart`), which the
  figures check forbids because of an old bug with paths that only
  move; it now reads the bounds first, as the figures' own hatching
  loop does. Nothing records differently.

The adapters are in `mobile/test/packs/water_a.dart` (open channels
through hydrology) and `water_b.dart` (routing, groundwater and
treatment), written side by side and registered together as one chapter.
The app gained:

- **Soil grains as one step** (`grains`): Which Speed Is That packs an
  aquifer block with grains, more of them the wider it is. Kept grain by
  grain the game was 44.6 MB; kept as the block and its porosity, filled
  on the phone by the game's own loop, it is 3.6 KB.
- **A hatched shape as one step** (`hatch`): the phone hatches the shape
  with the figures' own loop. Hatching kept line by line could not land
  exactly where the app draws it (Which Formula Fits This Weir), and
  keeping it closer instead made a game 5.5 MB. Only these games use it,
  so every earlier game records as before.
- **A line to tap within its own reach** (What the Water Touches takes
  the nearest piece within 22 pixels), and the test scripts tap a line at
  its middle.

The builder gained one fix: every bend is first moved to where its two
pieces meet, before a nearby sampled width is tried in its place (What
the Water Touches bends at exactly 342 wide, which had been kept at
341.9998). This recorded 31 games in earlier chapters slightly
differently; each was compared again and all match to the pixel.

| Check | Result |
|---|---|
| 1 to 4, as above | 192 of 192 runs pass, all 32 games pixel for pixel on every screen, every round played. |
| Size | 248 KB for the chapter; every game under 30 KB, the largest What Moves the Critical Depth. |
| On the iPhone simulator (iPhone 17 Pro) | As for Geotechnical, below. |
| Everything else | As for Geotechnical, below. |

What else the move needed:

- The channel, flow, weir, main, hydrograph, aquifer, BOD, clarifier and
  chlorine figures and the Water Resources concept pictures switched to
  the recordable path and text. The channel section is painted in three
  parts so the pack can layer its pieces. Nothing draws differently: the
  helpers hashed every built-in Water Resources drawing and sheet picture
  before and after (5,007 and 3,760 hashes), all identical. The figures'
  hatching loop moved into a shared function unchanged, so every other
  hatched figure in the app draws exactly as before.

## Geotechnical (35 games), 2026-10-28

Moved, published in FE Civil pack version 16 with Water Resources (327
games, 3.04 MB to download; Geotechnical is 234 KB of it). Not switched
on.

The adapters are in `mobile/test/packs/geotech_a.dart` (phase relations
through the infinite slope) and `geotech_b.dart` (slope stability
through deep foundations), written side by side and registered together
as one chapter. Every game is the panel screen (the problem, a drawing
in a white panel, a formula under it in some, plain answer rows), so
neither the phone nor the builder needed anything new. Two things in the
figures did:

- **Sheet labels set with a plain text painter.** The Geotechnical sheet
  pictures laid out their own labels, which the recorder cannot read;
  they now use the text and path shims, as the Structural sheet pictures
  do.
- **A traced curve that never finished.** Wetter Is Not Denser's Proctor
  curve is 61 short lines; traced, the builder found different corners at
  nearly every width and had not finished one round after half an hour.
  Through the path shim it is its 61 moves and records in under two
  seconds. The classification, effective stress, consolidation, seepage,
  slope, earth pressure, wall, compaction and pile figures all draw their
  paths through the shim now.

| Check | Result |
|---|---|
| 1 to 4, as above | 210 of 210 runs pass, all 35 games pixel for pixel on every screen, every round played. |
| Size | 234 KB for the chapter; 3.3 to 53 KB a game. How Long Does It Take is the large one: about 280 small arrowheads on its drainage arrows, kept path by path. Well under the ceiling, so left. |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 327 pack games played to the end. |
| Everything else | 5,705 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- Nothing draws differently: the helpers hashed every round drawing of
  the 35 games, of the three other games that share the slope figures,
  and every Geotechnical sheet picture before and after (4,400 and 3,806
  images), all identical.

## Mathematics (48 games), 2026-10-28

Moved, published in FE Civil pack version 18 (375 games, 3.40 MB to
download; Mathematics is 351 KB of it). Not switched on. With it every
one of the 375 games in the app is in the pack: all of FE Civil.

Version 17 carried it first; the full phone suite then caught two
things, so it was fixed and published again rather than merged:

- **Which Happens First numbered its answers its own way.** The game's
  answers are every piece of the formula, operators included (which are
  never tappable); the pack listed only the tappable pieces, so each
  answer was a different number from the game's, which the pack audit
  test caught. The pack now keeps every piece, as the game does, and the
  parity check skips a wrong answer that has no button to tap.
- **A test leaned on a game not being packed.** The pack store test showed
  that an unpacked game still plays as built-in using Perpendicular Flip,
  which is now packed; it now takes the game out of a later pack itself.

The adapters are in `mobile/test/packs/mathematics_a.dart` (algebra,
trigonometry, analytic geometry, calculus and differential equations)
and `mathematics_b.dart` (integrals, vectors, spreadsheets, programming
and numerical methods). Mathematics' games were among the first built,
each laid out its own way, so nearly every screen is written as screen
nodes, and the chapter taught the phone more than any other
(`docs/mobile/content-packs.md` has each in full):

- **Drawing steps the player repeats as the figure did:** a parabola
  (`para`) and a triangle's side labels, angle arcs and corner labels
  (`beside`, `carc`, `ptext`), found from the points they start at.
- **New ways to answer:** bare tap areas with no ripple (`plain`, as a
  spreadsheet cell or a piece of a formula is), slots tapped to empty
  them, answers dragged across a drawing, a run of moves with no lock in
  (Run the Loop), a pick moved with plus and minus buttons (Stretch It to
  Fit), rows filled in turn (Fill the Trace), a drawing pinned or moved
  onto the one point picked out of 169 (Land the Resultant, Place the
  Center), other accepted orders, and a button the game names itself.
- **New tap rules on a drawing:** a line within its own stroke
  (`"reach": "stroke"`, Tap the Side), the larger of across and up
  (`"axis": "box"`, a lattice), and the later of two spots as near
  (`"tie": "last"`, as Slide to the Flat Spot rounds a half up).

The two halves were written side by side and both taught the renderer a
fade, a wrap, a slot tapped empty, and values that follow how a round
ended or whether an answer is picked, under different names. They were
joined on one set of names before the chapter was checked. What the
Water Touches now asks for its line reach by name too, and passes again.

| Check | Result |
|---|---|
| 1 to 4, as above | 288 of 288 runs pass, every round played. Two games carry small differences inside the ADR 0031 bar: Slide to the Flat Spot (108 pixels by at most 8 shades on five screens at 390 wide, at night) and Land the Resultant (5 pixels by at most 2 shades on five screens at 320 wide). Every other screen is pixel for pixel. |
| Size | 351 KB for the chapter; 2.3 to 40 KB a game, the largest Follow the Tangent. |
| On the iPhone simulator (iPhone 17 Pro) | 4 of 4: every round of all 375 pack games played to the end. |
| Everything else | 6,041 phone tests (the full drawing comparison of every moved game among them) and 961 website and server tests. |

What else the move needed:

- The vector, cross product, root finding, discriminant, triangle and
  Mathematics sheet figures draw through the recording shims. The
  helpers hashed every built-in Mathematics drawing and sheet picture
  before and after, all identical.

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

3. **How Do They Sit runs off a small phone.** On a phone 320 pixels wide,
   the answer "One changes the odds of the other" wraps to two lines and
   overflows its button by 18 pixels, in the built-in game as much as in the
   pack. Fix: let the button grow with its words.

4. **Mechanics of Materials formulas run off the screen.** In the
   built-in games as much as in the pack: What Comes Out (58 and 215
   pixels at 320, still 105 at 430), Can You Get There (15 at every
   width) and Is R the Worst (15 at 320). Fix: let a long formula wrap or
   scale down.

5. **Structural formulas run off the screen.** In the built-in games as
   much as in the pack, at 320 pixels wide: Which Line Is It and Which
   One Controls (287, still 177 at 430), What the Table Gives You (239),
   Where Do You Park It (235), The Count Says Yes (197, still 87 at 430),
   Z or S (190 and 176), Both Factors or One (125), Which Axis Wins Now
   (93), More, Less or the Same (81), Factored or Service (63), Enough or
   Too Many (47), and about 25 in three steel and concrete games. Fix: as
   note 4.

6. **How Much Bank could be smaller.** Its car turns with the road, and
   the builder's turned-figure shortcut assumes the run along the road is
   positive at width zero. Here it is the width minus 46, so the shortcut
   gives up and the angle is kept bend by bend (50 KB). Flipping the sign
   for such a run should shrink it a lot; not measured. Test: make the
   change, rebuild this one game and compare, then rebuild the pack and
   compare every game whose recording changed.

7. **Water Resources formulas run off a small phone.** In the built-in
   games as much as in the pack, at 320 pixels wide: Double the Drawdown
   (34) and What Do You Feed (43). Fix: as note 4.

8. **Geotechnical formulas run off a small phone.** In the built-in games
   as much as in the pack: Which Fork First (78 pixels at 320 wide, 8 at
   390), Above or Below the Line (53 at 320), Drained or Not (101 at 320,
   31 at 390) and Which Term Drops Out (27 at 320). Fix: as note 4.
