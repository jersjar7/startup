# Phase 1 results: the pack and the server

Date: 2026-10-26. Branch `content-packs-phase1`.
Plan: [content-packs-migration.md](../content-packs-migration.md). How it
works: [content-packs.md](../content-packs.md).

## The answer

Done. FE Civil has a published pack, version 1 (the three phase 0 games), and
the server can hand it out. No student sees any of it: the app does not ask
for packs until phase 2.

## What was built

- **The pack layout**, format 1: exam, title, version, and every lesson with
  its games and the oldest app that can play them.
- **The game type list** in the app, each type with the release that first
  had it (1.2.0 for the three so far).
- **The builder** now writes a whole pack, working out each lesson's oldest
  app itself.
- **The publisher** (`scripts/publish-pack.mjs`): checks the pack, gives it
  the next version, and writes it under a name carrying its hash. Publishing
  the same content twice publishes nothing.
- **The server**: three public addresses under `/api/packs`. The list of
  exams and an exam's latest version are always rechecked; a published file
  is cached forever.

## Checks run

| Check | Result |
|---|---|
| Pack rules | A sound pack passes; a pack with six different faults is refused with all six named in plain words. |
| Versions | First publish is version 1; unchanged content publishes nothing; a change becomes version 2 in a new file with version 1 still listed; two exams cannot share a manifest. |
| Server | Each address answers with the right content and caching; an unchanged answer costs a 304; every file not in the manifest is a 404, including the manifest itself and a path that tries to climb out of the folder. |
| Published packs never change | Every published FE Civil file matches the hash in its name and the version inside it; no unlisted files. |
| The version guard | Every lesson's oldest app is exactly right. Setting one lesson a release too old on purpose made the test fail, as it should. |

## Found

1. **The first app that reads packs is assumed to be 1.2.0**, since 1.1.0 is
   the release in the stores. If the next release gets another number, two
   lines change before it ships.
2. **Old versions will get heavy in git.** Fine now (208 KB a version), but
   the whole of FE Civil would be about 26 MB a version. Decide where old
   versions live before phase 3.
