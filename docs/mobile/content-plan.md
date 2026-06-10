# Mobile content plan — what each of our 1,126 problems becomes on the phone

_Generated overnight 2026-06-09. Source of truth: `problem-classification.json`
(one record per problem, integrity-checked against `getProblemPoolSize()`=1126).
Method: mechanical first pass (`classify-problems.mjs`) → per-chapter LLM
inspection of every problem's real statement/steps/traps/eli5 against
`classification-rubric.md` → aggregation + integrity check (`aggregate-tiers.mjs`)
→ human spot-verification of the boundary in both directions. Grounded in
`../mobile-app-north-star.md`._

## Headline

Every one of the 1,126 problems has a **phone-native surface**. The phone↔paper
split is not "half the bank is unusable on a phone" — it's that **only ~29% need
paper to fully *solve*; 100% can be *practiced* on the phone** as retrieval of
the concept, the formula, or the approach.

| Tier | Count | Share | What it is | Phone role |
|---|--:|--:|---|---|
| `concept` | **327** | 29% | Fact / relationship / judgment, no arithmetic | Full practice on phone |
| `phone-calc` | **468** | 42% | One formula / light calc (calculator-on-screen OK) | Full practice on phone |
| `paper` | **331** | 29% | Multi-line / spatial / unit-heavy solve | Setup on phone, **solve on paper** |
| **phone-native** | **795** | **71%** | concept + phone-calc | — |

**This reversed my earlier estimate** (the mechanical pass guessed 56% paper).
The step-count was over-counting: most "3–4 step" solutions are *padded with
teaching steps* (expanding a Pythagorean triple, showing F_y when only F_x was
asked). The real cognitive work is often one formula. Verified by sampling the
most aggressive reclassifications — they hold. Conversely, 9 "2-step" deflection
problems (PL³/3EI with GPa→Pa unit conversion) were correctly pushed *to* paper.
Judgment beat the counter in both directions.

### What "phone-calc" means (the honesty line)

`phone-calc` is **not** "fake the solve by tapping a calculator." A phone-calc
problem's *graded, spaced* surface is retrieving **the approach** — "which
formula? which handbook page? what's the first move?" The arithmetic is
secondary (optional on-screen scratchpad). The dishonesty the North Star forbids
is pretending a multi-line FBD / simultaneous-equation / unit-tracking solve can
be tapped through — those are `paper`, surfaced honestly with "grab paper." So
the real split for *graded practice* is: **all 1,126 retrieve the method on the
phone; 331 additionally require paper to finish the number.**

## The card yield (the big asset)

Mining each problem's own `traps[]` / `handbookFormula` / `eli5` produced
**2,388 grounded retrieval-card seeds** (avg 2.1/problem) — drafts, human-verify
before shipping:

| Card kind | Count | Source |
|---|--:|---|
| `tap-the-trap` | 1,257 | the pre-written `traps[]` arrays — spot-the-misconception |
| `formula-first` | 585 | handbook formula/page recall |
| `recall-reveal` | 372 | eli5 core idea / relationship |
| `setup-not-solve` | 174 | "what's the governing equation?" for paper problems |

The `traps[]` arrays are the hidden goldmine: every problem already ships with
2–3 hand-written, exam-specific misconceptions. That's a 1,257-card
spot-the-error library we get essentially for free, and it's the *most*
generative (anti-recognition) mode we have.

## Interaction-mode strategy (primary mode per problem)

`formula-first` 369 · `setup-not-solve` 325 · `recall-reveal` 249 ·
`tap-the-trap` 176 · `mcq` **7**.

**mcq nearly vanished** — only 7 of 1,126 work best as plain recognition (a few
ethics/standards-lookup items). That's the North Star's rule #1 (generation over
recognition) landing in the data: we are *not* shipping the website's tap-an-option
format to the phone.

## Per-chapter character (build-sequencing signal)

| Chapter | Total | concept | phone-calc | paper | cards | Character |
|---|--:|--:|--:|--:|--:|---|
| mathematics | 135 | 42 | 48 | 45 | 271 | Calculus = paper; spreadsheet/programming = concept cluster; trig splits by complexity |
| statistics | 54 | 9 | 29 | 16 | 151 | Most phone-calc; interpretation items = best concept/trap cards; full-dataset sums = paper |
| ethics | 59 | 57 | 2 | 0 | 152 | Almost all concept; tap-the-trap dominates; patent 20-yr + experience schedule = top facts |
| economics | 50 | 10 | 17 | 23 | 104 | Heaviest paper — factor tables force paper; break-even = phone-calc; rich cost-type traps |
| statics | 59 | 13 | 14 | 32 | 158 | Paper-heavy; setup-not-solve dominant; joints/sections, friction, composites |
| dynamics | 54 | 7 | 31 | 16 | 109 | Phone-calc dense; unit-conversion traps; simultaneous-eqn collisions = paper |
| mechanics-materials | 77 | 12 | 27 | 38 | 165 | Paper dominates; L³/L⁴/d⁴ + units; J-vs-I trap cards rich |
| materials | 80 | 32 | 38 | 10 | 160 | Concept-heavy; metallurgy/corrosion = recall; fracture mechanics = paper |
| fluid-mechanics | 72 | 12 | 33 | 27 | 144 | Trap-dense (gauge/abs, factor-of-2); momentum pipe-bend = paper |
| surveying | 68 | 9 | 43 | 16 | 136 | Heavily phone-calc; lat/dep sin-vs-cos trap recurs 8×; vertical curves = paper |
| water-resources | 89 | 20 | 38 | 31 | 178 | Exp/log heavy (BOD, Thiem, Streeter-Phelps) = paper; 22% concept |
| structural | 87 | 22 | 40 | 25 | 173 | Trig singles phone-calc, RC/steel chains = paper; determinacy/philosophy = concept |
| geotechnical | 92 | 21 | 56 | 15 | 184 | Most phone-calc (61%); single plug-ins; log consolidation = paper |
| transportation | 87 | 30 | 28 | 29 | 176 | High concept (MUTCD/LOS/Greenshields); SSD/yellow-interval = paper |
| construction | 63 | 31 | 24 | 8 | 127 | Concept-dominant (delivery/OSHA); CPM network traversals = paper |

**Phone-richest** (best first content): geotechnical, surveying, statistics,
materials, ethics, construction, transportation. **Paper-heaviest** (lean on the
hand-off + concept/setup cards): economics, mechanics-materials, statics,
water-resources, fluid-mechanics, mathematics.

## Review queue (before any of this ships)

- **45 reviewFlag=true** — genuine boundary calls the agents flagged (mostly
  phone-calc⇄paper). Human eyes decide.
- **45 medium-confidence** — same neighborhood; sample-audit.
- The **405 lesson problems' authored type tags never existed** — their tier is
  fully inference-derived. Spot-audit a sample per chapter.
- Every **card is a draft** mined from existing text — accuracy review is
  mandatory before a single one is shown (the whole point is honesty).

## Files
- `problem-classification.json` — the full per-problem dataset (id, chapter,
  pool, tier, interaction, mined cards, confidence, reviewFlag, note).
- `classification-rubric.md` — the rules applied.
- `scripts/classify-problems.mjs` / `dump-problems.mjs` / `aggregate-tiers.mjs` —
  reproducible pipeline; always matches `getProblemPoolSize()`.
