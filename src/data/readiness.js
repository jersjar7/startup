// Shared exam-readiness + focus-area scoring.
//
// One coherent model used by both the dashboard and the post-session summary,
// so "where you stand" and "what to do next" never disagree. Input is a map of
// chapterId -> mastery percentage (0-100); weighting uses the NCEES exam
// question counts (single source of truth in exam-bank).

import { CHAPTERS } from './chapters';
import { getExamWeight } from './exam-bank/index';

/**
 * Weighted exam-readiness percentage: chapter mastery weighted by how many
 * questions each chapter contributes to the 110-question FE Civil exam.
 */
export function computeReadiness(masteryByChapterId = {}) {
  let totalWeight = 0;
  let weighted = 0;
  for (const ch of CHAPTERS) {
    const w = getExamWeight(ch.id);
    totalWeight += w;
    weighted += (masteryByChapterId[ch.id] || 0) * w;
  }
  return Math.round(weighted / (totalWeight || 1));
}

/**
 * The chapters where effort moves the score most: low mastery x high exam
 * weight. Returns [{ ch, masteryPct, weight, focusScore }] sorted strongest-first.
 */
export function computeFocusAreas(masteryByChapterId = {}, { exclude = [], limit = 3, masteredAt = 90 } = {}) {
  return CHAPTERS
    .map((ch) => ({
      ch,
      masteryPct: masteryByChapterId[ch.id] || 0,
      weight: getExamWeight(ch.id),
    }))
    .filter((c) => c.masteryPct < masteredAt && !exclude.includes(c.ch.id))
    .map((c) => ({ ...c, focusScore: (100 - c.masteryPct) * c.weight }))
    .sort((a, b) => b.focusScore - a.focusScore)
    .slice(0, limit);
}

/**
 * Human-readable mastery tier. Mastery language only — never a pass
 * probability or "ready" verdict (nobody can promise that).
 */
export function readinessLabel(pct) {
  if (pct >= 85) return 'Strong concept coverage';
  if (pct >= 70) return 'Solid concept coverage';
  if (pct >= 40) return 'Building momentum';
  return 'Just getting started';
}
