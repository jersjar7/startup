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

| # | Title | Status |
|---|---|---|
| [0001](0001-grade-abandoned-exams-only-if-genuinely-sat.md) | Grade abandoned exams only if genuinely sat | Accepted |
