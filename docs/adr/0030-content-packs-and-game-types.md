# 0030. Exams ship as content packs; new kinds of games ship in the app; learning comes first

Date: 2026-10-26
Status: Accepted 2026-10-26 (owner: "I love it. write the ADR")

## Context

FE for Raccoons covers one exam, FE Civil. The owner plans to add more:
the PE (Water Resources, Structural and others), and other FE disciplines
such as Electrical and Surveying. He asked how to do that without the app
growing with every exam, and without losing the figures, drawings and text
that make the material work on a phone.

What was measured on 2026-10-26:

- **The phone already downloads its study text and problems.** It reads
  chapters and lessons from the server (`/content/*`, served from
  `service/content.json`, 3.3 MB). None of that is inside the app, so it
  does not grow the download.
- **The phone games are inside the app.** `mobile/lib/features/games/` holds
  375 game files and 114 figure files, about 7 MB of source. Each game file
  holds everything about that game: its rules, its drawing and its rounds.
  All of it is compiled into the app.
- **So two things grow with every exam:** the app's size, roughly another
  FE Civil's worth of games per exam, and the number of store reviews,
  because even fixing a typo in one round means a new app release.
- **The website bundles its lesson data** (`src/data/`, 3.1 MB) and draws its
  figures as React components (`src/components/diagrams/`). Pages load
  lazily, so the website is not hurting yet, but it has the same shape.

The owner's constraint, in his words: "I don't want to sacrifice creative.
If a concept needs a specific type of game that does not exist then we
create it and we make a new version submission then." And: we prioritize
UX and learning approaches that will help our users.

## Decision

### 1. Learning and the student's experience come first

This is the rule every other part of this record answers to. The pack
system exists to serve how students learn. It never decides how they learn.
When a technical convenience and a better lesson disagree, the lesson wins
and the system bends.

In practice:

- **Every game is designed from its own concept,** authored for its lesson
  and never a reusable shell, as the phone's games direction already
  requires (see [0013](0013-games-keep-their-own-score.md) and
  `docs/mobile-app-north-star.md`).
  The question is always "what would make this idea click for a student
  holding a phone?", never "which existing game type can we fit this into?"
- **A student never waits on a download in the middle of studying.** A
  pack downloads when the student picks an exam, ahead of time, and the
  app shows progress in plain words.
- **It works offline once downloaded.** Students study on buses, in
  breaks and in dead zones.
- **A student is never locked out of a whole exam** because one lesson
  needs a newer app (see 5).
- **The student never sees technical language.** No version numbers, no
  "pack", no error codes. They see "Update the app to play this lesson."
- **Nothing a student has done is lost** when a pack updates. Progress
  belongs to the account (see [0018](0018-one-record-per-account.md)),
  not to the pack.

### 2. Each exam is a content pack on the server

A pack holds everything for one exam: chapters, lessons, problems, concept
sheets, figures and the content of every game. The app downloads only the
packs a student studies, keeps them for offline use, and checks for
updates. FE Civil becomes the first pack.

### 3. A game is a game type plus its content

- **The game type is app code.** It knows how to run one kind of
  interaction: the gestures, the feedback, the motion.
- **The game's content lives in the pack.** It names the game type and
  supplies everything that makes this lesson's game its own: the rules,
  the numbers, the rounds, the wording, and the drawing (a Rive file or a
  figure description).

So the app grows with the number of kinds of games, not the number of
lessons, and fixing or improving a round no longer needs a store review.

### 4. A concept that needs a new kind of game gets one

If no existing game type can teach a concept well, we build a new one. It
ships as app code in a normal app release, and the lessons that use it go
live after the release is out. No lesson is bent to fit an existing type
to save a release. Adding a game type is a normal, expected event, not a
failure of the system.

### 5. Each lesson names the app version it needs

- Every lesson in a pack states the oldest app version that can play it.
- If the student's app is older, **only that lesson** shows "Update the app
  to play this lesson" with a button to the store. Everything else in the
  pack keeps working.
- On Android the update can run inside the app. On iPhone the button
  opens the App Store page.

### 6. The server sends content, never code

Packs contain only data that the app already knows how to play: text,
numbers, images, Rive files and figure descriptions. New behavior always
reaches students through an app release. This keeps us inside Apple's and
Google's rules on downloaded code (App Store guideline 2.5.2).

### 7. FE Civil moves first

The existing 375 games are moved onto game types and pack content before
any PE material is written, so the PE starts on a system that is already
proven with real students. Moving a game must not change how it plays; the
student should not notice the move. A separate migration plan covers the
order and the checks.

## Consequences

**Good:**

- The app's size stops growing with every exam.
- Fixing a round, a typo or a drawing ships the same day, with no review.
- A new exam that only uses existing game types can launch with no app
  release at all.
- One pack per exam is the single source for that exam's material, in
  line with [0018](0018-one-record-per-account.md). The website can read
  the same packs later instead of bundling its own copy.

**Costs and risks:**

- **Moving FE Civil is a big job.** Each of the 375 games has to be split
  into a game type and its content, then checked to play exactly as
  before. Nobody yet knows how many game types they reduce to; the
  migration plan measures that first.
- **The pull toward reuse.** With a box of existing game types, it becomes
  tempting to keep reusing them. Section 1 and section 4 are the guard: a
  game is reviewed on whether it teaches its concept well, and "it needed
  a new game type" is never a reason to reject it.
- **Version checks have to be kept honest.** A lesson that names the wrong
  minimum version either blocks students for no reason or breaks on older
  apps. A test should check every lesson's game type against the version
  that introduced it.
- **Pack updates must not break a lesson in progress.** A student midway
  through a round keeps the version they started with until they finish.
- **Downloads use the student's storage and data.** Packs should stay
  small, say how big they are before downloading, and offer to wait for
  Wi-Fi.
- **Guest mode is unchanged.** Packs are public study content, which
  [0026](0026-guest-mode.md) already lets a guest use without an account.

## Alternatives considered

- **Keep building every game into the app.** Simplest today. Rejected: the
  app grows by roughly an FE Civil's worth of games per exam, and every
  content fix needs a store review.
- **A small set of reusable game templates, filled with content.** Smallest
  app, fastest to author. Rejected: it trades the hand-made, concept-first
  games for convenience, which the owner ruled out ("I don't want to
  sacrifice creative") and which goes against how the phone teaches.
- **Download game code at runtime.** Would avoid releases entirely.
  Rejected: against store rules on downloaded code, and a real risk of
  breaking the app on students' phones with no review in between.
- **Lock a whole pack until the app is updated.** Simpler to check.
  Rejected: one new lesson would block a student from an entire exam.
  Checking per lesson costs little and keeps them studying.
- **Games as web pages inside the app.** Would make games downloadable.
  Rejected: they would not feel like the rest of the app, would be slower,
  and would struggle offline. That is a worse experience for the student.
