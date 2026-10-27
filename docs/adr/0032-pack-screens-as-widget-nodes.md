# 0032. A pack round may describe its screen as a small widget tree

**Status:** Accepted (2026-10-27)

## Context

[ADR 0030](0030-content-packs-and-game-types.md) moves every game into a
downloadable pack, one chapter at a time, and keeps new kinds of games in
the app. The first pick-one games all shared one screen. Dynamics and
Economics did not, so a round gained its own screen as a list of blocks
(`docs/mobile/content-packs.md`, "A round laid out as its own screen"):
`text`, `box`, `figure`, `tiles`, `bars`, `panels`, `tap` and so on, each
block a piece of layout that the app knows how to build.

That worked while each new block served several games. Statistics broke the
pattern. Its 19 games share almost nothing beyond the overline and the
verdict:

- Which Line Do You Read answers on a calculator's dark readout, each line
  an answer, with a bar drawn over the x of x-bar.
- What Gets Weighted answers by tapping the headings of a table, the first
  tap giving a column one role and the second the other, each column tinted
  by its role.
- Build the Binomial has a formula with three empty slots that fill, in the
  order they were picked, with the factors chosen below.
- Mind the Order numbers each picked row 1 or 2 and drops its value into
  "first minus second".
- Read It Off the Line is a dot plot where any number of ticks are tapped.
- Most of the rest are a drawing that changes with the pick, over a row of
  buttons in one of four different styles.

Counted game by game, blocks would have meant about twelve new ones, nearly
all used by a single game, and the next chapters (Ethics, Fluid Mechanics,
then eleven more) will bring their own one-offs. Each new block is app code
that must be released before any pack can use it.

## Decision

A block may be a **node**: a small widget tree using the same widgets the
built-in games are written with (box, row, column, gap, flex, centre, words,
formula, drawing, grid, clip, divider, answer, a drawing answered by tapping
on it). Any value in a node may follow the round instead of being fixed:
before and after the answer, the state of the answer it sits in, which slot
an answer was picked into, what is in a slot, which answer is picked. A
node's child may follow the round as well.

The existing blocks stay. Nodes are for layouts the blocks do not cover,
and a chapter whose games all fit the blocks keeps using them.

## Consequences

- All 19 Statistics games moved with no new block and no game-specific app
  code. What was added to the app is general: the node kinds, the ways a
  value follows the round, three settings on several picks (`most`, `need`,
  `order`), a round's own verdict, and a row of pictures on a concept sheet.
- A future chapter's one-off layout is usually a pack change only. The
  owner's goal of FE Civil fully served from the server is reached sooner,
  and with less app code to keep in step with packs.
- Nodes describe widgets, not intentions. A pack written with nodes says
  "an ember box 54 high" rather than "an answer button", so a later restyle
  of the answer buttons in the app would not reach node games until their
  packs are rebuilt. The adapters build nodes from shared helpers
  (`mobile/test/packs/nodes.dart`), so a restyle is one helper changed and
  the pack published again.
- The parity check (check 1 of the migration plan, at the bar of
  [ADR 0031](0031-pack-drawings-match-to-sampling-not-bits.md)) still
  compares every screen of every round with the built-in game, so a node
  tree that drifts from the original fails the same way a block would.

## Alternatives considered

- **A block per layout.** The way Dynamics and Economics went. About twelve
  blocks for Statistics alone, most used once, each one an app change.
- **A new game type per Statistics game.** The most faithful and the most
  code: nineteen screens written twice, once in the built-in game and once
  in the pack reader, which is the duplication packs exist to end.
- **Ship a general layout language (a server-driven UI framework).** Far
  more than is needed. The nodes are the dozen widgets the games already
  use, read by about 350 lines of app code that the parity check covers.
