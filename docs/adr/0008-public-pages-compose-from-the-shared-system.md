# 0008. Public pages compose from the shared public.css system

- **Status:** Accepted
- **Date:** 2026-08-07
- **Affects:** `src/public/public.css`, `src/public/ExamSimulation.jsx`, `ExamGuide.jsx`, `PublicTopic.jsx`, and every future public page

## Context

The `/exam-simulation` page shipped its first draft with markup written against
a stylesheet nobody had opened. Fourteen class names were used; **eight did not
exist**:

```
.pub-wrap  .pub-eyebrow  .pub-list  .pub-table-wrap
.pub-table  .pub-table-total  .pub-cta-btn  .pub-cta-link
```

Every one of them rendered as an unstyled default. The result was not a design,
it was a document:

- The primary call to action, on the page whose only job is selling the one paid
  product, rendered as plain black text with the arrow icon wrapped onto its own
  line. Nothing signalled it was clickable.
- The distribution table had no cell padding, so the first row read
  "Mathematics & Computational Tools13".
- The fifteen topic names were links to the topic guides and rendered as plain
  black text, losing the internal linking that was half the reason for the table.
- No ember appeared anywhere on the page. The brand's primary accent was absent
  from a page that is entirely a conversion surface.

The deeper problem is that none of those components needed to be written.
`public.css` already had a hero with an icon tile, a two-tier button system, a
label overline, white panels, numbered rows, stat cards, an accent-marked list,
a `<details>`-based FAQ, and a charcoal closing CTA — all in use by the guide and
topic pages. The draft invented a parallel vocabulary for components that
already existed and then failed to define it.

This was caught only because the owner looked at the rendered page and pushed
back. Prerendering succeeded, the byte count looked healthy, the JSON-LD
validated, and the tests passed. **Nothing in the pipeline can fail on a class
that does not exist**, because an undefined class is valid HTML and valid CSS.

## Decision

**A public page is assembled from the components already in `public.css`. New
CSS is written only for something the system genuinely lacks, and it is added to
`public.css` as a named component, not inlined into a page.**

In practice, for a new public page:

1. Read `public.css` first and inventory what exists.
2. Build from `.pub-hero`, `.pub-label`, `.pub-btn` / `.pub-cta-row`,
   `.pub-panel`, `.pub-rows`, `.pub-facts`, `.pub-traps`, `.pub-faq` +
   `.pub-eli5`, `.pub-final-cta`.
3. Only when a genuine gap exists, add a component to `public.css`. The
   simulation page needed exactly two: `.pub-table*` (nothing handled tables) and
   `.pub-price*` (a price should not be styled as body text).
4. Before shipping, assert that every class used in the page resolves, and
   **look at the rendered page** at desktop and mobile widths.

The verification is mechanical and takes seconds:

```
python3 - <<'PY'
import re
used = {c for m in re.finditer(r'className="([^"]*)"', open(JSX).read())
          for c in m.group(1).split()}
defined = set(re.findall(r'\.([a-zA-Z0-9_-]+)', open(CSS).read()))
print(sorted(used - defined))   # must be empty
PY
```

## Consequences

**Good**

- Public pages look like one product. A visitor moving from a topic guide to the
  sales page sees the same hero, buttons and rhythm.
- New pages get the accumulated design work for free, including the responsive
  behaviour already encoded in the breakpoints.
- Undefined classes become a detectable condition rather than an invisible one.
- The stylesheet stays the single place where public styling is decided, so a
  brand change happens once.

**Bad, and accepted**

- Writing a page now requires reading an existing stylesheet first, which is
  slower than inventing names.
- The shared components constrain layout. A page wanting something genuinely
  different has to extend the system rather than freelance, which is the point
  but is occasionally the wrong trade.
- `public.css` grows over time and will eventually need grouping.

## Alternatives considered

**Define the eight missing classes as written.** The obvious local fix, and
wrong. It would have produced a second parallel set of components duplicating
the hero, buttons and lists that already existed, guaranteeing visual drift the
first time either copy was edited.

**Tailwind utilities on the public pages.** Tailwind is already in the project.
Rejected because the public pages are deliberately a small, hand-tuned system
echoing the landing page, and mixing two styling models across sibling pages
makes the shared look harder to hold, not easier.

**A CSS-modules or lint rule enforcing class existence.** The correct long-term
answer and still open. Not done now because the plain check above costs nothing
and the immediate problem was a broken page, not missing tooling.

## Notes

Two content errors were found in the same review, both invented rather than
derived, and both worth recording because they share a cause with the CSS:

- The page reused `EXAM_FACTS.durationLabel` ("6 hours total"), which describes
  the real NCEES appointment including tutorial and survey. The product is
  5h 20m of testing plus a 25-minute break. It overstated what a customer sits.
- It claimed "Most people discover their weakest chapter is not the one they
  expected," which is supported by nothing.
- It listed "Time used" as part of the score report. **The results screen did not
  show time at all.** Rather than cut the claim, the metric was built: see
  `src/exam/ExamResults.jsx` and ADR notes below.

The rule those three share with the missing CSS: state only what the code
actually does, and check the code rather than assuming it. See ADR-0005 — the
same discipline that says measurement beats preference.

## Related change: pacing on the score report

`timeUsedSeconds` was already computed server-authoritatively and stored on the
attempt, but was never rendered. The results screen now shows time used against
the limit and questions answered against 110, because a full-length timed exam
answers two different questions and the score alone answers one: finishing early
with 45% is a knowledge problem, running out of time with 20 questions untouched
is a pacing problem, and the remedies differ.

One real bug surfaced doing it. `finalizeAttempt` computed the value and wrote it
to the database but did **not** return it, and the results screen reads the
submit response out of `sessionStorage` on the way out of the exam, only falling
back to `GET /attempt/:id` on a later visit. Pacing would have been blank on the
pass every customer sees and present on the pass almost nobody makes.
