// The week, for the leagues and every weekly number: Sunday to Saturday,
// US Eastern for everyone (ADR 0037).
//
// The id keeps the YYYY-Wnn format the board has always used, but a week is
// named after its Sunday. Counting from January 1 alone split the week that
// crosses New Year into two ids ("2026-W53" and "2027-W01" for one Sunday to
// Saturday), which would cut a league week in half. Named by its Sunday,
// every day of a week gets one id, and every week away from New Year keeps
// the id it always had.

const TZ = 'America/New_York';
const DAY_RE = /^\d{4}-\d{2}-\d{2}$/;

/** YYYY-MM-DD of an instant in the given time zone (Eastern by default). */
function dayIn(date = new Date(), tz = TZ) {
  return new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit' }).format(date);
}

// Calendar arithmetic on a YYYY-MM-DD day, in UTC so the machine's own time
// zone never enters into it.
function toUtc(day) {
  const [y, m, d] = day.split('-').map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}
function addDays(day, n) {
  const t = toUtc(day);
  t.setUTCDate(t.getUTCDate() + n);
  return t.toISOString().slice(0, 10);
}

/** The Sunday that starts the week holding this day. */
function sundayOf(day) {
  return addDays(day, -toUtc(day).getUTCDay());
}

/** The week's id for a YYYY-MM-DD day. */
function weekIdFor(day) {
  if (!DAY_RE.test(String(day))) throw new Error(`weekIdFor needs YYYY-MM-DD, got ${day}`);
  const sunday = toUtc(sundayOf(day));
  const year = sunday.getUTCFullYear();
  const jan1 = new Date(Date.UTC(year, 0, 1));
  const days = Math.round((sunday - jan1) / 86400000);
  const week = Math.ceil((days + jan1.getUTCDay() + 1) / 7);
  return `${year}-W${String(week).padStart(2, '0')}`;
}

/** This week's id, by the Eastern calendar. */
function currentWeekId(now = new Date()) {
  return weekIdFor(dayIn(now));
}

/** The id of the week before the one holding this instant. */
function previousWeekId(now = new Date()) {
  return weekIdFor(addDays(dayIn(now), -7));
}

// Minutes the zone is ahead of UTC at an instant (negative in the Americas).
function offsetMinutes(date, tz = TZ) {
  const p = Object.fromEntries(new Intl.DateTimeFormat('en-US', {
    timeZone: tz, hourCycle: 'h23', year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  }).formatToParts(date).map((x) => [x.type, x.value]));
  const asUtc = Date.UTC(+p.year, +p.month - 1, +p.day, +p.hour, +p.minute, +p.second);
  return Math.round((asUtc - date.getTime()) / 60000);
}

/** The instant a day begins in the zone, daylight saving included. */
function startOfDay(day, tz = TZ) {
  const guess = toUtc(day).getTime();
  let t = guess - offsetMinutes(new Date(guess), tz) * 60000;
  t = guess - offsetMinutes(new Date(t), tz) * 60000;
  return new Date(t);
}

/** When this week ends: the next Sunday's midnight, Eastern. */
function weekEndsAt(now = new Date()) {
  return startOfDay(addDays(sundayOf(dayIn(now)), 7));
}

/** The seven days of the week holding this day, Sunday first. */
function daysOfWeek(day) {
  const s = sundayOf(day);
  return Array.from({ length: 7 }, (_, i) => addDays(s, i));
}

module.exports = { TZ, dayIn, addDays, sundayOf, weekIdFor, currentWeekId, previousWeekId, weekEndsAt, startOfDay, daysOfWeek };
