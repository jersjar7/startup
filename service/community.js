// The dashboard's live feed (docs/dashboard.md): what other students are
// doing, worked out from the event log and the Daily results, never stored.
// This module is pure; service/routes/community.js reads the rows and hands
// them in.
//
// One row per student, the most telling thing they did in the last day:
//   working    answered something in the last LIVE_MS ("is working through Trusses")
//   practiced  their latest study session ("practiced Friction, 9 problems")
//   challenge  finished this month's challenge
//   daily      finished today's Daily
// A student working right now is shown as working, whatever else they did.
// Simulation answers never show: a timed exam is nobody else's business.

const content = require('./content.json');
const lessonGames = require('./lessonGames.json'); // {chapterId: {lessonId: [gameId]}}
const { progress } = require('./challenges.js');

const LIVE_MS = 10 * 60 * 1000;
const SESSION_GAP_MS = 30 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;
const MAX_ROWS = 6;

let index = null;
/** problemId and gameId -> { chapterId, lesson }, built once from the content. */
function lessonIndex() {
  if (index) return index;
  const problems = new Map();
  const games = new Map();
  for (const ch of content.chapters || []) {
    for (const sub of ch.subtopics || []) {
      for (const l of sub.lessons || []) {
        const full = content.lessons[`${ch.id}/${l.id}`];
        for (const p of full?.problems || []) problems.set(p.id, { chapterId: ch.id, lesson: l.name });
        for (const g of (lessonGames[ch.id] || {})[l.id] || []) games.set(g, { chapterId: ch.id, lesson: l.name });
      }
    }
  }
  index = { problems, games };
  return index;
}

const isAnswer = (e) => e && (!e.kind || e.kind === 'answer');
const isExam = (e) => String(e.eventId || '').startsWith('exam-');

/** Where an answer was: its lesson if it has one, else just its chapter. */
function placeOf(e) {
  const { problems, games } = lessonIndex();
  if (e.source === 'web') {
    const hit = problems.get(String(e.itemId || ''));
    return hit || (e.chapterId ? { chapterId: e.chapterId, lesson: null } : null);
  }
  const gameId = String(e.itemId || '').split(':')[1];
  const hit = games.get(gameId);
  return hit || (e.chapterId ? { chapterId: e.chapterId, lesson: null } : null);
}

/** The most frequent value of a list, ties to the latest. */
function mostOf(list) {
  const counts = new Map();
  let best = null;
  let bestN = 0;
  for (const v of list) {
    const n = (counts.get(v) || 0) + 1;
    counts.set(v, n);
    if (n >= bestN) { best = v; bestN = n; }
  }
  return best;
}

/**
 * Each student's latest session from a day of answers: where it was, how
 * many answers, which device, and when it ended.
 */
function sessionsOf(events) {
  const byEmail = new Map();
  for (const e of events || []) {
    if (!isAnswer(e) || isExam(e) || !Number.isFinite(e.ts)) continue;
    if (!byEmail.has(e.email)) byEmail.set(e.email, []);
    byEmail.get(e.email).push(e);
  }
  const out = new Map();
  for (const [email, list] of byEmail) {
    list.sort((a, b) => a.ts - b.ts);
    let i = list.length - 1;
    while (i > 0 && list[i].ts - list[i - 1].ts <= SESSION_GAP_MS) i--;
    const session = list.slice(i);
    const places = session.map(placeOf).filter(Boolean);
    if (!places.length) continue;
    const where = mostOf(places.map((p) => `${p.chapterId}|${p.lesson || ''}`));
    const [chapterId, lesson] = where.split('|');
    const phone = session.filter((e) => e.source !== 'web').length;
    out.set(email, {
      email,
      chapterId,
      lesson: lesson || null,
      count: session.length,
      device: phone > session.length / 2 ? 'phone' : 'desk',
      ts: session[session.length - 1].ts,
    });
  }
  return out;
}

/**
 * When a student finished a challenge: the time of the answer that made
 * progress() say finished, found by halving the answers in time order.
 */
function finishedAt(entry, events) {
  const list = [...(events || [])].filter((e) => Number.isFinite(e.ts)).sort((a, b) => a.ts - b.ts);
  const done = (n) => { const p = progress(entry, list.slice(0, n)); return Boolean(p && p.finished); };
  if (!list.length || !done(list.length)) return null;
  let lo = 1;
  let hi = list.length;
  while (lo < hi) {
    const mid = Math.floor((lo + hi) / 2);
    if (done(mid)) hi = mid; else lo = mid + 1;
  }
  return list[lo - 1].ts;
}

/**
 * The feed: one row per student, working ones first, then the latest.
 * `answers` is the last day of answer events, any account. `challenge` is
 * { entry, eventsByEmail } for this month's challenge, or null. `dailies`
 * is today's Daily results ({ email, createdAt }). `nameOf(email)` gives the
 * name to show.
 */
function buildFeed({ answers = [], challenge = null, dailies = [], now = Date.now(), nameOf = () => 'A student', limit = MAX_ROWS } = {}) {
  const since = now - DAY_MS;
  const rows = new Map(); // email -> row

  const offer = (row) => {
    if (row.ts < since || row.ts > now + 60000) return;
    const held = rows.get(row.email);
    if (!held) { rows.set(row.email, row); return; }
    // Working beats everything, a challenge finish beats a session or a
    // Daily, and otherwise the latest wins.
    if (held.kind === 'working') return;
    if (row.kind === 'working' || row.kind === 'challenge') { rows.set(row.email, row); return; }
    if (held.kind === 'challenge') return;
    if (row.ts > held.ts) rows.set(row.email, row);
  };

  for (const s of sessionsOf(answers).values()) {
    offer({ ...s, kind: now - s.ts <= LIVE_MS ? 'working' : 'practiced' });
  }
  if (challenge?.entry) {
    for (const [email, events] of challenge.eventsByEmail || []) {
      const ts = finishedAt(challenge.entry, events);
      if (ts) offer({ email, kind: 'challenge', chapterId: challenge.entry.chapterId, lesson: null, ts });
    }
  }
  for (const d of dailies) {
    const ts = new Date(d.createdAt).getTime();
    if (Number.isFinite(ts)) offer({ email: d.email, kind: 'daily', chapterId: null, lesson: null, ts });
  }

  return [...rows.values()]
    .sort((a, b) => {
      const wa = a.kind === 'working';
      const wb = b.kind === 'working';
      if (wa !== wb) return wa ? -1 : 1;
      return b.ts - a.ts;
    })
    .slice(0, limit)
    .map((r) => ({
      email: r.email,
      name: nameOf(r.email),
      kind: r.kind,
      device: r.device || null,
      chapterId: r.chapterId || null,
      lesson: r.lesson || null,
      count: r.count || null,
      ts: r.ts,
    }));
}

module.exports = { buildFeed, sessionsOf, finishedAt, placeOf, LIVE_MS };
