#!/usr/bin/env node
// End-to-end check of school site licences (ADR 0040) through the real UI, as
// real users would use it, against a THROWAWAY in-memory MongoDB.
//
// What runs: an in-memory mongod, the real API (service/index.js) with email
// captured to a file instead of sent, and the Vite dev server. Playwright then
// drives four kinds of people: the owner creating licences on /admin, a
// student at a licensed school verifying their school email, a student at a
// school with no licence, and an unverified student. It also races two
// students for a last seat, ends a licence mid-exam, and deletes an account.
//
// It never reads service/.env, never sets the production DB_* variables, and
// refuses to start if they are present. Stripe is given a dummy test key and
// is never called (nobody presses Buy).
//
// Setup, once (mongodb-memory-server is not a dependency of this repo):
//   mkdir -p /tmp/mms && cd /tmp/mms && npm init -y && npm i mongodb-memory-server@10
// Run from the repo root:
//   MMS_DIR=/tmp/mms SHOTS_DIR=/tmp/school-shots node scripts/e2e/school-access.mjs
import { createRequire } from 'node:module';
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import pw from 'playwright';

const ROOT = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const SERVICE = path.join(ROOT, 'service');
const requireSvc = createRequire(path.join(SERVICE, 'package.json'));
const { MongoClient } = requireSvc('mongodb');
const bcrypt = requireSvc('bcryptjs');

for (const k of ['DB_USERNAME', 'DB_PASSWORD', 'DB_HOSTNAME']) {
  if (process.env[k]) throw new Error(`${k} is set. This run must never see production credentials.`);
}
if (fs.existsSync(path.join(SERVICE, '.env'))) {
  throw new Error('service/.env exists here; the API would load it. Run from a checkout without it.');
}
if (!process.env.MMS_DIR) throw new Error('Set MMS_DIR to a folder with mongodb-memory-server installed.');
const { MongoMemoryServer } = createRequire(path.join(process.env.MMS_DIR, 'package.json'))('mongodb-memory-server');

const SHOTS = process.env.SHOTS_DIR || path.join(os.tmpdir(), 'school-shots');
fs.mkdirSync(SHOTS, { recursive: true });
const API_PORT = 4000;
const WEB_PORT = Number(process.env.WEB_PORT || 5288);
const API = `http://localhost:${API_PORT}`;
const WEB = `http://localhost:${WEB_PORT}`;
const MAIL = path.join(os.tmpdir(), `school-e2e-mail-${process.pid}.jsonl`);
fs.writeFileSync(MAIL, '');

const results = [];
function check(name, ok, detail = '') {
  results.push({ name, ok: !!ok, detail });
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail ? `  (${detail})` : ''}`);
}

const children = [];
function start(cmd, args, opts, readyRe) {
  return new Promise((resolve, reject) => {
    const p = spawn(cmd, args, { ...opts, stdio: ['ignore', 'pipe', 'pipe'] });
    children.push(p);
    let log = '';
    const onData = (d) => {
      log += d.toString();
      if (readyRe.test(log)) resolve({ p, log: () => log });
    };
    p.stdout.on('data', onData);
    p.stderr.on('data', onData);
    p.on('exit', (code) => reject(new Error(`${cmd} exited ${code}\n${log}`)));
    setTimeout(() => reject(new Error(`${cmd} not ready in 60s\n${log}`)), 60000);
  });
}

const mongod = await MongoMemoryServer.create();
const DB_URL = mongod.getUri();
if (!/^mongodb:\/\/127\.0\.0\.1:/.test(DB_URL)) throw new Error(`Unexpected DB URL ${DB_URL}`);
const mongo = new MongoClient(DB_URL);
await mongo.connect();
const db = mongo.db('fe4raccoons');

let browser;
try {
  // The API, with only what it needs in its environment.
  const api = await start('node', ['-r', path.join(ROOT, 'scripts/e2e/mail-capture.cjs'), 'index.js', String(API_PORT)], {
    cwd: SERVICE,
    env: {
      PATH: process.env.PATH,
      HOME: process.env.HOME,
      DB_URL,
      MAIL_CAPTURE_FILE: MAIL,
      STRIPE_SECRET_KEY: 'sk_test_e2e_dummy_never_called',
      RESEND_API_KEY: 're_e2e_captured',
      RESEND_FROM_EMAIL: 'noreply@example.test',
      LIFECYCLE_EMAILS_DISABLED: '1',
      LEAGUES_DISABLED: '1',
    },
  }, /Listening on port/);
  await start('npx', ['vite', '--port', String(WEB_PORT), '--strictPort'], { cwd: ROOT, env: process.env }, /ready in|Local:/);

  // ── People ────────────────────────────────────────────────────────────────
  const PASSWORD = 'e2e-password-123';
  const hash = await bcrypt.hash(PASSWORD, 4);
  async function person(email, fields = {}) {
    const res = await db.collection('users').insertOne({
      email, password: hash, createdAt: new Date(), emailVerified: true, verifiedAt: new Date(),
      firstName: email.split('@')[0].replace(/^\w/, (c) => c.toUpperCase()), ...fields,
    });
    const token = crypto.randomUUID();
    await db.collection('sessions').insertOne({ token, email, client: 'web', createdAt: new Date(), lastSeen: new Date() });
    return { email, token, id: res.insertedId.toString() };
  }
  const admin = await person('admin@oqupa.com');
  // A student at a licensed school who signed up with the school address and
  // has not verified it yet.
  const sam = await person('sam@byu.edu', { emailVerified: false, verifiedAt: null, school: { name: 'Brigham Young University' } });
  // An unverified student at the same school who gets the code wrong.
  const kim = await person('kim@byu.edu', { emailVerified: false, verifiedAt: null });
  // A student at a school with no licence, school address verified by code.
  const lee = await person('lee@gmail.com', { studentVerified: true, verifiedStudentEmail: 'lee@utah.edu', studentVerifiedAt: new Date() });
  // A student who has verified nothing and whose school we do not know.
  const max = await person('max@gmail.com');
  // Two students at a school whose licence has one seat.
  const first = await person('first@usu.edu');
  const pat = await person('pat@gmail.com', { studentVerified: true, verifiedStudentEmail: 'pat@usu.edu', studentVerifiedAt: new Date() });

  const apiFetch = (who, url, opts = {}) => fetch(API + url, {
    ...opts,
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${who.token}`, ...(opts.headers || {}) },
  });

  browser = await pw.chromium.launch();
  async function pageFor(who) {
    const ctx = await browser.newContext({ viewport: { width: 1280, height: 900 }, deviceScaleFactor: 1 });
    await ctx.addCookies([{ name: 'token', value: who.token, domain: 'localhost', path: '/', httpOnly: true, secure: false, sameSite: 'Strict' }]);
    const p = await ctx.newPage();
    p.on('pageerror', (e) => console.log(`[pageerror ${who.email}]`, e.message));
    return p;
  }
  const shots = [];
  async function shoot(p, name) {
    for (const [w, label] of [[1280, 'desktop'], [390, 'phone']]) {
      await p.setViewportSize({ width: w, height: w === 390 ? 844 : 900 });
      await p.waitForTimeout(350);
      // Keep an open admin tab in view in the sideways-scrolling tab row.
      await p.evaluate(() => document.querySelector('.admin-tab[aria-selected="true"]')
        ?.scrollIntoView({ block: 'nearest', inline: 'nearest' }));
      const file = path.join(SHOTS, `${name}-${label}.png`);
      await p.screenshot({ path: file, fullPage: true });
      shots.push(file);
    }
    await p.setViewportSize({ width: 1280, height: 900 });
  }
  const lastCodeFor = (to) => {
    const lines = fs.readFileSync(MAIL, 'utf8').trim().split('\n').filter(Boolean).map((l) => JSON.parse(l));
    const mail = lines.reverse().find((m) => m.to === to);
    const m = mail && (mail.html + mail.text).match(/\b(\d{6})\b/);
    return m ? m[1] : null;
  };

  // ── 1. The owner creates licences on /admin ───────────────────────────────
  const ap = await pageFor(admin);
  await ap.goto(`${WEB}/admin`, { waitUntil: 'networkidle' });
  await ap.getByRole('tab', { name: /Schools/ }).click();
  await ap.getByText('No licences yet').waitFor();
  await shoot(ap, '01-admin-licences-empty');

  await ap.getByRole('button', { name: /New licence/ }).click();
  const form = ap.getByRole('form', { name: 'New licence' });
  await form.getByPlaceholder('Brigham Young University').fill('Brigham Young University');
  await form.getByPlaceholder('byu.edu, student.byu.edu').fill('byu.edu');
  await form.getByRole('spinbutton').fill('500');
  await form.getByPlaceholder('Dr. Ames').fill('Dr. Ames');
  await form.getByPlaceholder('department@byu.edu').fill('civil@byu.edu');
  await form.getByPlaceholder('Invoice, purchase order, renewal terms').fill('Signed 2026-11-06, invoice 1001');
  await shoot(ap, '02-admin-new-licence-form');
  await form.getByRole('button', { name: 'Create licence' }).click();
  await ap.getByRole('article', { name: 'Brigham Young University' }).waitFor();

  // A lookalike domain is refused with the reason.
  await ap.getByRole('button', { name: /New licence/ }).click();
  const bad = ap.getByRole('form', { name: 'New licence' });
  await bad.getByPlaceholder('Brigham Young University').fill('Evil');
  await bad.getByPlaceholder('byu.edu, student.byu.edu').fill('byu.edu.evil.com');
  await bad.getByRole('button', { name: 'Create licence' }).click();
  const refusal = await ap.getByRole('alert').textContent();
  check('admin: a lookalike domain is refused', /not a school domain/.test(refusal), refusal);
  await bad.getByPlaceholder('Brigham Young University').fill('Utah State University');
  await bad.getByPlaceholder('byu.edu, student.byu.edu').fill('usu.edu');
  await bad.getByRole('spinbutton').fill('1');
  await bad.getByRole('button', { name: 'Create licence' }).click();
  await ap.getByRole('article', { name: 'Utah State University' }).waitFor();
  check('admin: two licences stored', (await db.collection('schoolLicenses').countDocuments()) === 2);

  // The only Utah State seat goes to the first student who starts an exam.
  const firstStart = await apiFetch(first, '/api/exam/start', { method: 'POST', body: '{}' });
  check('first@usu.edu takes the only Utah State seat', firstStart.status === 200, `status ${firstStart.status}`);

  // ── 2. A student at a licensed school, not yet verified ───────────────────
  const sp = await pageFor(sam);
  await sp.goto(`${WEB}/exam`, { waitUntil: 'networkidle' });
  await sp.getByRole('heading', { name: 'Your school gives you the exam simulation' }).waitFor();
  check('licensed student: no checkout button on the school gate',
    (await sp.getByRole('button', { name: /Buy the Exam Simulation/ }).count()) === 0);
  const blocked = await apiFetch(sam, '/api/exam/start', { method: 'POST', body: '{}' });
  check('licensed student: cannot start before verifying', blocked.status === 403, `status ${blocked.status}`);
  await shoot(sp, '04-student-licensed-school-gate');

  await sp.getByRole('button', { name: 'Send my code' }).click();
  await sp.getByPlaceholder('123456').waitFor();
  await shoot(sp, '05-student-licensed-code-step');
  const code = lastCodeFor('sam@byu.edu');
  check('licensed student: the code email went to the school address', !!code);
  await sp.getByPlaceholder('123456').fill(code);
  await sp.getByRole('button', { name: 'Verify' }).click();
  await sp.getByText('Given to you by Brigham Young University').waitFor();
  check('licensed student: no seat taken just by opening the page',
    (await db.collection('schoolLicenses').findOne({ domains: 'byu.edu' })).seatsUsed === 0);
  await shoot(sp, '06-student-licensed-in');

  await sp.getByRole('button', { name: /Start New Exam/ }).click();
  await sp.waitForURL(/\/exam\/session/);
  await sp.waitForFunction(() => !document.body.innerText.includes('Preparing your exam'), null, { timeout: 30000 });
  await sp.waitForTimeout(800);
  await shoot(sp, '07-student-licensed-exam-started');
  const byu = await db.collection('schoolLicenses').findOne({ domains: 'byu.edu' });
  check('licensed student: starting the exam took exactly one seat', byu.seatsUsed === 1, `seatsUsed ${byu.seatsUsed}`);
  const samAttempt = await db.collection('examAttempts').findOne({ userId: sam.id });
  check('licensed student: attempt records it came through the school', samAttempt?.accessVia === 'school');
  const notAdmin = await apiFetch(sam, '/api/admin/school-licenses');
  check('a student cannot reach the admin licence endpoints', notAdmin.status === 403, `status ${notAdmin.status}`);

  // ── 3. An unverified student who gets the code wrong ──────────────────────
  const kp = await pageFor(kim);
  await kp.goto(`${WEB}/exam`, { waitUntil: 'networkidle' });
  await kp.getByRole('heading', { name: 'Your school gives you the exam simulation' }).waitFor();
  await kp.getByRole('button', { name: 'Send my code' }).click();
  await kp.getByPlaceholder('123456').fill(lastCodeFor('kim@byu.edu') === '000000' ? '111111' : '000000');
  await kp.getByRole('button', { name: 'Verify' }).click();
  await kp.getByText('Incorrect code').waitFor();
  await shoot(kp, '08-student-unverified-wrong-code');
  const kimStart = await apiFetch(kim, '/api/exam/start', { method: 'POST', body: '{}' });
  check('unverified student: still no simulation', kimStart.status === 403, `status ${kimStart.status}`);

  // ── 4. A verified student at a school with no licence ─────────────────────
  const lp = await pageFor(lee);
  await lp.goto(`${WEB}/exam`, { waitUntil: 'networkidle' });
  await lp.getByRole('button', { name: /Buy the Exam Simulation for \$35/ }).waitFor();
  check('unlicensed student: ordinary page with the student price', true);
  check('unlicensed student: no school line',
    (await lp.getByText(/Your school gives you/).count()) === 0);
  await shoot(lp, '09-student-unlicensed-school');
  const leeStart = await apiFetch(lee, '/api/exam/start', { method: 'POST', body: '{}' });
  check('unlicensed student: no simulation without paying', leeStart.status === 403, `status ${leeStart.status}`);

  const mp = await pageFor(max);
  await mp.goto(`${WEB}/exam`, { waitUntil: 'networkidle' });
  await mp.getByText(/nothing if their school has a licence with us/).waitFor();
  check('student with nothing verified: told a school licence would make it free', true);
  await shoot(mp, '10-student-nothing-verified');

  // ── 5. Seats full ─────────────────────────────────────────────────────────
  const pp = await pageFor(pat);
  await pp.goto(`${WEB}/exam`, { waitUntil: 'networkidle' });
  await pp.getByText('Every seat at Utah State University is taken').waitFor();
  await shoot(pp, '11-student-seats-full');
  const patStart = await apiFetch(pat, '/api/exam/start', { method: 'POST', body: '{}' });
  const patBody = await patStart.json();
  check('seats full: refused with the department message', patStart.status === 403 && /department/i.test(patBody.msg), patBody.msg);

  // ── 6. The owner sees the seats ───────────────────────────────────────────
  await ap.reload({ waitUntil: 'networkidle' });
  await ap.getByRole('tab', { name: /Schools/ }).click();
  await ap.getByRole('meter', { name: '1 of 500 seats used' }).waitFor();
  await shoot(ap, '03-admin-licences-seats');

  // ── 7. The licence ends mid-exam ──────────────────────────────────────────
  ap.once('dialog', (d) => d.accept());
  await ap.getByRole('article', { name: 'Brigham Young University' }).getByRole('button', { name: 'End now' }).click();
  await ap.getByText('Ended early').waitFor();
  await shoot(ap, '12-admin-licence-ended');

  await sp.goto(`${WEB}/exam`, { waitUntil: 'networkidle' });
  await sp.getByRole('button', { name: /Finish my exam/ }).waitFor();
  await shoot(sp, '13-student-licence-ended-finish-exam');
  await sp.getByRole('button', { name: /Finish my exam/ }).click();
  await sp.waitForURL(/\/exam\/session/);
  await sp.waitForFunction(() => !document.body.innerText.includes('Preparing your exam'), null, { timeout: 30000 });
  check('licence ended: the open exam still resumes', /\/exam\/session/.test(sp.url()));
  const resumed = await apiFetch(sam, '/api/exam/start', { method: 'POST', body: '{}' });
  const resumedBody = await resumed.json();
  check('licence ended: resume returns the same stored attempt',
    resumed.status === 200 && resumedBody.attemptId === samAttempt._id.toString() && resumedBody.resumed === true);
  const q = resumedBody.questions[0];
  const saved = await apiFetch(sam, '/api/exam/answers', {
    method: 'PATCH', body: JSON.stringify({ attemptId: resumedBody.attemptId, answers: { [q.id]: q.choices[0].id } }),
  });
  check('licence ended: autosave still works', saved.status === 200, `status ${saved.status}`);
  const submitted = await apiFetch(sam, '/api/exam/submit', {
    method: 'POST', body: JSON.stringify({ attemptId: resumedBody.attemptId, answers: [], timeUsedSeconds: 120 }),
  });
  const submittedBody = await submitted.json();
  check('licence ended: submit grades it and keeps the autosaved answer',
    submitted.status === 200 && submittedBody.totalAttempted === 1, `attempted ${submittedBody.totalAttempted}`);
  const again = await apiFetch(sam, '/api/exam/start', { method: 'POST', body: '{}' });
  check('licence ended: no new exam can start', again.status === 403, `status ${again.status}`);

  // ── 8. Two students race for the last seat (real MongoDB) ─────────────────
  const created = await apiFetch(admin, '/api/admin/school-licenses', {
    method: 'POST',
    body: JSON.stringify({ schoolName: 'Race College', domains: 'race.edu', startsAt: '2026-01-01', endsAt: '2030-01-01', seatCap: 1 }),
  });
  check('admin API: create', created.status === 201, `status ${created.status}`);
  const r1 = await person('one@gmail.com', { studentVerified: true, verifiedStudentEmail: 'one@race.edu' });
  const r2 = await person('two@gmail.com', { studentVerified: true, verifiedStudentEmail: 'two@race.edu' });
  const [s1, s2] = await Promise.all([
    apiFetch(r1, '/api/exam/start', { method: 'POST', body: '{}' }),
    apiFetch(r2, '/api/exam/start', { method: 'POST', body: '{}' }),
  ]);
  const race = await db.collection('schoolLicenses').findOne({ domains: 'race.edu' });
  const raceClaims = await db.collection('schoolLicenseClaims').countDocuments({ licenseId: race._id });
  check('race: exactly one of two students gets the last seat',
    [s1.status, s2.status].sort().join() === '200,403' && race.seatsUsed === 1 && raceClaims === 1,
    `statuses ${s1.status},${s2.status} seatsUsed ${race.seatsUsed} claims ${raceClaims}`);

  // ── 9. Account deletion drops the claim, the seat stays counted ──────────
  const del = await apiFetch(sam, '/api/user/account', {
    method: 'DELETE', body: JSON.stringify({ password: PASSWORD, confirmation: 'DELETE' }),
  });
  const samClaims = await db.collection('schoolLicenseClaims').countDocuments({ userId: sam.id });
  const byuAfter = await db.collection('schoolLicenses').findOne({ domains: 'byu.edu' });
  check('deletion: the student\'s seat claim is gone', del.status === 200 && samClaims === 0, `status ${del.status}`);
  check('deletion: the seat stays counted for the school', byuAfter.seatsUsed === 1);

  // ── 10. None of it is a sale ──────────────────────────────────────────────
  const sales = await db.collection('purchases').countDocuments();
  const flagged = await db.collection('users').countDocuments({ examSimAccess: true });
  check('no purchase rows and no purchase flags from licence access', sales === 0 && flagged === 0, `purchases ${sales}`);
  const mails = fs.readFileSync(MAIL, 'utf8').trim().split('\n').filter(Boolean).length;
  check('every email was captured locally, none sent', mails >= 2, `${mails} captured`);

  fs.writeFileSync(path.join(SHOTS, 'results.json'), JSON.stringify({ results, shots }, null, 2));
  console.log(`\n${results.filter((r) => r.ok).length}/${results.length} checks passed`);
  console.log(`screenshots in ${SHOTS}`);
  if (api.log().includes('[ERROR]')) console.log('\nAPI errors:\n', api.log().split('\n').filter((l) => l.includes('[ERROR]')).join('\n'));
} finally {
  if (browser) await browser.close();
  for (const c of children) { try { c.kill('SIGTERM'); } catch { /* gone */ } }
  await mongo.close();
  await mongod.stop();
  fs.rmSync(MAIL, { force: true });
}
process.exit(results.every((r) => r.ok) ? 0 : 1);
