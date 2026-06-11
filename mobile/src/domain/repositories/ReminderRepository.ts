// Stores the chosen reminder hour (0–23), or null when reminders are off.
export interface ReminderRepository {
  getHour(): Promise<number | null>;
  setHour(hour: number | null): Promise<void>;
}
