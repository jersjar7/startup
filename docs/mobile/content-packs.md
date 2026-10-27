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

One exam's study material for the phone, as one JSON file: its lessons, and
every game in them with its rounds, recorded drawings and concept sheet. No
code. The app plays it with game types it already has.

```json
{
  "format": 1,
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

- **format.** The layout of the file itself. Raised only if an older app
  could no longer make sense of a pack at all. A new game type never raises
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
- **Bands** (`{"bands": [[from width, steps], ...]}`) for a drawing that
  really changes at some width.
- **Concept sheet pictures**: one drawing, two side by side, or a column of
  those with gaps (`"kind": "one" | "pair" | "column" | "gap"`).

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
| `overline`, `mono`, `text` | The game's three kinds of words (`text` may be `bold`). |
| `math` | A centered formula. |
| `figure` | A recorded drawing, before (`ask`) and after (`done`), framed as a bordered `panel`, on the bare `grid`, or `none`. Its height may differ before and after. |
| `box` | A white bordered box holding blocks. |
| `choices` | The answers as buttons, all of them or a listed few. An answer may carry a symbol before its words (`tex`). |
| `panels` | Answers that are drawings, in a column or a row, each recorded as it looks idle, picked, right and wrong (or just idle and "on" when only the border changes, since a picked border is a pixel thicker and the drawing inside a pixel smaller). |
| `tap` | A drawing answered by tapping near a mark: the nearest mark within reach wins, as in the games. Recorded for every mark picked, or none, before and after. |
| `pickedLabel` | The picked answer's words, while it is picked. |
| `feedback` | The verdict and the why. |

Any block can be limited to before the answer, after it, or while an answer
is picked (`"when": "ask" | "done" | "picked"`). The app's side is
`mobile/lib/features/packs/games/pick_one_game.dart`; the adapters that
describe each game are in `mobile/test/packs/` (`dynamics.dart`).

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
cd mobile && flutter test test/packs/build_pack_test.dart && cd ..
node scripts/publish-pack.mjs mobile/build/packs/fe-civil.json
```

The publisher checks the pack (every game in exactly one lesson, chapters
agree, versions well formed), and refuses it with the problems listed in
plain words if anything is off. If nothing changed since the latest version
it publishes nothing. Otherwise it writes:

- `service/packs/<exam>/<exam>-v<version>-<hash>.json`, the new version.
  The name carries the first 12 characters of the content's sha256. It is
  written so that it can never overwrite an existing file.
- `service/packs/<exam>/manifest.json`, pointing at the new version and
  listing every version ever published.

Commit both, then deploy the service. The server reads packs when it starts.

**A published version is never edited or deleted.** A phone may be halfway
through downloading it, or hold it offline. A fix is a new version.
`service/packs.test.js` checks every published file against the hash in its
name and fails if one changed, went missing, or if a file appears that the
manifest does not list.

## The server

All public, like `/api/content`: packs are study material a guest may use
(ADR 0026).

| Request | Answer | Cached |
|---|---|---|
| `GET /api/packs` | Every exam with a pack: exam, title, format, latest version, download size | Always rechecked |
| `GET /api/packs/:exam` | The latest version: file name, sha256, size, size to download, and every lesson's `minApp` | Always rechecked (an unchanged answer costs a 304) |
| `GET /api/packs/:exam/:file` | One published version | Forever |

The phone can tell from the second answer alone whether anything is new and
which lessons it is too old for, without downloading the pack. In phase 2
it will fetch the file, check it against the sha256, and only then swap it
in.
The server sends only files the manifest lists; anything else in the folder
is a 404.

## Open for later phases

- **Size in git.** Each version is kept as a file in the repository. The
  phase 0 pack is 208 KB (13 KB to download). The whole of FE Civil is
  estimated at about 26 MB per version before compression, so by phase 3
  old versions should move out of git (to storage on the server, or
  compressed files), keeping enough for phones still holding them.
- **Pack contents.** Today's pack holds only the three phase 0 games, in
  three lessons that still have their other games built in. It grows
  chapter by chapter in phase 3.
- **Choosing an exam** stays out of scope until a second pack exists.
