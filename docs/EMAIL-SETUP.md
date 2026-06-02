# Email Setup (Resend) — Required for verification, password reset & student discount

## The problem (root cause)

Transactional email **does not reach real users** because no sending domain is
verified in Resend. `RESEND_FROM_EMAIL` is set to `onboarding@resend.dev`, which
is Resend's shared test sender — it **only** delivers to the Resend account
owner's own address (`jersondevs@gmail.com`). Every other recipient is rejected
with `403 domain is not verified`. The app now logs this loudly at startup and
surfaces send failures instead of swallowing them.

This blocks three things until fixed:
1. Email verification (signup `verify-email`).
2. Password reset.
3. **Student-discount verification** — the new anti-fraud flow emails a 6-digit
   code to the `.edu` address, so the discount can't be claimed until email works.

## The fix (~5 minutes, needs the Resend dashboard + GoDaddy DNS)

DNS for `fe4raccoons.com` is at **GoDaddy** (nameservers `*.domaincontrol.com`).

1. **Resend → Domains → Add Domain** → enter `fe4raccoons.com` (or a subdomain
   like `mail.fe4raccoons.com`). Resend shows DNS records (a DKIM `TXT`/`CNAME`,
   an SPF `TXT`, and a `MX` for the bounce subdomain).
2. **GoDaddy → fe4raccoons.com → DNS** → add exactly those records.
3. Back in Resend, click **Verify** (DNS can take a few minutes to propagate).
4. Set the sender in prod env and restart:
   ```bash
   ssh -i secrets/jerson-cs260-key.pem ubuntu@fe4raccoons.com
   # edit /home/ubuntu/services/startup/.env →  RESEND_FROM_EMAIL=noreply@fe4raccoons.com
   bash -ilc "pm2 restart startup --update-env"
   ```
   (The API key is currently a **send-only restricted key**. That's fine for
   sending. Creating/verifying the domain is a dashboard action.)

## Verify it works (after the above)

From the admin Analytics account, or via curl with the admin cookie:

```bash
# Config check — should show your domain, usingTestSender:false
curl -s --cookie "token=<admin token>" https://fe4raccoons.com/api/admin/email-status

# Send a real test email to any address and read the result:
curl -s --cookie "token=<admin token>" -X POST \
  -H 'Content-Type: application/json' -d '{"to":"you@example.com"}' \
  https://fe4raccoons.com/api/admin/email-test
# -> { ok: true, id: "..." }   (ok:false returns the exact Resend error)
```

Then do an end-to-end check: sign up a fresh account and confirm the verification
email arrives; on the Exam page, run the student `.edu` flow and confirm the code
arrives.

## Relevant code

- `service/email.js` — sender config, branded templates, `sendTestEmail`,
  `getEmailConfig`. Honors `RESEND_FROM_EMAIL` and `APP_URL`.
- `service/routes/admin.js` — `GET /api/admin/email-status`, `POST /api/admin/email-test`.
- `service/routes/checkout.js` — student `start`/`confirm` code flow.
