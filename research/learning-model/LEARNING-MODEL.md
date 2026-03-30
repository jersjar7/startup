# FE for Raccoons — Learning Model Research & Design

## Part 1: Current Approach (Grade: F)

Right now FE for Raccoons presents content like a static textbook:
- Hardcoded bullet list of concepts
- 5 practice problems with collapsible solutions
- Checkbox to mark "done"
- No video (placeholder only)

**What's wrong:**
- No structure to guide what to study or when
- No feedback loop — user checks a box but learns nothing from it
- No reason to come back tomorrow
- No adaptation to what the user actually knows vs. doesn't know
- A student using this would have no advantage over reading a PDF

---

## Part 2: The FE Exam Prep Market

### What Competitors Charge

| Platform | Price Range | Approach |
|----------|-----------|----------|
| PrepFE | $70–$110 | Practice problems only, analytics |
| School of PE | $350–$1,200 | Live lectures + quizzes |
| Civil Engineering Academy | $700–$800 | Videos + practice + CBT simulator |
| PPI2Pass | $1,500–$1,800 | Full course, AI tutor, 40yr reputation |
| Genie Prep | $500–$2,000 | Videos + AI tutor + Discord community |
| Achievable | Unknown | Adaptive learning engine |

### Key Insight: Nobody Uses Gamification

Zero major FE exam platforms use real gamification. This is the biggest gap in the market. Gamification adoption in broader test-prep went from 41% (2019) to 68% (2024), but FE prep hasn't followed.

### What Students Complain About

1. **Overwhelming breadth** — 13-17 topics covering 4 years of coursework
2. **No structured study plan** — students don't know what to study next
3. **Can't measure progress** — no clear milestones, feels like an endless grind
4. **Expensive** — best resources cost $1,000+
5. **Weak areas get avoided** — students study what's comfortable, not what they need
6. **Practice problems don't match exam** — many platforms have unrealistic questions
7. **Burnout** — especially for people studying while working full-time

---

## Part 3: What Duolingo Gets Right (And What Doesn't Apply)

### Mechanics That Work for FE Prep

| Mechanic | Why It Works | FE Adaptation |
|----------|-------------|---------------|
| **Streaks** | 60% increase in commitment. Over 9M users maintain 1yr+ streaks | "Study streak" — practice at least 1 session per day |
| **XP system** | Universal currency connecting all activity | XP for completing problems, finishing topics, daily reviews |
| **Bite-sized sessions** | 3-5 min lessons, low commitment = high completion | "Quick rounds" of 5-8 problems (5-10 min each) |
| **Immediate feedback** | Know right away if you got it right + see the solution | Show worked solution immediately after each answer |
| **Progress per skill** | Visual mastery levels per topic | Mastery bar per FE topic (0→5 levels) |
| **Spaced repetition** | Resurface old material at optimal intervals | Review problems from past topics mixed into daily practice |
| **Weekly leaderboards** | 25% increase in lesson completion | Small cohort leaderboards (30 people) |
| **Streak freeze** | Safety net reduces churn by 21% | Allow 1 skip per week without breaking streak |

### Mechanics That DON'T Work for FE Prep

| Mechanic | Why It Fails |
|----------|-------------|
| **Hearts/Lives** | Penalizing wrong answers on hard calculus problems would be infuriating and drive users away |
| **Complex storylines** | Patronizing for adults prepping for a professional exam |
| **Speed-only rewards** | Encourages guessing on multi-step engineering problems |
| **Excessive celebrations** | Condescending for adult professionals |
| **Match-pairs games** | Don't work for problems requiring multi-step math |

---

## Part 4: The FE for Raccoons Learning Model

### Core Philosophy

> **Spaced repetition is the engine. Gamification is the fuel.**
>
> Spaced repetition ensures students retain what they study.
> Gamification ensures they show up every day.

### The User Flow (Duolingo-Inspired)

```
Open app
  → See streak count, XP today, daily goal progress
  → See "Continue" button (next recommended session)
  → Tap "Continue"
      → 5-8 problems, mixed: new + review
      → Each problem: answer → immediate feedback → worked solution
      → Session complete: XP earned, streak updated, mastery progress
  → Back to dashboard
      → Topic map with mastery levels visible
      → "Daily Review" available (spaced repetition mix)
      → Leaderboard position
```

### Problem Session Structure

Instead of showing all problems at once with expandable solutions (current approach), each session is a **focused round**:

1. **Present one problem at a time** (like a flashcard/quiz)
2. **User selects answer** (multiple choice to match FE exam format)
3. **Immediate reveal** — correct/incorrect + full worked solution
4. **Rate difficulty** (optional: "Easy / Medium / Hard" — feeds spaced repetition)
5. **Next problem** — mix of new material + review from past topics
6. **Session complete** — show XP earned, problems correct, streak update

### Mastery System (Per Topic)

Each of the ~14 FE exam topics has a mastery level:

| Level | Name | Meaning |
|-------|------|---------|
| 0 | Not Started | No problems attempted |
| 1 | Introduced | Completed first session |
| 2 | Practicing | Answered 50%+ correctly |
| 3 | Familiar | Answered 75%+ correctly across multiple sessions |
| 4 | Proficient | Passed a topic quiz (timed, exam-like) |
| 5 | Mastered | Maintained proficiency over time via spaced review |

Mastery can **decay** if a topic isn't reviewed — this drives spaced repetition naturally.

### XP System

| Action | XP |
|--------|-----|
| Complete a problem correctly | +10 XP |
| Complete a problem incorrectly (but attempted) | +5 XP |
| Complete a full session (5-8 problems) | +25 XP bonus |
| Complete daily review | +50 XP bonus |
| Maintain streak (per day) | +10 XP |
| Pass a topic quiz | +100 XP |

### Daily Review (Spaced Repetition)

A special session that pulls problems from all topics the user has studied, weighted toward:
- Topics close to mastery decay
- Topics the user got wrong recently
- Older topics that need refreshing

This is the highest-value feature — it's what actually makes people pass the exam.

---

## Part 5: Implementation Phases

### MVP (Phase 1) — "Make it work"
- Problem sessions: one problem at a time with immediate feedback
- Topic routing: each topic loads its own problems from the database
- Basic progress tracking: problems completed per topic
- Streak counter: consecutive days with at least one session
- XP: earned per problem and per session

### Phase 2 — "Make it sticky"
- Mastery levels per topic (visible on dashboard)
- Daily review mode (spaced repetition, simple algorithm)
- Streak freeze (1 per week)
- Weekly leaderboard (XP-based, small cohorts)
- Achievement badges for milestones

### Phase 3 — "Make it smart"
- Adaptive difficulty (serve harder/easier problems based on performance)
- Full spaced repetition algorithm (SM-2 or FSRS)
- Timed practice mode (simulate FE exam time pressure)
- Topic quiz mode (exam-like conditions per topic)
- Study plan generator (recommended daily schedule)

### Phase 4 — "Make it a business"
- Full FE exam simulator (all topics, timed, scored)
- Payment integration (free tier + paid features)
- Admin panel for content management
- Analytics dashboard
- Mobile-optimized PWA

---

## Part 6: How This Changes the Architecture

The learning model above means the architecture needs to support:

| Feature | Architecture Requirement |
|---------|------------------------|
| One-problem-at-a-time sessions | API that serves individual problems, not all at once |
| Multiple choice answers | Problems stored with answer options + correct answer + solution |
| XP and streaks | User stats collection in database |
| Mastery levels | Per-topic scoring tracked and calculated |
| Spaced repetition | Algorithm that selects which problems to review |
| Leaderboards | Aggregate XP query across users |
| Topic routing | URL params + dynamic content loading |

**This is why we needed this research before building the architecture.**

---

## References

- Duolingo streaks increased commitment by 60% — [Orizon](https://www.orizon.co/blog/duolingos-gamification-secrets)
- Streak Freeze reduced churn by 21% — [StriveCloud](https://www.strivecloud.io/blog/gamification-examples-boost-user-retention-duolingo)
- XP leaderboards drive 40% more engagement — [OpenLoyalty](https://www.openloyalty.io/insider/how-duolingos-gamification-mechanics-drive-customer-loyalty)
- Leagues increased lesson completion by 25% — [Trophy](https://trophy.so/blog/duolingo-gamification-case-study)
- Gamification meta-analysis: large effect size g=0.822 — [Frontiers in Psychology](https://pmc.ncbi.nlm.nih.gov/articles/PMC10591086/)
- FSRS algorithm: personalized spaced repetition — [GitHub](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm)
- FE exam prep market gamification gap — [Test Prep Insight](https://testprepinsight.com/best/best-fe-exam-prep-courses/)
- PrepFE pricing — [prepfe.com](https://www.prepfe.com/pricing)
- PPI2Pass — [ppi2pass.com](https://ppi2pass.com/fe-exam/civil)
- Brilliant.org gamification — [Trophy](https://trophy.so/blog/brilliant-gamification-case-study)
