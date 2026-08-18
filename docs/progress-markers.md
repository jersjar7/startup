# Progress markers on the chapter page

**Status:** Specified, not built. Decisions locked with the owner 2026-08-13.

## Why

A real user (Victoria Nally, iMessage, 2026-08-12) asked for the only thing the
study experience does not give her:

> "Once I complete something, a lesson or practice, it would be nice to have it
> checked off. Just so I know what I have and haven't done."

She is right, and the situation is worse than "missing". The chapter page already
makes two progress promises it does not keep:

1. **Every subtopic row shows a hollow circle.** `study.jsx` defines four states
   (`locked | available | in-progress | mastered`) with a `CheckCircle` icon
   wired for the last one, then hardcodes `const status = 'available'` with the
   comment "Mastery state would come from API — placeholder for now". The control
   looks like it reports something and never has.
2. **The primary button always says "Start:" and always points at the first
   lesson of the first subtopic**, regardless of what the user has done. Come
   back after finishing four lessons and it still invites you to start lesson
   one. That is not merely missing information, it is confidently wrong.

Underneath, the study page fetches **no user data at all** — it renders entirely
from bundled content, deliberately (see the comment in its `useEffect`). Giving
that page a sense of who is looking at it is the real work here. Drawing dots is
the easy half.

## The structure this hangs off

```
15 chapters -> 51 subtopics -> 135 lessons -> 405 exercises
```

**Every lesson has exactly 3 exercises. All 135 of them.** That is what makes a
five-state marker exact rather than a rounded bucket, and it is the single fact
the whole design depends on. If lessons ever stop having exactly 3, this spec
needs revisiting.

Three problem pools exist and **share no ids whatsoever** (verified):

| Pool | Count | Where it appears |
|---|--:|---|
| Lesson exercises | 405 | inside a lesson, 3 each |
| Chapter practice | 248 | the "Practice All" row, 11-29 per chapter |
| Exam bank | 473 | diagnostic + exam simulation only |
| **Total** | **1,126** | |

So a student can finish a lesson's 3 exercises *and* the whole chapter practice
set and never meet the same problem twice.

## One question per level

No level answers another level's question.

| Level | The question | Signal | State today |
|---|---|---|---|
| Chapter | *How ready am I?* | Mastery % | **Exists** |
| Subtopic | *How far through this am I?* | "4 of 6 lessons" | To build |
| Lesson | *Have I done this, and how did it go?* | Five-state dot | To build |
| Exercise | *Which ones did I get?* | End-of-session summary | **Exists** |

## The five states

Five states. **No red anywhere.**

| State | Marker (web, shipped) | Meaning |
|---|---|---|
| Untouched | *(nothing)* | never opened |
| Attempted | **hollow ember ring** | tried it, none right yet |
| 1 of 3 | filled ember | |
| 2 of 3 | filled sunbeam | |
| 3 of 3 | filled forest | |

### SUPERSEDED ON MOBILE 2026-08-17: the capsule, and one colour

The five states below are unchanged. The **marker** and the **palette** are not.
The web still ships the dot above; mobile now draws a small vertical capsule that
fills bottom-up, **all of it forest green**. Port to the web once it has been
judged on a real phone.

| State | Marker (mobile) |
|---|---|
| Untouched | *(nothing, space held)* |
| Attempted | outlined capsule, empty |
| 1 of 3 | filled a third |
| 2 of 3 | filled two thirds |
| 3 of 3 | filled solid |

**Why the capsule.** A dot has one channel, so the three-colour ladder existed to
encode HOW MANY in that one channel. The capsule encodes the count in fill
height, at which point the ladder is a second encoding of the same number.

**No internal dividers.** The capsule shipped first with hairlines marking the
three compartments. Three options were built and compared side by side on device
— dividers always, dividers except when full, and none — and the owner chose
none. The fill is still QUANTISED to thirds, from the server's own `correct` and
`total`; it is a count of exercises, not a percentage.

The cost was raised before the choice and accepted: an empty capsule no longer
shows that three things are waiting inside it, so "tried it, got all three wrong"
reads as a plain outline. It stays distinct from untouched, which draws nothing
at all, and the long-press still says it in words.

**Why one colour, and why forest specifically.** The ladder had a real defect
that only became visible once it shipped: this app paints a correct answer forest
and an incorrect one ember (`exercise_screen.dart`), so a lesson with 1 of 3
right was reported in **ember, the wrong-answer colour**. Green segments now mean
what green already means one screen deeper: correct answers, accumulating.

It also brings the screen inside the brand rule of at most two accents per
section. The ladder could put ember, sunbeam and forest in a single open subtopic.

**The cost, accepted.** Forest also means *done* elsewhere on the same screen (the
mastery ring, the subtopic fraction when everything is right), so green now
appears on lessons nowhere near finished. Fill height carries that difference
instead of hue.

**Accessibility improves rather than regresses.** The dot needed hue to say how
many; the capsule needs none, so the signal now survives any colour vision.

**The segments are a count, not an identity.** The server sends `correct` and
`answered`, never which problems, so a filled second segment does not mean
"question 2 was right". That is why the fill is always contiguous from the bottom
and why the long-press text still says the count in words.

**Why "attempted" is its own state and not blank.** Someone who tried a lesson
and got nothing right is exactly who should go back to it. Leaving that blank
would make the page's most useful row indistinguishable from one nobody has
opened.

**Why not red.** `--error` (#D64045) means error in this brand, and the review
tab was deliberately built with no guilt counters and no red debt. Struggling on
first contact with a hard lesson is normal learning, not a fault. There is also
a true and encouraging reading available: a missed problem is *already* queued
into review automatically, so the hollow ring means "these are coming back",
not "you failed".

**Accessibility.** Ember, sunbeam and forest differ mainly by hue. Hue alone must
not be the only carrier: hollow-vs-filled already separates the "attempted"
state, and every marker needs a text label for screen readers and hover
(e.g. `aria-label="2 of 3 exercises correct"`). Do not ship a colour-only signal.

## Definition of "got it right"

**Ever got it right**, not first try.

`problemHistory` stores `timesCorrect` / `timesIncorrect` per `{email, problemId}`,
not first-attempt correctness, so "ever" is what the data actually supports.

Consequences, accepted deliberately by the owner:

- **Markers only ever improve.** A lesson that reaches forest stays forest
  permanently, even if the user would fail it today.
- The dots will therefore drift away from current ability over months. That is
  fine: **completion is not readiness, and mastery is the thing that tells the
  truth.** This separation is the point, per the anti-illusion-of-competence rule
  in `mobile-app-north-star.md` — a row of green dots must never read as "ready
  for the exam".

## The four surfaces

### 1. Lesson row — the five-state dot
Inside an expanded subtopic. This is Victoria's actual request.

### 2. Subtopic row — "2 of 9 exercises"
Counts **exercises**, not whole lessons. Visible while the row is collapsed,
which is how the page opens (all subtopics start collapsed, one at a time).

CHANGED 2026-08-13, after seeing it on screen. This originally counted completed
lessons, with the under-reporting written off as acceptable. Built and viewed,
it was clearly wrong: a subtopic holding one attempted lesson and another at 2
of 3 reported **"0 of 3 lessons"** while the dots inside it plainly showed work.
The collapsed row is the only progress signal most people ever see, so it must
never contradict the markers underneath it.

Counting exercises never under-reports, needed no endpoint change, and reads
"2 of 9 exercises" for that same subtopic. The whole-lesson count is still
returned as `complete` for anything that wants it.

### 3. Chapter practice — its own row, plain fraction, **no dot**
e.g. `Practice All Mathematics Problems ......... 12 of 29`

**Why no dot.** The five-state scale is calibrated to exactly 3 items. Practice
sets run 11-29. Stretching the scale across 29 would (a) make one colour cover
many different results, (b) make forest mean "3 correct" on a lesson and "29
correct" one row below, and (c) make forest nearly unreachable. The dot
vocabulary stays reserved for the one thing it describes exactly.

### 4. The guided-entry button — BUILT, THEN REMOVED

Originally the page's primary CTA always said "Start:" and always pointed at the
first lesson of the first subtopic, no matter what had been finished. That was
genuinely broken, so it was rebuilt to say "Continue:" and point at the first
lesson below complete.

**It was then removed entirely (2026-08-13, owner's call), and that was right.**

Once the markers existed, the button was a second voice saying what the dots
already said, and less precisely: the dots show the state of every lesson at
once, while the button could only nominate one. Two answers to "where am I" is
worse than one.

Removing it also resolved a duplication: when every lesson was complete the same
slot offered "Practice: N problems to go", which pointed at the very same place
as the chapter-practice button further down the page.

The lesson for anything similar: a marker that shows state does not need a
control that narrates it. See also the chapter-complete banner, removed for the
same reason on the same day.

### Also verified, no work needed
The "Practice All" flow already ends on a summary. `/problems/:topicId` is the
same player used for lessons and practice, and its `SUMMARY` phase shows
`Score: n/N (x%)`, the XP breakdown and the streak. **Verify during QA, do not
rebuild.**

### Also: delete the hollow circle
The decorative circle on each subtopic row goes away. With fractions at subtopic
level and dots at lesson level, keeping it would put a third circle vocabulary on
one screen.

## Data

**No migration, no backfill, no new writes.** Everything needed is already being
recorded and has been all along, so existing users see their history the moment
this ships.

- Every answered problem upserts `problemHistory` on `{email, problemId}` with
  `topicId`, `timesCorrect`, `timesIncorrect`, `lastSeen`
  (`service/db/stats.js`, called from `sessions.js`, `review.js`, `sync.js`).
- Lessons own their problems, so `problemId -> lessonId` is derivable from
  bundled content. `service/content.json` already carries the full
  chapter/subtopic/lesson/problem tree; chapter-practice problems additionally
  carry an explicit `lessonId`.

What does not exist and must be added:

- A `problemId -> {chapterId, lessonId}` map, built from content, not hand-kept.
- A read-only endpoint returning per-lesson correct counts for the current user.
- The study page fetching anything at all.

## Build phases

Each phase is independently shippable and leaves the product coherent.

### Phase 1 — The map and the endpoint (no visible change)
Build the `problemId -> {chapterId, lessonId}` lookup from content, and one
read-only endpoint returning, for the signed-in user and a given chapter, the
distinct-correct count per lesson plus the chapter-practice correct count.

Everything else depends on this and none of it is visible, so it ships alone and
safely.

**Done when:** the endpoint returns correct counts for a known account, verified
against `problemHistory` by hand for at least one lesson at each of the five
states. Unit tests cover the map (every one of the 405 exercises resolves to
exactly one lesson) and the state thresholds (0/1/2/3 -> the right state).

**Risk:** the map silently missing problems would show everyone as untouched.
Assert the map's size equals 405 in a test so a content change that breaks it
fails the suite rather than the UI.

### Phase 2 — Lesson dots
Fetch on the study page (loading and error states included, since it currently
fetches nothing) and render the five-state marker on each lesson row, with
accessible labels.

This alone satisfies Victoria's request and is the phase worth shipping fastest.

**Done when:** a test account showing one lesson at each of the five states
renders five distinguishable markers, verified visually at desktop and mobile
widths.

### Phase 3 — Subtopic fractions, and delete the dead circle
Add "4 of 6 lessons" to the collapsed row, counting forest only. Remove the
hardcoded circle and its now-unused status map.

Grouped deliberately: both touch the same component, and removing the misleading
circle should not ship separately from the thing that replaces it.

**Done when:** the fraction matches a hand count, and no hardcoded `status`
remains in `study.jsx`.

### Phase 4 — the guided-entry button (built, then removed)
Built as "Continue:" pointing at the first lesson below complete, then deleted
along with the whole guided-entry slot once it was clear the markers had made it
redundant. See surface 4 above. Net effect of this phase: the chapter page has
ONE call to action, the chapter-practice button, and the markers do the rest.

### Phase 5 — Chapter practice row
Give practice its own row at the bottom with a plain "12 of 29" fraction and no
dot. Confirm the existing practice summary appears on the way out.

**Done when:** the fraction matches distinct practice problems answered
correctly, and the summary is confirmed present (not rebuilt).

### Phase 6 — Verification pass — DONE 2026-08-13

Twelve combinations driven in a real browser: six chapter states x two widths
(1150px and 390px). Every one asserted programmatically rather than eyeballed:

- no horizontal overflow at either width
- the subtopic header fraction EQUALS the sum of its own lesson dots
- exactly one call to action on the page
- every visible marker carries an aria-label

All twelve passed. The failure state correctly falls back to the plain lesson
count ("6 lessons") instead of fabricating "0 of 18".

Keyboard: the marker is reachable by Tab, focus reveals the bubble, Escape
dismisses it, and its accessible name is the same sentence the bubble shows.

Data, re-checked after all five phases: 40 real user/chapter pairs recomputed
from production `problemHistory`. All five lesson states occur naturally
(368 complete, 87 two-correct, 47 one-correct, 50 untouched, 15 attempted), and
158 subtopic roll-ups were cross-checked against their own lessons with zero
mismatches.

**A deliberate limitation.** The RENDERING of the richer states was verified with
stubbed API responses, not by manufacturing study activity on the QA account.
The render path is identical whatever the numbers' origin, and the numbers
themselves were verified against real accounts in phase 1 and again here.
Generating fake study activity would have written XP, sessions and history to
production for an account that is NOT excluded from analytics — see the note
below.

## Known, not fixed here

`admin+test1@oqupa.com` is the QA account but is NOT excluded from analytics.
`isExcluded()` matches exactly against `admin@oqupa.com` and the long-dead
`qa-bot@fe4raccoons.com`, while `scripts/baseline-report.js` strips plus-tags and
DOES exclude it — so the two disagree about whether that account is a real user.
It affects the leaderboard, funnel counts, the admin user list and analytics.
Harmless at present (225 XP against a 3,005 XP leaderboard cutoff) and it did
not block this work, but it is why phase 6 avoided generating study activity.

## Out of scope, deliberately

- **The Flutter app.** It mirrors this same chapter/subtopic/lesson structure and
  will eventually want the same markers. The decisions here should carry over
  rather than be reinvented, but it is not part of this work.
- **Any change to mastery.** Mastery already answers the readiness question and
  is not touched.
- **Decay.** Markers are monotonic by decision. If completion should ever expire,
  that is a separate discussion with a separate rationale.
