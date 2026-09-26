# Phone and website: one account, one record? The audit

_2026-09-19. Owner's ask: before the mobile app ships, check that the phone
and the website each keep their own functionality and share their progress
cleanly. Owner's decisions that the audit checks against: games can carry a
chapter to 50 percent and no further; the desk can carry it from 0 to 100;
mastery is one number with two visible halves; the cap is the hand-off._

Three parts: the contract (what is shared and by which rule), the findings
(what the code and a live run actually do), and the fixes in order. The live
run is `scripts/auditSync.mjs`, which plays rounds exactly as the phone does
and a session exactly as the website does against the live server on the QA
account, and checks what the other surface then reads. Run it with `--reset`
before every backend deploy.

## 1. The contract

Identity is sound: every write keys on the account email, the phone's bearer
token and the website's cookie resolve to the same user, and the stats record
has a unique index on email. One record per account is guaranteed at the
storage layer. Every divergence below is in a formula or a clock, not in
identity.

| Score | Phone writes | Website writes | Computed | Read by | Rule (owner) |
|---|---|---|---|---|---|
| Chapter mastery | rounds, as phone answers on the source problem | practice, review, diagnostic, quick start | server: max(diagnostic, study evidence); phone-only evidence capped | both | one number; games to 50; desk to 100 |
| Problem history and the review queue | yes (source phone) | yes (source desk) | server | website only | one history per problem |
| Total XP | rounds, capped 60 per local day | every action, uncapped | server | both | one total |
| Weekly XP, leaderboard | via total | via total | server, week by server clock | website only | |
| Days studied (count) | rounds, by the phone's day | every action, by the server's UTC day | server | both | one count, one day per calendar day |
| Days studied (the list) | same | same | server since 2026-09-19 | phone | the calendar |
| Exam date, name | set | set | | both | |
| Badges | never awarded | practice, review, diagnostic, exam | server | count on phone, full on web | |
| Problems answered | counted | counted | server | website | |
| Concepts held, rounds cleared, map state | yes | | phone (local mirror + server log) | phone | phone's own |
| Sessions per chapter, level ladder | | practice, review | server | website | website's own |
| Diagnostic and quick start | | yes | server | website; sets the mastery floor | |
| Exam simulation attempts | | yes | server | website | |
| Readiness and focus areas | | | both clients, same weights (checked) | both | one weighting |
| Paper flags | nothing writes them any more | | | website's Tonight card | dead |
| Feedback | yes | | server, emailed | owner | |
| One-time cues, tour seen | phone preferences | | | phone | phone's own |
| Diagnostic dismissed | | browser localStorage | | that browser | |

## 2. Findings, ranked by what they mean for a student

**F1. The desk cannot reach 100 today, on any chapter.** Study evidence
weights each correctly answered problem by a "maturity" that is meant to
grow as the problem is answered again across spaced reviews
(`service/mastery.js:67-72`). Nothing in the service ever writes the
`interval` field that maturity reads, so every problem stays at the lowest
weight forever. With every problem in a chapter answered correctly at the
desk, study evidence tops out between 55 and 88 percent depending on how
many problems the chapter has (Economics 50 problems, 55; Mathematics 135,
88). Only the diagnostic can lift a chapter above that, and it is capped at
60. The owner's rule "the website alone can take it from 0 to 100" is not
true in the code. Measured from `service/content.json` and the formula.

**F2. Games cannot reach 50 either, except in Mathematics.** Each game is
authored from one to three website problems (163 games from one, 130 from
two, 82 from three), and a round writes evidence on the problem, not the
round. So a chapter's games can only ever touch as many problems as they
draw on: Mathematics 48, most chapters 17 to 36. At the lowest maturity that
is a phone-only ceiling of 24 to 54 percent per chapter, under the 50 cap
everywhere but Mathematics. The cap is not what stops the phone; the
authoring is. Any "games have taken this chapter as far as they can" line
has to be computed from what the games can reach, not from the cap.

**F3. One evening can count as three study days.** Web writes date the day by
the server's UTC clock; the phone dates it by the student's clock. The live
run, at 18:00 Pacific, ticked a day for the phone rounds (local 19th), a
second for the website session (UTC 20th), and a third for a late phone round
(local 19th again, because the count only compares against the last date).
`service/routes/sessions.js:75`, `review.js:151`, `diagnostic.js:107`,
`quickstart.js:137`, `exam.js:90` versus `sync.js:85`. The website already
sends the student's local date on sessions and reviews and the server ignores
it for the tick.

**F4. Deleting an account leaves its phone work behind.** Account deletion
clears eight collections (`service/db/accountDeletion.js`) but not the
review-event log, the paper flags, or the feedback reports. The live run
proved it: after the QA account was deleted and recreated, 28 events and the
day's phone XP were still there, so the fresh account started with its XP cap
already spent. A privacy gap as much as a data one.

**F5. Quick start uses a different mastery formula.** Every other writer sets
chapter mastery to the higher of the diagnostic and the study evidence; the
quick start adds them (`service/routes/quickstart.js:153`, capped at 100). A
chapter with 40 from a quick start and 50 from practice reads 90 after a quick
start and 50 after anything else. The same account, two numbers.

**F6. The paid exam simulation adds no desk evidence.** It writes the attempt
and XP but no problem history (`service/routes/exam.js:48-139`), so 110
answered questions move mastery by nothing, although the mastery code
describes the simulation as desk evidence.

**F7. Badges are only evaluated on the web.** Practice, review, the diagnostic
and the exam award them; the phone's push and the quick start never do
(`service/routes/sync.js`, `quickstart.js`). Phone XP still counts toward
the XP badges, but they are only paid out on the next web action. The live
run showed two badges arriving at once on the first website session.

**F8. A second phone starts with an empty map.** The phone keeps its own
mirror of cleared rounds in the keychain and never reads the server's log
back, although `GET /api/sync/changes` returns every event and each event
names its game and round. A reinstall on the same phone survives (the
keychain does); a new phone or a second device does not.

**F9. The website cannot show the two halves.** The mastery endpoint returns
one total per chapter with a diagnostic and a study score, no phone-versus-
desk split, and no client shows one. A chapter built only from games stalls
with no explanation anywhere on either surface.

**F10. Smaller, all confirmed.** Paper flags have no writer left, so the
website's Tonight card runs on empty. The phone still carries an unreachable
lesson screen that posts web sessions. `updateChapterMastery` in
`service/db/diagnostic.js` is dead. A GET on `/api/topics` writes the stats
record. The diagnostic rebuilds chapter mastery from a fixed list and drops
any other key. The study-days count and list can disagree for accounts older
than the list. "Diagnostic skipped" lives in one browser's localStorage.

**What is right.** Identity. Idempotent phone pushes (a retried batch changes
nothing). Phone XP capped at 60 per day. Desk evidence resuming the same
curve in full after phone evidence. A desk problem re-answered on the phone
staying desk evidence. Both clients weighting readiness the same way. The
website seeing the phone's work the same day. The event log holding every
round from both surfaces.

## 3. The live run

`node scripts/auditSync.mjs --reset`, 2026-09-19 18:05 Pacific, against
fe4raccoons.com on the QA account. Twenty checks: seventeen passed as the
contract says; three failed only because deletion had left the previous
run's events behind (F4). Snapshots after each step:

| | start | 1 phone game | retry | +4 problems | 1 web session | late phone round |
|---|---|---|---|---|---|---|
| total XP | 0 | 0* | 0* | 0* | 75 | 75 |
| days studied | 0 | 1 | 1 | 1 | 2 | 3 |
| badges | 0 | 0 | 0 | 0 | 2 | 2 |
| problems answered | 0 | 1 | 1 | 5 | 10 | 10 |
| Mathematics study | 0 | 2 | 2 | 8 | 15 | 15 |
| events on server | 28* | 36 | 36 | 40 | 45 | 46 |

\* leftovers from the deleted account (F4); on the first, truly fresh run the
same steps gave XP 0, 40, 40, 60, 135, 135 and events 10 to 28.

## 4. Fixes, in order

1. **Make the desk reach 100 (F1).** Write and grow `interval` on problem
   history as the model intended: a correct answer after 7 or 21 days raises
   the problem's maturity. Medium; one server file, tests, no migration.
   Done 2026-09-20, then replaced 2026-09-25: the desk half is now coverage
   (share of the chapter's problems held), see ADR 0019. No re-asks feed
   the number.
2. **Define the games half so the hand-off is exact (F2, F9).** Recommended:
   the games half of a chapter is 50 times the share of its games cleared,
   the desk half is the study curve from desk evidence with the diagnostic
   as its floor, and the one number is the smaller of 100 and their sum.
   The server returns both halves; both surfaces show them; the phone says
   "games have taken this chapter to 50" only when it is true. This replaces
   the evidence cap. Medium; server, phone, website. Needs the owner's yes,
   because it changes what the number means.
3. **One clock (F3).** Every write ticks the day by the student's local date
   (the website already sends it; the diagnostic, quick start and exam gain
   it), and a day already in the list never ticks again. Small.
4. **Deletion clears everything (F4).** Three collections added. Small.
5. **One formula in quick start (F5).** One line. Small.
6. **The simulation counts as desk work (F6).** Write problem history on
   submit. Small to medium.
7. **Badges everywhere (F7).** Evaluate on the phone push and the quick start;
   the phone shows a badge when it lands. Small.
8. **The phone rebuilds from the server (F8).** On sign-in, pull the log and
   rebuild cleared rounds; keep the keychain mirror as the cache. Medium.
9. **Tidy (F10).** Remove the paper-flag card or give it a writer; delete the
   phone's dead lesson screen and the dead server function; stop the GET
   write. Small.

After 1 to 3 the single record is honest and the numbers on the two surfaces
mean the same thing. 8 is what makes the phone a view of the record rather
than a second one, which is the door to the "one source of truth" design the
owner asked about; that design note follows this audit.

## 5. Status, 2026-09-20

Owner's decisions on the morning of the 20th: the cap is 50; mastery is one
number with two halves, the desk alone to 100, the games to 50; the cap is
the hand-off; the clock is the student's; the phone becomes a view; deletion
clears everything. All six were built and deployed the same day, in three
deploys' worth of commits shipped as one:

| Fix | Commit | State |
|---|---|---|
| 3 One clock (F3) | aa0c241 | live; the proof shows one day for one evening |
| 4 Deletion clears everything (F4) | aa0c241 | live; the proof starts from an empty log after a reset |
| 2 Games half, one formula (F2, F5, F9, part of F10) | ad9e5f6 | live; every account recomputed (340); both surfaces show the games share |
| 1 Maturity (F1) | 5645d88 | live; grows from the next spaced right answer on |
| 6 Simulation as desk work (F6) | 5645d88 | live |
| 7 Badges everywhere (F7) | 5645d88 | live |
| 8 The phone rebuilds from the server (F8) | mobile, build after 853 | on sign-in and at launch |
| 9 Tidy (F10) | mobile ad9e5f6, server after | dead lesson screens and the dead writer removed; the topics GET write and the paper-flag card left as they are, documented below |

The proof, `node scripts/auditSync.mjs --reset`, passed 20 of 20 against
fe4raccoons.com after the deploy.

Two things left alone on purpose. `GET /api/topics` still persists the old
level ladder's decay on read; it is the legacy ladder the website's study
page no longer shows, and removing the write changes nothing a student sees,
so it waits for the single-record design. The website's Tonight card falls
back to the day's phone misses when there are no paper flags, so it is not
empty; the flag route stays for a future hand-off feature.

One thing the maturity fix does not do on its own: a problem answered right
once and never again stays at the lowest weight, because the review queue
holds only missed problems (the study-load policy of 2026-06-29). The desk
reaches 100 through spaced re-answers, which today come from practice
repeats and the simulation. Whether known problems should come back at 7
and 21 days is a policy question for the owner, not a bug.
