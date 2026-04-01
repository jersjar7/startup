# FE for Raccoons — Product Roadmap

Based on [Learning Model Research](./LEARNING-MODEL.md)

---

## Phase 1: MVP — "Make it work"

### Architecture & Backend
- [x] Reorganize backend: separate routes, controllers, and middleware into their own files
- [x] Add input validation on all endpoints (email format, password strength, field types)
- [x] Add `/api/health` endpoint (confirms service + DB are running)
- [x] Add request logging with timestamps
- [x] Move credentials to environment variables (replace dbConfig.json with .env)
- [x] Add `helmet` for HTTP security headers
- [x] Remove unused dependencies (bootstrap, react-bootstrap) from frontend package.json

### Database & Content
- [x] Design MongoDB schema for topics, problems, and user stats
- [x] Create `topics` collection with all FE Civil exam topics and metadata
- [x] Create `problems` collection with multiple-choice format (question, options, correct answer, worked solution)
- [x] Seed database with Analytic Geometry problems (first topic, real FE-level content)
- [x] Create API endpoint: `GET /api/topics/:topicId` — fetch single topic with study materials
- [x] Create API endpoint: `GET /api/topics/:topicId/problems` — fetch problems for a topic
- [x] Create API endpoint: `POST /api/sessions` — submit session results (answers, XP earned)
- [x] Add database indexes on frequently queried fields (email, token, topicId)

### Frontend — Core Experience
- [x] Add topic routing: `/study/:topicId` and `/problems/:topicId` (pass topic ID through URL)
- [x] Redesign problems page: one problem at a time (not all at once)
- [x] Add multiple-choice answer selection with immediate feedback
- [x] Show worked solution after each answer (correct or incorrect)
- [x] Add session summary screen after completing a round (problems correct, XP earned)
- [x] Dashboard: show actual progress per topic from database (not hardcoded "0")
- [x] Eliminate inline styles — use CSS variables consistently
- [x] Make topic cards keyboard-accessible (use `<button>` instead of `<div>`)

### Gamification — Basic
- [x] Implement XP system: +10 correct, +5 incorrect, +25 session bonus
- [x] Store XP in user stats collection in database
- [x] Display total XP on dashboard
- [x] Implement streak counter: track consecutive days with at least 1 completed session
- [x] Display streak on dashboard
- [x] Store streak data (current streak, last session date) in database

---

## Phase 2: "Make it sticky"

### Mastery System
- [x] Calculate mastery level (0–3) per topic based on session history
- [x] Display mastery bars on dashboard topic cards
- [x] Implement mastery decay: reduce level if topic not reviewed in X days
- [x] Visual indicator when a topic is "decaying" (needs review)

### Spaced Repetition
- [x] Implement basic spaced repetition: track last-seen date and performance per problem
- [x] Create "Daily Review" mode: mixed problems from past topics, weighted by need
- [x] API endpoint: `GET /api/review` — returns a personalized set of review problems
- [x] Add Daily Review button on dashboard

### Social & Motivation
- [x] Weekly leaderboard: rank users by XP earned that week (30-person cohorts)
- [x] Display leaderboard on dashboard
- [x] Streak freeze: allow 1 missed day per week without breaking streak
- [x] Achievement badges for milestones (first session, 7-day streak, first mastered topic, etc.)
- [x] Display badges on user profile

### Lesson Content — Chapter Rollout
Content lives in frontend data files (`src/data/lessons/<chapter>/`), one file per lesson.
Each lesson has structured content blocks (text, headings, formulas, callouts) + 3 exam-style
problems with worked solutions, handbook references, and common traps. Drafted using the
`fe-lesson-content` skill, reviewed lesson by lesson before insertion.

See `research/civil/fe-civil-exam-topics.md` for the full lesson breakdown per chapter.

- [x] Ch 1: Mathematics — 13 lessons (Analytic Geometry, Single-Variable Calculus, Vector Operations)
- [ ] Ch 2: Probability & Statistics
- [ ] Ch 3: Ethics & Professional Practice
- [ ] Ch 4: Engineering Economics
- [ ] Ch 5: Statics
- [ ] Ch 6: Dynamics
- [ ] Ch 7: Mechanics of Materials
- [ ] Ch 8: Materials
- [ ] Ch 9: Fluid Mechanics
- [ ] Ch 10: Surveying
- [ ] Ch 11: Water Resources & Environmental
- [ ] Ch 12: Structural Engineering
- [ ] Ch 13: Geotechnical Engineering
- [ ] Ch 14: Transportation Engineering
- [ ] Ch 15: Construction Engineering

### Content Extras
- [ ] Add real YouTube video embeds per lesson
- [ ] Expand problem bank: add 3-5 extra problems per lesson for review variety (spaced repetition currently re-serves the same 3 — a larger bank prevents memorizing answers)

---

## Phase 3: "Make it smart"

### Adaptive Learning
- [ ] Track difficulty rating per problem (user feedback: easy/medium/hard)
- [ ] Serve problems at appropriate difficulty based on user's mastery level
- [ ] Implement full spaced repetition algorithm (SM-2 or FSRS)
- [ ] Personalize review intervals based on individual user's memory patterns

### Exam Simulation
- [ ] Timed practice mode: problems with countdown timer (2-3 min per problem)
- [ ] Topic quiz mode: 10-15 problems under exam-like conditions, scored
- [ ] Study plan generator: recommend daily schedule based on exam date and current mastery

### Infrastructure
- [x] Add backend unit tests (auth, sessions, streak, mastery, badges — vitest + supertest)
- [x] Add frontend component tests (MathText, shuffleChoices — vitest + testing-library)
- [ ] Set up GitHub Actions CI/CD pipeline
- [ ] Separate dev and production environments (different databases)

---

## Phase 4: "Make it a business"

### Full Product
- [ ] Full FE exam simulator: all topics, timed, scored, with results breakdown
- [ ] Landing page: marketing page with value proposition (no login required)
- [ ] User profile page: view/edit email, see stats, manage account
- [ ] Password reset flow
- [ ] Email verification on registration

### Monetization
- [ ] Payment integration (Stripe): free tier + paid subscription
- [ ] Define free vs. paid feature split
- [ ] Admin panel: manage content, view user metrics, add/edit problems

### Growth
- [ ] SEO: meta tags, Open Graph, sitemap, robots.txt
- [ ] Analytics: track signups, sessions, retention (Google Analytics or similar)
- [ ] Privacy policy and terms of service
- [ ] Mobile-optimized PWA (offline support, home screen install)

---

## Progress Tracking

| Phase | Total Items | Completed | % |
|-------|------------|-----------|---|
| Phase 1 | 27 | 27 | 100% |
| Phase 2 | 30 | 14 | 47% |
| Phase 3 | 10 | 2 | 20% |
| Phase 4 | 12 | 0 | 0% |
| **Total** | **79** | **43** | **54%** |

*Last updated: 2026-03-31*
