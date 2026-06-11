import type { UseCase } from './UseCase';
import type { ReminderRepository } from '../repositories/ReminderRepository';
import type { ReminderScheduler } from '../services/ReminderScheduler';

export interface SetReminderInput {
  readonly hour: number | null; // null = off
}

// Persists the choice and (de)schedules the daily notification. Returns whether
// a reminder is now active (false if permission was denied or it's off).
export class SetReminder implements UseCase<SetReminderInput, boolean> {
  constructor(
    private readonly reminders: ReminderRepository,
    private readonly scheduler: ReminderScheduler,
  ) {}

  async execute({ hour }: SetReminderInput): Promise<boolean> {
    if (hour === null) {
      await this.reminders.setHour(null);
      await this.scheduler.cancel();
      return false;
    }
    const granted = await this.scheduler.requestPermission();
    if (!granted) {
      await this.reminders.setHour(null);
      return false;
    }
    await this.reminders.setHour(hour);
    await this.scheduler.scheduleDaily(hour);
    return true;
  }
}
