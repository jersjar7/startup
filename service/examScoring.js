// Pure scoring for one exam attempt.
//
// Extracted so that BOTH paths can score identically: a normal submit, and an
// attempt whose window closed without the customer ever pressing submit. Before
// this, expiry simply stamped status:'expired' and abandoned everything the
// autosave had collected, so a customer's whole 5h20m exam was thrown away by
// the very fix meant to protect it.

// Unanswered questions must never read as correct.
//
// The previous inline version computed `selectedId === q.correctAnswerId` with no
// guard, so any question where BOTH sides were null/undefined scored as correct.
// The tally was safe because counting sat behind `if (selectedId)`, but the
// per-question `isCorrect: true` still reached the results screen, telling a
// customer they got a question right that they never answered.
function isAnswerCorrect(selectedId, correctAnswerId) {
  if (!selectedId || !correctAnswerId) return false;
  return selectedId === correctAnswerId;
}

// answerMap is keyed by questionId. Returns everything needed to persist and to
// render a result, and mutates nothing.
function scoreAttempt(questions = [], answerMap = {}, totalQuestions = null) {
  const chapterScores = {};
  let totalCorrect = 0;
  let totalAttempted = 0;

  const scoredQuestions = questions.map((q) => {
    const selectedId = answerMap[q.id] || null;
    const isCorrect = isAnswerCorrect(selectedId, q.correctAnswerId);

    if (!chapterScores[q.chapterId]) {
      chapterScores[q.chapterId] = { correct: 0, total: 0 };
    }
    // Every question in the chapter counts toward its total, answered or not —
    // an unanswered question is a wrong answer on the real exam.
    chapterScores[q.chapterId].total += 1;

    if (selectedId) {
      totalAttempted += 1;
      if (isCorrect) {
        totalCorrect += 1;
        chapterScores[q.chapterId].correct += 1;
      }
    }

    return { ...q, selectedAnswerId: selectedId, isCorrect };
  });

  for (const ch of Object.keys(chapterScores)) {
    const s = chapterScores[ch];
    s.percentage = s.total > 0 ? Math.round((s.correct / s.total) * 100) : 0;
  }

  // Denominator is the full exam, not the number attempted: skipping 60
  // questions must not flatter the score.
  const denominator = totalQuestions || questions.length;
  const overallPercentage = denominator > 0
    ? Math.round((totalCorrect / denominator) * 100)
    : 0;

  return { scoredQuestions, chapterScores, totalCorrect, totalAttempted, overallPercentage };
}

module.exports = { scoreAttempt, isAnswerCorrect };
