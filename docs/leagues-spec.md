# Weekly leagues: spec

Status: approved 2026-11-01 (ADR 0037), with the names, the board, the
fourth Profile figure and the XP rules updated the same day (ADR 0038).
Decisions marked **Recommend** were all approved by the owner.

**League and group.** A *league* is a level (Copper to Platinum). Each week
the students in a league who have earned XP are split into *groups* of up to
15, and a student's board shows their group. Nobody is left out: with 110
active students each league has one or two groups, and a busy league simply
opens more.

## Why

Today the weekly board shows the top 30 students by XP. Last week
(Oct 25 to Oct 31) **117 students** finished at least one study session, so
**87 of them (74%) never saw their own name** on the board, however hard they
worked. The ones who need a nudge most, the middle and the beginners, are
exactly the ones the board leaves out. The board rewards the few who are
already ahead.

Leagues fix this by splitting everyone into small groups of people at a similar
level. Every active student is on a board every week, close enough to the
people above them to feel they can pass them.

In June 2026 we decided to wait until about 100 students were active each
week. We were at 34 then. We are at 97 to 120 every week since early September:

| ISO week | Students with a finished session |
|---|---|
| W36 | 74 |
| W37 | 105 |
| W38 | 104 |
| W39 | 97 |
| W40 | 101 |
| W41 | 120 |
| W42 | 105 |
| W43 | 97 |
| W44 | 112 |

(Desk sessions only; phone-only students would add a few more. Internal and
test accounts excluded.)

The spread of effort is wide, which is why grouping by level matters. Last
week's XP: a quarter of students earned under 200, half under 425, the top
tenth over 2,220, and the top student 4,945. A student with 300 XP on today's
board is looking up at someone with ten times as much.

## How Duolingo does it

What Duolingo states itself (blog post "Duolingo Leagues and Leaderboards"):

1. **A new league week starts every Sunday**, in each learner's own time zone.
2. **You are matched with learners with similar study habits and a similar
   time zone.** Leagues mix all languages; you compete on effort, not subject.
3. **Ten tiers**: Bronze, Silver, Gold, Sapphire, Ruby, Emerald, Amethyst,
   Pearl, Obsidian, Diamond. It started with five in 2018 and added more as the
   user base grew.
4. **You move up or down one tier a week** based on where you finish.
5. **Diamond Tournament**: the top 10 in Diamond can enter a three-round
   knockout (quarterfinals, semifinals, finals), held some weeks only.
6. **You can opt out** by making your profile private.
7. **Cheating is policed**: unusual XP gets you removed.

Widely reported but not confirmed by Duolingo itself (treat as approximate):

- Groups hold about **30 people** (Diamond is smaller).
- **You only join a league once you finish your first lesson of the week.**
  This is the key trick: nobody on your board is a ghost. Everyone you see
  studied this week.
- The **promotion zone** is the top few places, larger in low tiers (it is
  easy to leave Bronze) and smaller higher up. The **demotion zone** is the
  bottom few places, and there is no demotion out of Bronze.
- **Results land on Monday** as a full-screen "you moved up" moment with a
  shareable image. Top 3 get a small prize (gems).
- **Notifications do much of the work**: "X just passed you", "you dropped out
  of the promotion zone", "the week ends in a few hours".

Why it works, in plain words:

- **Small groups.** Being 4th of 15 feels winnable. Being 74th of 117 does not.
- **Fresh start every week.** Last week's loser can win this week.
- **Something to lose.** The demotion zone is loss aversion: people study on
  Saturday night to avoid dropping.
- **Only active people.** Because you join on your first lesson, the board is
  always full of real, current competitors.
- **Similar people.** Matching by habits means a casual learner is not crushed
  by someone who plays four hours a day.

What we do **not** copy: gems, paid "league repair", streak freezes, hearts.
Our learning model rules out penalties and pay-to-win for an adult audience.

## What we would build

### The rules

1. **Leagues.** Five, named after metals, weakest to strongest: **Copper,
   Bronze, Silver, Gold, Platinum** (ADR 0038; ADR 0037 first named them after
   construction materials). Each has a coin in its metal. Five, not ten,
   because with about 110 students a week ten tiers would leave most of them
   empty. We can add tiers later, as Duolingo did.
2. **Group size.** **Recommend 15.** With about 110 students that is about
   seven groups a week, one or two per tier.
3. **Joining.** A student joins a group the moment they earn their first XP of
   the week, web or phone. They land in the newest group of their tier that
   still has room; when it is full, a new group opens. Students who start the
   same day tend to study at a similar pace, so this is our version of
   Duolingo's matching, with no extra machinery.
4. **Week.** Sunday 00:00 to Saturday 23:59, **US Eastern for everyone**.
   One clock is simpler to explain and to test than one per time zone, and
   nearly all our students are in the US. (The current board already ends on
   Saturday.)
5. **Score.** The same weekly XP the board uses now: desk problems, reviews,
   tests, the simulation, and phone practice under its daily cap. No new
   points. Two rules added before launch (ADR 0038): a problem earns XP only
   the first time it is answered on a day, and the server, not the browser,
   decides whether a desk answer was right.
6. **Moving.** At the end of the week:
   - **Top 5 move up** one league (none above Platinum).
   - **Bottom 3 move down** one league (none below Copper).
   - A group with fewer than 8 people has no demotion zone, so a thin late
     group never punishes anyone.
   - A group with fewer than 8 people moves up only its top third, rounded
     down (added 2026-11-01), so a late group of two is not a free promotion.
   - A student with 0 XP that week is not in any group and **keeps their
     tier**. **Recommend no penalty for missing a week**: students take breaks
     before and after the exam, and punishing that goes against our no-penalty
     rule.
7. **Ties.** Equal XP: whoever reached it first ranks higher.
8. **First week.** **Recommend seeding** everyone's starting tier from their
   XP over the last four weeks, so regular students do not spend a month
   climbing out of Copper. New students start in Copper. The split is by
   fifths of the students active in those four weeks.
9. **All-time board stays** as it is. The league replaces only the weekly
   board.
10. **Names.** Same rule as now: "Maria G." when a name is set, masked email
    otherwise. **Recommend adding a "Hide me from leagues" switch** in the
    profile. A hidden student still competes but appears as "A student".
11. **Integrity.** Internal and test accounts stay excluded, as today.

### What students see

**Website dashboard.** The "This week" board becomes the league card, drawn
like a music chart:

- Header: the league's coin and name, large, and "Ends Saturday".
- Each row: the place, with a green up caret, a red down caret, or "New" for
  how it moved since the start of the day; an initials avatar; the name; and
  "1,840 XP · 6 days this week". The student's own row is highlighted.
- Lines name the leagues at the zones: "Moving up to Gold" above the top 5,
  "Staying in Silver" below them, "Moving down to Bronze" above the last 3.
- The all-time board beside it shows the top 15.
- The road card's line changes from "Not on this week's board yet" to, for
  example, "4th in Silver this week". Before the first XP of the week:
  "Earn XP this week to join your Silver league."
- **Sunday results.** The first visit after the week ends shows the result
  once: moved up, stayed, or moved down, with a short line in our voice. The
  student's coin travels the ladder of five coins from last week's league to
  the new one (about 1.2 seconds; reduced motion shows the end state).

**Phone app.** The app has no leaderboard screen today. The Profile gains a
fourth figure, the student's place in their league ("4th in Silver"), which
opens the league page with the group's rows (ADR 0038). It must follow `mobile/design/DESIGN.md` (no stacked
web-style list); the design is mocked first, as with every screen. The app
reads the same API as the website.

**Email.** The Sunday weekly digest (sent at 8am Eastern) gains one line: last
week's result and the new tier. No new emails. The lifecycle kill switch still
covers it.

**Not in version one:** push notifications ("X passed you") and a top-tier
tournament. Both are worth testing once leagues are running.

### How it works underneath

- **Two new collections.**
  - `leagueGroups`: one document per group per week:
    `{ weekId, tier, groupNo, members: [email], createdAt, closedAt, results }`.
  - `leagueStanding`: one per student: `{ email, tier, weekId, groupId,
    hidden, history: [{ weekId, tier, place, moved }] }`.
- **Joining happens in one place.** Every XP change already goes through
  `rederiveAccount` (service/rederive.js). When it computes weekly XP above 0
  and the student has no group for this week, it places them. Placement must
  be safe when two requests arrive at once (an atomic "add to the open group
  if it has room" update).
- **The week id gets an explicit time zone.** Today `getWeekId` and
  `weekIdFor` use the server's own clock. Leagues need both to use US Eastern,
  and a test must hold the two in agreement.
- **Closing the week** is a job on the existing scheduler, run Sunday shortly
  after midnight Eastern. It ranks each group by weekly XP, writes results,
  and updates each student's tier. It must be safe to run twice; the nightly
  re-derive must not undo it.
- **API.** `GET /api/league` returns the student's league and the ones above
  and below, the week's end time, their group's rows (place, name, XP, days
  studied this week, move since the day's snapshot, is-me), the zone sizes,
  whether they are hidden, and last week's result if not yet seen. It answers
  404 while leagues are switched off. `POST /api/league/seen` marks the result
  shown; `POST /api/league/hidden` saves the switch.
- **Moves.** Once each Eastern day the league job records every open group's
  places. A row is "up" or "down" against that snapshot, and "new" for anyone
  who joined since. The current `GET /api/leaderboard` stays for the all-time board and
  older app versions.
- **Admin.** The admin dashboard gains a weekly line: students placed,
  groups, and per tier how many moved.

### How we know it worked

Compare four weeks before with four weeks after:

1. **Share of active students who see their own name on a board.** Today 26%
   (30 of 117). Should be 100%.
2. **Students who come back the next week.** The main goal.
3. **Days studied per active student per week.** Leagues should pull people
   back mid-week, not just once.
4. **Weekly active students.** It should not drop. If it does, the move-down
   zone may be scaring people off, and we soften it.

### Risks

- **Summer and post-exam dips.** If weekly actives fall below about 60, groups
  thin out. The code should read tier count and group size from settings so we
  can shrink to four tiers or groups of 10 without a release.
- **Grinding.** Wrong answers earn 5 XP, so someone could farm XP by guessing.
  This exists today and leagues make it more tempting. Watch the top of each
  group in the first weeks.
- **Old app versions** never call the new endpoint, so they keep working and
  simply do not show leagues.

### Rough size

- Server (collections, placement, week close, API, time zone fix, tests):
  the largest part.
- Website league card, road line, Sunday result, profile switch.
- Phone: mock first, then the profile row and sheet.
- Digest line and admin line.

## Decisions for the owner

1. Five tiers named Timber, Masonry, Concrete, Steel, Titanium. (Renamed
   Copper, Bronze, Silver, Gold, Platinum by ADR 0038.)
2. Groups of 15; top 5 up, bottom 3 down.
3. One week for everyone, Sunday to Saturday, US Eastern.
4. No penalty for a missed week.
5. Seed the first week from the last four weeks of XP.
6. A "Hide me from leagues" switch.
7. Keep the all-time board; leagues replace only the weekly board.
8. Phone app gets a league row on Profile, designed and mocked before building.
   (Built as a fourth Profile figure, ADR 0038.)
