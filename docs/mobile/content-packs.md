# Content packs: how they work

The reference for packs as built. The decision is
[ADR 0030](../adr/0030-content-packs-and-game-types.md); the order of work is
[content-packs-migration.md](content-packs-migration.md). Written 2026-10-26
at the end of phase 1.

Students see none of this yet. The app still plays its built-in games;
reading packs is phase 2.

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
