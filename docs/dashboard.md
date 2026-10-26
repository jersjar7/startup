# The dashboard

Redesigned 2026-10-26 with the owner, from mockups. The decisions that are
easy to undo by accident are in ADR 0028.

## Layout

The chapter list is the main thing on the page, so it starts at the top
on the left, right under the title. Nothing sits above it.

- **Left column:** the 15 chapters, then this week's board and the all-time
  board side by side, then the badge shelf, then one line asking students to
  share the site.
- **Right column:** "Your road to the FE", then the readiness map card and
  the account setup card when they apply, then "Right now".

The two columns are sized to end at about the same height, so neither side
leaves empty space under it. On a laptop (1440 wide) they end within about
25px of each other. Below 900px wide the page becomes one column in this
order: chapters, the road, the feed, the boards, then badges.

The four numbers that used to sit above the list (XP, days studied, days to
the FE, total mastery) now live in the road. The chapter challenge card
became a stop on the road. Focus areas became a "Most to gain" mark on the
three chapter rows they named. The simulation banner and the simulation
card became a stop on the road.

## Your road to the FE (`src/dashboard/RoadToFe.jsx`)

One line from today to exam day. Each stop is something with a date.
`roadStops()` in `src/dashboard/road.js` decides which stops appear and in
what order, and it is unit tested.

| Stop | When it shows | What it says |
|---|---|---|
| Today | Always | Reviews due, what the phone did and missed, or the chapter with the most to gain |
| Week ends | Always (the Saturday; leaderboard weeks start on Sunday) | Weekly rank, a bar for each of the top 10, the XP needed to pass the next student, days studied, total XP |
| Challenge ends | While this month's challenge runs, until it is finished at the desk, and only if it ends before the exam | Coin, lesson marks, progress, how many finished, the next lesson |
| Timed simulation | Three weeks before the exam; "Now" inside three weeks; dropped in the last two days unless already bought; undated when there is no exam date | Pitch for non-buyers (tracked as `via: 'road'`), or runs and best score for owners |
| Exam day | Always, last | The date, or a link to set one |

The header shows the days left and the total mastery. Tapping the mastery
opens the scoring explanation. The raccoon peeks over this card, which is
why the card is first in the column and why the column is not sticky or
scrollable: either would clip the raccoon.

## Right now (`src/dashboard/LiveFeed.jsx`, `GET /api/community/now`)

The section that tells a student they are not studying alone. It shows one
row per other student, people working right now first, then the most
recent. Each row has a name, what they did, the chapter coin and how long
ago. The footer shows how many studied today and, when at least five from
the viewer's school studied this week, that number.

The server works the feed out from the event log and the Daily results
(`service/community.js`, pure and unit tested), and stores nothing new.
Each student gets their single most telling row from the last 24 hours:

- **working:** answered something in the last 10 minutes.
- **challenge:** finished this month's challenge. The time comes from the
  answer that completed it.
- **daily:** finished today's Daily.
- **practiced:** their latest session. A session ends at a gap of 30
  minutes or more. The row names its most common lesson, or the chapter
  when the problems are not lesson problems.

Rules:

- Working beats everything. A challenge finish beats a session or a Daily.
  Otherwise the latest wins.
- Simulation answers never appear (their event ids start with `exam-`).
- A student without a first name shows as "A student", never part of
  their email.
- Our own accounts are hidden from students. They do see each other, which
  is the Daily's rule.
- The viewer never sees their own row.

The feed is cached for a minute per local day. The school count is cached
for five minutes. The page polls once a minute while visible. A lesson or
practice page that opens while the dashboard is up also arrives through the
existing presence socket. The pages send only a name the student typed,
or "A student". Socket frames whose name contains "@" are dropped anyway,
in case an older open tab sends one.

## Boards and badges (`Boards.jsx`, `BadgeShelf.jsx`)

Each board shows the top 10. When the viewer is further down, it shows the
top 7, a gap, then the viewer with one student either side. The bars are
scaled to the leader, so students can see the distances between places and
not just the order. The badge shelf shows all 12 website badges. Earned
ones are raised in sunbeam and the rest are dashed. "Next" names the
closest badge we can measure from what the page already has, XP or study
days.

## Screenshots

Before shipping a change here, run the mock screenshot script used for this
redesign at 1440, 1024 and 390 wide. It mocks `/api/**` with Playwright
route handlers. Check that the columns end level and that the page never
scrolls sideways.
