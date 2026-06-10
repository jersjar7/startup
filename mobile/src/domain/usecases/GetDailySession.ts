import type { UseCase } from './UseCase';
import type { DailySession, SessionItem, PaperHandoff } from '../entities/session';
import type { ReviewRepository } from '../repositories/ReviewRepository';
import type { CardRepository } from '../repositories/CardRepository';
import type { ProblemRepository } from '../repositories/ProblemRepository';
import { needsPaper } from '../entities/tiers';
import { isReviewableProblem } from '../entities/problem';

export interface GetDailySessionInput {
  readonly now: number;
  readonly cardTarget: number;
}

// Builds the bounded daily set: due cards (recall) + tap-the-trap problems,
// interleaved across chapters, plus the single paper problem for the desk.
export class GetDailySession implements UseCase<GetDailySessionInput, DailySession> {
  constructor(
    private readonly reviews: ReviewRepository,
    private readonly cards: CardRepository,
    private readonly problems: ProblemRepository,
  ) {}

  async execute({ now, cardTarget }: GetDailySessionInput): Promise<DailySession> {
    const dueIds = await this.reviews.dueItems(now, cardTarget);
    const cardById = new Map((await this.cards.listAll()).map((c) => [c.id, c] as const));
    const problemById = new Map((await this.problems.listAll()).map((p) => [p.id, p] as const));

    const items: SessionItem[] = [];
    for (const id of dueIds) {
      const card = cardById.get(id);
      if (card) {
        items.push({
          kind: 'card',
          id: card.id,
          chapterId: card.chapterId,
          tier: 'concept',
          interaction: card.kind,
          prompt: card.prompt,
          answer: card.answer,
        });
        continue;
      }
      const p = problemById.get(id);
      if (p && isReviewableProblem(p)) {
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
    }

    const interleaved = interleaveByChapter(items);
    return {
      date: new Date(now).toISOString().slice(0, 10),
      items: interleaved,
      estimatedMinutes: Math.max(1, Math.round(interleaved.length * 0.7)),
      paperHandoff: await this.pickPaperHandoff(),
    };
  }

  private async pickPaperHandoff(): Promise<PaperHandoff | null> {
    const all = await this.problems.listAll();
    const paper = all.find((p) => needsPaper(p.tier));
    return paper
      ? { problemId: paper.id, chapterId: paper.chapterId, statement: paper.statement }
      : null;
  }
}

// Round-robin across chapters so consecutive items rarely share a topic.
function interleaveByChapter(items: readonly SessionItem[]): SessionItem[] {
  const queues = new Map<string, SessionItem[]>();
  for (const it of items) {
    const q = queues.get(it.chapterId) ?? [];
    q.push(it);
    queues.set(it.chapterId, q);
  }
  const out: SessionItem[] = [];
  let progressed = true;
  while (progressed) {
    progressed = false;
    for (const q of queues.values()) {
      const next = q.shift();
      if (next) {
        out.push(next);
        progressed = true;
      }
    }
  }
  return out;
}
