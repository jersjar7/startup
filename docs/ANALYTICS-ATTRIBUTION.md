# Analytics and attribution — where the numbers come from

Two separate systems, measuring two different layers. Confusing them produces
wrong conclusions, which has already happened once.

| | Layer | Source of truth |
|---|---|---|
| **Plausible** | pre-signup: visitors, traffic sources, landing pages | plausible.io dashboard + weekly email |
| **`acquisition` on the user doc** | post-signup: which channel produced an account | MongoDB, via `scripts/baseline-report.js` |

The scorecard needs both: 50 signups from 500 visitors and 50 from 5,000 are
completely different situations, and a signup-only view shows both as "50".

---

## Plausible

Installed as a script tag in `index.html` `<head>`, deliberately **not** in the
JS bundle, so it is present in the head of every prerendered public page too
(`scripts/prerender.mjs` snapshots `documentElement.outerHTML`).

**CSP:** helmet's defaults are `script-src 'self'`, which blocked both the tag
and its event beacon (`connect-src` falls back to `default-src`). `service/index.js`
now allows `https://plausible.io` on exactly those two directives. The init
snippet lives in `public/plausible-init.js` so no `'unsafe-inline'` is needed.

**Weekly + monthly email reports** go to the owner's Gmail, which is how the
Weekly Scorecard gets its visitor numbers — no manual export. The Stats API
requires Plausible's Business plan; the Growth plan the budget allows does not
include it, and upgrading is not worth it for two numbers a week.

**Excluding your own traffic:** run `localStorage.plausible_ignore = "true"` in
the console on fe4raccoons.com. Per browser, per device.

---

## Signup attribution

`user.acquisition` can hold three independent signals. **Reading only one badly
misleads** — an early baseline read only `source`, reported 10% attribution, and
named the wrong lead channel.

| Field | Coverage | Set by |
|---|---|---|
| `referrer`, `landingPath` | widest | captured automatically on first touch (`src/app.jsx`) |
| `utmSource/Medium/Campaign` | tagged links only | same capture, from the query string |
| `source`, `answeredAt` | the survey | the chip prompt |

Capture pipeline: `src/app.jsx` writes `localStorage.fe4r_acq` → `src/login/login.jsx`
sends it at register → `service/routes/auth.js` persists it.

`scripts/baseline-report.js` prefers **utm > referrer > survey**, and also
prints raw referrer hosts and first-touch landing paths.

### The survey: asked once, never twice

Rule: **ask until resolved, never after.**

- Asked at **registration**, right after account creation, because
  `/api/auth/create` already sets the auth cookie so the answer is written
  server-side immediately. Mandatory single tap, 8 fixed options, no free text.
- The dashboard shows a **modal** safety net for anyone still unresolved.
- `resolved` = `acquisition.source` OR `acquisition.dismissedAt`
  (`service/acquisition.js`). **Server-side deliberately**: a localStorage flag
  is per-device, so the same person would be re-asked on their phone.
- Gate logic: `src/dashboard/acquisitionGate.js::shouldAskSource`, unit tested.
- The chip ids and `ACQ_SOURCES` in `service/routes/auth.js` **must stay in
  sync**, or the POST 400s and the answer is silently lost.

**Do not move the ask to the email-verification screen.** It was tried and
reverted: `verify-email` issues no session, so the answer had to be parked in
localStorage and flushed later, and that link routinely opens in a different
browser or profile. Manual production testing lost the answer outright.
Verification also only reaches the ~75% who verify.

### Bio links

All four social bios carry
`?utm_source=<platform>&utm_medium=social&utm_campaign=bio`. TikTok required a
Business account (EIN verification). Keep the bare domain **out** of bio text:
people type it and arrive untagged, which cancels out the tracked link.

---

## Reading the numbers honestly

- **Search is fully instrumented. TikTok, Instagram and Reddit are not** — they
  strip referrers or arrive in-app. They are *unmeasured*, not *proven small*.
  Never rank a measured channel against an unmeasured one.
- The unattributed bucket contains both social traffic and referrer-stripped
  search traffic. It cannot be apportioned.
- **Exam timing:** `purchases.daysUntilExam` is frozen at checkout
  (`service/routes/checkout.js`) because users edit their exam date afterwards.
  `examDateAtPurchase` is stored alongside it so the figure stays auditable. The
  same timing is logged on `checkout_started`, so **abandoned** checkouts carry
  it too — a purchases-only field can never tell you whether buyers close to
  their exam convert better.
- Exam dates are validated to a **rolling one-year window** either side of today
  (`service/profile.js::normalizeExamDate`, bounds mirrored in
  `src/data/examDateBounds.js`). Two users had entered 2028 dates, producing a
  739-day outlier that made timing data unusable.
