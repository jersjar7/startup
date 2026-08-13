// Screenshots a signed-in route so authed UI changes can be verified visually.
//
// Authentication is a SESSION minted straight into the database for the QA
// account, not a password typed into the login form. No credential is stored
// anywhere, the run cannot break because a password changed, and the session is
// revoked again at the end so nothing is left behind. See scripts/qa-session.mjs.
//
// Usage:
//   node --env-file=service/.env scripts/verify-ui.mjs [route] [outPath] [full]
import pw from 'playwright';
import { mintQaSession, revokeToken } from './qa-session.mjs';

const { chromium } = pw;
const route = process.argv[2] || '/dashboard';
const out = process.argv[3] || '/tmp/qa-shot.png';
const full = process.argv[4] === 'full';
const SITE = 'https://fe4raccoons.com';

const { token, email } = await mintQaSession();
console.log(`signed in as ${email} via a temporary session`);

const b = await chromium.launch();
try {
  const ctx = await b.newContext({ viewport: { width: 1300, height: 1700 }, deviceScaleFactor: 1 });

  // Same attributes the server sets the cookie with (service/middleware/auth.js:
  // name 'token', secure, httpOnly, sameSite strict, path '/'). Anything else
  // and the browser silently refuses to send it back.
  await ctx.addCookies([{
    name: 'token',
    value: token,
    domain: new URL(SITE).hostname,
    path: '/',
    httpOnly: true,
    secure: true,
    sameSite: 'Strict',
  }]);

  const p = await ctx.newPage();
  await p.goto(SITE + route, { waitUntil: 'networkidle' });
  await p.waitForTimeout(1800);

  // A silent redirect to /login means the cookie was rejected — say so loudly
  // rather than saving a screenshot of the logged-out page and calling it done.
  if (/\/login/.test(p.url())) {
    throw new Error(`Not authenticated — landed on ${p.url()}. The session cookie was refused.`);
  }

  await p.screenshot({ path: out, fullPage: full });
  console.log('final url:', p.url());
  console.log('saved    :', out);
} finally {
  await b.close();
  // Always clean up, even if the screenshot failed.
  await revokeToken(token);
}
