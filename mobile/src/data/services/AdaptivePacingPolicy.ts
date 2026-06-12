import type { StudyPlan } from '@/domain/entities/plan';
import type { PacingPolicy, PacingInput } from '@/domain/services/PacingPolicy';
import { computeDailyPlan } from '@/shared/scheduler';

// Daily load + projection scale with time-to-exam (the spacing effect:
// Cepeda 2008). The regime/target/projection math lives in the shared scheduler
// module (mirror of service/shared/scheduler.js, parity-tested) so web and
// mobile agree. This class adapts the shared plan to the domain's StudyPlan.
export class AdaptivePacingPolicy implements PacingPolicy {
  computePlan(input: PacingInput): StudyPlan {
    const plan = computeDailyPlan({
      now: input.now,
      examDate: input.examDate,
      minutesPerDay: input.minutesPerDay,
      currentMasteryPercent: input.currentMasteryPercent,
    });
    return {
      minutesPerDay: plan.minutesPerDay,
      daysUntilExam: plan.daysUntilExam ?? 0,
      regime: plan.regime,
      dailyCardTarget: plan.dailyCardTarget,
      dailyPaperTarget: plan.dailyPaperTarget,
      projection: plan.projection ?? {
        currentPercent: Math.round(input.currentMasteryPercent),
        projectedPercent: Math.round(input.currentMasteryPercent),
        examDate: input.examDate,
      },
    };
  }
}
