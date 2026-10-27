# Moving FE Civil onto content packs

Plan for carrying out [ADR 0030](../adr/0030-content-packs-and-game-types.md).
Written 2026-10-26. Status: phases 0 to 2 done (2026-10-26 and 27); phase 3 under way,
Construction and Dynamics moved but not switched on (2026-10-27); records in
`content-packs-checks/`, and how packs work as built in
[content-packs.md](content-packs.md).

The goal: the phone app holds only the kinds of games (how a round is
played) and the tools to draw. Everything that belongs to FE Civil itself
(the chapters, the concept sheets, every round and every drawing) moves into
a pack the app downloads. Students must not notice the move. Then the PE
starts as a second pack.

## The rule this plan answers to

Learning and the student's experience come first (ADR 0030, section 1).
Every phase below ends with checks, and these are checked at every phase,
not just at the end:

1. **Every game plays exactly as it does today.** Same rounds, same
   wording, same drawing, same feedback, day and night. The test is a
   picture comparison of every round, before and after answering, in
   both themes.
2. **No progress is lost.** Game ids stay the same, so cleared rounds,
   the Daily, badges, challenges and a guest's saved rounds all keep
   working without a migration.
3. **The first open never waits on a download.** The app carries a copy
   of the FE Civil pack inside it, so a new student can study straight
   away, offline. Updates arrive quietly in the background.
4. **An update never interrupts a round.** A new pack version takes
   effect the next time the student opens a lesson.
5. **No technical words reach the student.** They see "Update the app to
   play this lesson", never a version number or the word "pack".
6. **Every game and every concept sheet is checked, one by one,** against
   how it worked before the move. The full check is in "How every game and
   concept sheet is checked" below. Nothing is switched on until all of it
   passes.

## How every game and concept sheet is checked

Looking the same is not enough; a game also has to behave the same. Each
of the 375 games and every concept sheet gets all of these checks, run
against the built-in version as the reference:

1. **Looks the same.** Picture comparison of every round, before and after
   answering, every tappable spot, day and night.
2. **Plays the same.** An automatic play-through of every round answers it
   right, then wrong, with every wrong option. Each time it must give the
   same verdict, the same feedback wording, and the same "this one comes
   back" behavior for a miss.
3. **Records the same.** The same answer is sent to the server under the
   same game id and source problem, so mastery, the Daily, badges,
   challenges and a guest's saved rounds see no difference.
4. **The concept sheet reads the same.** Every sheet's text, formulas and
   pictures compared with the built-in sheet, and reachable from the same
   games.
5. **The game checks still pass.** The existing item checks (the game
   audit) run on the pack version of every game.
6. **A person plays it.** The owner plays each chapter on his phone before
   it is switched on.
7. **Real students confirm it.** After release, each game's completion and
   accuracy are compared with the weeks before the move. A game whose
   numbers drop is investigated before the built-in copy is removed.

A written record of the results is kept per chapter in
`docs/mobile/content-packs-checks/`, so it is clear what was checked and
when.

**About "or better".** The move itself changes nothing on purpose. If a
game were improved during the move, the comparison could no longer tell an
improvement from a breakage. Anything worth improving that is noticed
during the move goes on that chapter's record as a note, and is done right
after the chapter passes, as its own change, checked the normal way.

## What was measured (2026-10-26)

**The games.**

- There are 375 games across 15 chapters, with 2,269 rounds between them.
- Each game file holds everything about that game: its rounds, its
  question wording, its feedback and its screen. About 4.3 MB of source.
- The rounds are already kept apart from the rest. 366 of the 375 games
  keep all their rounds in one list at the top of the file, so lifting
  them out is mechanical, not a rewrite.
- All 375 already share one frame (the board: round counter, the button,
  feedback, the done screen). Nothing about that changes.

**How students answer.** A first pass by pattern, to be confirmed by hand
in phase 0:

| How a round is answered | Games, roughly |
|---|---|
| Pick one answer from a list | 280 |
| Choose between two (holds or fails, above or below) | 40 |
| Tap a spot on the drawing | 33 |
| Mark each row true or false | 15 |
| Pick all that apply | 10 |
| Put steps in order, or fill slots | 8 |
| One of a kind (build a line with moves, step a value) | 10 or so |

So the 375 games likely need **about 10 to 14 game types** in the app.
The one-of-a-kind games each stay their own game type. That is the ADR
working as intended, not a problem to remove.

**The drawings.** This is the part that makes the games feel hand-made,
and the part that needs the most care.

- 341 drawing routines, about 1.8 MB of source, plus shared drafting
  conventions (which view, solid material, water surfaces).
- They draw with plain shapes: lines, paths, rectangles, circles and arcs.
- Each drawing is computed from the round's own numbers, and most change
  once the student answers (the answer is revealed on the drawing).
- None of them are animated over time. That makes them much easier to
  move.

**Also built into the app today.** The concept sheets (about 580 KB of
text) and the catalog of chapters, lessons and games (about 140 KB). Both
are plain content and move into the pack first.

**Today's app.** The Android upload is 97 MB, the last measured iPhone
build 28 MB. The plan measures how much of that the games account for in
phase 0, so the gain is a number, not a guess.

## The key idea: authoring stays the same, only where it runs moves

Today a game is written in Dart and compiled into the app. After the move
it is still written the same way, in the same language, by the same
people, with the same freedom. The difference is that it lives in a
separate **pack builder**, not in the app.

The builder runs every game's rounds and drawing routines on our side and
writes out the pack:

- the catalog, the concept sheets and every round as data;
- every drawing, recorded shape by shape for each state it can be in
  (before answering, after answering, each spot that can be tapped), as a
  small drawing file.

The app gets one **drawing player** that replays those files with the
current theme's colors. Because the builder records the exact drawing
routine we have today, the drawings come out identical. Nobody redraws
anything by hand.

Why this approach:

- Writing a game stays as creative as it is now. Any drawing we can code
  today we can still code, and it costs the app nothing.
- New games for the PE are written exactly like the FE Civil games.
- If a drawing ever needs something the player cannot replay (true
  animation, a drawing that follows a finger), that becomes a new
  ability in the app, shipped in an app release, which is exactly what
  ADR 0030 section 4 allows.

## Phases

### Phase 0. Prove it on three games

Pick three games that cover the hard cases:

- **Per Million What** (Transportation): pick one answer, drawing
  changes on answer.
- One **tap the drawing** game: needs tappable spots recorded with the
  drawing.
- One **put in order** game: a different interaction entirely.

Build the smallest working version of the builder, the drawing player and
those three game types.

Done when:

- Every round of all three looks identical before and after the move,
  day and night, by picture comparison.
- The recorded drawings keep the right colors in dark mode and keep text
  sharp.
- We know the size of the three games' content, and so roughly the size
  of the whole FE Civil pack.
- The interaction count above is confirmed by reading the games, giving
  the real list of game types.

If the drawing recording cannot match the current drawings exactly, stop
and bring the owner one recommendation before going further.

### Phase 1. The pack and the server

- Define the pack: a list of contents with the exam's name, the pack
  version, its size, and for every lesson the oldest app version that can
  play it.
- The server publishes packs as fixed files that never change once
  published. A new version is a new file, so a phone mid-download never
  gets a mix of two versions.
- A test checks every lesson's game types against the app version that
  introduced each type (the guard from ADR 0030).

### Phase 2. The app learns to play packs

Behind a developer switch, invisible to students:

- Download, store and update packs, and read them offline.
- The drawing player.
- The game types, built from the existing games' screens so they look
  exactly as they do now, following `mobile/design/DESIGN.md`.
- The catalog and concept sheets read from the pack.
- A lesson the app is too old for shows "Update the app to play this
  lesson" with a button to the store (in-app update on Android).
- The starter copy of the FE Civil pack inside the app (rule 3 above).
- The report flag keeps working on every pack game, with two additions
  (owner asked 2026-10-26): the report carries the pack and its version,
  since a round can now change without an app release and the app build
  alone no longer says which wording the student saw; and the game's name
  comes from the pack, so a PE game is reported by name, not by its id.

### Phase 3. Move the content, chapter by chapter

Catalog and concept sheets first, since they are plain content. Then the
games, one chapter at a time, smallest first, so the method is proven
before the big chapters:

1. Construction (10 games)
2. Dynamics (17)
3. Economics, Statistics (19 each)
4. Ethics, Fluid Mechanics (21 each)
5. Materials, Statics, Surveying (23 each)
6. Mechanics of Materials (27), Structural (28), Transportation (29)
7. Water Resources (32), Geotechnical (35)
8. Mathematics (48)

For each chapter:

- Lift the rounds, drawings and concept sheets into the builder. Game ids
  stay the same.
- Run checks 1 to 6 from "How every game and concept sheet is checked" on
  every game and sheet in the chapter. All must pass.
- Write the chapter's record, including any improvement notes for
  afterwards.

### Phase 4. Ship it in two releases

1. **First release:** the app plays from the pack, with the built-in games
   still inside as a fallback. Watch real students for a few weeks:
   errors, downloads that fail, anything that looks different, and check 7
   (completion and accuracy per game against the weeks before).
2. **Second release:** remove the built-in games. Measure the app size
   before and after and record it.

Older app versions already on phones keep working with their built-in
games, so nobody is forced to update.

### Phase 5. The PE begins

A new exam is a new pack, written in the builder the same way. Its first
truly new kinds of games arrive with the app releases that introduce them.

## What is not in this plan

- **The website.** It can read the same packs later so each exam has one
  source, but it works today and nothing here depends on it.
- **How a student chooses an exam.** That is a product and design
  decision for when a second pack exists. FE Civil stays the only exam
  until then.

## What the owner is asked to do

- Play each chapter on his phone before it is switched on (phase 3).
- Approve the download and "update to play" screens when they are
  designed (phase 2).
- Nothing technical. If phase 0 finds the drawings cannot be matched
  exactly, he gets one recommendation to approve.
