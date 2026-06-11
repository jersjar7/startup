import type { UseCase } from './UseCase';
import type { Problem } from '../entities/problem';
import { isReviewableProblem } from '../entities/problem';
import type { ProblemRepository } from '../repositories/ProblemRepository';
import type { ChapterRepository } from '../repositories/ChapterRepository';

export interface GetDiagnosticQuestionsInput {
  readonly count: number;
}

// One question from each of the top-N chapters by exam weight — a short check to
// seed where the user stands.
export class GetDiagnosticQuestions implements UseCase<GetDiagnosticQuestionsInput, readonly Problem[]> {
  constructor(
    private readonly chapters: ChapterRepository,
    private readonly problems: ProblemRepository,
  ) {}

  async execute({ count }: GetDiagnosticQuestionsInput): Promise<readonly Problem[]> {
    const top = [...(await this.chapters.listAll())]
      .sort((a, b) => b.examWeight - a.examWeight)
      .slice(0, count);
    const out: Problem[] = [];
    for (const ch of top) {
      const reviewable = (await this.problems.listByChapter(ch.id)).filter(isReviewableProblem);
      if (reviewable.length > 0) out.push(reviewable[0]);
    }
    return out;
  }
}
