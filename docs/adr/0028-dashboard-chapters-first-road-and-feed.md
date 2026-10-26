# 0028. Dashboard: chapters first, a road to the FE, and a live feed of other students

Date: 2026-10-26
Status: Accepted 2026-10-26. The owner chose these from mockups. The full
description is in `docs/dashboard.md`. Keeps
[0020](0020-mastery-is-desk-earned.md) (the road shows mastery but never
changes it) and [0027](0027-monthly-chapter-challenges.md).

## Context

Adding the monthly challenge card pushed the chapter list further down the
dashboard. At laptop size only 5 of the 15 chapters showed on the first
screen. The owner said the list should be the main thing on the page, and
that the right column wasted space. He looked at several rounds of mockups:

- **Layouts:** a slimmed band, a ribbon, and chapters from the top.
- **Right columns:** tabs, a single sheet, a "next up" queue, a tile grid,
  then three designs that kept every section.
- **"Right now" cards:** a study hall, a live feed, and a dot chart by
  chapter.

He chose chapters from the top, the timeline he called "Your road to the
FE", and the live feed. He rejected the first round of right columns
because they dropped the weekly and all-time boards. He rejected the first
"Right now" design as too plain, because that section is what tells a
student they are not alone.

## Decision

1. **Nothing sits above the chapter list.** The four numbers and the
   challenge card moved into the right column.
2. **The right column is a road from today to exam day.** Each stop has a
   date: today, the end of the leaderboard week, the end of the challenge,
   a suggested timed simulation three weeks out, and exam day. The
   simulation pitch is a stop on the road, not a banner.
3. **Both boards stay, at full size, under the chapters.** A bar for each
   student shows the distance to the next place.
4. **"Right now" is a feed of named students and what they are doing.** It
   is worked out from the event log and the Daily results, never stored.
   Rules:
   - A student without a first name is "A student".
   - Simulation answers never appear.
   - Our accounts are hidden from students.
   - The viewer does not see themselves.
5. **The columns end at about the same height.** Arrange new sections so
   neither column leaves empty space under it.

## Consequences

- **What the feed reveals.** The feed shows more about each student than
  the old Live Activity list: the lesson, the device, and how long ago. It
  uses the same names the leaderboard already shows. A student who does not
  want to appear by name can leave their first name blank. There is no
  separate opt-out yet. If a student asks for one, add it to the profile and
  filter on it in `service/routes/community.js`.
- **Data cost.** The feed reads the last day of answers from every account
  once a minute, so `reviewEvents` gained an index on `ts`. At a few
  thousand answers a day this costs nothing. At much larger scale, cache it
  for longer or keep a rolling summary.
- **Old pitch measurements.** The `banner` and `card` pitch surfaces no
  longer appear on the dashboard. Their data stays valid for its dates, and
  new impressions are logged as `road`.
- **Presence names.** The practice and lesson pages used to send the
  account's email as their presence name, which the old Live Activity list
  showed. All three study pages now send only a name the student typed, or
  "A student". The feed also drops any frame whose name contains "@".
