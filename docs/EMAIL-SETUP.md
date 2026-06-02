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

## Re-verifying a domain from scratch (if ever needed)

1. Resend → Domains → Add Domain → `fe4raccoons.com`.
2. Add the shown DKIM/SPF/MX records in GoDaddy DNS.
3. Click **Verify**, then set `RESEND_FROM_EMAIL` and restart (above).
