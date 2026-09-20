// The proof half of the phone <-> website sync audit (docs/mobile/sync-audit.md).
//
// Plays rounds the way the phone does, then a session the way the website
// does, and checks after each step that everything the OTHER surface reads
// moved the way the contract says. Runs against the live server on the QA
// account (secrets/qa-login.json), never the owner's.
//
//   node scripts/auditSync.mjs [https://fe4raccoons.com] [--reset]
//
// The checks assume a FRESH account (they compare to the model from zero).
// --reset deletes the QA account and creates it again with the same
// credentials before starting, so the script can be run any number of times.
// Exit code 1 when a check fails. Prints a table; writes the raw snapshots
// to /tmp/audit-sync.json for the report.
import { readFileSync, writeFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';

const args = process.argv.slice(2);
const BASE = args.find((a) => !a.startsWith('--')) || 'https://fe4raccoons.com';
const RESET = args.includes('--reset');
const creds = JSON.parse(readFileSync(new URL('../secrets/qa-login.json', import.meta.url)));
const content = JSON.parse(readFileSync(new URL('../service/content.json', import.meta.url)));

const STUDY_TAU = 25;
const PHONE_CEILING = 60; // what the server enforces today (ADR 0012); the owner has chosen 50
const PHONE_CAP_EVIDENCE = -STUDY_TAU * Math.log(1 - PHONE_CEILING / 100);
const model = (desk, phone) =>
  Math.round(100 * (1 - Math.exp(-(0.4 * desk + Math.min(0.4 * phone, PHONE_CAP_EVIDENCE)) / STUDY_TAU)));

let token = null;
async function api(method, path, body) {
  const r = await fetch(BASE + '/api' + path, {
    method,
    headers: { 'Content-Type': 'application/json', 'x-client': 'mobile', ...(token ? { Authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await r.text();
  let data; try { data = JSON.parse(text); } catch { data = text; }
  if (!r.ok) throw new Error(`${method} ${path} -> ${r.status} ${typeof data === 'string' ? data.slice(0, 120) : data.msg}`);
  return data;
}

const pad = (n) => String(n).padStart(2, '0');
const localDay = (d = new Date()) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
const utcDay = (d = new Date()) => d.toISOString().slice(0, 10);

async function snapshot(label) {
  const [me, mastery, days, reviewCount, today, changes] = await Promise.all([
    api('GET', '/auth/me'),
    api('GET', '/diagnostic/mastery'),
    api('GET', '/sync/study-days'),
    api('GET', '/review/count'),
    api('GET', `/sync/today?date=${localDay()}`),
    api('GET', '/sync/changes'),
  ]);
  const math = mastery.chapterMastery?.mathematics || {};
  return {
    label,
    totalXp: me.totalXp, currentStreak: me.currentStreak, badges: (me.badges || []).length,
    problemsAnswered: me.problemsAnswered,
    mathTotal: math.totalMastery ?? 0, mathStudy: math.studyScore ?? 0, mathDiag: math.diagnosticScore ?? 0,
    studyDays: days.days, dayCount: days.count,
    dueReviews: reviewCount.count ?? reviewCount.due ?? reviewCount,
    phoneCardsToday: today.cards, lastSync: today.lastSync,
    eventsOnServer: changes.events.length,
  };
}

const checks = [];
const check = (name, ok, detail) => { checks.push({ name, ok, detail }); };

// ---- sign in ---------------------------------------------------------------
async function signIn() {
  const login = await api('POST', '/auth/login', { email: creds.email, password: creds.password });
  token = login.token;
  if (!token) throw new Error('no token from login');
}
if (RESET) {
  // Start from nothing: the account is the QA account and exists to be reset.
  try {
    await signIn();
    await api('DELETE', '/auth/account', { password: creds.password, confirmation: 'DELETE' });
  } catch (e) {
    if (!String(e.message).includes('401')) throw e;
  }
  token = null;
  await api('POST', '/auth/create', { email: creds.email, password: creds.password });
}
await signIn();
const s0 = await snapshot('start');

// ---- phone: one game, eight rounds, all on one website problem -------------
// Perpendicular Flip is authored from math-slq-q2 for all eight rounds, exactly
// as the app ships it.
const phoneRound = (itemId, r) => ({
  eventId: randomUUID(), itemId, chapterId: 'mathematics', grade: 'gotIt', source: 'ios',
  ts: Date.now() - (8 - r) * 1000, localDate: localDay(),
});
const batchA = { events: Array.from({ length: 8 }, (_, r) => phoneRound('math-slq-q2', r)), device: 'audit' };
const pushA = await api('POST', '/sync/events', batchA);
const s1 = await snapshot('after one phone game');
check('phone push accepted 8 new events', pushA.accepted === 8, JSON.stringify(pushA));
check('one problem of phone evidence moves Mathematics to the model value',
  s1.mathStudy === model(0, 1) && s1.mathTotal === s1.mathStudy, `study ${s1.mathStudy}, model ${model(0, 1)}`);
check('phone XP: 8 gotIt = 40, under the 60 daily cap', s1.totalXp - s0.totalXp === 40, `+${s1.totalXp - s0.totalXp}`);
check('a study day ticked once and today (local) is in the list',
  s1.dayCount === s0.dayCount + 1 && s1.studyDays.includes(localDay()), `count ${s0.dayCount} -> ${s1.dayCount}`);
check('the website sees the phone work for today', s1.phoneCardsToday === 8 && s1.lastSync?.device === 'audit', JSON.stringify({ cards: s1.phoneCardsToday, lastSync: s1.lastSync }));
check('badges: none from the phone path (expected gap)', s1.badges === s0.badges, `${s0.badges} -> ${s1.badges}`);

// ---- phone: a retry of the same batch must change nothing -----------------
const pushA2 = await api('POST', '/sync/events', batchA);
const s2 = await snapshot('after retry');
check('a retried batch is all duplicates', pushA2.accepted === 0 && pushA2.duplicates === 8, JSON.stringify(pushA2));
check('a retry moves nothing', s2.totalXp === s1.totalXp && s2.dayCount === s1.dayCount && s2.mathStudy === s1.mathStudy, '');

// ---- phone: three more games on four more distinct problems ---------------
const batchB = { events: ['math-slq-q1', 'math-slq-q3', 'math-log-q1', 'math-log-q2'].map((id, i) => phoneRound(id, i)), device: 'audit' };
await api('POST', '/sync/events', batchB);
const s3 = await snapshot('after four more problems on the phone');
check('five phone-only problems -> the model value', s3.mathStudy === model(0, 5), `study ${s3.mathStudy}, model ${model(0, 5)}`);
check('phone XP capped per local day at 60', s3.totalXp - s0.totalXp === 60, `+${s3.totalXp - s0.totalXp} total from 12 gotIt (=60 uncapped, cap 60)`);
check('still one study day', s3.dayCount === s1.dayCount, `${s3.dayCount}`);

// ---- website: a chapter practice session on five OTHER problems ------------
const phoneIds = new Set(['math-slq-q1', 'math-slq-q2', 'math-slq-q3', 'math-log-q1', 'math-log-q2']);
const idx = content.problemIndex;
const mathIds = Object.entries(idx).filter(([, m]) => (m.chapterId || m.topicId) === 'mathematics').map(([id]) => id)
  .filter((id) => !phoneIds.has(id)).slice(0, 5);
const session = { topicId: 'mathematics', answers: mathIds.map((problemId) => ({ problemId, isCorrect: true })), localDate: localDay(), durationSeconds: 120 };
await api('POST', '/sessions', session);
const s4 = await snapshot('after one website session');
check('desk evidence adds in full: 5 desk + 5 phone -> the model value', s4.mathStudy === model(5, 5), `study ${s4.mathStudy}, model ${model(5, 5)}`);
check('website XP: 5 correct + session bonus = 75', s4.totalXp - s3.totalXp === 75, `+${s4.totalXp - s3.totalXp}`);
const sameDay = utcDay() === localDay();
check(sameDay ? 'same UTC and local day: the study day did not tick twice' : 'UTC day differs from local day: a second day was ticked for one evening (the two-clock gap)',
  sameDay ? s4.dayCount === s3.dayCount : s4.dayCount === s3.dayCount + 1, `${s3.dayCount} -> ${s4.dayCount}; utc ${utcDay()} local ${localDay()}`);
// Badges are only evaluated on the web paths, so the web session also pays
// out what the phone XP earned earlier (xp-100 here): a catch-up, not a bug in
// the count, but the phone never shows a badge the moment it is earned.
check('badges: awarded on the web path, catching up on phone XP', s4.badges > s3.badges, `${s3.badges} -> ${s4.badges}`);
check('problems answered counts both surfaces', s4.problemsAnswered === 10, `${s4.problemsAnswered}`);

// ---- phone re-answers a desk problem: stays desk, no double count ----------
await api('POST', '/sync/events', { events: [phoneRound(mathIds[0], 0)], device: 'audit' });
const s5 = await snapshot('after the phone re-answers a desk problem');
check('a desk problem answered on the phone stays desk evidence', s5.mathStudy === model(5, 5), `study ${s5.mathStudy}`);
check('problems answered is still 10 distinct', s5.problemsAnswered === 10, `${s5.problemsAnswered}`);
check(sameDay ? 'same day: no extra tick from the late phone round' : 'the late phone round ticked a THIRD day for one evening (the two-clock gap, both directions)',
  sameDay ? s5.dayCount === s4.dayCount : s5.dayCount === s4.dayCount + 1, `${s4.dayCount} -> ${s5.dayCount}`);

// ---- the phone could rebuild itself from the server ------------------------
check('the event log holds every round from both surfaces', s5.eventsOnServer === s0.eventsOnServer + 8 + 4 + 5 + 1, `${s0.eventsOnServer} -> ${s5.eventsOnServer}`);

// ---- report ---------------------------------------------------------------
const snaps = [s0, s1, s2, s3, s4, s5];
console.log('\nsnapshots');
for (const k of ['totalXp', 'currentStreak', 'dayCount', 'badges', 'problemsAnswered', 'mathStudy', 'mathTotal', 'dueReviews', 'phoneCardsToday', 'eventsOnServer']) {
  console.log(`  ${k.padEnd(18)} ${snaps.map((s) => String(s[k]).padStart(6)).join('')}`);
}
console.log(`  ${'labels'.padEnd(18)} ${snaps.map((s, i) => `s${i}`.padStart(6)).join('')}`);
console.log('\nchecks');
let failed = 0;
for (const c of checks) {
  if (!c.ok) failed++;
  console.log(`  ${c.ok ? 'OK  ' : 'FAIL'} ${c.name}${c.detail ? `  (${c.detail})` : ''}`);
}
writeFileSync('/tmp/audit-sync.json', JSON.stringify({ base: BASE, ranAt: new Date().toISOString(), snapshots: snaps, checks }, null, 2));
console.log(`\n${checks.length - failed} of ${checks.length} checks passed; snapshots in /tmp/audit-sync.json`);
process.exitCode = failed ? 1 : 0;
