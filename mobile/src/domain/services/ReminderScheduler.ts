// Domain PORT for scheduling a daily study reminder. Implemented in data/ via
// expo-notifications (a no-op on web).
export interface ReminderScheduler {
  requestPermission(): Promise<boolean>;
  /** Schedule the daily reminder at an exact local time. */
  scheduleDaily(hour: number, minute: number): Promise<void>;
  cancel(): Promise<void>;
}
