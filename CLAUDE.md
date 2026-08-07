# FE for Raccoons — Project Instructions

## What This Project Is
FE for Raccoons is a gamified study platform for the Fundamentals of Engineering (FE) Civil exam. It's a React + Vite + Tailwind app. The name comes from a YouTube video called "Raccoon Engineering" — the raccoon theme gives the brand personality but should never be cartoonish or childish.

## Tech Stack
- **Framework:** React 19 + React Router 7
- **Build:** Vite 7
- **Styling:** Tailwind CSS 4 + custom CSS variables
- **Math rendering:** KaTeX
- **Icons:** Phosphor Icons (use `@phosphor-icons/react`, Bold weight for nav/CTAs, Regular for content)
- **Fonts:** DM Sans (headings), Inter (body text), JetBrains Mono (formulas, data, code)

## Brand System — ALWAYS FOLLOW THESE

### Color Tokens (use CSS custom properties)
```css
--cream:        #FFF9F0;   /* Page background, base canvas */
--cream-dark:   #F5EDE0;   /* Hover states, subtle sections */
--charcoal:     #2C2C2C;   /* Primary text, nav, footer */
--ember:        #E8683A;   /* Primary CTA, links, focus rings */
--ember-bg:     #FEF0EA;   /* Tags, badges in ember context */
--sunbeam:      #F5B731;   /* XP, streaks, highlights, warnings */
--sunbeam-bg:   #FEF7E0;   /* Tags, badges in sunbeam context */
--forest:       #2D7A5F;   /* Success, mastery, correct answers */
--forest-bg:    #E8F5EE;   /* Tags, badges in forest context */
--error:        #D64045;   /* Error states */
--info:         #3B82B8;   /* Informational states */
```

### Typography Rules
- **Headings:** `font-family: 'DM Sans'` — weight 600-700, tight letter-spacing (-0.02em to -0.04em)
- **Body:** `font-family: 'Inter'` — weight 400-500, line-height 1.6
- **Code/Data/Formulas:** `font-family: 'JetBrains Mono'`
- **Overlines/Badges:** DM Sans 600, 0.7rem, uppercase, letter-spacing 0.08em

### Design Tokens
- **Border radius:** 6px (small/chips), 10px (buttons/inputs), 16px (cards), 24px (hero/banners)
- **Shadows:** Use subtle, warm shadows: `0 1px 3px rgba(44,44,44,0.04), 0 4px 16px rgba(44,44,44,0.06)` for cards
- **Max content width:** 1100px
- **Spacing scale:** 4px, 8px, 16px, 24px, 32px, 48px, 64px, 96px

### Layout Approach (Brilliant.org-style)
- Cream (#FFF9F0) is the main page background — let it breathe with generous whitespace
- Charcoal (#2C2C2C) for nav bar and footer to anchor the page structure
- Ember accent border (3px) on bottom of nav bar
- White (#FFFFFF) background for cards, elevated above the cream
- Feature cards use a colored 4px top accent bar (Ember, Forest, or Sunbeam)
- Topic cards use a 4px left border in Forest

### Absolute Don'ts
- NEVER use emojis — Phosphor icons replace every use case
- NEVER use purple gradients or neon colors
- NEVER use sharp corners (minimum 6px radius)
- NEVER center-align body text — left-align for readability
- NEVER use system fonts — always load DM Sans + Inter + JetBrains Mono
- NEVER make the raccoon theme cartoonish or childish
- NEVER use more than 2 accent colors in a single section

### Brand Reference
The full interactive brand deck is at: `fe4raccoons-brand-deck.html` in the project root.
For the custom design skill with more detail, see: `.claude/skills/fe4raccoons-brand/SKILL.md`

## Deployment & Ops — READ BEFORE DEPLOYING
Full runbook: `docs/DEPLOY.md`. Critical points:
- **Deploy with `-s startup`, NOT `-s fe4raccoons`.** The live pm2 process is
  named `startup` (runs from `services/startup/`). `-s fe4raccoons` deploys to a
  dead directory and the pm2 restart fails silently.
  - Backend changed → `./deployService.sh -k secrets/jerson-cs260-key.pem -h fe4raccoons.com -s startup`
  - Frontend only → `./deployReact.sh -k secrets/jerson-cs260-key.pem -h fe4raccoons.com -s startup`
- **Verifying a deploy: status codes lie.** The SPA catch-all returns `index.html`
  (HTTP 200) for any missing asset path. Verify by `content_type` or by grepping
  the served bundle for a changed string — never by status code alone.
- **A new public page needs TWO route lists, not one.** Add it to `ROUTES` in
  `scripts/prerender.mjs` *and* to `PRERENDERED_ROUTE_PATTERN` in
  `service/prerenderedRoutes.js`. Miss the second and the page still returns
  HTTP 200 and looks perfect in a browser, while every crawler gets the generic
  landing title and none of the page's JSON-LD. `/exam-simulation` shipped that
  way on 2026-08-07. `service/prerenderedRoutes.test.js` now fails on the drift.
- Node on the box needs a login shell over SSH: `ssh … 'bash -ilc "pm2 …"'`.
- **Never package `.env`.** `deployService.sh` excludes it and aborts if one
  reaches `build/`. The local `service/.env` holds Stripe TEST keys; shipping it
  would silently stop all real card charges. Production secrets live only on the
  box — change them with `./scripts/set-prod-secrets.sh` (hidden prompt, refuses
  a non-`sk_live_` key).
- **A deploy will abort if an exam simulation is in progress.** That is correct;
  do not force with `-f` unless you have checked. See `docs/DEPLOY.md`.
- After a backend deploy, confirm the payment mode tripwire:
  `[stripe] mode: LIVE` in the pm2 logs.

## Paid Exam Simulation — READ BEFORE TOUCHING
`docs/EXAM-SIMULATION.md`. It was badly broken for its first customers and the
fixes rest on non-obvious invariants. The two most important:
- **Submit can only ADD answers, never clear them.** `mergeAutosave` (null = the
  user cleared it) and `mergeSubmission` (additive only) are separate on purpose.
  Collapsing them reintroduces a bug that scored paying customers ~0%.
- **Answers are keyed by `questionId`, never array position**, and resume must
  render the SERVER's stored questions.
Known and unfixed: the client picks the 110 questions and POSTs them **including
`correctAnswerId`**, so any buyer can forge a perfect score.

## Analytics & attribution
`docs/ANALYTICS-ATTRIBUTION.md`. Plausible measures pre-signup; `user.acquisition`
measures which channel produced an account. `user.acquisition` has THREE signals
(referrer, utm, survey) — reading only the survey once produced a 10% attribution
figure and named the wrong lead channel. Real coverage is ~50% and **organic
search leads, not Reddit**. The "how did you find us" question is asked ONCE at
registration; see the doc before moving it (the verification-screen placement was
tried and silently lost answers).

## Growth plan
A hired analyst's 90-day plan lives at
`~/developer/fe4raccoons-marketing/analysis/90-day-growth-plan.xlsx`. Follow it
as written; log each day in column L. Weekly review on Mondays, using the
Plausible weekly email.

## Repo scope — code only
Marketing assets and company/legal records were moved OUT of this repo on
2026-08-04 and now live beside it:
- `~/developer/fe4raccoons-marketing` (reels, carousels, posting pipeline, the
  growth plan and baseline analyses)
- `~/developer/fe4raccoons-legal` (LLC and DBA records)

Keep this repo to software. `src/legal/` is unrelated — those are the Terms and
Privacy React pages and they stay.

## Architecture Decision Records
`docs/adr/`. Write one when a decision has a non-obvious rationale, beat a
defensible alternative, or came from evidence that will not be visible later.
Never edit an accepted ADR to say something different; supersede it with a new
one. See `docs/adr/README.md`.

## Email (Resend)
Config + troubleshooting: `docs/EMAIL-SETUP.md`. **Working** — sends from
`noreply@fe4raccoons.com` (domain verified in Resend; DNS at GoDaddy). Branded
templates live in `service/email.js`. If delivery breaks, check
`GET /api/admin/email-status` (`usingTestSender` must be `false`) and
`POST /api/admin/email-test`; never let `RESEND_FROM_EMAIL` fall back to the
`onboarding@resend.dev` test sender (it only reaches the Resend account owner).
