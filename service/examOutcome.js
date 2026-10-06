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

/// Who should be asked today. Pure, so the scheduler and the tests see the
/// same rule.
function shouldAsk(user, today = dayString(new Date())) {
  if (!user || !user.examDate) return false;
  if (isAnswered(user)) return false;
  if (user.examOutcome && user.examOutcome.askedAt) return false;
  const due = dueDate(user.examDate);
  if (!due) return false;
  return today >= due;
}

/// Validates a submitted answer. Returns null when the body is unusable, so a
/// caller can reject rather than store something meaningless.
function parseOutcome(body) {
  if (!body || typeof body !== 'object') return null;
  if (body.declined === true) return { declined: true };

  if (typeof body.sat !== 'boolean') return null;
  // Someone who did not sit it has no result and no attempt number, and
  // recording a false "did not pass" against them would poison every rate
  // computed from this field.
  if (!body.sat) return { sat: false, passed: null, attemptNumber: null };

  if (typeof body.passed !== 'boolean') return null;
  let attempt = body.attemptNumber;
  if (attempt === null || attempt === undefined || attempt === '') attempt = null;
  else {
    attempt = Number(attempt);
    if (!Number.isInteger(attempt) || attempt < 1 || attempt > 20) return null;
  }
  return { sat: true, passed: body.passed, attemptNumber: attempt };
}

module.exports = { ASK_AFTER_DAYS, dueDate, shouldAsk, isAnswered, parseOutcome, dayString };
