# 0033. A pack is published as one file per chapter, every chapter always on the phone

**Status:** Accepted (2026-10-28)

## Context

[ADR 0030](0030-content-packs-and-game-types.md) moved the phone's games
into a content pack, published as one JSON file per version. With every
chapter moved (2026-10-28, version 18) that one file holds all 375 games:

- **55.4 MB on the phone, 3.40 MB to download.** The server gzips it on
  the way; the phone keeps it unzipped. The drawings are written as drawing
  steps in plain text, which repeats itself and so compresses about 16 to 1.
- **The app reads all of it before its first screen.** `main.dart` awaits
  `PackStore.load()`, which reads the file, parses it and hashes it. On the
  development Mac (Apple M5 Pro) that is 0.08 to 0.16 s to read, 0.44 s to
  parse and 0.41 s to hash, measured three times (2026-10-28). A phone is
  slower; by how much is **unverified** (test: time a cold launch on a
  mid-range Android phone with packs on).
- **A fix to one game republishes everything.** The phone downloads the
  whole 3.40 MB again, and the repository gains another 55 MB file: the 18
  versions published so far are 433 MB in `service/packs/fe-civil/`.
- **GitHub warns above 50 MB a file and refuses above 100 MB.** Version 18
  drew the warning when it was pushed.

The migration record had already noted (phase 3, note 2) that the pack
should be split by chapter before the big chapters. The owner approved the
split on 2026-10-28 on one condition, asked as a question first: a student
studying for the FE Civil exam must never wait on a chapter, or find one
missing on the train with no signal.

The chapters on their own, version 18:

| Chapter | Games | On the phone | To download |
|---|---|---|---|
| Statics | 23 | 7.30 MB | 435 KB |
| Mathematics | 48 | 6.27 MB | 351 KB |
| Surveying | 23 | 5.92 MB | 252 KB |
| Mechanics of Materials | 27 | 4.84 MB | 250 KB |
| Fluid Mechanics | 21 | 4.78 MB | 186 KB |
| Statistics | 19 | 4.51 MB | 259 KB |
| Geotechnical | 35 | 3.92 MB | 234 KB |
| Materials | 23 | 3.63 MB | 142 KB |
| Dynamics | 17 | 3.24 MB | 260 KB |
| Water Resources | 32 | 2.91 MB | 248 KB |
| Transportation | 29 | 2.78 MB | 271 KB |
| Structural | 28 | 2.51 MB | 159 KB |
| Economics | 19 | 1.40 MB | 145 KB |
| Ethics | 21 | 0.79 MB | 84 KB |
| Construction | 10 | 0.59 MB | 37 KB |

The list of lessons, with each one's games and oldest app, is 16 KB.

## Decision

A pack version is published as **one small index and one file per
chapter** (pack format 2), and **every chapter is always on the phone.**

1. **The index** (`fe-civil-v19-<hash>.json`) names the version, every
   lesson with its games and oldest app, and every chapter's file with its
   sha256. It is what a version is; the manifest points at it.
2. **A chapter file** (`fe-civil.statics.<hash>.json`) holds that chapter's
   games and nothing about the version, and is named by its content. A
   version that leaves a chapter alone points at the same file as the
   version before it, so the repository and the phone gain only the
   chapters that changed. Published chapter files are never changed or
   removed, as versions are not.
3. **Every chapter ships inside the app** (`assets/packs/fe-civil/`), so
   all of FE Civil works from the first open with no signal, as before.
4. **An update downloads only the chapters that changed**, quietly, as
   before: the index first, then each chapter file the phone does not
   already hold, each checked against its hash. Only when every one is in
   place does the phone switch to the new version, so it never plays half
   of two versions. Nothing is fetched when a chapter is opened.
5. **The app reads the index at launch and a chapter when one of its games
   is first opened**, and keeps it. Reading is the only thing that waits
   for a chapter, never the network.

## Consequences

- Launch reads 16 KB of lessons instead of 55 MB; opening a game reads at
  most its chapter (7.3 MB at the largest, an eighth of today's file) the
  first time.
- A one-game fix costs a student one chapter's download (37 to 435 KB)
  instead of 3.40 MB, and costs the repository one chapter file instead
  of 55 MB. The largest file in the repository is 7.3 MB, far from
  GitHub's limits.
- The published format 1 versions (1 to 18) stay published and unchanged,
  as ADR 0030 requires. No released app reads format 1 (1.1.0 does not read
  packs), so the app reads only format 2; a development build still holding
  a format 1 pack keeps it until the new app replaces it.
- Opening the first game of a chapter can wait briefly while the chapter is
  read; the app shows its plain background meanwhile. On the Mac that is
  about 0.12 s for the largest chapter, Statics (read 0.01 s, parse 0.06 s,
  check its hash 0.05 s; three runs, 2026-10-28), against about 1 s to read
  the whole pack at launch before. On a phone, unverified (same test as
  above).
- The pack builder is unchanged: it still writes one pack, and the
  publisher splits it. Every check (parity, the pack audit, the simulator,
  the size ceilings) keeps reading whole games.

## Alternatives

- **Fetch a chapter when it is opened.** Smaller install, but a student
  with no signal would meet a chapter they cannot open. Rejected: the
  owner's condition.
- **Keep one file and gzip it on the phone.** Fixes the size on the phone
  but not the reading at launch, the 55 MB a version in the repository,
  or a fix costing the whole download.
- **Git LFS for the pack files.** Moves the size out of the repository but
  not off the phone or the student's data plan, and makes every deploy
  depend on LFS.
