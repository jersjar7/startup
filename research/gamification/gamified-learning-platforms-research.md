# Gamified Learning Platforms Research

**Date:** March 2026
**Purpose:** Extract design patterns from gamified learning platforms (especially Duolingo) that could apply to FE for Raccoons -- a study platform for the Fundamentals of Engineering exam.

---

## 1. Duolingo's Core Mechanics

Duolingo is not a language app that happens to use gamification -- it is a gamification engine that happens to teach languages. With 128+ million monthly active users (Q2 2025) and a $14B+ valuation, it is the most successful gamified education app ever built. Here are the specific mechanics that make it work.

### 1.1 Streaks

- **What it is:** A counter tracking consecutive days of app usage. Over 9 million users maintain a 1-year+ streak.
- **Why it works:** Leverages loss aversion -- people are more motivated to avoid losing progress than to gain something new. Streaks increased user commitment by 60%.
- **Streak Freeze:** Users can "freeze" their streak for a limited number of days, which reduced churn by 21% for at-risk users. This is critical because it prevents rage-quitting from a single missed day.
- **Design insight:** The streak is displayed prominently everywhere. It becomes part of the user's identity. Breaking a long streak feels like a genuine loss.

### 1.2 XP (Experience Points)

- **What it is:** Points earned for completing lessons, challenges, and activities. XP accumulates to unlock levels.
- **Why it works:** Provides immediate, tangible feedback for effort. A progress bar fills in real-time during lessons with celebratory animations on completion. XP leaderboards drive 40% more engagement.
- **Design insight:** XP is the universal currency connecting all other systems (leagues, levels, streaks). Everything earns XP, making it feel like nothing is wasted effort.

### 1.3 Hearts/Lives System

- **What it is:** Originally, users had 5 hearts (lives). Each wrong answer cost one heart. Running out of hearts stopped progress until hearts regenerated (or were purchased).
- **Evolution:** Duolingo evolved to a more forgiving energy system. Heart refills can be earned through practice or purchased with gems.
- **Design insight:** Creates a sense of scarcity and stakes. Users pay more attention when mistakes have consequences. However, Duolingo has softened this over time because excessive punishment drives users away.

### 1.4 Leagues and Leaderboards

- **What it is:** 10 leagues from Bronze to Diamond. Users are grouped into 30-person cohorts based on weekly XP. Top performers are promoted; bottom performers are demoted. Leaderboards reset every Sunday.
- **Why it works:** Introduced leagues and increased lesson completion by 25%. Social competition triggers the desire for status and achievement.
- **Design insight:** Cohorts are small (30 people) and randomized so users always feel competitive. Being in a 30-person league feels achievable; being ranked against millions would be demoralizing.

### 1.5 Skill Tree / Learning Path

- **Old design:** A branching skill tree where users chose their own path.
- **New design (2022+):** A single winding path (like a board game) organized into Sections > Units > Levels > Lessons. Users follow a prescribed order.
- **Why it changed:** The linear path reduced decision paralysis and embedded spaced repetition directly into the path ordering. Users do not need to decide what to study -- the path decides for them.
- **Design insight:** The path includes built-in review sessions at intervals to reinforce previously learned material. The structure is hierarchical: Sections (aligned with proficiency standards) > Units (thematic) > Steps (individual bite-sized tasks).

### 1.6 Bite-Sized Lessons

- **Duration:** Each lesson takes roughly 3-5 minutes.
- **Why it works:** Low commitment threshold. Users feel they can "always do just one more." This exploits the Zeigarnik effect (incomplete tasks create tension that motivates completion).
- **Design insight:** Short sessions have higher completion rates than long ones. Users who start a 3-minute lesson almost always finish it.

### 1.7 Lesson Exercise Types

Duolingo uses a variety of question formats within each lesson to keep engagement high:

| Exercise Type | Description |
|---|---|
| **Multiple choice** | Select the correct answer from options |
| **Translation** | Translate a sentence from one language to another |
| **Tap the words** | Arrange shuffled words into the correct order |
| **Fill in the blank** | Complete a sentence with the missing word |
| **Match pairs** | Connect items in two columns |
| **Type what you hear** | Transcribe audio |
| **Picture matching** | Match words to images |

**Key insight for FE Raccoons:** The variety of question types keeps the brain engaged. Asking the same concept in different ways (identify the formula, apply the formula, fill in a missing step, match the concept to the definition) strengthens neural pathways differently than repeating the same format.

### 1.8 Duolingo User Flow (App Open to Session Complete)

1. **Open app** -> See streak counter, daily goal progress, and current position on the learning path
2. **Tap next lesson** -> Brief intro/context (if new concept), then immediately into questions
3. **Answer questions** -> Real-time feedback (correct/incorrect), progress bar fills, XP accumulates
4. **Complete lesson** -> Celebration screen, XP earned, streak updated, optional "continue" prompt
5. **Post-lesson** -> League position updated, badges earned, "one more lesson?" nudge
6. **Close app** -> Push notification reminders if streak is at risk

### 1.9 Duolingo's Impact Metrics

| Metric | Impact |
|---|---|
| Streaks | +60% commitment |
| XP Leaderboards | +40% engagement |
| Leagues | +25% lesson completion |
| Badges | +30% completion rates |
| Streak Freeze | -21% churn for at-risk users |
| Double XP events | +50% activity surge |
| 60-day retention | 3x higher than non-gamified competitors |

---

## 2. Other Gamified Education Platforms

### 2.1 Khan Academy

- **Gamification elements:** Energy points, badges, skill tree/constellation (visual knowledge map), avatars, mastery levels per skill
- **Badge system:** Tiered badges from easy (participation) to extremely hard ("10,000 Problems Solved"). The hard badges represent real commitment and feel meaningful.
- **Mastery system:** Skills have levels (Familiar, Proficient, Mastered). You level up by consistently answering correctly. Skills can decay if not practiced.
- **What works well:** The mastery framework ties directly to learning outcomes. Badges feel earned, not given. The visual skill map gives a sense of the overall knowledge landscape.
- **What does not work well:** Gamification is lighter than Duolingo. No streaks (historically), no leagues, no competitive element. Lower stickiness as a result.

### 2.2 Brilliant.org

- **Most relevant to FE Raccoons** because Brilliant focuses on STEM, math, and problem-solving.
- **Core approach:** Interactive problem-solving. Every lesson is built around solving problems, not watching videos. Users make decisions, drag-and-drop, and test understanding interactively.
- **Gamification elements:** Streaks, leagues, points, progress tracking, badge system, unlockable content
- **Design philosophy:** "Avoid packing too many game incentives into the product to keep focus on learning content." Execute well on a few core habit loops.
- **Spaced repetition:** Built into the system. The platform predicts the optimal next problem and mixes practice problems from different concepts.
- **Adaptive difficulty:** The platform adjusts difficulty based on performance to maintain flow state.
- **Key insight:** Brilliant proves that STEM/math content CAN be gamified effectively. Their interactive problem format (not passive video) is more effective for engineering-style learning.

### 2.3 Quizlet

- **Core product:** User-created flashcard sets
- **Gamification elements:** Study modes (Learn, Flashcards, Write, Spell, Test, Match, Gravity game), streaks, progress tracking
- **Key insight:** The act of creating flashcards is itself a learning activity. This engages active recall and organization.
- **Match game:** A timed matching game that turns flashcard review into a competitive activity (compete against your own time or others).
- **Limitation:** Flashcard-based learning works for memorization but is less effective for problem-solving skills that require multi-step reasoning.

### 2.4 Anki

- **Core product:** Flashcard system with spaced repetition
- **Gamification elements:** Minimal. Streak tracking, review counts, "heat map" of activity, deck completion stats
- **Strength:** The most scientifically rigorous spaced repetition implementation available. Used extensively by medical students.
- **Weakness:** Ugly UI, steep learning curve, no social features, no gamification to speak of. Users must be intrinsically motivated.
- **Key insight:** Anki proves that spaced repetition alone is incredibly powerful for retention (200-300% better than traditional study). But without gamification, only highly motivated users stick with it. The opportunity is to combine Anki-level spaced repetition with Duolingo-level engagement.

### 2.5 Other Notable Platforms

| Platform | Key Gamification Elements | Relevance to FE Raccoons |
|---|---|---|
| **Kahoot!** | Real-time competitive quizzes, leaderboards, music/energy | Great for live study groups; hard to replicate in async solo study |
| **Codecademy** | Streaks, progress bars, project badges, skill paths | Similar structure to what FE Raccoons could use (topic paths) |
| **Mathspace** | Step-by-step problem solving, hints, adaptive difficulty | Directly relevant for math-heavy FE content |
| **Photomath** | Step-by-step solutions, visual breakdowns | Good UX model for showing worked solutions |

---

## 3. Spaced Repetition Deep Dive

### 3.1 What Is Spaced Repetition?

The spacing effect: your brain retains information better when you review it at increasing intervals over time, rather than cramming. Material you know well is reviewed less frequently; material you struggle with is reviewed more often.

### 3.2 The SM-2 Algorithm (Classic Anki)

The original SuperMemo 2 algorithm, used by Anki for decades:

**Inputs:**
- `quality` (0-5): How well you recalled the answer (0 = total blackout, 5 = perfect)
- `repetitions`: Number of times reviewed
- `previous_ease_factor`: How "easy" this card is for you (starts at 2.5)
- `previous_interval`: Days since last review

**Core logic:**
```
If quality >= 3 (passed):
  If repetitions == 0: interval = 1 day
  If repetitions == 1: interval = 6 days
  If repetitions >= 2: interval = previous_interval * ease_factor

If quality < 3 (failed):
  Reset repetitions to 0, interval = 1 day

Ease factor adjustment:
  EF = EF + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
  Minimum EF = 1.3
```

**Key properties:**
- First review: 1 day later
- Second review: 6 days later
- Subsequent reviews: interval grows by the ease factor (typically 2.5x)
- Struggling cards get shorter intervals; easy cards get longer intervals
- Ease factor never drops below 1.3

### 3.3 FSRS (Free Spaced Repetition Scheduler) -- The Modern Approach

FSRS replaced SM-2 in Anki 23.10+ and is now the recommended algorithm:

- **Built with machine learning:** Trained on 700 million reviews from 20,000 real users
- **Three Component Model of Memory:** Models stability (how long before you forget), difficulty (inherent card difficulty), and retrievability (probability of recall right now)
- **Personalized:** Uses an optimizer that learns YOUR specific memory patterns from your review history
- **More efficient:** Users need fewer reviews than SM-2 to achieve the same retention level
- **Better at handling delays:** If you skip reviews for a while, FSRS handles the catch-up better than SM-2

### 3.4 Spaced Repetition for Engineering Exam Prep

**Why it is especially valuable for FE exams:**
- The FE exam covers 15+ topics with hundreds of formulas and concepts
- Students need to retain knowledge across all topics simultaneously, not just cram one topic at a time
- Engineering math is hierarchical: advanced topics build on basics. Forgetting fundamentals undermines everything

**How to implement it for problem-solving (not just flashcards):**
- **Formula cards:** "What is the distance formula?" -> Classic flashcard format
- **Application cards:** "Find the distance between (2,3) and (5,7)" -> Show the problem, user solves it, then rates difficulty
- **Concept cards:** "When would you use the dot product vs. the cross product?" -> Conceptual understanding
- **Multi-step problems:** Present a problem, user works through steps, system tracks which step types need more review
- **Hierarchical scheduling:** Advanced skills implicitly practice simpler skills. If a student solves an integration by parts problem, they are also practicing basic integration

### 3.5 Practical Implementation for a Web App

```
// Simplified SM-2 implementation for FE Raccoons
function calculateNextReview(quality, repetitions, easeFactor, interval) {
  let newEF = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
  newEF = Math.max(1.3, newEF);

  let newInterval;
  let newReps;

  if (quality >= 3) {  // Passed
    if (repetitions === 0) newInterval = 1;
    else if (repetitions === 1) newInterval = 6;
    else newInterval = Math.round(interval * newEF);
    newReps = repetitions + 1;
  } else {  // Failed
    newInterval = 1;
    newReps = 0;
  }

  return {
    interval: newInterval,        // Days until next review
    repetitions: newReps,
    easeFactor: newEF,
    nextReviewDate: addDays(new Date(), newInterval)
  };
}
```

---

## 4. Key Gamification Principles for Education

### 4.1 What Research Says

**Meta-analysis findings (41 studies, 5,071+ participants):**
- Overall effect size: g = 0.822 (large) for gamification vs. non-gamified instruction
- Cognitive learning outcomes: g = 0.49 (medium)
- Motivational outcomes: g = 0.36 (small-medium)
- Behavioral outcomes: g = 0.25 (small)

**Key moderating factors:**
- Duration matters: Both very short (<1 week) and very long (20+ weeks) interventions show strong effects, but for different reasons
- Educational discipline matters: STEM gamification has shown 20% increase in conceptual understanding
- Design quality matters more than the number of game elements

**Specific STEM finding:** A study of 175 calculus students using leaderboard-based gamification found significant improvement in learning performance. Gamified eLearning courses can increase engagement by up to 60%.

### 4.2 What Actually Improves Retention

| Element | Retention Impact | Why |
|---|---|---|
| **Spaced repetition** | Very High | Directly targets the forgetting curve. 200-300% better retention. |
| **Active recall (testing)** | Very High | Retrieving information strengthens memory more than re-reading. |
| **Immediate feedback** | High | Corrects misconceptions before they solidify. |
| **Streaks** | High (indirect) | Does not improve retention per se, but ensures daily practice, which does. |
| **Progress tracking** | Medium | Metacognition (knowing what you know) improves study efficiency. |
| **Interleaving** | Medium-High | Mixing problem types improves transfer and discrimination. |
| **Social competition** | Medium | Increases time spent studying, which indirectly improves retention. |

### 4.3 What Is Just Fluff

| Element | Impact | Why It Fails |
|---|---|---|
| **Arbitrary points** | Low | Points not tied to real progress are quickly ignored ("pointsification"). |
| **Cosmetic badges** | Low | "You logged in!" badges feel patronizing. Only achievement badges work. |
| **Excessive animations** | Neutral/Negative | Can feel condescending for adult learners and slow down the experience. |
| **Complex narratives** | Low for exam prep | Story elements distract from the core task of learning formulas and solving problems. |
| **Avatar customization** | Low | Fun initially but has no lasting impact on learning behavior. |

### 4.4 The Critical Distinction: Gamification vs. Pointsification

"The simple addition of points and badges is a misuse of the gamification concept, referred to as 'pointsification.'" Real gamification requires:

1. **Clear goals** tied to real learning outcomes
2. **Meaningful progress indicators** (not arbitrary points)
3. **Appropriate challenge levels** (flow state)
4. **Autonomy** (some choice in what/when to study)
5. **Emotional investment** (streak fear, league promotion, mastery pride)

### 4.5 Minimum Viable Gamification (What Still Works)

Based on the research, the minimum gamification that still produces meaningful engagement improvements:

1. **Streaks** -- The single most impactful mechanic for building daily habits. Non-negotiable.
2. **Progress tracking** -- Visual indicator of what you have completed and what remains. Essential for any study tool.
3. **XP / Points tied to real activity** -- Must be connected to actual problem-solving, not just clicking around.
4. **Immediate feedback** -- Correct/incorrect with explanation. This is both a learning tool and a gamification element.

**Nice-to-have (for v2):**
5. Leaderboards (weekly, small cohorts)
6. Achievement badges (milestone-based, not participation-based)
7. Difficulty adaptation

---

## 5. What Works for Engineering Exam Prep Specifically

### 5.1 Context: What Makes Engineering Exams Different

- **Math-heavy:** Requires solving multi-step quantitative problems, not recognizing vocabulary
- **Formula-dense:** Hundreds of formulas across 15+ topics
- **Hierarchical:** Advanced topics depend on mastery of fundamentals
- **Time-pressured:** FE exam is 5 hours 20 minutes, 110 questions (~3 min per question)
- **High stakes:** Pass/fail, affects career trajectory, costs $175 to retake
- **Adult learners:** Users are college students or recent graduates -- they do not want to feel like they are playing a children's game

### 5.2 Elements That Translate Well

| Element | Why It Works for FE Prep | Implementation |
|---|---|---|
| **Streaks** | Daily practice is essential for retaining formulas across 15+ topics. A streak keeps students coming back. | Track consecutive days with at least 1 problem solved. Offer streak freeze (1-2 per week). |
| **Spaced repetition** | Perfect for formula retention and concept review. The FE exam requires broad recall, not deep expertise in one area. | SM-2 or FSRS algorithm scheduling problem review across all topics. |
| **Progress tracking** | Students need to know which topics they have mastered and which need work. | Visual topic map showing mastery level per topic (0-100% or color-coded). |
| **Bite-sized sessions** | Engineers are busy students. 5-10 minute daily sessions are sustainable; 2-hour sessions are not. | Each "lesson" = 5-8 problems, takes ~5-10 minutes. |
| **XP tied to problems solved** | Rewards actual studying. XP = problems attempted and completed (not just time spent). | Award XP per problem. Bonus XP for streaks of correct answers. |
| **Immediate feedback with worked solutions** | Engineering problems require understanding the solution process, not just the answer. | Show step-by-step solutions after each attempt. Highlight where the user went wrong. |
| **Weekly leaderboards** | Social motivation works for college students studying the same exam. | Small cohorts (20-30 people). Weekly reset. Based on XP earned. |
| **Mastery levels per topic** | Maps directly to FE exam topics. Students can see which areas need more work. | 5 levels: New > Learning > Familiar > Proficient > Mastered. Based on spaced repetition performance. |
| **Interleaved practice** | Mix problems from different topics in review sessions. This is how the real FE exam works. | "Daily review" sessions pull problems from multiple topics based on spaced repetition schedule. |
| **Timed practice mode** | The FE exam is time-pressured. Practicing under time constraints builds speed. | Optional timer per problem (~3 min). Track average solve time per topic. |

### 5.3 Elements That Translate Poorly

| Element | Why It Does NOT Work for FE Prep | Alternative |
|---|---|---|
| **Hearts/Lives system** | Engineering problems are HARD. Losing progress because you got 3 calculus problems wrong would be infuriating and would punish learning. | No penalty for wrong answers. Instead, wrong answers trigger more review (spaced repetition). |
| **Complex storylines/narratives** | Adult engineering students preparing for a professional exam do not want to "save the kingdom." It feels patronizing. | Keep the tone professional but friendly. The raccoon mascot can provide encouragement without being a narrative device. |
| **Match-pairs/word-tap exercises** | These work for vocabulary but not for multi-step math problems. You cannot "match" a calculus problem to its answer. | Use multiple choice, numerical input, step-by-step solution building, and formula identification. |
| **Punishment mechanics** | Losing XP, demoting in leagues for inactivity, or harsh penalties for wrong answers cause anxiety in high-stakes prep. | Use positive reinforcement. Show what was gained, not what was lost. |
| **Speed-only rewards** | Rewarding only speed encourages guessing and discourages careful problem-solving. | Reward accuracy AND completion. Bonus XP for speed only in timed practice mode. |
| **Excessive celebrations** | Over-the-top animations feel patronizing to adults studying for a professional exam. | Subtle, clean feedback. A brief "Correct!" with green highlight, not confetti explosions. |

### 5.4 Recommended Question Types for FE Raccoons

Adapting Duolingo's variety principle for engineering problems:

| Question Type | Description | Example |
|---|---|---|
| **Multiple choice** | Standard FE exam format. 4 options. | "What is the derivative of sin(x)cos(x)?" A) cos(2x)/2 B) ... |
| **Numerical input** | Type the answer. More rigorous than multiple choice. | "Calculate the moment of inertia for a rectangular beam (b=10cm, h=20cm)." Answer: ____ cm^4 |
| **Formula identification** | Given a scenario, select the correct formula. | "Which equation would you use to find the stress in a thin-walled pressure vessel?" |
| **Step ordering** | Put solution steps in the correct order. | Drag steps of integration by parts into correct sequence. |
| **Fill in the missing step** | A solution is shown with one step missing. Fill it in. | "Step 1: F=ma, Step 2: ____, Step 3: a = 9.81 m/s^2, therefore F = 49.05N" |
| **Concept matching** | Match concepts to definitions or formulas to names. | Match: "Hooke's Law" <-> "F = kx" |
| **Estimation** | Quick estimation problems to build engineering intuition. | "Approximately how much force does a 10kg mass exert at sea level?" |

### 5.5 Recommended Feature Priority for FE Raccoons

**MVP (Phase 1) -- Minimum viable gamification:**
1. Streak counter (consecutive days with 1+ problem solved)
2. XP system (points per problem, bonus for correct answers)
3. Progress tracking per topic (% complete, mastery level)
4. Immediate feedback with worked solutions
5. Bite-sized sessions (5-8 problems per session)
6. Basic spaced repetition (schedule review problems based on past performance)

**Phase 2 -- Social and competitive:**
7. Weekly leaderboard (small cohorts)
8. Achievement badges (milestone-based: "50 problems solved", "5-day streak", "Mastered Analytic Geometry")
9. Daily review mode (interleaved problems from multiple topics)
10. Streak freeze (1-2 per week)

**Phase 3 -- Advanced:**
11. Timed practice mode
12. Adaptive difficulty
13. Full FSRS-based spaced repetition
14. Study group features (real-time via WebSocket -- already partially built)
15. Simulated FE exam mode (110 questions, timed, mixed topics)

### 5.6 Mapping to Existing FE Raccoons Architecture

Based on the current codebase:

| Current Feature | Gamification Enhancement |
|---|---|
| **Dashboard** (`/dashboard`) -- Topic grid | Add mastery level indicators, streak counter, XP display, daily goal progress |
| **Study** (`/study`) -- Topic content page | Add lesson structure (concept review + practice problems), progress within lesson |
| **Problems** (`/problems`) -- Practice problems | Replace checkbox completion with interactive problem-solving, add XP rewards, spaced repetition scheduling, immediate feedback |
| **WebSocket live activity** | Extend to show leaderboard updates, study buddy status, "X just mastered Y topic" notifications |
| **Backend `/api/progress`** | Extend to store spaced repetition data (ease factor, interval, next review date per problem) |

---

## 6. Summary: The Design Formula

The most effective gamified engineering exam prep platform would combine:

**From Duolingo:** Streaks, XP, bite-sized sessions, progress paths, leagues, and the principle of making the user feel like they are making progress every single day.

**From Brilliant.org:** Interactive problem-solving (not passive video), adaptive difficulty, and the philosophy of "few mechanics, well-executed."

**From Anki/FSRS:** Scientifically rigorous spaced repetition to ensure long-term retention across all FE exam topics.

**From Khan Academy:** Meaningful mastery levels tied to real skill, not participation.

**Unique to engineering exams:** No lives/hearts (mistakes are learning), step-by-step solution feedback, formula identification exercises, timed practice mode, interleaved multi-topic review, and a professional (not childish) tone.

The core insight: **Spaced repetition is the engine. Gamification is the fuel.** Spaced repetition ensures students actually retain what they study. Gamification ensures they show up every day to study in the first place.

---

## Sources

- [Duolingo Gamification Secrets -- Orizon](https://www.orizon.co/blog/duolingos-gamification-secrets)
- [The Good, the Bad and the Ugly of Duolingo Gamification -- UX Collective](https://uxdesign.cc/the-good-the-bad-and-the-ugly-of-duolingo-gamification-3a12f0e80dc7)
- [Duolingo Case Study 2025 -- Young Urban Project](https://www.youngurbanproject.com/duolingo-case-study/)
- [Duolingo: Gamification as Design Language -- Blake Crosley](https://blakecrosley.com/guides/design/duolingo)
- [Duolingo Gamification Explained -- StriveCloud](https://www.strivecloud.io/blog/gamification-examples-boost-user-retention-duolingo)
- [How Duolingo's Gamification Mechanics Drive Loyalty -- OpenLoyalty](https://www.openloyalty.io/insider/how-duolingos-gamification-mechanics-drive-customer-loyalty)
- [Duolingo's Customer Retention Strategy 2026 -- Propel](https://www.trypropel.ai/resources/duolingo-customer-retention-strategy)
- [Duolingo Gamification Case Study -- Trophy](https://trophy.so/blog/duolingo-gamification-case-study)
- [The Science Behind Duolingo's Home Screen Redesign -- Duolingo Blog](https://blog.duolingo.com/new-duolingo-home-screen-design/)
- [FAQ: Duolingo's New Learning Path -- Duolingo Help Center](https://support.duolingo.com/hc/en-us/articles/6448741924237-FAQ-Duolingo-s-new-learning-path)
- [Duolingo Onboarding UX Breakdown -- UserGuiding](https://userguiding.com/blog/duolingo-onboarding-ux)
- [How Brilliant Uses Gamification -- Trophy](https://trophy.so/blog/brilliant-gamification-case-study)
- [Top 10 Gamification Education Apps -- Yu-kai Chou](https://yukaichou.com/gamification-examples/top-10-education-gamification-examples/)
- [Gamification in EdTech -- ProdWrks](https://prodwrks.com/gamification-in-edtech-lessons-from-duolingo-khan-academy-ixl-and-kahoot/)
- [FSRS vs SM-2 Guide 2025 -- MemoForge](https://memoforge.app/blog/fsrs-vs-sm2-anki-algorithm-guide-2025/)
- [Anki SM-2 Algorithm -- RemNote Help Center](https://help.remnote.com/en/articles/6026144-the-anki-sm-2-spaced-repetition-algorithm)
- [FSRS Algorithm Wiki -- GitHub](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm)
- [What Spaced Repetition Algorithm Does Anki Use? -- Anki FAQs](https://faqs.ankiweb.net/what-spaced-repetition-algorithm)
- [SM-2 Algorithm Explained -- Tegaru](https://tegaru.app/en/blog/sm2-algorithm-explained)
- [Meta-analysis: Gamification in Education -- PMC/Frontiers in Psychology](https://pmc.ncbi.nlm.nih.gov/articles/PMC10591086/)
- [The Gamification of Learning Meta-analysis -- Springer](https://link.springer.com/article/10.1007/s10648-019-09498-w)
- [Gamification Enhances Intrinsic Motivation Meta-analysis -- Springer](https://link.springer.com/article/10.1007/s11423-023-10337-7)
- [How Gamification Boosts Learning in STEM Higher Education -- Springer](https://link.springer.com/article/10.1186/s40594-024-00521-3)
- [Gamification Streaks in Learning -- Growth Engineering](https://www.growthengineering.co.uk/gamification-streaks/)
- [Gamification vs. Pointsification -- Frontiers in Education](https://www.frontiersin.org/journals/education/articles/10.3389/feduc.2023.1212994/full)
- [The Psychology of Gamification and Learning -- BadgeOS](https://badgeos.org/the-psychology-of-gamification-and-learning-why-points-badges-motivate-users/)
- [Gamification in Math Learning -- Wiris](https://www.wiris.com/en/blog/gamification-math-learning-benefits-challenges/)
- [Gamification on Math Engagement Meta-analysis -- Springer](https://link.springer.com/article/10.1007/s10648-025-10108-1)
- [Spaced Repetition for Math -- Memoo](https://memoo.app/blog/spaced-repetition-for-learning-and-retaining-math-concepts/)
- [Using Spaced Repetition for Mathematics -- Cognitive Medium](https://cognitivemedium.com/srs-mathematics)
- [Individualized Spaced Repetition in Hierarchical Knowledge Structures -- Justin Skycak](https://www.justinmath.com/individualized-spaced-repetition-in-hierarchical-knowledge-structures/)
