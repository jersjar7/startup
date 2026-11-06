# 0040. A college buys a site licence, and its verified students get the simulation

- **Status:** Accepted
- **Date:** 2026-11-06
- **Affects:** `service/schoolAccess.js` (the rule), `service/db/schoolLicenses.js`, `service/routes/exam.js`, `service/routes/checkout.js` (`/status`), `service/routes/admin.js`, `service/mailer-jobs.js`, `src/exam/ExamGate.jsx`, `src/admin/SchoolLicenses.jsx`

## Context

The owner wants to sell the Exam Simulation to colleges for a yearly fee:
"grant access to the exam simulation to colleges depending on their student
email domain and make sure only verified student emails of those domains can
access the simulation exam."

Until now the only way in was a `purchases` row with `status: 'completed'`
(a comp is the same row at $0). A licence is not a sale, so a row per student
would put licence students into every sales count and revenue figure
(`collectedSales.js`, `scripts/baseline-report.js`, the admin dashboard).

## Decision

**A licence is its own record.** `schoolLicenses` holds the school name, the
email domains, `startsAt`/`endsAt`, a seat cap, the contact and notes. Ending a
licence early sets `endedAt`; nothing is deleted, so the history of what a
school bought stays.

**One rule decides access** (`resolveSimAccess` in `service/schoolAccess.js`
with its database half in `service/db/schoolLicenses.js`). A student has the
simulation when they bought it (`hasPurchased`, unchanged) OR they hold a
seat on an active licence for one of their verified school emails. Every place
that gated on `hasPurchased` for the simulation now asks this rule.
`hasPurchased` stays exactly as it was, so revenue and refunds do not move.

**Verified means proven inbox control, with the flow we already have.**
Two addresses count: the school address confirmed with the emailed 6-digit
code (`studentVerified` + `verifiedStudentEmail`, the student-price flow), and
the account address itself once its verification link was clicked
(`emailVerified`). Both are the same proof `qualifiesForStudent` accepts for
the student price. A typed address never counts.

**Domains match exactly.** The domain after the `@`, lowercased, must equal one
the licence lists. `student.byu.edu` matches only if the licence lists it, so
an admin decides which subdomains are the school's; `byu.edu.evil.com` and
`evilbyu.edu` never match. Licence domains must be academic (`.edu`,
`.edu.xx`, `.ac.xx`) because the code flow only mails academic addresses.

**Seats are claimed on first use and never re-counted.** The first time a
verified student opens the simulation, a `schoolLicenseClaims` row is written
(unique per licence and account) and the licence's `seatsUsed` counter goes up
only if it is under the cap. That conditional increment is what stops two
students taking the last seat at once. A student who already holds a seat keeps
it when the cap is lowered or reached. When it is full, a new student is told to
contact their department, and raising the cap lets them in.

**A licence that ends does not end an exam.** An attempt records how it was
started (`accessVia: 'school'`). A student whose licence has ended can still
resume, autosave and submit an attempt that is `in_progress` and was started
under a licence, and an expired one is still graded (EXAM-SIMULATION.md,
invariant 6). They cannot start a new one. Purchases keep today's behaviour.

**Account deletion** removes the student's claim but keeps the seat counted:
the school paid for that seat and the counter does not go down. **An email
change** needs nothing: claims are keyed by account id like purchases, and the
rule re-reads the student's current verified addresses on every check.

## Consequences

- Licence students never appear in sales, revenue or ARPPU, by construction.
- They also stop being pitched the simulation in the weekly digest and the
  countdown emails, because those now ask the same rule (without claiming a
  seat).
- A seat is held for the licence's life even if the student never sits an
  exam. That is the stable count the owner asked for, and it is what a school
  can be shown.
- The check runs on every simulation request. It is one indexed query for
  active licences on the student's domains, which is cheap at our size.

## Alternatives considered

- **A comp purchase row per licence student.** Rejected: every revenue surface
  would need a third flag, and ending a licence would mean finding and
  revoking hundreds of rows.
- **Counting claims with `countDocuments` at check time.** Rejected: two
  students could both see 499 of 500 and both get in.
- **Suffix matching on domains** (anything ending in `.byu.edu`). Rejected:
  schools hand out subdomains to alumni and staff; the owner chooses each one.
- **A new verification flow for school access.** Rejected: the student code
  flow already proves inbox control and students already know it.
