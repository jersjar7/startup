# Email (Resend) — Configuration & Troubleshooting

**Status: working (verified 2026-06-02).** Transactional email — signup
verification, password reset, and the student-discount code — delivers to real
users from `noreply@fe4raccoons.com`.

## Current setup

- **Provider:** Resend. Account owner: `jersondevs@gmail.com`.
- **Sending domain:** `fe4raccoons.com`, verified in Resend (DKIM + SPF + MX).
  DNS is at **GoDaddy** (nameservers `*.domaincontrol.com`).
- **Prod env** (`/home/ubuntu/services/startup/.env`):
  - `RESEND_FROM_EMAIL=noreply@fe4raccoons.com`
  - `APP_URL=https://fe4raccoons.com`
  - `RESEND_API_KEY` — a **send-only restricted** key (fine for sending; managing
    domains is a dashboard action, not available via this key).
- **Code:** `service/email.js` — branded HTML templates (`ctaEmail`, `codeEmail`),
  honors `RESEND_FROM_EMAIL`/`APP_URL`, surfaces send failures (returns
  `{ok,error}`) and warns loudly at startup if it ever falls back to the
  `onboarding@resend.dev` test sender.

## Test delivery (from the admin account)

```bash
# Config — should show from=noreply@fe4raccoons.com, usingTestSender:false
curl -s --cookie "token=<admin token>" https://fe4raccoons.com/api/admin/email-status

# Send a real test email and read the result:
curl -s --cookie "token=<admin token>" -X POST \
  -H 'Content-Type: application/json' -d '{"to":"you@example.com"}' \
  https://fe4raccoons.com/api/admin/email-test     # -> { ok:true, id:"..." }
```

## Troubleshooting

- **Nobody receives email / `email-status` shows `usingTestSender:true`:**
  `RESEND_FROM_EMAIL` reverted to the test sender (which only reaches the Resend
  account owner). Set it back to `noreply@fe4raccoons.com` and
  `pm2 restart startup --update-env`.
- **`email-test` returns `ok:false` with "domain is not verified":** the Resend
  domain verification lapsed (e.g. DNS changed at GoDaddy). Re-verify at
  resend.com/domains and ensure the DKIM/SPF/MX records still exist in GoDaddy.
- **Emails land in spam:** confirm DMARC; a `_dmarc` TXT record exists at GoDaddy.

## Lifecycle emails (welcome / weekly digest / win-back)

An in-process scheduler (`service/mailer-jobs.js`, started from `index.js`) sends
engagement emails at **8:00am `LIFECYCLE_TZ`** (default `America/New_York`):
- **Welcome** — morning after a user verifies (`verifiedAt`), points to the diagnostic.
- **Weekly digest** — **Sundays**; recap + weakest-chapter focus, with a gentler
  variant for inactive users.
- **Win-back** — one-time, after ~7 days inactive.

All are idempotent (per-user `welcomeSentAt` / `lastWeeklyAt` / `winbackSentAt`),
carry an unsubscribe link + `List-Unsubscribe` headers, and respect
`lifecycleOptOut` (set via `GET/POST /api/email/unsubscribe/:token`).
Transactional emails (verify/reset/student code) are unaffected.

**Kill switch:** set `LIFECYCLE_EMAILS_DISABLED=1` in prod `.env` +
`pm2 restart startup --update-env` to stop all lifecycle sends. Tune timing with
`LIFECYCLE_TZ` / `LIFECYCLE_HOUR`. Pure scheduling logic is in `service/lifecycle.js`.

## Re-verifying a domain from scratch (if ever needed)

1. Resend → Domains → Add Domain → `fe4raccoons.com`.
2. Add the shown DKIM/SPF/MX records in GoDaddy DNS.
3. Click **Verify**, then set `RESEND_FROM_EMAIL` and restart (above).
