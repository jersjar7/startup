# FE for Raccoons — Platform Maturity Rubric

**Platform category:** EdTech SaaS — Adaptive Learning / Exam Prep

**Total score:** 1000 points across 15 categories

**How to use:** Run periodic audits. Score each item 0 (absent), partial, or full points. Track the total over time to measure platform maturity. Items are ordered by priority within each category.

---

## 1. Core Learning Experience (150 pts)

The product's primary value. If this is weak, nothing else matters.

| Item | Pts | Description |
|------|-----|-------------|
| Bite-sized lessons with immediate feedback | 20 | One problem at a time, instant correct/incorrect, explanation shown |
| Spaced repetition system | 20 | Overdue problems resurface on schedule, intervals adapt to performance |
| Adaptive difficulty / mastery tracking | 20 | Per-topic mastery levels that decay over time, gating progression |
| Practice problem quality | 20 | Problems match FE exam format, have clear explanations, cover all topics |
| Diagnostic assessment | 15 | Timed full-length diagnostic that seeds initial mastery across chapters |
| Study resource panels | 15 | Formulas, key concepts, common traps, eli5 explanations per lesson |
| Progress persistence across devices | 10 | User progress stored server-side, not in localStorage |
| Content coverage completeness | 15 | All 15 FE Civil exam chapters covered with sufficient lesson depth |
| Review queue UX | 15 | Dedicated review mode for spaced repetition items, clear queue status |

---

## 2. Authentication & User Management (80 pts)

Users need to trust the platform with their account and data.

| Item | Pts | Description |
|------|-----|-------------|
| Secure registration and login | 10 | Bcrypt hashing, password strength validation, rate-limited auth |
| Session management | 10 | HttpOnly + Secure + SameSite cookies, server-side token |
| Session expiry | 10 | Tokens expire after reasonable period (e.g., 30 days), auto-logout |
| Email verification | 10 | Verify email ownership on registration before granting full access |
| Password reset flow | 15 | Forgot password via email link with time-limited token |
| Profile management | 10 | Change email, change password, view account info |
| Account deletion | 10 | User can delete their account and all associated data (GDPR/CCPA) |
| OAuth / social login | 5 | Optional: Google sign-in reduces friction |

---

## 3. Security (80 pts)

Non-negotiable for a platform that stores user credentials and progress.

| Item | Pts | Description |
|------|-----|-------------|
| Helmet security headers | 10 | CSP, X-Frame-Options, HSTS, X-Content-Type-Options |
| Password hashing (bcrypt/argon2) | 10 | Salted hashes, never storing plaintext |
| Rate limiting on auth endpoints | 10 | Brute-force protection on login/register |
| Rate limiting on API endpoints | 5 | Global rate limit that skips static assets |
| HTTPS everywhere | 10 | TLS via Caddy/Let's Encrypt, HSTS header |
| Input validation on all routes | 10 | Validate types, lengths, formats at every API boundary |
| Database indexes on auth lookups | 5 | Index on token field to avoid collection scans on every request |
| WebSocket authentication | 5 | Verify user identity on WS upgrade, reject anonymous connections |
| Dependency auditing | 5 | Regular npm audit, Dependabot or equivalent for vulnerability alerts |
| CSRF protection | 5 | SameSite cookies + CSRF token for state-changing requests |
| Secrets management | 5 | .env files, no hardcoded credentials, secrets in .gitignore |

---

## 4. Performance & Caching (80 pts)

Slow study tools lose students. Every second counts.

| Item | Pts | Description |
|------|-----|-------------|
| Gzip/Brotli compression | 10 | All text responses compressed |
| Code splitting / lazy routes | 15 | Route-level splitting so initial load is fast |
| Static asset cache headers | 10 | Hashed filenames with max-age=1y, immutable; index.html no-cache |
| Vendor chunk separation | 5 | React, KaTeX, etc. in separate cacheable chunks |
| Database query indexes | 10 | Indexes on all frequently queried fields (email, token, topicId, nextReview) |
| Image optimization | 5 | WebP/AVIF format, responsive sizes, lazy loading |
| Critical CSS / above-the-fold | 5 | Landing page renders without waiting for full CSS bundle |
| API response times < 200ms | 10 | All API endpoints respond within 200ms under normal load |
| Lesson data lazy loading | 10 | Large lesson/problem data loaded on demand, not in main bundle |

---

## 5. Error Handling & Resilience (60 pts)

The app should never show a blank screen or leave users confused.

| Item | Pts | Description |
|------|-----|-------------|
| React Error Boundary | 15 | Catches render errors, shows recovery UI instead of blank screen |
| Meaningful 404 page | 5 | Styled 404 with navigation back to dashboard |
| API error feedback in UI | 10 | User-facing error messages when API calls fail (not silent failures) |
| Graceful degradation on network loss | 10 | Offline indicator, queued actions, or clear "you're offline" message |
| Backend structured error logging | 10 | Log levels (info/warn/error), structured JSON logs for debugging |
| Health check endpoint | 5 | GET /api/health returns DB status for monitoring |
| Auto-retry on transient failures | 5 | Retry failed API calls once before showing error |

---

## 6. Accessibility — WCAG 2.1 AA (70 pts)

Legal requirement in many jurisdictions. Ethical requirement everywhere.

| Item | Pts | Description |
|------|-----|-------------|
| Semantic HTML landmarks | 10 | Proper use of main, nav, header, footer, section, article |
| Keyboard navigation | 10 | All interactive elements reachable and operable via keyboard |
| Skip-to-content link | 5 | Hidden link that becomes visible on focus, jumps past nav |
| ARIA labels on interactive elements | 10 | Buttons, links, form inputs, custom widgets have accessible names |
| Color contrast WCAG AA (4.5:1) | 10 | All text/background combinations pass contrast ratio |
| Focus management on route changes | 5 | Focus moves to main content or page heading on navigation |
| Screen reader testing | 10 | Verified with VoiceOver/NVDA, no dead ends or confusing announcements |
| Reduced motion support | 5 | Respects prefers-reduced-motion media query |
| Form error announcements | 5 | Validation errors announced to screen readers via aria-live |

---

## 7. Mobile & Responsive Design (60 pts)

Many students study on phones during commutes and breaks.

| Item | Pts | Description |
|------|-----|-------------|
| Responsive layout (phone/tablet/desktop) | 20 | All pages usable at 320px–1440px+ without horizontal scroll |
| Touch targets >= 44px | 10 | Buttons and interactive elements meet minimum touch size |
| Mobile-optimized forms | 10 | Appropriate input types, autocomplete, no tiny inputs |
| Responsive math rendering | 10 | KaTeX formulas don't overflow on small screens |
| Tested on real devices | 10 | Verified on iOS Safari, Android Chrome, not just desktop resize |

---

## 8. Testing & Quality Assurance (70 pts)

Confidence to ship without breaking things.

| Item | Pts | Description |
|------|-----|-------------|
| Unit tests for business logic | 15 | Mastery, streaks, badges, spaced repetition calculations |
| API route integration tests | 15 | Every endpoint tested with supertest (auth, topics, sessions, etc.) |
| Frontend component tests | 10 | Key components rendered and asserted with Testing Library |
| End-to-end tests | 15 | Critical user flows (register, login, study, submit answers) via Playwright |
| Test coverage tracking | 5 | Coverage reported, goal of 70%+ on business logic |
| Pre-deploy test gate | 10 | Tests must pass before deploy script runs |

---

## 9. SEO & Discoverability (40 pts)

Students need to find the platform through search engines.

| Item | Pts | Description |
|------|-----|-------------|
| Meta description tag | 5 | Unique, compelling description for search results |
| Open Graph tags | 5 | og:title, og:description, og:image for social sharing |
| Dynamic page titles | 5 | Each route sets a unique document title |
| robots.txt | 5 | Allows crawling of public pages, blocks authenticated routes |
| sitemap.xml | 5 | Lists public pages for search engine indexing |
| Canonical URLs | 5 | Prevents duplicate content issues |
| Structured data (JSON-LD) | 5 | Course/LearningResource schema for rich search results |
| Landing page performance (LCP < 2.5s) | 5 | Core Web Vitals passing for SEO ranking signal |

---

## 10. Real-Time Features (40 pts)

Social presence and live activity keep students engaged.

| Item | Pts | Description |
|------|-----|-------------|
| Authenticated WebSocket connections | 10 | Verify user identity on upgrade, reject anonymous |
| Auto-reconnect on disconnect | 10 | Client reconnects automatically after network interruption |
| Live activity feed | 10 | Shows who's studying what in real time |
| Server-side message validation | 5 | Validate message shape and content before broadcasting |
| Presence indicator | 5 | Show how many students are online now |

---

## 11. Gamification & Engagement (60 pts)

What makes the platform sticky. The reason students come back.

| Item | Pts | Description |
|------|-----|-------------|
| XP system with visible progression | 10 | Earn XP per session, displayed on dashboard |
| Streak tracking with freeze protection | 10 | Daily streaks that forgive occasional missed days |
| Achievement badges | 10 | Milestone badges (first session, streak milestones, mastery levels) |
| Leaderboard | 10 | Weekly leaderboard with privacy-safe display |
| Mastery visualization per chapter | 10 | Visual indicator of mastery level and decay for each topic |
| Study reminders / notifications | 10 | Email or push notifications to maintain streaks and review schedules |

---

## 12. Infrastructure & DevOps (60 pts)

Reliability, deployability, and operational confidence.

| Item | Pts | Description |
|------|-----|-------------|
| Automated deployment script | 10 | One-command deploy (build + copy + restart) |
| Zero-downtime deploys | 10 | PM2 cluster mode or rolling restart so users aren't interrupted |
| Database backups | 10 | Automated daily backups with tested restore procedure |
| Uptime monitoring | 10 | External ping (UptimeRobot, Betterstack) with alert on downtime |
| SSL certificate auto-renewal | 5 | Caddy handles this automatically |
| CI pipeline (build + test on push) | 10 | GitHub Actions or equivalent runs tests on every push |
| Environment separation | 5 | Separate dev/staging/prod environments |

---

## 13. Analytics & Insights (40 pts)

Understand how students use the platform to improve it.

| Item | Pts | Description |
|------|-----|-------------|
| Privacy-respecting analytics | 10 | Plausible, Fathom, or similar (no Google Analytics) |
| Problem difficulty analysis | 10 | Track which problems have low accuracy, flag for review |
| User retention metrics | 10 | DAU/WAU/MAU, session frequency, drop-off points |
| Admin dashboard | 10 | Internal view of user stats, content performance, system health |

---

## 14. Documentation (30 pts)

For the developer (you), future contributors, and API consumers.

| Item | Pts | Description |
|------|-----|-------------|
| README with setup instructions | 10 | Clone, install, configure .env, run dev, run tests |
| API documentation | 10 | Every endpoint documented with request/response examples |
| Architecture decision records | 5 | Key decisions documented (why bcrypt over argon2, why no JWT, etc.) |
| Contributing guide | 5 | Code style, branch naming, PR process |

---

## 15. Monetization Readiness (80 pts)

The path from free tool to sustainable business.

| Item | Pts | Description |
|------|-----|-------------|
| Payment integration | 20 | Stripe Checkout or equivalent, subscription and one-time options |
| Free tier / paywall boundary | 15 | Clear definition of what's free vs. paid (e.g., 2 chapters free) |
| Account tiers (Free / Pro) | 10 | Backend enforces access control based on subscription status |
| Billing management | 10 | Users can view invoices, cancel, upgrade/downgrade |
| Terms of service and privacy policy | 10 | Legal pages accessible from footer |
| Landing page conversion optimization | 10 | Clear value prop, social proof, CTA above the fold |
| Email onboarding sequence | 5 | Welcome email, day-3 nudge, streak reminder |

---

## Score Summary Template

Use this table when running audits:

| # | Category | Max | Score | Notes |
|---|----------|-----|-------|-------|
| 1 | Core Learning Experience | 150 | | |
| 2 | Authentication & User Management | 80 | | |
| 3 | Security | 80 | | |
| 4 | Performance & Caching | 80 | | |
| 5 | Error Handling & Resilience | 60 | | |
| 6 | Accessibility — WCAG 2.1 AA | 70 | | |
| 7 | Mobile & Responsive Design | 60 | | |
| 8 | Testing & Quality Assurance | 70 | | |
| 9 | SEO & Discoverability | 40 | | |
| 10 | Real-Time Features | 40 | | |
| 11 | Gamification & Engagement | 60 | | |
| 12 | Infrastructure & DevOps | 60 | | |
| 13 | Analytics & Insights | 40 | | |
| 14 | Documentation | 30 | | |
| 15 | Monetization Readiness | 80 | | |
| | **TOTAL** | **1000** | | |

---

## Maturity Levels

| Score | Level | Meaning |
|-------|-------|---------|
| 0–200 | Prototype | Core feature works but not production-ready |
| 201–400 | MVP | Usable by early adopters, major gaps remain |
| 401–600 | Beta | Solid product, ready for broader testing |
| 601–800 | Production | Reliable platform, ready for paying users |
| 801–1000 | Mature | Polished, scalable, competitive EdTech product |
