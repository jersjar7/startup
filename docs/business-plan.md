# FE for Raccoons — Business Plan (Draft)

**Created:** 2026-06-01
**Status:** Draft. Data-backed sections are filled from research + the live product. Items marked **[DECIDE]** are strategic calls for the owner — they're placeholders, not recommendations to adopt as-is.

---

## 1. Executive Summary

FE for Raccoons is a gamified, mobile-friendly study platform for the **FE Civil** exam. It makes nearly everything free — 15 chapters of lessons, 1,126 practice problems, spaced-repetition review, a diagnostic, and step-by-step solutions — and charges a single **$14.99 one-time** fee for a full 110-question timed exam simulation. The wedge is price and experience: the cheapest credible competitor (PrepFE) is ~$110 for six months, and full courses run $1,000–$1,800. The platform is live at fe4raccoons.com with a verified payment funnel and conversion analytics in place.

**The opportunity:** ~26,500 people sit for the FE Civil exam each year (and ~58,000 across all FE disciplines), a market growing ~50% over the last decade. Most are price-sensitive students who don't want a $1,000 course. A free-to-use product with a $15 upsell can capture meaningful share of that top of funnel.

---

## 2. Problem

- The FE Civil exam (~68% pass rate) is a required gate to becoming an EIT, then a licensed PE.
- Existing prep is **expensive** ($110–$1,800) and often **course-heavy** (video lectures, rigid schedules) — a poor fit for students who learn by doing problems in short sessions on their phone.
- Free resources (PDFs, scattered YouTube) are disorganized and have no feedback loop, no progress tracking, and no spaced repetition.

## 3. Solution / Product (current, live)

A Brilliant.org-style learning platform with a Duolingo-style engagement loop, built specifically for FE Civil:

- **Content:** 15 chapters, 135 lessons, 51 subtopics, **1,126 practice problems** across non-overlapping pools (405 lesson, 473 exam-bank, 248 chapter-practice), all adversarially verified for correct answers and distractor quality. ~80 custom SVG diagrams.
- **Learning engine:** mastery tracking with decay, **spaced repetition (SM-2)**, a diagnostic that seeds a personalized starting point, and dashboard intelligence (exam-readiness %, focus areas, "study next" recommendations).
- **Engagement:** XP, streaks, badges, weekly leaderboard — tuned for an adult audience (no hearts/lives or childish elements).
- **Monetization:** a paid **110-question timed exam simulation** ($14.99 one-time) matching the NCEES topic distribution, with per-chapter score breakdown.
- **Quality:** 123 automated tests, verified payment funnel, owner-facing conversion analytics. React + Vite, deployed on AWS (EC2 + Caddy + PM2), MongoDB Atlas, Stripe.

**Differentiators:** gamification + spaced repetition + custom diagrams + mobile-first UX, at **1/30th–1/120th** of competitor pricing.

## 4. Market

Source: `research/market-size/fe-exam-market-size.md` (NCEES Squared annual reports).

| Segment | Size | Note |
|---|---|---|
| **TAM** — all FE examinees / year | ~58,000 (2024-25), +~50% over decade | Content is Civil-only today; other disciplines are an expansion path |
| **SAM** — FE Civil examinees / year | **~26,500** (~46% of all FE) | The immediate market |
| **SOM** — realistic early capture | **[DECIDE]** (e.g., 5–20% as free signups) | Drives the model below |

- FE Civil is the **largest** FE discipline and growing (~+7% YoY).
- Pass rate ~68% → strong demand for prep; repeat customers exist (retakes).
- NCEES administers globally → international upside.

## 5. Competition (2026 pricing)

| Provider | Price (FE Civil) | Format | Gamified | Spaced rep | Mobile |
|---|---|---|---|---|---|
| **FE for Raccoons** | **Free + $14.99** one-time | Problems + lessons + sim | ✅ | ✅ | ✅ |
| PrepFE | ~$110 / 6 mo (~$10/mo) | Problems + flashcards + analytics | ❌ | ❌ | ✅ |
| School of PE | $290/mo self-study; $990 live; $1,199–1,499 class | Video courses | ❌ | ❌ | partial |
| PPI2Pass (Kaplan) | ~$1,800 packages | Comprehensive course | ❌ | ❌ | partial |

**Positioning:** the only **free-to-use, gamified, spaced-repetition** FE Civil tool. PrepFE is the closest competitor (practice-focused, affordable) but is ~7× the price, not free to start, and not gamified. We win the price-sensitive, mobile-first, self-paced student.

**Competitive risk:** low switching cost; a well-funded incumbent could add a free tier. Moats to build: content depth + brand/community (Reddit), not technology alone.

## 6. Business Model & Pricing

**Current model (implemented):** Freemium. Everything free except the $14.99 one-time exam simulation. No subscription.

Open pricing decisions — **[DECIDE]**:
- Keep one-time $14.99, or test a **low subscription** (e.g., $4–6/mo) for the sim + future premium features? One-time is simpler and matches the "accessible" brand; subscription grows LTV if there's recurring value (new sims, fresh question sets, PE-exam expansion).
- Add a **pass-guarantee** (refund/extension if you don't pass), matching PrepFE/School of PE? Cheap to offer at this price, strong conversion lever.
- Tiered upsells later (e.g., a "PE Civil" product, an "all-disciplines" expansion).

## 7. Go-to-Market

The product is the funnel; distribution is the job. Channels (low/no cost, fit the audience):
- **Reddit** — r/FE_Exam, r/engineeringstudents (an in-app referral already nudges sharing for a discount). Authentic, founder-led posts.
- **SEO** — already has meta/OG/sitemap; target "FE Civil practice problems", "free FE Civil prep", long-tail topic queries. The 1,126-problem library is strong SEO surface.
- **LinkedIn** — founder (civil engineer) audience; the referral discount is DM-gated via LinkedIn today.
- **University outreach** — ASCE student chapters, professors who advise EIT candidates.
- **App store** (later) — PrepFE has an iOS app; a PWA/app could capture mobile search.

**[DECIDE]:** which 1–2 channels to commit to first, and any paid-acquisition budget (the analytics now make CAC measurable).

## 8. Unit Economics (template — fill from live analytics)

The `/admin` metrics page now tracks the funnel. Once there's traffic, fill:
- Free→paid conversion rate (target: 2–5% is typical freemium; **measure** via `signup → purchase`).
- Revenue per paying user: **$14.99** (gross), minus Stripe fee (~$0.74 → ~**$14.25 net**).
- Infra cost / user: low (single EC2 + Atlas free/shared tier) — **[DECIDE]** confirm current monthly infra spend.
- CAC: ~$0 organic; **[DECIDE]** if paid.
- Contribution margin per paying user ≈ $14.25 − allocated infra (likely > $13). Healthy at any organic scale.

## 9. Financial Projections (illustrative — assumptions flagged)

Base: 26,500 FE Civil examinees/year. **All percentages are assumptions to validate with live analytics.**

| Scenario | Signups (% of market) | Free→paid conv. | Paying users/yr | Net revenue/yr (@ $14.25) |
|---|---|---|---|---|
| Conservative | 5% (~1,325) | 3% | ~40 | ~$570 |
| Moderate | 15% (~3,975) | 4% | ~159 | ~$2,265 |
| Optimistic | 30% (~7,950) | 5% | ~398 | ~$5,670 |

**Reading this honestly:** at $14.99 one-time, revenue is modest unless either (a) conversion/reach is high, (b) price/LTV rises (subscription, PE expansion, higher sim price), or (c) the market broadens to all FE disciplines (~58k). The current model is better understood as **mission-first / low-margin** — great for users and brand, limited as a standalone business. The **[DECIDE]** levers in §6 are where the business case is actually made.

## 10. Metrics to Watch (now instrumented)

From `/admin`: signups, diagnostic completion %, **checkout→purchase**, total revenue, and stage conversions. Add later: retention/streak cohorts, diagnostic→study activation, exam-sim score → "felt ready" survey.

## 11. Risks & Mitigations

- **Low revenue ceiling at $14.99 one-time** → revisit pricing/LTV (§6); treat sim as one of several future paid features.
- **Single-discipline (Civil only)** → expansion to other FE disciplines / PE Civil reuses the engine.
- **Content trust** (a wrong answer erodes credibility) → already mitigated by adversarial verification + tests; keep that bar.
- **Incumbent free tier** → defend with community + content depth + UX, not tech alone.
- **Solo founder bandwidth** → the platform is built and self-serve; focus time on distribution + content, not rebuilding.

## 12. Decisions Needed From the Owner

1. **Pricing strategy** — keep $14.99 one-time, or test subscription / pass-guarantee / higher sim price? (§6)
2. **Growth target** — what signup share of the ~26,500 FE Civil market to aim for in year 1? (§4 SOM)
3. **Primary channel(s)** — commit to 1–2 (Reddit, SEO, LinkedIn, university) and any paid budget. (§7)
4. **Scope** — stay Civil-only to start, or plan multi-discipline expansion? (§4, §11)
5. **Infra cost** — confirm current monthly spend to finalize unit economics. (§8)

---

## Sources
- Internal: `research/market-size/fe-exam-market-size.md` (NCEES Squared 2024/2025 annual reports), `docs/audits/2026-04-07-content-readiness.md`.
- Competitor pricing (2026): [PrepFE pricing](https://www.prepfe.com/pricing), [School of PE FE Civil](https://schoolofpe.com/collections/fe-civil-exam-prep), [PPI2Pass FE Civil](https://ppi2pass.com/fe-exam/civil), [Best FE Civil courses — Achievable](https://achievable.me/exams/fe-civil/best-courses/).
