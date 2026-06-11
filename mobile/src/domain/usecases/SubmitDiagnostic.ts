import type { UseCase } from './UseCase';
import type { DiagnosticRepository } from '../repositories/DiagnosticRepository';

export interface DiagnosticAnswer {
  readonly chapterId: string;
  readonly correct: boolean;
}

// Familiarity is capped well below "ready" — a right answer is a hint you've seen
// it, not proof you've mastered it. Study overtakes this over time.
const CORRECT = 0.4;
const WRONG = 0.12;

export class SubmitDiagnostic implements UseCase<readonly DiagnosticAnswer[], void> {
  constructor(private readonly diagnostic: DiagnosticRepository) {}

  async execute(answers: readonly DiagnosticAnswer[]): Promise<void> {
    const familiarity: Record<string, number> = {};
    for (const a of answers) familiarity[a.chapterId] = a.correct ? CORRECT : WRONG;
    await this.diagnostic.save(familiarity);
  }
}
