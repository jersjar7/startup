# Mobile visual language — LOCKED

_Approved 2026-06-10. This is the agreed style for the FE for Raccoons mobile
app. Reference render: `visual-language.png` (the "Today / trap card / paper
hand-off" trio). Every mobile screen follows the rules below._

## The philosophy: calm canvas, confident color

We triangulated to this from three tries:
- **v1** — website palette ported straight over: every element colored → too busy, shouts.
- **v2** — stripped to near-monochrome → clean but cold and boring.
- **v3 (this)** — neutral, airy base + color used **with intent**. The sweet spot.

Color is **signal, never decoration.** A neutral cream/white canvas carries ~80%
of every screen; color appears only in three sanctioned jobs:

1. **One hero / data moment** — the readiness *ring*, a streak flame. Energetic,
   modern, and it's showing real information.
2. **Meaningful status** — the small Concept / Trap / Recall tier tiles + dots,
   the correct/trap colors. Color that helps you scan and understand.
3. **The primary action + the payoff** — the ember button; the filled forest card
   when you get the answer right; the bold ember "grab paper" hand-off.

Everything *between* those moments stays neutral. That restraint is what keeps the
color from tipping back into noise. (This also honors the brand rule: never more
than ~2 accent hues competing in one section.)

## Palette (brand tokens, mobile usage)

Same tokens as the website (`CLAUDE.md`); the difference is **discipline of use**.

| Token | Hex | Mobile job |
|---|---|---|
| cream / white | `#FFF9F0` / `#FFF` | page canvas / cards — the calm base |
| charcoal | `#2C2C2C` | all primary type; hierarchy is carried by **type**, not color |
| ink2 / ink3 | `#6b6358` / `#9c9488` | secondary / tertiary text |
| **ember** | `#E8683A` | the standing accent: primary action, readiness ring, paper hand-off, active tab |
| forest | `#2D7A5F` | mastery / correct / the reveal payoff |
| sunbeam | `#F5B731` | streak / highlight (the one warm pop) |
| error | `#D64045` | the struck-through wrong answer only |
| soft bgs | `--ember-bg #FEF0EA` · `--forest-bg #E8F5EE` · `--sunbeam-bg #FEF7E0` | tier tiles + filled payoff cards |

Rule of thumb: **one identity accent per screen** (usually ember), with forest /
sunbeam appearing once each at a meaningful moment.

## Typography
- **DM Sans** (600–700) — headings; big and confident, does the hierarchy.
- **Inter** (400–500) — body, secondary text.
- **JetBrains Mono** — all numbers, formulas, data (μ, φ, %, equations).
- Overlines: DM Sans 600, ~10.5px, uppercase, letter-spacing .1em.

## Components
- **Cards** — white, radius 16–20px, soft warm shadow
  (`0 8px 24px rgba(44,44,44,.06)`). Float on the cream canvas.
- **Dividers** — 1px hairline `rgba(44,44,44,.09)`. Prefer hairlines over boxes.
- **Icons** — thin outline, monochrome (charcoal/ink3) in neutral spots; inside a
  soft-tinted tile (`34px`, radius 11) only when it carries tier color.
- **Tier dots / tiles** — Concept = forest, Trap = ember, Recall = sunbeam.
- **Readiness ring** — ember stroke on a `--cream-dark` track, mono % in center.
- **Bottom nav** — 4 outline icons, labels DM Sans 10px; active tab ember, rest `#bcb3a6`.

## Buttons — fixed height, single line (hard rule)

- **All buttons are the same height: 54px.** Never let a button grow or shrink.
- **Labels stay on one line — they must never wrap.** `white-space: nowrap`,
  fixed height enforce this structurally.
- **If a label is too long, shorten the words — don't grow the button.** Reduce to
  the simplest clear verb/noun.
  - "Start review · 9 cards" → **"Start"** (the count already shows above it)
  - "Worked example" → **"Example"**
  - "See worked example" → **"Example"**
- **Primary** = ember fill, white text, soft ember shadow. **Secondary** = ghost
  (transparent, hairline border, ink2 text). Both identical height.
- Two buttons in a row: secondary ~40–46% width, primary takes the rest.

## How this differs from the website
The website brand can spread out — colored top-accent bars, multi-color badges,
denser sections — because it has the screen room. Mobile applies the *same
identity* (cream warmth, ember, the three fonts, subtle raccoon) with far more
restraint: one accent per screen, color only at hero/status/action moments,
typography and whitespace doing the rest.

## Copy rules (honesty)
- The progress metric is **"mastery" / "concept mastery"** — *never* "readiness"
  framed as odds, and **never a probability of passing.** Don't write "X% chance
  to pass," a "pass line," or pass-odds anywhere. (See north-star rule #3.)
- Allowed: "you've mastered X% of the concepts the FE tests," per-topic states
  **Mastered / Familiar / Building / New**, and the standing honest line
  *"Mastery of the concepts the FE tests — not a probability of passing."*
- Keep the "familiar isn't mastered — now lock it in" nuance visible.
- (Retrofit note: earlier mock screens labeled "Readiness" + a "pass ~70%" marker
  predate this rule — rename to mastery, drop the pass marker.)
