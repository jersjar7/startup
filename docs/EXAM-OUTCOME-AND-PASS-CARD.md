# Exam outcome and the pass card

Status: specification, approved 2026-10-06. Build on `development`.

What this covers: the question we ask after somebody's exam, the three surfaces
that ask it, what each answer leads to, and the share card a pass earns. Most of
the asking is already built; most of the answering is not.

---

## 1. Why this exists

Whether a student passed is the single most valuable record the platform does
not collect. Without it there is no way to show a department that the product
moved their pass rate, and no way to calibrate a readiness prediction against
anything real.

The non-response is not random, and that is the whole difficulty. Somebody who
failed is less likely to come back and say so than somebody who passed. Every
decision below is shaped by that one fact: equal weight on the answers, no sign
in before answering, four asks rather than one, and a notification that reaches
a phone whose owner has stopped opening the app.

---

## 2. What is already built

| Surface | When | Way out | Lands on |
|---|---|---|---|
| Email | exam +9, +16, +30, +60 | Ignore, or unsubscribe | A web page, no sign in |
| Notification | exam +9, 10am local | Back gesture only | Full screen in the app |
| Home card | every open from exam +9 | An X, which snoozes to the next ask | Stays on the home screen |

Answering on any one silences all three. The morning job already excludes anyone
who has answered, declined, opted out of lifecycle email, or had all four asks.

The email is held behind `EXAM_OUTCOME_ENABLED` (off) pending approval to send.

### Known good, do not regress

- A no-show is recorded as `sat: false, passed: null`, never `passed: false`.
  Storing a failure against somebody who never sat the exam would make every
  pass rate computed from this field wrong.
- A second tap, or a mail client's background prefetch, can never overwrite an
  answer. `shouldRecord` enforces it and `examResultLink.test.js` guards it.
- The two real answers are equal-weight buttons. An earlier draft made "I
  passed" an ember button and the others grey links, which is exactly the bias
  this question exists to measure.

---

## 3. What is wrong today

### 3.1 The email path is a different product

The landing pages are the unsubscribe template with different words in them.
They were built to confirm an opt-out and they still behave like one: a white
card, centred body text, and a button back to the homepage.

Measured against the app, answering the same way:

| | The app says | The email path says |
|---|---|---|
| The middle answer | Not this time | I did not pass |
| The question | Your exam has been and gone. | Jerson, how did it go? |
| After a fail | Weakest chapter, and a new exam date | Thank you, and a link to the homepage |
| After a no-show | That happens, and a new exam date | Thank you, and a link to the homepage |
| After a pass | Share card, then the PE question | Congratulations, and nothing else |
| Body text | Left aligned, per the brand rules | Centred, inherited from the unsubscribe page |

The person this hurts most is someone who failed, has stopped opening the app,
and answered honestly from their inbox. They get the thinnest screen in the
product. That is backwards: they are the most motivated user we have, because
they are about to sit it again.

### 3.2 The notification schedule goes stale

`rearm` is called from `ProfileTab.initState` and from the notifications toggle.
Nothing else calls it. So:

- Saving a new exam date does not rebuild the schedule. They are counted down to
  an exam that moved, and asked about an outcome on the wrong day.
- Finishing a study session does not rebuild it. The 7pm "you have not studied
  today" fires on a day they studied, which is the most annoying possible
  notification to send an active user.

Both clear on the next cold launch, which is no defence.

### 3.3 Our exam question counts are from a retired specification

`src/data/chapters.js` carries a `qs` range per chapter. All fifteen reconstruct
exactly from the NCEES FE Civil specification **effective January 2014**, which
was superseded in July 2020. The 2014 document has eighteen knowledge areas; our
fifteen are those eighteen with three pairs merged, and the arithmetic is exact:

| Our chapter | 2014 areas | Sum | `chapters.js` |
|---|---|---|---|
| Mathematics & Computational Tools | Mathematics 7–11 + Computational Tools 4–6 | 11–17 | 11–17 |
| Water Resources & Env. | Hydraulics 8–12 + Environmental 6–9 | 14–21 | 14–21 |
| Structural Engineering | Structural Analysis 6–9 + Structural Design 6–9 | 12–18 | 12–18 |

`research/civil/fe-civil-exam-topics.md` claims the July 2020 spec and disagrees
with the code on eleven of fifteen chapters. Two sources in the repo, neither
matching the other.

**Unverified:** the current counts. The session's web search budget was spent and
NCEES does not link the PDF from their exam page. Cheapest test: download the FE
Civil specification from ncees.org into `research/civil/` and reconcile all
fifteen in one pass. Our research note is a secondary source we wrote, so it is
not a substitute.

**Not in scope here, but flagged:** those counts drive what the site tells
students the exam looks like, and the chapter weighting decides what the platform
puts in front of them. If that weighting is calibrated to a retired blueprint,
study time is being steered by it. Tracing that through the exam simulation and
the mastery model is a separate piece of work and needs its own decision.

The pass card is deliberately designed to not depend on any of this.

---

## 4. The pass card

### 4.1 What it is

A horizontal image, 1200 × 627, that somebody who passed can post. It carries the
claim, their name, and a numbered index of the exam's fifteen chapters. It is the
same for every person except the name and the month.

Option C of three, chosen 2026-10-06. The other two:

- **A, per-person coverage bars.** The best looking of the three, and the reason
  is that a passing student's bars run 68–100%, so the column reads as full.
  Rejected: the figures are personal, and printing the same ones for everybody
  would make every card on LinkedIn claim a study record its owner never had.
- **B, bars by what the exam asks.** Honest and general, but it averages 45% of
  the track against A's 87%, so it reads as a specification rather than an
  achievement, and short bars look like weakness to anyone who does not read the
  heading. Also blocked by 3.3.

No bar can be both general and flattering without claiming something untrue, so
C stops trying and lets the headline carry the achievement. It also cannot go
stale.

### 4.2 Layout

Design size 1200 × 627. Exported at 2× (2400 × 1254).

```
┌─────────────────────────────────────────────────────────────┐
│  FUNDAMENTALS OF ENGINEERING        ALL FIFTEEN CHAPTERS.    │
│                                     110 QUESTIONS.           │
│  FE Civil                           01  Mathematics          │
│  passed.                            02  Probability & Stats  │
│                                     ...                      │
│  Jerson Garcia, EIT                 15  Construction Eng.    │
│  Prepared with FE for Raccoons                               │
│  ─────────────────────────────────────────────────────────   │
│  DISCIPLINE      RESULT     DATE            FE4RACCOONS      │
│  Civil Eng.      Pass       October 2026                     │
└─────────────────────────────────────────────────────────────┘
```

Ground is engineering paper: `#FDFCF8`, a 24px grid at 5.5% ink, a 120px grid at
10%. Padding 52. The chapter index sits at x=700, rows 25.6 apart, the number in
ember mono and the name in Inter 500, each row underlined at 10% ink. The title
block is a 2.5px rule with three cells at 232px pitch and the wordmark right
aligned.

Type: DM Sans 800 at 84px for the claim, DM Sans 700 at 37px for the name,
JetBrains Mono for every label. Ember `#E8683A` is the only accent.

### 4.3 One source, two renderers

The layout figures and the fifteen chapter names live in **one shared file** with
a dated source line. The reason our question counts went stale unnoticed is that
nothing in the code says where they came from or when.

- **Web:** Canvas 2D in the browser, exported with `toBlob`. No server-side
  rasteriser, no new dependency on the box. This was verified by building a
  working renderer before specifying it.
- **Mobile:** a Flutter painter drawing the same figures, captured and saved to
  the photo library.

The two must produce the same image. A golden test on each side, compared
against the same reference, is how that stays true.

### 4.4 The name

`POST /api/auth/create` collects email, password, acquisition, school and
graduation. **It never collects a name.** `firstName` only ever arrives through
`PUT /api/auth/profile`, so for most accounts the card has nothing to put on it.

So asking is the common path, not an edge case:

- If a name is on the account, use it and do not ask.
- If not, ask for it immediately before the card is drawn, on both surfaces, as
  one field and one button.
- The name is saved to the profile, so it is asked once ever, not once per card.
- `, EIT` is appended by the renderer, never typed by the user.

Never block the answer on it. The outcome is recorded first; the name is only
ever asked on the way to the card.

### 4.5 Where it lives

Not only at the end of an email. A permanent page in their account on both
surfaces, so somebody who passed in October and changes jobs in March can come
back for it without us having sent anything.

---

## 5. The flows to build

### 5.1 Web, arriving from the email

```
email · "I passed"
   └→ GET /api/email/exam-result/<token>?a=passed     answer recorded, no sign in
        └→ W1  Congratulations + the card shown, not described
             └→ [name missing?] W1b  "What name should it carry?"
                  └→ W2  The card · Download · Share on LinkedIn
                       └→ W3  The PE question
```

No sign in anywhere. Nothing on the card is private except the name, and the
tokenised link already identifies the account.

### 5.2 Mobile, after answering in the app

```
ExamOutcomeCard · "I passed"
   └→ attempt number
        └→ [name missing?] "What name should it carry?"
             └→ P1  The card · Save the image     ← first photo permission ask
                  └→ P2  The PE question
                       └→ home
```

Someone who declines the card skips straight to the PE question, so it is never
lost to a "not now".

### 5.3 Both result pages get the app's endings

The web pages adopt the app's words and its two endings. The server already
computes mastery for the website, so the fail page can name the same weakest
chapter and offer the same new exam date. One shared set of copy, two renderers.
This closes five of the six rows in 3.1. The sixth, the card, is closed by
section 4.

Labels align on the app's wording: **I passed / Not this time / I did not sit
it**, and the question becomes "Your exam has been and gone."

---

## 6. Build order

1. **The notification rearm bug** (3.2). Small, independent, and it ships in the
   TestFlight build either way.
2. **The shared card file**: layout figures, the fifteen names, the dated source
   line.
3. **The web renderer and the three pages**, including the name prompt.
4. **The Flutter painter**, the save plugin and the photo permission.
5. **The result pages adopting the app's endings and wording** (5.3).

Each step lands on `development` as its own commit with tests.

---

## 7. Open, needing the owner

- The current NCEES FE Civil specification PDF, dropped into `research/civil/`,
  so section 3.3 can be closed.
- Whether to trace the stale weighting through the exam simulation and the
  mastery model, and when.
- Approval to switch `EXAM_OUTCOME_ENABLED` on, which is what starts the asking
  at all.
