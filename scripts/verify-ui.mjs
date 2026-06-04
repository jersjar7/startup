// Logs in as the QA account (secrets/qa-login.json) and screenshots an authed
// route, so authed UI changes can be visually verified. Creds are read locally
// and never printed. Usage: node scripts/verify-ui.mjs [route] [outPath] [full]
import pw from 'playwright';
import fs from 'node:fs';

const { chromium } = pw;
const { email, password } = JSON.parse(fs.readFileSync('secrets/qa-login.json', 'utf8'));
const route = process.argv[2] || '/dashboard';
const out = process.argv[3] || '/tmp/qa-shot.png';
const full = process.argv[4] === 'full';
const SITE = 'https://fe4raccoons.com';

const b = await chromium.launch();
const ctx = await b.newContext({ viewport: { width: 1300, height: 1700 }, deviceScaleFactor: 1 });
const p = await ctx.newPage();
await p.goto(`${SITE}/login`, { waitUntil: 'domcontentloaded' });
await p.getByPlaceholder('you@example.com').first().fill(email);
await p.getByPlaceholder('8+ characters').fill(password);
await p.getByRole('button', { name: 'Login' }).click();
await p.waitForURL(/\/dashboard/, { timeout: 20000 }).catch(() => {});
if (route !== '/dashboard') await p.goto(SITE + route, { waitUntil: 'networkidle' });
await p.waitForTimeout(1800);
await p.screenshot({ path: out, fullPage: full });
console.log('final url:', p.url());
await b.close();
