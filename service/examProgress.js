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

module.exports = { sanitizeAnswers, mergeAutosave, mergeSubmission, answeredCount, elapsedSeconds };
