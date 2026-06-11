import type { UseCase } from './UseCase';
import type { ReminderRepository } from '../repositories/ReminderRepository';

export class GetReminder implements UseCase<void, number | null> {
  constructor(private readonly reminders: ReminderRepository) {}
  execute(): Promise<number | null> {
    return this.reminders.getHour();
  }
}
