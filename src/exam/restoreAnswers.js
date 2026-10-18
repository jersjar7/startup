// Which answers a resumed exam starts from: the server's, with this browser's
// own saved copy laid over them per question where the local choice is newer.
//
// The local copy exists because it can be newer than the last save that
// reached the server. But another tab may have saved a newer answer since, so
// each answer carries the time it was chosen and the newer one wins. A local
// copy from before answers were stamped is laid over as it always was.
export function restoreAnswers(serverAnswers = {}, serverTimes = {}, local = null) {
  const answers = { ...(serverAnswers || {}) };
  const times = { ...(serverTimes || {}) };
  if (!local || typeof local.userAnswers !== 'object' || !local.userAnswers) return { answers, times };
  const localTimes = local.answerTimes && typeof local.answerTimes === 'object' ? local.answerTimes : null;
  for (const [qid, choiceId] of Object.entries(local.userAnswers)) {
    const at = localTimes ? Number(localTimes[qid]) || null : null;
    const st = times[qid] ?? null;
    const newer = at == null ? st == null : st == null || at >= st;
    if (!newer) continue;
    answers[qid] = choiceId;
    if (at != null) times[qid] = at;
  }
  return { answers, times };
}
