# Progress Sync — One Brain, Two Surfaces

**Status:** v2 — panel-reviewed (5-persona user study, 2026-06-10; see
`feedback-backlog.md` for the prioritized findings)
**Decides:** how the website (desk) and the phone app (pocket) share one
account and one progress state.

## Product model

- **Website** = sitting at a table: lessons, full calculation problems, mock
  exams, diagrams, the deep work.
- **Phone** = on the go: spaced repetition of the *same* concepts and
  questions — formula recall, tap-the-trap, concept cards — resurfacing each
  item right before you'd forget it.
- Same account. Same question bank (mobile cards are derived from web problem
  IDs — `math-slq-q1` → `math-slq-q1:fc` / `:cc`). Studying on either surface
  advances the same shared state.
- Litmus (from the North Star): every synced signal must serve honest concept
  mastery — never a pass probability.

## Identity

- Mobile gets **login with the existing fe4raccoons account** (same email +
  password, same normalized-email rules as the web auth pipeline). No separate
  mobile account, no social login in v1.
- Token stored on device (SecureStore); `/api/me` TTL rules apply as on web.
- **Guest mode stays.** The app works locally without an account (as today);
  signing in merges local progress up (see Merge).

## What syncs (and what doesn't)

Sync **events**, derive state. Never sync computed state — recompute it.

| Signal | Synced? | How |
|---|---|---|
| Review events (item id, grade, timestamp, source, **localDate**) | ✅ | append-only event log |
| Study-day record (for streak) | ✅ | derived from events' localDate, server-computed |
| Diagnostic familiarity (per chapter) | ✅ | keep-max per chapter (seed-only; quickly dominated by real events — show provenance: "from your June 10 phone diagnostic") |
| Exam date | ✅ | web profile is the source; on first sign-in with a differing local value, ask once which is right (it drives all pacing math — never silently clobber) |
| Daily pace (minutes/day) | ✅ | last-write-wins; same ask-once rule at first sign-in |
| Paper hand-off flags (`flaggedForPaper`) | ✅ | event type — phone misses flag their parent problems for the web's desk queue |
| Sound/reminder settings | ❌ | device-local by nature |
| Schedule (due dates, intervals) | ❌ | recomputed from the event log by ONE shared scheduler (below) |
| Mastery / XP / streak number | ❌ | derived from the merged log — never stored, never synced |

**One scheduler, not two.** The web's Daily Review queue
(`service/scheduling.js`) and the phone's SM-2 are today two different
algorithms. Sync v1 extracts ONE versioned scheduling module (plain JS, shared
web + RN, version-stamped into events) so "due" is computed identically
everywhere, with explicit mapping between card-level events
(`math-slq-q1:cc`) and the web's parent-problem queue. Written invariant:
**an item graded on surface A is never due on surface B the same local day.**
If the full unification slips, the v1 floor is dedupe — drop from a surface's
due list any item with a same-day review event from the other surface.

**XP is derived, like mastery.** SHIPPED 2026-06-11 — the table: phone card
reviews earn **gotIt 5 · fuzzy 3 · forgot 2**, capped at **60 XP per local
day** from the phone (web problems stay 10/5 + 25 session bonus). Computed
at ingest from the day's capped totals (idempotent under replay), credited
to totalXp/weeklyXp so the leaderboard sees phone work without being
farmable.

**Streak rules (defined once, here):** a day qualifies when one *completed
bounded session* happened (per the North Star's bounded-session rule — not one
throwaway card). Every event carries a client-supplied `localDate` (web too —
server UTC would break 11:50pm sessions); streak credit always uses the
event's recorded localDate regardless of when it syncs (offline Tuesday synced
Wednesday still counts Tuesday). The server computes the streak from the
merged log; both clients render the server's number.

**Why events:** merging is trivial and conflict-free. Two devices offline at
once just produce two event sets; union them, sort by timestamp, recompute
schedule + streak + mastery. No clocks-fighting over "current interval."

## Cross-surface semantics (the heart of it)

- **Phone reps strengthen web mastery.** A `gotIt` on `math-slq-q1:cc` is
  evidence about concept `math-slq-q1` — the web mastery model consumes review
  events alongside its lesson/exam-bank signals.
- **Web work seeds the phone schedule.** Solving a problem correctly in a web
  lesson emits a review event (`source: web`) for that item — the phone won't
  re-drill at day-1 spacing something you just did at your desk; it schedules
  the *next* touch at the right interval.
- **Diagnostics don't repeat.** Web quick-start diagnostic familiarity ≡
  mobile diagnostic familiarity (same per-chapter scale). Whichever ran first
  seeds both; running both keeps the max per chapter.
- **One streak.** A study day counts if *either* surface logged qualifying
  work that local-date. Phone-only week = streak intact on web.

## Offline-first protocol

1. All writes land locally first (AsyncStorage) — the app never blocks on
   network. A subway session works exactly like today.
2. Each review appends to a local **outbox** (event + uuid + local date).
3. On connectivity/app-foreground: `POST /api/sync/events` (batch, idempotent
   by event uuid) then `GET /api/sync/changes?since=<cursor>` to pull events
   from other devices/web. Cursor = server sequence number.
4. After pull: recompute schedule/streak/mastery from merged log. UI updates.
5. Sign-in with existing local progress → local events get uploaded (they have
   uuids; the server dedupes), so guest work is never lost.

Conflict rules (few, because events): settings = last-write-wins by server
receive time; familiarity = max per chapter; events = set-union by uuid.

## API surface (server work)

- `POST /api/sync/events` — body `{events: [...]}`, idempotent, auth'd.
- `GET  /api/sync/changes?since=` — events + settings newer than cursor.
- New collection `reviewEvents` (userId, eventId, itemId, chapterId, grade,
  source: web|ios|android, ts, localDate). Index (userId, seq).
- Web lesson flow emits events into the same collection (closing the known
  mastery-model gap — studyScore — becomes part of this work).

## Phasing (revised after panel review)

The panel unanimously rejected a silent v1 ("web display unchanged" = the
betrayal scenario). The bar for v1 is the **Tuesday test**: 25 phone minutes
at lunch must be visible on the web that evening.

- **v0 — fix the foundation (prereq):** ✅ DONE 2026-06-10. Correction: web
  `studyScore` was already wired + live (380d6c2, 2026-06-04) — the panel and
  spec v1 cited a stale doc. The real residual defect was a formula
  inconsistency (diagnostic wrote `min(diag+study,100)` vs `max(diag,study)`
  in sessions/review); unified to **max(diagnosticScore, studyScore)**
  everywhere — one formula, matching the mobile model.
- **v1 — account + one log + same-day visibility:** mobile login
  (account-first onboarding: "Already use fe4raccoons.com? Sign in" on screen
  one; after sign-in pull exam date/pace/familiarity, skip the mobile
  diagnostic, confirm the import — never greet a paying user with a zero
  ring); event push/pull; ONE shared scheduler (or at minimum the same-day
  dedupe invariant); shared server-computed streak; same-evening web
  visibility: streak ticked, due-queue decremented, and a dashboard activity
  line ("Today on your phone: 12 cards, 8 min, 3 misses in Surveying — synced
  12:42").
- **v2 — one mastery + the hand-off:** one metric, one name, one formula on
  both surfaces (replacing web "Exam Readiness" tiers); `flaggedForPaper`
  events feed a web "Tonight" card ("From your phone today: 3 trap concepts →
  5 full problems in Water Resources, ~40 min"); daily-pace *progress* derives
  from the shared log so "Done for today" is true on both surfaces; mastery
  drops are attributed ("Surveying −4%: station-notation trap missed 3× on
  phone") and paired with a repair action.
- **v3 — polish:** visible sync state ("last synced 12:42 from iPhone");
  live dashboard refresh over the existing /ws channel when phone events
  land; home-screen widget (streak + countdown + due count); account deletion
  on phone (store compliance).

## Reset semantics

Set-union-by-uuid cannot represent deletion, so "Reset progress" on a synced
account must be scoped: **"Reset this device — your account progress is
safe"** (clear local cache, re-pull on next sync). Account-wide reset, if ever
offered, requires a tombstone/epoch mechanism in the event protocol plus typed
confirmation — specified together with the account-deletion work, not
improvised.

## Store-compliance note

Once accounts exist, the app "collects data" — App Privacy / Data Safety
answers change (email, progress), and Apple requires **in-app account
deletion** if accounts can be created in-app. The web deletion pipeline
already covers all collections; mobile needs the button.

## Closed questions (panel verdicts, 2026-06-10 — all unanimous or consensus)

1. **Wrong answers visibly lower web mastery — small, capped, attributed,
   paired with a repair action.** Slower-growth-only was rejected as "lying by
   omission"; the betrayal otherwise arrives on exam day. Cap per-day movement
   from any single surface, drop 2–4 points per cause, and always attach the
   why + the fix. Discouragement comes from opacity, not truth.
2. **Login offered on screen one, never required.** Guest try-then-keep stays
   the default for new users; existing users must be able to sign in *before*
   pace + diagnostic, or "diagnostics don't repeat" is unreachable.
3. **Same-day continuation — one continuing day, one plan, partially
   completable on either surface.** Independent daily quotas = "two products
   wearing one logo" / double-billing the user's time.
4. **Sync is free, forever, in writing.** The live landing page already
   promises "the whole platform is free … and spaced repetition"; gating sync
   would be a published-copy bait-and-switch. Monetize depth on top of unified
   state (exam simulation, advanced analytics) — never the continuity of a
   user's own progress.
