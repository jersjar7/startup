# Mobile problem-classification rubric

_The decision rules for deciding what each bank problem becomes on the phone.
Applied per-problem to all 1,126 (see `scripts/dump-problems.mjs` for the data,
`scripts/classify-problems.mjs` for the mechanical first pass). Grounded in
`../mobile-app-north-star.md` — re-read that first._

This started as "the LLM pass over the 264 borderline computationals." Generalized:
every problem gets the same structured judgment, because the mechanical pass is
blind to cognitive load (a 2-step log/trig problem still needs paper) and to the
405 untyped lesson problems.

## What we decide for each problem

### 1. `mobileTier` — where it lives in the phone↔paper split

| Tier | Meaning | North Star layer |
|---|---|---|
| `concept` | Tests a fact, relationship, definition, or judgment. Answerable on a screen with **no arithmetic** (or trivial mental arithmetic). | Declarative / retrieval |
| `phone-calc` | One formula, a plug-in, an estimate, or ≤2 *simple* operations a focused person does in their head or one line of scratch. No heavy trig/log/iteration/unit-conversion chains. | Declarative, applied |
| `paper` | Multi-step or computationally heavy — genuinely needs paper. **Not hidden** — surfaced on the phone as an honest "grab paper" hand-off. | Procedural / problem-solving |

Decision aids (in priority order, judgment beats the count):
- Authored `type: 'conceptual'` → almost always `concept`. Verify it really is.
- `type: 'computational'` or untyped → look at the **steps' math**, not just the
  count. Logs, trig, simultaneous equations, integrals, iterative lookups,
  multi-unit conversions, interpolation → `paper` even at 2 steps.
- A single handbook-formula plug-in with clean numbers → `phone-calc`.
- Pure "which is true / what should the engineer do / what does X mean" → `concept`.

### 2. `interaction` — how it's presented on the phone (the pedagogy)

Pick the **primary** mode; the goal is *generation*, not recognition (rule #1).

| Mode | What the user does | Best for |
|---|---|---|
| `recall-reveal` | See the prompt, retrieve the answer/idea in their head, then reveal to check | concept facts, definitions, relationships |
| `formula-first` | "Which formula / handbook page applies here?" before any numbers | `phone-calc` and `paper` setups — tests *the approach* |
| `tap-the-trap` | Given a scenario or a worked line, spot the error/misconception | anything with a populated `traps` array |
| `setup-not-solve` | "What's the governing equation / first move?" — phone tests the setup, paper does the math | `paper` problems |
| `mcq` | Recognize the right option | judgment/ethics where recognition *is* the skill; use sparingly elsewhere |
| `flag-for-paper` | Full problem, labeled "grab paper," worked example available first (rule #4) | every `paper` problem's full-solve form |

A `paper` problem typically gets **two** mobile surfaces: a phone-native setup
card (`formula-first` or `setup-not-solve`) **and** a `flag-for-paper` full solve.

### 3. `cards` — phone retrieval micro-cards mined from the problem (0–3)

Every problem can seed at least one (all carry handbook refs and/or traps). Each
card is a short generation prompt + its answer source. Mine from:
- `traps[]` → `tap-the-trap` / "why is this wrong?" cards (highest value — these
  are pre-written misconceptions).
- `handbookFormula` / `handbookPage` → `formula-first` recall ("what formula? where
  in the handbook?").
- `eli5` core idea → a `recall-reveal` concept card.
- The underlying relationship the problem hinges on.

Keep each card one line. These are **drafts** — an LLM proposes, a human verifies
before anything ships (accuracy is the whole point).

### 4. Bookkeeping

- `needsPaper`: boolean (true iff tier `paper`).
- `confidence`: `high` | `medium` | `low`.
- `reviewFlag` + `reviewReason`: set when the mechanical pass and the judgment
  disagree, the authored type looks wrong, or the call is genuinely close.
- `note`: one line of *why*.

## Output schema (one record per problem)

```json
{
  "id": "stat-fsr-ex1",
  "mobileTier": "phone-calc",
  "interaction": { "primary": "formula-first", "secondary": "tap-the-trap" },
  "cards": [
    { "kind": "formula-first", "prompt": "Force given by rise/run — how do you get the horizontal component?" },
    { "kind": "tap-the-trap", "prompt": "Why is using 12/13 (not 5/13) wrong here?" }
  ],
  "needsPaper": false,
  "confidence": "high",
  "reviewFlag": false,
  "reviewReason": null,
  "note": "5-12-13 plug-in, clean numbers — one line of mental math."
}
```

## Non-negotiables (carry from the North Star)
- Default to **generation** over recognition. If a problem only works as `mcq`,
  say why.
- Be **honest about paper**. Don't downgrade a real paper problem to `phone-calc`
  to pad the phone tier. When unsure between `phone-calc` and `paper`, choose
  `paper` and set `reviewFlag`.
- Cards are **mined, not invented** — grounded in the problem's own traps/handbook/eli5.
