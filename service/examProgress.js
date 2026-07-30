// In-progress exam state: how a partial answer set is merged into what the
// server already holds.
//
// Why this exists at all: answers used to live ONLY in React state, with no
// autosave and no answers returned on resume. Any refresh during the 5h20m exam
// wiped everything while the server clock kept running. Three of the first six
// paying customers submitted single-digit answer counts because of it.
//
// The rule that matters: MERGE, never replace. A client that has lost its state
// must never be able to blank out answers the server already has. That is the
// exact failure being fixed, so it must not be reintroduced by the fix.

// Answers are keyed by questionId, never by array position. Position keys break
// the moment question order changes, which is precisely what resume does — the
// old client regenerated its own question set on resume, so index-keyed answers
// were scored against the wrong questions and silently dropped.
// The scheduled break, mirroring BREAK_DURATION in src/exam/ExamSession.jsx.
const BREAK_LIMIT_SECONDS = 25 * 60;

function sanitizeAnswers(input) {
  if (!input || typeof input !== 'object') return {};
  const out = {};
  for (const [questionId, choiceId] of Object.entries(input)) {
    if (typeof questionId !== 'string' || !questionId) continue;
    if (questionId.length > 120) continue;
    // null is meaningful: it clears a selection the user deliberately undid.
    if (choiceId === null) { out[questionId] = null; continue; }
    if (typeof choiceId !== 'string' || !choiceId || choiceId.length > 120) continue;
    out[questionId] = choiceId;
  }
  return out;
}

// AUTOSAVE merge. The client is authoritative here: it is reporting live state
// while the user works, so an explicit null legitimately means "the user cleared
// this answer". Last write wins per question, so a retried request is harmless.
function mergeAutosave(stored, incoming) {
  return { ...sanitizeAnswers(stored), ...sanitizeAnswers(incoming) };
}

// SUBMIT merge. Deliberately different: submit can only ADD answers, never clear
// them.
//
// This distinction is the whole ballgame. The client's submit payload sends an
// explicit null for every question it does not currently hold, and a submitting
// client may hold only a fraction of the truth — most dangerously the timed
// auto-submit, which can fire with a stale snapshot. Honouring those nulls at
// submit time deleted every autosaved answer and scored the customer ~0%, which
// is precisely the data loss the autosave was built to prevent.
//
// So at submit, nulls and absent entries are ignored: whatever the server has
// already saved stands.
function mergeSubmission(stored, submitted) {
  const base = sanitizeAnswers(stored);
  for (const [questionId, choiceId] of Object.entries(sanitizeAnswers(submitted))) {
    if (choiceId) base[questionId] = choiceId; // additive only
  }
  return base;
}


// When this attempt must end, as an epoch milliseconds value.
//
// Returned by /exam/start so the CLIENT never computes it. The old countdown was
// a bare setInterval decrement that never re-derived from wall clock, so
// backgrounding the tab or sleeping the laptop simply stopped the clock and
// handed out unlimited extra time. A server-issued deadline cannot be paused by
// hiding a tab.
//
// The 25-minute break does NOT count against exam time — that mirrors the real
// NCEES appointment, where the break sits outside the 5h20m — so any break the
// customer has taken extends the deadline. A break still in progress extends it
// as it runs.
function examDeadlineMs(attempt = {}, limitSeconds, now = new Date()) {
  // Guard falsy explicitly: new Date(null) is the 1970 epoch, not Invalid Date,
  // so a missing startedAt would silently yield a deadline decades in the past
  // and mark every submit late.
  if (!attempt || !attempt.startedAt) return NaN;
  const started = new Date(attempt.startedAt).getTime();
  if (Number.isNaN(started)) return NaN;

  let breakMs = 0;
  const bStart = attempt.breakStartedAt ? new Date(attempt.breakStartedAt).getTime() : NaN;
  const bEnd = attempt.breakEndedAt ? new Date(attempt.breakEndedAt).getTime() : NaN;
  if (!Number.isNaN(bStart)) {
    const end = Number.isNaN(bEnd) ? new Date(now).getTime() : bEnd;
    breakMs = Math.max(0, end - bStart);
    // Never credit more than one full break, however the timestamps look.
    breakMs = Math.min(breakMs, BREAK_LIMIT_SECONDS * 1000);
  }
  return started + limitSeconds * 1000 + breakMs;
}

// Has the window closed? Used at submit to record the truth rather than to
// reject: refusing a late submit would throw the customer's work away, which is
// the failure mode being fixed everywhere else in this file.
function isPastDeadline(attempt, limitSeconds, now = new Date()) {
  const d = examDeadlineMs(attempt, limitSeconds, now);
  if (Number.isNaN(d)) return false;
  return new Date(now).getTime() > d;
}

// Count of questions with a real selection, for progress display.
function answeredCount(answers) {
  return Object.values(sanitizeAnswers(answers)).filter((v) => v !== null).length;
}

// Real elapsed seconds, taken from the server's startedAt rather than a
// client-side timestamp. The old client reset its startTime on every resume, so
// a 36-day-old attempt reported under two hours used.
function elapsedSeconds(startedAt, now = new Date()) {
  if (!startedAt) return 0;
  const started = new Date(startedAt).getTime();
  if (Number.isNaN(started)) return 0;
  return Math.max(0, Math.round((new Date(now).getTime() - started) / 1000));
}

module.exports = {
  sanitizeAnswers, mergeAutosave, mergeSubmission, answeredCount, elapsedSeconds,
  examDeadlineMs, isPastDeadline, BREAK_LIMIT_SECONDS,
};
