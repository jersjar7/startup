// Monthly chapter challenges (ADR 0027, docs/challenges.md).
//
// The calendar (challenges.json) is one entry a month: month, chapterId, name,
// and optionally line (the one sentence) and storeName (the App Store event
// name, 30 characters at most; it defaults to "<Month> <name>").
//
// One chapter a month. A lesson counts when, between the 1st and the last day
// of the month (the student's local day), every game on its path node is
// cleared on the phone, or every one of its practice problems is answered
// right on the website. Progress is worked out from the event log and never
// stored, so this module is pure and the routes hand it the events.
//
// Never mastery (ADR 0020): nothing here is read by derive.js's mastery.

const calendar = require('./challenges.json'); // [{month: 'YYYY-MM', chapterId, name}]
const content = require('./content.json');
const catalog = require('./gameCatalog.json'); // {chapterId: {gameId: rounds}}
const lessonGames = require('./lessonGames.json'); // {chapterId: {lessonId: [gameId]}}

const DAY_RE = /^\d{4}-\d{2}-\d{2}$/;
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'];

/** The first and last local day of a 'YYYY-MM' month. */
function monthBounds(month) {
  const [y, m] = month.split('-').map(Number);
  const last = new Date(Date.UTC(y, m, 0)).getUTCDate();
  return { start: `${month}-01`, end: `${month}-${String(last).padStart(2, '0')}` };
}

/** The chapter's lessons in path order, each with its practice ids and games. */
function lessonsOf(chapterId) {
  const chapter = content.chapters.find((c) => c.id === chapterId);
  if (!chapter) return [];
  const out = [];
  for (const sub of chapter.subtopics || []) {
    for (const l of sub.lessons || []) {
      const full = content.lessons[`${chapterId}/${l.id}`];
      out.push({
        id: l.id,
        name: l.name,
        practice: (full?.problems || []).map((p) => p.id),
        games: (lessonGames[chapterId] || {})[l.id] || [],
      });
    }
  }
  return out;
}

/** The calendar entry, filled in: dates, month name, the one line, lessons. */
function view(entry) {
  if (!entry) return null;
  const { start, end } = monthBounds(entry.month);
  const monthName = MONTHS[Number(entry.month.slice(5, 7)) - 1];
  const lessons = lessonsOf(entry.chapterId);
  const chapterName = entry.name.replace(/ Challenge$/, '');
  return {
    month: entry.month,
    monthName,
    chapterId: entry.chapterId,
    name: entry.name,
    storeName: entry.storeName || `${monthName} ${entry.name}`,
    line: entry.line || `Clear every ${chapterName} lesson before ${monthName} ends.`,
    start,
    end,
    lessons: lessons.map(({ id, name }) => ({ id, name })),
  };
}

/** The challenge running on a local day, or null. */
function challengeOn(day) {
  if (!DAY_RE.test(day || '')) return null;
  return view(calendar.find((c) => c.month === day.slice(0, 7)) || null);
}

/** The next challenge to start after a local day (for "starts Dec 1"), or null. */
function nextAfter(day) {
  const month = String(day || '').slice(0, 7);
  const next = calendar.filter((c) => c.month > month).sort((a, b) => a.month.localeCompare(b.month))[0];
  return view(next || null);
}

/**
 * One account's progress in one challenge, from its events.
 * Each lesson is cleared 'desk', 'phone' or null; desk wins when both.
 */
function progress(entry, events) {
  const c = typeof entry === 'string' ? challengeOn(`${entry}-01`) : entry;
  if (!c) return null;
  const rounds = catalog[c.chapterId] || {};
  const deskRight = new Set();
  const phoneRight = new Map(); // gameId -> Set of rounds answered right
  for (const e of events || []) {
    if (!e || (e.kind && e.kind !== 'answer') || e.grade === 'forgot') continue;
    if (!DAY_RE.test(e.localDate || '') || e.localDate < c.start || e.localDate > c.end) continue;
    if (e.source === 'web') { deskRight.add(String(e.itemId || '')); continue; }
    const parts = String(e.itemId || '').split(':');
    const round = Number(parts[2]);
    if (parts.length !== 3 || !Number.isInteger(round) || !(parts[1] in rounds)) continue;
    if (!phoneRight.has(parts[1])) phoneRight.set(parts[1], new Set());
    phoneRight.get(parts[1]).add(round);
  }
  const gameCleared = (g) => {
    const got = phoneRight.get(g);
    if (!got || !rounds[g]) return false;
    for (let r = 1; r <= rounds[g]; r++) if (!got.has(r)) return false;
    return true;
  };
  const lessons = lessonsOf(c.chapterId).map((l) => {
    const desk = l.practice.length > 0 && l.practice.every((id) => deskRight.has(id));
    const phone = l.games.length > 0 && l.games.every(gameCleared);
    return { id: l.id, name: l.name, cleared: desk ? 'desk' : phone ? 'phone' : null };
  });
  const cleared = lessons.filter((l) => l.cleared).length;
  return {
    month: c.month,
    chapterId: c.chapterId,
    lessons,
    cleared,
    total: lessons.length,
    finished: lessons.length > 0 && cleared === lessons.length,
    finishedAtDesk: lessons.length > 0 && lessons.every((l) => l.cleared === 'desk'),
  };
}

/** Every challenge the account has finished, oldest first: the coins. */
function finishedChallenges(events) {
  const out = [];
  for (const entry of [...calendar].sort((a, b) => a.month.localeCompare(b.month))) {
    const p = progress(view(entry), events);
    if (p && p.finished) out.push({ month: p.month, chapterId: p.chapterId, name: entry.name, atDesk: p.finishedAtDesk });
  }
  return out;
}

/** How many accounts finished, from events grouped by email. */
function finishedCount(entry, eventsByEmail) {
  let finished = 0;
  let atDesk = 0;
  for (const events of eventsByEmail.values()) {
    const p = progress(entry, events);
    if (p && p.finished) { finished += 1; if (p.finishedAtDesk) atDesk += 1; }
  }
  return { finished, atDesk, taking: eventsByEmail.size };
}

module.exports = { calendar, monthBounds, lessonsOf, challengeOn, nextAfter, progress, finishedChallenges, finishedCount };
