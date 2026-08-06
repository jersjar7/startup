# 0006. This repository holds software only

- **Status:** Accepted
- **Date:** 2026-08-04
- **Affects:** repository layout, `.gitignore`, every doc or memory that referenced `marketing/`

## Context

The repository had grown to hold three unrelated kinds of thing:

1. **Software** — the React app, the Express service, scripts, tests, docs.
2. **Marketing production** — 5.6GB across 54,445 files: Remotion reels, Manim
   renders, carousels, raw footage, the posting pipeline, LinkedIn assets, and
   the growth plan and baseline analyses.
3. **Company records** — the LLC certificate of organization, EIN confirmation,
   and DBA filings as PDFs.

All of (2) and (3) were gitignored, so none of it was ever tracked. That is
precisely what made the arrangement awkward rather than merely large:

- The working tree was **5.6GB**, almost entirely files git could not see.
  Anything scanning the tree paid that cost for no benefit.
- The directory layout implied the marketing pipeline was part of the software
  project. It is a separate discipline with a separate cadence.
- Company legal records sat one `.gitignore` edit away from being committed to a
  repository. Nothing enforced their exclusion but a single line.
- A fresh clone produced a repo where documented paths like
  `marketing/analysis/90-day-growth-plan.xlsx` simply did not exist, because
  they were never in git. The docs described a layout only one machine had.

## Decision

**This repository contains software and its documentation. Nothing else.**

Non-software moved to siblings beside it:

| Was | Now |
|---|---|
| `marketing/` | `~/developer/fe4raccoons-marketing` |
| `legal/` | `~/developer/fe4raccoons-legal` |

The `.gitignore` entries stay, with a comment explaining where the directories
went, so neither can be recreated inside the repo by accident.

`src/legal/` is unrelated and untouched — those are the Terms and Privacy React
pages, which are software.

Before moving, verified: neither directory was tracked, nothing in the build,
deploy or application reads them, and file counts matched exactly on both sides
(54,445 and 7).

## Consequences

**Good**

- The repo is what it claims to be. `ls` at the root now describes a web
  application.
- Company legal records can no longer be committed by an errant `git add`.
- Documented paths now match reality for anyone who clones, rather than
  describing one machine's untracked directories.

**Bad, and accepted**

- Every reference had to be repathed: `CLAUDE.md` plus 11 memory files. A stale
  path is now a broken path rather than a working one, which is a real cost paid
  once.
- No single checkout gives you everything. Working on a reel and the app at once
  means two locations.
- **The moved directories have no version control at all.** That was already
  true — they were never tracked — but the move makes it conspicuous. 5.6GB of
  marketing production and the growth plan currently have no history and no
  backup beyond whatever the filesystem provides. Worth solving separately; this
  ADR does not solve it.

## Alternatives considered

**Leave them and rely on `.gitignore`.** Zero effort, status quo. Rejected: it
keeps 5.6GB in the tree, keeps legal records one edit from being committed, and
keeps the misleading layout.

**Git submodules.** Would keep one checkout while separating history. Rejected
as heavy for a solo project, and submodules are a well-known source of confusing
failure modes for no benefit here — the marketing pipeline has no reason to be
version-pinned against the app.

**Git LFS for the media.** Would let the assets be tracked. Rejected: it solves
a problem nobody has. The reels are build outputs from `remotion/` and `manim/`
sources, and nobody wants to diff a 200MB MP4. It also costs money at this
volume.

**A separate git repository for each, rather than plain directories.** Better
than nothing and still available later. Not done now because the immediate
problem was repo scope, not versioning, and conflating the two would have
delayed the move. See the consequence above.

## Notes

This ADR was written a day late, after the owner pointed out that a structural
decision had been made in the same commit that introduced the ADR practice,
without an ADR. The rule in `docs/adr/README.md` — write one when a decision
constrains future work — applied to this and was missed. Recorded here rather
than quietly fixed, because the omission is part of the history.
