# Mobile App — Pedagogy North Star

_Last updated: 2026-06-10._

This is the **backbone of the FE for Raccoons mobile app** (React Native, iOS +
Android, works online and offline). It exists for one reason: **every mobile
feature idea must be checked against the principles here.** If a feature can't
pass the litmus test at the bottom, it doesn't ship — no matter how engaging,
clever, or pretty it is. When in doubt, re-read this doc before building.

Stack decision: **React Native** — chosen so web and mobile stay one
JavaScript/React family (shared content data + study logic, one language to
maintain long-term) and so the ~104 SVG diagram components port mostly
mechanically via `react-native-svg`. Fully native (App Store + Play Store),
supports home-screen widgets (a native extension + data bridge).

---

## The North Star (one sentence)

> The phone is a **serious spaced-retrieval engine for concepts**, an **honest
> hand-off to paper for problem-solving**, and **relentlessly truthful that
> "feeling fluent ≠ being exam-ready."** Every mechanic exists to bring students
> back to *effortful* practice — we measure **readiness, not minutes**.

## The failure mode we are designing against

The FE is a serious, sit-down, paper-and-pen exam. The danger of a phone app is
that it makes prep *feel* like casual scrolling — manufacturing **confidence
without competence**. We will not build something that lets a student believe
they can get exam-ready the way they scroll TikTok. The enemy isn't the phone;
the enemy is **passivity**.

## The evidence base

1. **Retrieval practice + spaced repetition are among the most effective study
   methods that exist** — a review of 254 studies found distributed practice
   consistently beats massed practice, and self-directed retrieval practice
   *predicts medical-licensing-exam performance*. Active recall on a phone, done
   right, is genuine, high-leverage learning — not a toy.
   ([Evidence Based Education](https://evidencebased.education/resource/retrieval-and-spaced-practice-study-strategies-that-must-be-combined/),
   [medical licensing study](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4673073/))
2. **Easy, fluent, recognition-based study creates false confidence that
   collapses on the exam** — Bjork's *fluency illusion* / *illusion of
   competence*: recognizing an answer "feels like knowing" but doesn't predict
   recall or application, and people wrongly use *ease* as their readiness cue.
   ([fluency illusion](https://learnnovators.com/blog/the-fluency-illusion-why-easy-learning-can-be-misleading/),
   [Bjork's desirable difficulties](https://www.structural-learning.com/post/desirable-difficulties))
3. **Multi-step problem-solving can't be built in phone-sized micro-bursts** —
   microlearning is great for *retention* but has reduced effectiveness for
   higher-order thinking, complex problem-solving, and analytical reasoning.
   ([mobile microlearning review](https://pmc.ncbi.nlm.nih.gov/articles/PMC6716752/))
4. **Cognitive load theory explains why paper is required for real problems** —
   working memory holds only ~5–9 chunks; a novice solving a multi-step problem
   spends *all* of it on the means-ends search, leaving nothing for learning
   unless they **offload to paper**. Studying a *worked example* beats unguided
   struggle for novices.
   ([Paas & van Merriënboer](https://journals.sagepub.com/doi/10.1177/0963721420922183))

## Two cognitive jobs (not "serious vs. casual")

Do **not** frame the phone as the "lightweight" tier — that mislabels a powerful
method. Frame the split as two distinct *cognitive jobs*, both real:

- **Phone = the declarative / retrieval layer.** Concepts, formula *locations*
  in the FE Handbook, common traps, "what's the approach." Active recall + spaced
  review of what you're forgetting. Genuinely effective, and it fits the phone's
  working-memory budget.
- **Desk + paper = the procedural / problem-solving layer.** Full multi-step
  calculations that *require* offloading to paper. The phone's job here is to
  **flag, queue, and send you to it** — never to fake it.

Same split the owner proposed; reframed so "phone" means "serious retrieval
engine," not "casual."

## The pedagogy spine (design rules)

1. **Generation, not just recognition.** Tapping a multiple-choice answer is
   *recognition* — the thing that inflates false confidence. Where possible on
   the phone, make them **generate**: recall the formula before the reveal, name
   the first step, estimate the number. Build productive friction in.
2. **Spacing + interleaving are the phone's superpower.** Surface what they're
   forgetting on an expanding schedule (reuse the existing spaced-repetition
   engine), and **mix topics** rather than blocking — interleaving builds the
   discrimination the FE demands.
3. **Honest readiness signaling (anti-illusion-of-competence).** Because phone
   fluency *feels* like mastery, keep saying what the quick-start already says:
   *"You know the concept — now prove you can solve it on paper."* Phone streaks
   never equal "ready." **This is the single most important guardrail.**
4. **Worked example before the hard problem.** For novices, studying a solved
   example beats unguided struggle (CLT). Paper-tier problems pair with a worked
   example first, then "now you try one on paper."
5. **Bounded sessions, never an infinite feed.** A session is a *defined set* →
   "done for now," not endless scroll. Reward depth and consistency, not
   time-in-app. This is the structural answer to "not like TikTok."
6. **Orchestrate the hand-off; widgets as honest triggers.** The app coaches the
   rhythm: *"On the bus? 8 minutes of concept review. At your desk tonight? 5 full
   problems flagged for paper in your weak chapter."* Home-screen widgets (exam
   countdown, concept of the day) are honest re-engagement triggers that pull
   students *toward* real practice — not screen time.

## The tension we hold on purpose

Engagement mechanics (streaks, notifications, widgets) are double-edged: they
drive the **consistency** that spacing requires — but optimized for minutes-in-app
they manufacture the exact illusion we fear. **North star: every mechanic exists
to bring students back to *effortful* practice, and we measure *readiness*, not
minutes.** A feature that only grows time-in-app without growing real practice or
readiness is working *against* us.

## The litmus test (run EVERY mobile feature through this)

Before building any mobile feature, it must answer **yes** to all of these:

1. **Active?** Does it involve retrieval/generation — not passive consumption or
   pure recognition?
2. **Honest?** Does it avoid letting phone fluency masquerade as exam-readiness?
3. **Right layer?** Concept work stays on the phone; full multi-step problems are
   flagged for paper, not crammed onto the screen?
4. **Bounded?** Is the session finite (no infinite feed)?
5. **Pulls toward effort?** Does the mechanic move students toward effortful
   practice rather than just time-in-app?
6. **Measured by learning?** Would it still be worth building if we scored it on
   *readiness gained*, not *minutes spent*?

If a feature fails any one of these, redesign it or drop it.

## Related docs
- [`pedagogy-and-research.md`](./pedagogy-and-research.md) — the learning-science
  basis for the web onboarding (self-efficacy, retrieval practice, mastery
  learning, etc.). The mobile spine above is the same philosophy, applied to the
  phone's constraints and opportunities.
- [`quickstart-diagnostic-design.md`](./quickstart-diagnostic-design.md) — the
  "familiarity, not mastery" honesty that rule #3 (honest readiness) extends.
