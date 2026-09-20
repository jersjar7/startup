# 0018. One record per account: the server holds the truth, both surfaces are views

Date: 2026-09-20
Status: Accepted 2026-09-20 (the owner's decision of 2026-09-19 to
centralize each account's data in one source of truth; this is the design it
turns into). Builds on the audit in `docs/mobile/sync-audit.md` and its nine
fixes, all live as of 2026-09-20. Work starts with the migration's step 1.

## Context

The website and the phone share one account, one server and, since the
audit fixes, one formula for every shared number. What they do not yet
share is one record. Today a student's progress is spread over seven
collections, each written by a different path, with the phone keeping a
mirror of its own in the keychain:

| What | Where it lives | Written by |
|---|---|---|
| Every answer, either surface | `reviewEvents` (append-only) | practice, review, the phone push |
| Per-problem state: correct counts, maturity, the review queue | `problemHistory` | practice, review, the simulation, the phone push |
| The derived figures: XP, days, mastery halves, badges, last sync | `userStats` | six writers, each recomputing what it touches |
| Session summaries | `sessionLog` | five writers |
| The diagnostic and the quick start | `diagnosticResults`, `userStats` | two writers |
| The paid simulation | `examAttempts` | one writer |
| Cleared rounds on the phone | the phone's keychain, now also rebuilt from `reviewEvents` | the phone |

The audit found the consequences: the same number computed five ways
(fixed), a day counted by two clocks (fixed), evidence a writer forgot to
record (the simulation, fixed), a map that lived on one phone (fixed), and
a deletion that missed three collections (fixed). Each was a symptom of the
same shape: derived state written by whoever happened to be writing, rather
than derived from one record by one piece of code.

The owner asked, on 2026-09-19, whether the audit would give enough context
to "centralize the data needed for the website and the app to function
correctly and have one organized source of truth per user account", and
said storage cost is not a constraint as long as the kept data serves a
more informative preparation. It does, and this is the design.

## Decision

**The event log is the record. Everything else is derived from it, on the
server, by one module, and served to both surfaces the same way.**

1. **One log, every action.** `reviewEvents` already holds every answer
   from practice, review and the phone. It gains the actions it misses
   today: a diagnostic or quick-start answer, a simulation answer, a
   lesson opened, a concept read, a feedback report, an exam date set. One
   row per action, with the student's local day, the surface, the device,
   and the ids of what was touched. Rows are never edited or deleted except
   by account deletion.

2. **One deriver.** A single server module turns a log into the account's
   state: problem history and maturity, the review queue, the two halves of
   every chapter's mastery, XP (with the phone's daily cap), study days,
   badges, cleared games and rounds, last sync. It replaces the six
   per-route recomputations. It is pure, so it is unit-tested against the
   log alone, and it can rebuild any account from scratch, which is also
   how the migration runs.

3. **Derived state is a cache, not a truth.** `userStats` and
   `problemHistory` stay for speed, but they are written only by the
   deriver, after each new event, and a nightly job re-derives every account
   and reports any drift. A bug in the deriver becomes a diff to fix and
   re-run, never a corrupted number.

4. **One read for both surfaces.** `GET /api/account/state` returns the
   derived state the dashboard and the phone both need: the figures, the
   halves, the days, the badges, the cleared rounds, the queue. The website
   stops assembling it from six calls; the phone stops keeping its own map
   and becomes a view of this, keeping the keychain mirror only as an
   offline cache that the state overwrites on every sync.

5. **Each surface keeps its own functionality.** What a surface *does*
   stays its own: the website's lessons, practice sets and simulation; the
   phone's games and map. What a surface *knows* is the same record.

## Why this over the alternatives

- **Leave it as it is, with the audit fixes.** Cheapest. But every new
  feature adds a writer, and every writer is a place for the next drift.
  The nine fixes took a day because nine places had to be found.
- **A shared "progress" collection written by all routes.** Centralizes the
  storage but not the logic: six writers into one document still compute
  six ways. The formula divergence the audit found lived exactly there.
- **The log as the record, derived by one module.** Chosen. It is the
  shape the sync design already sketched (`docs/mobile/sync-design.md`),
  half-built: the log exists, the phone writes to it, the website writes
  its answers to it. What is missing is the deriver and the reads.

## What the kept data makes possible

Keeping every action, not just its effect, opens views the owner has asked
about in passing and that a student would value. None are in scope here;
the design keeps them possible:

- A per-chapter timeline: what was studied when, on which surface.
- Time on task, from session durations the log already carries.
- Which explanations get flagged, joined to which rounds were missed.
- "Since your last visit" on either surface, from the other surface's rows.
- A true days-studied history, no backfill needed.

Storage: at the current few hundred accounts and even ten thousand events
each, the log is a few hundred megabytes, within the database plan.

## Migration

1. Build the deriver and prove it against today's records: for every
   account, derive from the log and compare to the stored figures. The
   audit's proof script becomes its test.
2. Add the missing event kinds to the writers (diagnostic, quick start,
   simulation, lesson, concept, feedback, profile), still writing derived
   state the old way. Two weeks of both, and the nightly diff shows zero.
3. Switch the writers to "append the event, run the deriver". Delete the
   per-route recomputation.
4. Add the one read; move the dashboard to it; move the phone to it, keeping
   the keychain as a cache.
5. Account deletion deletes the log and the caches. Nothing else exists.

Roughly two weeks, with a deploy after steps 1, 3 and 4, and the proof
script before each.

## Consequences

- The formula lives in one file. A change to how mastery is scored is one
  change, one test, one re-derive.
- A second device, a reinstall, a new laptop: one refresh and the account
  is whole.
- The nightly re-derive is a cost of a few minutes of server time and a
  guarantee the audit can never silently regress.
- The old level ladder on `/api/topics` and the paper-flag route retire
  with the migration; both are unused by the surfaces today.
