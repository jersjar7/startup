# 0037. Weekly leagues replace the weekly top-30 board

- **Status:** Accepted
- **Date:** 2026-11-01
- **Supersedes:** the June 2026 decision to keep a single weekly board until about 100 students were active each week
- **Spec:** [docs/leagues-spec.md](../leagues-spec.md)

## Context

The weekly board showed the top 30 students by XP. In the week of
2026-10-25, 117 students finished a study session and 87 of them never saw
their own name. Weekly actives have been 97 to 120 every week since
September, past the level the June decision named for revisiting it. Effort
is spread wide (median 425 XP, top tenth over 2,220), so one board puts most
students hopelessly far from the top.

## Decision

The owner approved all eight decisions in the spec on 2026-11-01:

1. Five tiers: Timber, Masonry, Concrete, Steel, Titanium.
2. Groups of 15. Top 5 move up, bottom 3 move down; a group under 8 has no
   move-down zone.
3. One week for everyone, Sunday to Saturday, US Eastern.
4. No penalty for a missed week: the tier is kept.
5. The first week is seeded from each student's last four weeks of XP.
6. A "Hide me from leagues" switch; a hidden student competes as "A student".
7. The all-time board stays; leagues replace only the weekly board.
8. The phone app gets a league row on Profile, mocked before it is built.

A student joins a group when they earn their first XP of the week, so every
row on a board is someone studying that week. This is the part taken from
Duolingo that matters most.

## Alternatives

- **Keep one weekly board.** Fails three quarters of active students.
- **Ten tiers like Duolingo.** With about 110 students a week most tiers
  would be empty. Tier count and group size live in settings so they can
  grow later.
- **Per-time-zone weeks like Duolingo.** Nearly all students are in the US;
  one clock is simpler to explain and to test.
- **Demote for a missed week.** Punishes exam breaks, against the
  no-penalty rule of the learning model.

## Consequences

- Placement happens inside `rederiveAccount`, the one place XP is written.
- The week id moves from the server's clock to US Eastern.
- A Sunday job closes the week; it must be safe to run twice and the nightly
  re-derive must not undo it.
- `GET /api/leaderboard` stays for the all-time board and older app versions.
