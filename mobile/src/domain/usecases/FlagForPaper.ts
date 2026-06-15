import type { UseCase } from './UseCase';
import type { PaperHandoff } from '../entities/session';
import { localIsoDay } from '../entities/streak';

export interface PaperFlag {
  readonly itemId: string;
  readonly chapterId: string;
  readonly statement: string;
  readonly source: 'ios' | 'android' | 'web';
  readonly ts: number;
  readonly localDate: string;
}

export interface PaperFlagTransport {
  flagForPaper(flags: readonly PaperFlag[]): Promise<{ saved: number }>;
}

export interface FlagForPaperInput {
  readonly handoff: PaperHandoff;
  readonly now: number;
}

// Sends a paper-tier problem the user set aside to the shared hand-off list, so
// it shows up on the web "Tonight" card. The hand-off IS the product: this is
// what makes web and mobile one study plan, not two to-do lists.
export class FlagForPaper implements UseCase<FlagForPaperInput, void> {
  constructor(
    private readonly transport: PaperFlagTransport,
    private readonly source: 'ios' | 'android' | 'web',
  ) {}

  async execute({ handoff, now }: FlagForPaperInput): Promise<void> {
    await this.transport.flagForPaper([
      {
        itemId: handoff.problemId,
        chapterId: handoff.chapterId,
        statement: handoff.statement,
        source: this.source,
        ts: now,
        localDate: localIsoDay(now),
      },
    ]);
  }
}
