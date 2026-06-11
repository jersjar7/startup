import type { StudyPlan, PacingRegime } from '@/domain/entities/plan';
import type { PacingPolicy, PacingInput } from '@/domain/services/PacingPolicy';

const DAY = 24 * 60 * 60 * 1000;
const MAX_PROJECTION = 98; // never project 100% / a guaranteed pass

// Daily load + projection scale with time-to-exam (the spacing effect:
// Cepeda 2008). Three regimes; crunch compresses and adds a paper problem.
export class AdaptivePacingPolicy implements PacingPolicy {
  computePlan(input: PacingInput): StudyPlan {
    const days = daysUntil(input.examDate, input.now);
    // The plan targets mastery by the DAY BEFORE the exam — the final day is
    // light review / rest, never new learning (panel verdict, owner ratified).
    const studyDays = Math.max(0, days - 1);
    const regime = regimeFor(studyDays);
    const intensity = regime === 'crunch' ? 1.3 : 1;

    const dailyCardTarget = clamp(Math.round(input.minutesPerDay * 0.6 * intensity), 5, 40);
    const dailyPaperTarget = regime === 'crunch' ? 2 : 1;

    const gainPerDay = input.minutesPerDay * 0.03;
    const projectedPercent = Math.round(
      clamp(input.currentMasteryPercent + studyDays * gainPerDay, 0, MAX_PROJECTION),
    );

    return {
      minutesPerDay: input.minutesPerDay,
      daysUntilExam: days,
      regime,
      dailyCardTarget,
      dailyPaperTarget,
      projection: {
        currentPercent: Math.round(input.currentMasteryPercent),
        projectedPercent,
        examDate: input.examDate,
      },
    };
  }
}

function regimeFor(days: number): PacingRegime {
  if (days >= 56) return 'runway';
  if (days >= 14) return 'onPace';
  return 'crunch';
}

function daysUntil(examDate: string, now: number): number {
  const exam = Date.parse(`${examDate}T00:00:00`);
  return Number.isNaN(exam) ? 0 : Math.max(0, Math.ceil((exam - now) / DAY));
}

function clamp(n: number, lo: number, hi: number): number {
  return Math.max(lo, Math.min(hi, n));
}
