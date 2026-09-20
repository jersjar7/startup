// Which calendar days a student studied.
//
// "Days studied" on the dashboard and the phone is a cumulative COUNT
// (streak.js): it ticks once per new calendar day and never resets. Until
// 2026-09-19 the count was all that was kept, plus the date of the last
// session, so nothing could show WHICH days. Now every place that advances
// the count also adds the day to `studyDays` on the user's stats, and the
// phone's calendar reads that list. Days before the list existed are
// backfilled once from the dated records that do exist (scripts/backfillStudyDays.js).

const DAY_RE = /^\d{4}-\d{2}-\d{2}$/;

/**
 * The Mongo update for a stats write. When the write moves lastSessionDate
 * (every study-day tick does), the day joins the set as well, so the count
 * and the list can never drift apart from here on.
 */
function studyDayUpdate(update) {
  const day = update && update.lastSessionDate;
  if (typeof day !== 'string' || !DAY_RE.test(day)) return { $set: update };
  return { $set: update, $addToSet: { studyDays: day } };
}

/** A Date, or anything Date can parse, as a YYYY-MM-DD in UTC. */
function utcDay(value) {
  if (value == null) return null;
  const d = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(d.getTime())) return null;
  return d.toISOString().slice(0, 10);
}

/**
 * The distinct days across a user's dated records, oldest first. Web sessions
 * and diagnostics carry a timestamp (the server's UTC day, which is also how
 * the count was ticked for them); phone events carry the client's local day,
 * which is the day the count credited.
 */
function collectStudyDays({ sessions = [], events = [], diagnostics = [], attempts = [], existing = [] } = {}) {
  const days = new Set(existing.filter((d) => typeof d === 'string' && DAY_RE.test(d)));
  for (const s of sessions) {
    const d = utcDay(s.completedAt);
    if (d) days.add(d);
  }
  for (const e of events) {
    if (typeof e.localDate === 'string' && DAY_RE.test(e.localDate)) days.add(e.localDate);
  }
  for (const r of diagnostics) {
    const d = utcDay(r.completedAt || r.createdAt || r.date);
    if (d) days.add(d);
  }
  for (const a of attempts) {
    const d = utcDay(a.createdAt || a.startedAt);
    if (d) days.add(d);
  }
  return [...days].sort();
}

/**
 * The day a write counts toward: the student's own calendar day when the
 * client sent one (`localDate`, YYYY-MM-DD), else the server's UTC day. The
 * website and the phone both send it, so an evening's work lands on one day.
 */
function dayFor(body) {
  const d = body && body.localDate;
  return typeof d === 'string' && DAY_RE.test(d) ? d : utcDay(new Date());
}

module.exports = { studyDayUpdate, collectStudyDays, utcDay, dayFor, DAY_RE };
