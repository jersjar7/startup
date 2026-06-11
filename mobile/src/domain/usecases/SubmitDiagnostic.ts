import type { UseCase } from './UseCase';
import type { DiagnosticRepository } from '../repositories/DiagnosticRepository';
import type { ReviewRepository } from '../repositories/ReviewRepository';
import type { SpacedRepetitionScheduler } from '../services/SpacedRepetitionScheduler';

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
  ) {}

  async execute(answers: readonly DiagnosticAnswer[]): Promise<void> {
    const familiarity: Record<string, number> = {};
    const now = Date.now();
    for (const a of answers) {
      familiarity[a.chapterId] = a.correct ? CORRECT : WRONG;
      // Seed a schedule for each answered item so the very first review
      // session doesn't replay a question the user saw two minutes ago.
      const base = (await this.reviews.scheduleFor(a.problemId)) ?? this.scheduler.start(a.problemId, now);
      await this.reviews.save(this.scheduler.review(base, a.correct ? 'gotIt' : 'forgot', now));
    }
    await this.diagnostic.save(familiarity);
  }
}
