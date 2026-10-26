// The words and order behind the dashboard's right column (docs/dashboard.md):
// the road to the FE, the live feed, the boards and the badge shelf. Kept
// apart from the markup so they are tested on their own.

const DAY_MS = 86400000;
const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const WEEKDAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
const DAY_RE = /^\d{4}-\d{2}-\d{2}$/;

// The simulation is suggested three weeks out: late enough to measure what
// was learned, early enough to fix what it finds. Below two days it is no
// longer a real offer (simPitchGate's MIN_DAYS).
export const SIM_WEEKS_OUT = 3;
export const SIM_MIN_DAYS = 2;

const utc = (day) => Date.parse(`${day}T00:00:00Z`);
export function addDays(day, n) {
  return new Date(utc(day) + n * DAY_MS).toISOString().slice(0, 10);
}
export function daysBetween(a, b) {
  return Math.round((utc(b) - utc(a)) / DAY_MS);
}
/** "Jan 20" */
export function shortDate(day) {
  const d = new Date(utc(day));
  return `${MONTHS[d.getUTCMonth()]} ${d.getUTCDate()}`;
}

/** The last day of the leaderboard week: weeks start on Sunday (leaderboard.js). */
export function weekEnd(today) {
  const dow = new Date(utc(today)).getUTCDay();
  return addDays(today, 6 - dow);
}

/**
 * The stops on the road, in date order: today first, exam day last, and
 * nothing after exam day. Each stop is { key, date, when }; the component
 * fills in the rest from what it already holds.
 */
export function roadStops({ today, examDate = null, challenge = null, challengeEnd = null, simOwned = false }) {
  const exam = DAY_RE.test(examDate || '') && examDate >= today ? examDate : null;
  const stops = [{ key: 'today', date: today, when: 'Today' }];

  const wk = weekEnd(today);
  stops.push({
    key: 'week',
    date: wk,
    when: wk === today ? 'Tonight · week ends' : `${WEEKDAYS[new Date(utc(wk)).getUTCDay()]} · week ends`,
  });

  if (challenge && !challenge.finishedAtDesk && DAY_RE.test(challengeEnd || '')) {
    stops.push({ key: 'challenge', date: challengeEnd, when: `${shortDate(challengeEnd)} · challenge ends` });
  }

  if (exam) {
    const left = daysBetween(today, exam);
    const suggested = addDays(exam, -7 * SIM_WEEKS_OUT);
    if (suggested > today) stops.push({ key: 'sim', date: suggested, when: `${shortDate(suggested)} · three weeks out` });
    else if (left >= SIM_MIN_DAYS || simOwned) stops.push({ key: 'sim', date: today, when: `Now · ${left} days out` });
  } else {
    stops.push({ key: 'sim', date: null, when: 'Before exam day' });
  }

  stops.push({ key: 'exam', date: exam, when: exam ? shortDate(exam) : 'Exam day' });

  // Today, then the dated stops by date, then anything undated, then the exam.
  const rank = (s) => (s.key === 'today' ? 0 : s.key === 'exam' ? 3 : s.date ? 1 : 2);
  return stops
    .filter((s) => s.key === 'exam' || !exam || !s.date || s.date <= exam)
    .sort((a, b) => rank(a) - rank(b) || (rank(a) === 1 ? a.date.localeCompare(b.date) : 0));
}

/** "12 min", "3 hr", "now" */
export function timeAgo(ts, now) {
  const mins = Math.floor((now - ts) / 60000);
  if (mins < 2) return 'now';
  if (mins < 60) return `${mins} min`;
  return `${Math.floor(mins / 60)} hr`;
}

const plural = (n, one, many) => `${n} ${n === 1 ? one : many}`;

/** What a feed row says after the name. */
export function feedLine(row, chapterName = '') {
  const where = row.lesson || chapterName || 'the FE';
  switch (row.kind) {
    case 'working':
      return row.device === 'phone' ? `is playing ${where} in the app` : row.lesson ? `is working through ${row.lesson}` : `is practicing ${where}`;
    case 'practiced':
      return row.device === 'phone'
        ? `played ${plural(row.count || 1, 'round', 'rounds')} of ${where}`
        : `practiced ${where}, ${plural(row.count || 1, 'problem', 'problems')}`;
    case 'challenge':
      return `finished the ${chapterName || 'monthly'} challenge`;
    case 'daily':
      return "finished today's Daily";
    default:
      return '';
  }
}

/** Two letters for a name's circle: "Maria G." -> "MG", "A student" -> "AS". */
export function initials(name) {
  const parts = String(name || '').replace(/\./g, '').trim().split(/\s+/).filter(Boolean);
  if (!parts.length) return '?';
  return (parts[0][0] + (parts[1] ? parts[1][0] : '')).toUpperCase();
}

/**
 * The rows a board shows: the top, then the viewer with a neighbour either
 * side if they sit below it. A gap marker separates the two.
 */
export function boardRows(entries, top = 8) {
  const list = entries || [];
  const meAt = list.findIndex((e) => e.isCurrentUser);
  if (meAt < top) return list.slice(0, top);
  const head = list.slice(0, top - 3);
  return [...head, { gap: true }, ...list.slice(meAt - 1, meAt + 2)];
}

/** The student right above the viewer, and how far: "30 XP to pass Devon R." */
export function passLine(entries, xpKey) {
  const list = entries || [];
  const meAt = list.findIndex((e) => e.isCurrentUser);
  if (meAt === 0) return 'You lead this week.';
  if (meAt < 0) return '';
  const above = list[meAt - 1];
  const gap = (above[xpKey] || 0) - (list[meAt][xpKey] || 0) + 1;
  return `${gap} XP to pass ${above.name}${above.name.endsWith('.') ? '' : '.'}`;
}

// Badges whose progress can be read from what the dashboard already has.
const COUNTED = {
  'xp-100': ['xp', 100], 'xp-500': ['xp', 500], 'xp-1000': ['xp', 1000],
  'streak-3': ['streak', 3], 'streak-7': ['streak', 7], 'streak-30': ['streak', 30],
};

/** The closest unearned badge we can measure: { id, have, need, unit }, or null. */
export function nextBadge(earnedIds, { totalXp = 0, streak = 0 } = {}) {
  let best = null;
  for (const [id, [kind, need]] of Object.entries(COUNTED)) {
    if (earnedIds.has(id)) continue;
    const have = kind === 'xp' ? totalXp : streak;
    if (have >= need) continue;
    const share = have / need;
    if (!best || share > best.share) best = { id, have, need, unit: kind === 'xp' ? 'XP' : 'days', share };
  }
  if (!best) return null;
  const { share, ...rest } = best;
  return rest;
}
