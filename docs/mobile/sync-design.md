# Progress Sync — One Brain, Two Surfaces

**Status:** draft v1 (for persona review)
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
| Review events (item id, grade, timestamp, source) | ✅ | append-only event log |
| Study-day record (for streak) | ✅ | derived from events' local-date |
| Diagnostic familiarity (per chapter) | ✅ | latest-wins per chapter, keep max |
| Exam date | ✅ | already a web profile field — single source |
| Daily pace (minutes/day) | ✅ | last-write-wins |
| Sound/reminder settings | ❌ | device-local by nature |
| SM-2 schedule (due dates, intervals) | ❌ | recomputed deterministically from the event log |
| Mastery / readiness | ❌ | derived on each surface from the same events |

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

## Phasing

- **v1 — account + one log:** mobile login; event push/pull; shared streak;
  shared exam date; local merge on sign-in. Web *emits* events but its mastery
  display is unchanged.
- **v2 — one mastery:** web mastery model consumes review events; phone
  consumes web-sourced events into its schedule; shared diagnostic
  familiarity.
- **v3 — polish:** sync status UI, multi-device niceties, account management
  on phone (delete account parity for store compliance).

## Store-compliance note

Once accounts exist, the app "collects data" — App Privacy / Data Safety
answers change (email, progress), and Apple requires **in-app account
deletion** if accounts can be created in-app. The web deletion pipeline
already covers all collections; mobile needs the button.

## Open questions (for persona review)

1. Should a *wrong* answer on the phone visibly lower web mastery, or only
   slow its growth? (Honesty vs. discouragement.)
2. Is login required up-front, or after the first session ("try, then keep
   your progress")?
3. What does the user expect to see *immediately* after switching surfaces
   mid-day — same-day session continuation, or independent daily sessions?
4. Does the paid tier gate sync? (Freemium boundary placement.)
