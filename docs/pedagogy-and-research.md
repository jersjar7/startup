# Pedagogy & Research — Why the Onboarding Works This Way

_Last updated: 2026-06-07._

This is the evidence base behind the [quick-start diagnostic
design](./quickstart-diagnostic-design.md). Each principle below is tied to a
concrete product decision. The point is durability: when someone later proposes
"let's just make the first questions trivially easy" or "let users pick their
chapters," this file is the record of why we didn't — and what would have to
change in the evidence for that to be a good idea.

A note on method: this design was pressure-tested adversarially. Instincts were
not accepted because they sounded right; each was checked against published
research, and two appealing ideas (a "trap" opener and user-chosen chapter
coverage) were **rejected on the evidence**. Keep that bar.

---

## 1. Self-efficacy → confidence-first, no traps

**Principle.** Bandura's self-efficacy theory: a learner's belief that they can
succeed is one of the strongest predictors of effort and persistence, and the
most powerful source of that belief is a **mastery experience** — actually
succeeding at something real.

**Design consequence.**
- Every segment opens with the **easiest** question in the set, so the first
  thing a user does is (usually) succeed.
- We **rejected a "trap" opener.** Manufacturing an early failure to "humble"
  the user directly undermines the mastery experience we need at the moment of
  highest drop-off risk.
- But openers are **real FE questions**, not toy ones — see §2.

## 2. Desirable difficulty & credibility → fair, not trivial

**Principle.** Bjork's "desirable difficulties": learning that feels too easy
produces weak retention and, for an exam product, destroys credibility. An
adult studying for a professional licensure exam will not trust a tool that
feels beneath the real test.

**Design consequence.** Confidence-first means *start with the easiest real
question*, not *fake the difficulty*. The 5-question set ramps easy→hard so the
user both gets an early win **and** sees genuine FE-level rigor before the
segment ends.

## 3. Retrieval practice → answer first, feedback immediately

**Principle.** The testing effect (Roediger & Karpicke): retrieving an answer
strengthens memory more than re-reading, especially with immediate corrective
feedback.

**Design consequence.** The quick-start is itself retrieval practice. Each
question gives immediate ✓/✗ plus a one-line explanation, so the onboarding is
already teaching, not just measuring.

## 4. Mastery learning → "familiarity," capped, never "mastery"

**Principle.** Mastery learning (Bloom) treats mastery as demonstrated,
sustained competence — not a single sitting. Calling a 5-question result
"mastery" is both pedagogically wrong and dishonest.

**Design consequence.**
- A fresh sample is labeled an **"early read" / "familiarity,"** and capped at
  **40%** even for a perfect 5/5.
- "Mastery" is reserved for the score that grows through repeated study and
  spaced review over time (`studyScore` in `service/routes/sessions.js`).
- The cap is explained in-product ("a starting point, not a grade") so a strong
  user reads it as rigor, not stinginess.

## 5. Psychometric reliability → 5 per chapter, not 1 across 15

**Principle.** A reliable ability estimate needs multiple items per construct.
Adaptive tests typically need on the order of **15–20 items** to match a fixed
test's reliability, and diagnostics draw an adaptive subset from large banks.
One item per topic is essentially a coin flip (a lucky guess or a careless miss
swings it 0↔100).

Sources:
- [A narrative review of adaptive testing and its application to medical education (PMC)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10680016/)
- [Adaptive Diagnostic — Item Response Theory (future-proof)](https://www.future-proof.app/science-diagnostic/)

**Design consequence.** We concentrate the 5 questions on **one** chapter (a
defensible rough read) instead of spreading them across all 15 (noise). We are
honest that even 5 is rough — hence the cap and the "familiarity" label. An
earlier proposal to animate per-chapter "mastery" off 5 total questions was
rejected as "animating noise."

## 6. Self-assessment is unreliable → the system picks chapters, not the user

**Principle.** Dunning–Kruger: people are poor judges of their own competence,
and the **least competent overestimate the most.** In classic studies, bottom-
quartile performers rated themselves around the 62nd percentile; a 2024 study
found ~35% of first-year medical students overestimated their performance, the
effect strongest among the lowest scorers. Letting learners choose what to be
tested on means the weakest learners skip exactly the chapters they most need.

Sources:
- [Dunning–Kruger effect (Wikipedia)](https://en.wikipedia.org/wiki/Dunning%E2%80%93Kruger_effect)
- [Prevalence of the Dunning-Kruger effect in first-semester medical students (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC11515314/)

**Design consequence.** This is the reason for the core principle (user controls
*how far*, system controls *which*). Chapters are ordered by NCEES exam weight
(with `mathematics` first for a fair opener), so even a user who stops early has
covered the highest-impact material rather than a comfort-picked subset.

## 7. Goal-gradient & endowed progress → a visible, seeded, finite finish line

**Principle.** The goal-gradient effect: motivation to complete rises as a
visible goal nears. The endowed progress effect: starting people partway toward
a goal raises completion — reported lifts of up to ~82% in some settings.
Caveat: a long/empty progress bar can *backfire* by signaling how far there is
to go, so it must be designed to feel within reach.

Sources:
- [The psychology behind progress bars in onboarding (Userpilot)](https://userpilot.com/blog/progress-bar-psychology/)
- [The endowed progress effect (Lead Alchemists)](https://www.leadalchemists.com/marketing-psychology/cognitive-biases-marketing/endowed-progress-effect/)
- [The goal-gradient effect (LogRocket)](https://blog.logrocket.com/ux-design/goal-gradient-effect/)
- [When progress bars backfire (Irrational Labs)](https://irrationallabs.com/blog/knowledge-cuts-both-ways-when-progress-bars-backfire/)

**Design consequence.** The "X / 15 chapters" map is **finite and visible**, and
it is already partly filled after the first segment (endowed progress). We
rejected an open-ended "keep answering until done" flow precisely because it
hides the finish line and kills the goal-gradient pull.

## 8. Self-determination theory & decision load → autonomy with few off-ramps

**Principle.** SDT: autonomy supports intrinsic motivation, so "stop anytime"
is right. But every added decision point is also an opportunity to drop off, and
choice overload (Hick's law and related work) slows or stalls action.

**Design consequence.** Autonomy is expressed as **duration control** ("stop
anytime, study anything"), not as a menu to navigate. There is **one**
checkpoint per segment, and it **defaults to continue.** We do not ask the user
to choose a chapter from 15 as their first action (a cold-start decision they're
not equipped to make).

## 9. Honesty as a feature → the "5-minute" promise becomes true

**Principle.** Trust compounds; manufactured pressure and broken promises erode
it. The previous "5-minute diagnostic" copy was simply false (the real thing was
~87 minutes).

**Design consequence.** The first segment genuinely is ~5 minutes, so the
marketing copy is now accurate. We also refused the "if you stop you'll have to
study every chapter blind" framing: it isn't true (lessons are always open) and
it's a soft dark pattern. The honest version — "the more you answer, the more
complete your plan" — is motivating without coercion.

---

## Summary: principle → decision

| Principle | Decision |
|---|---|
| Self-efficacy (mastery experiences) | Easiest-first opener; no traps in onboarding |
| Desirable difficulty / credibility | Real FE questions, ramped — fair, not trivial |
| Retrieval practice | Immediate ✓/✗ + one-line explanation per question |
| Mastery learning | "Familiarity," capped at 40%, never "mastery" |
| Psychometric reliability | 5 questions on one chapter, not 1 across 15 |
| Self-assessment is unreliable | System orders chapters; user can't cherry-pick |
| Goal-gradient / endowed progress | Finite, visible, pre-seeded "X / 15" map |
| Self-determination + decision load | "Stop anytime"; one default-continue checkpoint |
| Honesty | Accurate "5-minute" copy; no "you're stuck" framing |
