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
- [ ] Calculate mastery level (0–5) per topic based on session history
- [ ] Display mastery bars on dashboard topic cards
- [ ] Implement mastery decay: reduce level if topic not reviewed in X days
- [ ] Visual indicator when a topic is "decaying" (needs review)

### Spaced Repetition
- [ ] Implement basic spaced repetition: track last-seen date and performance per problem
- [ ] Create "Daily Review" mode: mixed problems from past topics, weighted by need
- [ ] API endpoint: `GET /api/review` — returns a personalized set of review problems
- [ ] Add Daily Review button on dashboard

### Social & Motivation
- [ ] Weekly leaderboard: rank users by XP earned that week (30-person cohorts)
- [ ] Display leaderboard on dashboard
- [ ] Streak freeze: allow 1 missed day per week without breaking streak
- [ ] Achievement badges for milestones (first session, 7-day streak, first mastered topic, etc.)
- [ ] Display badges on user profile

### Content Expansion
- [ ] Seed database with problems for all FE Civil topics (not just Analytic Geometry)
- [ ] Add real YouTube video embeds per topic
- [ ] Add study material summaries per topic (key concepts, formulas) in database

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
- [ ] Add backend unit tests (auth, progress, sessions endpoints)
- [ ] Add frontend component tests (problem display, session flow, dashboard)
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
| Phase 2 | 14 | 0 | 0% |
| Phase 3 | 10 | 0 | 0% |
| Phase 4 | 12 | 0 | 0% |
| **Total** | **63** | **27** | **43%** |

*Last updated: 2026-03-29*
