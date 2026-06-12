<!-- Deliberation run 2026-06-12: 4 pedagogy-expert agents + 7 student personas + referee synthesis. Decision input only — no code shipped from this yet. -->

# FINAL POLICY v2 — Daily Study Volume Governance ("Pace")

**Status:** FINAL — ready for the owner's go/no-go before any code ships.
**Owns:** how much an adult FE Civil candidate is asked to study per day, web + mobile, across the full range from ~6 months out to 4 days out.
**Canonical surface:** `service/shared/scheduler.js` (+ its mirror `mobile/src/shared/scheduler.ts`, both `SCHEDULER_VERSION 2.0.0`). The live flat-5 at `service/routes/review.js:46` (`Math.min(parseInt(req.query.count) || 5, 8)`) is **deleted** and the route re-routes through the canonical module.

---

## 1. Executive summary

We govern the study day as **three independent streams** — uncapped DUE REVIEWS (the spaced-retrieval durability engine, emergent from the SM-2 scheduler and never hard-capped), a soft-defaulted, ceiling-bounded NEW-LEARNING stream (the only real overload lever), and UNLIMITED chapter PRACTICE (the pressure-release valve). The single flat number on web — five problems a day, blind to the exam date, identical whether you are six months or six days out — is replaced by an exam-aware plan that the mobile app already approximates. The relaxed user keeps a small, finite, spacing-protected dose; the motivated late starter is **never** told "you're done, come back tomorrow." Seven student personas stress-tested the v1 draft and exposed five genuine gaps — a 20-minute user blown past budget on a comeback day, a half-covered panicker shown a melting 98%, a blank-slate crammer capped at 40 cards/day, a returner shown a confidently wrong number built on un-decayed mastery, and an over-eager beginner handed the firehose as a reward. v2 fixes all five: a **minutes budget** that governs the combined day (reviews protected first), **coverage-anchored, trajectory-aware projections** instead of a calendar-melting one, a **blank-slate path** that lets prescribed new-learning rise above 40 when the review queue is near-empty, a **"welcome back" recheck** that refuses to show a confident number on stale mastery, and a symmetric **over-study guard** for early bingers. The honesty rail is absolute throughout: projection capped at 98%, framed as an estimate, **never a pass probability**.

---

## 2. The question and why it matters

**How should the platform decide how much a user should study per day, across the full range of timelines (6 months out down to 4 days out), honoring spaced-retrieval science AND never turning away a motivated late starter, for an adult professional audience?**

This is not academic. **We have real paying users mid-prep right now**, on the old web flat-5 and the shipped mobile adaptive model. The tension is real on both ends:

- A **daily cap protects** a relaxed user from burnout and respects the spacing effect — distributed practice durably beats cramming. Removing it naively would harm the very users it was built for.
- But a **flat or low cap turns away** the highest-intent, highest-business-value user we have: the motivated late starter who finds us one-to-two weeks before their exam and is told "come back tomorrow" after five problems. That string is bad for them and bad for the business — and once the tool is visibly wrong about their timeline, they stop trusting the mastery number that is our entire moat.

So this decision sits exactly where pedagogy, honesty, and revenue intersect. Any change must improve the late-starter experience **without silently harming the users already on the platform or the numbers the business watches.**

---

## 3. What the platform does today, and the specific problem

**WEB (the bug):** the spaced-review queue is a **flat cap of 5 problems/day, hard max 8**, computed at `service/routes/review.js:46` as `Math.min(parseInt(req.query.count) || 5, 8)` — **with no reference whatsoever to the exam date.** A user 6 months out and a user 6 days out get the identical drip of 5. Separately, chapter PRACTICE problems are already UNLIMITED on web.

**MOBILE (already better, but partial):** exam-aware via the canonical scheduler. `dailyCardTarget = clamp(round(minutesPerDay * 0.6 * intensity), 5, 40)`. Three regimes off days-until-exam: **runway** (≥56 study days, intensity 1.0), **onPace** (14–55, 1.0), **crunch** (<14, intensity 1.3, paper target doubles). `reviewTargetFor` ceilings are 8/12/30. It projects mastery at the chosen pace (capped 98%) and targets mastery the **day before** the exam (last day = light review / rest). It exposes `softCap: true` and `MAX_INTERVAL_DAYS = 60`.

**The specific problem:** the web flat-5 governs the **wrong variable** — raw review count, blind to the only thing the science cares about (when items are due relative to the exam horizon). It conflates two streams that obey different rules. And the route never consumes the shared scheduler at all, so the two surfaces have silently diverged: `softCap: true` is a **dead boolean** the API never honors, and the exam-aware logic that exists on mobile simply does not run on web.

---

## 4. The pedagogy proposals — agreement and disagreement

**The key agreement (all four lenses converged independently):** govern the day as **two (we add a third) independent streams, never one number.**

- **Stream A — DUE REVIEWS** (spaced retrieval; durability). Volume is **emergent** from the SM-2 scheduler's `dueCount`, never invented, **never hard-capped** — only soft-batched for a finite finish line. Capping below true-due silently lengthens real intervals past the planned gap; for items near the exam they may then never resurface before test day — the one failure mode spacing science cannot tolerate.
- **Stream B — NEW LEARNING** (acquisition of unseen concepts). The discretionary firehose, and the **only place a real volume ceiling belongs.**
- **Stream C — CHAPTER PRACTICE** stays **UNLIMITED** (already true on web). The pressure-release valve; the cap machinery never touches it.

The disagreements, named by lens, and how v2 resolves each:

| # | Disagreement | Lenses | Resolution in v2 |
|---|---|---|---|
| 1 | Flat ceiling vs. `backlog÷days` adaptive ceiling vs. uncapped-emergent | Cognitive-load (adaptive) vs. spacing (emergent) | **`dynamicCeiling = baseCeiling + ceil(backlog/studyDays)`** governing the spacing expert's emergent `dueCount`. Relaxed users never reach the ceiling (emergent); late starters get a deadline-scaled ask (adaptive); nothing is hard-capped below true-due (soft + "keep going"). |
| 2 | Does new learning stop near the exam? | Spacing + mastery-triage (hard-stop <4d) vs. motivation (a wall erodes trust) | **Hard `lastMile` cutoff at studyDays < 4, reframed as strategy** — pivot to consolidation + paper + exam-mechanics drills, announced and dismissible. v2 softens it for blank-slate users (see §6). |
| 3 | Intensity cliff at 14 days | spacing + mastery-triage flagged the cliff | **Continuous lerp 1.0→1.3 across studyDays 20→10**, no overnight lurch. |
| 4 | Pin Stream B to a constant vs. derive from the gap | mastery-triage (derive) vs. motivation (autonomy contract) | **Hybrid:** `comfortTarget` (user's minutes contract) as the floor, `requiredPerDay` allowed to push it **up** in crunch, triage when the gap exceeds the ceiling. |
| 5 | Numbers vs. shape | all four flagged every constant as heuristic | **Policy commits to the SHAPE; all constants ship as instrumented launch defaults**, A/B-tuned against next-day-return + review-completion + lapse-rate, never items-served or minutes-in-app. |

**Cap stance: SOFT, unanimous.** The two `adaptiveCap` proposals reduce to a soft cap with a backlog-scaled ceiling — which is exactly Stream A. Every soft cap, when hit, shows a plain-language reason and a visible "Continue anyway." We inform; we never lock an adult out.

**Empirical confidence (shared across lenses):** STRONG — the spacing/distributed-practice effect (Cepeda 2006/2008, 254-study meta-analysis), the testing/retrieval effect, optimal gap scaling with retention interval, sleep consolidation favoring exam-eve rest over cram. These carry the **architecture**. HEURISTIC / instrument-don't-trust — every constant (0.6 cards/min, 0.03 mastery-pts/day, the 8/14/30 ceilings, the 40 cap, the 0.25 horizon coefficient, intensity 1.3, the 30-item/45-min fatigue bounds). The 98% projection cap is an ethics decision, not an empirical one.

---

## 5. The student stress-test

Seven personas spanning the full timeline stress-tested draft v1.

| Persona | Timeline | Verdict | Honest? | Sharpest friction |
|---|---|---|---|---|
| **Maria** — disciplined, durable-mastery | ~180d (runway) | wellServed | yes | Runway is under-designed vs. crunch: `comfortTarget` anchored to a 20-min default undersizes her real 30 min; projection auto-pins to ~98% six months out — the false comfort she came to escape; no visible NEW-concept sequencing story. |
| **Devin** — busy, inconsistent, ~20 min | ~60d (onPace) | wellServed | yes | **The comeback day blows the budget.** After 3 missed days, ~15 reviews + 12 new = ~27 min against his honest 20. The two streams are each reasonable but **never summed against his minutes budget.** |
| **Priya** — anxious, half-covered, 90 min | 21d (onPace/crunch edge) | **mixed** | **no** | **Melting 98%:** day-one projection shows 98% while she's half-covered, then decays daily (98→91→80→69) so time passing reads as punishment. `newTarget` silently pins at 40; the triage that would make 40 survivable is the deferrable part. |
| **Marcus** — blank-slate crammer, 4+ hrs | 7d (crunch) | **mixed** | yes | **The catch-up engine doesn't apply to him.** Empty review queue → all his fight is Stream B → he slams the **hard 40 cap** in ~1 hour having offered 4. lastMile at day 4 freezes new intake on material he's never seen. |
| **Sam** — lapsed, triage-only, no new | 4d (lastMile) | **mixed** | yes | Review queue stays **soonest-due-first** — for a lapsed user that's noise, not triage. His highest-yield GAP (a high-weight chapter he never opened) is locked out by the no-new rule with no adult override. |
| **Elena** — returner after 3-wk break | 35d (onPace) | **mixed** | **no** | **Confidently wrong number:** projection stacks growth onto **un-decayed** mastery (decay still unimplemented), so after 3 weeks of forgetting the app says she's fine. `ceil(backlog/34)` silently bets on perfect attendance — the bet she just lost. |
| **Jordan** — over-eager beginner, 3 hrs | ~150d (runway) | **mixed** | yes | **The over-study guard has no teeth.** The whole "soft cap / keep going / unlimited practice" design protects the late starter; it hands the early binger the firehose as a reward. The §d.3 interstitial is a dismissible one-liner he taps past nightly. |

**The pattern:** v1 was excellent at "never turn away the late starter" and at honesty-for-the-honest-case. It failed on **(a)** budget realism on a recovery day, **(b)** projection honesty for the half-covered and the returner, **(c)** the blank-slate crammer who has no backlog for the catch-up math to work on, and **(d)** the symmetric problem — protecting the over-eager early user from himself.

---

## 6. THE FINAL RECOMMENDED POLICY (v2)

Everything is driven off **`studyDays = max(0, daysUntilExam - 1)`** — the existing exam-eve clamp. The last day before the exam is light review / rest, not new mastery. **Keep this exactly** (unanimous; sleep-consolidation + cram-anxiety evidence is strong).

### 6.1 Daily-target formula at every timeline

**Stream A — review target (backlog-aware, horizon-aware ceiling):**

```
baseCeiling      = runway 8 | onPace 14 | crunch 30      // onPace raised 12→14 (12 was arbitrary)
backlog          = max(0, dueCount - baseCeiling)
catchUpAllowance = studyDays > 0 ? ceil(backlog / studyDays) : backlog
dynamicCeiling   = baseCeiling + catchUpAllowance
floorTarget      = min(dueCount, 3)                      // a near-empty queue never shows 0 when something is due
reviewTarget     = clamp(dueCount, floorTarget, dynamicCeiling)
```

A relaxed runway user with `dueCount ≤ 8` sees ~5–8 and never touches the ceiling — spacing protected. A late starter with a real backlog sees a ceiling that **scales to their deadline**, not "come back tomorrow." `reviewTarget` is the **default rendered batch**; if `dueCount > reviewTarget`, the UI shows `reviewTarget` then an explicit, non-auto-loaded **"N more due — keep going"** that surfaces the entire due queue on demand, and always states the true debt (*"18 shown, 122 more waiting"*).

**Stream B — new-learning target (comfort floor, gap-derived push, blank-slate uncapping):**

```
comfortTarget     = clamp(round(minutesPerDay * 0.6 * intensity), 5, 40)
remainingConcepts = totalConceptsToReachReadiness - conceptsMastered
requiredPerDay    = studyDays > 0 ? ceil(remainingConcepts / studyDays) : remainingConcepts
newTarget         = clamp(max(comfortTarget, requiredPerDay), 5, newCeiling)
```

**[v2 FIX — Marcus] The 40-card ceiling is conditional, not absolute.** For a **blank-slate crammer** (crunch/lastMile **and** `dueCount` near-empty relative to `remainingConcepts`), the user's entire fight is Stream B and the 40 cap is exactly backwards. In that state:

```
newCeiling = (crunch_or_lastMile && dueCount < blankSlateThreshold)
           ? null                       // prescribed new-learning may exceed 40
           : 40
```

When `newCeiling` is lifted, the **per-sitting fatigue ceiling and break nudges become the real overload guard** (§6.4) — not a flat daily cap — and new concepts are front-loaded **NCEES-weight-ordered** so capped time hits the densest points. For everyone else the 40 ceiling stands as the anti-overload lever.

### 6.2 The minutes-budget governor **[v2 FIX — Devin]**

The two streams must be **summed against the user's `minutesPerDay`**, not governed independently. On any day where `newTarget + reviewTarget` overflows the minutes budget:

1. **Protect DUE REVIEWS first** — forgetting is the real, already-earned loss.
2. **Trim/defer NEW concepts** to fit the remaining budget.
3. Show one honest, non-scolding line: *"You're behind on reviews from missed days — we paused new concepts today so you can catch up. 12 new waiting for tomorrow."*

This keeps the comeback day inside the budget the user actually gave us, prioritizes durability over acquisition exactly when the user is rusty, and never reads as a scold. **Minutes-budget is a first-class stop, co-equal with item-count** — Devin will never hit the 30-item fatigue ceiling, but he hits 20 minutes every day.

### 6.3 Intensity — continuous ramp, no cliff

```
intensity = studyDays >= 20 ? 1.0
          : studyDays <= 10 ? 1.3
          : lerp(1.0, 1.3, (20 - studyDays) / 10)
```

No overnight lurch for a user sitting on the boundary (Priya at studyDays 20).

### 6.4 Soft-cap rule and burnout guards

**Stance = SOFT.** Make the dead `softCap: true` boolean real.

- **Stream A (reviews): SOFT.** Recommended default batch; "keep going" surfaces the full due queue; **never hard-blocked.**
- **Stream B (new learning): SOFT default**, real ceiling of 40/day **except** the blank-slate uncapping (§6.1).
- **Stream C (practice): NO CAP, ever.**

**The only TWO hard stops:**
1. **`lastMile` new-learning cutoff (studyDays < 4)** — see §6.6 for the v2 blank-slate softening.
2. **Streak/abuse integrity** — streak credit is earned by *schedule completion*, not raw volume, so the cap can't be farmed.

Burnout guards (defaults + framing + honesty — never locks, never streak-fear):

1. The `newTarget` ceiling (40, where it applies) is the real anti-overload lever.
2. Small default batches = a finite, guilt-free finish line (goal-gradient).
3. **Absolute fatigue ceiling per sitting, regime-independent:** ~30 review items OR ~45 min continuous, whichever first. At the ceiling, don't block — *"You've cleared today's review. More now hits sharply diminishing returns — the same reps tomorrow buy more."* + visible "Continue anyway" → unlimited practice.
4. Within-day nudge at ~20 consecutive items: a one-line dismissible break offer.
5. **Spacing protection on the LOW end:** when `dueCount ≤ baseCeiling`, refuse to inflate the day; empty-queue state routes to practice, **offered neutrally, not sold as a reward** (Jordan fix).
6. **Relearn accounting:** an SM-2 `forgot` relearn (10-min resurface) counts as ~0.3 of an item against the session, so a struggling user (Elena, Marcus) isn't trapped in a loop that reads as failure.
7. **Streak sanity:** streak = clearing due reviews + meeting `newTarget` (or the protected-review minimum on a budget-overflow day); the prescribed exam-eve rest day counts; streak loss is never a burnout lever.
8. **Rolling 3-day completion ratio** lowers a chronically-overshot target toward what the user actually sustains — but **slowly, hysteresis-gated** so one busy exam-week stretch doesn't ratchet a disciplined user down (Maria/Devin fix).
9. **[v2 FIX — Jordan] Symmetric over-study guard for runway.** A rolling 3-day **over-**study counter mirrors guard #8's under-study one. If a runway user does ≥2× prescribed time three days running, the §6.4.3 interstitial becomes a **once-and-sticky** framing (not a nightly dismissible one-liner): *"You're 149 days out. People who pass studied a little, most days — not a lot, some days. Tonight's extra reps barely move the line; tomorrow's move it most."* Show the spacing curve once, memorably. Add a small **consistency surface** (days-shown-up, not minutes-ground) so the early user gets a habit hook the same way the crunch user gets a deadline hook.

### 6.5 Late-starter behavior at 2wk / 1wk / 4day

Onboarding asks **exam date FIRST.** If `daysUntilExam < 14`, route into a **"Focused sprint plan"** and ask **"how many hours can you commit before exam day?"** (not the soft "minutes/day?").

| Timeline | Regime | What they see | What they can do |
|---|---|---|---|
| **2 weeks (studyDays 13)** | crunch | `reviewTarget = min(dueCount, 30 + catchUp)`; `newTarget` pushed toward 40 (or uncapped if blank-slate) by `requiredPerDay`, **NCEES-weight-ordered**; intensity ramping ~1.2; paper target 2; **coverage-anchored, capped projection.** | Clear entire backlog via "keep going"; pull tomorrow's set forward; unlimited practice. **No "done for today" string ever.** |
| **1 week (studyDays 6)** | crunch (deep) | As above, intensity ~1.3; queue reordered by exam weight; banner: *"At 1 week out, we front-load high-yield concepts and send calc-heavy work to paper."* | Same — full backlog on demand, unlimited practice. |
| **4 days (studyDays 3)** | **lastMile** | **Net-new intake closes — softened (§6.6).** Surface: due reviews (triage-ordered), highest-weight already-seen concepts, exam-day mechanics drills. Banner: *"With 4 days, spaced review can't fully run its course. We'll consolidate what can still stick and send the rest to paper. This builds real shape; it is not a guarantee."* | Unlimited review + practice + drills + the one adult-consent gap exception. |

### 6.6 The lastMile softening **[v2 FIX — Marcus, Sam]**

The v1 hard freeze on **all** new concepts at studyDays < 4 fails a blank-slate or lapsed user who still has **never-seen high-weight material** — a total freeze can mean "never learned 30% of the exam," and a 70% wall is worse than a guided, honest scramble. So:

- lastMile freezes **new LOW-weight concepts only**, not all new intake.
- The single **highest-weight unopened chapter** is surfaced as an explicit **adult-consent choice**, not silently demoted: *"High-yield gap you haven't touched — cram it on paper?"*
- The **review queue is triage-ordered** in lastMile (and crunch): rank by **NCEES chapter weight × current weakness**, not soonest-due. For a lapsed user, soonest-due is noise.
- Lead the screen with a ranked **3-item "do this first"** list; the honesty banner sits second.

### 6.7 Backlog handling

The `dynamicCeiling` was built for this; no special path needed for the backlog crammer. The backlog is **divided across remaining study days** (`catchUpAllowance`), bounded by the per-sitting fatigue ceiling, remainder one tap away, practice unlimited. No silent truncation — the true debt is always stated. The horizon-aware interval cap (§6.8) keeps the backlog from re-exploding near the exam.

**[v2 FIX — Elena] Backlog-after-absence is a trigger, not just a number.** Don't key the regime purely on days-until-exam. Add a **"returning with a backlog"** trigger (large `dueCount` relative to recent activity, any regime) that swaps framing to *"Welcome back — here's the real catch-up picture,"* front-loads the first few days **more aggressively than `ceil(backlog/studyDays)`** (because betting on perfect attendance is the bet the returner just lost), then lets guard #8 relax it down if they keep up. **Conservative-then-rewarded keeps a scared returner showing up; optimistic-then-corrected demoralizes.**

### 6.8 Horizon-aware interval cap

In `nextSchedule`, cap each newly-scheduled interval at the exam horizon (Cepeda: optimal gap scales with retention interval):

```
effectiveMaxInterval = min(MAX_INTERVAL_DAYS /*60*/, ceil(0.25 * daysUntilExam))
intervalDays         = min(grown, effectiveMaxInterval)
```

At 180d out the 60-day cap dominates (no change). At 20d out nothing exceeds 5 days → every item gets ≥3 more retrievals before test day. At 6d out, ~1–2 day max → near-daily contact. **Existing-user safety:** apply only to the NEXT scheduled interval — never retroactively pull an already-set `dueAt` earlier; the change phases in over a few cycles instead of spiking due counts on ship day.

### 6.9 The honesty rule **[v2 FIX — Priya, Elena]**

- **Projection capped at 98%**, framed as an estimate, targeting mastery the day **before** the exam. **Never a pass-probability, never "on track to pass."**
- **[Priya] Anchor to actual coverage, and make it trajectory-aware.** Day-one projection reflects the user's **real coverage** (a half-covered user sees ~60% with a concrete triage plan, not a melting 98%). Doing the work **holds or raises** the number; it must not **decay merely because the calendar advances** — passing time while completing the plan should never read as punishment. The linear `gainPerDay` is replaced/bounded so a long-horizon user is **"paced toward 98%"** (a calibration band), not auto-pinned to 98% on day one (Maria's false-comfort trap).
- **[Elena] Never show a confident number on stale mastery.** A "returning with a backlog" user does not get a projection stacked onto un-decayed mastery. Either ship even a **crude decay** so a long absence visibly lowers mastery before growth is added, **or** gate the projection behind a *"you've been away — let's recheck where you actually stand"* state that re-tests the weakest chapters first. The dishonest moment is the silent over-credit; close it.
- **Show the real number** at the real pace — 71% is shown as 71%, 41% as 41%, **always paired with the triage plan that moves it** ("here's exactly how to close the gap"), never as a verdict.
- **Honesty is the throttle and the burnout guard:** slow a binger with *"you're ahead of pace; spacing these will stick better"* + one-tap continue — never a gate.
- **First-show gating:** a projection appearing for the first time on an existing account is gated behind a one-time explainer (*"this is an estimate, capped at 98%, never a pass guarantee"*).
- **Never tell a crunch/late-starter "you're done, come back tomorrow."**

### 6.10 Triage is non-deferrable for sub-14-day users **[v2 FIX — Priya, Marcus]**

v1 hedged: if `totalConceptsToReachReadiness` couldn't be defined cleanly, Stream B shipped comfort-only and triage slid to v1.1 — which leaves the **exact users who need it most** (Priya, Marcus) with just a ceiling and no plan. v2 makes **NCEES-weighted triage non-deferrable for crunch/lastMile users.** When `requiredPerDay` exceeds comfort, show an explicit **high-yield subset and a named "optional if time" tail** — never a silently pinned 40. If `totalConceptsToReachReadiness` cannot be defined cleanly pre-ship, **ship a crude version** (e.g., concept-tier cards across chapters at the NCEES-weighted coverage bar) and instrument it — do not leave the late starter with a bare cap. The runway gap-push may still defer; the crunch triage may not.

---

## 7. What changes for web vs mobile

**Shared (`scheduler.js` + `scheduler.ts` together — bump `SCHEDULER_VERSION` 2.0.0 → 2.1.0 in BOTH or the parity test goes red):**
- `reviewTargetFor` → backlog-aware `dynamicCeiling` (§6.1); onPace base 12 → 14.
- `intensity` binary `crunch ? 1.3 : 1` → continuous lerp (§6.3).
- `nextSchedule` → `effectiveMaxInterval` horizon cap (§6.8).
- `computeDailyPlan` → emit the **minutes-budget reconciliation** (§6.2), the **blank-slate `newCeiling` lift** (§6.1), `requiredPerDay`/triage signal (§6.10), and the **regime is augmented by a "returning-with-backlog" flag** (§6.7).
- Add a `lastMile` regime to `regimeForStudyDays` (studyDays < 4), with low-weight-only new freeze + adult-consent gap exception (§6.6).

**WEB (the bug fix + new surfaces):**
- **Delete `service/routes/review.js:46`** (`Math.min(parseInt(req.query.count) || 5, 8)`); route review through canonical `computeDailyPlan`/`reviewTargetFor`. **Do not re-fork logic in the route.** (Just consuming the existing module needs no version bump; the new ceiling/interval/budget logic above does.)
- Reorder the web review queue (`getProblemsForReview`) by NCEES weight × weakness in crunch/lastMile, not soonest-due.
- Build the UI surfaces below.

**MOBILE:** already consumes the module — picks up the new logic for free on the version bump. Verify the Today slice renders the two-number + "keep going" + budget-pause + welcome-back + lastMile surfaces.

**Designer surface (both):** two numbers (new + reviews); always-present non-auto-loaded "keep going"; soft-cap interstitials with a real "Continue anyway"; the minutes-budget pause line; the coverage-anchored/trajectory-aware projection with first-show explainer; the "welcome back — recheck" state; the lastMile ranked "do this first" + adult-consent gap choice; the empty-queue neutral "practice" route; the runway over-study sticky framing + consistency surface. **No hearts/lives, no speed rewards, no streak-loss fear — adult tone throughout.**

---

## 8. Rollout safety for existing users (no silent harm)

1. **Ship dark + versioned.** Compute new `reviewTarget`/`newTarget` alongside the old, log both, flip UX only after telemetry confirms the new ask isn't tanking completion. Gate the crunch cohort behind a flag; the failure mode to watch is **opens-then-bounces** (overwhelm-churn), not lower opens.
2. **Grandfather gradually.** Ramp `dynamicCeiling` up over 5–7 days for users mid-prep on flat-5 — never jump 5 → 30 overnight (that itself causes overload + abandonment). New users start on the full model.
3. **Never regress the low end.** Verify a relaxed 6-months-out user still sees ~5–8/day; the `backlog÷days` math must floor gracefully so we never suddenly demand 20/day from someone happy at 5.
4. **No silent target jump.** Never let the displayed number rise without a one-line reason; gate the first projection appearance behind the one-time explainer; don't auto-expand the default batch for a user in an active streak — surface "N more ready — show them?" as opt-in.
5. **Mastery untouched.** The web mastery formula `max(diagnostic, study)` is independent of batch size — changing how many items are **shown** must not trigger a recompute; only answered items move mastery. **Verify this explicitly.** (Note: if v2 ships crude decay per §6.9, that DOES change mastery — treat it as a separate, clearly-communicated migration, not a side effect of the pace change.)
6. **Watch the right metric.** Optimize next-day-return and review-completion, **not** items-served or minutes-in-app. Split completion into review-completion vs. new-completion before rollout so the expected dip (targets rising) isn't misread as breakage; communicate the dip to the owner in advance.
7. **Parity is the highest operational risk.** Change web canonical + mobile mirror together and bump `SCHEDULER_VERSION` in both, or the parity test goes red and the two surfaces silently diverge.
8. **Don't break earned streaks.** Apply the schedule-completion earn-rule going forward only; grandfather current streaks.

---

## 9. Open questions for the owner

1. **`totalConceptsToReachReadiness`** — define the readiness bar now (concept-tier cards at the NCEES-weighted coverage bar?), or ship a crude version for crunch/lastMile and refine later? v2 requires *something* shippable for sub-14-day users; the runway gap-push may wait.
2. **Mastery decay** — ship even a crude decay so the returner's projection is honest, or gate the projection behind a "recheck" diagnostic instead? Decay touches the live mastery number and needs its own migration plan.
3. **Blank-slate threshold** — what `dueCount`-relative cutoff flags a "blank-slate crammer" who gets the lifted `newCeiling`? Needs a value before the Marcus path can ship.
4. **Constants to instrument first** — confirm the priority order: cards/minute conversion (Maria's "30 min should buy 30 min"), then the 8/14/30 ceilings, then the fatigue bounds. All are launch defaults, tuned against return + completion + lapse-rate.
5. **Trajectory-aware projection model** — replace the linear `gainPerDay` with a coverage-anchored, work-responsive curve: build now, or ship coverage-anchoring first and trajectory-responsiveness in a fast-follow?
6. **Returner front-load aggressiveness** — how much steeper than `ceil(backlog/studyDays)` should the first few days be for a "returning-with-backlog" user before guard #8 relaxes it?
---

## LOCKED DECISIONS — owner ruling, 2026-06-12

All six open questions resolved (owner confirmed the recommended answers):

1. **Readiness denominator:** ship the crude-but-honest version now —
   concept-tier coverage × NCEES chapter weight (chapter-level, reuse existing
   weights). Refine per-concept later with telemetry.
2. **Stale mastery (decay):** **recheck gate, decay deferred.** A
   returner-after-a-gap sees a "your mastery may be rusty — 2-min recheck?"
   before we show a confident projection. Stored mastery is untouched for
   everyone else; NO platform-wide number change. We measure retention, not
   guess a forgetting curve. Full decay + drop-attribution stays a future,
   owner-gated migration.
3. **Blank-slate crammer:** flagged when regime ∈ {crunch, lastMile} AND
   coverage < ~20%. For them, lift the 40-card new-learning ceiling and let
   per-sitting fatigue bounds (not a flat daily cap) govern, plus soft
   "keep going."
4. **Constant calibration order:** cards/minute conversion FIRST (set
   empirically from real seconds-per-card in session logs), then the 8/14/30
   ceilings, then fatigue bounds.
5. **Projection:** coverage-anchoring first (kills the fake 98%);
   trajectory-responsiveness (number visibly moves as you work) as fast-follow.
6. **Returner backlog front-load:** ~1.25× steady `ceil(backlog/studyDays)` for
   the first ~3 days, SOFT, reviews protected against the minutes budget first,
   then the rolling-3-day completion ratio relaxes it.

**Crammer stance:** HONEST-BUT-BOUNDED — surface the full due backlog, soft
ceilings, modest front-load, always "keep going," protect time budget first;
never an overwhelm-dump.

**Throughline for implementation:** honest now · surgical not platform-wide ·
soft never hard · ship the crude version and tune with telemetry · ship dark +
versioned + grandfathered so no existing paying user is silently harmed.
