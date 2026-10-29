# Content packs: how they work

The reference for packs as built. The decision is
[ADR 0030](../adr/0030-content-packs-and-game-types.md); the order of work is
[content-packs-migration.md](content-packs-migration.md). Written 2026-10-26
at the end of phase 1.

Students see none of this yet. Since phase 2 the app can hold, update and
play packs, but only behind a switch that is off in every build students
get (`--dart-define=PACKS=true` turns it on for development). The phase 2
record has what the app does with a pack:
[content-packs-checks/phase-2.md](content-packs-checks/phase-2.md).

## What a pack is

One exam's study material for the phone: its lessons, and every game in
them with its rounds, recorded drawings and concept sheet. No code. The app
plays it with game types it already has.

The builder writes it as one JSON file. The publisher splits it into a small
index and one file per chapter (format 2,
[ADR 0033](../adr/0033-a-pack-is-published-as-one-file-per-chapter.md));
see [Publishing](#publishing). As the builder writes it:

```json
{
  "format": 2,
  "exam": "fe-civil",
  "title": "FE Civil",
  "version": 1,
  "lessons": {
    "transportation/traffic-flow": { "minApp": "1.2.0", "games": ["per-million-what"] }
  },
  "games": {
    "per-million-what": { "id": "per-million-what", "type": "pick-one", "chapter": "transportation", "...": "..." }
  }
}
```

- **format.** The layout of the files. Raised only if an older app
  could no longer make sense of a pack at all; format 2 split it by
  chapter. A new game type never raises
  it; that is what `minApp` is for.
- **version.** Given by the publisher, 1, 2, 3 and so on. Never reused.
- **lessons.** Keyed `chapter/lesson`, the same ids as the app's catalog and
  `service/lessonGames.json`. Each lists its games in order and the oldest
  app that can play all of them.
- **games.** Keyed by game id, the same ids as today, so progress, the
  Daily, badges and challenges carry over untouched. `type` names the game
  type that plays it. The rest is described in the
  [phase 0 record](content-packs-checks/phase-0.md).

## How a drawing is kept

Every drawing is recorded by running the game's own painter at every width
a phone can give it, in day and night (the builder, `mobile/test/packs/`).
What is kept:

- **Numbers that follow the width**: a plain number, a straight line
  (`{"w": [a, b]}` is `a + b * width`), or a line with bends
  (`{"p": [width, value, ...]}`). A number is kept to a ten thousandth of a
  pixel. Two are kept closer (2026-10-27), because Does the Mass Matter's
  blocks on a slope landed a few edge pixels six shades out of 255 apart at
  that figure: a turn of the canvas to a ten millionth of a radian (a turn
  moves a corner by the angle times its distance from the pivot), and a
  move of the canvas to a hundred thousandth of a pixel.
- **Angles along a slope** (`{"a": [c, d, e, f]}` is atan2(c + d w,
  e + f w)), added 2026-10-27. A figure turned to lie along a slope whose
  run follows the width has an angle no chain of straight pieces can follow
  closely: the one picture took 190 KB to download kept that way, and 70 KB
  with this.
- **Colors** as `{"#": argb}`, or `{"#": [day, night]}`.
- **Repeated shapes** (a dashed line, a row of ticks, a hatch), added
  2026-10-27: one step drawn so many times, moving by the same amount each
  time (`["run", count, first, step]`). The count steps as the width grows
  (`{"n": [count, width, count, ...]}`). Without it, a dashed line made
  every few pixels of width a separate drawing: one trench game was 200 KB
  to download, and is 5 KB with it.
- **A whole dashed line** (`["dash", ax, ay, bx, by, on, every, paint]`),
  added 2026-10-28 with Surveying. A run still kept every dash of a line
  along a slope whose run follows the width: each dash end then lies on a
  curve in the width, and the last dash is cut short somewhere different
  at every width, so Road or Grade Line took 1.8 MB to download and Where
  It Flattens Out 6.7 MB. A figure that draws its dashes through
  `drawDashes` (`lib/features/packs/drawing/figure_dash.dart`) is recorded
  as the line's two ends, and the player runs the figure's own loop on
  them: 7.7 KB and 15 KB. On a phone's real canvas `drawDashes` is the
  same loop the figures had, so the built-in drawings did not change by a
  pixel (every Surveying drawing and sheet picture compared before and
  after).
- **Soil grains** (`["grains", left, top, right, bottom, porosity, seed,
  fill, edge]`), added 2026-10-28 with Water Resources: a block packed
  with grains by the figure's own seeded loop (`drawGrains`,
  `lib/features/packs/drawing/figure_grains.dart`), recorded as the block
  once and filled by the player the same way. See the Water Resources
  notes below.
- **Bands** (`{"bands": [[from width, steps], ...]}`) for a drawing that
  really changes at some width.
- **Concept sheet pictures**: one drawing, two side by side, or a column of
  those with gaps (`"kind": "one" | "pair" | "column" | "gap"`).

Two things about the builder itself, both learned on Fluid Mechanics
(2026-10-27):

- **A number that jumps.** A label that fits on one line from some width on
  has a patch behind it that halves in height at that width. No straight
  piece crosses the jump, so the builder looks no closer than a thousandth
  of a pixel and plays the gap between as a slope. Which One Drags More
  has a label exactly as wide as its panel leaves it on a 320 phone, and
  drew its patch two pixels tall there. Where two widths that close still
  disagree, the builder now also records the roundest width between them,
  so a jump that falls on a whole width is played from the side the
  painter takes.
- **Memory.** Every label a figure writes asks google_fonts for its style,
  and each ask leaves a small job for the event loop. The builder records
  each figure at hundreds of widths without the loop ever turning, so the
  jobs piled up: the first Fluid Mechanics build passed four gigabytes and
  crawled for hours. Each recording now runs its own jobs before it
  returns, and the build stays near 200 MB.
- **Kept closer** (Statics, 2026-10-28). A figure can be asked to keep
  its numbers to a ten millionth of a pixel instead (`closer` in the
  builder). Which Distance Counts runs a dashed line of action straight
  down a slanted strut, and at the plain tolerance enough of its dash
  edges sampled a few shades off to pass ADR 0031's share of the screen;
  a belt round a drum and a block on a slope did the same on one phone
  each. The cost is a few kilobytes a game, so it is used only where a
  figure needs it, never as the default.

What "the same" means for a drawing ([ADR 0031](../adr/0031-pack-drawings-match-to-sampling-not-bits.md),
proposed 2026-10-27): every number within the tolerances above, and on
screen no pixel more than 32 shades out of 255 from the built-in game's,
on no more than 0.05% of the screen. A number that is not a straight line
in the width (a dash along a diagonal) can be as close as you like and
still tip one pixel's edge sampling, so pixel-for-pixel equality is not a
bar that can be met for every drawing. The parity check still prints every
screen that differs at all.

## A round laid out as its own screen

The first pick-one games all had the same screen: an overline, the
problem's subject and question, one drawing, the answers as a list. Most
chapters lay their rounds out differently: a formula under the drawing, a
caption that changes once answered, a box of what the problem says, answers
that are drawings, a drawing you tap near a mark. Rather than a game type
per layout, a pick-one round may carry its whole screen as a list of blocks
(`"screen": [...]`), each one widget of the column, in order. Added
2026-10-27 for Dynamics; the earlier games keep the plain layout.

| Block | What it is |
|---|---|
| `gap` | Empty height. |
| `overline`, `mono`, `text`, `code` | The game's kinds of words (`text` may be `bold`, with its own size and line height; `code` may be grey). |
| `math` | A centered formula. |
| `figure` | A recorded drawing, before (`ask`) and after (`done`), framed as a bordered `panel`, on the bare `grid`, clipped to a rounded corner (`clip`), or `none`. Its height may differ before and after. |
| `box` | A box holding blocks: white and bordered, or shaded with its own corner and no border, as Economics quotes a problem. |
| `row`, `rule` | Words side by side (a column a set width, or sharing what is left, centred), and a hairline between rows. Together they make a small table. |
| `choices` | The answers as buttons, all of them or a listed few. An answer may carry a symbol before its words (`tex`), or a note beneath it (`notes` on the round, the app's titled row). |
| `tiles` | Answers that tint as well as border when picked, each a row of words or a formula, in a column or side by side. Most of Economics answers this way. A row of a table may hold answer tiles one by one (Find the Factor's table of percentages, about twenty answers a round), and a tile may carry a check box that fills when it is marked. |
| `bars` | Answers as horizontal bars against a reference line across all of them, each bar an answer tapped anywhere along its row (Over the Bar's projects against the MARR). |
| `panels` | Answers that are drawings, in a column or a row, each recorded as it looks idle, picked, right and wrong (or just idle and "on" when only the border changes, since a picked border is a pixel thicker and the drawing inside a pixel smaller). |
| `tap` | A drawing answered by tapping near a mark (the nearest within reach wins) or inside an area (the last area holding the tap wins, as the topmost does in a game built from a stack of tap areas). Recorded for every mark picked, or none, before and after. |
| `pickedLabel` | The picked answer's words, while it is picked. |
| `feedback` | The verdict and the why. |

Any block can be limited to before the answer, after it, while nothing is
picked, while an answer is picked and not yet locked in, or while one is
picked at all (`"when": "ask" | "done" | "none" | "picked" | "chosen"`),
and the last three to particular answers (`of`). Balance the Rate uses this
to redraw its bars at whichever rate is being tried. The app's side is
`mobile/lib/features/packs/games/pick_one_game.dart`; the adapters that
describe each game are in `mobile/test/packs/` (`dynamics.dart`,
`economics.dart`, `statistics.dart`, `ethics.dart`, `fluids.dart`).

**Pick several** (game type `pick-several`, added 2026-10-27 for
Economics) is the same screen with any number of answers picked: right when
exactly the right ones are. An answer may stand alone (`alone`, as "None of
them clears it"): picking it clears the rest, and picking any other clears
it. The round's `answer` is then a list.

**Screen nodes** (added 2026-10-27 for Statistics). Statistics has 19
games and almost no two lay their screen out alike: a calculator's readout
whose lines are the answers, a table whose columns are tapped to give them a
role, a formula with three empty slots that fill as factors are picked, a
dot plot where several ticks are tapped. A block per layout would have meant
a dozen new blocks for one chapter, each used once. Instead a block may be a
small widget tree, written with the same widgets the built-in games use, so
any layout made of them can be described without changing the app:

| Node (`k`) | What it is |
|---|---|
| `box` | A container: padding, width (or the full width), height, fill, border (all round, or the top only), corner, alignment, clipping, and one child or a column of children. |
| `row`, `col` | Children side by side or stacked, with their alignment (spaced evenly too). A `row` with `"even": true` keeps its children one height, the tallest's, as answer buttons side by side do when one's words wrap. |
| `gap`, `flex`, `center` | Empty space; a child taking a share of the row (or up to a share); a child centred. |
| `t`, `tex`, `rule` | Words in one of the app's faces (body, mono, code, overline, heading), a formula, a divider. |
| `draw`, `grid`, `clip` | A recorded drawing, the engineering grid behind it (its own spacing if a game uses a finer one), a rounded corner. |
| `math` | A formula set inline in a row or column, the way a block's centred formula is set on its own line (added with Fluid Mechanics, for the two numbers under Which One to Match). |
| `answer` | An answer, tapped anywhere on what it holds. |
| `icon` | One of the few icons the games draw (only the check of a tick box so far, added with Ethics). |
| `tapdraw` | A drawing answered by tapping on it: by area, by the nearest mark, by the nearest mark measured across only (or up and down only, added with Mechanics of Materials), by the nearest line however far (added with Statics, for Which Arrow Is That, where every tap on the triangle picks the arrow it is closest to) or within a reach of its own (added with Water Resources, for What the Water Touches), or by the nearest arc within reach (added with Surveying, for Which Curve Is Sharper's two curves). With `first`, the first mark within reach wins rather than the nearest. With several picks it is drawn in layers, one per mark, so no drawing is kept for every combination of picks. |

Any value in a node may follow the round instead of being fixed: before and
after the answer; the state of the answer it sits in (idle, picked, right,
wrong, or which slot it was picked into); what is picked in a slot; which
place an answer was picked in; or which answer is picked. That one rule is
what lets a fill turn ember when picked, a slot show the factor put in it,
or a row show the number it was picked as. A node's child can follow the
round too, and be nothing for now. The full list is at the top of
`mobile/lib/features/packs/games/screen_nodes.dart`, and the adapters write
nodes with the helpers in `mobile/test/packs/nodes.dart`. Why nodes and not
more blocks: [ADR 0032](../adr/0032-pack-screens-as-widget-nodes.md).

Several picks gained three settings with Statistics: `most` (no more than
this many at once), `need` (exactly this many before Lock it in), and
`order` (`list`: right only in the order picked, as Mind the Order fills
"first, minus second"; `slots`: each pick fills the first empty slot and a
tap on a picked one empties its slot, as What Gets Weighted gives one column
each role). A round may also name its own verdict (`right`), for a game
whose title changes with the answer, and since Materials (2026-10-27) its
verdict for a miss as one per answer (`wrong`), for a game that names what
was picked instead ("THAT IS APPARENT SPECIFIC GRAVITY"). Words in a node
may also carry a `weight`, for a value set in bold mono.

Ethics added one more setting, `groups`: answers in a group are one choice,
so picking one replaces the other and picking it again keeps it. Grounds, or
Not asks four yes-or-no questions in one round, each question's Yes and No
a group, with `need` set to the number of questions.

Statics (2026-10-27) added a ranking: Rank Them by Stiffness has three
sections tapped stiffest first, each numbered as it is tapped. Its rounds
are several picks with `order: list`, `need` set to the number of sections,
and `trim`: tapping a picked answer again takes it back along with every
pick after it. Its drawing follows the whole order (a `tapdraw` with `"by":
"order"`, one drawing per order the picks can be in), since the number on
each section depends on what was tapped before it.

Statics also draws its cross sections in world units, y up, and moves each
onto the screen with a matrix (`Path.transform`). The figures' path shim
keeps that as a move of its own (`T`, the 16 numbers of the matrix), so a
recorded section is moved exactly as it was drawn, and the builder keeps
those numbers a hundred million times closer than a pixel, since the
matrix's scale multiplies every point of the shape. Two builder fixes came
with it: a shape the search saw at only one width (a dash cut short for a
third of a pixel of width) is searched again end to end, and a bend in a
number is placed from lines through widths well inside each straight piece,
not the ones beside the bend.

A concept sheet's picture may now be a **row** of pictures side by side,
any number with the same gap between (Which Way Does It Point's three tails),
besides one picture, a pair, or a column of those.

Surveying (2026-10-28) lays some sheet pictures out with a small widget of
its own (two full width pictures stacked, for drawings whose labels collide
at half width). The builder reads any such widget by what it builds, so it
arrives in the pack as the plain column it is; nothing new on the phone.
The Surveying figures (bearings, leveling, areas) draw their paths through
the recording path shim, as the Statics figures do, so a recorded curve is
rebuilt move for move rather than traced.

Surveying also added two ways to tap a drawing and
changed one sheet helper:

- **An arc to tap.** Which Curve Is Sharper is answered by tapping one of
  two curves fitted into the same corner: the nearer curve within 24 pixels
  of the tap, measured to the arc itself, or to the end of the arc on the
  tap's side once the tap is past it. A `tapdraw` target may now be an arc,
  recorded as the game draws its curve (`drawArc`), with the reach as the
  paint's stroke width. The game's curves are found by `AlignPainter.arcOf`,
  made public for it.
- **The first mark, not the nearest** (`"first": true`). Where Does That
  Pair Land, Where It Flattens Out, Find It on the Plan, Which Length Is
  Which and Which Course Takes the Most check their marks in order and
  take the first in reach (25 or 26 pixels), not the nearest. The two differ only where
  two points sit closer than twice the reach, so the pack says which rule
  the game uses rather than leave it to chance.
- **Stacked sheet pictures.** The Surveying sheets' stacking widget is
  now a function that returns the plain column it built, so the builder
  reads it directly; the pictures drew the same to the pixel before and
  after.

Mechanics of Materials (2026-10-28) added two things a recording keeps
and one way to tap:

- **Two paths combined** (`["X", operation, movesA, movesB]`, a path
  move). Which Area Twists It shades a tube's metal as its outside less
  its bore (`Path.combine`). A combined path could only be traced, which
  turns a circle into a polygon. The path shim now has its own
  `Path.combine`, which notes both paths' moves, and the player rebuilds
  the two paths and combines them the same way. On a phone it is
  Flutter's `Path.combine`, nothing else.
- **A dashed outline** (`["pdash", fill, moves, on, every, paint]`). The
  same game dashes the middle of the tube's wall, a circle or a square,
  by cutting the path into pieces along its length. Each piece of a
  circle is a curve that could only be traced, a different one at every
  width. A figure that dashes an outline through `drawPathDashes`
  (`figure_dash.dart`) is recorded as the path once, and the player runs
  the figure's own loop on it, as `drawDashes` does for a straight line.
- **Up and down only** (`"axis": "y"` on a `tapdraw`). Which Fiber Is
  Worst marks five layers across a beam's section and takes the layer
  nearest the tap measured up and down only, within 26 pixels, since a
  layer runs the width of the section. The other way round from
  `"axis": "x"`.

Structural, first half (2026-10-28: determinacy, truss methods, virtual
work, indeterminate beams, design loads, influence lines) needed nothing
new. All fourteen games are the one screen the surveying panel games use:
a drawing in a white panel, a formula under it, plain answer rows. Where
Do You Take Moments lights the point as it is picked, so its panel holds a
drawing per pick (`perPick`). Its figures now draw through the path and
text shims; two private names became public for the adapters (the truss
in Joints or Sections, and how many load rows sets the panel's height in
Which One Controls). Every built-in Structural screen hashed the same
before and after. The fourteen games are 3.5 to 17 KB to download, about
7 KB on average.

One builder fix came with it: **a bend on a width looked at.** How Much
Comes Off draws two hatched squares that grow with the width until, at
exactly 300 wide, the height stops them. The builder placed that bend
where the lines either side of it meet, 299.99998, because the hatching
starts from a path's bounds, which the engine keeps in single precision,
so neither line is exact. On a 320 phone every hatch line lands on a
whole pixel, and the hundred-thousandth of a pixel was enough to move
thousands of them a shade or two. Where a width looked at sits within a
hundredth of a pixel of the meeting and, taken with its own value as the
corner, fits every value closer, it is the corner instead. Keeping the
figure closer (`closer`) also matched, but cost 1.6 MB.

Structural, second half (2026-10-28: Where Do You Park It, the
reinforced concrete beams and columns, the steel beams, columns and
tension members) needed nothing new on the phone or in the builder. All
fourteen share one screen: the problem, then either a drawing in a
bordered panel with a formula under it, or once answered a cream box of
two formulas, then plain answer rows. That is the plain blocks plus one
`box` node (`mobile/test/packs/structural_b.dart`). Three files now draw
through the shims: the steel figures (the column's buckled bows are
quadratic curves, and traced they cost Which Axis Wins Now 800 KB to
download, 3.6 KB kept as moves), the reinforced concrete figures (a
traced square to clip the hatch to came back with corners a float32 hair
off, a different one at nearly every width) and the Structural sheet
pictures (their own labels were a plain text painter, which cannot be
recorded). The two column cage sheets are kept closer (`closer`): their
hatch, fitted to a section whose edges sit on float32 bounds, drew three
lines a few shades off across a pair's width at the plain tolerance,
about 600 pixels, over ADR 0031's share. Every
round drawing of the fourteen games and every picture on all 28
Structural sheets hashed the same before and after, at eight widths, day
and night.

Transportation, first half (2026-10-28: stopping sight distance and the
peak hour, vertical and horizontal curves, superelevation, signal
timing, traffic flow, heavy vehicles) needed nothing new on the phone or
in the builder. All fourteen games are the screen Per Million What has
had since phase 0 (`pickOne` in `mobile/test/packs/pick_one_adapter.dart`),
so `mobile/test/packs/transportation_a.dart` only names each game's
rounds, painter, panel height and words. Two figure files now draw
through the path shim (the vertical curve and traffic flow figures);
the curve figures share the alignment figures with Surveying, which were
already shimmed. Every round drawing of the five games those two files
serve, Per Million What's, and the six sheet pictures they draw hashed
the same before and after, at eight widths, day and night. The fourteen
games are 3.6 to 104 KB to download, about 15 KB on average. Crest or
Sag is the large one: its car sits on a hump whose height at the car is a
square of a fraction of the width, so the car, its headlight beam and the
beam's label follow a curve in the width that is kept as a line with many
bends. How Much Bank (49 KB) turns its car to the pavement's tilt, a fixed
drop over a run of the width less 46; the slope angle form misses it
because it scales the run to start at one, and this run is negative at
width zero. Both are well under the ceiling, so neither was changed.

Transportation, second half (2026-10-28: capacity and level of service,
the four step and gravity models, signs and signal warrants, flexible
pavement, earthwork in yards, rigid pavement) needed nothing new on the
phone or in the builder. All fourteen games are the one screen: the
problem, a drawing in a white panel, the answers as plain rows
(`mobile/test/packs/transportation_b.dart`). Two things were found:

- **Labels written with Flutter's own text painter.** The sign, flexible
  pavement and rigid pavement figures write some labels straight onto a
  colored face, with a plain `TextPainter` rather than `writeOn`, which
  the recorder cannot read (the build stops on "text drawn with a plain
  TextPainter"). They now use the text shim.
- **A traced rectangle.** A guide sign is a path made with `addRect`.
  Traced, its fill and two pixel border drew about 600 pixels up to six
  shades off around the edge on every phone, over ADR 0031's share. The
  sign figures now draw through the path shim, which keeps the rectangle
  as one move.

Every round drawing of the fourteen games and every Transportation sheet
picture hashed the same before and after, at eight widths, day and night.
The fourteen games are 3.9 to 8 KB to download, 5 KB on average.

Water Resources, first half (2026-10-28: open channels and Manning's,
specific energy and the jump, weirs and Hazen-Williams, pumps, the
rational method and curve numbers, unit hydrographs and the time of
concentration; `mobile/test/packs/water_a.dart`). Fourteen of the
sixteen games are the panel screen: the problem, one drawing (or two,
each bordered forest once it wins) in the white panel, a formula, the
plain answer rows. Which Formula Fits This Weir's answers are the
formulas themselves, answer nodes holding a `math`. What the Water
Touches is answered on the drawing, and needed two things:

- **A line with a reach.** The game measures a tap to each piece of the
  channel's boundary (the bed, each wall up to the water, the surface,
  each dry wall above it) and takes the nearest within 22 pixels. A
  `tapdraw` line target was the nearest line however far, which Which
  Arrow Is That needs; with `"reach": "stroke"` on the node it keeps to
  its paint's stroke width (`Paint()..strokeWidth = 22`), and without it
  stays however far, so Which Arrow Is That records and plays as before
  (its parity passed again, unchanged). (It first followed any stroke
  width a line had; Mathematics' Tap the Side brought the flag, and the
  two were joined on it.) The pieces share their corners, so
  the parity check and the simulator script now tap a line at its middle
  rather than its first end; a tap at a shared corner picked the piece
  before it.
- **Six answers, whatever the channel.** The game's answers are the six
  pieces a boundary can have (the bed, each wet wall, the surface, each
  dry wall), and a channel with no freeboard has no dry wall to tap. The
  pack keeps all six as the answers and maps each drawn piece to its
  own (`hits`), so the answer is the same number as the game's; it first
  listed only the pieces drawn, which numbered the answers differently
  on such a channel (the pack audit caught it). The parity check skips a
  wrong answer that has no mark and nothing else on screen to tap.
- **Layers.** `SectionPainter` paints in three public pieces now
  (`paintSection`, `paintPiece`, `paintNotes`), called in the same order
  as before. The pack keeps the section and its words once a round and
  each piece for picked and answered, rather than the whole section once
  per piece.
- **A hatched shape** (`["hatch", fill, moves, step, slope, paint]`).
  The figures hatch a channel's lining and a weir's plate with
  `hatchIn` (`figure_ink.dart`), which starts every line from the bounds
  of the path, numbers the engine keeps in single precision. Recorded
  line by line, each end was that single precision number plus a double
  one, which no straight line in the width lands on exactly; a hundred
  thousandth of a pixel moved the V-notch plate's hatching two shades on
  hundreds of pixels at a 390 phone, and keeping it closer (a ten
  millionth) took Which One Runs Faster to 5.5 MB. While
  `recordHatches` is on (`figure_hatch.dart`), a hatch is recorded as the
  shape once and the player runs the figure's own loop on it, taking the
  bounds from the same path, as `drawPathDashes` does for a dashed
  outline. It is off unless a game asks: the Water Resources adapters
  turn it on (`_hatched` in `water_a.dart`), so every game recorded
  before records the same. On a phone `hatchIn` runs the same loop it
  always did, moved into `hatches`.

The figures' files now draw through the shims: the channel, flow, weir,
main and hydrograph figures through the path shim (the weir plate is a
rectangle less its notch, `Path.combine`), and the Water Resources sheet
pictures through both, since the sheets' own painters (the two rulers,
the row of notches, the peak bars) wrote their labels with a plain
`TextPainter`. Nothing is kept closer than plain.

One builder fix: a bend moved to where its two pieces' lines meet was
then checked against the next bend while that one still sat on its width
looked at, a hair up the piece after it, so a width looked at just
before the meeting seemed to fit closer and was kept instead. What the
Water Touches' wide swale stops growing at exactly 342 and the bend was
kept at 341.9998, every height of the section and its dimension line
0.00003 of a pixel off from there to 870 (554 pixels four shades out on a
430 phone). Every bend now moves to its meeting first, and only then is
a width looked at near the meeting tried in its place.
Every round drawing of the sixteen games, every Water Resources sheet
picture (the sheets of all 32 games, both halves of the chapter) and
Filling or Emptying's pond, which shares the hydrograph figures, hashed the same
before and after, at eight widths, day and night.
The fix changed the recording of 31 games in other chapters (and, with
the hatch step, six of the sixteen here); every one passed parity again,
and the only screens still differing (Which Rate's sheet, one to seven
pixels) differ the same with the old builder. The sixteen games are 4.3
to 30 KB to download, 8.6 KB on average.

Water Resources, second half (2026-10-28: storage routing, groundwater
and wells, BOD, clarifiers and activated sludge, chlorine, filters, the
drinking water standards) needed one new recorded step. All sixteen games
are one screen: the problem, a drawing in a white panel, mostly a formula
under it, then the answers as plain rows
(`mobile/test/packs/water_b.dart`). Which Well Formula's two answers are
the formulas themselves, so they are `answer` nodes holding a formula
rather than the plain rows. What was found:

- **Soil grains** (`["grains", left, top, right, bottom, porosity, seed,
  fill, edge]`). Which Speed Is That packs a block of aquifer with grains:
  circles placed by a seeded random walk until they cover the share of
  the block that is not void. A wider block takes more grains, so the
  recording changed every couple of pixels of width, and the game came
  to 44 MB to download. A figure that draws grains through `drawGrains`
  (`lib/features/packs/drawing/figure_grains.dart`) is recorded as the
  block and its porosity once, and the player runs the figure's own loop
  on them, as `drawDashes` does for a dashed line: 3.6 KB. On a phone's
  real canvas `drawGrains` is the same loop the figure had.
- **Traced curves.** The aquifer cone, the BOD curve and the plant loops
  were plain paths, traced at every width: Which Well Formula came to
  130 KB and the BOD games took a quarter of an hour each to record. The
  aquifer, BOD, clarifier and chlorine figures now draw through the path
  shim (Which Well Formula 16 KB).
- **Sheet labels with Flutter's own text painter.** The Water Resources
  sheet pictures write their labels with a plain `TextPainter`, which
  the recorder cannot read (What Moves the Ratio's sheet stopped the
  build). The sheet pictures now draw through the text and path shims.

Every round drawing of the sixteen games and every Water Resources sheet
picture (both halves of the chapter) hashed the same before and after, at
eight widths, day and night. The sixteen games are 3.6 to 20 KB to
download, about 8.5 KB on average.

Geotechnical, first half (2026-10-28: phase relations, classification,
effective stress, consolidation, shear strength, seepage and the infinite
slope) needed nothing new on the phone or in the builder. All eighteen
games are the Structural screen: the problem, a drawing in a white panel,
a formula centred under it, and the answers as plain rows
(`mobile/test/packs/geotech_a.dart`). Over What shows its formula only
once answered, since the formula is the answer; the gaps around it stay
either way, so it is a `math` block with `when: done`. One thing was
found:

- **Sheet labels written with a plain text painter.** The Geotechnical
  sheet pictures (`geotechnical_pictures.dart`) build their own labels
  with Flutter's `TextPainter` and hand them to `inkLabel`, which the
  recorder cannot read (the build stops on "text drawn with a plain
  TextPainter" at the first sheet, When Does It Simplify's scale and
  ruler). The file now uses the text and path shims. Five figure files
  (classification, effective stress, consolidation, seepage, slope) also
  draw their paths through the path shim, so a rectangle to hatch or a
  grading curve is kept move for move rather than traced.

Every round drawing of the eighteen games, of the two other games that
share the slope figures (After the Rain, What Holds the Wedge) and every
picture on all 35 Geotechnical sheets hashed the same before and after,
at eight widths, day and night (4,400 images). The eighteen games are 3.3
to 53 KB to download, about 9.6 KB on average. How Long Does It Take is
the large one (53 KB): its drainage arrows, one every 26 pixels across
the clay, each end in an arrowhead drawn as its own small path, and the
pack keeps those paths one by one (about 280 of them in a round's
drawing, across its bands). Well under the ceiling, so it was left.
Three built-in games set a formula wider than a small phone, and the
pack copies them exactly (to fix after the move): Which Fork First (78
pixels over at 320, 8 at 390), Above or Below the Line (53 at 320) and
Drained or Not (101 at 320, 31 at 390).

Geotechnical, second half (2026-10-28: slope stability, bearing
capacity, lateral earth pressure, retaining walls, compaction and
stabilization, deep foundations) needed nothing new on the phone or in
the builder. All seventeen games are one screen: the problem, a drawing
in a white panel, in eight of them a formula centred under it (three
show it only once answered, `"when": "done"`), then plain answer rows
(`mobile/test/packs/geotech_b.dart`). Two things were found:

- **A traced curve that never finishes.** Wetter Is Not Denser draws its
  Proctor curve as a path of 61 short lines. Traced, the walk along the
  path finds a different set of corners at nearly every width, so the
  builder split the drawing into a band per width and had not finished
  one round after half an hour. Through the path shim the same curve is
  its 61 moves, and the round records in under two seconds. The slope,
  earth pressure, wall stability, compaction and pile figures now all
  draw through the path shim (the bearing figures build no paths).
- **Sheet labels set with a plain text painter.** The Geotechnical sheet
  pictures lay out their own labels (`_text`, then `inkLabel`), which
  the recorder cannot read. That file now uses the text and path shims,
  as the Structural sheet pictures do.

Every round drawing of the seventeen games and of Steeper Than Its
Friction (which shares the slope figures), and every one of the 35
Geotechnical sheet pictures, hashed the same before and after, at eight
widths for the rounds and five for the sheets, day and night (3,806
images). The seventeen games are 3.6 to 7.2 KB to download, 5.2 KB on
average. All 102 parity screens matched to the pixel. Which Term Drops
Out's bearing capacity formula runs 27 pixels past the edge on a 320
phone in the built-in game; the pack copies that exactly, and it is
noted to fix after the chapter passes.

Mathematics, first half (2026-10-28: straight lines and quadratics,
logarithms, right triangle trig, the laws of sines and cosines, the unit
circle and identities, circles and conics, derivative rules, applications
of derivatives; adapters in `mobile/test/packs/mathematics_a.dart`) is
the chapter where hardly two games share a layout: a slope you flip and
negate, a formula built in slots, a dot put on a grid of 169 points, a
marker dragged along a curve, a check list with a "none of these". All
24 are screen nodes. What the phone gained:

- **Words and boxes.** A box may have a least and most width and a least
  height (`minw`, `maxw`, `minh`), and be a circle (`"shape": "circle"`).
  Words may ask the face for its own weight (`fw`, which picks a
  different face from setting the weight after, as a game's `AppTheme`
  call does), a heading may set its line height (`line`), and words may
  stop after some lines without an ellipsis (`max`). A formula may sit to
  one side of its box (`align`) and may keep its own size rather than
  shrink to fit (`"fit": false`); an inline formula may set its line
  height. New nodes: `wrap` (children that run onto the next line, with
  their spacing), `fade` (a child at some opacity, as a placed chip dims)
  and `slot` (a slot of a formula built in slots, tapped to empty it).
  The `close` icon joins `check`.
- **Answers.** An answer may be switched off by a value (`off`, as a chip
  already placed cannot be placed again), or be tapped with no ink at all
  (`"plain": true`), as games built on a bare tap handler are: a piece of
  a formula tapped where it stands, a number on a balance. The player
  gives each plain answer the key `answer-<i>`.
- **Values that follow the round.** Before, after a right answer and
  after a wrong one (`open`, `won`, `lost`); what is picked, keyed by the
  picks in order or sorted (`picks`, with `else`); whether an answer is
  picked at all, answered or not (`on`, `off`), as a check box stays
  ember on a ticked rule after the answer is out. A feedback block may
  name its own verdict and why as values.
- **Drawings tapped.** A `tapdraw` may be as tall as it is wide (`"h":
  "w"`, Place the Center's square grid), may be dragged across as well as
  tapped (`"drag": true`, Slide to the Flat Spot's marker, with `"axis":
  "x"` so the nearest whole number wins however high the finger is), may
  have areas of any shape as targets (a recorded path: Quadrant Signs'
  quarters of a disc, clear of the axes), and may take a line only within
  its paint's stroke width (`"reach": "stroke"`, Tap the Side's sides,
  60 wide). Layers may follow the round as any value does and come out as
  nothing, and a layer may be one drawing moved onto whichever mark is
  picked (`"moved": true`): Place the Center records its dot once, not
  once per point.
- **Rounds.** A game may name its button (`lock`: "Lock the order",
  "Confirm this line"). A round may start with an answer already picked
  (`start`, where the marker stands before it is moved), be locked in at
  any time (`any`) or once anything was tapped (`touched`, Every Rule,
  where tapping a rule off again still counts). Slots (`order: slots`)
  may keep a placed answer where it is until its slot is tapped (`keep`),
  let one answer fill several slots (`reuse`), and accept other orders
  besides the answer (`also`, as either side of a sum may come first). An
  answer that stands alone may stay picked when tapped again (`stay`,
  Every Rule's "Just the table").

Four new recorded steps, each one step where the figure's own arithmetic
made thousands of numbers, and each on a real canvas the figure's own
arithmetic in its own order, so the built-in screens did not change:

- **A parabola** (`["para", width, vx, vy, arm, half, ±1, step, paint]`,
  `figure_parabola.dart`). Discriminant Gate's curves are a point every
  three pixels of width; recorded point by point a curve gained a point
  every three pixels and was a different drawing at every width.
- **A label beside a side** (`["beside", ax, ay, bx, by, cx, cy, by,
  turned]`), **an angle's arc** (`["carc", x, y, px, py, qx, qy, radius,
  unit, paint]`) and **a label pushed off a corner** (`["ptext", ...,
  ["push", x, y, ax, ay, by] or ["half", x, y, px, py, qx, qy, by], half
  width, half height, ...]`), all in `figure_corner.dart`. The right
  and oblique triangle figures place a side's name 17 pixels off its
  middle along a direction scaled to unit length, turned to the side, an
  angle's arc between two such directions and its name out along the
  line halving them. Every one of those numbers divides by a length that
  grows with the width, so each kept a line with thousands of bends:
  Which Ratio and Which Law were each 650 KB to download, Tap the Side
  160 KB, Set It Up 42 KB. Kept as the points the figure starts from,
  which are straight lines in the width, they are 2.5 to 3 KB.

One adapter fix of the same kind needed nothing new: Slide to the Flat
Spot's tangent is 42 pixels each way along a unit direction, 650 KB as
recorded. The adapter records it as a short upright line on a canvas
moved to the tangent's middle and turned a quarter less than the
tangent, so the turn's run is the tangent's height, which does not
follow the width, and the existing slope angle form keeps it: 24 KB.

On the built-in side, six Mathematics figure files draw through the text
and path shims, Perpendicular Flip's dashes through `drawDashes`, the
discriminant parabolas through `drawParabola`, the triangle labels and
arcs through `figure_corner.dart`, and two painters became public for the
adapters (Perpendicular Flip's lines, Sign the Bend's arcs). Every round
of every Mathematics game (first screen, a played round and the concept
sheet, day and night) and every affected painter at several sizes hashed
the same before and after each change.

The 24 games are 2.5 to 29 KB to download, about 5.8 KB on average.
Sign the Bend (29 KB) and Slide to the Flat Spot (24 KB) are the large
ones: each round's curve is 241 points, drawn before and after.

Built-in flaws copied as they are: Discriminant Gate has two rounds with
the same words; Tap the Side takes a side within 60 pixels exactly as the
game does (`< 60` in the game, the same reach in the pack, so only a tap
at exactly 60 could differ). Slide to the Flat Spot rounds the finger to
the nearest whole number, a half up; a `tapdraw` took the first of two
circles as near, so it now takes the later with `"tie": "last"`, and a
tap exactly halfway picks the same spot in both. The second half's
spreadsheet cells and formula pieces are bare tap areas with no ripple
(`plain` answers, which may now carry their own `key`), as the built-in
games' are.

The two halves were built side by side and taught the renderer some of
the same things under different names (a fade, a wrap, a slot tapped
empty, a value by how the round ended or whether an answer is picked).
They were joined on the first half's names, so each is one node or one
value; the second half's node helpers in `nodes.dart` write those names.

Mathematics, second half (2026-10-28: integrals, l'Hopital's rule,
vectors, the dot and cross products, spreadsheets, programming and
numerical methods) were among the first games built, each laid out its
own way, so every screen is written as screen nodes
(`mobile/test/packs/mathematics_b.dart`). Four of the 24 play in ways no
earlier game did, and the renderer learned each:

- **A run of moves** (`steps` on a round). Run the Loop is played move
  by move: the right move goes on to the next step, the last right move
  finishes the round, and any wrong one ends it there. Each step has its
  right move (`answer`) and its own why for every wrong one (`why`, one
  per answer, used as the feedback). There is no Lock it in: the button
  reads the game's `button` words and stays off. A value may follow the
  step (`{"step": [one per step]}`), and the buttons show the right move
  for the step the round stopped at and the wrong one taken.
  `{"open", "won", "lost"}` follows how the round ended, for
  "THE LIMIT IS" shown only after a finished loop.
- **A pick worked with buttons** (`start` on a round, and a `step` node).
  Stretch It to Fit's multiplier starts at one and is moved by a minus
  and a plus button, kept to the answers there are. `start` is what is
  picked before anything is touched (so Lock it in is on from the
  start), and a `step` node is a button that moves the pick by `by`. The
  arrow is a layer of its own over the grid, one recorded per multiplier
  (a `draw` node may hold `layers`, each a value that may be nothing).
- **Rows filled in turn** (`"order": "fill"`, several picks). Fill the
  Trace drops each tapped value into the first empty row, the same value
  as often as it is tapped, and a filled row is emptied by tapping it
  (a `slot` node, keyed `slot-k` as the built-in rows are). Lock it
  in waits for every row, and the round is right when each row holds its
  own value. `{"fill": k, ...}` follows how row k stands: the next to
  fill, filled, empty, or once answered right or wrong.
- **One mark of 169, pinned** (`pin` layers on a `tapdraw`, and `"axis":
  "box"`). Land the Resultant is answered by tapping one point of a 13 by
  13 lattice, the point the tap rounds to. A drawing per pick would be
  169 drawings a round; instead the ring that marks a point is recorded
  once, around the origin, and the phone draws it on the picked point
  (`"at": "pick"`, ember, then red if wrong) and the right one (`"at":
  "truth"`, forest). `"axis": "box"` measures a tap by the larger of
  across and up, which with the outer of two equally near points first is
  exactly rounding to the lattice. Where the Shadow Falls pins the same
  ring to the marks along its member.

Smaller additions: a `box` may have a least width and height (`minw`,
`minh`) and a border on its top and left only (`"edge": "topLeft"`, a
table cell); a `row` may be as narrow as what it holds (`"size": "min"`);
a formula may be set to the left and left at its own size (`align`,
`"fit": false`); a heading may set its own line height; the nodes `fade`
(a child at an opacity, which may follow the round) and `wrap`
(children in runs), and four icons (the arrows up and down a slope, plus
and minus). `{"of": i, "on", "off"}` follows whether answer i is picked (Pick u
greys both rows while "no substitution fits" is). A round's `wrong` may
name the verdict per set of picks, keyed by the picks in order, comma
separated (Pick u says which half of the pair went wrong). Picking in a
group now clears an answer that stands alone, and beside groups an
answer that stands alone is kept when picked again, as Pick u's "no
substitution fits" is. An `answer` may carry the `key` the built-in game
gives the same button (`cell-B2`), so a test can find it in both.

Three app changes came with it, none changing a pixel: the vector, cross
product, root finding and Mathematics sheet figures draw through the
path, text and dash shims; the vector figures' ring and arrow are public
(`VectorPainter.drawMark`, `VectorPainter.drawArrow`) so a pack can
record each on its own; and Run the Loop's why for a wrong move is a
public function (`loopSlipWhy`). Every round drawing those figures serve
and every Mathematics sheet picture hashed the same before and after, at
eight widths, day and night.

Two built-in answers are a painted box under a bare tap area, not an
inked button: a spreadsheet cell in Copy It Down and a piece of the
formula in Which Happens First. Filled from underneath, as a button is,
their edges landed on part pixels a few shades differently (84 to 340
pixels a screen); so the pack paints their fill in the box itself and
leaves the button clear. The 24 games are 2.3 to 43 KB to download, 10 KB
on average; the largest are Follow the Tangent and Can It Start Here,
whose curve is redrawn for every pick.

This is still game type `pick-one` at 1.2.0: no app that reads packs has
shipped, so the type could grow before its first release. Once 1.2.0 is
out, a new kind of block is a new game type (or a new version of this one),
dated in the list below.

## The oldest app a lesson needs

`mobile/lib/features/packs/game_types.dart` lists every game type and the
app release that first had it. A lesson's `minApp` is the newest of its
games' types. The builder works it out; nobody types it by hand.

When a release adds a game type, add it to that list with the release's
version, and never change a version once that release is out. If the app is
older than a lesson's `minApp`, that lesson alone shows "Update the app to
play this lesson" (phase 2).

`mobile/test/packs/pack_versions_test.dart` is the guard: for every lesson
in every published pack it checks that `minApp` is exactly right, that every
game type it uses is dated, and that the app can play every dated type. A
version set one step too old was tried on purpose and the test failed.

The first app that reads packs is 1.2.0 (1.1.0 is the release in the
stores). If the next release ends up numbered differently, change
`firstPackApp` and the three types before it ships.

## Publishing

```sh
cd mobile && flutter test --run-skipped test/packs/build_pack_test.dart && cd ..
node scripts/publish-pack.mjs mobile/build/packs/fe-civil.json
```

The publisher checks the pack (every game in exactly one lesson, chapters
agree, versions well formed), and refuses it with the problems listed in
plain words if anything is off. If nothing changed since the latest version
it publishes nothing. Otherwise it splits the pack by chapter and writes:

- `service/packs/<exam>/<exam>.<chapter>.<hash>.json`, one chapter's games,
  for each chapter that changed. Named by its content and holding nothing
  about the version, so a chapter left alone keeps its file and the next
  version points at it again.
- `service/packs/<exam>/<exam>-v<version>-<hash>.json`, the new version's
  index: every lesson with its games and `minApp`, and every chapter's file
  with its sha256 and size.
- `service/packs/<exam>/manifest.json`, pointing at the new version and
  listing every version ever published.

Every name carries the first 12 characters of its content's sha256, and
nothing is written over an existing file. Versions 1 to 18 of FE Civil
predate the split (format 1: the whole pack in one file) and stay published
as they are.

Then copy the version into the app, so a phone with no signal has all of
it from the first open:

```sh
rm -r mobile/assets/packs/fe-civil && mkdir mobile/assets/packs/fe-civil
cp service/packs/fe-civil/<index of the new version> mobile/assets/packs/fe-civil/index.json
# and each chapter file that index names, under the same name
```

`mobile/test/packs/pack_store_test.dart` checks that the copy is a
published version byte for byte, with every chapter it names and nothing
else.

The build also stops if any game is over 250 KB to download, gzipped, or
the pack is over 25 KB a game on average (`maxGame`, `maxAverage` in
`mobile/test/packs/build_pack_test.dart`; the largest game is about 106 KB
and the average about 11 KB). The ceilings only ever stop the build: a game
over them is fixed by storing the same drawing better, never by loosening a
tolerance or drawing less, so a pack cannot lose quality to fit.

Commit the new files, the manifest and the app's copy, then deploy the
service. The server reads packs when it starts.

**A published version is never edited or deleted.** A phone may be halfway
through downloading it, or hold it offline. A fix is a new version.
`service/packs.test.js` checks every published file against the hash in its
name and fails if one changed, went missing, or if a file appears that no
listed version uses.

## The server

All public, like `/api/content`: packs are study material a guest may use
(ADR 0026).

| Request | Answer | Cached |
|---|---|---|
| `GET /api/packs` | Every exam with a pack: exam, title, format, latest version, download size | Always rechecked |
| `GET /api/packs/:exam` | The latest version: its index's name and sha256, size, size to download from nothing, every lesson's `minApp` and every chapter's file | Always rechecked (an unchanged answer costs a 304) |
| `GET /api/packs/:exam/:file` | One published index or chapter file | Forever |

The phone can tell from the second answer alone whether anything is new and
which lessons it is too old for, without downloading the pack. When a newer
version is out it fetches the index, then each chapter file it does not
already hold, checks every one against its sha256, and only then switches
to the new version. It reads a chapter from its own storage the first time
one of its games is opened; nothing is fetched then.
The server sends only the files listed versions use; anything else in the
folder is a 404.

## Open for later phases

- **Size in git.** Settled by the split (ADR 0033): a version adds only
  its changed chapters, 0.6 to 7.3 MB each. The 18 format 1 versions
  (433 MB) stay, as every published version does.
- **Pack contents.** Since version 18 (2026-10-28) the pack holds every
  game, all 375 across the 15 chapters (phase 3).
- **Choosing an exam** stays out of scope until a second pack exists.
