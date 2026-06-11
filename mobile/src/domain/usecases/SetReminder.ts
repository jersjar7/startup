import type { UseCase } from './UseCase';
import type { ReminderRepository } from '../repositories/ReminderRepository';
import type { ReminderScheduler } from '../services/ReminderScheduler';

export interface SetReminderInput {
  readonly minutes: number | null; // minutes since local midnight; null = off
}

// Persists the choice and (de)schedules the daily notification. Returns whether
// a reminder is now active (false if permission was denied or it's off).
export class SetReminder implements UseCase<SetReminderInput, boolean> {
  constructor(
    private readonly reminders: ReminderRepository,
    private readonly scheduler: ReminderScheduler,
  ) {}

  async execute({ minutes }: SetReminderInput): Promise<boolean> {
    if (minutes === null) {
      await this.reminders.setMinutes(null);
      await this.scheduler.cancel();
      return false;
    }
    const granted = await this.scheduler.requestPermission();
    if (!granted) {
      await this.reminders.setMinutes(null);
      return false;
    }
    await this.reminders.setMinutes(minutes);
    await this.scheduler.scheduleDaily(Math.floor(minutes / 60), minutes % 60);
    return true;
  }
}
