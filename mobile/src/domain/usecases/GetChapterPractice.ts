import type { UseCase } from './UseCase';
import type { DailySession, SessionItem } from '../entities/session';
import type { CardRepository } from '../repositories/CardRepository';
import type { ProblemRepository } from '../repositories/ProblemRepository';
import { isReviewableProblem } from '../entities/problem';

export interface GetChapterPracticeInput {
  readonly chapterId: string;
  readonly count: number;
  readonly now: number;
}

// A focused practice set drawn from ONE chapter (not the spaced-due queue) —
// for drilling a weak area. Reuses the same review UI.
export class GetChapterPractice implements UseCase<GetChapterPracticeInput, DailySession> {
  constructor(
    private readonly cards: CardRepository,
    private readonly problems: ProblemRepository,
  ) {}

  async execute({ chapterId, count, now }: GetChapterPracticeInput): Promise<DailySession> {
    const problems = (await this.problems.listByChapter(chapterId)).filter(isReviewableProblem);
    const cards = await this.cards.listByChapter(chapterId);

    const items: SessionItem[] = [];
    for (const c of cards) {
      items.push({
        kind: 'card',
        id: c.id,
        chapterId: c.chapterId,
        tier: 'concept',
        interaction: c.kind,
        prompt: c.prompt,
        answer: c.answer,
      });
    }
    for (const p of problems) {
      items.push({
        kind: 'problem',
        id: p.id,
        chapterId: p.chapterId,
        tier: p.tier,
        interaction: p.interaction,
        statement: p.statement,
        choices: p.choices,
        correctChoiceId: p.correctChoiceId,
        explanation: p.explanation,
      });
    }

    const picked = items.slice(0, count);
    return {
      date: new Date(now).toISOString().slice(0, 10),
      items: picked,
      estimatedMinutes: Math.max(1, Math.round(picked.length * 0.7)),
      paperHandoff: null,
    };
  }
}
