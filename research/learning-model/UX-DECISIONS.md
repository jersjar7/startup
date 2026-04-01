# FE for Raccoons — UX Decisions Log

Decisions about how the study experience works and why. Reference this before building any practice flow, feedback system, or session structure.

---

## 1. Wrong Answers: Immediate Feedback, No Retry

**Decision:** When a student answers incorrectly, show the correct answer immediately. No second chance on the same question.

**Why:**
- Immediate corrective feedback creates stronger memory associations than trial-and-error guessing (testing effect research).
- Allowing retries encourages elimination strategy — students click choices until they hit the right one and learn nothing.
- The real FE exam gives one shot per question. Training in exam conditions builds the right habits.
- Duolingo, Brilliant, and Khan Academy all use this pattern: reveal answer, explain, move on.

**What happens instead of retry:** The question resurfaces later via spaced repetition. That's the real "retry" — answering the same concept days later from memory.

**On wrong answer, the app:**
1. Highlights the correct choice (green) and the student's wrong choice (red)
2. Shows a feedback banner with the correct answer
3. Auto-opens the "Explain like I'm 5" panel for immediate understanding
4. Student clicks "Next Problem" to continue

---

## 2. No Back Button During Practice

**Decision:** Students move forward only through a lesson session. No navigating back to previous questions.

**Why:**
- Forward-only momentum keeps focus and prevents second-guessing.
- Going back mid-session encourages doubt ("should I change my answer?") rather than commitment and learning from feedback.
- Duolingo uses this exact pattern: forward only, no revisiting.
- The learning happens in the feedback moment, not in reconsidering the question.

---

## 3. Post-Session Review (Review Mistakes)

**Decision:** After completing all questions in a lesson, the summary screen shows a "Review Mistakes" option when the student got any wrong.

**Flow:**
```
Q1 --> Q2 --> Q3 --> Summary Screen
                       |
                       +--> Perfect (3/3):
                       |      "Back to Chapter" + "Try Again"
                       |      Clean celebration, no review needed.
                       |
                       +--> Got any wrong (0/3, 1/3, 2/3):
                              "Review Mistakes" (primary CTA, prominent)
                              "Try Again" (secondary)
                              "Back to Chapter" (secondary)
```

**Review screen shows (only missed questions):**
- The problem statement
- Student's answer (marked red) vs correct answer (marked green)
- ELI5 explanation
- Step-by-step worked solution
- "Try Again" button at the bottom to restart the lesson

**Why this order:**
- Summary first = reward moment. Students see their score and XP before anything else.
- Review is opt-in, not forced. Forcing review feels punitive; offering it feels supportive.
- Only showing missed questions keeps review focused. Reviewing correct answers wastes time.
- "Try Again" after review creates a natural loop: review what you missed, then practice again.

---

## 4. Lesson Content Structure (Block-Based)

**Decision:** Lesson explanations use structured content blocks instead of raw text.

**Block types:**
- `text` — Prose paragraphs with optional inline math ($...$)
- `heading` — Sub-headings within the lesson
- `formula` — Display-mode KaTeX (stacked fractions, centered equations)
- `callout` — Highlighted tip (green), warning (yellow), or exam note (blue)
- `diagram` — React SVG component referenced by name

**Why:**
- Inline math makes fractions unreadable (opp/hyp vs stacked fraction).
- Structured blocks create clear visual hierarchy: text, then formula, then tip.
- Callouts draw attention to mnemonics and exam traps without cluttering prose.
- React SVG diagrams are reusable, responsive, and brand-consistent.

---

## 5. Resource Panels (Right Column)

**Decision:** Six collapsible resource panels appear alongside each problem.

| Panel | Unlocked | Purpose |
|-------|----------|---------|
| Lesson | Always | Lesson explanation with formulas and diagrams |
| FE Handbook | Always | The exact formula from the FE Reference Handbook |
| Explain like I'm 5 | After submit | Plain-language explanation of the solution |
| Step-by-Step | After submit | Numbered worked solution with KaTeX |
| Video | After submit | Link to video explanation (when available) |
| Common Traps | After submit | Exam-specific pitfalls for this problem |

**Why locked until submit:**
- Prevents students from reading the solution before attempting the problem.
- Auto-opens ELI5 on wrong answer to provide immediate help.
- Lesson and Handbook are always available because they're reference material, not answers.

---

## 6. Session Size

**Decision:** Each lesson contains 3 problems (easy, medium, hard).

**Why:**
- Short sessions (5-10 minutes) match the bite-sized philosophy from the learning model.
- 3 problems is enough to cover a concept without overwhelming.
- Difficulty progression within a lesson builds confidence before challenging.
- Keeps the "just one more lesson" feeling that drives engagement.

---

## Design Principles (Reference)

These principles guide all UX decisions:

1. **Respect the adult learner.** No excessive celebrations, no hearts/lives, no patronizing animations. These are engineers preparing for a professional exam.
2. **One thing at a time.** One problem on screen. One action to take. Clear next step.
3. **Feedback is immediate and constructive.** Never punitive, always educational.
4. **Momentum over perfection.** Keep moving forward. Wrong answers are learning moments, not failures.
5. **Make the right action obvious.** Primary CTA is always clear. Secondary options don't compete.
