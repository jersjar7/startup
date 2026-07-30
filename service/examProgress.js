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

// Merge an incoming partial answer map over the stored one.
//
// Last write wins PER QUESTION, so two tabs or a retried request cannot lose
// work: whatever a question is not mentioned in the incoming set keeps its
// stored value. An explicit null clears that one answer.
function mergeAnswers(stored, incoming) {
  return { ...sanitizeAnswers(stored), ...sanitizeAnswers(incoming) };
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

module.exports = { sanitizeAnswers, mergeAnswers, answeredCount, elapsedSeconds };
