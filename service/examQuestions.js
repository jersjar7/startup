// The question set a paid exam attempt is graded against, taken from the
// server's own copy of the exam bank.
//
// The browser still picks which 110 questions to show (it already has the
// bank for the free preview and practice), but it no longer decides what is
// correct. Before this, /exam/start stored whatever the client posted,
// correctAnswerId included, and scored against it, so anyone could post their
// own answer key and get 110/110, or post a one-question exam (see
// docs/EXAM-SIMULATION.md, open issue 1).
//
// What the client may still choose: which exam-bank question goes in each
// chapter's slots, and the order its choices are shown in. Everything else
// (the statement, the choice text, the answer, the chapter) is the server's.

function buildExamQuestions(clientQuestions, content, distribution) {
  if (!Array.isArray(clientQuestions) || clientQuestions.length === 0) {
    return { error: 'Questions array is required' };
  }

  const expected = Object.values(distribution).reduce((a, b) => a + b, 0);
  if (clientQuestions.length !== expected) {
    return { error: `An exam has ${expected} questions` };
  }

  const seen = new Set();
  const perChapter = {};
  const questions = [];

  for (const q of clientQuestions) {
    const id = q && typeof q.id === 'string' ? q.id : null;
    const index = id ? content.problemIndex[id] : null;
    const stored = id ? content.problemsById[id] : null;
    if (!index || !stored || index.pool !== 'exam') {
      return { error: 'Unknown exam question' };
    }
    if (seen.has(id)) return { error: 'A question appears twice' };
    seen.add(id);
    perChapter[index.chapterId] = (perChapter[index.chapterId] || 0) + 1;

    // Keep the shuffled order the student saw, but only as an order of the
    // server's own choices.
    const byId = new Map((stored.choices || []).map((c) => [c.id, c]));
    const order = Array.isArray(q.choices) ? q.choices.map((c) => c && c.id) : [];
    const sameSet =
      order.length === byId.size && new Set(order).size === byId.size && order.every((cid) => byId.has(cid));
    const choices = sameSet ? order.map((cid) => ({ ...byId.get(cid) })) : (stored.choices || []).map((c) => ({ ...c }));

    questions.push({
      id,
      chapterId: index.chapterId,
      lessonId: index.lessonId,
      statement: stored.statement,
      choices,
      correctAnswerId: stored.correctAnswerId,
      type: stored.type,
      diagram: diagramFor(stored.diagram),
    });
  }

  for (const [chapterId, want] of Object.entries(distribution)) {
    if ((perChapter[chapterId] || 0) !== want) {
      return { error: 'The questions do not follow the exam\'s chapter weights' };
    }
  }

  return { questions };
}

// The server's copy carries a figureId for the pre-rendered picture; the
// browser's never did. Stored without it, the attempt holds exactly the
// diagram the exam page draws.
function diagramFor(diagram) {
  if (!diagram) return null;
  const { figureId, ...rest } = diagram; // eslint-disable-line no-unused-vars
  return rest;
}

module.exports = { buildExamQuestions };
