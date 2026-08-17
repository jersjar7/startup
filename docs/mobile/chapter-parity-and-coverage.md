# Mobile: progress parity, lesson navigation, and the coverage gap

**Status:** Specified, not built. Written 2026-08-17 after driving the TestFlight
build on a real phone.

Four items, found together but genuinely different in kind. Read the last one
first if you only read one: it is not app work and it is the biggest of them.

---

## 1. The app cannot show progress (parity with the web)

The Flutter chapter screen (Study L2) shows a chapter mastery ring and
`"3 lessons"` per subtopic. Per lesson it shows nothing. It is the same blindness
the website had until 2026-08-13.

**The design note that justified this is now out of date.** `mobile-flutter-screens`
records "NO per-lesson mastery (web only tracks chapter-level)", which was true
when the app was designed and is not true now. `GET /api/progress/chapter/:id` is
live in production and returns, per chapter:

- per lesson: `{ correct, answered, total, state }` over five states
- per subtopic: `{ complete, total, exercisesCorrect, exercisesTotal }`
- practice: `{ correct, total }`

`mobile/lib/features/study/content_repository.dart` does not reference it. Every
design decision was settled on the web last week (see
`docs/progress-markers.md`) and should carry over unchanged rather than be
re-litigated: five states, three brand colours, no red, exercise fractions
rather than lesson counts, and no CTA narrating what the markers already show.

**One decision the phone forces that the web did not.** At 390px the web stacks
the fraction under the subtopic name on its own line. The app's rows are the same
width, so either the same stack or a short form (`2/9`) is needed. Pick before
building.

**Also carry over the marker explanation.** On the web the dot is a button that
opens a bubble saying "2 of 3 exercises correct", because a colour alone is not
self-explanatory and `title` tooltips do not exist on touch. The app needs the
equivalent — long-press or tap — or the markers are a private language.

---

## 2. iOS deployment target is 13.0

Apple warned on the first TestFlight upload (ITMS-90068). From Spring 2027 all
uploads must target 15.0 or later. Build 481 was accepted; this is a deadline,
not a defect.

Set in four places, all currently 13.0:

- `mobile/ios/Runner.xcodeproj/project.pbxproj` — three build configurations
- `mobile/ios/Podfile` — line 2, currently commented out

Costs almost no devices: iOS 15 runs on the iPhone 6s and later, the same
hardware floor as iOS 13. The only people excluded are those who have never
updated since 2021.

---

## 3. The lesson navigation creates near-empty screens

Study L3 lists a lesson's headings as a numbered "In this lesson" table of
contents, and tapping one opens a sub-screen containing just the blocks under
that heading.

Driven on a phone, "Slope-Intercept Form" opens a screen holding **one formula
and one line of text**, with roughly 80% of the screen blank. So does
"Point-Slope Form". This is not a rendering bug: that is genuinely all the
content under those headings.

Measured across the bank:

| | value |
|---|--:|
| headings per lesson | median **3**, max 6 |
| content blocks per lesson | median 13 |
| lessons with 6 headings | **2 of 135** |

So the typical lesson costs three taps and three back-presses to read three
formulas that fit comfortably on one scrollable screen. The pattern was chosen
deliberately ("adds a light topic-read sub-screen under the lesson; accepted for
better phone UX") but the built result argues against it.

**It also diverges from the web**, which the mobile spec says to mirror: the web
renders all blocks inline through `LessonContent`, one scroll, no drilling.

**And it buries the exam-day callouts.** They are the last blocks in a lesson, so
they land at the bottom of the final topic's sub-screen — the least-visited
corner of the lesson.

**Proposed:** render the lesson as one scrolling page like the web. Keep the
heading list only if it becomes an anchor jump within that page, not a
navigation push.

---

## 4. Six formulas taught, three ever tested — THE BIG ONE

Not app work. Found through the app, lives in the content, affects the website
identically.

Every lesson has exactly 3 exercises. Lessons teach as many formulas as the topic
needs. Those two facts have quietly diverged:

| | value |
|---|--:|
| formulas taught across the bank | **436** |
| lesson exercises available to test them | **405** |
| lessons teaching MORE than 3 formulas | **59 of 135 (44%)** |
| lessons teaching more than 6 | 8 |
| worst case | `dynamics/work-energy-power` — **10 formulas, 3 problems** |

Worked example, `mathematics/straight-lines-quadratics`. It teaches six formulas.
Its three problems test slope-from-two-points, perpendicular lines, and the
quadratic formula. **Slope-intercept form, point-slope form and the distance
formula are taught and never practised.** A student can finish that lesson, see
it go forest green, and never have been asked about half of what it taught.

That last sentence is why this matters more than the other three items: the
progress markers we just shipped will report "complete" for a lesson whose
content is only half-tested. The marker is honest about the exercises. It is the
exercises that are incomplete.

**This is a content decision, not an engineering one**, and it is the owner's:

- accept it, and treat 3 problems as a sample rather than a coverage guarantee
- add exercises so every taught formula is tested at least once (roughly 60
  lessons need 1-7 more each; the constraint is authoring and verification, not
  code)
- or split over-stuffed lessons so each still has 3 problems for less material

Whichever way, note that "3 exercises per lesson" is now asserted at build time
(`scripts/gen-content.mjs`) and the five-state marker is calibrated to it. Adding
a fourth problem to one lesson breaks the build on purpose, and the marker design
needs revisiting with it. Splitting lessons does not.

---

## Build phases

Ordered so each ships alone, cheapest and most certain first.

### Phase 1 — iOS deployment target (30 min)
Raise 13.0 to 15.0 in the three build configurations and uncomment the Podfile
line to match. Rebuild, run on the simulator, ship a TestFlight build and confirm
Apple stops warning.

**Done when:** a build uploads with no ITMS-90068, and the app still launches.

Deliberately first: unrelated to everything else, has an external deadline, and
proves the fastlane pipeline still works before anything harder rides on it.

### Phase 2 — Progress markers in the app (parity)
Add a progress call to `ContentRepository`, then render on L2: the five-state
marker per lesson and the exercise fraction per subtopic, plus the practice
fraction. Reuse the web's decisions verbatim; do not redesign.

Includes the marker explanation (long-press or tap) and the same honesty rule:
**unknown progress must not render as untouched.** If the call fails, withhold
the markers and say so, rather than telling somebody they have done nothing.

**Done when:** a real signed-in account shows markers matching the website for
the same chapter, side by side, and a forced failure shows no markers rather than
empty ones.

### Phase 3 — Lesson navigation (one scrolling page)
Replace the topic sub-screen push with inline rendering of all blocks, matching
the web. Keep the heading list only as in-page anchors if it still earns its
place. Verify the exam-day callouts are now visible without hunting.

**Done when:** a lesson reads top to bottom in one scroll on a phone, with no
screen that holds a single formula, and the callouts are reachable by scrolling.

Third because it is a design change rather than a port, and it should not block
parity.

### Phase 4 — Coverage: DEFERRED 2026-08-17 (owner)

Decision: **not now, and not because it was missed.**

Owner's reasoning: the site and the app are deliberately built so questions are
modular — problems are resolved by id through one bank, the app is a thin client
over the content API, and nothing downstream is coupled to a particular problem.
So exercises can be added, replaced or re-cut later without breaking the app, the
markers, or the review queue. The material can wait; the app cannot.

That holds up. The one thing to carry forward is the constraint noted above:
"exactly 3 exercises per lesson" is asserted at build time and the five-state
marker is calibrated to it, so whoever revisits this should expect the build to
fail loudly the first time a lesson gains a fourth problem. That is the assertion
doing its job, not a regression.

Nothing in phases 1-3 depends on this, which is why it can sit.

---

## Not in scope

- The conceptual/handbook-derived question bank discussed on 2026-08-12. Still a
  2027 asset; see the reservations in that conversation (copyright on handbook
  wording, the verification burden, and MCQ being the weakest retrieval mode).
- Chapter practice on mobile (L2 still shows a "coming next" SnackBar).
- Profile's paper hand-off card, Exam Sim card, Edit profile, Reminders.
