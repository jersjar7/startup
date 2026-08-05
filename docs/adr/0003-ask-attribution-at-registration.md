# 0003. Ask "how did you find us?" at registration, not at verification

- **Status:** Accepted
- **Date:** 2026-07-30
- **Affects:** `src/login/login.jsx`, `src/dashboard/SourcePrompt.jsx`, `src/dashboard/acquisitionGate.js`, `service/acquisition.js`, `service/routes/auth.js`

## Context

Self-reported acquisition source is the only way to see channels that strip
referrers — TikTok, Instagram, Reddit — which is precisely where the most
marketing effort goes. Only ~10% of users ever answered.

The growth plan diagnosed placement and prescribed moving the question to
"a single mandatory tap immediately after email verification".

Investigation found the real cause was not placement but a **gate**.
`dashboard.jsx` only rendered the prompt when `hasActivity && readiness > 0`.
Roughly half of all users never answer a single problem, so they never reached
that condition and were never asked. The users least understood were exactly the
ones excluded.

The plan's prescription was then built and deployed, and **failed in production
testing**. Two independent reasons:

1. `GET /api/auth/verify-email` deliberately issues no session. The answer had
   to be parked in `localStorage` and flushed on a later authenticated load —
   but that link routinely opens in a different browser or profile from the one
   the user signed up in. A manual test lost the answer outright.
2. Verification is not enforced. Registration routes straight to the dashboard
   and "Verify your email" is only a setup task, so that placement reaches at
   most the ~75% who verify at all.

## Decision

Ask at **registration**, immediately after account creation, as a mandatory
single tap over fixed options with no free text.

`POST /api/auth/create` already sets the auth cookie, so the client is
authenticated at that moment and the answer is written server-side immediately.
No localStorage, no deferred flush, no dependence on which browser opens a link.

The dashboard keeps a **modal** as a safety net for anyone unresolved — legacy
accounts, and anyone who abandoned the signup step.

The governing rule is one sentence: **ask until resolved, never after.**
`resolved` means answered **or** explicitly dismissed, computed by
`service/acquisition.js::isAcquisitionResolved` and stored **on the user
document**.

## Consequences

**Good**

- Reaches 100% of new web signups instead of ~75%, and does not depend on
  engagement, verification, or which device opens an email.
- Attribution went from 50.4% to 64.4% in the first week, beating the plan's
  week-13 target of 60% in week 1.
- Server-side resolution means the same person is never asked twice across
  devices, browser profiles, or after clearing site data.

**Bad, and accepted**

- A mandatory question sits between signup and the product. It is one tap of
  eight options, but it is friction at the least forgiving moment.
- Forcing an answer produces some noise: people who do not remember will tap
  something. Accepted deliberately — a directional signal on 250 users beats a
  clean signal on 40. "Other" is the honest out.
- The chip ids and `ACQ_SOURCES` in `service/routes/auth.js` must stay in sync,
  or the POST 400s and the answer is lost silently. Adding LinkedIn required
  both.
- Deviates from the plan as written. Justified by a reproducible production
  failure, not by preference. See ADR-0005 on following the plan.

## Alternatives considered

**Keep it on the dashboard, just remove the activity gate.** The minimal change,
and it does fix the 10%. Rejected because it still only reaches users who return
to the dashboard, and it was already proven easy to miss: as a sidebar card it
rendered below the fold and users genuinely never saw it.

**At verification, as the plan prescribed.** Built, deployed, and reverted. It
loses the answer whenever the email link opens somewhere other than the signup
session, and cannot reach the 25% who never verify.

**Make `verify-email` issue a session** so the answer could be written there.
Rejected: clicking an emailed link would log you in, which is a real
authentication decision and far too large a change to make in service of an
analytics question.

**Optional rather than mandatory.** Rejected after the dismissible version shipped
briefly: dismissal was permanent and simply threw the answer away, which is the
same data loss with extra steps.

## Notes

The gate logic lives in `src/dashboard/acquisitionGate.js` as a tested pure
function rather than inline, because "never ask twice" is invisible in code
review and obvious to an annoyed user.

The failure worth remembering is that the plan's prescription was reasonable and
still wrong, and only manual production testing revealed it. Reading the code
would not have caught it — the flaw was in an assumption about where users open
their email.
