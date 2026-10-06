// Did they sit the exam, and did they pass.
//
// The two most valuable records the platform does not have. Without them there
// is no way to show a department that the product moved their pass rate, no way
// to calibrate a readiness prediction, and no way to learn what coverage level
// actually corresponds to passing. Everything else is a proxy for this.
//
// Asked once, by email and in the phone app, nine days after the exam date the
// user themselves entered. Nine because NCEES results for the computer-based FE
// arrive within about seven to ten days, so the answer is known but the day is
// still recent enough to be remembered precisely.
//
// Never asked of someone who has not given an exam date, and never asked twice.

const ASK_AFTER_DAYS = 9;

/// When each ask goes out, in days after the exam.
///
/// Four touches and then silence forever. The gaps widen so it reads as
/// persistence rather than nagging, and the whole sequence exists because of
/// response BIAS, not response volume: somebody who failed is less likely to
/// say so, and if mostly passers answer then the pass rate computed from this
/// is inflated and worse than having no data (owner, 2026-10-06).
const ASK_DAYS = [ASK_AFTER_DAYS, 16, 30, 60];

/// A date-only string, so nothing here depends on the time of day the
/// scheduler happens to run.
function dayString(d) {
  return new Date(d).toISOString().slice(0, 10);
}

/// The day the outcome question becomes due for a given exam date.
function dueDate(examDateIso, afterDays = ASK_AFTER_DAYS) {
  if (!examDateIso) return null;
  const exam = new Date(examDateIso);
  if (Number.isNaN(exam.getTime())) return null;
  const due = new Date(exam);
  due.setUTCDate(due.getUTCDate() + afterDays);
  return dayString(due);
}

function isAnswered(user) {
  const o = user && user.examOutcome;
  return Boolean(o && (o.answeredAt || o.declinedAt));
}

/// How many times they have already been asked.
function asksSent(user) {
  const o = user && user.examOutcome;
  if (!o) return 0;
  if (Array.isArray(o.asks)) return o.asks.length;
  // The first version stamped a single askedAt. Treat it as one ask so the
  // people already asked are not asked a second time from scratch.
  return o.askedAt ? 1 : 0;
}

/// Which ask is due today, one-based, or 0 for none. Pure, so the scheduler
/// and the tests see the same rule.
///
/// Returns 0 once all four have gone out, so nobody is ever asked a fifth
/// time no matter how long they go without replying.
function askDue(user, today = dayString(new Date())) {
  if (!user || !user.examDate) return 0;
  if (isAnswered(user)) return 0;
  const sent = asksSent(user);
  if (sent >= ASK_DAYS.length) return 0;
  const due = dueDate(user.examDate, ASK_DAYS[sent]);
  if (!due) return 0;
  return today >= due ? sent + 1 : 0;
}

/// Kept for readability at the call sites that only care whether anything is
/// due at all.
function shouldAsk(user, today = dayString(new Date())) {
  return askDue(user, today) > 0;
}

/// Which surface an answer came from.
///
/// Worth recording because the phone's notification path does not offer a
/// dismissal, so the cheapest way out of it is tapping an answer. If that is
/// pushing people to "I did not sit it" rather than the true one, the share of
/// no-shows by surface is where it shows up (owner, 2026-10-06).
const SURFACES = ['app', 'notification', 'email'];

function readVia(v) {
  const via = String(v || 'app').toLowerCase();
  return SURFACES.includes(via) ? via : 'app';
}

/// Validates a submitted answer. Returns null when the body is unusable, so a
/// caller can reject rather than store something meaningless.
function parseOutcome(body) {
  if (!body || typeof body !== 'object') return null;
  if (body.declined === true) return { declined: true };
  // Deliberately distinct from declined: putting the card away is "not now",
  // not "never". Only an explicit refusal ends the sequence.
  if (body.snoozed === true) return { snoozed: true };

  if (typeof body.sat !== 'boolean') return null;
  // Someone who did not sit it has no result and no attempt number, and
  // recording a false "did not pass" against them would poison every rate
  // computed from this field.
  if (!body.sat) {
    return { sat: false, passed: null, attemptNumber: null, via: readVia(body.via) };
  }

  if (typeof body.passed !== 'boolean') return null;
  let attempt = body.attemptNumber;
  if (attempt === null || attempt === undefined || attempt === '') attempt = null;
  else {
    attempt = Number(attempt);
    if (!Number.isInteger(attempt) || attempt < 1 || attempt > 20) return null;
  }
  return { sat: true, passed: body.passed, attemptNumber: attempt, via: readVia(body.via) };
}

module.exports = {
  ASK_AFTER_DAYS,
  ASK_DAYS,
  dueDate,
  askDue,
  shouldAsk,
  asksSent,
  isAnswered,
  parseOutcome,
  readVia,
  SURFACES,
  dayString,
};
