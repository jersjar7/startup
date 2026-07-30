// Is an unsubmitted exam attempt past its window?
//
// The paid simulation is a single timed session (5h20m). If the user never hits
// submit, the attempt sits at status 'in_progress' forever unless something
// retires it. Nothing did, and POST /api/exam/start resumed any in_progress
// attempt unconditionally — so a stale one dropped the user into the exam with
// a dead clock and no route to a fresh attempt. Three of the first six paying
// customers were stuck this way, one for 46 days.
//
// The grace period must stay in step with service/checkActiveExamSims.js, which
// uses the same limit + 30 minutes to decide whether a deploy would interrupt a
// live exam. If these two ever disagree, either deploys get blocked by attempts
// the app has already killed, or a deploy lands on someone the app still
// considers active.
const TIME_LIMIT_SECONDS = 5 * 3600 + 20 * 60; // 5h20m
const EXPIRY_GRACE_SECONDS = 30 * 60;

function isAttemptExpired(startedAt, now = new Date(), limitSeconds = TIME_LIMIT_SECONDS, graceSeconds = EXPIRY_GRACE_SECONDS) {
  if (!startedAt) return false; // no start time: leave it alone rather than guess
  const started = new Date(startedAt).getTime();
  if (Number.isNaN(started)) return false;
  const elapsedMs = new Date(now).getTime() - started;
  return elapsedMs > (limitSeconds + graceSeconds) * 1000;
}

module.exports = { isAttemptExpired, TIME_LIMIT_SECONDS, EXPIRY_GRACE_SECONDS };
