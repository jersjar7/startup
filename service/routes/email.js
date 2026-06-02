const express = require('express');
const { userCollection } = require('../db/connection.js');

const router = express.Router();

function page({ ok }) {
  const C = { ember: '#E8683A', charcoal: '#2C2C2C', cream: '#FFF9F0', body: '#5C584F', mute: '#A09C93' };
  const appUrl = process.env.APP_URL || 'https://fe4raccoons.com';
  const heading = ok ? "You're unsubscribed" : 'Link not found';
  const msg = ok
    ? "You won't get welcome, weekly, or re-engagement emails anymore. You'll still get important account emails (verification, password reset). Changed your mind? Email support and we'll turn them back on."
    : "That unsubscribe link wasn't recognized — it may already have been used. If you keep getting emails you don't want, contact support.";
  return `<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>${heading} — FE for Raccoons</title></head>
<body style="margin:0;background:${C.cream};font-family:'Inter','Helvetica Neue',Arial,sans-serif;">
<div style="max-width:480px;margin:64px auto;padding:0 20px;text-align:center;">
  <div style="font-family:'DM Sans',Arial,sans-serif;font-weight:700;font-size:26px;letter-spacing:-1px;color:${C.charcoal};margin-bottom:28px;">FE<span style="color:${C.ember};">4</span> <span style="font-size:12px;letter-spacing:4px;">RACCOONS</span></div>
  <div style="background:#fff;border-radius:16px;border-top:4px solid ${C.ember};box-shadow:0 6px 22px rgba(44,44,44,0.07);padding:36px 32px;">
    <h1 style="font-family:'DM Sans',Arial,sans-serif;font-size:22px;color:${C.charcoal};margin:0 0 14px;">${heading}</h1>
    <p style="font-size:15px;line-height:1.6;color:${C.body};margin:0 0 24px;">${msg}</p>
    <a href="${appUrl}" style="display:inline-block;background:${C.ember};color:#fff;font-family:'DM Sans',Arial,sans-serif;font-weight:600;font-size:15px;padding:12px 28px;border-radius:10px;text-decoration:none;">Back to FE for Raccoons</a>
  </div>
</div></body></html>`;
}

// GET /api/email/unsubscribe/:token — one-click opt-out from lifecycle emails.
// (GET so email "unsubscribe" links and Gmail's List-Unsubscribe both work.)
router.get('/unsubscribe/:token', async (req, res) => {
  let ok = false;
  try {
    const r = await userCollection.updateOne(
      { unsubToken: req.params.token },
      { $set: { lifecycleOptOut: true, lifecycleOptOutAt: new Date() } },
    );
    ok = r.matchedCount > 0;
  } catch (e) {
    console.error('[email/unsubscribe] failed:', e.message);
  }
  res.status(ok ? 200 : 404).type('html').send(page({ ok }));
});

// POST — Gmail one-click List-Unsubscribe-Post sends here.
router.post('/unsubscribe/:token', async (req, res) => {
  try {
    await userCollection.updateOne(
      { unsubToken: req.params.token },
      { $set: { lifecycleOptOut: true, lifecycleOptOutAt: new Date() } },
    );
  } catch (e) {
    console.error('[email/unsubscribe] failed:', e.message);
  }
  res.status(200).end();
});

module.exports = router;
