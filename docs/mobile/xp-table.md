# XP per event type

Single source of truth: `service/xp.js`. Every route imports from there, so XP
values stay consistent and intentional instead of being re-invented inline. This
doc is a human-readable mirror; if they ever disagree, the code wins.

## The table

| Surface | Event | XP |
|---|---|---|
| Web (practice + review) | Problem correct | 10 each |
| Web (practice + review) | Problem incorrect | 5 each (effort credit) |
| Web practice | Finish a chapter session | +25 bonus |
| Web review | Finish a spaced-review session | +15 bonus |
| Web | Diagnostic / quickstart, per question attempted | 10 each |
| Web | Diagnostic / quickstart, per correct | 5 each |
| Web | Exam simulation, per attempt | 100 flat |
| Web | Exam simulation, per correct | 2 each |
| Phone | Card graded `gotIt` | 5 |
| Phone | Card graded `fuzzy` | 3 |
| Phone | Card graded `forgot` | 2 |
| Phone | Daily cap (per local day) | 60 |

## Why these values

- **Desk problem-solving is the gold standard** (10 per correct + a completion
  bonus). The full exam simulation is the biggest single reward (100 + 2/correct).
- **Wrong answers still earn a little** so honest practice is never punished.
- **Phone retrieval is genuine but lighter** (2–5 per card) and **capped at 60
  XP per local day**, so couch card-grinding can't outscore real desk work on the
  leaderboard. Phone XP is *derived* server-side from the sync event log, never
  sent by the client.
- Streak credit always uses the event's CLIENT-local day, so an offline Tuesday
  synced Wednesday still counts Tuesday.
