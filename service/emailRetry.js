// Giving a failed verification email another chance.
//
// Why this exists. On 2026-10-07 the logs showed 34 sends refused with "API
// key is invalid", 22 distinct people. They were not over any quota: the
// rejections sit between "RESEND_FROM_EMAIL is unset" warnings and missing
// public/index.html errors, which is the service running with no environment.
// That is the few seconds during a deploy when the app is up but broken.
//
// The send was fired and forgotten at sign-up, so each failure was logged and
// dropped. Somebody signing up in that window got an account and no email, and
// nothing anywhere would have noticed. All 22 happen to be fine now, but only
// because they either came back or were purged.
//
// What is queued is the INTENT, never the email. A verification link cannot be
// stored and resent: only the hash of the token is kept, by design. So a retry
// mints a fresh token and sends a new one, exactly as "resend verification"
// does. Nothing sensitive sits in the queue.

/// Four attempts over roughly two hours, then it stops.
///
/// A deploy window is seconds and an outage is minutes, so the first retry is
/// fast and the rest back off. Past two hours the cause is not transient and
/// trying again just mails a bad address repeatedly, which costs sender
/// reputation.
const MAX_ATTEMPTS = 4;
const BACKOFF_MINUTES = [1, 10, 45, 120];

/// Errors that mean "the address is wrong", where trying again changes
/// nothing and repeated attempts hurt the sending domain.
const PERMANENT = [
  /invalid.*(recipient|to field|email address)/i,
  /recipient.*(rejected|not found|does not exist)/i,
  /suppress/i,
  /unsubscrib/i,
  /blocked/i,
];

/// Whether this failure is worth another go.
///
/// Unknown errors are retried. The failure that caused this to exist, an
/// invalid API key, is indistinguishable from any other config problem, and
/// the cost of one extra attempt is far below the cost of losing a sign-up.
function shouldRetry(error) {
  const msg = String(error || '');
  if (!msg) return true;
  return !PERMANENT.some((re) => re.test(msg));
}

/// When to try again, or null once it has had its chances.
function nextAttemptAt(attempts, now = new Date()) {
  if (attempts >= MAX_ATTEMPTS) return null;
  const minutes = BACKOFF_MINUTES[Math.min(attempts, BACKOFF_MINUTES.length - 1)];
  return new Date(now.getTime() + minutes * 60000);
}

/// The row to queue after a failure, or null when there is no point.
function retryEntry({ email, kind = 'verification', error, attempts = 0, now = new Date() }) {
  if (!email) return null;
  if (!shouldRetry(error)) return null;
  const at = nextAttemptAt(attempts, now);
  if (!at) return null;
  return {
    email,
    kind,
    attempts: attempts + 1,
    nextAt: at,
    lastError: String(error || '').slice(0, 200),
    updatedAt: now,
  };
}

/// Whether a queued row is due.
function isDue(row, now = new Date()) {
  if (!row || !row.nextAt) return false;
  return new Date(row.nextAt) <= now;
}

module.exports = {
  MAX_ATTEMPTS,
  BACKOFF_MINUTES,
  shouldRetry,
  nextAttemptAt,
  retryEntry,
  isDue,
};
