// Feedback on a game round, from the flag on the phone.
//
// A student who finds an explanation or a game unclear taps the flag, picks
// what it is about, writes a line, and sends it. The report is stored and the
// owner gets one email per report, with the game, the round, the account and
// the app build attached, so nobody has to ask which one they meant.

// The parts of a round (feedback_sheet.dart names them the same). 'game' and
// 'other' are what build 848 sent before the list grew.
const KINDS = new Set(['question', 'drawing', 'howto', 'concept', 'answer', 'explanation', 'game', 'other']);
const MAX_TEXT = 1000;
const PER_HOUR = 5;

/**
 * Checks a report body. Returns { ok: true, value } with the cleaned report,
 * or { ok: false, msg } with what is wrong, in words the app can show.
 */
function validateFeedback(body) {
  if (!body || typeof body !== 'object') return { ok: false, msg: 'Nothing to send.' };
  const kind = typeof body.kind === 'string' ? body.kind.trim() : '';
  if (!KINDS.has(kind)) return { ok: false, msg: 'Say what it is about.' };
  const text = typeof body.text === 'string' ? body.text.trim() : '';
  if (!text) return { ok: false, msg: 'Write a line first.' };
  if (text.length > MAX_TEXT) return { ok: false, msg: `Keep it under ${MAX_TEXT} characters.` };
  const gameId = typeof body.gameId === 'string' ? body.gameId.trim().slice(0, 80) : '';
  const chapterId = typeof body.chapterId === 'string' ? body.chapterId.trim().slice(0, 40) : '';
  if (!gameId || !chapterId) return { ok: false, msg: 'Which game this is about got lost. Try again.' };
  const round = Number.isInteger(body.round) && body.round >= 0 && body.round < 1000 ? body.round : null;
  const build = typeof body.build === 'string' ? body.build.trim().slice(0, 20) : null;
  // The chip's wording, as the student saw it; what the owner reads.
  const kindLabel = typeof body.kindLabel === 'string' && body.kindLabel.trim()
    ? body.kindLabel.trim().slice(0, 40)
    : kind;
  return { ok: true, value: { kind, kindLabel, text, gameId, chapterId, round, build } };
}

/** True when this account has already sent PER_HOUR reports in the last hour. */
function overTheHourlyLimit(sentInLastHour) {
  return sentInLastHour >= PER_HOUR;
}

module.exports = { validateFeedback, overTheHourlyLimit, KINDS, MAX_TEXT, PER_HOUR };
