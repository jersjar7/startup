import type { UseCase } from './UseCase';
import type { DiagnosticRepository } from '../repositories/DiagnosticRepository';
import type { ReviewRepository } from '../repositories/ReviewRepository';
import type { SpacedRepetitionScheduler } from '../services/SpacedRepetitionScheduler';
import type { SyncOutboxRepository } from '../repositories/SyncOutboxRepository';
import { localIsoDay } from '../entities/streak';

export interface DiagnosticAnswer {
  readonly problemId: string;
  readonly chapterId: string;
  readonly correct: boolean;
}

// Familiarity is capped well below "ready" — a right answer is a hint you've seen
// it, not proof you've mastered it. Study overtakes this over time.
const CORRECT = 0.4;
const WRONG = 0.12;

export class SubmitDiagnostic implements UseCase<readonly DiagnosticAnswer[], void> {
  constructor(
    private readonly diagnostic: DiagnosticRepository,
    private readonly reviews: ReviewRepository,
    private readonly scheduler: SpacedRepetitionScheduler,
    private readonly outbox: SyncOutboxRepository,
    private readonly source: 'ios' | 'android' | 'web',
  ) {}

  async execute(answers: readonly DiagnosticAnswer[]): Promise<void> {
    const familiarity: Record<string, number> = {};
    const now = Date.now();
    for (const a of answers) {
      familiarity[a.chapterId] = a.correct ? CORRECT : WRONG;
      // Seed a schedule for each answered item so the very first review
      // session doesn't replay a question the user saw two minutes ago.
      const base = (await this.reviews.scheduleFor(a.problemId)) ?? this.scheduler.start(a.problemId, now);
      const grade = a.correct ? ('gotIt' as const) : ('forgot' as const);
      await this.reviews.save(this.scheduler.review(base, grade, now));
      await this.outbox.enqueue({
        eventId: `${now.toString(36)}-${Math.random().toString(36).slice(2, 12)}`,
        itemId: a.problemId,
        chapterId: a.chapterId,
        grade,
        source: this.source,
        deviceId: await this.outbox.getDeviceId(),
        ts: now,
        localDate: localIsoDay(now),
      });
    }
    await this.diagnostic.save(familiarity);
  }
}
