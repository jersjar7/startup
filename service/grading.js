// Desk answers are graded here, from the server's own copy of the bank, never
// by the browser (ADR 0038). The browser sends which choice was picked; the
// server decides whether it was right and what it is worth.
//
// Before this the practice and review routes took the browser's `isCorrect`
// at its word, so anyone who could post JSON could mark every answer right.
// Leagues made that worth closing.
//
// Old builds (a tab left open from before this shipped) send only
// `isCorrect`. They are still accepted so nobody loses a session: the
// right/wrong they report is kept for study history and review, but it earns
// only the attempt XP (see deskAnswerXp in xp.js).

const { deskAnswerXp, XP } = require('./xp.js');

const defaultContent = () => require('./content.json');

/** Is this one answer well formed? An answer names a problem and either the picked choice or, from an old build, right or wrong. */
function validAnswer(a) {
  if (!a || typeof a.problemId !== 'string' || !a.problemId) return false;
  if (a.choiceId !== undefined) return typeof a.choiceId === 'string';
  return typeof a.isCorrect === 'boolean';
}

/** Each answer, graded: { problemId, topicId?, choiceId?, isCorrect, graded, known }. */
function gradeAnswers(answers, content = defaultContent()) {
  return answers.map((a) => {
    const stored = content.problemsById[a.problemId];
    const out = { problemId: a.problemId };
    if (a.topicId) out.topicId = a.topicId;
    if (typeof a.choiceId === 'string') {
      out.choiceId = a.choiceId;
      out.isCorrect = !!stored && a.choiceId === stored.correctAnswerId;
      out.graded = true;
    } else {
      out.isCorrect = a.isCorrect === true;
      out.graded = false;
    }
    out.known = !!stored;
    return out;
  });
}

/**
 * The session's XP, answer by answer. `answeredToday` holds the problems
 * already answered at the desk on this day; a problem asked twice in one
 * session also counts once.
 */
function scoreAnswers(graded, answeredToday = new Set(), bonus = XP.sessionBonus) {
  const seen = new Set(answeredToday);
  let correct = 0;
  let incorrect = 0;
  let repeats = 0;
  for (const a of graded) {
    const repeat = seen.has(a.problemId);
    seen.add(a.problemId);
    if (repeat) repeats += 1;
    const xp = deskAnswerXp({ ...a, repeat });
    if (a.isCorrect) correct += xp;
    else incorrect += xp;
  }
  return { correct, incorrect, bonus, total: correct + incorrect + bonus, repeats };
}

module.exports = { validAnswer, gradeAnswers, scoreAnswers };
