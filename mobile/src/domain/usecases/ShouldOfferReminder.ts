import type { UseCase } from './UseCase';
import type { ReminderRepository } from '../repositories/ReminderRepository';

// True exactly once: the first completed session with reminders off triggers
// the one-time offer sheet (jake's verdict — at the motivation peak, never
// nagging after that).
export class ShouldOfferReminder implements UseCase<void, boolean> {
  constructor(private readonly reminders: ReminderRepository) {}

  async execute(): Promise<boolean> {
    if ((await this.reminders.getMinutes()) !== null) return false;
    if (await this.reminders.wasOffered()) return false;
    await this.reminders.markOffered();
    return true;
  }
}
