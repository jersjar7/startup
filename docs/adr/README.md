# Architecture Decision Records

Short records of decisions that were **not obvious**, so the reasoning survives
the session that produced it. Six months from now the code shows *what* we do;
these explain *why*, and what we rejected.

## When to write one

Write an ADR when a decision:

- has a non-obvious rationale someone could reasonably reverse by accident
- was chosen over a defensible alternative
- came from evidence (a measurement, an incident) that will not be visible later
- constrains future work

Do **not** write one for routine implementation. If the code is
self-explanatory, a comment is enough.

## Format

`NNNN-short-kebab-title.md`, numbered sequentially, never renumbered.

Each record carries: **Status**, **Context** (what forced the decision),
**Decision**, **Consequences** (including the bad ones), and **Alternatives
considered** with why they were rejected.

Status is one of `Proposed`, `Accepted`, `Superseded by NNNN`, `Deprecated`.
**Never edit an accepted decision to say something different** — write a new ADR
that supersedes it, so the history of thinking stays readable.

## Index

| # | Title | Date | Status |
|---|---|---|---|
| [0001](0001-grade-abandoned-exams-only-if-genuinely-sat.md) | Grade abandoned exams only if genuinely sat | 2026-08-04 | Accepted |
| [0002](0002-separate-merge-semantics-for-autosave-and-submit.md) | Separate merge semantics for exam autosave and submit | 2026-07-30 | Accepted |
| [0003](0003-ask-attribution-at-registration.md) | Ask "how did you find us?" at registration, not at verification | 2026-07-30 | Accepted |
| [0004](0004-sim-pitch-gate-and-25-problem-threshold.md) | Widen the sim-pitch gate, and set the effort threshold at 25 problems | 2026-08-04 | Accepted |
| [0005](0005-follow-the-growth-plan-and-when-to-deviate.md) | Follow the growth plan as written, and deviate only on evidence | 2026-07-29 | Accepted |

Records 0002–0005 were written on 2026-08-04, backfilled from commit messages.
The **Date** column is when the decision was made, not when it was written up.
