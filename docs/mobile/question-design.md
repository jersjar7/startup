# Mobile question design — what a phone question is allowed to be

_Owner directive, 2026-08-24. This is a **hard constraint doc**, not a menu of
ideas. It sits under [`../mobile-app-north-star.md`](../mobile-app-north-star.md)
and it **tightens** [`classification-rubric.md`](./classification-rubric.md) and
[`content-plan.md`](./content-plan.md). Where they disagree, this wins._

## The rule

> **On the phone the student never computes a number. They demonstrate they know
> what governs the answer.**

Everything below follows from that one line. A phone question is answered with a
thumb: choosing, ordering, dragging, sorting, tapping a picture. Never with
arithmetic, never with a keypad, never with an on-screen calculator.

The owner's framing, verbatim: *"I personally do not want to solve a math problem
or engineering problem by looking at my phone. Those kinds of questions deserve a
desktop, paper and pencil."* Agreed, and it is also the better pedagogy (see
Prior art).

### What this kills, explicitly

| Killed | Why |
|---|---|
| On-screen calculator / scratchpad as an answer path | It fakes the desk. The desk is the desk. |
| Numeric-entry answers | Same. |
| The website's 4-line text MCQ shipped as-is to the phone | That is what `exercise_screen.dart` renders today. It is a port, not a design. |
| `phone-calc` as a **question type** | The tier name survives as a *content property* (it tells us how heavy the underlying solve is). It no longer means "let them tap out the calc." |
| "Calculator-on-screen OK" in `content-plan.md` | Superseded by this doc. |
| A `paper` problem rendered on the phone with choices | A paper problem gets a phone **setup** question and a hand-off card. Never a tappable full solve. |

### What survives

The three-way content tiering (`concept` 327 / `phone-calc` 468 / `paper` 331),
the 2,388 mined card seeds, the 1,257 pre-written `traps[]`, the 281 wired
figures. All of it is raw material. What changes is **the surface**: the item the
student actually touches.

---

## Prior art (you are not inventing this)

This exact approach is established practice in two separate worlds, and the
engineering-education one is directly about our subjects.

**Consumer learning products**
- **Brilliant.org** built an entire business on visual, manipulable, no-calculator
  problem solving across math, physics and engineering. Their unit is an
  interaction, not a question stem.
- **Duolingo** proved the thumb grammar we are borrowing: token banks (build the
  sentence from chips), tap-to-order, match-the-pairs, bounded sets with a "done"
  state.

**Engineering and physics education research (the credible half)**
- **Concept inventories.** Validated, deliberately non-computational instruments
  that measure whether a student actually understands a subject: the *Force
  Concept Inventory* (Hestenes et al., 1992), the *Concept Assessment Tool for
  Statics* / CATS (Steif & Dantzler, 2005), plus inventories for strength of
  materials, fluid mechanics, thermodynamics and statistics. The research finding
  that matters to us: students who can grind the algebra routinely fail these.
  Computational fluency and conceptual understanding are **different**, and the
  conceptual one is the one that transfers.
- **Ranking Tasks** (O'Kuma, Maloney & Hieggelke) and **TIPERs** (Tasks Inspired
  by Physics Education Research). Whole published task families with no
  computation: rank these situations by a quantity, say what changes if a variable
  doubles, work backwards from an answer, find the fault in a presented solution.
  Types 1, 6 and 7 below are lifted straight from this literature.
- **ConcepTests / Peer Instruction** (Mazur). Single-tap conceptual items designed
  for a clicker. One tap, no math, diagnostic of real understanding.
- **Completion problems / faded worked examples** (Sweller & Cooper; van
  Merrienboer). Give the student a worked solution with pieces missing and have
  them supply the missing piece. This is the sanctioned way to practice a
  multi-step procedure without executing it, and it is exactly what our `steps[]`
  arrays already are. It is the answer to "how does a paper problem become a phone
  item."

So: the format is not a compromise for small screens. It is a measurement of the
thing the FE actually rewards, which is knowing what governs the answer.

---

## The question kit

Ten types. This is a **closed set**. Adding an eleventh is a design decision, not
an authoring decision. Every type is thumb-only, gradeable, and generative
(retrieval, not recognition).

Each type below gives: the ask, what it tests, the interaction, a real example
built from our own bank, where the content comes from, and the failure mode.

### Family A — Structure (order it)

#### 1. `rank` — Rank by magnitude
- **Ask:** "Order these by X, largest first."
- **Tests:** proportionality and which variable dominates. The single highest-value
  non-computational engineering skill.
- **Interaction:** drag 3 to 4 cards into order. Tap fallback: tap in sequence.
- **Example (mechanics-materials):** three cantilevers, rectangular section, same
  load. A: length L, depth d. B: length 2L, depth d. C: length L, depth 2d. Rank
  by tip deflection, largest first. (Answer B, A, C. Deflection goes as L³/d³ for a
  rectangle, so doubling L multiplies by 8 and doubling d divides by 8.)
- **Source:** any problem whose formula has exponents; `traps[]` naming a
  power-of-length or power-of-diameter mistake.
- **Failure mode:** ranking items that differ in more than one variable at once
  without a clean dominant term. Keep exactly one idea per item.

#### 2. `sequence` — Order the method
- **Ask:** "Put the steps in the order you would actually do them."
- **Tests:** procedural knowledge without executing the procedure. This is the
  owner's *"steps you take to solve this kind of problem."*
- **Interaction:** drag 4 to 6 step chips into order.
- **Example (statics, method of sections):** [Cut through the member you need] /
  [Draw the FBD of one side] / [Sum moments about the joint that kills two
  unknowns] / [Solve for the remaining member force]. Distractor step available:
  [Solve every joint from the support inward] (that is method of joints).
- **Source:** the existing `steps[]` arrays, with the arithmetic stripped and the
  teaching padding removed. Roughly 3 to 6 real moves hide inside most of them.
- **Failure mode:** steps that are genuinely order-independent. If two steps can
  swap, either merge them or accept both orders.

### Family B — Selection (choose it)

#### 3. `first-move` — What is your first move
- **Ask:** given a full problem statement, "What do you do first?"
- **Tests:** approach selection, the thing that separates a 5-minute solve from a
  15-minute one on exam day.
- **Interaction:** one tap, 4 options, all of them plausible *methods* (never
  numeric answers).
- **Example (statics):** "You need the force in one diagonal member near midspan
  of a 13-member truss." → [Method of sections through that member] vs [Method of
  joints starting at the left support] vs [Sum moments about the roller first] vs
  [Check for zero-force members first].
- **Source:** every `paper` problem. This is the phone surface of a paper problem.
- **Failure mode:** making the right answer the longest option. Keep option
  lengths even.

#### 4. `hotspot` — Tap the figure
- **Ask:** "Tap every zero-force member." "Tap where the moment is maximum." "Tap
  the failure plane."
- **Tests:** reading an engineering drawing, which is over half of what the FE
  Civil actually shows you.
- **Interaction:** tap one or more regions on a diagram. Regions are generous
  (44pt minimum), never pixel-precise.
- **Example (statics):** the existing `ZeroForceJoint` figure, "tap the two
  zero-force members."
- **Source:** the 281 wired figures and the 294 spatially-flagged problems. Needs
  a hit-region layer added to each figure component (see Data model).
- **Failure mode:** requiring precision. If a fat thumb can miss it, the region is
  too small.
- **Cost note:** highest build cost of the ten (hit regions are per-figure, hand
  authored). Also the most differentiated. Worth it.

#### 5. `sort` — Sort into bins
- **Ask:** "Drag each into the right bucket."
- **Tests:** classification and discrimination, cheaply and several data points
  per interaction.
- **Interaction:** drag 5 to 8 chips into 2 or 3 labelled bins. Tap fallback:
  tap chip, tap bin.
- **Example (statics):** members of a loaded truss → Tension / Compression /
  Zero. **(geotech):** conditions → Drained / Undrained. **(construction):**
  items → OSHA-required / Recommended / Neither.
- **Source:** `concept` tier problems, definitions in lesson `content[]`, ethics
  and construction chapters especially.
- **Failure mode:** a chip that honestly belongs in both bins. Every chip must
  have exactly one defensible home.

#### 6. `what-changes` — Increase, decrease, no change
- **Ask:** "You double the beam depth. Deflection ___."
- **Tests:** the same proportionality sense as `rank`, in one tap, and it is the
  fastest item in the kit to answer honestly.
- **Interaction:** three fixed buttons: goes up / goes down / no change. Optional
  follow-up tap for "by roughly how much": ×2, ×4, ×8, ×16.
- **Example (mechanics-materials):** "A rectangular cantilever's tip deflection
  under a point load. You double the depth d. The deflection..." → goes down, by
  roughly ×1/8 (I goes as d³ for a rectangle; ×1/16 is the round-shaft instinct and
  is the intended distractor).
- **Source:** every formula in the bank. Mechanically minable, then verified.
- **Failure mode:** letting the "by how much" step become arithmetic. It is recall
  of the exponent, so keep the options as clean powers.

#### 7. `spot-the-error` — Find the wrong line
- **Ask:** four lines of a worked solution are shown. One is wrong. Tap it, then
  tap why.
- **Tests:** error detection, the closest phone proxy for real problem solving,
  and it is *generative* (they have to hold the correct version in their head to
  see the wrong one).
- **Interaction:** tap the bad line, then tap the reason from 3 options.
- **Example (mechanics-materials):** a simply-supported midspan-load deflection
  worked with PL³/3EI. Wrong line: the formula pick. Reason: "that is the
  cantilever case."
- **Source:** **the 1,257 pre-written `traps[]`.** This is the largest and most
  valuable seam in the whole bank and it is already written by a human.
- **Failure mode:** an error that is arithmetic slop ("they wrote 47.3 instead of
  43.7"). We are not testing carefulness with digits. The error must be
  conceptual: wrong formula, wrong assumption, wrong sign convention, wrong units
  family, wrong table.

#### 8. `match` — Match the pairs
- **Ask:** connect each term to its partner.
- **Tests:** vocabulary, symbol fluency, handbook geography.
- **Interaction:** two columns, tap-tap to pair (do not drag; dragging across a
  narrow screen is worse here).
- **Example (surveying):** latitude ↔ cos(bearing), departure ↔ sin(bearing).
  That single confusion recurs 8 times in the bank. **(any chapter):** quantity ↔
  handbook page.
- **Source:** `handbookFormula` / `handbookPage` fields, definitions, the 585
  formula-first card seeds.
- **Failure mode:** using it as filler. Match is cheap to author and shallow to
  answer. Cap it (see Composition).

### Family C — Construction (build it)

#### 9. `build-formula` — Assemble the expression
- **Ask:** "Build the expression for the maximum deflection of a cantilever with a
  tip point load."
- **Tests:** true recall of a formula's *form*, not recognition of it in a list.
  This is the strongest anti-fluency-illusion item we have.
- **Interaction:** a token bank of chips (P, w, L³, L⁴, E, I, 3, 8, 48, 384, 5)
  dragged into numerator and denominator slots. Extra distractor chips always
  present. Tap fallback: tap chip, it flies to the next open slot.
- **Example:** the four beam cases on handbook pp. 140 to 141 are one lesson's
  worth of these on their own, and the traps file already tells us the exact
  confusions (48 vs 384, L³ vs L⁴, the missing 5).
- **Source:** every `formula` content block and every `handbookFormula`.
- **Note:** the student assembles symbols. They never put a number in. Building
  PL³/3EI is recall. Evaluating it is the desk's job.
- **Failure mode:** formulas with too many tokens. Cap at about 6 slots. Anything
  bigger is a `match` to a handbook page instead.

#### 10. `build-diagram` — Place the arrows
- **Ask:** "Complete the free-body diagram." "Sketch the moment diagram shape."
- **Tests:** the single most examined skill in FE Civil statics and structures.
- **Interaction:** drag force/reaction arrows onto anchor points on a body, or
  choose the correct diagram shape from 4 rendered candidates (the cheap variant,
  ship this one first).
- **Example (statics):** a beam with a pin and a roller. Drag the correct reaction
  arrow set onto each support. Distractors include the classic "two arrows at the
  roller."
- **Source:** the 294 spatial problems, the FBD figures.
- **Failure mode:** free placement anywhere on the canvas. Use fixed anchor
  points, always.
- **Cost note:** highest build cost with `hotspot`. The "pick the right diagram
  from 4" variant gets 80% of the value for 20% of the work. Start there.

### The one deliberate exception

Plain text MCQ (`mcq`) stays legal for exactly the cases where **recognition is
the real-world skill**: ethics and professional-conduct judgment, code and
standard lookups. The classification pass found only **7 problems of 1,126** in
that bucket. Treat any new `mcq` as a smell and make the author justify it in the
item's `note` field.

---

## Composition: what a lesson ships

Each of the 135 lessons ships a **bounded set** of phone items. Target 8 to 14
per lesson, drawn from its own problems.

Rules:
1. **At least 5 distinct types** per lesson. Monotony is the enemy of the
   bounded-set feeling.
2. **Never the same type twice in a row** in a session.
3. **At least one `sequence`** per lesson that has any procedure at all. This is
   the owner's core ask and it is the type students will remember.
4. **At least two `spot-the-error`** per lesson. The traps are already written,
   they are the best items, and they are free.
5. **`match` capped at 2** per lesson. Cheap to author, shallow to answer.
6. **`hotspot` or `build-diagram` required** for any lesson with a wired figure.
7. **Open with the easiest type** (`what-changes` or `match`), put the hardest
   (`build-formula`, `build-diagram`) at position 3 to 6, close on a
   `spot-the-error`. Never open cold with a drag.
8. **Session length is fixed and visible.** 8 to 14 items, a progress capsule, a
   "done" screen. No infinite feed (North Star rule 5).

---

## The paper hand-off

A `paper` problem (331 of them) produces on the phone:
- one `first-move` or `sequence` item (the setup), **graded and spaced**, and
- a **hand-off card**: the full problem statement, a "Take this one to paper"
  action, and the worked example available *first* (North Star rule 4).

The hand-off card is **not a question**. It has no choices. It logs to a desk
queue, and the honest line stays: *"You know the approach. Now prove you can
finish it on paper."*

This is the app's one place where it must be openly useless, and saying so is the
whole brand.

---

## Grading, spacing, XP

- Every item emits `{itemId, sourceProblemId, type, correct, latencyMs}`.
- Feeds the existing spaced scheduler unchanged. An item is the review unit, not
  the source problem, so a lesson's items space independently.
- **Partial credit for multi-target types** (`sort`, `hotspot`, `rank`): report
  correct-target count, but grade the item as correct only on a clean sweep. No
  half-green states.
- **Never grade on speed.** No timers, no speed bonuses (North Star, and the
  adult-audience rule in `CLAUDE.md`).
- XP per item follows `xp-table.md`. A hand-off card completed at the desk is
  worth more than any phone item. That ordering is not negotiable: it is how the
  app stays honest about where the real work is.

---

## Data model

The web bank is **not modified**. Phone items are a separate, additive layer.

```
src/data/mobile-items/<chapter>/<lesson-id>.js
```

```js
{
  id: 'stat-tjs-i03',
  sourceProblemId: 'stat-tjs-q1',   // provenance, always required
  lessonId: 'trusses-joints-sections',
  chapter: 'statics',
  type: 'sort',                      // one of the ten
  tier: 'concept',                   // carried from problem-classification.json
  prompt: 'Sort each member by the force it carries.',
  payload: { /* type-specific, schema per type */ },
  answer:  { /* type-specific */ },
  explain: 'Rule 2: three members at an unloaded joint, two collinear...',
  handbookPage: 'p. 97, Statically Determinate Truss',
  figureId: 'ZeroForceJoint',        // when the item needs one
  difficulty: 'easy',
  verified: false,                   // flips true only after human review
  note: 'Mined from stat-tjs-q1 traps[0].'
}
```

- `payload` and `answer` are validated per type by a schema module, so a
  malformed item fails at build, not in a student's hand.
- Served through the existing content API alongside lessons. The Flutter client
  gets a `MobileItem` model and a widget per type. `exercise_screen.dart` becomes
  a dispatcher, not an MCQ renderer.
- Figures need a **hit-region layer** for `hotspot`: a sidecar per figure
  component listing named regions as normalized rects or paths.

---

## Authoring at 1,126-problem scale

The owner has accepted redesigning every problem, one by one, per lesson, per
chapter. Here is how that stays accurate.

**Inputs we already have per problem:** `statement`, `choices`, `steps[]`,
`eli5`, `traps[]`, `handbookPage`, `handbookFormula`, `diagram`, plus the
per-problem tier and mined card seeds in `problem-classification.json`.

**Per lesson (the unit of work):**
1. Read the lesson's `content[]` and all its problems.
2. Draft 8 to 14 items against the composition rules, **mined from the existing
   text, never invented**. Every claim must trace to a step, a trap, an eli5, or
   a handbook reference. Same non-negotiable as the card pass.
3. Schema-validate, then render every item in the app.
4. **Human verification before `verified: true`.** Accuracy is the entire product.
   An item that is pretty and wrong is worse than no item.
5. Commit per lesson. One lesson, one commit, so a bad batch is one revert.

**Guardrails carried from existing docs:** currency written as "dollars" not `$`,
no `\$` inside LaTeX, no emojis, Phosphor icons only, brand tokens only.

**Sequencing.** Do the phone-rich chapters first, both because they yield the most
items and because they prove the format fastest: **geotechnical, surveying,
statistics, materials, ethics, construction, transportation**. Then the
paper-heavy ones, where the work is mostly `first-move` and `sequence`:
economics, mechanics-materials, statics, water-resources, fluid-mechanics,
mathematics.

**Before any of it: build the ten widgets and pilot one lesson.** Author a full
item set for a single lesson (recommend `trusses-joints-sections`: it has a
figure, a clean procedure, real traps, and a zero-force rule that is genuinely
better taught by tapping than by reading). Put it on a real phone. Then decide
whether the kit is right, and only then spend the 135-lesson authoring budget.

---

## The item-level litmus test

The North Star's six questions still gate every *feature*. Every *item* also has
to pass these five:

1. **No arithmetic?** Could a student answer it correctly with no pen, no
   calculator, standing on a bus?
2. **Thumb-native?** One hand, no precision, no typing?
3. **Generative?** Do they have to retrieve or construct something, rather than
   recognize it in a list?
4. **Traceable?** Does every word trace to the source problem's own text?
5. **Honest?** Does it avoid implying that getting it right means they can solve
   the real problem?

Fail any one and the item is redesigned or dropped.

---

## Open questions for the owner

1. **Estimation items.** "Roughly what is a typical concrete f'c?" is number
   sense, not computation, and it is genuinely FE-useful. It is currently **out**
   of the kit. Want it in as an eleventh type (slider with banded grading), or
   keep the no-numbers line absolutely clean?
2. **`what-changes` follow-up.** The "by roughly how much: ×2 ×4 ×8 ×16" second
   tap is recall of an exponent, but it is the closest thing to arithmetic in the
   kit. Keep or cut?
3. **The web app.** This kit is specified for mobile. Several of these types
   (especially `spot-the-error` and `sequence`) would improve the website too.
   Separate decision, separate doc, not assumed here.

## Related docs
- [`../mobile-app-north-star.md`](../mobile-app-north-star.md) — the pedagogy spine this obeys
- [`classification-rubric.md`](./classification-rubric.md) — tiering rules (interaction table there is superseded by the kit above)
- [`content-plan.md`](./content-plan.md) — the 1,126-problem tiering and card yield (the raw material)
- [`visual-language.md`](./visual-language.md) — the locked mobile style every widget must render in
- [`xp-table.md`](./xp-table.md) — scoring
